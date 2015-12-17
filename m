From: kan.liang@intel.com
Subject: [RFC 3/5] net/ethtool: support set coalesce per queue
Date: Thu, 17 Dec 2015 06:51:19 +0000
Message-ID: <1450335081-3012-3-git-send-email-kan.liang@intel.com>
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
Received: from mga03.intel.com ([134.134.136.65]:1700 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751385AbbLQSdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 13:33:03 -0500
In-Reply-To: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Device driver has to provide an interface to set per queue coalesce. The
wanted coalesce information are stored in "data" for each masked queue,
which can copy from userspace.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/ethtool.h |  4 ++++
 net/core/ethtool.c      | 33 +++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 107f75f..b3bbbcb 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -203,6 +203,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
  * @get_per_queue_coalesce: Get interrupt coalescing parameters per queue.
  * 	Returns a negative error code or zero.
+ * @set_per_queue_coalesce: Set interrupt coalescing parameters per queue.
+ * 	Returns a negative error code or zero.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -283,6 +285,8 @@ struct ethtool_ops {
 			       const struct ethtool_tunable *, const void *);
 	int	(*get_per_queue_coalesce)(struct net_device *, int,
 					  struct ethtool_coalesce *);
+	int	(*set_per_queue_coalesce)(struct net_device *, int,
+					  struct ethtool_coalesce *);
 
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 22ff69a..c8c5726 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1778,6 +1778,37 @@ static int ethtool_get_per_queue_coalesce(struct net_device *dev,
 	return 0;
 }
 
+static int ethtool_set_per_queue_coalesce(struct net_device *dev,
+					  void __user *useraddr,
+					  struct ethtool_per_queue_op *per_queue_opt)
+{
+	u64 queue_mask;
+	int bit, i, ret;
+
+	if (!dev->ethtool_ops->set_per_queue_coalesce)
+		return -EOPNOTSUPP;
+
+	useraddr += sizeof(*per_queue_opt);
+	for (i = 0; i < MAX_QUEUE_MASK; i++) {
+		queue_mask = per_queue_opt->queue_mask[i];
+		if (queue_mask > 0) {
+			for_each_set_bit(bit, (unsigned long *)&queue_mask, 64) {
+				struct ethtool_coalesce coalesce;
+
+				if (copy_from_user(&coalesce, useraddr, sizeof(coalesce)))
+					return -EFAULT;
+
+				ret = dev->ethtool_ops->set_per_queue_coalesce(dev, bit + i * 64, &coalesce);
+				if (ret != 0)
+					return ret;
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
@@ -1788,6 +1819,8 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 	switch (per_queue_opt.sub_command) {
 	case ETHTOOL_GCOALESCE:
 		return ethtool_get_per_queue_coalesce(dev, useraddr, &per_queue_opt);
+	case ETHTOOL_SCOALESCE:
+		return ethtool_set_per_queue_coalesce(dev, useraddr, &per_queue_opt);
 	default:
 		return -EOPNOTSUPP;
 	};
-- 
1.7.11.7
