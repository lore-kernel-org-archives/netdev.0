From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] 2.5.68 - RCU for SNAP
Date: Tue, 29 Apr 2003 15:48:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429154856.39c75139.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jay Schulist <jschlst@samba.org>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace br_lock() in snap with Read Copy Update.

Straightforward since SNAP uses list macros already.

Tested by bringing up/down Appletalk on SMP system and making sure packets
get through.

This is the last subsystem that depends on br_lock before IPV4,IPV6
can be converted.

--- linux-2.5/net/802/psnap.c	2003-04-14 13:32:25.000000000 -0700
+++ linux-2.5-bridge/net/802/psnap.c	2003-04-29 15:42:04.000000000 -0700
@@ -21,9 +21,9 @@
 #include <linux/mm.h>
 #include <linux/in.h>
 #include <linux/init.h>
-#include <linux/brlock.h>
 
-LIST_HEAD(snap_list);
+static LIST_HEAD(snap_list);
+static spinlock_t snap_lock = SPIN_LOCK_UNLOCKED;
 static struct llc_sap *snap_sap;
 
 /*
@@ -34,17 +34,13 @@
 	struct list_head *entry;
 	struct datalink_proto *proto = NULL, *p;
 
-	if (list_empty(&snap_list))
-		goto out;
-
-	list_for_each(entry, &snap_list) {
+	list_for_each_rcu(entry, &snap_list) {
 		p = list_entry(entry, struct datalink_proto, node);
 		if (!memcmp(p->type, desc, 5)) {
 			proto = p;
 			break;
 		}
 	}
-out:
 	return proto;
 }
 
@@ -55,11 +51,13 @@
 		    struct packet_type *pt)
 {
 	int rc = 1;
-	struct datalink_proto *proto = find_snap_client(skb->h.raw);
+	struct datalink_proto *proto;
 	static struct packet_type snap_packet_type = {
 		.type = __constant_htons(ETH_P_SNAP),
 	};
 
+	rcu_read_lock();
+	proto = find_snap_client(skb->h.raw);
 	if (proto) {
 		/* Pass the frame on. */
 		skb->h.raw  += 5;
@@ -71,6 +69,7 @@
 		rc = 1;
 	}
 
+	rcu_read_unlock();
 	return rc;
 }
 
@@ -124,7 +123,7 @@
 {
 	struct datalink_proto *proto = NULL;
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
+	spin_lock_bh(&snap_lock);
 
 	if (find_snap_client(desc))
 		goto out;
@@ -135,10 +134,12 @@
 		proto->rcvfunc		= rcvfunc;
 		proto->header_length	= 5 + 3; /* snap + 802.2 */
 		proto->request		= snap_request;
-		list_add(&proto->node, &snap_list);
+		list_add_rcu(&proto->node, &snap_list);
 	}
 out:
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&snap_lock);
+
+	synchronize_net();
 	return proto;
 }
 
@@ -147,12 +148,13 @@
  */
 void unregister_snap_client(struct datalink_proto *proto)
 {
-	br_write_lock_bh(BR_NETPROTO_LOCK);
+	spin_lock_bh(&snap_lock);
+	list_del_rcu(&proto->node);
+	spin_unlock_bh(&snap_lock);
 
-	list_del(&proto->node);
-	kfree(proto);
+	synchronize_net();
 
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	kfree(proto);
 }
 
 MODULE_LICENSE("GPL");
