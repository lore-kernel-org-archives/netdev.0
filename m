From: Shmuel Hen <shmulik.hen@intel.com>
Subject: [PATCH] [8021q] Use VLAN tag set functionality in 8021q module (resend)
Date: Thu, 5 Feb 2004 15:59:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402051559.45159.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Make the regular/HW accelerated xmit functions in the 8021q module 
use the new set VLAN tag functionality to reduce code duplication. 

Tested for patch application and compilation against linux-2.6.2.

 
-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |


diff -Nuarp a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
--- a/net/8021q/vlan_dev.c	Wed Jan 21 16:56:13 2004
+++ b/net/8021q/vlan_dev.c	Wed Jan 21 16:56:15 2004
@@ -445,6 +445,7 @@ int vlan_dev_hard_start_xmit(struct sk_b
 	 */
 
 	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
+		int orig_headroom = skb_headroom(skb);
 		unsigned short veth_TCI;
 
 		/* This is not a VLAN frame...but we can fix that! */
@@ -454,33 +455,7 @@ int vlan_dev_hard_start_xmit(struct sk_b
 		printk(VLAN_DBG "%s: proto to encap: 0x%hx (hbo)\n",
 			__FUNCTION__, htons(veth->h_vlan_proto));
 #endif
-
-		if (skb_headroom(skb) < VLAN_HLEN) {
-			struct sk_buff *sk_tmp = skb;
-			skb = skb_realloc_headroom(sk_tmp, VLAN_HLEN);
-			kfree_skb(sk_tmp);
-			if (skb == NULL) {
-				stats->tx_dropped++;
-				return 0;
-			}
-			VLAN_DEV_INFO(dev)->cnt_inc_headroom_on_tx++;
-		} else {
-			if (!(skb = skb_unshare(skb, GFP_ATOMIC))) {
-				printk(KERN_ERR "vlan: failed to unshare skbuff\n");
-				stats->tx_dropped++;
-				return 0;
-			}
-		}
-		veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
-
-		/* Move the mac addresses to the beginning of the new header. */
-		memmove(skb->data, skb->data + VLAN_HLEN, 12);
-
-		/* first, the ethernet type */
-		/* put_unaligned(__constant_htons(ETH_P_8021Q), &veth->h_vlan_proto); */
-		veth->h_vlan_proto = __constant_htons(ETH_P_8021Q);
-
-		/* Now, construct the second two bytes. This field looks something
+		/* Construct the second two bytes. This field looks something
 		 * like:
 		 * usr_priority: 3 bits	 (high bits)
 		 * CFI		 1 bit
@@ -489,10 +464,16 @@ int vlan_dev_hard_start_xmit(struct sk_b
 		veth_TCI = VLAN_DEV_INFO(dev)->vlan_id;
 		veth_TCI |= vlan_dev_get_egress_qos_mask(dev, skb);
 
-		veth->h_vlan_TCI = htons(veth_TCI);
-	}
+		skb = __vlan_put_tag(skb, veth_TCI);
+		if (!skb) {
+			stats->tx_dropped++;
+			return 0;
+		}
 
-	skb->dev = VLAN_DEV_INFO(dev)->real_dev;
+		if (orig_headroom < VLAN_HLEN) {
+			VLAN_DEV_INFO(dev)->cnt_inc_headroom_on_tx++;
+		}
+	}
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "%s: about to send skb: %p to dev: %s\n",
@@ -506,10 +487,7 @@ int vlan_dev_hard_start_xmit(struct sk_b
 	stats->tx_packets++; /* for statics only */
 	stats->tx_bytes += skb->len;
 
-	skb->protocol = __constant_htons(ETH_P_8021Q);
-	skb->mac.raw -= VLAN_HLEN;
-	skb->nh.raw -= VLAN_HLEN;
-
+	skb->dev = VLAN_DEV_INFO(dev)->real_dev;
 	dev_queue_xmit(skb);
 
 	return 0;
@@ -518,17 +496,22 @@ int vlan_dev_hard_start_xmit(struct sk_b
 int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = vlan_dev_get_stats(dev);
-	struct vlan_skb_tx_cookie *cookie;
+	unsigned short veth_TCI;
+
+	/* Construct the second two bytes. This field looks something
+	 * like:
+	 * usr_priority: 3 bits	 (high bits)
+	 * CFI		 1 bit
+	 * VLAN ID	 12 bits (low bits)
+	 */
+	veth_TCI = VLAN_DEV_INFO(dev)->vlan_id;
+	veth_TCI |= vlan_dev_get_egress_qos_mask(dev, skb);
+	skb = __vlan_hwaccel_put_tag(skb, veth_TCI);
 
 	stats->tx_packets++;
 	stats->tx_bytes += skb->len;
 
 	skb->dev = VLAN_DEV_INFO(dev)->real_dev;
-	cookie = VLAN_TX_SKB_CB(skb);
-	cookie->magic = VLAN_TX_COOKIE_MAGIC;
-	cookie->vlan_tag = (VLAN_DEV_INFO(dev)->vlan_id |
-			    vlan_dev_get_egress_qos_mask(dev, skb));
-
 	dev_queue_xmit(skb);
 
 	return 0;
