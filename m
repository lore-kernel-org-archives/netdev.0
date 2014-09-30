From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Tue, 30 Sep 2014 04:48:56 -0700
Message-ID: <1412077736.30721.54.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140930085114.24043.81310.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:56327 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbaI3Ls7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 07:48:59 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so672237pde.20
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 04:48:59 -0700 (PDT)
In-Reply-To: <20140930085114.24043.81310.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 10:53 +0200, Jesper Dangaard Brouer wrote:
> Based on DaveM's recent API work on dev_hard_start_xmit(), that allows
> sending/processing an entire skb list.
> 
> This patch implements qdisc bulk dequeue, by allowing multiple packets
> to be dequeued in dequeue_skb().
> 
> The optimization principle for this is two fold, (1) to amortize
> locking cost and (2) avoid expensive tailptr update for notifying HW.
>  (1) Several packets are dequeued while holding the qdisc root_lock,
> amortizing locking cost over several packet.  The dequeued SKB list is
> processed under the TXQ lock in dev_hard_start_xmit(), thus also
> amortizing the cost of the TXQ lock.
>  (2) Further more, dev_hard_start_xmit() will utilize the skb->xmit_more
> API to delay HW tailptr update, which also reduces the cost per
> packet.
> 
> One restriction of the new API is that every SKB must belong to the
> same TXQ.  This patch takes the easy way out, by restricting bulk
> dequeue to qdisc's with the TCQ_F_ONETXQUEUE flag, that specifies the
> qdisc only have attached a single TXQ.
> 
> Some detail about the flow; dev_hard_start_xmit() will process the skb
> list, and transmit packets individually towards the driver (see
> xmit_one()).  In case the driver stops midway in the list, the
> remaining skb list is returned by dev_hard_start_xmit().  In
> sch_direct_xmit() this returned list is requeued by dev_requeue_skb().
> 
> To avoid overshooting the HW limits, which results in requeuing, the
> patch limits the amount of bytes dequeued, based on the drivers BQL
> limits.  In-effect bulking will only happen for BQL enabled drivers.
> Besides the bytelimit from BQL, also limit bulking to maximum 7
> packets to avoid any issues with available descriptor in HW and
> any HoL issues measured at 100Mbit/s.
> 
> For now, as a conservative approach, don't bulk dequeue GSO and
> segmented GSO packets, because testing showed requeuing occuring
> with segmented GSO packets.
> 
> Jointed work with Hannes, Daniel and Florian.
> 
> Testing:
> --------
>  Demonstrating the performance improvement of qdisc dequeue bulking, is
> tricky because the effect only "kicks-in" once the qdisc system have a
> backlog. Thus, for a backlog to form, we need either 1) to exceed wirespeed
> of the link or 2) exceed the capability of the device driver.
> 
> For practical use-cases, the measureable effect of this will be a
> reduction in CPU usage
> 
> 01-TCP_STREAM:
> --------------
> Testing effect for TCP involves disabling TSO and GSO, because TCP
> already benefit from bulking, via TSO and especially for GSO segmented
> packets.  This patch view TSO/GSO as a seperate kind of bulking, and
> avoid further bulking of these packet types.
> 
> The measured perf diff benefit (at 10Gbit/s) for TCP_STREAM were 4.66%
> less CPU used on calls to _raw_spin_lock() (mostly from sch_direct_xmit).
> 
> Tool mpstat, while stressing the system with netperf 24x TCP_STREAM, shows:
>  * Disabled bulking: 8.30% soft 88.75% idle
>  * Enabled  bulking: 7.80% soft 89.36% idle
> 
> 02-UDP_STREAM
> -------------
> The measured perf diff benefit for UDP_STREAM were 5.26% less CPU used
> on calls to _raw_spin_lock().  UDP_STREAM with packet size -m 1472 (to
> avoid sending UDP/IP fragments).
> 
> 03-trafgen driver test
> ----------------------
> The performance of the 10Gbit/s ixgbe driver is limited due to
> updating the HW ring-queue tail-pointer on every packet.  As
> previously demonstrated with pktgen.
> 
> Using trafgen to send RAW frames from userspace (via AF_PACKET), and
> forcing it through qdisc path (with option --qdisc-path and -t0),
> sending with 12 CPUs.
> 
> I can demonstrate this driver layer limitation:
>  * 12.8 Mpps with no qdisc bulking
>  * 14.8 Mpps with qdisc bulking (full 10G-wirespeed)
> 
> 04-netperf-wrapper
> ------------------
> I've designed some tests for the tool "netperf-wrapper" that tries to
> measure the Head-of-Line (HoL) blocking effect.
> 
> The bulking "budget" limit of 7 packets are choosen, based on testing
> with netperf-wrapper.  With driver igb at 100Mbit/s and a budget of
> max 7 packets I cannot measure any added HoL latency.  Increasing this
> value to 8 packets, I observed a fluctuating added 0.24ms delay
> corrosponding to 3000 bytes at 100Mbit/s.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> ---
> V5:
>  - Changed "budget" limit to 7 packets (from 8)
>  - Choosing to use skb->len, because BQL uses that
>  - Added testing results to patch desc
> 
> V4:
> - Patch rewritten in the Red Hat Neuchatel office jointed work with
>   Hannes, Daniel and Florian.
> - Conservative approach of only using on BQL enabled drivers
> - No user tunable parameter, but limit bulking to 8 packets.
> - For now, avoid bulking GSO packets packets.
> 
> V3:
>  - Correct use of BQL
>  - Some minor adjustments based on feedback.
>  - Default setting only bulk dequeue 1 extra packet (2 packets).
> 
> V2:
>  - Restruct functions, split out functionality
>  - Use BQL bytelimit to avoid overshooting driver limits
> 
> 
>  include/net/sch_generic.h |   16 +++++++++++++++
>  net/sched/sch_generic.c   |   47 +++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 61 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index e65b8e0..0654dfa 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -6,6 +6,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/pkt_sched.h>
>  #include <linux/pkt_cls.h>
> +#include <linux/dynamic_queue_limits.h>
>  #include <net/gen_stats.h>
>  #include <net/rtnetlink.h>
>  
> @@ -111,6 +112,21 @@ static inline void qdisc_run_end(struct Qdisc *qdisc)
>  	qdisc->__state &= ~__QDISC___STATE_RUNNING;
>  }
>  
> +static inline bool qdisc_may_bulk(const struct Qdisc *qdisc)
> +{
> +	return qdisc->flags & TCQ_F_ONETXQUEUE;
> +}
> +
> +static inline int qdisc_avail_bulklimit(const struct netdev_queue *txq)
> +{
> +#ifdef CONFIG_BQL
> +	/* Non-BQL migrated drivers will return 0, too. */
> +	return dql_avail(&txq->dql);
> +#else
> +	return 0;
> +#endif
> +}
> +
>  static inline bool qdisc_is_throttled(const struct Qdisc *qdisc)
>  {
>  	return test_bit(__QDISC_STATE_THROTTLED, &qdisc->state) ? true : false;
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 11b28f6..0fa8f0e 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -56,6 +56,42 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>  	return 0;
>  }
>  
> +static struct sk_buff *try_bulk_dequeue_skb(struct Qdisc *q,
> +					    struct sk_buff *head_skb,
> +					    int bytelimit)
> +{
> +	struct sk_buff *skb, *tail_skb = head_skb;
> +	int budget = 7; /* For now, conservatively choosen limit */
> +
> +	while (bytelimit > 0 && --budget > 0) {
> +		/* For now, don't bulk dequeue GSO (or GSO segmented) pkts */
> +		if (tail_skb->next || skb_is_gso(tail_skb))
> +			break;
> +
> +		skb = q->dequeue(q);
> +		if (!skb)
> +			break;
> +
> +		bytelimit -= skb->len; /* covers GSO len */
> +		skb = validate_xmit_skb(skb, qdisc_dev(q));
> +		if (!skb)
> +			break;
> +
> +		/* "skb" can be a skb list after validate call above
> +		 * (GSO segmented), but it is okay to append it to
> +		 * current tail_skb->next, because next round will exit
> +		 * in-case "tail_skb->next" is a skb list.
> +		 */
> +		tail_skb->next = skb;
> +		tail_skb = skb;
> +	}
> +
> +	return head_skb;
> +}
> +
> +/* Note that dequeue_skb can possibly return a SKB list (via skb->next).
> + * A requeued skb (via q->gso_skb) can also be a SKB list.
> + */
>  static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>  {
>  	struct sk_buff *skb = q->gso_skb;
> @@ -70,10 +106,17 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>  		} else
>  			skb = NULL;
>  	} else {
> -		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
> +		if (!(q->flags & TCQ_F_ONETXQUEUE) ||
> +		    !netif_xmit_frozen_or_stopped(txq)) {
> +			int bytelimit = qdisc_avail_bulklimit(txq);
> +
>  			skb = q->dequeue(q);
> -			if (skb)
> +			if (skb) {
> +				bytelimit -= skb->len;
>  				skb = validate_xmit_skb(skb, qdisc_dev(q));
> +			}
> +			if (skb && qdisc_may_bulk(q))
> +				skb = try_bulk_dequeue_skb(q, skb, bytelimit);
>  		}
>  	}

Okay...

In my opinion, you guys missed some opportunities :

1) Ideally the algo should try to call validate_xmit_skb() outside of
the locks (qdisc lock or device lock), because eventually doing checksum
computation or full segmentation should allow other cpus doing enqueues.

2) TSO support. Have you ideas how to perform this ?
