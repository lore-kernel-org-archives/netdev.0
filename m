From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 7/22] xfrm offload v2: Allow device drivers to force recalculation of offloads
Date: Mon, 10 Jan 2005 10:37:00 -0500
Message-ID: <20040110014300.16@ori.thedillows.org>
References: <20040110014300.15@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:46:32-05:00 dave@thedillows.org 
#   Give device drivers a method to allow the use of crypto
#   offload features for existing xfrm_states and bundles, as
#   well as dynamically remove crypto offload capabilities.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/xfrm/xfrm_state.c
#   2005/01/10 00:46:14-05:00 dave@thedillows.org +39 -0
#   When we've been informed of a new device that can offload
#   xfrm crypto operations, go ahead and offload existing inbound
#   xfrm_states to it.
#   
#   When we're removing crypto offload capabilities, remove every
#   offload instance for that device.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/xfrm/xfrm_policy.c
#   2005/01/10 00:46:14-05:00 dave@thedillows.org +17 -0
#   When adding/removing xfrm offload capable device, give the xfrm_state
#   engine a chance to make the changes it needs, then flush any existing
#   bundles that use the device so that future flows get a chance to use
#   the offload features (for add), or resume using the software crypto
#   routines (for remove).
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/xfrm/xfrm_export.c
#   2005/01/10 00:46:14-05:00 dave@thedillows.org +2 -0
#   Export the driver-visible API.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# include/net/xfrm.h
#   2005/01/10 00:46:14-05:00 dave@thedillows.org +4 -0
#   Prototypes for the new routines.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2005-01-10 01:19:25 -05:00
+++ b/include/net/xfrm.h	2005-01-10 01:19:25 -05:00
@@ -826,6 +826,8 @@
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern void xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto);
+extern void xfrm_state_accel_add(struct net_device *dev);
+extern void xfrm_state_accel_flush(struct net_device *dev);
 extern int xfrm_replay_check(struct xfrm_state *x, u32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, u32 seq);
 extern int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb);
@@ -879,6 +881,8 @@
 extern void xfrm_policy_flush(void);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_flush_bundles(void);
+extern void xfrm_accel_add(struct net_device *dev);
+extern void xfrm_accel_flush(struct net_device *dev);
 
 extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
diff -Nru a/net/xfrm/xfrm_export.c b/net/xfrm/xfrm_export.c
--- a/net/xfrm/xfrm_export.c	2005-01-10 01:19:25 -05:00
+++ b/net/xfrm/xfrm_export.c	2005-01-10 01:19:25 -05:00
@@ -62,3 +62,5 @@
 EXPORT_SYMBOL_GPL(skb_icv_walk);
 
 EXPORT_SYMBOL_GPL(xfrm_state_offload_add);
+EXPORT_SYMBOL_GPL(xfrm_accel_add);
+EXPORT_SYMBOL_GPL(xfrm_accel_flush);
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2005-01-10 01:19:25 -05:00
+++ b/net/xfrm/xfrm_policy.c	2005-01-10 01:19:25 -05:00
@@ -1141,6 +1141,23 @@
 	return 0;
 }
 
+static int bundle_uses_dev(struct dst_entry *dst, void *dev)
+{
+	return (dst->dev == dev);
+}
+
+void xfrm_accel_add(struct net_device *dev)
+{
+	xfrm_state_accel_add(dev);
+	xfrm_prune_bundles(bundle_uses_dev, dev);
+}
+
+void xfrm_accel_flush(struct net_device *dev)
+{
+	xfrm_state_accel_flush(dev);
+	xfrm_prune_bundles(bundle_uses_dev, dev);
+}
+
 /* Well... that's _TASK_. We need to scan through transformation
  * list and figure out what mss tcp should generate in order to
  * final datagram fit to mtu. Mama mia... :-)
diff -Nru a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c	2005-01-10 01:19:25 -05:00
+++ b/net/xfrm/xfrm_state.c	2005-01-10 01:19:25 -05:00
@@ -999,6 +999,45 @@
 		xfrm_offload_release(old);
 }
 
+static int try_new_accel(struct xfrm_state *x, int unused, void *data)
+{
+	struct net_device *dev = data;
+
+	if (x->dir == XFRM_STATE_DIR_IN)
+		dev->xfrm_state_add(dev, x);
+	return 0;
+}
+
+static int remove_stale_accel(struct xfrm_state *x, int unused, void *dev)
+{
+	struct xfrm_offload *xol, *entry = NULL;
+
+	spin_lock(&x->lock);
+	list_for_each_entry(xol, &x->offloads, bydev) {
+		if (xol->dev == dev) {
+			list_del(&xol->bydev);
+			entry = xol;
+			break;
+		}
+	}
+	spin_unlock(&x->lock);
+
+	if (entry)
+		xfrm_offload_release(entry);
+
+	return 0;
+}
+
+void xfrm_state_accel_add(struct net_device *dev)
+{
+	xfrm_state_walk(IPSEC_PROTO_ANY, try_new_accel, dev);
+}
+
+void xfrm_state_accel_flush(struct net_device *dev)
+{
+	xfrm_state_walk(IPSEC_PROTO_ANY, remove_stale_accel, dev);
+}
+
 void __init xfrm_state_init(void)
 {
 	int i;
