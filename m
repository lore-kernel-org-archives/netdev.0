From: Kan Liang <kan.liang@intel.com>
Subject: [PATCH V4 4/8] net/ethtool: support get coalesce per queue
Date: Mon,  8 Feb 2016 02:45:36 -0500
Message-ID: <1454917540-10648-5-git-send-email-kan.liang@intel.com>
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
Received: from mga11.intel.com ([192.55.52.93]:3370 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517AbcBHPFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 10:05:34 -0500
In-Reply-To: <1454917540-10648-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch implements sub command ETHTOOL_GCOALESCE for ioctl
ETHTOOL_PERQUEUE. It introduces an interface get_per_queue_coalesce to
get coalesce of each masked queue from device driver. Then the interrupt
coalescing parameters will be copied back to user space one by one.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/ethtool.h | 10 +++++++++-
 net/core/ethtool.c      | 34 +++++++++++++++++++++++++++++++++-
 2 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 653dc9c..a83566f 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -201,6 +201,13 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @get_module_eeprom: Get the eeprom information from the plug-in module
  * @get_eee: Get Energy-Efficient (EEE) supported and status.
  * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
+ * @get_per_queue_coalesce: Get interrupt coalescing parameters per queue.
+ *	It needs to do range check for the input queue number. Only if
+ *	neither RX nor TX queue number is in the range, a negative error code
+ *	returns. For the case that only RX or only TX is not in the range,
+ *	zero should return. But related unavailable fields should be set to ~0,
+ *	which indicates RX or TX is not in the range.
+ *	Returns a negative error code or zero.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -279,7 +286,8 @@ struct ethtool_ops {
 			       const struct ethtool_tunable *, void *);
 	int	(*set_tunable)(struct net_device *,
 			       const struct ethtool_tunable *, const void *);
-
+	int	(*get_per_queue_coalesce)(struct net_device *, int,
+					  struct ethtool_coalesce *);
 
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d0f7146..ccefbf5 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1823,6 +1823,37 @@ out:
 	return ret;
 }
 
+static int ethtool_get_per_queue_coalesce(struct net_device *dev,
+					  void __user *useraddr,
+					  struct ethtool_per_queue_op *per_queue_opt)
+{
+	int bit, ret;
+	DECLARE_BITMAP(queue_mask, MAX_NUM_QUEUE);
+
+	if (!dev->ethtool_ops->get_per_queue_coalesce)
+		return -EOPNOTSUPP;
+
+	useraddr += sizeof(*per_queue_opt);
+
+	bitmap_from_u32array(queue_mask,
+			     MAX_NUM_QUEUE,
+			     per_queue_opt->queue_mask,
+			     DIV_ROUND_UP(MAX_NUM_QUEUE, 32));
+
+	for_each_set_bit(bit, queue_mask, MAX_NUM_QUEUE) {
+		struct ethtool_coalesce coalesce = { .cmd = ETHTOOL_GCOALESCE };
+
+		ret = dev->ethtool_ops->get_per_queue_coalesce(dev, bit, &coalesce);
+		if (ret != 0)
+			return ret;
+		if (copy_to_user(useraddr, &coalesce, sizeof(coalesce)))
+			return -EFAULT;
+		useraddr += sizeof(coalesce);
+	}
+
+	return 0;
+}
+
 static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_per_queue_op per_queue_opt;
@@ -1831,7 +1862,8 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	switch (per_queue_opt.sub_command) {
-
+	case ETHTOOL_GCOALESCE:
+		return ethtool_get_per_queue_coalesce(dev, useraddr, &per_queue_opt);
 	default:
 		return -EOPNOTSUPP;
 	};
-- 
1.8.3.1
