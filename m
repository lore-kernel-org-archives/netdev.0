From: Christophe Devriese <christophe.devriese@eth1.org>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Fri, 28 Jul 2006 23:50:32 +0200
Message-ID: <20060728215032.GA17930@walrus.eth1.org>
References: <20060728094421.GA14903@walrus.eth1.org> <44CA34D0.1070507@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth1.org ([85.158.215.1]:38584 "EHLO walrus.kotnet.org")
	by vger.kernel.org with ESMTP id S1161320AbWG1VmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 17:42:23 -0400
To: Linux netdev <netdev@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <44CA34D0.1070507@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I basically move the skb_bond method into if_bonding.h, include that file
in if_vlan ( and call it from the vlan forwarding path, and the netif_rx
routine ). 

Somehow this patch is very incomplete. Let me try again.

sorry for the trouble. (I'm new at this)

Regards,

Christophe 

> Christophe Devriese wrote:
> >diff -rU3 linux-2.6.17.7/net/core/dev.c 
> >linux-2.6.17.7-wapper/net/core/dev.c
> >--- linux-2.6.17.7/net/core/dev.c       2006-07-25 05:36:01.000000000 +0200
> >+++ linux-2.6.17.7-wapper/net/core/dev.c        2006-07-27 
> >20:16:36.000000000 +0200
> >@@ -88,6 +88,7 @@
> > #include <linux/sockios.h>
> > #include <linux/errno.h>
> > #include <linux/interrupt.h>
> >+#include <linux/if_bonding.h>
> > #include <linux/if_ether.h>
> > #include <linux/netdevice.h>
> > #include <linux/etherdevice.h>
> >@@ -1518,37 +1519,6 @@
> >
> > EXPORT_SYMBOL(netif_rx_ni);
> >
> >-static inline struct net_device *skb_bond(struct sk_buff *skb)
> >-{
> >-       struct net_device *dev = skb->dev;
> >-
> >-       if (dev->master) {
> >-               /*
> >-                * On bonding slaves other than the currently active
> >-                * slave, suppress duplicates except for 802.3ad
> >-                * ETH_P_SLOW and alb non-mcast/bcast.
> >-                */
> >-               if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
> >-                       if (dev->master->priv_flags & IFF_MASTER_ALB) {
> >-                               if (skb->pkt_type != PACKET_BROADCAST &&
> >-                                   skb->pkt_type != PACKET_MULTICAST)
> >-                                       goto keep;
> >-                       }
> >-
> >-                       if (dev->master->priv_flags & IFF_MASTER_8023AD &&
> >-                           skb->protocol == __constant_htons(ETH_P_SLOW))
> >-                               goto keep;
> >-
> >-                       kfree_skb(skb);
> >-                       return NULL;
> >-               }
> >-keep:
> >-               skb->dev = dev->master;
> >-       }
> >-
> >-       return dev;
> >-}
> >-
> > static void net_tx_action(struct softirq_action *h)
> > {
> >        struct softnet_data *sd = &__get_cpu_var(softnet_data);
> >
> 
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
-----------------------------------------------------------------------
Christophe Devriese                                               EURiD
Network Adminstrator / Developer
christophe.devriese@eth1.org
---------------------------- http://www.eth1.org ----------------------


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="skbbondvlan.patch"

diff -rU3 linux-2.6.17.7/include/linux/if_bonding.h linux-2.6.17.7-wapper/include/linux/if_bonding.h
--- linux-2.6.17.7/include/linux/if_bonding.h	2006-07-25 05:36:01.000000000 +0200
+++ linux-2.6.17.7-wapper/include/linux/if_bonding.h	2006-07-27 21:17:25.000000000 +0200
@@ -46,6 +46,7 @@
 #include <linux/if.h>
 #include <linux/types.h>
 #include <linux/if_ether.h>
+#include <linux/netdevice.h>
 
 /* userland - kernel ABI version (2003/05/08) */
 #define BOND_ABI_VERSION 2
@@ -110,6 +111,37 @@
 	__u8 partner_system[ETH_ALEN];
 };
 
+static inline struct net_device *skb_bond(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+
+	if (dev->master) {
+		/*
+		 * On bonding slaves other than the currently active
+		 * slave, suppress duplicates except for 802.3ad
+		 * ETH_P_SLOW and alb non-mcast/bcast.
+		 */
+		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
+			if (dev->master->priv_flags & IFF_MASTER_ALB) {
+				if (skb->pkt_type != PACKET_BROADCAST &&
+				    skb->pkt_type != PACKET_MULTICAST)
+					goto keep;
+			}
+
+			if (dev->master->priv_flags & IFF_MASTER_8023AD &&
+			    skb->protocol == __constant_htons(ETH_P_SLOW))
+				goto keep;
+		
+			kfree_skb(skb);
+			return NULL;
+		}
+keep:
+		skb->dev = dev->master;
+	}
+
+	return dev;
+}
+
 #endif /* _LINUX_IF_BONDING_H */
 
 /*
diff -rU3 linux-2.6.17.7/include/linux/if_vlan.h linux-2.6.17.7-wapper/include/linux/if_vlan.h
--- linux-2.6.17.7/include/linux/if_vlan.h	2006-07-25 05:36:01.000000000 +0200
+++ linux-2.6.17.7-wapper/include/linux/if_vlan.h	2006-07-27 20:16:36.000000000 +0200
@@ -24,6 +24,7 @@
 struct hlist_node;
 
 #include <linux/proc_fs.h> /* for proc_dir_entry */
+#include <linux/if_bonding.h> /* for skb_bond */
 #include <linux/netdevice.h>
 
 #define VLAN_HLEN	4		/* The additional bytes (on top of the Ethernet header)
@@ -154,6 +155,12 @@
 				    unsigned short vlan_tag, int polling)
 {
 	struct net_device_stats *stats;
+	struct net_device *orig_dev;
+
+	orig_dev = skb_bond(skb);
+
+	if (!orig_dev) 
+		return NET_RX_DROP;
 
 	skb->dev = grp->vlan_devices[vlan_tag & VLAN_VID_MASK];
 	if (skb->dev == NULL) {
diff -rU3 linux-2.6.17.7/net/core/dev.c linux-2.6.17.7-wapper/net/core/dev.c
--- linux-2.6.17.7/net/core/dev.c	2006-07-25 05:36:01.000000000 +0200
+++ linux-2.6.17.7-wapper/net/core/dev.c	2006-07-27 20:16:36.000000000 +0200
@@ -88,6 +88,7 @@
 #include <linux/sockios.h>
 #include <linux/errno.h>
 #include <linux/interrupt.h>
+#include <linux/if_bonding.h>
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -1518,37 +1519,6 @@
 
 EXPORT_SYMBOL(netif_rx_ni);
 
-static inline struct net_device *skb_bond(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-
-	if (dev->master) {
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
-			kfree_skb(skb);
-			return NULL;
-		}
-keep:
-		skb->dev = dev->master;
-	}
-
-	return dev;
-}
-
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);

--IJpNTDwzlM2Ie8A6--
