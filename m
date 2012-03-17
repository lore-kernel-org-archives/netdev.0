From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 2/8] ethtool: Introduce a method for getting time stamping capabilities.
Date: Sat, 17 Mar 2012 13:12:28 +0100
Message-ID: <ce96bacb7b99ebace235794ab7bd7dfabeab7f7d.1331983687.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43430 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030798Ab2CQMMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 08:12:48 -0400
Received: by wejx9 with SMTP id x9so4653078wej.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 05:12:47 -0700 (PDT)
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds a new ethtool ioctl that exposes the SO_TIMESTAMPING
capabilities of a network interface. In addition, user space programs
can use this ioctl to discover the PTP Hardware Clock (PHC) device
associated with the interface.

Since software receive time stamps are handled by the stack, the generic
ethtool code can answer the query correctly in case the MAC or PHY
drivers lack special time stamping features.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 include/linux/ethtool.h |   20 ++++++++++++++++++++
 include/linux/phy.h     |    3 +++
 net/core/ethtool.c      |   36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index e1d9e0e..72ffda9 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -726,6 +726,24 @@ struct ethtool_sfeatures {
 	struct ethtool_set_features_block features[0];
 };
 
+/**
+ * struct ethtool_ts_info - holds a device's timestamping and PHC association
+ * @cmd: command number = %ETHTOOL_GET_TS_INFO
+ * @so_timestamping: bit mask of SO_TIMESTAMPING modes supported by the device
+ * @phc_index: device index of the associated PHC, or -1 if there is none
+ * @tx_types: bit mask of hwtstamp_tx_types modes supported by the device
+ * @rx_filters: bit mask of hwtstamp_rx_filters modes supported by the device
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
@@ -955,6 +973,7 @@ struct ethtool_ops {
 	int	(*get_dump_data)(struct net_device *,
 				 struct ethtool_dump *, void *);
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
+	int	(*get_ts_info)(struct net_device *, struct ethtool_ts_info *);
 
 };
 #endif /* __KERNEL__ */
@@ -1029,6 +1048,7 @@ struct ethtool_ops {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/include/linux/phy.h b/include/linux/phy.h
index c599f7ec..497b5c0 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -411,6 +411,9 @@ struct phy_driver {
 	/* Clears up any memory if needed */
 	void (*remove)(struct phy_device *phydev);
 
+	/* Handles ethtool queries for hardware time stamping. */
+	int (*ts_info)(struct phy_device *phydev, struct ethtool_ts_info *ti);
+
 	/* Handles SIOCSHWTSTAMP ioctl for hardware time stamping. */
 	int  (*hwtstamp)(struct phy_device *phydev, struct ifreq *ifr);
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6d6d7d2..d6eff4b 100644
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
@@ -1278,6 +1280,37 @@ out:
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
+	if (phydev && phydev->drv && phydev->drv->ts_info)
+		err = phydev->drv->ts_info(phydev, &info);
+
+	else if (dev->ethtool_ops->get_ts_info)
+		err = ops->get_ts_info(dev, &info);
+	else {
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
@@ -1496,6 +1529,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
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
