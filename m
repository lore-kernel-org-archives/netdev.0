From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/4] net: ethtool: add the EEE support
Date: Tue, 28 Feb 2012 13:44:42 +0100
Message-ID: <1330433084-18586-3-git-send-email-peppe.cavallaro@st.com>
References: <1330433084-18586-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:37553 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932299Ab2B1MpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 07:45:11 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 186BBD2
	for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 12:45:08 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C38D92779
	for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 12:45:08 +0000 (GMT)
In-Reply-To: <1330433084-18586-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two new functions to detect if Energy-Efficient
Ethernet (EEE) is supported and the way to enable/disable it.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 include/linux/ethtool.h |    7 +++++++
 net/core/ethtool.c      |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index da5b2de..fdea3c7 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -43,6 +43,7 @@ struct ethtool_cmd {
 	__u8	eth_tp_mdix;
 	__u8	reserved2;
 	__u32	lp_advertising;	/* Features the link partner advertises */
+	__u32	eee;		/* Energy-Efficient Etehrnet */
 	__u32	reserved[2];
 };
 
@@ -874,6 +875,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * 		   and flag of the device.
  * @get_dump_data: Get dump data.
  * @set_dump: Set dump specific flags to the device.
+ * @get_eee: Get Energy-Efficient Ethernet (EEE) supported and status.
+ * @set_eee: Set EEE status (enable/disable).
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -937,6 +940,8 @@ struct ethtool_ops {
 				 struct ethtool_dump *, void *);
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
 
+	int	(*get_eee) (struct net_device *, struct ethtool_value *);
+	int	(*set_eee) (struct net_device *, struct ethtool_value *);
 };
 #endif /* __KERNEL__ */
 
@@ -1010,6 +1015,8 @@ struct ethtool_ops {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GEEE		0x00000041 /* Get EEE */
+#define ETHTOOL_SEEE		0x00000042 /* Set EEE */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 3f79db1..088b621 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -714,6 +714,32 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_wol(dev, &wol);
 }
 
+static int ethtool_get_eee(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->get_eee)
+		return -EOPNOTSUPP;
+
+	dev->ethtool_ops->get_eee(dev, &edata);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_eee(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->set_eee)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_eee(dev, &edata);
+}
 static int ethtool_nway_reset(struct net_device *dev)
 {
 	if (!dev->ethtool_ops->nway_reset)
@@ -1368,6 +1394,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		rc = ethtool_set_value_void(dev, useraddr,
 				       dev->ethtool_ops->set_msglevel);
 		break;
+	case ETHTOOL_GEEE:
+		rc = ethtool_get_eee(dev, useraddr);
+		break;
+	case ETHTOOL_SEEE:
+		rc = ethtool_set_eee(dev, useraddr);
+		break;
 	case ETHTOOL_NWAY_RST:
 		rc = ethtool_nway_reset(dev);
 		break;
-- 
1.7.4.4
