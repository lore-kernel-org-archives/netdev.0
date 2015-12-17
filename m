From: kan.liang@intel.com
Subject: [RFC 2/5] net/ethtool: support get coalesce per queue
Date: Thu, 17 Dec 2015 06:51:18 +0000
Message-ID: <1450335081-3012-2-git-send-email-kan.liang@intel.com>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
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
Received: from mga03.intel.com ([134.134.136.65]:54437 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752115AbbLQSdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 13:33:02 -0500
In-Reply-To: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Device driver has to provide an interface to get per queue coalesce.
The interrupt coalescing parameters of each masked queue will be
copied back to user space one by one.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/ethtool.h |  5 ++++-
 net/core/ethtool.c      | 33 ++++++++++++++++++++++++++++++++-
 2 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 653dc9c..107f75f 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -201,6 +201,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @get_module_eeprom: Get the eeprom information from the plug-in module
  * @get_eee: Get Energy-Efficient (EEE) supported and status.
  * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
+ * @get_per_queue_coalesce: Get interrupt coalescing parameters per queue.
+ * 	Returns a negative error code or zero.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -279,7 +281,8 @@ struct ethtool_ops {
 			       const struct ethtool_tunable *, void *);
 	int	(*set_tunable)(struct net_device *,
 			       const struct ethtool_tunable *, const void *);
-
+	int	(*get_per_queue_coalesce)(struct net_device *, int,
+					  struct ethtool_coalesce *);
 
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 125fb32..22ff69a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1748,6 +1748,36 @@ out:
 	return ret;
 }
 
+static int ethtool_get_per_queue_coalesce(struct net_device *dev,
+					  void __user *useraddr,
+					  struct ethtool_per_queue_op *per_queue_opt)
+{
+	u64 queue_mask;
+	int bit, i, ret;
+
+	if (!dev->ethtool_ops->get_per_queue_coalesce)
+		return -EOPNOTSUPP;
+
+	useraddr += sizeof(*per_queue_opt);
+	for (i = 0; i < MAX_QUEUE_MASK; i++) {
+		queue_mask = per_queue_opt->queue_mask[i];
+		if (queue_mask > 0) {
+			for_each_set_bit(bit, (unsigned long *)&queue_mask, 64) {
+				struct ethtool_coalesce coalesce = { .cmd = ETHTOOL_GCOALESCE };
+
+				ret = dev->ethtool_ops->get_per_queue_coalesce(dev, bit + i * 64, &coalesce);
+				if (ret != 0)
+					return ret;
+				if (copy_to_user(useraddr, &coalesce, sizeof(coalesce)))
+					return -EFAULT;
+				useraddr += sizeof(coalesce);
+			}
+		}
+	}
+
+	return 0;
+}
+
 static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_per_queue_op per_queue_opt;
@@ -1756,7 +1786,8 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	switch (per_queue_opt.sub_command) {
-
+	case ETHTOOL_GCOALESCE:
+		return ethtool_get_per_queue_coalesce(dev, useraddr, &per_queue_opt);
 	default:
 		return -EOPNOTSUPP;
 	};
-- 
1.7.11.7
