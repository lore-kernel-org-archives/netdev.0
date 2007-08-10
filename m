From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH][RFC] ethtool flags
Date: Fri, 10 Aug 2007 05:32:58 -0400
Message-ID: <20070810093258.GA26983@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:50553 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760059AbXHJJc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 05:32:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


NOTE 1: note the code comments about read-only flag behavior

NOTE 2: I ignored driver-private flags for the moment
	(these were mentioned in the previous email)

NOTE 3: ethtool_op_xxx implementation will probably change a bit,
	as we see what drivers really need.

NOTE 4: the userland interface (ethtool(8)) will refer to flags by name,
	not by bit number.  As we see with msg_enable, bitmap math on
	the command line is a pain.

commit 3216337d7a6938df5b11935da5ee0045b0535d96
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Aug 10 05:27:23 2007 -0400

    [ETHTOOL] Add ETHTOOL_[GS]FLAGS sub-ioctls
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 include/linux/ethtool.h   |   21 +++++++++++++++
 include/linux/netdevice.h |    1 
 net/core/ethtool.c        |   61 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+)

3216337d7a6938df5b11935da5ee0045b0535d96
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 23ccea8..0e5de2f 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -256,6 +256,19 @@ struct ethtool_perm_addr {
 	__u8	data[0];
 };
 
+/* boolean flags controlling per-interface behavior characteristics.
+ * When reading, the flag indicates whether or not a certain behavior
+ * is enabled/present.  When writing, the flag indicates whether
+ * or not the driver should turn on (set) or off (clear) a behavior.
+ *
+ * Some behaviors may read-only (unconditionally absent or present).
+ * If such is the case, return EINVAL in the set-flags operation if the
+ * flag differs from the read-only value.
+ */
+enum ethtool_flags {
+	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
+};
+
 #ifdef __KERNEL__
 
 struct net_device;
@@ -272,6 +285,8 @@ u32 ethtool_op_get_tso(struct net_device *dev);
 int ethtool_op_set_tso(struct net_device *dev, u32 data);
 u32 ethtool_op_get_ufo(struct net_device *dev);
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
+u32 ethtool_op_get_flags(struct net_device *dev);
+int ethtool_op_set_flags(struct net_device *dev, u32 data);
 
 /**
  * &ethtool_ops - Alter and report network device settings
@@ -307,6 +322,8 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data);
  * get_strings: Return a set of strings that describe the requested objects 
  * phys_id: Identify the device
  * get_stats: Return statistics about the device
+ * get_flags: get 32-bit flags bitmap
+ * set_flags: set 32-bit flags bitmap
  * 
  * Description:
  *
@@ -369,6 +386,8 @@ struct ethtool_ops {
 	void	(*complete)(struct net_device *);
 	u32     (*get_ufo)(struct net_device *);
 	int     (*set_ufo)(struct net_device *, u32);
+	u32     (*get_flags)(struct net_device *);
+	int     (*set_flags)(struct net_device *, u32);
 };
 #endif /* __KERNEL__ */
 
@@ -410,6 +429,8 @@ struct ethtool_ops {
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
 #define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
+#define ETHTOOL_GFLAGS		0x00000025 /* Get flags bitmap(ethtool_value) */
+#define ETHTOOL_SFLAGS		0x00000026 /* Set flags bitmap(ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a616d7..559a4dc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -341,6 +341,7 @@ struct net_device
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
+#define NETIF_F_LRO		32768	/* large receive offload */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 2ab0a60..6e8563e 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -109,6 +109,32 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data)
 	return 0;
 }
 
+/* the following list of flags are the same as their associated
+ * NETIF_F_xxx values in include/linux/netdevice.h
+ */
+static const u32 flags_dup_features =
+	ETH_FLAG_LRO;
+
+u32 ethtool_op_get_flags(struct net_device *dev)
+{
+	/* in the future, this function will probably contain additional
+	 * handling for flags which are not so easily handled
+	 * by a simple masking operation
+	 */
+	
+	return dev->features & flags_dup_features;
+}
+
+int ethtool_op_set_flags(struct net_device *dev, u32 data)
+{
+	if (data & ETH_FLAG_LRO)
+		dev->features |= NETIF_F_LRO;
+	else
+		dev->features &= ~NETIF_F_LRO;
+
+	return 0;
+}
+
 /* Handlers for each ethtool command */
 
 static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
@@ -783,6 +809,33 @@ static int ethtool_get_perm_addr(struct net_device *dev, void __user *useraddr)
 	return 0;
 }
 
+static int ethtool_get_flags(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GFLAGS };
+
+	if (!dev->ethtool_ops->get_flags)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->ethtool_ops->get_flags(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_flags(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->set_flags)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_flags(dev, edata.data);
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct ifreq *ifr)
@@ -935,6 +988,12 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_SGSO:
 		rc = ethtool_set_gso(dev, useraddr);
 		break;
+	case ETHTOOL_GFLAGS:
+		rc = ethtool_get_flags(dev, useraddr);
+		break;
+	case ETHTOOL_SFLAGS:
+		rc = ethtool_set_flags(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
@@ -960,3 +1019,5 @@ EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
 EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
 EXPORT_SYMBOL(ethtool_op_set_ufo);
 EXPORT_SYMBOL(ethtool_op_get_ufo);
+EXPORT_SYMBOL(ethtool_op_set_flags);
+EXPORT_SYMBOL(ethtool_op_get_flags);
