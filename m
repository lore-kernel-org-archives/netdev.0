From: Kan Liang <kan.liang@intel.com>
Subject: [PATCH V4 3/8] net/ethtool: introduce a new ioctl for per queue setting
Date: Mon,  8 Feb 2016 02:45:35 -0500
Message-ID: <1454917540-10648-4-git-send-email-kan.liang@intel.com>
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
	id S1754409AbcBHPFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 10:05:34 -0500
In-Reply-To: <1454917540-10648-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Introduce a new ioctl ETHTOOL_PERQUEUE for per queue parameters setting.
The following patches will enable some SUB_COMMANDs for per queue
setting.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/uapi/linux/ethtool.h | 17 +++++++++++++++++
 net/core/ethtool.c           | 27 +++++++++++++++++++++++++--
 2 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index b2e1801..c0b5aaa 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1146,6 +1146,21 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
 #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
 
+#define MAX_NUM_QUEUE		4096
+
+/**
+ * struct ethtool_per_queue_op - apply sub command to the queues in mask.
+ * @cmd: ETHTOOL_PERQUEUE
+ * @sub_command: the sub command which apply to each queues
+ * @queue_mask: Bitmap of the queues which sub command apply to
+ * @data: A complete command structure following for each of the queues addressed
+ */
+struct ethtool_per_queue_op {
+	__u32	cmd;
+	__u32	sub_command;
+	__u32	queue_mask[DIV_ROUND_UP(MAX_NUM_QUEUE, 32)];
+	char	data[];
+};
 
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
@@ -1229,6 +1244,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
 #define ETHTOOL_GPHYSTATS	0x0000004a /* get PHY-specific statistics */
 
+#define ETHTOOL_PERQUEUE	0x0000004b /* Set per queue options */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 453c803..d0f7146 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1823,13 +1823,27 @@ out:
 	return ret;
 }
 
+static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_per_queue_op per_queue_opt;
+
+	if (copy_from_user(&per_queue_opt, useraddr, sizeof(per_queue_opt)))
+		return -EFAULT;
+
+	switch (per_queue_opt.sub_command) {
+
+	default:
+		return -EOPNOTSUPP;
+	};
+}
+
 /* The main entry point in this file.  Called from net/core/dev_ioctl.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
 {
 	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
 	void __user *useraddr = ifr->ifr_data;
-	u32 ethcmd;
+	u32 ethcmd, sub_cmd;
 	int rc;
 	netdev_features_t old_features;
 
@@ -1839,8 +1853,14 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
 		return -EFAULT;
 
+	if (ethcmd == ETHTOOL_PERQUEUE) {
+		if (copy_from_user(&sub_cmd, useraddr + sizeof(ethcmd), sizeof(sub_cmd)))
+			return -EFAULT;
+	} else {
+		sub_cmd = ethcmd;
+	}
 	/* Allow some commands to be done by anyone */
-	switch (ethcmd) {
+	switch (sub_cmd) {
 	case ETHTOOL_GSET:
 	case ETHTOOL_GDRVINFO:
 	case ETHTOOL_GMSGLVL:
@@ -2070,6 +2090,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GPHYSTATS:
 		rc = ethtool_get_phy_stats(dev, useraddr);
 		break;
+	case ETHTOOL_PERQUEUE:
+		rc = ethtool_set_per_queue(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.8.3.1
