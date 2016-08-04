From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 1/2] net: core: ethtool: add per queue bandwidth command
Date: Fri,  5 Aug 2016 00:11:50 +0300
Message-ID: <1470345113-804-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470345113-804-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
	linux-kernel@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470345113-804-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 include/linux/ethtool.h      |   4 ++
 include/uapi/linux/ethtool.h |   2 +
 net/core/ethtool.c           | 102 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 108 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9ded8c6..7e64c17 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -273,6 +273,8 @@ bool ethtool_convert_link_mode_to_legacy_u32(u32 *legacy_u32,
  *	a TX queue has this number, return -EINVAL. If only a RX queue or a TX
  *	queue has this number, ignore the inapplicable fields.
  *	Returns a negative error code or zero.
+ * @get_per_queue_bandwidth: get per-queue bandwidth
+ * @set_per_queue_bandwidth: set per-queue bandwidth
  * @get_link_ksettings: When defined, takes precedence over the
  *	%get_settings method. Get various device settings
  *	including Ethernet link settings. The %cmd and
@@ -368,6 +370,8 @@ struct ethtool_ops {
 					  struct ethtool_coalesce *);
 	int	(*set_per_queue_coalesce)(struct net_device *, u32,
 					  struct ethtool_coalesce *);
+	int	(*get_per_queue_bandwidth)(struct net_device *, u32, int *);
+	int	(*set_per_queue_bandwidth)(struct net_device *, u32, int);
 	int	(*get_link_ksettings)(struct net_device *,
 				      struct ethtool_link_ksettings *);
 	int	(*set_link_ksettings)(struct net_device *,
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index b8f38e8..0fcfe9e 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1314,6 +1314,8 @@ struct ethtool_per_queue_op {
 
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
+#define ETHTOOL_GBANDWIDTH	0x0000004e /* Get ethtool per queue bandwidth */
+#define ETHTOOL_SBANDWIDTH	0x0000004f /* Set ethtool per queue bandwidth */
 
 
 /* compatibility with older code */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9774898..f31d539 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2346,6 +2346,102 @@ static int ethtool_get_per_queue_coalesce(struct net_device *dev,
 	return 0;
 }
 
+static int
+ethtool_get_per_queue_bandwidth(struct net_device *dev,
+				void __user *useraddr,
+				struct ethtool_per_queue_op *per_queue_opt)
+{
+	u32 bit;
+	int ret;
+	DECLARE_BITMAP(queue_mask, MAX_NUM_QUEUE);
+
+	if (!dev->ethtool_ops->get_per_queue_bandwidth)
+		return -EOPNOTSUPP;
+
+	useraddr += sizeof(*per_queue_opt);
+
+	bitmap_from_u32array(queue_mask,
+			     MAX_NUM_QUEUE,
+			     per_queue_opt->queue_mask,
+			     DIV_ROUND_UP(MAX_NUM_QUEUE, 32));
+
+	for_each_set_bit(bit, queue_mask, MAX_NUM_QUEUE) {
+		int bandwidth;
+
+		ret = dev->ethtool_ops->get_per_queue_bandwidth(dev, bit,
+								&bandwidth);
+		if (ret != 0)
+			return ret;
+		if (copy_to_user(useraddr, &bandwidth, sizeof(bandwidth)))
+			return -EFAULT;
+		useraddr += sizeof(bandwidth);
+	}
+
+	return 0;
+}
+
+static int
+ethtool_set_per_queue_bandwidth(struct net_device *dev,
+				void __user *useraddr,
+				struct ethtool_per_queue_op *per_queue_opt)
+{
+	u32 bit;
+	int n_queue;
+	int i, ret = 0;
+	int *backup = NULL, *tmp = NULL;
+	DECLARE_BITMAP(queue_mask, MAX_NUM_QUEUE);
+
+	if ((!dev->ethtool_ops->set_per_queue_bandwidth) ||
+	    (!dev->ethtool_ops->get_per_queue_bandwidth))
+		return -EOPNOTSUPP;
+
+	useraddr += sizeof(*per_queue_opt);
+
+	bitmap_from_u32array(queue_mask,
+			     MAX_NUM_QUEUE,
+			     per_queue_opt->queue_mask,
+			     DIV_ROUND_UP(MAX_NUM_QUEUE, 32));
+	n_queue = bitmap_weight(queue_mask, MAX_NUM_QUEUE);
+	tmp = kmalloc_array(n_queue, sizeof(*backup), GFP_KERNEL);
+	if (!tmp)
+		return -ENOMEM;
+	backup = tmp;
+
+	for_each_set_bit(bit, queue_mask, MAX_NUM_QUEUE) {
+		int bandwidth;
+
+		ret = dev->ethtool_ops->get_per_queue_bandwidth(dev, bit, tmp);
+		if (ret != 0)
+			goto roll_back;
+
+		tmp++;
+
+		if (copy_from_user(&bandwidth, useraddr, sizeof(bandwidth))) {
+			ret = -EFAULT;
+			goto roll_back;
+		}
+
+		ret = dev->ethtool_ops->set_per_queue_bandwidth(dev, bit,
+								bandwidth);
+		if (ret != 0)
+			goto roll_back;
+
+		useraddr += sizeof(bandwidth);
+	}
+
+roll_back:
+	if (ret != 0) {
+		tmp = backup;
+		for_each_set_bit(i, queue_mask, bit) {
+			dev->ethtool_ops->set_per_queue_bandwidth(dev, i, *tmp);
+			tmp++;
+		}
+	}
+	kfree(backup);
+
+	return ret;
+}
+
 static int ethtool_set_per_queue_coalesce(struct net_device *dev,
 					  void __user *useraddr,
 					  struct ethtool_per_queue_op *per_queue_opt)
@@ -2417,6 +2513,12 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 		return ethtool_get_per_queue_coalesce(dev, useraddr, &per_queue_opt);
 	case ETHTOOL_SCOALESCE:
 		return ethtool_set_per_queue_coalesce(dev, useraddr, &per_queue_opt);
+	case ETHTOOL_GBANDWIDTH:
+		return ethtool_get_per_queue_bandwidth(dev, useraddr,
+						       &per_queue_opt);
+	case ETHTOOL_SBANDWIDTH:
+		return ethtool_set_per_queue_bandwidth(dev, useraddr,
+						       &per_queue_opt);
 	default:
 		return -EOPNOTSUPP;
 	};
-- 
1.9.1
