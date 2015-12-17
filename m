From: kan.liang@intel.com
Subject: [RFC 1/5] net/ethtool: introduce a new ioctl for per queue setting
Date: Thu, 17 Dec 2015 06:51:17 +0000
Message-ID: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
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
Received: from mga03.intel.com ([134.134.136.65]:23649 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751385AbbLQSdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 13:33:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Introduce a new ioctl ETHTOOL_PERQUEUE for per queue parameters setting.
The following patches will enable some SUB_COMMANDs for per queue
setting.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/uapi/linux/ethtool.h | 18 ++++++++++++++++++
 net/core/ethtool.c           | 17 +++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index cd16291..05bc92a 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1144,6 +1144,22 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
 #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
 
+#define MAX_QUEUE		4096
+#define MAX_QUEUE_MASK		(MAX_QUEUE / 64)
+
+/**
+ * struct ethtool_per_queue_op - apply sub command to the queues in mask.
+ * @cmd: ETHTOOL_PERQUEUE
+ * @queue_mask: Mask the queues which sub command apply to
+ * @sub_command: the sub command
+ * @data: parameters of the command
+ */
+struct ethtool_per_queue_op {
+	__u32	cmd;
+	__u64	queue_mask[MAX_QUEUE_MASK];
+	__u32	sub_command;
+	char	data[];
+};
 
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
@@ -1226,6 +1242,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
 
+#define ETHTOOL_PERQUEUE	0x0000004a /* Set per queue options */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 29edf74..125fb32 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1748,6 +1748,20 @@ out:
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
@@ -1991,6 +2005,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_STUNABLE:
 		rc = ethtool_set_tunable(dev, useraddr);
 		break;
+	case ETHTOOL_PERQUEUE:
+		rc = ethtool_set_per_queue(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.11.7
