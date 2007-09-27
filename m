From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 13:25:12 +0400
Message-ID: <20070927092512.GD29329@2ka.mipt.ru>
References: <20070927073446.GA14643@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58627 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbXI0J1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 05:27:10 -0400
Content-Disposition: inline
In-Reply-To: <20070927073446.GA14643@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert.

On Thu, Sep 27, 2007 at 03:34:47PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Hi:
> 
> [PKT_SCHED]: Add stateless NAT
> 
> Stateless NAT is useful in controlled environments where restrictions are
> placed on through traffic such that we don't need connection tracking to
> correctly NAT protocol-specific data.

Couple of comments below.
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -447,6 +447,17 @@ config NET_ACT_IPT
>  	  To compile this code as a module, choose M here: the
>  	  module will be called ipt.
>
> +config NET_ACT_NAT
> +        tristate "Stateless NAT"
> +        depends on NET_CLS_ACT
> +        select NETFILTER

Argh... People usually do not understand such jokes :)
What about not using netfilter helpers and just move them to the
accessible header so that no additional slow path would ever be enabled?

> +        ---help---
> +	  Say Y here to do stateless NAT on IPv4 packets.  You should use
> +	  netfilter for NAT unless you know what you are doing.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called ipt.
> +

Modile will be called 'nat' I believe.

> +++ b/net/sched/act_nat.c
...
> +#define NAT_TAB_MASK	15

This really wants to be configurable at least via module parameter.

> +static struct tcf_common *tcf_nat_ht[NAT_TAB_MASK + 1];
> +static u32 nat_idx_gen;
> +static DEFINE_RWLOCK(nat_lock);

> +static struct tcf_hashinfo nat_hash_info = {
> +	.htab	=	tcf_nat_ht,
> +	.hmask	=	NAT_TAB_MASK,
> +	.lock	=	&nat_lock,
> +};

When I read this I swear I heard 'I want to be RCU'.
But that is another task.

> +static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
> +		   struct tcf_result *res)
> +{
> +	struct tcf_nat *p = a->priv;
> +	struct iphdr *iph;
> +	__be32 old_addr;
> +	__be32 new_addr;
> +	__be32 mask;
> +	__be32 addr;
> +	int egress;
> +	int action;
> +	int ihl;
> +
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
> +
> +	if (!pskb_may_pull(skb, sizeof(*iph)))
> +		return TC_ACT_SHOT;
> +
> +	iph = ip_hdr(skb);
> +
> +	if (egress)
> +		addr = iph->saddr;
> +	else
> +		addr = iph->daddr;
> +
> +	if (!((old_addr ^ addr) & mask)) {
> +		if (skb_cloned(skb) &&
> +		    !skb_clone_writable(skb, sizeof(*iph)) &&
> +		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
> +			return TC_ACT_SHOT;
> +
> +		new_addr &= mask;
> +		new_addr |= addr & ~mask;
> +
> +		/* Rewrite IP header */
> +		iph = ip_hdr(skb);
> +		if (egress)
> +			iph->saddr = new_addr;
> +		else
> +			iph->daddr = new_addr;
> +
> +		nf_csum_replace4(&iph->check, addr, new_addr);
> +	}
> +
> +	ihl = iph->ihl * 4;
> +
> +	/* It would be nice to share code with stateful NAT. */
> +	switch (iph->frag_off & htons(IP_OFFSET) ? 0 : iph->protocol) {
> +	case IPPROTO_TCP:
> +	{
> +		struct tcphdr *tcph;
> +
> +		if (!pskb_may_pull(skb, ihl + sizeof(*tcph)) ||
> +		    (skb_cloned(skb) &&
> +		     !skb_clone_writable(skb, ihl + sizeof(*tcph)) &&
> +		     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
> +			return TC_ACT_SHOT;
> +
> +		tcph = (void *)(skb_network_header(skb) + ihl);

Were you too lazy to write struct tcphdr here and in other places? :)


-- 
	Evgeniy Polyakov
