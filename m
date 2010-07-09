From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] gre: propagate ipv6 transport class
Date: Thu, 08 Jul 2010 21:36:45 -0700 (PDT)
Message-ID: <20100708.213645.183036637.davem@davemloft.net>
References: <20100706105821.7b0e2538@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53445
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750815Ab0GIEgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 00:36:31 -0400
In-Reply-To: <20100706105821.7b0e2538@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 6 Jul 2010 10:58:21 -0700

> This patch makes IPV6 over IPv4 GRE tunnel propagate the transport
> class field from the underlying IPV6 header to the IPV4 Type Of Service
> field. Without the patch, all IPV6 packets in tunnel look the same to QoS.
> 
> This assumes that IPV6 transport class is exactly the same
> as IPv4 TOS. Not sure if that is always the case?  Maybe need
> to mask off some bits.
> 
> The mask and shift to get tclass is copied from ipv6/datagram.c
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Looks good, but we should use ipv6_get_dsfield() just like
ipgre_ecn_encapsulate() does.

Note that this also influences the route since this 'tos' feeds
into the flowi lookup key.  We should make sure that this is OK
too.

Anyways, I've committed the following to net-next-2.6, thanks!

--------------------
gre: propagate ipv6 transport class

This patch makes IPV6 over IPv4 GRE tunnel propagate the transport
class field from the underlying IPV6 header to the IPV4 Type Of Service
field. Without the patch, all IPV6 packets in tunnel look the same to QoS.

This assumes that IPV6 transport class is exactly the same
as IPv4 TOS. Not sure if that is always the case?  Maybe need
to mask off some bits.

The mask and shift to get tclass is copied from ipv6/datagram.c

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_gre.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 749e548..945b20a 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -731,6 +731,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		tos = 0;
 		if (skb->protocol == htons(ETH_P_IP))
 			tos = old_iph->tos;
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			tos = ipv6_get_dsfield((struct ipv6hdr *)old_iph);
 	}
 
 	{
-- 
1.7.1.1



