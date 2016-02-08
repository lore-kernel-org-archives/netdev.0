From: Kan Liang <kan.liang@intel.com>
Subject: [PATCH V4 5/8] net/ethtool: support set coalesce per queue
Date: Mon,  8 Feb 2016 02:45:37 -0500
Message-ID: <1454917540-10648-6-git-send-email-kan.liang@intel.com>
References: <1454917540-10648-1-git-send-email-kan.liang@intel.com>
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com, Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org,
	ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50920 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753789AbcBHPFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 10:05:35 -0500
In-Reply-To: <1454917540-10648-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch implements sub command ETHTOOL_SCOALESCE for ioctl
ETHTOOL_PERQUEUE. It introduces an interface set_per_queue_coalesce to
set coalesce of each masked queue to device driver. The wanted coalesce
information are stored in "data" for each masked queue, which can copy
from userspace.
If it fails to set coalesce to device driver, the value which already
set to specific queue will be tried to rollback.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/ethtool.h |  8 +++++++
 net/core/ethtool.c      | 60 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index a83566f..0c699b8 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -208,6 +208,12 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  *	zero should return. But related unavailable fields should be set to ~0,
  *	which indicates RX or TX is not in the range.
  *	Returns a negative error code or zero.
+ * @set_per_queue_coalesce: Set interrupt coalescing parameters per queue.
+ *	It needs to do range check for the input queue number. Only if
+ *	neither RX nor TX queue number is in the range, a negative error code
+ *	returns. For the case that only RX or only TX is not in the range,
+ *	zero should return. The related unavailable fields should be avoid.
+ *	Returns a negative error code or zero.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -288,6 +294,8 @@ struct ethtool_ops {
 			       const struct ethtool_tunable *, const void *);
 	int	(*get_per_queue_coalesce)(struct net_device *, int,
 					  struct ethtool_coalesce *);
+	int	(*set_per_queue_coalesce)(struct net_device *, int,
+					  struct ethtool_coalesce *);
 
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index ccefbf5..933de09 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1854,6 +1854,64 @@ static int ethtool_get_per_queue_coalesce(struct net_device *dev,
 	return 0;
 }
 
+static int ethtool_set_per_queue_coalesce(struct net_device *dev,
+					  void __user *useraddr,
+					  struct ethtool_per_queue_op *per_queue_opt)
+{
+	int bit, i, ret = 0;
+	int queue_num;
+	struct ethtool_coalesce *backup = NULL, *tmp = NULL;
+	DECLARE_BITMAP(queue_mask, MAX_NUM_QUEUE);
+
+	if ((!dev->ethtool_ops->set_per_queue_coalesce) ||
+	    (!dev->ethtool_ops->get_per_queue_coalesce))
+		return -EOPNOTSUPP;
+
+	useraddr += sizeof(*per_queue_opt);
+
+	bitmap_from_u32array(queue_mask,
+			     MAX_NUM_QUEUE,
+			     per_queue_opt->queue_mask,
+			     DIV_ROUND_UP(MAX_NUM_QUEUE, 32));
+	queue_num = bitmap_weight(queue_mask, MAX_NUM_QUEUE);
+	tmp = backup = kmalloc_array(queue_num, sizeof(*backup), GFP_KERNEL);
+	if (!backup)
+		return -ENOMEM;
+
+	for_each_set_bit(bit, queue_mask, MAX_NUM_QUEUE) {
+		struct ethtool_coalesce coalesce;
+
+		ret = dev->ethtool_ops->get_per_queue_coalesce(dev, bit, tmp);
+		if (ret != 0)
+			goto roll_back;
+
+		tmp += sizeof(struct ethtool_coalesce);
+
+		if (copy_from_user(&coalesce, useraddr, sizeof(coalesce))) {
+			ret = -EFAULT;
+			goto roll_back;
+		}
+
+		ret = dev->ethtool_ops->set_per_queue_coalesce(dev, bit, &coalesce);
+		if (ret != 0)
+			goto roll_back;
+
+		useraddr += sizeof(coalesce);
+	}
+
+roll_back:
+	if (ret != 0) {
+		tmp = backup;
+		for_each_set_bit(i, queue_mask, bit) {
+			dev->ethtool_ops->set_per_queue_coalesce(dev, i, tmp);
+			tmp += sizeof(struct ethtool_coalesce);
+		}
+	}
+	kfree(backup);
+
+	return ret;
+}
+
 static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_per_queue_op per_queue_opt;
@@ -1864,6 +1922,8 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 	switch (per_queue_opt.sub_command) {
 	case ETHTOOL_GCOALESCE:
 		return ethtool_get_per_queue_coalesce(dev, useraddr, &per_queue_opt);
+	case ETHTOOL_SCOALESCE:
+		return ethtool_set_per_queue_coalesce(dev, useraddr, &per_queue_opt);
 	default:
 		return -EOPNOTSUPP;
 	};
-- 
1.8.3.1
