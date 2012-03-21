From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V1 4/6] net/mlx4_en: Set max rate-limit for a TC
Date: Wed, 21 Mar 2012 11:25:01 +0200
Message-ID: <1332321903-11704-5-git-send-email-amirv@mellanox.com>
References: <1332321903-11704-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:56119 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756849Ab2CUJZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 05:25:37 -0400
In-Reply-To: <1332321903-11704-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Set max rate-limit using sysfs file /sys/class/net/<interface>/qos/ratelimit

To set, enter a space separated list of values in units of 100Mbps.  For
example to set ratelimit of 5G to TC0 and 10G for the reset on eth2 issue:
echo 50 100 100 100 100 100 100 100 100 > /sys/class/net/eth2/qos/ratelimit

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---

We used sysfs since max bw isn't part of the ETS / DCBX NL support, and we're
open to other suggestions to add generic support for max bw, e.g add call to
the DCBX NL API.

 drivers/net/ethernet/mellanox/mlx4/Makefile    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |   14 +++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   13 +++
 drivers/net/ethernet/mellanox/mlx4/en_sysfs.c  |  120 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    5 +
 5 files changed, 152 insertions(+), 2 deletions(-)
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
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 24ca87c..eb0964f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -126,7 +126,7 @@ mlx4_en_dcbnl_ieee_setets(struct net_device *dev, struct ieee_ets *ets)
 		return err;
 
 	err = mlx4_SET_PORT_SCHEDULER(mdev->dev, priv->port, tc_tx_bw, pg,
-			NULL);
+			priv->ratelimit);
 	if (err)
 		return err;
 
@@ -192,6 +192,18 @@ static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	return 0;
 }
 
+int mlx4_en_dcbnl_set_ratelimit(struct mlx4_en_priv *priv, u16 *ratelimit)
+{
+	memcpy(priv->ratelimit, ratelimit, sizeof(priv->ratelimit));
+
+	if (mlx4_en_dcbnl_ieee_setets(priv->dev, NULL)) {
+		en_err(priv, "Error setting ets in HW\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
 	.ieee_getets	= mlx4_en_dcbnl_ieee_getets,
 	.ieee_setets	= mlx4_en_dcbnl_ieee_setets,
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
index 0000000..fdada20
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/en_sysfs.c
@@ -0,0 +1,120 @@
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
+#define to_en_priv(cd)	((struct mlx4_en_priv *)(netdev_priv(to_net_dev(cd))))
+
+static ssize_t mlx4_en_show_ratelimit(struct device *d,
+					 struct device_attribute *attr,
+					 char *buf)
+{
+	struct mlx4_en_priv *priv = to_en_priv(d);
+	int i;
+	int len = 0;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		len += sprintf(buf + len,  "%d ", priv->ratelimit[i]);
+	len += sprintf(buf + len, "\n");
+
+	return len;
+}
+
+static ssize_t mlx4_en_store_ratelimit(struct device *d,
+					  struct device_attribute *attr,
+					  const char *buf, size_t count)
+{
+	int ret = count;
+	struct mlx4_en_priv *priv = to_en_priv(d);
+	char save;
+	int i = 0;
+	u16 ratelimit[IEEE_8021QAZ_MAX_TCS] = { 0 };
+
+	do {
+		int len;
+		int new_value;
+
+		if (i >= IEEE_8021QAZ_MAX_TCS)
+			goto bad_elem_count;
+
+		len = strcspn(buf, " ");
+
+		/* nul-terminate and parse */
+		save = buf[len];
+		((char *)buf)[len] = '\0';
+
+		if (sscanf(buf, "%d", &new_value) != 1 ||
+				new_value > 100 || new_value < 0) {
+			en_err(priv, "bad ratelimit value: '%s'\n", buf);
+			ret = -EINVAL;
+			goto out;
+		}
+		ratelimit[i] = new_value;
+
+		buf += len+1;
+		i++;
+	} while (save == ' ');
+
+	if (i != IEEE_8021QAZ_MAX_TCS)
+		goto bad_elem_count;
+
+	mlx4_en_dcbnl_set_ratelimit(priv, &ratelimit[0]);
+
+out:
+	return ret;
+
+bad_elem_count:
+	en_err(priv, "bad number of elemets in ratelimit array\n");
+	return -EINVAL;
+}
+
+static DEVICE_ATTR(ratelimit, S_IRUGO | S_IWUSR,
+		   mlx4_en_show_ratelimit, mlx4_en_store_ratelimit);
+
+static struct attribute *mlx4_en_qos_attrs[] = {
+	&dev_attr_ratelimit.attr,
+	NULL,
+};
+
+static struct attribute_group qos_group = {
+	.name = "qos",
+	.attrs = mlx4_en_qos_attrs,
+};
+
+void mlx4_en_prepare_sysfs_group(struct mlx4_en_priv *priv)
+{
+	priv->dev->sysfs_groups[0] = &qos_group;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index fa09792..32b447d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -499,6 +499,7 @@ struct mlx4_en_priv {
 
 #ifdef CONFIG_MLX4_EN_DCB
 	struct ieee_ets *mlx4_en_ieee_ets;
+	u16 ratelimit[IEEE_8021QAZ_MAX_TCS];
 #endif
 };
 
@@ -576,6 +577,10 @@ int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
 
 #ifdef CONFIG_MLX4_EN_DCB
 extern const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops;
+
+void mlx4_en_prepare_sysfs_group(struct mlx4_en_priv *priv);
+
+int mlx4_en_dcbnl_set_ratelimit(struct mlx4_en_priv *priv, u16 *ratelimit);
 #endif
 
 #define MLX4_EN_NUM_SELF_TEST	5
-- 
1.7.8.2
