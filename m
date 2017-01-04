From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next rfc 5/6] net-tc: convert tc_at to tc_at_ingress
Date: Wed, 04 Jan 2017 20:18:07 +0100
Message-ID: <586D4A6F.7020009@iogearbox.net>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com> <1482952410-50003-6-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54805 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967484AbdADTSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 14:18:13 -0500
In-Reply-To: <1482952410-50003-6-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willem,

overall I think the series looks great, thanks for working on it!

On 12/28/2016 08:13 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Field tc_at is used only within tc actions to distinguish ingress from
> egress processing. A single bit is sufficient for this purpose. Set it
> within tc_classify to make the scope clear and to avoid the need to
> clear it in skb_reset_tc.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>   include/linux/skbuff.h    |  3 ++-
>   include/net/sch_generic.h |  3 +--
>   net/core/dev.c            |  6 +-----
>   net/sched/act_mirred.c    | 12 ++++++------
>   net/sched/sch_api.c       |  1 +
>   5 files changed, 11 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index f738d09..fab3f87 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -590,6 +590,7 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
>    *	@fclone: skbuff clone status
>    *	@ipvs_property: skbuff is owned by ipvs
>    *	@tc_skip_classify: do not classify packet. set by IFB device
> + *	@tc_at_ingress: used within tc_classify to distinguish in/egress
>    *	@peeked: this packet has been seen already, so stats have been
>    *		done for it, don't do them again
>    *	@nf_trace: netfilter packet trace flag
> @@ -751,7 +752,7 @@ struct sk_buff {
>   #endif
>   #ifdef CONFIG_NET_CLS_ACT
>   	__u8			tc_skip_classify:1;
> -	__u8			tc_at:2;
> +	__u8			tc_at_ingress:1;
>   	__u8			tc_from:2;
>   #endif
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index f80dba5..4bd6d53 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -412,7 +412,6 @@ int skb_do_redirect(struct sk_buff *);
>   static inline void skb_reset_tc(struct sk_buff *skb)
>   {
>   #ifdef CONFIG_NET_CLS_ACT
> -	skb->tc_at = 0;
>   	skb->tc_from = 0;
>   #endif
>   }
> @@ -420,7 +419,7 @@ static inline void skb_reset_tc(struct sk_buff *skb)
>   static inline bool skb_at_tc_ingress(const struct sk_buff *skb)
>   {
>   #ifdef CONFIG_NET_CLS_ACT
> -	return skb->tc_at & AT_INGRESS;
> +	return skb->tc_at_ingress;
>   #else
>   	return false;
>   #endif
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 25620cf..90833fdf 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3153,9 +3153,7 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>   	if (!cl)
>   		return skb;
>
> -	/* skb->tc_at and qdisc_skb_cb(skb)->pkt_len were already set
> -	 * earlier by the caller.
> -	 */
> +	/* qdisc_skb_cb(skb)->pkt_len was already set by the caller. */
>   	qdisc_bstats_cpu_update(cl->q, skb);
>
>   	switch (tc_classify(skb, cl, &cl_res, false)) {
> @@ -3320,7 +3318,6 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
>
>   	qdisc_pkt_len_init(skb);
>   #ifdef CONFIG_NET_CLS_ACT
> -	skb->tc_at = AT_EGRESS;
>   # ifdef CONFIG_NET_EGRESS
>   	if (static_key_false(&egress_needed)) {
>   		skb = sch_handle_egress(skb, &rc, dev);
> @@ -3916,7 +3913,6 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
>   	}
>
>   	qdisc_skb_cb(skb)->pkt_len = skb->len;
> -	skb->tc_at = AT_INGRESS;
>   	qdisc_bstats_cpu_update(cl->q, skb);
>
>   	switch (tc_classify(skb, cl, &cl_res, false)) {
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index 8543279..e832c62 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -39,15 +39,15 @@ static bool tcf_mirred_is_act_redirect(int action)
>   	return action == TCA_EGRESS_REDIR || action == TCA_INGRESS_REDIR;
>   }
>
> -static u32 tcf_mirred_act_direction(int action)
> +static bool tcf_mirred_act_wants_ingress(int action)
>   {
>   	switch (action) {
>   	case TCA_EGRESS_REDIR:
>   	case TCA_EGRESS_MIRROR:
> -		return AT_EGRESS;
> +		return false;
>   	case TCA_INGRESS_REDIR:
>   	case TCA_INGRESS_MIRROR:
> -		return AT_INGRESS;
> +		return true;
>   	default:
>   		BUG();
>   	}
> @@ -198,7 +198,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
>   	 * and devices expect a mac header on xmit, then mac push/pull is
>   	 * needed.
>   	 */
> -	if (skb->tc_at != tcf_mirred_act_direction(m_eaction) &&
> +	if (skb_at_tc_ingress(skb) != tcf_mirred_act_wants_ingress(m_eaction) &&
>   	    m_mac_header_xmit) {
>   		if (!skb_at_tc_ingress(skb)) {
>   			/* caught at egress, act ingress: pull mac */
> @@ -212,11 +212,11 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
>
>   	/* mirror is always swallowed */
>   	if (tcf_mirred_is_act_redirect(m_eaction))
> -		skb2->tc_from = skb2->tc_at;
> +		skb2->tc_from = skb_at_tc_ingress(skb) ? AT_INGRESS : AT_EGRESS;
>
>   	skb2->skb_iif = skb->dev->ifindex;
>   	skb2->dev = dev;
> -	if (tcf_mirred_act_direction(m_eaction) & AT_EGRESS)
> +	if (!tcf_mirred_act_wants_ingress(m_eaction))
>   		err = dev_queue_xmit(skb2);
>   	else
>   		err = netif_receive_skb(skb2);
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index ef53ede..be4e18d 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -1865,6 +1865,7 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>   	const struct tcf_proto *old_tp = tp;
>   	int limit = 0;
>
> +	skb->tc_at_ingress = !!(tp && tp->q->flags & TCQ_F_INGRESS);

I'd prefer if skb->tc_at_ingress is set directly to 0/1 in sch_handle_ingress()
and __dev_queue_xmit() as we do right now, this would avoid above tests in fast
path and it would also avoid to set the same thing in tc_classify() multiple
times f.e. on egress path walking through multiple qdiscs. I don't see anything
in layers above tc that would read it and expect an AT_STACK-like equivalent.
skb_reset_tc() could thus still remain as you have above in fast-path like
__netif_receive_skb_core().

>   reclassify:
>   #endif
>   	for (; tp; tp = rcu_dereference_bh(tp->next)) {
>

Thanks,
Daniel
