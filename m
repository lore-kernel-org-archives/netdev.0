From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 4/22] xfrm offload v2: Try to offload inbound xfrm_states
Date: Mon, 10 Jan 2005 10:36:59 -0500
Message-ID: <20040110014300.13@ori.thedillows.org>
References: <20040110014300.12@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:08:02-05:00 dave@thedillows.org 
#   Plumb in offloading of inbound xfrm_states.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/xfrm/xfrm_state.c
#   2005/01/10 00:07:45-05:00 dave@thedillows.org +26 -1
#   Try to offload an inbound xfrm_state when it is added or updated.
#   Since it could potentially come in from any interface, try to
#   offload it on all devices that support it.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c	2005-01-10 01:20:02 -05:00
+++ b/net/xfrm/xfrm_state.c	2005-01-10 01:20:02 -05:00
@@ -401,6 +401,24 @@
 	spin_unlock_bh(&xfrm_state_lock);
 }
 
+static void xfrm_state_inbound_accel(struct xfrm_state *x)
+{
+	/* Only called for an inbound xfrm_state. Since it could
+	 * possibly arrive on any interface, try to offload it
+	 * on all devices that are capable.
+	 */
+	struct net_device *dev;
+
+	rtnl_lock();
+	dev = dev_base;
+	while (dev) {
+		if (netif_running(dev) && (dev->features & NETIF_F_IPSEC))
+			dev->xfrm_state_add(dev, x);
+		dev = dev->next;
+	}
+	rtnl_unlock();
+}
+
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
 
 int xfrm_state_add(struct xfrm_state *x)
@@ -447,6 +465,9 @@
 	spin_unlock_bh(&xfrm_state_lock);
 	xfrm_state_put_afinfo(afinfo);
 
+	if (!err && x->dir == XFRM_STATE_DIR_IN)
+		xfrm_state_inbound_accel(x);
+
 	if (x1) {
 		xfrm_state_delete(x1);
 		xfrm_state_put(x1);
@@ -458,7 +479,7 @@
 int xfrm_state_update(struct xfrm_state *x)
 {
 	struct xfrm_state_afinfo *afinfo;
-	struct xfrm_state *x1;
+	struct xfrm_state *x1, *accel = NULL;
 	int err;
 
 	afinfo = xfrm_state_get_afinfo(x->props.family);
@@ -482,6 +503,7 @@
 
 	if (x1->km.state == XFRM_STATE_ACQ) {
 		__xfrm_state_insert(x);
+		accel = x;
 		x = NULL;
 	}
 	err = 0;
@@ -492,6 +514,9 @@
 
 	if (err)
 		return err;
+
+	if (accel && accel->dir == XFRM_STATE_DIR_IN)
+		xfrm_state_inbound_accel(accel);
 
 	if (!x) {
 		xfrm_state_delete(x1);
