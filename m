From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 5/22] xfrm offload v2: Attempt to offload bundled xfrm_states for outbound xfrms
Date: Mon, 10 Jan 2005 10:37:00 -0500
Message-ID: <20040110014300.14@ori.thedillows.org>
References: <20040110014300.13@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:39:35-05:00 dave@thedillows.org 
#   Plumb in offloading new bundles for outgoing packets.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/xfrm/xfrm_policy.c
#   2005/01/10 00:39:18-05:00 dave@thedillows.org +47 -0
#   When we create a new bundle for an outbound flow, try to
#   offload as much as the destination driver will allow.
#   
#   Don't forget to clean up....
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# include/net/dst.h
#   2005/01/10 00:39:18-05:00 dave@thedillows.org +2 -0
#   Add a field to store the offload information for this part
#   of the outgoing bundle (non-NULL if this dst is offloaded.)
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/include/net/dst.h b/include/net/dst.h
--- a/include/net/dst.h	2005-01-10 01:19:50 -05:00
+++ b/include/net/dst.h	2005-01-10 01:19:50 -05:00
@@ -65,6 +65,8 @@
 	struct neighbour	*neighbour;
 	struct hh_cache		*hh;
 	struct xfrm_state	*xfrm;
+	struct xfrm_offload	*xfrm_offload;
+	struct dst_entry	*offload_next;
 
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2005-01-10 01:19:50 -05:00
+++ b/net/xfrm/xfrm_policy.c	2005-01-10 01:19:50 -05:00
@@ -40,6 +40,10 @@
 	LIST_HEAD_INIT(xfrm_policy_gc_list);
 static spinlock_t xfrm_policy_gc_lock = SPIN_LOCK_UNLOCKED;
 
+static struct work_struct xfrm_accel_work;
+static struct dst_entry *xfrm_accel_list;
+static spinlock_t xfrm_accel_lock = SPIN_LOCK_UNLOCKED;
+
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 
@@ -707,8 +711,47 @@
 	};
 }
 
+static void xfrm_accel_bundle(struct dst_entry *dst)
+{
+	if (dst->dev && (dst->dev->features & NETIF_F_IPSEC)) {
+		dst_hold(dst);
+
+		spin_lock_bh(&xfrm_accel_lock);
+		dst->offload_next = xfrm_accel_list;
+		xfrm_accel_list = dst;
+		spin_unlock_bh(&xfrm_accel_lock);
+		schedule_work(&xfrm_accel_work);
+	}
+}
+
 static int stale_bundle(struct dst_entry *dst);
 
+static void xfrm_accel_task(void *data)
+{
+	struct dst_entry *dst, *next;
+	struct net_device *dev;
+
+	spin_lock_bh(&xfrm_accel_lock);
+	dst = xfrm_accel_list;
+	xfrm_accel_list = NULL;
+	spin_unlock_bh(&xfrm_accel_lock);
+
+	while (dst) {
+		next = dst->offload_next;
+		dst->offload_next = NULL;
+		dev = dst->dev;
+
+		/* stale_bundle() validates that we have a dev, and that it
+		* is currently running.
+		*/
+		if (!stale_bundle(dst) && (dev->features & NETIF_F_IPSEC))
+			dev->xfrm_bundle_add(dev, dst);
+
+		dst_release(dst);
+		dst = next;
+	}
+}
+
 /* Main function: finds/creates a bundle for given flow.
  *
  * At the moment we eat a raw IP route. Mostly to speed up lookups
@@ -834,6 +877,7 @@
 		dst->next = policy->bundles;
 		policy->bundles = dst;
 		dst_hold(dst);
+		xfrm_accel_bundle(dst);
 		write_unlock_bh(&policy->lock);
 	}
 	*dst_p = dst;
@@ -1025,8 +1069,10 @@
 {
 	if (!dst->xfrm)
 		return;
+	xfrm_offload_release(dst->xfrm_offload);
 	xfrm_state_put(dst->xfrm);
 	dst->xfrm = NULL;
+	dst->xfrm_offload = NULL;
 }
 
 static void xfrm_link_failure(struct sk_buff *skb)
@@ -1238,6 +1284,7 @@
 		panic("XFRM: failed to allocate xfrm_dst_cache\n");
 
 	INIT_WORK(&xfrm_policy_gc_work, xfrm_policy_gc_task, NULL);
+	INIT_WORK(&xfrm_accel_work, xfrm_accel_task, NULL);
 	register_netdevice_notifier(&xfrm_dev_notifier);
 }
 
