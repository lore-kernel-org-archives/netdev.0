From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 02/28] ethtool: Introduce a method
	for getting time stamping capabilities.
Date: Tue,  3 Apr 2012 19:47:26 +0200
Message-ID: <40ae199e9b653f8f2bff0a606e11d90b6806a4e5.1333474522.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This commit adds a new ethtool ioctl that exposes the SO_TIMESTAMPING
capabilities of a network interface. In addition, user space programs
can use this ioctl to discover the PTP Hardware Clock (PHC) device
associated with the interface.

Since software receive time stamps are handled by the stack, the generic
ethtool code can answer the query correctly in case the MAC or PHY
drivers lack special time stamping features.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 include/linux/ethtool.h |   28 +++++++++++++++++++++++++++
 include/linux/phy.h     |    3 ++
 net/core/ethtool.c      |   48 ++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 76 insertions(+), 3 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index e1d9e0e..1769714 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -726,6 +726,29 @@ struct ethtool_sfeatures {
 	struct ethtool_set_features_block features[0];
 };
 
+/**
+ * struct ethtool_ts_info - holds a device's timestamping and PHC association
+ * @cmd: command number = %ETHTOOL_GET_TS_INFO
+ * @so_timestamping: bit mask of the sum of the supported SO_TIMESTAMPING flags
+ * @phc_index: device index of the associated PHC, or -1 if there is none
+ * @tx_types: bit mask of the supported hwtstamp_tx_types enumeration values
+ * @rx_filters: bit mask of the supported hwtstamp_rx_filters enumeration values
+ *
+ * The bits in the 'tx_types' and 'rx_filters' fields correspond to
+ * the 'hwtstamp_tx_types' and 'hwtstamp_rx_filters' enumeration values,
+ * respectively.  For example, if the device supports HWTSTAMP_TX_ON,
+ * then (1 << HWTSTAMP_TX_ON) in 'tx_types' will be set.
+ */
+struct ethtool_ts_info {
+	__u32	cmd;
+	__u32	so_timestamping;
+	__s32	phc_index;
+	__u32	tx_types;
+	__u32	tx_reserved[3];
+	__u32	rx_filters;
+	__u32	rx_reserved[3];
+};
+
 /*
  * %ETHTOOL_SFEATURES changes features present in features[].valid to the
  * values of corresponding bits in features[].requested. Bits in .requested
@@ -893,6 +916,9 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * 		   and flag of the device.
  * @get_dump_data: Get dump data.
  * @set_dump: Set dump specific flags to the device.
+ * @get_ts_info: Get the time stamping and PTP hardware clock capabilities.
+ *	Drivers supporting transmit time stamps in software should set this to
+ *	ethtool_op_get_ts_info().
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -955,6 +981,7 @@ struct ethtool_ops {
 	int	(*get_dump_data)(struct net_device *,
 				 struct ethtool_dump *, void *);
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
+	int	(*get_ts_info)(struct net_device *, struct ethtool_ts_info *);
 
 };
 #endif /* __KERNEL__ */
@@ -1029,6 +1056,7 @@ struct ethtool_ops {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 6fe0a37..f092032 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -412,6 +412,9 @@ struct phy_driver {
 	/* Clears up any memory if needed */
 	void (*remove)(struct phy_device *phydev);
 
+	/* Handles ethtool queries for hardware time stamping. */
+	int (*ts_info)(struct phy_device *phydev, struct ethtool_ts_info *ti);
+
 	/* Handles SIOCSHWTSTAMP ioctl for hardware time stamping. */
 	int  (*hwtstamp)(struct phy_device *phydev, struct ifreq *ifr);
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6d6d7d2..a723b13 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -17,6 +17,8 @@
 #include <linux/errno.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
+#include <linux/net_tstamp.h>
+#include <linux/phy.h>
 #include <linux/bitops.h>
 #include <linux/uaccess.h>
 #include <linux/vmalloc.h>
@@ -1278,6 +1280,40 @@ out:
 	return ret;
 }
 
+static int ethtool_get_ts_info(struct net_device *dev, void __user *useraddr)
+{
+	int err = 0;
+	struct ethtool_ts_info info;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct phy_device *phydev = dev->phydev;
+
+	memset(&info, 0, sizeof(info));
+	info.cmd = ETHTOOL_GET_TS_INFO;
+
+	if (phydev && phydev->drv && phydev->drv->ts_info) {
+
+		err = phydev->drv->ts_info(phydev, &info);
+
+	} else if (dev->ethtool_ops && dev->ethtool_ops->get_ts_info) {
+
+		err = ops->get_ts_info(dev, &info);
+
+	} else {
+		info.so_timestamping =
+			SOF_TIMESTAMPING_RX_SOFTWARE |
+			SOF_TIMESTAMPING_SOFTWARE;
+		info.phc_index = -1;
+	}
+
+	if (err)
+		return err;
+
+	if (copy_to_user(useraddr, &info, sizeof(info)))
+		err = -EFAULT;
+
+	return err;
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1295,11 +1331,13 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		return -EFAULT;
 
 	if (!dev->ethtool_ops) {
-		/* ETHTOOL_GDRVINFO does not require any driver support.
-		 * It is also unprivileged and does not change anything,
-		 * so we can take a shortcut to it. */
+		/* A few commands do not require any driver support,
+		 * are unprivileged, and do not change anything, so we
+		 * can take a shortcut to them. */
 		if (ethcmd == ETHTOOL_GDRVINFO)
 			return ethtool_get_drvinfo(dev, useraddr);
+		else if (ethcmd == ETHTOOL_GET_TS_INFO)
+			return ethtool_get_ts_info(dev, useraddr);
 		else
 			return -EOPNOTSUPP;
 	}
@@ -1330,6 +1368,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GRXCLSRULE:
 	case ETHTOOL_GRXCLSRLALL:
 	case ETHTOOL_GFEATURES:
+	case ETHTOOL_GET_TS_INFO:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
@@ -1496,6 +1535,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_DUMP_DATA:
 		rc = ethtool_get_dump_data(dev, useraddr);
 		break;
+	case ETHTOOL_GET_TS_INFO:
+		rc = ethtool_get_ts_info(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.2.5


------------------------------------------------------------------------------
Better than sec? Nothing is better than sec when it comes to
monitoring Big Data applications. Try Boundary one-second 
resolution app monitoring today. Free.
http://p.sf.net/sfu/Boundary-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
