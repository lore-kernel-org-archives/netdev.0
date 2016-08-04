From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 2/2] net: core: ethtool: add ringparam perqueue command
Date: Fri,  5 Aug 2016 00:11:53 +0300
Message-ID: <1470345113-804-5-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470345113-804-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
	linux-kernel@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470345113-804-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It useful feature to be able to configure number of buffers for
every queue.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 include/linux/ethtool.h |   4 ++
 net/core/ethtool.c      | 104 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 108 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 7e64c17..7109736 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -372,6 +372,10 @@ struct ethtool_ops {
 					  struct ethtool_coalesce *);
 	int	(*get_per_queue_bandwidth)(struct net_device *, u32, int *);
 	int	(*set_per_queue_bandwidth)(struct net_device *, u32, int);
+	int	(*get_per_queue_ringparam)(struct net_device *, u32,
+					   struct ethtool_ringparam *);
+	int	(*set_per_queue_ringparam)(struct net_device *, u32,
+					   struct ethtool_ringparam *);
 	int	(*get_link_ksettings)(struct net_device *,
 				      struct ethtool_link_ksettings *);
 	int	(*set_link_ksettings)(struct net_device *,
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f31d539..42a7cb3 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2347,6 +2347,104 @@ static int ethtool_get_per_queue_coalesce(struct net_device *dev,
 }
 
 static int
+ethtool_get_per_queue_ringparam(struct net_device *dev,
+				void __user *useraddr,
+				struct ethtool_per_queue_op *per_queue_opt)
+{
+	u32 bit;
+	int ret;
+	DECLARE_BITMAP(queue_mask, MAX_NUM_QUEUE);
+
+	if (!dev->ethtool_ops->get_per_queue_ringparam)
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
+		struct ethtool_ringparam
+			ringparam = { .cmd = ETHTOOL_GRINGPARAM };
+
+		ret = dev->ethtool_ops->get_per_queue_ringparam(dev, bit,
+								&ringparam);
+		if (ret != 0)
+			return ret;
+		if (copy_to_user(useraddr, &ringparam, sizeof(ringparam)))
+			return -EFAULT;
+		useraddr += sizeof(ringparam);
+	}
+
+	return 0;
+}
+
+static int
+ethtool_set_per_queue_ringparam(struct net_device *dev,
+				void __user *useraddr,
+				struct ethtool_per_queue_op *per_queue_opt)
+{
+	struct ethtool_ringparam *backup = NULL, *tmp = NULL;
+	DECLARE_BITMAP(queue_mask, MAX_NUM_QUEUE);
+	int i, ret = 0;
+	int n_queue;
+	u32 bit;
+
+	if ((!dev->ethtool_ops->set_per_queue_ringparam) ||
+	    (!dev->ethtool_ops->get_per_queue_ringparam))
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
+		struct ethtool_ringparam
+			ringparam = { .cmd = ETHTOOL_SRINGPARAM };
+
+		ret = dev->ethtool_ops->get_per_queue_ringparam(dev, bit, tmp);
+		if (ret != 0)
+			goto roll_back;
+
+		tmp++;
+
+		if (copy_from_user(&ringparam, useraddr, sizeof(ringparam))) {
+			ret = -EFAULT;
+			goto roll_back;
+		}
+
+		ret = dev->ethtool_ops->set_per_queue_ringparam(dev, bit,
+								&ringparam);
+		if (ret != 0)
+			goto roll_back;
+
+		useraddr += sizeof(ringparam);
+	}
+
+roll_back:
+	if (ret != 0) {
+		tmp = backup;
+		for_each_set_bit(i, queue_mask, bit) {
+			dev->ethtool_ops->set_per_queue_ringparam(dev, i, tmp);
+			tmp++;
+		}
+	}
+	kfree(backup);
+
+	return ret;
+}
+
+static int
 ethtool_get_per_queue_bandwidth(struct net_device *dev,
 				void __user *useraddr,
 				struct ethtool_per_queue_op *per_queue_opt)
@@ -2509,6 +2607,12 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	switch (per_queue_opt.sub_command) {
+	case ETHTOOL_GRINGPARAM:
+		return ethtool_get_per_queue_ringparam(dev, useraddr,
+						       &per_queue_opt);
+	case ETHTOOL_SRINGPARAM:
+		return ethtool_set_per_queue_ringparam(dev, useraddr,
+						       &per_queue_opt);
 	case ETHTOOL_GCOALESCE:
 		return ethtool_get_per_queue_coalesce(dev, useraddr, &per_queue_opt);
 	case ETHTOOL_SCOALESCE:
-- 
1.9.1
