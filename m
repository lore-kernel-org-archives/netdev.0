From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] consolidate skb delivery
Date: Thu, 2 Oct 2003 10:21:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002102133.7285b5ee.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several places all have the same code for delivering skb's to protocols.
Consolidate into one inline function and give preference to new protocols.

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Thu Oct  2 10:01:13 2003
+++ b/net/core/dev.c	Thu Oct  2 10:01:13 2003
@@ -1489,6 +1489,18 @@
 	}
 }
 
+static __inline__ int deliver_skb(struct sk_buff *skb,
+				  struct packet_type *pt_prev, int last)
+{
+	if (unlikely(!pt_prev->data))
+		return deliver_to_old_ones(pt_prev, skb, last);
+	else {
+		atomic_inc(&skb->users);
+		return pt_prev->func(skb, skb->dev, pt_prev);
+	}
+}
+
+
 #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
 int (*br_handle_frame_hook)(struct sk_buff *skb);
 
@@ -1496,15 +1508,8 @@
 				     struct packet_type *pt_prev)
 {
 	int ret = NET_RX_DROP;
-
-	if (pt_prev) {
-		if (!pt_prev->data)
-			ret = deliver_to_old_ones(pt_prev, skb, 0);
-		else {
-			atomic_inc(&skb->users);
-			ret = pt_prev->func(skb, skb->dev, pt_prev);
-		}
-	}
+	if (pt_prev)
+		ret = deliver_skb(skb, pt_prev, 0);
 
 	return ret;
 }
@@ -1552,16 +1557,8 @@
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
-			if (pt_prev) {
-				if (!pt_prev->data) {
-					ret = deliver_to_old_ones(pt_prev,
-								  skb, 0);
-				} else {
-					atomic_inc(&skb->users);
-					ret = pt_prev->func(skb, skb->dev,
-							    pt_prev);
-				}
-			}
+			if (pt_prev) 
+				ret = deliver_skb(skb, pt_prev, 0);
 			pt_prev = ptype;
 		}
 	}
@@ -1574,27 +1571,15 @@
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {
 		if (ptype->type == type &&
 		    (!ptype->dev || ptype->dev == skb->dev)) {
-			if (pt_prev) {
-				if (!pt_prev->data) {
-					ret = deliver_to_old_ones(pt_prev,
-								  skb, 0);
-				} else {
-					atomic_inc(&skb->users);
-					ret = pt_prev->func(skb, skb->dev,
-							    pt_prev);
-				}
-			}
+			if (pt_prev) 
+				ret = deliver_skb(skb, pt_prev, 0);
 			pt_prev = ptype;
 		}
 	}
 
-	if (pt_prev) {
-		if (!pt_prev->data) {
-			ret = deliver_to_old_ones(pt_prev, skb, 1);
-		} else {
-			ret = pt_prev->func(skb, skb->dev, pt_prev);
-		}
-	} else {
+	if (pt_prev)
+		ret = deliver_skb(skb, pt_prev, 1);
+	else {
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)
