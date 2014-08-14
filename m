From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v3 2/3] ethtool: Add generic options for tunables
Date: Thu, 14 Aug 2014 14:59:19 +0530
Message-ID: <1408008560-1067-3-git-send-email-_govind@gmx.com>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com>
Cc: ben@decadent.org.uk, stephen@networkplumber.org, ssujith@cisco.com,
	benve@cisco.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:62979 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbaHNJaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 05:30:16 -0400
In-Reply-To: <1408008560-1067-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new ethtool cmd, ETHTOOL_GTUNABLE & ETHTOOL_STUNABLE for getting
tunable values from driver.

Add ethtool_tunable_ops array to ethtool_ops. The array index will be
the tunable tcmd as defined in enum tunable_cmd. ethtool_tunable_ops has two
function pointers set & get. This is set by the driver for getting/setting
particular tunable.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 include/linux/ethtool.h      |  6 ++++++
 include/uapi/linux/ethtool.h | 17 +++++++++++++++
 net/core/ethtool.c           | 51 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index e658229..33bff94 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -77,6 +77,11 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
 	return index % n_rx_rings;
 }
 
+struct ethtool_tunable_ops {
+	int (*set)(struct net_device *, struct ethtool_tunable *);
+	int (*get)(struct net_device *, struct ethtool_tunable *);
+};
+
 /**
  * struct ethtool_ops - optional netdev operations
  * @get_settings: Get various device settings including Ethernet link
@@ -257,6 +262,7 @@ struct ethtool_ops {
 				     struct ethtool_eeprom *, u8 *);
 	int	(*get_eee)(struct net_device *, struct ethtool_eee *);
 	int	(*set_eee)(struct net_device *, struct ethtool_eee *);
+	struct ethtool_tunable_ops tunable_ops[ETHTOOL_TUNABLE_MAX];
 
 
 };
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index e3c7a71..99e43ca 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -209,6 +209,21 @@ struct ethtool_value {
 	__u32	data;
 };
 
+enum tunable_cmd {
+	ETHTOOL_RX_COPYBREAK = 0,
+	ETHTOOL_TUNABLE_MAX,
+};
+
+struct ethtool_tunable {
+	u32 cmd;
+	u32 tcmd;
+	u32 len;
+	union {
+		u32 rx_copybreak;
+		u32 data[48];
+	} data;
+};
+
 /**
  * struct ethtool_regs - hardware register dump
  * @cmd: Command number = %ETHTOOL_GREGS
@@ -1152,6 +1167,8 @@ enum ethtool_sfeatures_retval_bits {
 
 #define ETHTOOL_GRSSH		0x00000046 /* Get RX flow hash configuration */
 #define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
+#define ETHTOOL_GTUNABLE	0x00000048 /* Get Tunable  */
+#define ETHTOOL_STUNABLE	0x00000049 /* Set Tunable */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 17cb912..0574c66 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1621,6 +1621,50 @@ static int ethtool_get_module_eeprom(struct net_device *dev,
 				      modinfo.eeprom_len);
 }
 
+static int ethtool_get_tunable(struct net_device *dev, void __user *useraddr)
+{
+	int ret;
+	struct ethtool_tunable tuna;
+	const struct ethtool_tunable_ops *ops;
+
+	if (copy_from_user(&tuna, useraddr, sizeof(tuna)))
+		return -EFAULT;
+	if (tuna.tcmd >= ETHTOOL_TUNABLE_MAX)
+		return -EOPNOTSUPP;
+	ops = &dev->ethtool_ops->tunable_ops[tuna.tcmd];
+	if (!ops->get)
+		return -EOPNOTSUPP;
+	ret = ops->get(dev, &tuna);
+	if (ret)
+		return ret;
+	if (copy_to_user(useraddr, &tuna, sizeof(tuna)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int ethtool_set_tunable(struct net_device *dev, void __user *useraddr)
+{
+	int ret;
+	struct ethtool_tunable tuna;
+	const struct ethtool_tunable_ops *ops;
+
+	if (copy_from_user(&tuna, useraddr, sizeof(tuna)))
+		return -EFAULT;
+	if (tuna.tcmd >= ETHTOOL_TUNABLE_MAX)
+		return -EOPNOTSUPP;
+	ops = &dev->ethtool_ops->tunable_ops[tuna.tcmd];
+	if (!ops->set)
+		return -EOPNOTSUPP;
+	ret = ops->set(dev, &tuna);
+	if (ret)
+		return ret;
+	if (copy_to_user(useraddr, &tuna, sizeof(tuna)))
+		return -EFAULT;
+
+	return 0;
+}
+
 /* The main entry point in this file.  Called from net/core/dev_ioctl.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1670,6 +1714,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GCHANNELS:
 	case ETHTOOL_GET_TS_INFO:
 	case ETHTOOL_GEEE:
+	case ETHTOOL_GTUNABLE:
 		break;
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -1857,6 +1902,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GMODULEEEPROM:
 		rc = ethtool_get_module_eeprom(dev, useraddr);
 		break;
+	case ETHTOOL_GTUNABLE:
+		rc = ethtool_get_tunable(dev, useraddr);
+		break;
+	case ETHTOOL_STUNABLE:
+		rc = ethtool_set_tunable(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
2.0.4
