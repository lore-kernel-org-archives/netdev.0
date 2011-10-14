From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH RFC 1/2] ethtool: Add extended flow control query
 facility
Date: Fri, 14 Oct 2011 13:54:01 -0700
Message-ID: <1318625642-9668-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2608 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932460Ab1JNUyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 16:54:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a new ethtool_pauseparamext structure that elaborates
on the older struct ethtool_pauseparam structure.  The new structure
adds two new fields that represent the current flow control status.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 include/linux/ethtool.h |   14 ++++++++++-
 net/core/ethtool.c      |   59 +++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 67 insertions(+), 6 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 45f00b6..cd60d74 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -284,6 +284,15 @@ struct ethtool_pauseparam {
 	__u32	tx_pause;
 };
 
+/* for configuring link flow control parameters */
+struct ethtool_pauseparamext {
+	struct ethtool_pauseparam cfg;
+
+	__u32	rx_pause_status;
+	__u32	tx_pause_status;
+	__u32	reserved[2];
+};
+
 #define ETH_GSTRING_LEN		32
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -956,7 +965,8 @@ struct ethtool_ops {
 	int	(*get_dump_data)(struct net_device *,
 				 struct ethtool_dump *, void *);
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
-
+	void	(*get_pauseparamext)(struct net_device *,
+				  struct ethtool_pauseparamext*);
 };
 #endif /* __KERNEL__ */
 
@@ -1030,6 +1040,8 @@ struct ethtool_ops {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GPAUSEPARAMEXT	0x00000041 /* Get pause parameters v2 */
+#define ETHTOOL_SPAUSEPARAMEXT	0x00000042 /* Set pause parameters v2 */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f444817..1c0f58c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1206,15 +1206,21 @@ static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
 
 static int ethtool_get_pauseparam(struct net_device *dev, void __user *useraddr)
 {
-	struct ethtool_pauseparam pauseparam = { ETHTOOL_GPAUSEPARAM };
+	struct ethtool_pauseparamext pauseparam = {
+		{ .cmd = ETHTOOL_GPAUSEPARAM }
+	};
 
-	if (!dev->ethtool_ops->get_pauseparam)
+	if (dev->ethtool_ops->get_pauseparam)
+		dev->ethtool_ops->get_pauseparam(dev, &pauseparam.cfg);
+	else if (dev->ethtool_ops->get_pauseparamext)
+		dev->ethtool_ops->get_pauseparamext(dev, &pauseparam);
+	else
 		return -EOPNOTSUPP;
 
-	dev->ethtool_ops->get_pauseparam(dev, &pauseparam);
-
-	if (copy_to_user(useraddr, &pauseparam, sizeof(pauseparam)))
+	if (copy_to_user(useraddr, &pauseparam,
+			 sizeof(struct ethtool_pauseparam)))
 		return -EFAULT;
+
 	return 0;
 }
 
@@ -1231,6 +1237,42 @@ static int ethtool_set_pauseparam(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_pauseparam(dev, &pauseparam);
 }
 
+static int ethtool_get_pauseparamext(struct net_device *dev,
+				     void __user *useraddr)
+{
+	struct ethtool_pauseparamext pauseparam = {
+		{ .cmd = ETHTOOL_GPAUSEPARAMEXT }
+	};
+
+	if (dev->ethtool_ops->get_pauseparamext) {
+		dev->ethtool_ops->get_pauseparamext(dev, &pauseparam);
+	} else {
+		if (!dev->ethtool_ops->get_pauseparam)
+			return -EOPNOTSUPP;
+
+		dev->ethtool_ops->get_pauseparam(dev, &pauseparam.cfg);
+	}
+
+	if (copy_to_user(useraddr, &pauseparam, sizeof(pauseparam)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int ethtool_set_pauseparamext(struct net_device *dev,
+				     void __user *useraddr)
+{
+	struct ethtool_pauseparamext pauseparam;
+
+	if (!dev->ethtool_ops->set_pauseparam)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&pauseparam, useraddr, sizeof(pauseparam)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_pauseparam(dev, &pauseparam.cfg);
+}
+
 static int __ethtool_set_sg(struct net_device *dev, u32 data)
 {
 	int err;
@@ -1667,6 +1709,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GCOALESCE:
 	case ETHTOOL_GRINGPARAM:
 	case ETHTOOL_GPAUSEPARAM:
+	case ETHTOOL_GPAUSEPARAMEXT:
 	case ETHTOOL_GRXCSUM:
 	case ETHTOOL_GTXCSUM:
 	case ETHTOOL_GSG:
@@ -1754,6 +1797,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SPAUSEPARAM:
 		rc = ethtool_set_pauseparam(dev, useraddr);
 		break;
+	case ETHTOOL_GPAUSEPARAMEXT:
+		rc = ethtool_get_pauseparamext(dev, useraddr);
+		break;
+	case ETHTOOL_SPAUSEPARAMEXT:
+		rc = ethtool_set_pauseparamext(dev, useraddr);
+		break;
 	case ETHTOOL_TEST:
 		rc = ethtool_self_test(dev, useraddr);
 		break;
-- 
1.7.3.4
