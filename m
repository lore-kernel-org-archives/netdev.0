From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.68] [BRIDGE] Get write lock config PDU processing
Date: Thu, 24 Apr 2003 13:48:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030424134831.5619fa68.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All received packets are being processed with only read lock held.
Since processing a Spanning Tree Protocol (STP) packet can cause changes
in bridge configuration; a write lock should be acquired.  Must also
check for state transistions during that interval.

Also, keep comments in sync with locking, and don't retest same
state variables already checked in the call chain.

diff -Nru a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c	Thu Apr 24 13:40:23 2003
+++ b/net/bridge/br_input.c	Thu Apr 24 13:40:23 2003
@@ -167,13 +167,8 @@
 	return 0;
 
 handle_special_frame:
-	if (!dest[5]) {
-		br_stp_handle_bpdu(skb);
-		read_unlock(&br->lock);
-		return 0;
-	}
-
-	kfree_skb(skb);
 	read_unlock(&br->lock);
-	return 0;
+	if (!dest[5]) 
+		br_stp_handle_bpdu(skb);
+	goto err_nolock;
 }
diff -Nru a/net/bridge/br_stp.c b/net/bridge/br_stp.c
--- a/net/bridge/br_stp.c	Thu Apr 24 13:40:23 2003
+++ b/net/bridge/br_stp.c	Thu Apr 24 13:40:23 2003
@@ -22,7 +22,7 @@
 
 
 
-/* called under ioctl_lock or bridge lock */
+/* called under bridge lock */
 int br_is_root_bridge(struct net_bridge *br)
 {
 	return !memcmp(&br->bridge_id, &br->designated_root, 8);
@@ -35,7 +35,7 @@
 		(p->designated_port == p->port_id);
 }
 
-/* called under ioctl_lock or bridge lock */
+/* called under bridge lock */
 struct net_bridge_port *br_get_port(struct net_bridge *br, int port_no)
 {
 	struct net_bridge_port *p;
@@ -419,18 +419,13 @@
 	br_transmit_config(p);
 }
 
-/* lock-safe */
+/* called under bridge lock */
 void br_received_config_bpdu(struct net_bridge_port *p, struct br_config_bpdu *bpdu)
 {
 	struct net_bridge *br;
 	int was_root;
 
-	if (p->state == BR_STATE_DISABLED)
-		return;
-
 	br = p->br;
-	read_lock(&br->lock);
-
 	was_root = br_is_root_bridge(br);
 	if (br_supersedes_port_info(p, bpdu)) {
 		br_record_config_information(p, bpdu);
@@ -455,21 +450,16 @@
 	} else if (br_is_designated_port(p)) {		
 		br_reply(p);		
 	}
-
-	read_unlock(&br->lock);
 }
 
-/* lock-safe */
+/* called under bridge lock */
 void br_received_tcn_bpdu(struct net_bridge_port *p)
 {
-	read_lock(&p->br->lock);
-	if (p->state != BR_STATE_DISABLED &&
-	    br_is_designated_port(p)) {
+	if (br_is_designated_port(p)) {
 		printk(KERN_INFO "%s: received tcn bpdu on port %i(%s)\n",
 		       p->br->dev.name, p->port_no, p->dev->name);
 
 		br_topology_change_detection(p->br);
 		br_topology_change_acknowledge(p);
 	}
-	read_unlock(&p->br->lock);
 }
diff -Nru a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
--- a/net/bridge/br_stp_bpdu.c	Thu Apr 24 13:40:23 2003
+++ b/net/bridge/br_stp_bpdu.c	Thu Apr 24 13:40:23 2003
@@ -132,18 +132,23 @@
 
 static unsigned char header[6] = {0x42, 0x42, 0x03, 0x00, 0x00, 0x00};
 
-/* called under bridge lock */
+/* NO locks */
 void br_stp_handle_bpdu(struct sk_buff *skb)
 {
 	unsigned char *buf;
 	struct net_bridge_port *p;
+	struct net_bridge *br;
 
 	buf = skb->mac.raw + 14;
 	p = skb->dev->br_port;
-	if (!p->br->stp_enabled || memcmp(buf, header, 6)) {
-		kfree_skb(skb);
-		return;
-	}
+	br = p->br;
+
+	write_lock_bh(&br->lock);
+	if (p->state == BR_STATE_DISABLED 
+	    || !(br->dev.flags & IFF_UP)
+	    || !br->stp_enabled 
+	    || memcmp(buf, header, 6)) 
+		goto out;
 
 	if (buf[6] == BPDU_TYPE_CONFIG) {
 		struct br_config_bpdu bpdu;
@@ -178,16 +183,14 @@
 		bpdu.hello_time = br_get_ticks(buf+34);
 		bpdu.forward_delay = br_get_ticks(buf+36);
 
-		kfree_skb(skb);
 		br_received_config_bpdu(p, &bpdu);
-		return;
+		goto out;
 	}
 
 	if (buf[6] == BPDU_TYPE_TCN) {
 		br_received_tcn_bpdu(p);
-		kfree_skb(skb);
-		return;
+		goto out;
 	}
-
-	kfree_skb(skb);
+ out:
+	write_unlock_bh(&br->lock);
 }
