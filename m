From: Shmulik Hen <hshmulik@intel.com>
Subject: [patch] (1/8) Adding 802.3ad support to bonding
Date: Thu, 20 Mar 2003 17:15:07 +0200 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303201608300.10351-100000@jrslxjul4.npdj.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: Bonding Developement list <bonding-devel@lists.sourceforge.net>,
   Bonding Announce list <bonding-announce@lists.sourceforge.net>,
   Linux Net Mailing list <linux-net@vger.kernel.org>,
   Linux Kernel Mailing list <linux-kernel@vger.kernel.org>,
   Oss SGI Netdev list <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds support for point to point protocols (e.g. 802.3ad)
over bonding that need to know the physical device the skb came on. It
saves the real device in a new field in skbuff before overwriting it with
the virtual interface device in skb_bond() and __vlan_hwaccel_rx().
 
This patch is against 2.4.20 kernel and gives compatibility for anyone who 
wants to test the latest release of bonding from source-forge 
(2.4.20-20030317).

diff -Nuarp linux-2.4.20-orig/include/linux/if_vlan.h linux-2.4.20-devel/include/linux/if_vlan.h
--- linux-2.4.20-orig/include/linux/if_vlan.h	2002-11-29 01:53:15.000000000 +0200
+++ linux-2.4.20-devel/include/linux/if_vlan.h	2003-03-04 12:13:23.000000000 +0200
@@ -148,6 +148,9 @@ static inline int __vlan_hwaccel_rx(stru
 {
 	struct net_device_stats *stats;
 
+#ifdef BOND_POINT_TO_POINT_PROT
+	skb->real_dev = skb->dev;
+#endif //BOND_POINT_TO_POINT_PROT
 	skb->dev = grp->vlan_devices[vlan_tag & VLAN_VID_MASK];
 	if (skb->dev == NULL) {
 		kfree_skb(skb);
diff -Nuarp linux-2.4.20-orig/include/linux/skbuff.h linux-2.4.20-devel/include/linux/skbuff.h
--- linux-2.4.20-orig/include/linux/skbuff.h	2002-08-03 03:39:46.000000000 +0300
+++ linux-2.4.20-devel/include/linux/skbuff.h	2003-03-04 11:59:29.000000000 +0200
@@ -135,6 +135,11 @@ struct sk_buff {
 	struct sock	*sk;			/* Socket we are owned by 			*/
 	struct timeval	stamp;			/* Time we arrived				*/
 	struct net_device	*dev;		/* Device we arrived on/are leaving by		*/
+#define BOND_POINT_TO_POINT_PROT
+	struct net_device	*real_dev;	/* For support of point to point protocols 
+						   (e.g. 802.3ad) over bonding, we must save the
+						   physical device that got the packet before
+						   replacing skb->dev with the virtual device.  */
 
 	/* Transport layer header */
 	union
diff -Nuarp linux-2.4.20-orig/net/core/dev.c linux-2.4.20-devel/net/core/dev.c
--- linux-2.4.20-orig/net/core/dev.c	2002-11-29 01:53:15.000000000 +0200
+++ linux-2.4.20-devel/net/core/dev.c	2003-03-03 19:48:15.000000000 +0200
@@ -1328,8 +1328,12 @@ static __inline__ void skb_bond(struct s
 {
 	struct net_device *dev = skb->dev;
 
-	if (dev->master)
-		skb->dev = dev->master;
+	if (dev->master) {
+#ifdef BOND_POINT_TO_POINT_PROT
+		skb->real_dev = skb->dev;
+#endif //BOND_POINT_TO_POINT_PROT
+		skb->dev = dev->master;
+	}
 }
 
 static void net_tx_action(struct softirq_action *h)
diff -Nuarp linux-2.4.20-orig/net/core/skbuff.c linux-2.4.20-devel/net/core/skbuff.c
--- linux-2.4.20-orig/net/core/skbuff.c	2002-08-03 03:39:46.000000000 +0300
+++ linux-2.4.20-devel/net/core/skbuff.c	2003-03-03 19:51:39.000000000 +0200
@@ -231,6 +231,9 @@ static inline void skb_headerinit(void *
 	skb->sk = NULL;
 	skb->stamp.tv_sec=0;	/* No idea about time */
 	skb->dev = NULL;
+#ifdef BOND_POINT_TO_POINT_PROT
+	skb->real_dev = NULL;
+#endif //BOND_POINT_TO_POINT_PROT
 	skb->dst = NULL;
 	memset(skb->cb, 0, sizeof(skb->cb));
 	skb->pkt_type = PACKET_HOST;	/* Default type */
@@ -362,6 +365,9 @@ struct sk_buff *skb_clone(struct sk_buff
 	n->sk = NULL;
 	C(stamp);
 	C(dev);
+#ifdef BOND_POINT_TO_POINT_PROT
+	C(real_dev);
+#endif //BOND_POINT_TO_POINT_PROT
 	C(h);
 	C(nh);
 	C(mac);
@@ -417,6 +423,9 @@ static void copy_skb_header(struct sk_bu
 	new->list=NULL;
 	new->sk=NULL;
 	new->dev=old->dev;
+#ifdef BOND_POINT_TO_POINT_PROT
+	new->real_dev=old->real_dev;
+#endif //BOND_POINT_TO_POINT_PROT
 	new->priority=old->priority;
 	new->protocol=old->protocol;
 	new->dst=dst_clone(old->dst);

-- 
| Shmulik Hen                                    |
| Israel Design Center (Jerusalem)               |
| LAN Access Division                            |
| Intel Communications Group, Intel corp.        |
|                                                |
| Anti-Spam: shmulik dot hen at intel dot com    |
