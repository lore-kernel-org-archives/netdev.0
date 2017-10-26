From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next v2] net: core: introduce mini_Qdisc and
 eliminate usage of tp->q for clsact fastpath
Date: Thu, 26 Oct 2017 08:54:56 -0700
Message-ID: <20171026155454.nkh5ykb2bw35wpnb@ast-mbp>
References: <20171026094103.10164-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, edumazet@google.com,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        willemb@google.com, john.fastabend@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:49679 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932320AbdJZPzA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:55:00 -0400
Received: by mail-pf0-f196.google.com with SMTP id i5so2810480pfe.6
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:55:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171026094103.10164-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 11:41:03AM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> In sch_handle_egress and sch_handle_ingress tp->q is used only in order
> to update stats. So stats and filter list are the only things that are
> needed in clsact qdisc fastpath processing. Introduce new mini_Qdisc
> struct to hold those items. This removes need for tp->q usage without
> added overhead.

that is false claim. The patch adds run-time overhead instead.

> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
> - Use dev instead of skb->dev in sch_handle_egress as pointed out by Daniel
> - Fixed synchronize_rcu_bh() in mini_qdisc_disable and commented
...
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 24ac908..44ea1c3 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3274,14 +3274,16 @@ EXPORT_SYMBOL(dev_loopback_xmit);
>  static struct sk_buff *
>  sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>  {
> -	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
> +	struct mini_Qdisc *miniq = rcu_dereference_bh(dev->miniq_egress);
>  	struct tcf_result cl_res;
> +	struct tcf_proto *cl;
>  
> -	if (!cl)
> +	if (!miniq)
>  		return skb;
> +	cl = rcu_dereference_bh(miniq->filter_list);

Just like Daniel pointed out in the earlier version of the patch
it adds another rcu dereference to critical path of execution
for every packet...

> @@ -4189,16 +4191,19 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
>  		   struct net_device *orig_dev)
>  {
>  #ifdef CONFIG_NET_CLS_ACT
> -	struct tcf_proto *cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
> +	struct mini_Qdisc *miniq = rcu_dereference_bh(skb->dev->miniq_ingress);
>  	struct tcf_result cl_res;
> +	struct tcf_proto *cl;
>  
>  	/* If there's at least one ingress present somewhere (so
>  	 * we get here via enabled static key), remaining devices
>  	 * that are not configured with an ingress qdisc will bail
>  	 * out here.
>  	 */
> -	if (!cl)
> +	if (!miniq)
>  		return skb;
> +	cl = rcu_dereference_bh(miniq->filter_list);

... both ingress and egress paths.
There gotta be very strong reasons to penalize all users for this
and I don't see them in commit log.
