From: kan.liang@intel.com
Subject: [PATCH V3 2/6] net/ethtool: support get coalesce per queue
Date: Thu, 14 Jan 2016 09:08:03 -0500
Message-ID: <1452780487-10581-2-git-send-email-kan.liang@intel.com>
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
Received: from mga11.intel.com ([192.55.52.93]:56595 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756558AbcANV1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2016 16:27:02 -0500
In-Reply-To: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch implements sub command ETHTOOL_GCOALESCE for ioctl
ETHTOOL_PERQUEUE. It introduces an interface get_per_queue_coalesce to
get coalesce of each masked queue from device driver. Then the interrupt
coalescing parameters will be copied back to user space one by one.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---

Changes since V1:
 - Use bitmap functions to parse queue mask
 - Improve comments

No changes since V2

 include/linux/ethtool.h | 10 +++++++++-
 net/core/ethtool.c      | 34 ++++++++++++++++++++++++++++++++--
 2 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 653dc9c..bd01feb 100644
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
+ * 	Returns a negative error code or zero.
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
index ac45597..572c103 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1748,6 +1748,31 @@ out:
 	return ret;
 }
 
+static int ethtool_get_per_queue_coalesce(struct net_device *dev,
+					  void __user *useraddr,
+					  struct ethtool_per_queue_op *per_queue_opt)
+{
+	int bit, ret;
+
+	if (!dev->ethtool_ops->get_per_queue_coalesce)
+		return -EOPNOTSUPP;
+
+	useraddr += sizeof(*per_queue_opt);
+
+	for_each_set_bit(bit, per_queue_opt->queue_mask, MAX_NUM_QUEUE) {
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
@@ -1756,7 +1781,8 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	switch (per_queue_opt.sub_command) {
-
+	case ETHTOOL_GCOALESCE:
+		return ethtool_get_per_queue_coalesce(dev, useraddr, &per_queue_opt);
 	default:
 		return -EOPNOTSUPP;
 	};
@@ -1768,7 +1794,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 {
 	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
 	void __user *useraddr = ifr->ifr_data;
-	u32 ethcmd;
+	u32 ethcmd, sub_cmd;
 	int rc;
 	netdev_features_t old_features;
 
@@ -1814,6 +1840,10 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GTUNABLE:
 		break;
 	case ETHTOOL_PERQUEUE:
+		if (copy_from_user(&sub_cmd, useraddr + sizeof(ethcmd), sizeof(sub_cmd)))
+			return -EFAULT;
+		if (sub_cmd == ETHTOOL_GCOALESCE)
+			break;
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
-- 
1.8.3.1
