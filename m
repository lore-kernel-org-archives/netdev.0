From: "Martin Schiller" <mschiller@tdt.de>
Subject: RE: [PATCH] NAT and requests to unrouted targets
Date: Thu, 15 Mar 2007 15:54:19 +0100
Message-ID: <001101c76711$cf7dc6a0$1a04010a@V505CP>
References: <000001c766d8$66f1cc00$1a04010a@V505CP> <45F90905.4000408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"'Netfilter Development Mailinglist'"
	<netfilter-devel@lists.netfilter.org>
To: "'Patrick McHardy'" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:43272 "EHLO ns.tdt.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030304AbXCOOyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 10:54:19 -0400
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id l2FEsI110257
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2007 15:54:18 +0100
In-Reply-To: <45F90905.4000408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, March 15, 2007 9:51 AM, Patrick McHardy wrote:

> diff -uNpr linux-2.6.19.org/net/ipv4/netfilter/ip_nat_standalone.c
> linux-2.6.19/net/ipv4/netfilter/ip_nat_standalone.c
> --- linux-2.6.19.org/net/ipv4/netfilter/ip_nat_standalone.c
> 2006-11-29 22:57:37.000000000 +0100
> +++ linux-2.6.19/net/ipv4/netfilter/ip_nat_standalone.c 2007-03-15
> 08:25:11.000000000 +0100
> @@ -191,11 +191,13 @@ ip_nat_in(unsigned int hooknum,
>            int (*okfn)(struct sk_buff *))  {
>         unsigned int ret;
> +       __be32 saddr = (*pskb)->nh.iph->saddr;
>         __be32 daddr = (*pskb)->nh.iph->daddr;
> 
>         ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
>         if (ret != NF_DROP && ret != NF_STOLEN
> -           && daddr != (*pskb)->nh.iph->daddr) {
> +           && ((*pskb)->nh.iph->saddr != saddr
> +               || (*pskb)->nh.iph->daddr != daddr)) {
>                 dst_release((*pskb)->dst);
>                 (*pskb)->dst = NULL;
>         }
> 
> I don't see how this would change anything, the PRE_ROUTING hook
> doesn't change the source address, so the comparison is unnecessary,
> additionally the dst_release is only needed for loopback because
> packets received from a real interface don't have a route attached at
> this time.    

Sorry, you are right. This wouldn't change anything.
I've tested so much to find the responsible peace of code for my problem, so
i messed up some things here.

Well, the really responsible code is the following:

------------------------------------------------------------------------
static unsigned int
ip_nat_local_fn(unsigned int hooknum,
		struct sk_buff **pskb,
		const struct net_device *in,
		const struct net_device *out,
		int (*okfn)(struct sk_buff *))
{
	struct ip_conntrack *ct;
	enum ip_conntrack_info ctinfo;
	unsigned int ret;

	/* root is playing with raw sockets. */
	if ((*pskb)->len < sizeof(struct iphdr)
	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
		return NF_ACCEPT;

	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
	if (ret != NF_DROP && ret != NF_STOLEN
	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);

		if (ct->tuplehash[dir].tuple.dst.ip !=
		    ct->tuplehash[!dir].tuple.src.ip
#ifdef CONFIG_XFRM
		    || ct->tuplehash[dir].tuple.dst.u.all !=
		       ct->tuplehash[!dir].tuple.src.u.all
#endif
		    )
			if (ip_route_me_harder(pskb, RTN_UNSPEC))
				ret = NF_DROP;
	}
	return ret;
}
----------------------------------------------------------------------------

To be more exactly, it's the examination of
"ct->tuplehash[dir].tuple.dst.u.all != ct->tuplehash[!dir].tuple.src.u.all"
which is only be done if XFRM is configured. Since I don't need this anyway,
I deactivated XFRM now and my "ping -I" is working now. 

Regards, Martin


