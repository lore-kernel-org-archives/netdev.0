From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 08:39:45 -0400
Message-ID: <1190896785.4290.18.camel@localhost>
References: <20070927073446.GA14643@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:9120 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbXI0Mju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 08:39:50 -0400
Received: by wr-out-0506.google.com with SMTP id 36so1041717wra
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 05:39:49 -0700 (PDT)
In-Reply-To: <20070927073446.GA14643@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nice work. I like the egress flag idea;->
and who would have thunk stateless nat could be written in such a few
lines ;-> I would have put the checksum as a separate action but it is
fine the way you did it since it simplifies config.
more comments below.

On Thu, 2007-27-09 at 15:34 +0800, Herbert Xu wrote:

> +config NET_ACT_NAT
> +        tristate "Stateless NAT"
> +        depends on NET_CLS_ACT
> +        select NETFILTER

I am gonna have to agree with Evgeniy on this Herbert;->
The rewards are it will improve performance for people who dont need
netfilter.
Ok, who is gonna move the csum utility functions out? /me looks at
Evgeniy;->
I could do it realsoonnow if noone raises their hands. 
In any case, it would be real nice to have but i dont see it as a show
stopper for inclusion.
 
> +static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
> +		   struct tcf_result *res)
> +{
> +	struct tcf_nat *p = a->priv;

> +	spin_lock(&p->tcf_lock);
> +
> +	p->tcf_tm.lastuse = jiffies;
> +	old_addr = p->old_addr;
> +	new_addr = p->new_addr;
> +	mask = p->mask;
> +	egress = p->flags & TCA_NAT_FLAG_EGRESS;
> +	action = p->tcf_action;
> +
> +	p->tcf_bstats.bytes += skb->len;
> +	p->tcf_bstats.packets++;
> +
> +	spin_unlock(&p->tcf_lock);

You also need to p->tcf_qstats.drops++ for all packets that get shot.
I would just hold tcf_lock until the end.
If you are concerned about performance of multiple flows contending for
the lock, then just create a new action entry per flow by using a
different index for each; you cant avoid contention with control path in
case of updates, but i suspect that would be a rare occasion.

Do you have plans to do the iproute bits? If you do it will be nice to
also update the doc/examples with some simple example(s).

cheers,
jamal

