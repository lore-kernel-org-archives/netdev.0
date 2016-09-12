From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 15:01:31 -0700
Message-ID: <1473717691.18970.82.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33493 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755824AbcILWBd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 18:01:33 -0400
Received: by mail-pf0-f195.google.com with SMTP id 128so8635856pfb.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 15:01:33 -0700 (PDT)
In-Reply-To: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 16:46 -0400, Jamal Hadi Salim wrote:

> +
> +static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
> +			   int bind, int ref)
> +{
> +	struct tcf_skbmod *d = to_skbmod(a);
> +	unsigned char *b = skb_tail_pointer(skb);
> +	struct tcf_skbmod_params  *p = rtnl_dereference(d->skbmod_p);
> +	struct tc_skbmod opt = {
> +		.index   = d->tcf_index,
> +		.refcnt  = d->tcf_refcnt - ref,
> +		.bindcnt = d->tcf_bindcnt - bind,
> +		.action  = d->tcf_action,
> +	};
> +	struct tcf_t t;
> +
> +	rcu_read_lock();

You do not need rcu read lock protection here, RTNL is enough.

> +
> +	opt.flags  = p->flags;
> +	if (nla_put(skb, TCA_SKBMOD_PARMS, sizeof(opt), &opt))
> +		goto nla_put_failure;
> +	if ((p->flags & SKBMOD_F_DMAC) &&
> +	    nla_put(skb, TCA_SKBMOD_DMAC, ETH_ALEN, p->eth_dst))
> +		goto nla_put_failure;
> +	if ((p->flags & SKBMOD_F_SMAC) &&
> +	    nla_put(skb, TCA_SKBMOD_SMAC, ETH_ALEN, p->eth_src))
> +		goto nla_put_failure;
> +	if ((p->flags & SKBMOD_F_ETYPE) &&
> +	    nla_put_u16(skb, TCA_SKBMOD_ETYPE, ntohs(p->eth_type)))
> +		goto nla_put_failure;
> +
> +	tcf_tm_dump(&t, &d->tcf_tm);
> +	if (nla_put_64bit(skb, TCA_SKBMOD_TM, sizeof(t), &t, TCA_SKBMOD_PAD))
> +		goto nla_put_failure;
> +
> +	rcu_read_unlock();
> +
> +	return skb->len;
> +nla_put_failure:
> +	rcu_read_unlock();
> +	nlmsg_trim(skb, b);
> +	return -1;
> +}
> +
