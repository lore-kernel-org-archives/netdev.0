From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC PATCH V2 1/2] net/core/ethtool: New Commands to Configure IOV
	features
Date: Thu, 22 Sep 2011 14:35:22 -0700
Message-ID: <20110922213522.26654.59301.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63625 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939Ab1IVVfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 17:35:25 -0400
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id p8MLZM9Z026684
	for <netdev@vger.kernel.org>; Thu, 22 Sep 2011 14:35:22 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only currently supported method of configuring the number of VFs
is through the max_vfs module parameter.  This method is inadequate to
support scenarios in which the user might wish to have varying numbers
of VFs per PF.  There is additional support for drivers that want to
partition some driver resources to additional net devices and for
configuring the number of Tx/Rx queue pairs per VF.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/ethtool.h |   30 +++++++++++++++++++++++++++++-
 net/core/ethtool.c      |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 45f00b6..448730f 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -720,6 +720,27 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
 #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
 
+enum ethtool_iov_modes {
+	ETHTOOL_IOV_MODE_NONE,
+	ETHTOOL_IOV_MODE_SRIOV,
+	ETHTOOL_IOV_MODE_NETDEVS,
+};
+
+#define	ETHTOOL_IOV_CMD_CONFIGURE_SRIOV		1
+#define	ETHTOOL_IOV_CMD_CONFIGURE_NETDEVS	2
+#define	ETHTOOL_IOV_CMD_CONFIGURE_VF_QUEUES	3
+
+struct ethtool_iov_set_cmd {
+	__u32 cmd;
+	__u32 set_cmd;
+	__u32 cmd_param;
+};
+
+struct ethtool_iov_get_cmd {
+	__u32 cmd;
+	__u32 mode;
+};
+
 #ifdef __KERNEL__
 
 #include <linux/rculist.h>
@@ -879,6 +900,8 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
  * 		   and flag of the device.
  * @get_dump_data: Get dump data.
  * @set_dump: Set dump specific flags to the device.
+ * @iov_set_cmd: Set IOV parameters - number of VFs or VM Queues
+ * @iov_get_cmd: Get current IOV parameters and configuration
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -956,7 +979,10 @@ struct ethtool_ops {
 	int	(*get_dump_data)(struct net_device *,
 				 struct ethtool_dump *, void *);
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
-
+	int	(*iov_set_cmd)(struct net_device *,
+			struct ethtool_iov_set_cmd *);
+	int	(*iov_get_cmd)(struct net_device *,
+			struct ethtool_iov_get_cmd *);
 };
 #endif /* __KERNEL__ */
 
@@ -1030,6 +1056,8 @@ struct ethtool_ops {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_IOV_SET_CMD	0x00000041 /* Set IOV parameters */
+#define ETHTOOL_IOV_GET_CMD	0x00000042 /* Get IOV parameters */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f444817..a469e40 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1633,6 +1633,38 @@ out:
 	return ret;
 }
 
+static int ethtool_iov_set_command(struct net_device *dev,
+				  void __user *useraddr)
+{
+	struct ethtool_iov_set_cmd iov_cmd;
+
+	if (!dev->ethtool_ops->iov_set_cmd)
+		return -EOPNOTSUPP;
+	if (copy_from_user(&iov_cmd, useraddr, sizeof(iov_cmd)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->iov_set_cmd(dev, &iov_cmd);
+}
+
+static int ethtool_iov_get_command(struct net_device *dev,
+				  void __user *useraddr)
+{
+	int ret;
+	struct ethtool_iov_get_cmd iov_cmd;
+
+	if (!dev->ethtool_ops->iov_get_cmd)
+		return -EOPNOTSUPP;
+	if (copy_from_user(&iov_cmd, useraddr, sizeof(iov_cmd)))
+		return -EFAULT;
+
+	ret = dev->ethtool_ops->iov_get_cmd(dev, &iov_cmd);
+	if (!ret)
+		ret = copy_to_user(useraddr, &iov_cmd, sizeof(iov_cmd));
+
+	return ret;
+}
+
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1855,6 +1887,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_DUMP_DATA:
 		rc = ethtool_get_dump_data(dev, useraddr);
 		break;
+	case ETHTOOL_IOV_SET_CMD:
+		rc = ethtool_iov_set_command(dev, useraddr);
+		break;
+	case ETHTOOL_IOV_GET_CMD:
+		rc = ethtool_iov_get_command(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
