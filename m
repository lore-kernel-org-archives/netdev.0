From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net, sched: add clsact qdisc
Date: Thu, 07 Jan 2016 08:29:55 -0800
Message-ID: <1452184195.8255.215.camel@edumazet-glaptop2.roam.corp.google.com>
References: <d091709bf1a93c65cdadc9a990c9065e065840b8.1452041153.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36533 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbcAGQ36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 11:29:58 -0500
Received: by mail-pa0-f50.google.com with SMTP id yy13so169828294pab.3
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 08:29:58 -0800 (PST)
In-Reply-To: <d091709bf1a93c65cdadc9a990c9065e065840b8.1452041153.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-06 at 02:00 +0100, Daniel Borkmann wrote:
> This work adds a generalization of the ingress qdisc as a qdisc holding
> only classifiers. The clsact qdisc works on ingress, but also on egress.
> In both cases, it's execution happens without taking the qdisc lock, and
> the main difference for the egress part compared to prior version of [1]
> is that this can be applied with _any_ underlying real egress qdisc (also
> classless ones).


> +void net_dec_egress_queue(void)
> +{
> +	static_key_slow_dec(&egress_needed);
> +}
> +EXPORT_SYMBOL_GPL(net_dec_egress_queue);
> +#endif
> +
>  static struct static_key netstamp_needed __read_mostly;
>  #ifdef HAVE_JUMP_LABEL
>  /* We are not allowed to call static_key_slow_dec() from irq context
> @@ -3100,6 +3116,48 @@ int dev_loopback_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(dev_loopback_xmit);
>  
> +#ifdef CONFIG_NET_EGRESS
> +static struct sk_buff *
> +sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
> +{
> +	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
> +	struct tcf_result cl_res;
> +
> +	if (!cl)
> +		return skb;
> +
> +	qdisc_skb_cb(skb)->pkt_len = skb->len;

You probably should move qdisc_pkt_len_init() out of __dev_xmit_skb()
and call it earlier. Then this pkt_len partial init is no longer needed.

> +	/* skb->tc_verd was already set earlier by the caller. */
> +	qdisc_bstats_cpu_update(cl->q, skb);
> +
> +	switch (tc_classify(skb, cl, &cl_res, false)) {
> +	case TC_ACT_OK:
> +	case TC_ACT_RECLASSIFY:
> +		skb->tc_index = TC_H_MIN(cl_res.classid);
> +		break;
> +	case TC_ACT_SHOT:
> +		qdisc_qstats_cpu_drop(cl->q);
> +		*ret = NET_XMIT_DROP;
> +		goto drop;
> +	case TC_ACT_STOLEN:
> +	case TC_ACT_QUEUED:
> +		*ret = NET_XMIT_SUCCESS;
> +drop:
> +		kfree_skb(skb);
> +		return NULL;
> +	case TC_ACT_REDIRECT:
> +		/* No need to push/pop skb's mac_header here on egress! */
> +		skb_do_redirect(skb);
> +		*ret = NET_XMIT_SUCCESS;
> +		return NULL;
> +	default:
> +		break;
> +	}
> +
> +	return skb;
> +}
> +#endif /* CONFIG_NET_EGRESS */
> +
