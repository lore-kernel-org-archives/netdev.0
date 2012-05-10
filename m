From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 6/8] ethtool: Extend the ethtool API to obtain
 plugin module eeprom data
Date: Thu, 10 May 2012 03:31:36 +0100
Message-ID: <1336617096.2499.39.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51908 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753809Ab2EJCbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:31:40 -0400
In-Reply-To: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stuart Hodgson <smhodgson@solarflare.com>

ETHTOOL_GMODULEINFO returns a new struct ethtool_modinfo that will return the
type and size of plug-in module eeprom (such as SFP+) for parsing
by userland program.

ETHTOOL_GMODULEEEPROM returns the raw eeprom information
using the existing ethtool_eeprom structture to return the data

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |   33 +++++++++++++++++++++++++++++++++
 net/core/ethtool.c      |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 89d68d8..4787254 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -137,6 +137,23 @@ struct ethtool_eeprom {
 };
 
 /**
+ * struct ethtool_modinfo - plugin module eeprom information
+ * @cmd: %ETHTOOL_GMODULEINFO
+ * @type: Standard the module information conforms to %ETH_MODULE_SFF_xxxx
+ * @eeprom_len: Length of the eeprom
+ *
+ * This structure is used to return the information to
+ * properly size memory for a subsequent call to %ETHTOOL_GMODULEEEPROM.
+ * The type code indicates the eeprom data format
+ */
+struct ethtool_modinfo {
+	__u32   cmd;
+	__u32   type;
+	__u32   eeprom_len;
+	__u32   reserved[8];
+};
+
+/**
  * struct ethtool_coalesce - coalescing parameters for IRQs and stats updates
  * @cmd: ETHTOOL_{G,S}COALESCE
  * @rx_coalesce_usecs: How many usecs to delay an RX interrupt after
@@ -920,6 +937,9 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @get_ts_info: Get the time stamping and PTP hardware clock capabilities.
  *	Drivers supporting transmit time stamps in software should set this to
  *	ethtool_op_get_ts_info().
+ * @get_module_info: Get the size and type of the eeprom contained within
+ *	a plug-in module.
+ * @get_module_eeprom: Get the eeprom information from the plug-in module
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -982,6 +1002,11 @@ struct ethtool_ops {
 				 struct ethtool_dump *, void *);
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
 	int	(*get_ts_info)(struct net_device *, struct ethtool_ts_info *);
+	int     (*get_module_info)(struct net_device *,
+				   struct ethtool_modinfo *);
+	int     (*get_module_eeprom)(struct net_device *,
+				     struct ethtool_eeprom *, u8 *);
+
 
 };
 #endif /* __KERNEL__ */
@@ -1057,6 +1082,8 @@ struct ethtool_ops {
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
 #define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
+#define ETHTOOL_GMODULEINFO	0x00000042 /* Get plug-in module information */
+#define ETHTOOL_GMODULEEEPROM	0x00000043 /* Get plug-in module eeprom */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1206,6 +1233,12 @@ struct ethtool_ops {
 #define RX_CLS_LOC_FIRST	0xfffffffe
 #define RX_CLS_LOC_LAST		0xfffffffd
 
+/* EEPROM Standards for plug in modules */
+#define ETH_MODULE_SFF_8079		0x1
+#define ETH_MODULE_SFF_8079_LEN		256
+#define ETH_MODULE_SFF_8472		0x2
+#define ETH_MODULE_SFF_8472_LEN		512
+
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
  * were actually reset.  On successful return, the flags indicate the
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index ca7698f..9c2afb4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1335,6 +1335,47 @@ static int ethtool_get_ts_info(struct net_device *dev, void __user *useraddr)
 	return err;
 }
 
+static int ethtool_get_module_info(struct net_device *dev,
+				   void __user *useraddr)
+{
+	int ret;
+	struct ethtool_modinfo modinfo;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
+	if (!ops->get_module_info)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&modinfo, useraddr, sizeof(modinfo)))
+		return -EFAULT;
+
+	ret = ops->get_module_info(dev, &modinfo);
+	if (ret)
+		return ret;
+
+	if (copy_to_user(useraddr, &modinfo, sizeof(modinfo)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int ethtool_get_module_eeprom(struct net_device *dev,
+				     void __user *useraddr)
+{
+	int ret;
+	struct ethtool_modinfo modinfo;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
+	if (!ops->get_module_info || !ops->get_module_eeprom)
+		return -EOPNOTSUPP;
+
+	ret = ops->get_module_info(dev, &modinfo);
+	if (ret)
+		return ret;
+
+	return ethtool_get_any_eeprom(dev, useraddr, ops->get_module_eeprom,
+				      modinfo.eeprom_len);
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1559,6 +1600,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_TS_INFO:
 		rc = ethtool_get_ts_info(dev, useraddr);
 		break;
+	case ETHTOOL_GMODULEINFO:
+		rc = ethtool_get_module_info(dev, useraddr);
+		break;
+	case ETHTOOL_GMODULEEEPROM:
+		rc = ethtool_get_module_eeprom(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
