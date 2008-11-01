From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 17:16:33 -0700
Message-ID: <22495.1225498593@death.nxdomain.ibm.com>
References: <20081031125713.6c6923de@extreme> <20081031201016.GA4748@ioremap.net> <490B7284.2010003@cosmosbay.com> <20081031.165144.86556444.davem@davemloft.net> <20081031165620.7322b0e5@extreme>
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	zbr@ioremap.net, ilpo.jarvinen@helsinki.fi, rjw@sisk.pl,
	mingo@elte.hu, s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	efault@gmx.de, akpm@linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:45501 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751151AbYKAAQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 20:16:39 -0400
In-reply-to: <20081031165620.7322b0e5@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>On Fri, 31 Oct 2008 16:51:44 -0700 (PDT)
>David Miller <davem@davemloft.net> wrote:
[...]
>> However, I do like Stephen's suggestion that maybe we can get rid of
>> this ->last_rx thing by encapsulating the logic completely in the
>> bonding driver.
>
>Since bonding driver doesn't actually see the rx packets, that isn't
>really possible.  But it would be possible to change last_rx from a variable
>to an function pointer, so that device's could apply other logic to derive
>the last value.  One example would be to keep it per cpu and then take the
>maximum.

	I suspect it could also be tucked away in skb_bond_should_drop,
which is called both by the standard input path and the VLAN accelerated
path to see if the packet should be tossed (e.g., it arrived on an
inactive bonding slave).

	Since last_rx is part of struct net_device, I don't think any
additional bonding internals knowledge would be needed.  It could be
arranged to only update last_rx for devices that are actually bonding
slaves.

	Just off the top of my head (haven't tested this), something
like this:

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c8bcb59..ed1e58f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1743,22 +1743,24 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	struct net_device *master = dev->master;
 
-	if (master &&
-	    (dev->priv_flags & IFF_SLAVE_INACTIVE)) {
-		if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
-		    skb->protocol == __constant_htons(ETH_P_ARP))
-			return 0;
-
-		if (master->priv_flags & IFF_MASTER_ALB) {
-			if (skb->pkt_type != PACKET_BROADCAST &&
-			    skb->pkt_type != PACKET_MULTICAST)
+	if (master) {
+		dev->last_rx = jiffies;
+		if (dev->priv_flags & IFF_SLAVE_INACTIVE)) {
+			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
+			    skb->protocol == __constant_htons(ETH_P_ARP))
 				return 0;
-		}
-		if (master->priv_flags & IFF_MASTER_8023AD &&
-		    skb->protocol == __constant_htons(ETH_P_SLOW))
-			return 0;
 
-		return 1;
+			if (master->priv_flags & IFF_MASTER_ALB) {
+				if (skb->pkt_type != PACKET_BROADCAST &&
+				    skb->pkt_type != PACKET_MULTICAST)
+					return 0;
+			}
+			if (master->priv_flags & IFF_MASTER_8023AD &&
+			    skb->protocol == __constant_htons(ETH_P_SLOW))
+				return 0;
+
+			return 1;
+		}
 	}
 	return 0;
 }


	That doesn't move the storage out of struct net_device, but it
does stop the updates for devices that aren't bonding slaves.  It could
probably be refined further to only update when the ARP monitor is
running (the gizmo that uses last_rx).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
