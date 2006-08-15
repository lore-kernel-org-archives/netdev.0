From: David Miller <davem@davemloft.net>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Mon, 14 Aug 2006 17:09:05 -0700 (PDT)
Message-ID: <20060814.170905.69218340.davem@davemloft.net>
References: <200607311015.40255.Christophe.Devriese@eurid.eu>
	<20060802.135859.91441473.davem@davemloft.net>
	<200608040101.k7411ZZt013801@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Christophe.Devriese@eurid.eu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43177
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965081AbWHOAJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 20:09:09 -0400
To: fubar@us.ibm.com
In-Reply-To: <200608040101.k7411ZZt013801@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 03 Aug 2006 18:01:35 -0700

> 	In this case (bond0.555 above bond0 above eth0,eth1,etc),
> skb_bond doesn't suppress duplicates because skb_bond is called with the
> skb->dev set to the bond0.555 dev, not the ethX dev.  Non-accelerated
> VLAN devices don't do this; they'll come in with skb->dev set to ethX
> and will go through skb_bond as expected.

Ok, since __vlan_hwaccel_rx() bypasses the netif_receive_skb()
that would normally occur, we have to duplicate the bonding
drop checks.

The submitted patch put skb_bond() into if_vlan.h which is
definitely the wrong thing to do.  This is a generic operation
and therefore belongs in linux/netdevice.h at best.

Furthermore, we're only interested in the packet drop check,
so that's the only part of the logic we need to export,
the rest can stay private to skb_bond() in net/core/dev.c

Can the folks who can reproduce this try this patch?

Thanks.

commit 8a9583e08d0524e3bfe43a51af7c66ca21adf9f3
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Aug 14 17:08:36 2006 -0700

    [VLAN]: Make sure bonding packet drop checks get done in hwaccel RX path.
    
    Since __vlan_hwaccel_rx() is essentially bypassing the
    netif_receive_skb() call that would have occurred if we did the VLAN
    decapsulation in software, we are missing the skb_bond() call and the
    assosciated checks it does.
    
    Export those checks via an inline function, skb_bond_should_drop(),
    and use this in __vlan_hwaccel_rx().
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 383627a..ab27408 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -155,6 +155,11 @@ static inline int __vlan_hwaccel_rx(stru
 {
 	struct net_device_stats *stats;
 
+	if (skb_bond_should_drop(skb)) {
+		dev_kfree_skb_any(skb);
+		return NET_RX_DROP;
+	}
+
 	skb->dev = grp->vlan_devices[vlan_tag & VLAN_VID_MASK];
 	if (skb->dev == NULL) {
 		dev_kfree_skb_any(skb);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 75f02d8..c0c2b46 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1012,6 +1012,30 @@ static inline int netif_needs_gso(struct
 		unlikely(skb->ip_summed != CHECKSUM_HW));
 }
 
+/* On bonding slaves other than the currently active slave, suppress
+ * duplicates except for 802.3ad ETH_P_SLOW and alb non-mcast/bcast.
+ */
+static inline int skb_bond_should_drop(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	struct net_device *master = dev->master;
+
+	if (master &&
+	    (dev->priv_flags & IFF_SLAVE_INACTIVE)) {
+		if (master->priv_flags & IFF_MASTER_ALB) {
+			if (skb->pkt_type != PACKET_BROADCAST &&
+			    skb->pkt_type != PACKET_MULTICAST)
+				return 0;
+		}
+		if (master->priv_flags & IFF_MASTER_8023AD &&
+		    skb->protocol == __constant_htons(ETH_P_SLOW))
+			return 0;
+
+		return 1;
+	}
+	return 0;
+}
+
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_DEV_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index d95e262..9fe96cd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1619,26 +1619,10 @@ static inline struct net_device *skb_bon
 	struct net_device *dev = skb->dev;
 
 	if (dev->master) {
-		/*
-		 * On bonding slaves other than the currently active
-		 * slave, suppress duplicates except for 802.3ad
-		 * ETH_P_SLOW and alb non-mcast/bcast.
-		 */
-		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
-			if (dev->master->priv_flags & IFF_MASTER_ALB) {
-				if (skb->pkt_type != PACKET_BROADCAST &&
-				    skb->pkt_type != PACKET_MULTICAST)
-					goto keep;
-			}
-
-			if (dev->master->priv_flags & IFF_MASTER_8023AD &&
-			    skb->protocol == __constant_htons(ETH_P_SLOW))
-				goto keep;
-		
+		if (skb_bond_should_drop(skb)) {
 			kfree_skb(skb);
 			return NULL;
 		}
-keep:
 		skb->dev = dev->master;
 	}
 
