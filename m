From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: [PATCH] Handle shared SKBs in VLAN receive code
Date: Sat, 11 Oct 2003 01:38:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F87430D.2040000@tpack.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000107050007030202030904"
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000107050007030202030904
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

As noted by Jonas Munsin, the vlan patch that went into 2.6.0-test7 did a
kfree() rather than a kfree_skb(). Hmm.

Instead of just fixing this up, I suggest we do things the right way:

The VLAN code have long been claiming to handle shared SKBs, without actually
doing so. I have now added the call to skb_share_check().

This enables us to simply do a skb_unshare() when mangling the ethernet header.


Patch is against linux-2.6.0-test7 (applies to 2.4.23-pre7 as well).

-Tommy

--------------000107050007030202030904
Content-Type: text/plain;
 name="vlan_dev.c.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan_dev.c.patch"

diff -ru linux-2.6.0-test7/net/8021q/vlan_dev.c linux-2.6/net/8021q/vlan_dev.c
--- linux-2.6.0-test7/net/8021q/vlan_dev.c	Wed Oct  8 21:24:44 2003
+++ linux-2.6/net/8021q/vlan_dev.c	Sat Oct 11 00:45:28 2003
@@ -74,11 +74,7 @@
 static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
 {
 	if (VLAN_DEV_INFO(skb->dev)->flags & 1) {
-		if (skb_shared(skb) || skb_cloned(skb)) {
-			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
-			kfree(skb);
-			skb = nskb;
-		}
+		skb = skb_unshare(skb, GFP_ATOMIC);
 		if (skb) {
 			/* Lifted from Gleb's VLAN code... */
 			memmove(skb->data - ETH_HLEN,
@@ -121,6 +117,7 @@
 	struct net_device_stats *stats;
 	unsigned short vlan_TCI;
 	unsigned short proto;
+	struct net_device *vlan_dev;
 
 	/* vlan_TCI = ntohs(get_unaligned(&vhdr->h_vlan_TCI)); */
 	vlan_TCI = ntohs(vhdr->h_vlan_TCI);
@@ -144,8 +141,8 @@
 	 */
 
 	spin_lock_bh(&vlan_group_lock);
-	skb->dev = __find_vlan_dev(dev, vid);
-	if (!skb->dev) {
+	vlan_dev = __find_vlan_dev(dev, vid);
+	if (!vlan_dev) {
 		spin_unlock_bh(&vlan_group_lock);
 
 #ifdef VLAN_DEBUG
@@ -156,10 +153,18 @@
 		return -1;
 	}
 
-	skb->dev->last_rx = jiffies;
+	vlan_dev->last_rx = jiffies;
+	stats = vlan_dev_get_stats(vlan_dev);
+
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb) {
+		spin_unlock_bh(&vlan_group_lock);
+		stats->rx_dropped++;
+		return NET_RX_DROP;
+	}
+	skb->dev = vlan_dev;
 
 	/* Bump the rx counters for the VLAN device. */
-	stats = vlan_dev_get_stats(skb->dev);
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 


--------------000107050007030202030904--
