From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V3 01/13] vlan: wrap hw-acceleration calls in separate functions.
Date: Wed, 19 Dec 2012 12:30:36 -0500
Message-ID: <1355938248-8407-2-git-send-email-vyasevic@redhat.com>
References: <1355938248-8407-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755731Ab2LSRbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 12:31:04 -0500
In-Reply-To: <1355938248-8407-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap VLAN hardware acceleration calls into separate functions.  This way
other code can re-use it.

Singed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/if_vlan.h |   57 +++++++++++++++++++++++++++++++++++++++++++++++
 net/8021q/vlan.c        |    4 +--
 net/8021q/vlan_core.c   |   22 ++++++-----------
 3 files changed, 66 insertions(+), 17 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index d06cc5c..5fc6a02 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -158,6 +158,63 @@ static inline bool vlan_uses_dev(const struct net_device *dev)
 #endif
 
 /**
+ * vlan_hw_buggy - Check to see if VLAN hw acceleration is supported.
+ * @dev: netdevice of the lowerdev/hw nic
+ *
+ * Checks to see if HW and driver report VLAN acceleration correctly.
+ */
+static inline bool vlan_hw_buggy(const struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	    (!ops->ndo_vlan_rx_add_vid || !ops->ndo_vlan_rx_kill_vid))
+		return true;
+
+	return false;
+}
+
+/**
+ * vlan_vid_add_hw - Add the VLAN vid to the HW filter
+ * @dev: netdevice of the lowerdev/hw nic
+ * @vid: vlan id.
+ *
+ * Inserts the vid into the HW vlan filter table if hw supports it.
+ */
+static inline int vlan_vid_add_hw(const struct netdevice *dev,
+				  unsigned short vid)
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
+
+/**
+ * vlan_vid_del_hw - Delete the VLAN vid from the HW filter
+ * @dev: netdevice of the lowerdev/hw nic
+ * @vid: vlan id.
+ *
+ * Delete the vid from the HW vlan filter table if hw supports it.
+ */
+static inline int vlan_vid_del_hw(const struct netdevice *dev,
+				  unsigned short vid)
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
+
+/**
  * vlan_insert_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
  * @vlan_tci: VLAN TCI to insert
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index a292e80..d1ac63f 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -115,15 +115,13 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
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
index 65e06ab..52d83be 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -220,13 +220,10 @@ static int __vlan_vid_add(struct vlan_info *vlan_info, unsigned short vid,
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
@@ -278,13 +275,10 @@ static void __vlan_vid_del(struct vlan_info *vlan_info,
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
