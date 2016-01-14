From: kan.liang@intel.com
Subject: [PATCH V3 3/6] net/ethtool: support set coalesce per queue
Date: Thu, 14 Jan 2016 09:08:04 -0500
Message-ID: <1452780487-10581-3-git-send-email-kan.liang@intel.com>
References: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, ben@decadent.org.uk,
	Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31404 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756559AbcANV1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2016 16:27:02 -0500
In-Reply-To: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
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

Changes since V1:
 - Use bitmap functions to parse queue mask
 - Improve comments
 - Add rollback support

No changes since V2

 include/linux/ethtool.h |  8 +++++++
 net/core/ethtool.c      | 59 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index bd01feb..e68f950 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -208,6 +208,12 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  *	zero should return. But related unavailable fields should be set to ~0,
  *	which indicates RX or TX is not in the range.
  * 	Returns a negative error code or zero.
+ * @set_per_queue_coalesce: Set interrupt coalescing parameters per queue.
+ * 	It needs to do range check for the input queue number. Only if
+ * 	neither RX nor TX queue number is in the range, a negative error code
+ * 	returns. For the case that only RX or only TX is not in the range,
+ * 	zero should return. The related unavailable fields should be avoid.
+ * 	Returns a negative error code or zero.
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
index 572c103..d0e6d29 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1773,6 +1773,63 @@ static int ethtool_get_per_queue_coalesce(struct net_device *dev,
 	return 0;
 }
 
+static int ethtool_set_per_queue_coalesce(struct net_device *dev,
+					  void __user *useraddr,
+					  struct ethtool_per_queue_op *per_queue_opt)
+{
+	int bit, i, ret = 0;
+	int queue_num = bitmap_weight(per_queue_opt->queue_mask, MAX_NUM_QUEUE);
+	struct ethtool_coalesce *backup = NULL, *tmp = NULL;
+	bool rollback = true;
+
+	if (!dev->ethtool_ops->set_per_queue_coalesce)
+		return -EOPNOTSUPP;
+
+	if (!dev->ethtool_ops->get_per_queue_coalesce)
+		rollback = false;
+
+	useraddr += sizeof(*per_queue_opt);
+
+	if (rollback)
+		tmp = backup = kmalloc(queue_num * sizeof(*backup), GFP_KERNEL);
+
+	for_each_set_bit(bit, per_queue_opt->queue_mask, MAX_NUM_QUEUE) {
+		struct ethtool_coalesce coalesce;
+
+		if (rollback) {
+			if (dev->ethtool_ops->get_per_queue_coalesce(dev, bit, tmp)) {
+				ret = -EFAULT;
+				goto roll_back;
+			}
+			tmp += sizeof(struct ethtool_coalesce);
+		}
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
+	if (rollback) {
+		if (ret != 0) {
+			tmp = backup;
+			for_each_set_bit(i, per_queue_opt->queue_mask, bit - 1) {
+				dev->ethtool_ops->set_per_queue_coalesce(dev, i, tmp);
+				tmp += sizeof(struct ethtool_coalesce);
+			}
+		}
+		kfree(backup);
+	}
+	return ret;
+}
+
 static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_per_queue_op per_queue_opt;
@@ -1783,6 +1840,8 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
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
