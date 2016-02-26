From: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Fri, 26 Feb 2016 17:48:49 +0100
Message-ID: <56D081F1.3030801@openwrt.org>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1456492163-11437-1-git-send-email-michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2016-02-26 14:09, Michal Kazior wrote:
> Since 11n aggregation become important to get the
> best out of txops. However aggregation inherently
> requires buffering and queuing. Once variable
> medium conditions to different associated stations
> is considered it became apparent that bufferbloat
> can't be simply fought with qdiscs for wireless
> drivers. 11ac with MU-MIMO makes the problem
> worse because the bandwidth-delay product becomes
> even greater.
> 
> This bases on codel5 and sch_fq_codel.c. It may
> not be the Right Thing yet but it should at least
> provide a framework for more improvements.
Nice work!

> I guess dropping rate could factor in per-station
> rate control info but I don't know how this should
> exactly be done. HW rate control drivers would
> need extra work to take advantage of this.
> 
> This obviously works only with drivers that use
> wake_tx_queue op.
> 
> Note: This uses IFF_NO_QUEUE to get rid of qdiscs
> for wireless drivers that use mac80211 and
> implement wake_tx_queue op.
> 
> Moreover the current txq_limit and latency setting
> might need tweaking. Either from userspace or be
> dynamically scaled with regard to, e.g. number of
> associated stations.
> 
> FWIW This already works nicely with ath10k's (not
> yey merged) pull-push congestion control for
> MU-MIMO as far as throughput is concerned.
> 
> Evaluating latency improvements is a little tricky
> at this point if a driver is using more queue
> layering and/or its firmware controls tx
> scheduling - hence I don't have any solid data on
> this. I'm open for suggestions though.
> 
> It might also be a good idea to do the following
> in the future:
> 
>  - make generic tx scheduling which does some RR
>    over per-sta-tid queues and dequeues bursts of
>    packets to form a PPDU to fit into designated
>    txop timeframe and bytelimit
> 
>    This could in theory be shared and used by
>    ath9k and (future) mt76.
> 
>    Moreover tx scheduling could factor in rate
>    control info and keep per-station number of
>    queued packets at a sufficient low threshold to
>    avoid queue buildup for slow stations. Emmanuel
>    already did similar experiment for iwlwifi's
>    station mode and got promising results.
> 
>  - make software queueing default internally in
>    mac80211. This could help other drivers to get
>    at least some benefit from mac80211 smarter
>    queueing.
> 
> Signed-off-by: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
> ---
>  include/net/mac80211.h     |  36 ++++-
>  net/mac80211/agg-tx.c      |   8 +-
>  net/mac80211/codel.h       | 260 +++++++++++++++++++++++++++++++
>  net/mac80211/codel_i.h     |  89 +++++++++++
>  net/mac80211/ieee80211_i.h |  27 +++-
>  net/mac80211/iface.c       |  25 ++-
>  net/mac80211/main.c        |   9 +-
>  net/mac80211/rx.c          |   2 +-
>  net/mac80211/sta_info.c    |  10 +-
>  net/mac80211/sta_info.h    |  27 ++++
>  net/mac80211/tx.c          | 370 ++++++++++++++++++++++++++++++++++++++++-----
>  net/mac80211/util.c        |  20 ++-
>  12 files changed, 805 insertions(+), 78 deletions(-)
>  create mode 100644 net/mac80211/codel.h
>  create mode 100644 net/mac80211/codel_i.h
> 

> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
> index af584f7cdd63..f42f898cb8b5 100644
> --- a/net/mac80211/tx.c
> +++ b/net/mac80211/tx.c
> + [...]
> +static void ieee80211_txq_enqueue(struct ieee80211_local *local,
> +				  struct txq_info *txqi,
> +				  struct sk_buff *skb)
> +{
> +	struct ieee80211_fq *fq = &local->fq;
> +	struct ieee80211_hw *hw = &local->hw;
> +	struct txq_flow *flow;
> +	struct txq_flow *i;
> +	size_t idx = fq_hash(fq, skb);
> +
> +	flow = &fq->flows[idx];
> +
> +	if (flow->txqi)
> +		flow = &txqi->flow;
I'm not sure I understand this part correctly, but shouldn't that be:
	if (flow->txqi && flow->txqi != txqi)

> +
> +	/* The following overwrites `vif` pointer effectively. It is later
> +	 * restored using txq structure.
> +	 */
> +	IEEE80211_SKB_CB(skb)->control.enqueue_time = codel_get_time();
> +
> +	flow->txqi = txqi;
> +	flow->backlog += skb->len;
> +	txqi->backlog_bytes += skb->len;
> +	txqi->backlog_packets++;
> +	fq->backlog++;
> +
> +	if (list_empty(&flow->backlogchain))
> +		i = list_last_entry(&fq->backlogs, struct txq_flow, backlogchain);
> +	else
> +		i = flow;
> +
> +	list_for_each_entry_continue_reverse(i, &fq->backlogs, backlogchain)
> +		if (i->backlog > flow->backlog)
> +			break;
> +
> +	list_move(&flow->backlogchain, &i->backlogchain);
> +
> +	if (list_empty(&flow->flowchain)) {
> +		flow->deficit = fq->quantum;
> +		list_add_tail(&flow->flowchain, &txqi->new_flows);
> +	}
> +
> +	__skb_queue_tail(&flow->queue, skb);
> +
> +	if (fq->backlog > hw->txq_limit)
> +		fq_drop(local);
> +}
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
