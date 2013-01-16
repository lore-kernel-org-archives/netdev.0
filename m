From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V6 01/14] vlan: wrap hw-acceleration calls in separate functions.
Date: Wed, 16 Jan 2013 13:17:56 -0500
Message-ID: <1358360289-23249-2-git-send-email-vyasevic@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com, shmulik.ladkani@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55357 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365Ab3APSSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 13:18:14 -0500
In-Reply-To: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap VLAN hardware acceleration calls into separate functions.  This way
other code can re-use it.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/if_vlan.h |   21 ++++++++++++
 net/8021q/vlan.c        |    4 +--
 net/8021q/vlan_core.c   |   81 +++++++++++++++++++++++++++++++++++++---------
 3 files changed, 87 insertions(+), 19 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index d06cc5c..b658eda 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -93,6 +93,10 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 extern bool vlan_do_receive(struct sk_buff **skb);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 
+extern bool vlan_hw_buggy(const struct net_device *dev);
+extern int vlan_vid_add_hw(struct net_device *dev, unsigned short vid);
+extern int vlan_vid_del_hw(struct net_device *dev, unsigned short vid);
+
 extern int vlan_vid_add(struct net_device *dev, unsigned short vid);
 extern void vlan_vid_del(struct net_device *dev, unsigned short vid);
 
@@ -155,6 +159,23 @@ static inline bool vlan_uses_dev(const struct net_device *dev)
 {
 	return false;
 }
+
+static inline bool vlan_hw_buggy(const struct net_device *dev)
+{
+	return false;
+}
+
+static inline int vlan_vid_add_hw(struct net_device *dev,
+				  unsigned short vid)
+{
+	return 0;
+}
+
+static inline int vlan_vid_del_hw(struct net_device *dev,
+				  unsigned short vid)
+{
+	return 0;
+}
 #endif
 
 /**
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index babfde9..540d759 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -117,15 +117,13 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 {
 	const char *name = real_dev->name;
-	const struct net_device_ops *ops = real_dev->netdev_ops;
 
 	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		pr_info("VLANs not supported on %s\n", name);
 		return -EOPNOTSUPP;
 	}
 
-	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
-	    (!ops->ndo_vlan_rx_add_vid || !ops->ndo_vlan_rx_kill_vid)) {
+	if (vlan_hw_buggy(real_dev)) {
 		pr_info("Device %s has buggy VLAN hw accel\n", name);
 		return -EOPNOTSUPP;
 	}
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 380440b..d044dd3 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -145,6 +145,63 @@ err_free:
 	return NULL;
 }
 
+/**
+ * vlan_hw_buggy - Check to see if VLAN hw acceleration is supported.
+ * @dev: netdevice of the lowerdev/hw nic
+ *
+ * Checks to see if HW and driver report VLAN acceleration correctly.
+ */
+bool vlan_hw_buggy(const struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	    (!ops->ndo_vlan_rx_add_vid || !ops->ndo_vlan_rx_kill_vid))
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL(vlan_hw_buggy);
+
+/**
+ * vlan_vid_add_hw - Add the VLAN vid to the HW filter
+ * @dev: netdevice of the lowerdev/hw nic
+ * @vid: vlan id.
+ *
+ * Inserts the vid into the HW vlan filter table if hw supports it.
+ */
+int vlan_vid_add_hw(struct net_device *dev, unsigned short vid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	int err = 0;
+
+	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	    ops->ndo_vlan_rx_add_vid)
+		err = ops->ndo_vlan_rx_add_vid(dev, vid);
+
+	return err;
+}
+EXPORT_SYMBOL(vlan_vid_add_hw);
+
+/**
+ * vlan_vid_del_hw - Delete the VLAN vid from the HW filter
+ * @dev: netdevice of the lowerdev/hw nic
+ * @vid: vlan id.
+ *
+ * Delete the vid from the HW vlan filter table if hw supports it.
+ */
+int vlan_vid_del_hw(struct net_device *dev, unsigned short vid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	int err = 0;
+
+	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	    ops->ndo_vlan_rx_kill_vid)
+		err = ops->ndo_vlan_rx_add_vid(dev, vid);
+
+	return err;
+}
+EXPORT_SYMBOL(vlan_vid_del_hw);
 
 /*
  * vlan info and vid list
@@ -216,7 +273,6 @@ static int __vlan_vid_add(struct vlan_info *vlan_info, unsigned short vid,
 			  struct vlan_vid_info **pvid_info)
 {
 	struct net_device *dev = vlan_info->real_dev;
-	const struct net_device_ops *ops = dev->netdev_ops;
 	struct vlan_vid_info *vid_info;
 	int err;
 
@@ -224,13 +280,10 @@ static int __vlan_vid_add(struct vlan_info *vlan_info, unsigned short vid,
 	if (!vid_info)
 		return -ENOMEM;
 
-	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
-	    ops->ndo_vlan_rx_add_vid) {
-		err =  ops->ndo_vlan_rx_add_vid(dev, vid);
-		if (err) {
-			kfree(vid_info);
-			return err;
-		}
+	err = vlan_vid_add_hw(dev, vid);
+	if (err) {
+		kfree(vid_info);
+		return err;
 	}
 	list_add(&vid_info->list, &vlan_info->vid_list);
 	vlan_info->nr_vids++;
@@ -278,17 +331,13 @@ static void __vlan_vid_del(struct vlan_info *vlan_info,
 			   struct vlan_vid_info *vid_info)
 {
 	struct net_device *dev = vlan_info->real_dev;
-	const struct net_device_ops *ops = dev->netdev_ops;
 	unsigned short vid = vid_info->vid;
 	int err;
 
-	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
-	     ops->ndo_vlan_rx_kill_vid) {
-		err = ops->ndo_vlan_rx_kill_vid(dev, vid);
-		if (err) {
-			pr_warn("failed to kill vid %d for device %s\n",
-				vid, dev->name);
-		}
+	err = vlan_vid_del_hw(dev, vid);
+	if (err) {
+		pr_warn("failed to kill vid %d for device %s\n",
+			vid, dev->name);
 	}
 	list_del(&vid_info->list);
 	kfree(vid_info);
-- 
1.7.7.6
