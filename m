From: chavey@google.com
Subject: [PATCH 1/1] add ethtool loopback support
Date: Thu, 08 Apr 2010 10:35:34 -0700
Message-ID: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, therbert@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:31767 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab0DHRfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 13:35:43 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o38HZgaf012707
	for <netdev@vger.kernel.org>; Thu, 8 Apr 2010 10:35:42 -0700
Received: from iwn6 (iwn6.prod.google.com [10.241.68.70])
	by kpbe18.cbf.corp.google.com with ESMTP id o38HZfSF004661
	for <netdev@vger.kernel.org>; Thu, 8 Apr 2010 10:35:41 -0700
Received: by iwn6 with SMTP id 6so1573206iwn.26
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 10:35:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ranjit Manomohan <ranjitm@google.com>
Date: Wed, 7 Apr 2010 15:19:48 -0700

Add an ethtool option to use internal loopback mode for testing. 
This feature is used for component and driver test coverage by putting
the device in hardware loopback mode and sending / receiving network
traffic from a user application to test the hardware and driver
transmit / receive paths. 

Signed-off-by: laurent chavey <chavey@google.com>
---
 include/linux/ethtool.h |   16 ++++++++++++++++
 net/core/ethtool.c      |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b33f316..df1dcc7 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -292,6 +292,18 @@ struct ethtool_stats {
 	__u64	data[0];
 };
 
+/* for setting the NIC into loopback mode */
+struct ethtool_loopback {
+	u32 cmd;		/* ETHTOOL_SLOOPBACK */
+	u32 type;		/* ethtool_loopback_type */
+};
+
+enum ethtool_loopback_type {
+	ETH_MAC			= 0x00000001,
+	ETH_PHY_INT		= 0x00000002,
+	ETH_PHY_EXT		= 0x00000004
+};
+
 struct ethtool_perm_addr {
 	__u32	cmd;		/* ETHTOOL_GPERMADDR */
 	__u32	size;
@@ -566,6 +578,8 @@ struct ethtool_ops {
 	int	(*reset)(struct net_device *, u32 *);
 	int	(*set_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *);
 	int	(*get_rx_ntuple)(struct net_device *, u32 stringset, void *);
+	int     (*set_loopback)(struct net_device *, struct ethtool_loopback *);
+	int     (*get_loopback)(struct net_device *, struct ethtool_loopback *);
 };
 #endif /* __KERNEL__ */
 
@@ -627,6 +641,8 @@ struct ethtool_ops {
 #define	ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
 #define	ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
 #define	ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
+#define ETHTOOL_SLOOPBACK       0x00000038 /* Set loopback mode on/off */
+#define ETHTOOL_GLOOPBACK       0x00000039 /* Get loopback mode setting */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f4cb6b6..89b4ecb 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1289,6 +1289,40 @@ static noinline_for_stack int ethtool_flash_device(struct net_device *dev, char
 	return dev->ethtool_ops->flash_device(dev, &efl);
 }
 
+static int ethtool_set_loopback(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_loopback lpbk;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
+	if (!ops->set_loopback)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&lpbk, useraddr, sizeof(lpbk)))
+		return -EFAULT;
+
+	return ops->set_loopback(dev, &lpbk);
+}
+
+static int ethtool_get_loopback(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_loopback lpbk;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	int err;
+
+	if (!ops->get_loopback)
+		return -EOPNOTSUPP;
+
+	err = ops->get_loopback(dev, &lpbk);
+
+	if (err)
+		return err;
+
+	if (copy_to_user(useraddr, &lpbk, sizeof(lpbk)))
+		return -EFAULT;
+
+	return 0;
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1518,6 +1552,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GSSET_INFO:
 		rc = ethtool_get_sset_info(dev, useraddr);
 		break;
+	case ETHTOOL_SLOOPBACK:
+		rc = ethtool_set_loopback(dev, useraddr);
+		break;
+	case ETHTOOL_GLOOPBACK:
+		rc = ethtool_get_loopback(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.0.1

