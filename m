From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 05/18] net/mlx4: New file for QoS related firmware commands
Date: Thu,  2 Apr 2015 16:31:10 +0300
Message-ID: <1427981483-19317-6-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45681 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752785AbbDBNb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:31:59 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Create two new files fw_qos.h and fw_qos.c in mlx4_core module.

It gathers all relevant QoS firmware related commands etc, thus improving
encapsulation of the mlx4_core module. For now it contains the QoS existing
commands: mlx4_SET_PORT_SCHEDULER and mlx4_SET_PORT_PRIO2TC.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/Makefile    |    5 +-
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |    1 +
 drivers/net/ethernet/mellanox/mlx4/fw_qos.c    |  125 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw_qos.h    |   75 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |   15 ---
 drivers/net/ethernet/mellanox/mlx4/port.c      |   71 -------------
 include/linux/mlx4/device.h                    |    5 -
 7 files changed, 204 insertions(+), 93 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/fw_qos.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/fw_qos.h

diff --git a/drivers/net/ethernet/mellanox/mlx4/Makefile b/drivers/net/ethernet/mellanox/mlx4/Makefile
index 3e9c70f..c82217e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx4/Makefile
@@ -1,7 +1,8 @@
 obj-$(CONFIG_MLX4_CORE)		+= mlx4_core.o
 
-mlx4_core-y :=	alloc.o catas.o cmd.o cq.o eq.o fw.o icm.o intf.o main.o mcg.o \
-		mr.o pd.o port.o profile.o qp.o reset.o sense.o srq.o resource_tracker.o
+mlx4_core-y :=	alloc.o catas.o cmd.o cq.o eq.o fw.o fw_qos.o icm.o intf.o \
+		main.o mcg.o mr.o pd.o port.o profile.o qp.o reset.o sense.o \
+		srq.o resource_tracker.o
 
 obj-$(CONFIG_MLX4_EN)               += mlx4_en.o
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 8e3260c..f01918c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -35,6 +35,7 @@
 #include <linux/math64.h>
 
 #include "mlx4_en.h"
+#include "fw_qos.h"
 
 /* Definitions for QCN
  */
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw_qos.c b/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
new file mode 100644
index 0000000..0f5af7c
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
@@ -0,0 +1,125 @@
+/*
+ * Copyright (c) 2004, 2005 Topspin Communications.  All rights reserved.
+ * Copyright (c) 2005, 2006, 2007, 2008 Mellanox Technologies.
+ * All rights reserved.
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
+ */
+
+#include <linux/export.h>
+#include "fw_qos.h"
+
+struct mlx4_set_port_prio2tc_context {
+	u8 prio2tc[4];
+};
+
+struct mlx4_port_scheduler_tc_cfg_be {
+	__be16 pg;
+	__be16 bw_precentage;
+	__be16 max_bw_units; /* 3-100Mbps, 4-1Gbps, other values - reserved */
+	__be16 max_bw_value;
+};
+
+struct mlx4_set_port_scheduler_context {
+	struct mlx4_port_scheduler_tc_cfg_be tc[MLX4_NUM_TC];
+};
+
+int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_prio2tc_context *context;
+	int err;
+	u32 in_mod;
+	int i;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	context = mailbox->buf;
+
+	for (i = 0; i < MLX4_NUM_UP; i += 2)
+		context->prio2tc[i >> 1] = prio2tc[i] << 4 | prio2tc[i + 1];
+
+	in_mod = MLX4_SET_PORT_PRIO2TC << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_PRIO2TC);
+
+int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
+			    u8 *pg, u16 *ratelimit)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_scheduler_context *context;
+	int err;
+	u32 in_mod;
+	int i;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	context = mailbox->buf;
+
+	for (i = 0; i < MLX4_NUM_TC; i++) {
+		struct mlx4_port_scheduler_tc_cfg_be *tc = &context->tc[i];
+		u16 r;
+
+		if (ratelimit && ratelimit[i]) {
+			if (ratelimit[i] <= MLX4_MAX_100M_UNITS_VAL) {
+				r = ratelimit[i];
+				tc->max_bw_units =
+					htons(MLX4_RATELIMIT_100M_UNITS);
+			} else {
+				r = ratelimit[i] / 10;
+				tc->max_bw_units =
+					htons(MLX4_RATELIMIT_1G_UNITS);
+			}
+			tc->max_bw_value = htons(r);
+		} else {
+			tc->max_bw_value = htons(MLX4_RATELIMIT_DEFAULT);
+			tc->max_bw_units = htons(MLX4_RATELIMIT_1G_UNITS);
+		}
+
+		tc->pg = htons(pg[i]);
+		tc->bw_precentage = htons(tc_tx_bw[i]);
+	}
+
+	in_mod = MLX4_SET_PORT_SCHEDULER << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_SCHEDULER);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
new file mode 100644
index 0000000..ab9be0f
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
@@ -0,0 +1,75 @@
+/*
+ * Copyright (c) 2004, 2005 Topspin Communications.  All rights reserved.
+ * Copyright (c) 2005, 2006, 2007, 2008 Mellanox Technologies.
+ * All rights reserved.
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
+ */
+
+#ifndef MLX4_FW_QOS_H
+#define MLX4_FW_QOS_H
+
+#include <linux/mlx4/cmd.h>
+#include <linux/mlx4/device.h>
+
+#define MLX4_NUM_UP 8
+#define MLX4_NUM_TC 8
+
+/**
+ * mlx4_SET_PORT_PRIO2TC - This routine maps user priorities to traffic
+ * classes of a given port and device.
+ *
+ * @dev: mlx4_dev.
+ * @port: Physical port number.
+ * @prio2tc: Array of TC associated with each priorities.
+ *
+ * Returns 0 on success or a negative mlx4_core errno code.
+ **/
+int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc);
+
+/**
+ * mlx4_SET_PORT_SCHEDULER - This routine configures the arbitration between
+ * traffic classes (ETS) and configured rate limit for traffic classes.
+ * tc_tx_bw, pg and ratelimit are arrays where each index represents a TC.
+ * The description for those parameters below refers to a single TC.
+ *
+ * @dev: mlx4_dev.
+ * @port: Physical port number.
+ * @tc_tx_bw: The percentage of the bandwidth allocated for traffic class
+ *  within a TC group. The sum of the bw_percentage of all the traffic
+ *  classes within a TC group must equal 100% for correct operation.
+ * @pg: The TC group the traffic class is associated with.
+ * @ratelimit: The maximal bandwidth allowed for the use by this traffic class.
+ *
+ * Returns 0 on success or a negative mlx4_core errno code.
+ **/
+int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
+			    u8 *pg, u16 *ratelimit);
+
+#endif /* MLX4_FW_QOS_H */
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 0b16db0..9e5236b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -64,21 +64,6 @@
 
 #define INIT_HCA_TPT_MW_ENABLE          (1 << 7)
 
-struct mlx4_set_port_prio2tc_context {
-	u8 prio2tc[4];
-};
-
-struct mlx4_port_scheduler_tc_cfg_be {
-	__be16 pg;
-	__be16 bw_precentage;
-	__be16 max_bw_units; /* 3-100Mbps, 4-1Gbps, other values - reserved */
-	__be16 max_bw_value;
-};
-
-struct mlx4_set_port_scheduler_context {
-	struct mlx4_port_scheduler_tc_cfg_be tc[MLX4_NUM_TC];
-};
-
 enum {
 	MLX4_HCR_BASE		= 0x80680,
 	MLX4_HCR_SIZE		= 0x0001c,
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index b97f173..6a53d42 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -1016,77 +1016,6 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 }
 EXPORT_SYMBOL(mlx4_SET_PORT_qpn_calc);
 
-int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	struct mlx4_set_port_prio2tc_context *context;
-	int err;
-	u32 in_mod;
-	int i;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-	context = mailbox->buf;
-	for (i = 0; i < MLX4_NUM_UP; i += 2)
-		context->prio2tc[i >> 1] = prio2tc[i] << 4 | prio2tc[i + 1];
-
-	in_mod = MLX4_SET_PORT_PRIO2TC << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
-
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
-}
-EXPORT_SYMBOL(mlx4_SET_PORT_PRIO2TC);
-
-int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
-		u8 *pg, u16 *ratelimit)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	struct mlx4_set_port_scheduler_context *context;
-	int err;
-	u32 in_mod;
-	int i;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-	context = mailbox->buf;
-
-	for (i = 0; i < MLX4_NUM_TC; i++) {
-		struct mlx4_port_scheduler_tc_cfg_be *tc = &context->tc[i];
-		u16 r;
-
-		if (ratelimit && ratelimit[i]) {
-			if (ratelimit[i] <= MLX4_MAX_100M_UNITS_VAL) {
-				r = ratelimit[i];
-				tc->max_bw_units =
-					htons(MLX4_RATELIMIT_100M_UNITS);
-			} else {
-				r = ratelimit[i]/10;
-				tc->max_bw_units =
-					htons(MLX4_RATELIMIT_1G_UNITS);
-			}
-			tc->max_bw_value = htons(r);
-		} else {
-			tc->max_bw_value = htons(MLX4_RATELIMIT_DEFAULT);
-			tc->max_bw_units = htons(MLX4_RATELIMIT_1G_UNITS);
-		}
-
-		tc->pg = htons(pg[i]);
-		tc->bw_precentage = htons(tc_tx_bw[i]);
-	}
-
-	in_mod = MLX4_SET_PORT_SCHEDULER << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
-
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
-}
-EXPORT_SYMBOL(mlx4_SET_PORT_SCHEDULER);
-
 enum {
 	VXLAN_ENABLE_MODIFY	= 1 << 7,
 	VXLAN_STEERING_MODIFY	= 1 << 6,
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 0f7f13d..b676d0c 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -49,8 +49,6 @@
 #define MSIX_LEGACY_SZ		4
 #define MIN_MSIX_P_PORT		5
 
-#define MLX4_NUM_UP			8
-#define MLX4_NUM_TC			8
 #define MLX4_MAX_100M_UNITS_VAL		255	/*
 						 * work around: can't set values
 						 * greater then this value when
@@ -1311,9 +1309,6 @@ int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
 int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 			   u8 promisc);
-int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc);
-int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
-		u8 *pg, u16 *ratelimit);
 int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering, int enable);
 int mlx4_find_cached_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *idx);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
-- 
1.7.1
