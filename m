From: Jouni Malinen <jouni@codeaurora.org>
Subject: Re: [PATCH] bridge: Remove BR_PROXYARP flooding check code
Date: Wed, 10 Dec 2014 13:39:38 +0200
Message-ID: <20141210113938.GA12093@jouni.qca.qualcomm.com>
References: <1418052460-30691-1-git-send-email-jouni@codeaurora.org>
 <20141209142158.7e513dbf@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Kyeyoon Park <kyeyoonp@codeaurora.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:56286 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbaLJLjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 06:39:45 -0500
Content-Disposition: inline
In-Reply-To: <20141209142158.7e513dbf@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2014 at 02:21:58PM -0800, Stephen Hemminger wrote:
> On Mon,  8 Dec 2014 17:27:40 +0200
> Jouni Malinen <jouni@codeaurora.org> wrote:
> > diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> > @@ -185,10 +185,6 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
> >  		if (unicast && !(p->flags & BR_FLOOD))
> >  			continue;
> >  
> > -		/* Do not flood to ports that enable proxy ARP */
> > -		if (p->flags & BR_PROXYARP)
> > -			continue;
> > -
> >  		prev = maybe_deliver(prev, p, skb, __packet_hook);

> Aren't you at risk of duplicate ARP responses in some cases.
> You can't assume user will run netfilter.

This is only for the case where BR_PROXYARP has been enabled by the
user, but yes, it would be convenient to handle cases better without
requiring netfilter and skip flooding to BR_PROXYARP port more
selectively here. Would there be some convenient means for
br_do_proxy_arp() to mark the skb that it has replied to in br_input.c
and then use that here in br_forward.c to not flood an ARP request that
has already been replied to? Or should this simply skip flooding of all
ARP packets with something like following?

 		if (unicast && !(p->flags & BR_FLOOD))
 			continue;
 
-		/* Do not flood to ports that enable proxy ARP */
-		if (p->flags & BR_PROXYARP)
+		/* Do not flood ARP to ports that enable proxy ARP */
+		if (p->flags & BR_PROXYARP &&
+		    skb->protocol == htons(ETH_P_ARP))
 			continue;
 
 		prev = maybe_deliver(prev, p, skb, __packet_hook);

-- 
Jouni Malinen                                            PGP id EFC895FA
