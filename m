From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v5 net-next 1/2] ethtool: Support for configurable RSS hash key
Date: Mon, 17 Mar 2014 18:01:34 +0530
Message-ID: <2c198273-6bd2-48b2-a568-9957edef7e5e@CMEXHTCAS2.ad.emulex.com>
References: <1395059495-16073-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:28288 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932767AbaCQMcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 08:32:04 -0400
In-Reply-To: <1395059495-16073-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch primarily copies the ioctl command data structures
from/to the User space and invokes the driver hook.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 include/linux/ethtool.h      |   13 +++
 include/uapi/linux/ethtool.h |   30 ++++++
 net/core/ethtool.c           |  219 +++++++++++++++++++++++++++++++++++++++---
 3 files changed, 248 insertions(+), 14 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 0a114d0..f7f5576 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -154,13 +154,23 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @reset: Reset (part of) the device, as specified by a bitmask of
  *	flags from &enum ethtool_reset_flags.  Returns a negative
  *	error code or zero.
+ * @get_rxfh_key_size: Get the size of the RX flow hash key.
+ *	Returns zero if not supported for this specific device.
  * @get_rxfh_indir_size: Get the size of the RX flow hash indirection table.
  *	Returns zero if not supported for this specific device.
  * @get_rxfh_indir: Get the contents of the RX flow hash indirection table.
  *	Will not be called if @get_rxfh_indir_size returns zero.
+ * @get_rxfh: Get the contents of the RX flow hash indirection table and hash
+ *	key.
+ *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
+ *	returns zero.
  *	Returns a negative error code or zero.
  * @set_rxfh_indir: Set the contents of the RX flow hash indirection table.
  *	Will not be called if @get_rxfh_indir_size returns zero.
+ * @set_rxfh: Set the contents of the RX flow hash indirection table and
+ *	hash key.
+ *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
+ *	returns zero.
  *	Returns a negative error code or zero.
  * @get_channels: Get number of channels.
  * @set_channels: Set number of channels.  Returns a negative error code or
@@ -232,7 +242,10 @@ struct ethtool_ops {
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int	(*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
+	u32	(*get_rxfh_key_size)(struct net_device *);
 	u32	(*get_rxfh_indir_size)(struct net_device *);
+	int	(*get_rxfh)(struct net_device *, struct ethtool_rxfh *);
+	int	(*set_rxfh)(struct net_device *, struct ethtool_rxfh *);
 	int	(*get_rxfh_indir)(struct net_device *, u32 *);
 	int	(*set_rxfh_indir)(struct net_device *, const u32 *);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index fd161e9..89fb708 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -847,6 +847,33 @@ struct ethtool_rxfh_indir {
 };
 
 /**
+ * struct ethtool_rxfh - command to get/set RX flow hash indir or/and hash key.
+ * @cmd: Specific command number - %ETHTOOL_GRSSH or %ETHTOOL_SRSSH
+ * @indir_size: On entry, the array size of the user buffer, which may be zero.
+ *		On return from %ETHTOOL_GRSSH, the array size of the hardware
+ *		indirection table.
+ * @key_size:	On entry, the array size of the user buffer in bytes,
+ *		which may be zero.
+ *		On return from %ETHTOOL_GRSSH, the size of the RSS hash key.
+ * @rsvd:	Reserved for future extensions.
+ * @rss_config: RX ring/queue index for each hash value i.e., indirection table
+ *		of size @indir_size followed by hash key of size @key_size.
+ *
+ * For %ETHTOOL_GRSSH, a @indir_size and key_size of zero means that only the
+ * size should be returned.  For %ETHTOOL_SRSSH, a @indir_size of 0xDEADBEEF
+ * means that indir table setting is not requested and a @indir_size of zero
+ * means the indir table should be reset to default values. This last feature
+ * is not supported by the original implementations.
+ */
+struct ethtool_rxfh {
+	__u32   cmd;
+	__u32   indir_size;
+	__u32   key_size;
+	__u32	rsvd[3];
+	__u32   rss_config[0];
+};
+
+/**
  * struct ethtool_rx_ntuple_flow_spec - specification for RX flow filter
  * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
  * @h_u: Flow field values to match (dependent on @flow_type)
@@ -1118,6 +1145,9 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
 #define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
 
+#define ETHTOOL_GRSSH		0x00000046 /* Get RX flow hash configuration */
+#define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 30071de..98525af 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -556,6 +556,23 @@ err_out:
 	return ret;
 }
 
+static int ethtool_copy_validate_indir(u32 *indir, void __user *useraddr,
+					struct ethtool_rxnfc *rx_rings,
+					u32 size)
+{
+	int ret = 0, i;
+
+	if (copy_from_user(indir, useraddr, size * sizeof(indir[0])))
+		ret = -EFAULT;
+
+	/* Validate ring indices */
+	for (i = 0; i < size; i++) {
+		if (indir[i] >= rx_rings->data)
+			ret = -EINVAL;
+	}
+	return ret;
+}
+
 static noinline_for_stack int ethtool_get_rxfh_indir(struct net_device *dev,
 						     void __user *useraddr)
 {
@@ -612,6 +629,7 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 	u32 *indir;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	int ret;
+	u32 ringidx_offset = offsetof(struct ethtool_rxfh_indir, ring_index[0]);
 
 	if (!ops->get_rxfh_indir_size || !ops->set_rxfh_indir ||
 	    !ops->get_rxnfc)
@@ -642,28 +660,194 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 		for (i = 0; i < dev_size; i++)
 			indir[i] = ethtool_rxfh_indir_default(i, rx_rings.data);
 	} else {
-		if (copy_from_user(indir,
-				  useraddr +
-				  offsetof(struct ethtool_rxfh_indir,
-					   ring_index[0]),
-				  dev_size * sizeof(indir[0]))) {
+		ret = ethtool_copy_validate_indir(indir,
+						  useraddr + ringidx_offset,
+						  &rx_rings,
+						  dev_size);
+		if (ret)
+			goto out;
+	}
+
+	ret = ops->set_rxfh_indir(dev, indir);
+
+out:
+	kfree(indir);
+	return ret;
+}
+
+static noinline_for_stack int ethtool_get_rxfh(struct net_device *dev,
+					       void __user *useraddr)
+{
+	int ret;
+	struct ethtool_rxfh *rss_info;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	u32 user_indir_size = 0, user_key_size = 0;
+	u32 dev_indir_size = 0, dev_key_size = 0;
+	u32 total_size;
+	u32 indir_offset, indir_bytes;
+	u32 key_offset;
+
+	if (!(dev->ethtool_ops->get_rxfh_indir_size ||
+	      dev->ethtool_ops->get_rxfh_key_size) ||
+	      !dev->ethtool_ops->get_rxfh)
+		return -EOPNOTSUPP;
+
+	if (ops->get_rxfh_indir_size)
+		dev_indir_size = ops->get_rxfh_indir_size(dev);
+
+	indir_offset = offsetof(struct ethtool_rxfh, indir_size);
+
+	if (copy_from_user(&user_indir_size,
+			   useraddr + indir_offset,
+			   sizeof(user_indir_size)))
+		return -EFAULT;
+
+	if (copy_to_user(useraddr + indir_offset,
+			 &dev_indir_size, sizeof(dev_indir_size)))
+		return -EFAULT;
+
+	if (ops->get_rxfh_key_size)
+		dev_key_size = ops->get_rxfh_key_size(dev);
+
+	if ((dev_key_size + dev_indir_size) == 0)
+		return -EOPNOTSUPP;
+
+	key_offset = offsetof(struct ethtool_rxfh, key_size);
+
+	if (copy_from_user(&user_key_size,
+			   useraddr + key_offset,
+			   sizeof(user_key_size)))
+		return -EFAULT;
+
+	if (copy_to_user(useraddr + key_offset,
+			 &dev_key_size, sizeof(dev_key_size)))
+		return -EFAULT;
+
+	/* If the user buffer size is 0, this is just a query for the
+	 * device table size and key size.  Otherwise, if the User size is
+	 * not equal to device table size or key size it's an error.
+	 */
+	if (!user_indir_size && !user_key_size)
+		return 0;
+
+	if ((user_indir_size && (user_indir_size != dev_indir_size)) ||
+	    (user_key_size && (user_key_size != dev_key_size)))
+		return -EINVAL;
+
+	indir_bytes = user_indir_size * sizeof(rss_info->rss_config[0]);
+	total_size = sizeof(*rss_info) + indir_bytes + user_key_size;
+	rss_info = kzalloc(total_size, GFP_USER);
+	if (!rss_info)
+		return -ENOMEM;
+
+	rss_info->indir_size = user_indir_size;
+	rss_info->key_size = user_key_size;
+	ret = dev->ethtool_ops->get_rxfh(dev, rss_info);
+	if (!ret) {
+		if (copy_to_user(useraddr +
+				 offsetof(struct ethtool_rxfh, rss_config[0]),
+				 rss_info->rss_config, total_size))
 			ret = -EFAULT;
+	}
+
+	kfree(rss_info);
+
+	return ret;
+}
+
+static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
+					       void __user *useraddr)
+{
+	int ret;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct ethtool_rxnfc rx_rings;
+	struct ethtool_rxfh *rss_info;
+	u32 user_indir_size = 0, dev_indir_size = 0, i;
+	u32 user_key_size = 0, dev_key_size = 0;
+	u32 *indir, indir_bytes = 0;
+	u32 indir_offset, key_offset;
+	u32 rss_cfg_offset = offsetof(struct ethtool_rxfh, rss_config[0]);
+
+	if (!(ops->get_rxfh_indir_size || ops->get_rxfh_key_size) ||
+	    !ops->get_rxnfc || !ops->set_rxfh)
+		return -EOPNOTSUPP;
+
+	if (ops->get_rxfh_indir_size)
+		dev_indir_size = ops->get_rxfh_indir_size(dev);
+
+	indir_offset = offsetof(struct ethtool_rxfh, indir_size);
+	if (copy_from_user(&user_indir_size,
+			   useraddr + indir_offset,
+			   sizeof(user_indir_size)))
+		return -EFAULT;
+
+	if (ops->get_rxfh_key_size)
+		dev_key_size = dev->ethtool_ops->get_rxfh_key_size(dev);
+
+	if ((dev_key_size + dev_indir_size) == 0)
+		return -EOPNOTSUPP;
+
+	key_offset = offsetof(struct ethtool_rxfh, key_size);
+	if (copy_from_user(&user_key_size,
+			   useraddr + key_offset,
+			   sizeof(user_key_size)))
+		return -EFAULT;
+
+	/* If either indir or hash key is valid, proceed further.
+	 */
+	if ((user_indir_size && ((user_indir_size != 0xDEADBEEF) &&
+				 user_indir_size != dev_indir_size)) ||
+	    (user_key_size && (user_key_size != dev_key_size)))
+		return -EINVAL;
+
+	if (user_indir_size != 0xDEADBEEF)
+		indir_bytes = dev_indir_size * sizeof(rss_info->rss_config[0]);
+
+	rss_info = kzalloc(sizeof(*rss_info) + indir_bytes + user_key_size,
+			   GFP_USER);
+	if (!rss_info)
+		return -ENOMEM;
+
+	rx_rings.cmd = ETHTOOL_GRXRINGS;
+	ret = ops->get_rxnfc(dev, &rx_rings, NULL);
+	if (ret)
+		goto out;
+
+	rss_info->indir_size = user_indir_size;
+	rss_info->key_size = user_key_size;
+
+	/* user_indir_size == 0 means reset the indir table to default.
+	 * user_indir_size == 0xDEADBEEF means indir setting is not requested.
+	 */
+	indir = rss_info->rss_config;
+	if (user_indir_size && user_indir_size != 0xDEADBEEF) {
+		ret = ethtool_copy_validate_indir(indir,
+						  useraddr + rss_cfg_offset,
+						  &rx_rings,
+						  user_indir_size);
+		if (ret)
 			goto out;
-		}
+	} else if (user_indir_size == 0) {
+		for (i = 0; i < dev_indir_size; i++)
+			indir[i] = ethtool_rxfh_indir_default(i, rx_rings.data);
+			rss_info->indir_size = dev_indir_size;
+	} else {
+		rss_info->indir_size = 0;
+	}
 
-		/* Validate ring indices */
-		for (i = 0; i < dev_size; i++) {
-			if (indir[i] >= rx_rings.data) {
-				ret = -EINVAL;
-				goto out;
-			}
+	if (user_key_size) {
+		if (copy_from_user(((char *)rss_info->rss_config) + indir_bytes,
+				   useraddr + rss_cfg_offset + indir_bytes,
+				   user_key_size)) {
+			ret = -EFAULT;
+			goto out;
 		}
 	}
 
-	ret = ops->set_rxfh_indir(dev, indir);
+	ret = ops->set_rxfh(dev, rss_info);
 
 out:
-	kfree(indir);
+	kfree(rss_info);
 	return ret;
 }
 
@@ -1490,6 +1674,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GRXCLSRULE:
 	case ETHTOOL_GRXCLSRLALL:
 	case ETHTOOL_GRXFHINDIR:
+	case ETHTOOL_GRSSH:
 	case ETHTOOL_GFEATURES:
 	case ETHTOOL_GCHANNELS:
 	case ETHTOOL_GET_TS_INFO:
@@ -1627,6 +1812,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SRXFHINDIR:
 		rc = ethtool_set_rxfh_indir(dev, useraddr);
 		break;
+	case ETHTOOL_GRSSH:
+		rc = ethtool_get_rxfh(dev, useraddr);
+		break;
+	case ETHTOOL_SRSSH:
+		rc = ethtool_set_rxfh(dev, useraddr);
+		break;
 	case ETHTOOL_GFEATURES:
 		rc = ethtool_get_features(dev, useraddr);
 		break;
-- 
1.7.1
