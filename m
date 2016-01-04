From: kan.liang@intel.com
Subject: [PATCH V2 1/5] net/ethtool: introduce a new ioctl for per queue setting
Date: Mon,  4 Jan 2016 07:53:57 -0500
Message-ID: <1451912041-8860-1-git-send-email-kan.liang@intel.com>
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
Received: from mga02.intel.com ([134.134.136.20]:53172 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682AbcADUM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 15:12:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Introduce a new ioctl ETHTOOL_PERQUEUE for per queue parameters setting.
The following patches will enable some SUB_COMMANDs for per queue
setting.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---

Changes since V1:
 - Checking the sub-command number to determine whether the command
   requires CAP_NET_ADMIN
 - Refine the struct ethtool_per_queue_op and improve the comments

 include/uapi/linux/ethtool.h | 17 +++++++++++++++++
 net/core/ethtool.c           | 18 ++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index cd16291..1913d37 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1144,6 +1144,21 @@ enum ethtool_sfeatures_retval_bits {
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
+	unsigned long queue_mask[BITS_TO_LONGS(MAX_NUM_QUEUE)];
+	char	data[];
+};
 
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
@@ -1226,6 +1241,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
 
+#define ETHTOOL_PERQUEUE	0x0000004a /* Set per queue options */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 09948a7..ac45597 100644
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
@@ -1799,6 +1813,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GEEE:
 	case ETHTOOL_GTUNABLE:
 		break;
+	case ETHTOOL_PERQUEUE:
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
@@ -1991,6 +2006,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
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
1.8.3.1
