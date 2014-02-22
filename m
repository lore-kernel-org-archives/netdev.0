From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v2 net-next 1/2] ethtool - Support for configurable RSS hash key
Date: Sat, 22 Feb 2014 17:21:57 +0530
Message-ID: <ecb603ac-aefa-4288-9f90-c335b2faa6aa@CMEXHTCAS1.ad.emulex.com>
References: <1393069918-11539-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:21351 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbaBVLv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 06:51:59 -0500
In-Reply-To: <1393069918-11539-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch primarily copies the ioctl command data structures
from/to the User space and invokes the driver hook.
---
 include/linux/ethtool.h      |   17 +++-
 include/uapi/linux/ethtool.h |   38 +++++---
 net/core/ethtool.c           |  207 +++++++++++++++++++++++++++++-------------
 3 files changed, 178 insertions(+), 84 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 0a114d0..ecc7193 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -154,13 +154,19 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @reset: Reset (part of) the device, as specified by a bitmask of
  *	flags from &enum ethtool_reset_flags.  Returns a negative
  *	error code or zero.
+ * @get_rxfh_key_size: Get the size of the RX flow hash key.
+ *	Returns zero if not supported for this specific device.
  * @get_rxfh_indir_size: Get the size of the RX flow hash indirection table.
  *	Returns zero if not supported for this specific device.
- * @get_rxfh_indir: Get the contents of the RX flow hash indirection table.
- *	Will not be called if @get_rxfh_indir_size returns zero.
+ * @get_rxfh: Get the contents of the RX flow hash indirection table and hash
+ *	key.
+ *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
+ *	returns zero.
  *	Returns a negative error code or zero.
- * @set_rxfh_indir: Set the contents of the RX flow hash indirection table.
- *	Will not be called if @get_rxfh_indir_size returns zero.
+ * @set_rxfh: Set the contents of the RX flow hash indirection table and
+ *	hash key.
+ *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
+ *	returns zero.
  *	Returns a negative error code or zero.
  * @get_channels: Get number of channels.
  * @set_channels: Set number of channels.  Returns a negative error code or
@@ -232,7 +238,10 @@ struct ethtool_ops {
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int	(*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
+	u32	(*get_rxfh_key_size)(struct net_device *);
 	u32	(*get_rxfh_indir_size)(struct net_device *);
+	int	(*set_rxfh)(struct net_device *, struct ethtool_rxfh *);
+	int	(*get_rxfh)(struct net_device *, struct ethtool_rxfh *);
 	int	(*get_rxfh_indir)(struct net_device *, u32 *);
 	int	(*set_rxfh_indir)(struct net_device *, const u32 *);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index fd161e9..c88d0e9 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -828,22 +828,30 @@ struct ethtool_rxnfc {
 
 
 /**
- * struct ethtool_rxfh_indir - command to get or set RX flow hash indirection
- * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFHINDIR
- * @size: On entry, the array size of the user buffer, which may be zero.
- *	On return from %ETHTOOL_GRXFHINDIR, the array size of the hardware
- *	indirection table.
- * @ring_index: RX ring/queue index for each hash value
+ * struct ethtool_rxfh - command to get or set RX flow hash indirection or/and
+ * hash key.
+ * @cmd: Specific command number - %ETHTOOL_GRSSH or %ETHTOOL_SRSSH
+ * @indir_size: On entry, the array size of the user buffer, which may be zero.
+ *		On return from %ETHTOOL_GRSSH, the array size of the hardware
+ *		indirection table.
+ * @key_size:	On entry, the array size of the user buffer in bytes,
+ *		which may be zero.
+ *		On return from %ETHTOOL_GRSSH, the size of the RSS hash key.
+ * @rsvd:	Reserved for future extensions.
+ * @rss_config: RX ring/queue index for each hash value or/and hash key
+ *		respectively.
  *
- * For %ETHTOOL_GRXFHINDIR, a @size of zero means that only the size
- * should be returned.  For %ETHTOOL_SRXFHINDIR, a @size of zero means
- * the table should be reset to default values.  This last feature
+ * For %ETHTOOL_GRSSH, a @indir_size and key_size of zero means that only the
+ * size should be returned.  For %ETHTOOL_SRSSH, a @indir_size of zero means
+ * the indir table should be reset to default values.  This last feature
  * is not supported by the original implementations.
  */
-struct ethtool_rxfh_indir {
-	__u32	cmd;
-	__u32	size;
-	__u32	ring_index[0];
+struct ethtool_rxfh {
+	__u32   cmd;
+	__u32   indir_size;
+	__u32   key_size;
+	__u32	rsvd[3];
+	__u32   rss_config[0];
 };
 
 /**
@@ -1102,8 +1110,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
 #define ETHTOOL_GRXNTUPLE	0x00000036 /* deprecated */
 #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
-#define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
-#define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
+#define ETHTOOL_GRSSH		0x00000038 /* Get RX flow hash indir'n table */
+#define ETHTOOL_SRSSH		0x00000039 /* Set RX flow hash indir'n table */
 
 #define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
 #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 30071de..92827b4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -556,81 +556,145 @@ err_out:
 	return ret;
 }
 
-static noinline_for_stack int ethtool_get_rxfh_indir(struct net_device *dev,
-						     void __user *useraddr)
+static noinline_for_stack int ethtool_get_rxfh(struct net_device *dev,
+					       void __user *useraddr)
 {
-	u32 user_size, dev_size;
-	u32 *indir;
 	int ret;
-
-	if (!dev->ethtool_ops->get_rxfh_indir_size ||
-	    !dev->ethtool_ops->get_rxfh_indir)
+	struct ethtool_rxfh *rss_info;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	u32 user_indir_size = 0, user_key_size = 0;
+	u32 dev_indir_size = 0, dev_key_size = 0;
+	u32 total_size;
+	u32 indir_offset, indir_bytes;
+	u32 key_offset;
+
+	if (!(dev->ethtool_ops->get_rxfh_indir_size ||
+	      dev->ethtool_ops->get_rxfh_key_size ||
+	      dev->ethtool_ops->get_rxfh))
 		return -EOPNOTSUPP;
-	dev_size = dev->ethtool_ops->get_rxfh_indir_size(dev);
-	if (dev_size == 0)
+
+	if (ops->get_rxfh_indir_size)
+		dev_indir_size = ops->get_rxfh_indir_size(dev);
+
+	if (dev_indir_size) {
+		indir_offset = offsetof(struct ethtool_rxfh, indir_size);
+
+		if (copy_from_user(&user_indir_size,
+				   useraddr + indir_offset,
+				   sizeof(user_indir_size)))
+			return -EFAULT;
+
+		if (copy_to_user(useraddr + indir_offset,
+				 &dev_indir_size, sizeof(dev_indir_size)))
+			return -EFAULT;
+	}
+
+	if (ops->get_rxfh_key_size)
+		dev_key_size = ops->get_rxfh_key_size(dev);
+
+	if ((dev_key_size + dev_indir_size) == 0)
 		return -EOPNOTSUPP;
 
-	if (copy_from_user(&user_size,
-			   useraddr + offsetof(struct ethtool_rxfh_indir, size),
-			   sizeof(user_size)))
-		return -EFAULT;
+	if (dev_key_size) {
+		key_offset = offsetof(struct ethtool_rxfh, key_size);
 
-	if (copy_to_user(useraddr + offsetof(struct ethtool_rxfh_indir, size),
-			 &dev_size, sizeof(dev_size)))
-		return -EFAULT;
+		if (copy_from_user(&user_key_size,
+				   useraddr + key_offset,
+				   sizeof(user_key_size)))
+			return -EFAULT;
+
+		if (copy_to_user(useraddr + key_offset,
+				 &dev_key_size, sizeof(dev_key_size)))
+			return -EFAULT;
+	}
 
 	/* If the user buffer size is 0, this is just a query for the
-	 * device table size.  Otherwise, if it's smaller than the
-	 * device table size it's an error.
+	 * device table size and key size.  Otherwise, if the User size is
+	 * not equal to device table size or key size it's an error.
 	 */
-	if (user_size < dev_size)
-		return user_size == 0 ? 0 : -EINVAL;
+	if (!user_indir_size && !user_key_size)
+		return 0;
+
+	if ((user_indir_size && (user_indir_size != dev_indir_size)) ||
+	    (user_key_size && (user_key_size != dev_key_size)))
+		return -EINVAL;
 
-	indir = kcalloc(dev_size, sizeof(indir[0]), GFP_USER);
-	if (!indir)
+	indir_bytes = user_indir_size * sizeof(rss_info->rss_config[0]);
+	total_size = indir_bytes + user_key_size;
+	rss_info = kzalloc(total_size, GFP_USER);
+	if (!rss_info)
 		return -ENOMEM;
 
-	ret = dev->ethtool_ops->get_rxfh_indir(dev, indir);
-	if (ret)
-		goto out;
+	rss_info->indir_size = user_indir_size;
+	rss_info->key_size = user_key_size;
+	ret = dev->ethtool_ops->get_rxfh(dev, rss_info);
+	if (!ret) {
+		if (copy_to_user(useraddr +
+				 offsetof(struct ethtool_rxfh, rss_config[0]),
+				 rss_info->rss_config, total_size))
+			ret = -EFAULT;
+	}
 
-	if (copy_to_user(useraddr +
-			 offsetof(struct ethtool_rxfh_indir, ring_index[0]),
-			 indir, dev_size * sizeof(indir[0])))
-		ret = -EFAULT;
+	kfree(rss_info);
 
-out:
-	kfree(indir);
 	return ret;
 }
 
-static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
-						     void __user *useraddr)
+static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
+					       void __user *useraddr)
 {
-	struct ethtool_rxnfc rx_rings;
-	u32 user_size, dev_size, i;
-	u32 *indir;
-	const struct ethtool_ops *ops = dev->ethtool_ops;
 	int ret;
-
-	if (!ops->get_rxfh_indir_size || !ops->set_rxfh_indir ||
-	    !ops->get_rxnfc)
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct ethtool_rxnfc rx_rings;
+	struct ethtool_rxfh *rss_info;
+	u32 user_indir_size = 0, dev_indir_size = 0, i;
+	u32 user_key_size = 0, dev_key_size = 0;
+	u32 *indir, indir_bytes = 0;
+	u32 indir_offset, key_offset;
+	u32 rss_cfg_offset = offsetof(struct ethtool_rxfh, rss_config[0]);
+
+	if (!(ops->get_rxfh_indir_size || ops->set_rxfh ||
+	      ops->get_rxnfc || ops->get_rxfh_key_size))
 		return -EOPNOTSUPP;
 
-	dev_size = ops->get_rxfh_indir_size(dev);
-	if (dev_size == 0)
+	if (ops->get_rxfh_indir_size)
+		dev_indir_size = ops->get_rxfh_indir_size(dev);
+
+	if (dev_indir_size) {
+		indir_offset = offsetof(struct ethtool_rxfh, indir_size);
+		if (copy_from_user(&user_indir_size,
+				   useraddr + indir_offset,
+				   sizeof(user_indir_size)))
+			return -EFAULT;
+	}
+
+	if (ops->get_rxfh_key_size)
+		dev_key_size = dev->ethtool_ops->get_rxfh_key_size(dev);
+
+	if ((dev_key_size + dev_indir_size) == 0)
 		return -EOPNOTSUPP;
 
-	if (copy_from_user(&user_size,
-			   useraddr + offsetof(struct ethtool_rxfh_indir, size),
-			   sizeof(user_size)))
-		return -EFAULT;
+	if (dev_key_size) {
+		key_offset = offsetof(struct ethtool_rxfh, key_size);
+		if (copy_from_user(&user_key_size,
+				   useraddr + key_offset,
+				   sizeof(user_key_size)))
+			return -EFAULT;
+	}
+
+	if (!user_indir_size && !user_key_size)
+		return -EINVAL;
 
-	if (user_size != 0 && user_size != dev_size)
+	if ((user_indir_size && ((user_indir_size != 0xDEADBEEF) &&
+				 user_indir_size != dev_indir_size)) ||
+	    (user_key_size && (user_key_size != dev_key_size)))
 		return -EINVAL;
 
-	indir = kcalloc(dev_size, sizeof(indir[0]), GFP_USER);
-	if (!indir)
+	if (user_indir_size && user_indir_size != 0xDEADBEEF)
+		indir_bytes = user_indir_size * sizeof(rss_info->rss_config[0]);
+
+	rss_info = kzalloc(indir_bytes + user_key_size, GFP_USER);
+	if (!rss_info)
 		return -ENOMEM;
 
 	rx_rings.cmd = ETHTOOL_GRXRINGS;
@@ -638,32 +702,45 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 	if (ret)
 		goto out;
 
-	if (user_size == 0) {
-		for (i = 0; i < dev_size; i++)
-			indir[i] = ethtool_rxfh_indir_default(i, rx_rings.data);
-	} else {
+	rss_info->indir_size = user_indir_size;
+	rss_info->key_size = user_key_size;
+
+	indir = rss_info->rss_config;
+	if (user_indir_size && user_indir_size != 0xDEADBEEF) {
 		if (copy_from_user(indir,
-				  useraddr +
-				  offsetof(struct ethtool_rxfh_indir,
-					   ring_index[0]),
-				  dev_size * sizeof(indir[0]))) {
+				   useraddr + rss_cfg_offset,
+				   user_indir_size * sizeof(indir[0]))) {
 			ret = -EFAULT;
 			goto out;
 		}
 
 		/* Validate ring indices */
-		for (i = 0; i < dev_size; i++) {
+		for (i = 0; i < user_indir_size; i++) {
 			if (indir[i] >= rx_rings.data) {
 				ret = -EINVAL;
 				goto out;
 			}
 		}
+	} else if (user_indir_size == 0) {
+		for (i = 0; i < dev_indir_size; i++)
+			indir[i] = ethtool_rxfh_indir_default(i, rx_rings.data);
+	} else {
+		rss_info->indir_size = 0;
+	}
+
+	if (user_key_size) {
+		if (copy_from_user(((char *)rss_info->rss_config) + indir_bytes,
+				   useraddr + rss_cfg_offset + indir_bytes,
+				   user_key_size)) {
+			ret = -EFAULT;
+			goto out;
+		}
 	}
 
-	ret = ops->set_rxfh_indir(dev, indir);
+	ret = ops->set_rxfh(dev, rss_info);
 
 out:
-	kfree(indir);
+	kfree(rss_info);
 	return ret;
 }
 
@@ -1489,7 +1566,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GRXCLSRLCNT:
 	case ETHTOOL_GRXCLSRULE:
 	case ETHTOOL_GRXCLSRLALL:
-	case ETHTOOL_GRXFHINDIR:
+	case ETHTOOL_GRSSH:
 	case ETHTOOL_GFEATURES:
 	case ETHTOOL_GCHANNELS:
 	case ETHTOOL_GET_TS_INFO:
@@ -1621,11 +1698,11 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GSSET_INFO:
 		rc = ethtool_get_sset_info(dev, useraddr);
 		break;
-	case ETHTOOL_GRXFHINDIR:
-		rc = ethtool_get_rxfh_indir(dev, useraddr);
+	case ETHTOOL_GRSSH:
+		rc = ethtool_get_rxfh(dev, useraddr);
 		break;
-	case ETHTOOL_SRXFHINDIR:
-		rc = ethtool_set_rxfh_indir(dev, useraddr);
+	case ETHTOOL_SRSSH:
+		rc = ethtool_set_rxfh(dev, useraddr);
 		break;
 	case ETHTOOL_GFEATURES:
 		rc = ethtool_get_features(dev, useraddr);
-- 
1.7.1
