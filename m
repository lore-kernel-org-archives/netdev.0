From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V2 4/7] net/mlx4_en: Set max rate-limit for a TC
Date: Mon, 26 Mar 2012 11:07:51 +0200
Message-ID: <1332752874-8086-5-git-send-email-amirv@mellanox.com>
References: <1332752874-8086-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:43714 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753829Ab2CZJIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 05:08:20 -0400
In-Reply-To: <1332752874-8086-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set max rate-limit using sysfs file /sys/class/net/<interface>/ratelimit/tc<n>
Values in Mbps units.

For example, to set ratelimit of 5G to TC3 issue:
echo 5000 > /sys/class/net/eth2/ratelimit/tc3

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---

We used sysfs since max bw isn't part of the ETS / DCBX NL support, and we're
open to other suggestions to add generic support for max bw, e.g add call to
the DCBX NL API.

 drivers/net/ethernet/mellanox/mlx4/Makefile    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   13 +++
 drivers/net/ethernet/mellanox/mlx4/en_sysfs.c  |   99 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |   11 +++
 4 files changed, 124 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_sysfs.c

diff --git a/drivers/net/ethernet/mellanox/mlx4/Makefile b/drivers/net/ethernet/mellanox/mlx4/Makefile
index 293127d..8e5bd88 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx4/Makefile
@@ -7,4 +7,4 @@ obj-$(CONFIG_MLX4_EN)               += mlx4_en.o
 
 mlx4_en-y := 	en_main.o en_tx.o en_rx.o en_ethtool.o en_port.o en_cq.o \
 		en_resources.o en_netdev.o en_selftest.o
-mlx4_en-$(CONFIG_MLX4_EN_DCB) += en_dcb_nl.o
+mlx4_en-$(CONFIG_MLX4_EN_DCB) += en_dcb_nl.o en_sysfs.o
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9b456ae..f45d544 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -810,6 +810,18 @@ static void mlx4_en_restart(struct work_struct *work)
 	mutex_unlock(&mdev->state_lock);
 }
 
+static int mlx4_en_init(struct net_device *dev)
+{
+#ifdef CONFIG_MLX4_EN_DCB
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	if (!mlx4_is_slave(priv->mdev->dev))
+		mlx4_en_prepare_sysfs_group(priv);
+#endif
+
+	return 0;
+}
+
 static void mlx4_en_clear_stats(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -1026,6 +1038,7 @@ static int mlx4_en_set_features(struct net_device *netdev,
 }
 
 static const struct net_device_ops mlx4_netdev_ops = {
+	.ndo_init		= mlx4_en_init,
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
 	.ndo_start_xmit		= mlx4_en_xmit,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_sysfs.c b/drivers/net/ethernet/mellanox/mlx4/en_sysfs.c
new file mode 100644
index 0000000..f633f61
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/en_sysfs.c
@@ -0,0 +1,99 @@
+/*
+ * Copyright (c) 2011 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/device.h>
+#include <linux/netdevice.h>
+
+#include "mlx4_en.h"
+
+#define to_en_ratelimit_attr(x) container_of(x, struct en_ratelimit_attr, attr)
+static ssize_t mlx4_en_show_ratelimit(struct device *dev,
+			  struct device_attribute *attr,
+			  char *buf)
+{
+	struct en_ratelimit_attr *a = to_en_ratelimit_attr(attr);
+	struct mlx4_en_priv *priv = a->priv;
+	int tc = a->tc;
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", priv->ratelimit[tc]);
+}
+
+static ssize_t mlx4_en_store_ratelimit(struct device *d,
+					  struct device_attribute *attr,
+					  const char *buf, size_t size)
+{
+	struct en_ratelimit_attr *a = to_en_ratelimit_attr(attr);
+	struct mlx4_en_priv *priv = a->priv;
+	int tc = a->tc;
+	u16 ratelimit[IEEE_8021QAZ_MAX_TCS];
+	int ret;
+
+	memcpy(ratelimit, priv->ratelimit, sizeof(ratelimit));
+
+	ret = kstrtou16(buf, 0, &ratelimit[tc]);
+	if (ret)
+		return ret;
+
+	ret = mlx4_en_config_port_scheduler(priv, NULL, ratelimit);
+	if (ret)
+		return ret;
+
+	priv->ratelimit[tc] = ratelimit[tc];
+
+	return size;
+}
+
+void mlx4_en_prepare_sysfs_group(struct mlx4_en_priv *priv)
+{
+	static char *dev_attr_tcs_name[] = { "tc0", "tc1", "tc2", "tc3", "tc4",
+		"tc5", "tc6", "tc7"};
+	int i;
+
+	priv->ratelimit_group.name = "ratelimit",
+	priv->ratelimit_group.attrs =
+		(struct attribute **)priv->ratelimit_attrs_p;
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		struct en_ratelimit_attr *dev_attr = &priv->ratelimit_attrs[i];
+
+		dev_attr->attr.attr.name = dev_attr_tcs_name[i];
+		dev_attr->attr.attr.mode = S_IRUGO | S_IWUSR;
+		dev_attr->attr.show = mlx4_en_show_ratelimit;
+		dev_attr->attr.store = mlx4_en_store_ratelimit;
+		dev_attr->priv = priv;
+		dev_attr->tc = i;
+
+		priv->ratelimit_attrs_p[i] = dev_attr;
+	}
+
+	priv->dev->sysfs_groups[0] = &priv->ratelimit_group;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index cc30677..7c32973 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -421,6 +421,12 @@ struct mlx4_en_frag_info {
 
 #define MLX4_EN_TC_ETS 7
 
+struct en_ratelimit_attr {
+	struct device_attribute attr;
+	struct mlx4_en_priv *priv;
+	int tc;
+};
+
 #endif
 
 struct mlx4_en_priv {
@@ -499,6 +505,10 @@ struct mlx4_en_priv {
 
 #ifdef CONFIG_MLX4_EN_DCB
 	struct ieee_ets *mlx4_en_ieee_ets;
+	u16 ratelimit[IEEE_8021QAZ_MAX_TCS];
+	struct attribute_group ratelimit_group;
+	struct en_ratelimit_attr ratelimit_attrs[IEEE_8021QAZ_MAX_TCS];
+	struct en_ratelimit_attr *ratelimit_attrs_p[IEEE_8021QAZ_MAX_TCS + 1];
 #endif
 };
 
@@ -578,6 +588,7 @@ int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
 extern const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops;
 int mlx4_en_config_port_scheduler(struct mlx4_en_priv *priv,
 		struct ieee_ets *ets, u16 *ratelimit);
+void mlx4_en_prepare_sysfs_group(struct mlx4_en_priv *priv);
 #endif
 
 #define MLX4_EN_NUM_SELF_TEST	5
-- 
1.7.8.2
