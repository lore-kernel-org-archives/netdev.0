From: Carolyn Wyborny <carolyn.wyborny@intel.com>
Subject: [RFC 2/2] ethtool: Add support for DMA Coalescing feature config to ethtool.
Date: Tue, 14 Jun 2011 10:13:26 -0700
Message-ID: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
To: netdev@vger.kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15073 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214Ab1FNRLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 13:11:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This RFC patch adds functions to get and set DMA Coalescing feature
configuration.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
---
 include/linux/ethtool.h |   15 ++++++++++++++-
 net/core/ethtool.c      |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c6a850a..efed754 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -703,6 +703,14 @@ enum ethtool_sfeatures_retval_bits {
 	ETHTOOL_F_COMPAT__BIT,
 };
 
+/* for configuring DMA coalescing parameters of chip */
+struct ethtool_dmac {
+	__u32	cmd;	/* ETHTOOL_{G,S}DMAC */
+
+	/* tune setting, options and validation determined by device. */
+	__u32	tune;
+};
+
 #define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
 #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
@@ -877,6 +885,8 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
  * 		   and flag of the device.
  * @get_dump_data: Get dump data.
  * @set_dump: Set dump specific flags to the device.
+ * @get_dmac: Get DMA Coalescing setting from device.
+ * @set_dmac: Set DMA Coalescing setting.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -955,7 +965,8 @@ struct ethtool_ops {
 	int	(*get_dump_data)(struct net_device *,
 				 struct ethtool_dump *, void *);
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
-
+	void	(*get_dmac)(struct net_device *, struct ethtool_dmac *);
+	int	(*set_dmac)(struct net_device *, struct ethtool_dmac *);
 };
 #endif /* __KERNEL__ */
 
@@ -1029,6 +1040,8 @@ struct ethtool_ops {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GDMAC		0X00000041 /* Get DMA Coalsce settings */
+#define ETHTOOL_SDMAC		0X00000042 /* Set DMA Coalsce settings */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index fd14116..0f122d3 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1926,6 +1926,32 @@ out:
 	vfree(data);
 	return ret;
 }
+static int ethtool_set_dmac(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_dmac dmac;
+
+	if (!dev->ethtool_ops->set_dmac)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&dmac, useraddr, sizeof(dmac)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_dmac(dev, &dmac);
+}
+
+static int ethtool_get_dmac(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_dmac dmac = { .cmd = ETHTOOL_GDMAC };
+
+	if (!dev->ethtool_ops->get_dmac)
+		return -EOPNOTSUPP;
+
+	dev->ethtool_ops->get_dmac(dev, &dmac);
+
+	if (copy_to_user(useraddr, &dmac, sizeof(dmac)))
+		return -EFAULT;
+	return 0;
+}
 
 /* The main entry point in this file.  Called from net/core/dev.c */
 
@@ -2152,6 +2178,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_DUMP_DATA:
 		rc = ethtool_get_dump_data(dev, useraddr);
 		break;
+	case ETHTOOL_GDMAC:
+		rc = ethtool_get_dmac(dev, useraddr);
+		break;
+	case ETHTOOL_SDMAC:
+		rc = ethtool_set_dmac(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.4.4

