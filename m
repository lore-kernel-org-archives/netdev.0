From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NAT and requests to unrouted targets
Date: Fri, 16 Mar 2007 05:13:52 +0100
Message-ID: <45FA1980.5050507@trash.net>
References: <000001c766d8$66f1cc00$1a04010a@V505CP> <45F90905.4000408@trash.net> <001101c76711$cf7dc6a0$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Netfilter Development Mailinglist'
	<netfilter-devel@lists.netfilter.org>
To: Martin Schiller <mschiller@tdt.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44227 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917AbXCPEOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 00:14:22 -0400
In-Reply-To: <001101c76711$cf7dc6a0$1a04010a@V505CP>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Schiller wrote:
> Well, the really responsible code is the following:
> 
> ------------------------------------------------------------------------
> static unsigned int
> ip_nat_local_fn(unsigned int hooknum,
> 		struct sk_buff **pskb,
> 		const struct net_device *in,
> 		const struct net_device *out,
> 		int (*okfn)(struct sk_buff *))
> {
> 	struct ip_conntrack *ct;
> 	enum ip_conntrack_info ctinfo;
> 	unsigned int ret;
> 
> 	/* root is playing with raw sockets. */
> 	if ((*pskb)->len < sizeof(struct iphdr)
> 	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
> 		return NF_ACCEPT;
> 
> 	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
> 	if (ret != NF_DROP && ret != NF_STOLEN
> 	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
> 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
> 
> 		if (ct->tuplehash[dir].tuple.dst.ip !=
> 		    ct->tuplehash[!dir].tuple.src.ip
> #ifdef CONFIG_XFRM
> 		    || ct->tuplehash[dir].tuple.dst.u.all !=
> 		       ct->tuplehash[!dir].tuple.src.u.all
> #endif
> 		    )
> 			if (ip_route_me_harder(pskb, RTN_UNSPEC))
> 				ret = NF_DROP;
> 	}
> 	return ret;
> }
> ----------------------------------------------------------------------------
> 
> To be more exactly, it's the examination of
> "ct->tuplehash[dir].tuple.dst.u.all != ct->tuplehash[!dir].tuple.src.u.all"
> which is only be done if XFRM is configured. Since I don't need this anyway,
> I deactivated XFRM now and my "ping -I" is working now. 


You're right, that doesn't really work for ICMP since the tuples are
asymetric even without NAT. I didn't expect the unnecessary call to
ip_route_me_harder to have any side-effects. I'll look into fixing
this properly.

