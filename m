From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 1/2] vlan: export functions to register/unregister vlan devices
Date: Tue, 24 Sep 2013 17:27:09 +0100
Message-ID: <1380040030-6648-2-git-send-email-jchapman@katalix.com>
References: <1380040030-6648-1-git-send-email-jchapman@katalix.com>
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:42170 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753032Ab3IXQ1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 12:27:16 -0400
In-Reply-To: <1380040030-6648-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export two new symbols to let external code register and unregister
vlan devices. Allow the caller to specify the name template for the
new netdev instance.

The new symbols are:
vlan_register_device
unregister_vlan_dev
---
 include/linux/if_vlan.h |   11 ++++++
 net/8021q/vlan.c        |   82 ++++++++++++++++++++++++++++------------------
 2 files changed, 61 insertions(+), 32 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 715c343..c6431d5 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -101,6 +101,8 @@ extern void vlan_vids_del_by_dev(struct net_device *dev,
 				 const struct net_device *by_dev);
 
 extern bool vlan_uses_dev(const struct net_device *dev);
+extern int vlan_register_device(struct net_device *real_dev, u16 vlan_id, struct net_device **dev, char *name);
+extern void unregister_vlan_dev(struct net_device *dev, struct list_head *head);
 #else
 static inline struct net_device *
 __vlan_find_dev_deep(struct net_device *real_dev,
@@ -155,6 +157,15 @@ static inline bool vlan_uses_dev(const struct net_device *dev)
 {
 	return false;
 }
+
+static inline int vlan_register_device(struct net_device *real_dev, u16 vlan_id, struct net_device **dev, char *name)
+{
+	return -EPROTONOSUPPORT;
+}
+
+static inline void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
+{
+}
 #endif
 
 static inline bool vlan_hw_offload_capable(netdev_features_t features,
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 61fc573..272157c 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -121,6 +121,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	/* Get rid of the vlan's reference to real_dev */
 	dev_put(real_dev);
 }
+EXPORT_SYMBOL(unregister_vlan_dev);
 
 int vlan_check_real_dev(struct net_device *real_dev,
 			__be16 protocol, u16 vlan_id)
@@ -204,18 +205,16 @@ out_vid_del:
 	return err;
 }
 
-/*  Attach a VLAN device to a mac address (ie Ethernet Card).
- *  Returns 0 if the device was created or a negative error code otherwise.
- */
-static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
+int vlan_register_device(struct net_device *real_dev, u16 vlan_id, struct net_device **dev, char *name)
 {
 	struct net_device *new_dev;
 	struct vlan_dev_priv *vlan;
 	struct net *net = dev_net(real_dev);
-	struct vlan_net *vn = net_generic(net, vlan_net_id);
-	char name[IFNAMSIZ];
 	int err;
 
+	if (!dev || !name)
+		return -EINVAL;
+
 	if (vlan_id >= VLAN_VID_MASK)
 		return -ERANGE;
 
@@ -223,32 +222,6 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	if (err < 0)
 		return err;
 
-	/* Gotta set up the fields for the device. */
-	switch (vn->name_type) {
-	case VLAN_NAME_TYPE_RAW_PLUS_VID:
-		/* name will look like:	 eth1.0005 */
-		snprintf(name, IFNAMSIZ, "%s.%.4i", real_dev->name, vlan_id);
-		break;
-	case VLAN_NAME_TYPE_PLUS_VID_NO_PAD:
-		/* Put our vlan.VID in the name.
-		 * Name will look like:	 vlan5
-		 */
-		snprintf(name, IFNAMSIZ, "vlan%i", vlan_id);
-		break;
-	case VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD:
-		/* Put our vlan.VID in the name.
-		 * Name will look like:	 eth0.5
-		 */
-		snprintf(name, IFNAMSIZ, "%s.%i", real_dev->name, vlan_id);
-		break;
-	case VLAN_NAME_TYPE_PLUS_VID:
-		/* Put our vlan.VID in the name.
-		 * Name will look like:	 vlan0005
-		 */
-	default:
-		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
-	}
-
 	new_dev = alloc_netdev(sizeof(struct vlan_dev_priv), name, vlan_setup);
 
 	if (new_dev == NULL)
@@ -273,12 +246,57 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	if (err < 0)
 		goto out_free_newdev;
 
+	*dev = new_dev;
+
 	return 0;
 
 out_free_newdev:
 	free_netdev(new_dev);
 	return err;
 }
+EXPORT_SYMBOL(vlan_register_device);
+
+/*  Attach a VLAN device to a mac address (ie Ethernet Card).
+ *  Returns 0 if the device was created or a negative error code otherwise.
+ */
+static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
+{
+	struct net_device *new_dev;
+	struct net *net = dev_net(real_dev);
+	struct vlan_net *vn = net_generic(net, vlan_net_id);
+	char name[IFNAMSIZ];
+	int err;
+
+	/* Gotta set up the fields for the device. */
+	switch (vn->name_type) {
+	case VLAN_NAME_TYPE_RAW_PLUS_VID:
+		/* name will look like:	 eth1.0005 */
+		snprintf(name, IFNAMSIZ, "%s.%.4i", real_dev->name, vlan_id);
+		break;
+	case VLAN_NAME_TYPE_PLUS_VID_NO_PAD:
+		/* Put our vlan.VID in the name.
+		 * Name will look like:	 vlan5
+		 */
+		snprintf(name, IFNAMSIZ, "vlan%i", vlan_id);
+		break;
+	case VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD:
+		/* Put our vlan.VID in the name.
+		 * Name will look like:	 eth0.5
+		 */
+		snprintf(name, IFNAMSIZ, "%s.%i", real_dev->name, vlan_id);
+		break;
+	case VLAN_NAME_TYPE_PLUS_VID:
+		/* Put our vlan.VID in the name.
+		 * Name will look like:	 vlan0005
+		 */
+	default:
+		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
+	}
+
+	err = vlan_register_device(real_dev, vlan_id, &new_dev, name);
+
+	return err;
+}
 
 static void vlan_sync_address(struct net_device *dev,
 			      struct net_device *vlandev)
-- 
1.7.0.4
