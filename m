From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH 1/3]  Kernel support for flexible wakeup filters
Date: Tue, 29 Jan 2008 13:02:08 -0800
Message-ID: <1201640528.11148.32.camel@strongmad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18884 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222AbYA2VVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 16:21:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtool infrastructure support for Wake-on-Lan flexible filters.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 71d4ada..70b86da 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -56,6 +56,16 @@ struct ethtool_wolinfo {
 	__u8	sopass[SOPASS_MAX]; /* SecureOn(tm) password */
 };
 
+#define WOL_FILTER_MAX_LEN 256
+#define WOL_FILTER_IGNORE_OCTET 0x100
+/* wake-on-lan flexible filters */
+struct ethtool_wol_filter {
+	__u32	cmd;
+	__u32	index;
+	__u32	len;
+	__u16	mask_val[0];
+};
+
 /* for passing single values */
 struct ethtool_value {
 	__u32	cmd;
@@ -326,6 +336,8 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data);
  * get_stats: Return statistics about the device
  * get_flags: get 32-bit flags bitmap
  * set_flags: set 32-bit flags bitmap
+ * get_wol_filter: get user-defined Wake-on-Lan filter
+ * set_wol_filter: set user-defined Wake-on-Lan filter
  * 
  * Description:
  *
@@ -391,6 +403,8 @@ struct ethtool_ops {
 	u32     (*get_priv_flags)(struct net_device *);
 	int     (*set_priv_flags)(struct net_device *, u32);
 	int	(*get_sset_count)(struct net_device *, int);
+	int	(*get_wol_filter)(struct net_device *, struct ethtool_wol_filter *, u16 *);
+	int	(*set_wol_filter)(struct net_device *, struct ethtool_wol_filter *, u16 *);
 
 	/* the following hooks are obsolete */
 	int	(*self_test_count)(struct net_device *);/* use get_sset_count */
@@ -440,6 +454,9 @@ struct ethtool_ops {
 #define ETHTOOL_SFLAGS		0x00000026 /* Set flags bitmap(ethtool_value) */
 #define ETHTOOL_GPFLAGS		0x00000027 /* Get driver-private flags bitmap */
 #define ETHTOOL_SPFLAGS		0x00000028 /* Set driver-private flags bitmap */
+#define ETHTOOL_GNUMWOLFILT	0x00000029 /* Get number of WOL filters. */
+#define ETHTOOL_GWOLFILTER	0x0000002a /* Get WOL filter */
+#define ETHTOOL_SWOLFILTER	0x0000002b /* Set WOL filter */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -526,5 +543,6 @@ struct ethtool_ops {
 #define WAKE_ARP		(1 << 4)
 #define WAKE_MAGIC		(1 << 5)
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
+#define WAKE_FILTER		(1 << 7)
 
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1163eb2..9ba9eb5 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -272,6 +272,64 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_wol(dev, &wol);
 }
 
+static int ethtool_get_wol_filter(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_wol_filter wolfilt = { ETHTOOL_GWOLFILTER };
+	u16 *data;
+
+	if (!dev->ethtool_ops->get_wol_filter)
+		return -EOPNOTSUPP;
+
+	data = kmalloc(WOL_FILTER_MAX_LEN * 2, GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	if (copy_from_user(&wolfilt, useraddr, sizeof(wolfilt)))
+		return -EFAULT;
+
+	dev->ethtool_ops->get_wol_filter(dev, &wolfilt, data);
+
+	if (copy_to_user(useraddr, &wolfilt, sizeof(wolfilt)))
+		return -EFAULT;
+	if (copy_to_user(useraddr + sizeof(wolfilt), data, wolfilt.len * 2))
+		return -EFAULT;
+
+	kfree(data);
+	return 0;
+}
+
+static int ethtool_set_wol_filter(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_wol_filter wolfilt;
+	u16 *data = NULL;
+	int ret;
+
+	if (!dev->ethtool_ops->get_wol_filter)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&wolfilt, useraddr, sizeof(wolfilt)))
+		return -EFAULT;
+
+	if (wolfilt.len > WOL_FILTER_MAX_LEN)
+		return -EOPNOTSUPP;
+		
+	if (wolfilt.len) {
+		data = kmalloc(wolfilt.len * 2, GFP_KERNEL);
+		if (!data)
+			return -ENOMEM;
+	}
+
+	ret = -EFAULT;
+	if (copy_from_user(data, useraddr + sizeof(wolfilt), wolfilt.len * 2))
+		goto out;
+
+	ret = dev->ethtool_ops->set_wol_filter(dev, &wolfilt, data);
+out:
+	kfree(data);
+	return ret;
+		
+}
+
 static int ethtool_nway_reset(struct net_device *dev)
 {
 	if (!dev->ethtool_ops->nway_reset)
@@ -964,6 +1022,13 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		rc = ethtool_set_value(dev, useraddr,
 				       dev->ethtool_ops->set_priv_flags);
 		break;
+	case ETHTOOL_GNUMWOLFILT:
+	case ETHTOOL_GWOLFILTER:
+		rc = ethtool_get_wol_filter(dev, useraddr);
+		break;
+	case ETHTOOL_SWOLFILTER:
+		rc = ethtool_set_wol_filter(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}


