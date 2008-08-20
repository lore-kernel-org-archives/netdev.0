From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [Patch RFC 05/10 v2] mlx4_en: en_port
Date: Wed, 20 Aug 2008 16:00:36 +0300
Message-ID: <48AC1574.7070500@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liran Liss <liranl@mellanox.co.il>,
	tziporet@mellanox.co.il, Roland Dreier <rdreier@cisco.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49087 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754166AbYHTNBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 09:01:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 18 Aug 2008 11:35:27 +0300
Subject: [PATCH] mlx4_en: en_port

These files implement port commands: Firmware commands ment to
set port configuration or query for its state.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_port.c |  235 ++++++++++++++++++
 drivers/net/mlx4/en_port.h |  586 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 821 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/mlx4/en_port.c
 create mode 100644 drivers/net/mlx4/en_port.h

diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
new file mode 100644
index 0000000..b55e3a0
--- /dev/null
+++ b/drivers/net/mlx4/en_port.c
@@ -0,0 +1,235 @@
+/*
+ * Copyright (c) 2007 Mellanox Technologies. All rights reserved.
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
+
+#include <linux/if_vlan.h>
+
+#include <linux/mlx4/device.h>
+#include <linux/mlx4/cmd.h>
+
+#include "en_port.h"
+#include "mlx4_en.h"
+
+
+int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
+			u64 mac, u64 clear, u8 mode)
+{
+	return mlx4_cmd(dev, (mac | (clear << 63)), port, mode,
+			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B);
+}
+
+int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_vlan_fltr_mbox *filter;
+	int i;
+	int j;
+	int index = 0;
+	u32 entry;
+	int err = 0;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	filter = mailbox->buf;
+	if (grp) {
+		memset(filter, 0, sizeof *filter);
+		for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
+			entry = 0;
+			for (j = 0; j < 32; j++)
+				if (vlan_group_get_device(grp, index++))
+					entry |= 1 << j;
+			filter->entry[i] = cpu_to_be32(entry);
+		}
+	} else {
+		/* When no vlans are configured we block all vlans */
+		memset(filter, 0, sizeof(*filter));
+	}
+	err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_VLAN_FLTR,
+		       MLX4_CMD_TIME_CLASS_B);
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+
+int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
+			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_general_context *context;
+	int err;
+	u32 in_mod;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	memset(context, 0, sizeof *context);
+
+	context->flags = SET_PORT_GEN_ALL_VALID;
+	context->mtu = cpu_to_be16(mtu);
+	context->pptx = (pptx * (!pfctx)) << 7;
+	context->pfctx = pfctx;
+	context->pprx = (pprx * (!pfcrx)) << 7;
+	context->pfcrx = pfcrx;
+
+	in_mod = MLX4_SET_PORT_GENERAL << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
+			   u8 promisc)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_rqp_calc_context *context;
+	int err;
+	u32 in_mod;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	memset(context, 0, sizeof *context);
+
+	context->base_qpn = cpu_to_be32(base_qpn);
+	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT | base_qpn);
+	context->mcast = cpu_to_be32(1 << SET_PORT_PROMISC_SHIFT | base_qpn);
+
+	in_mod = MLX4_SET_PORT_RQP_CALC << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+
+int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
+{
+	struct mlx4_en_stat_out_mbox *mlx4_en_stats;
+	struct mlx4_en_priv *priv = netdev_priv(mdev->pndev[port]);
+	struct net_device_stats *stats = &priv->stats;
+	struct mlx4_cmd_mailbox *mailbox;
+	u64 in_mod = reset << 8 | port;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(mdev->dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	memset(mailbox->buf, 0, sizeof(*mlx4_en_stats));
+	err = mlx4_cmd_box(mdev->dev, 0, mailbox->dma, in_mod, 0,
+			   MLX4_CMD_DUMP_ETH_STATS, MLX4_CMD_TIME_CLASS_B);
+	if (err)
+		goto out;
+
+	mlx4_en_stats = mailbox->buf;
+
+	spin_lock_bh(&priv->stats_lock);
+	/* Skip packet+byte counts if we are already doing those in SW */
+	if (DO_SW_COUNTERS)
+		goto skip;
+
+	stats->rx_packets = be32_to_cpu(mlx4_en_stats->RTOTFRMS) -
+			    be32_to_cpu(mlx4_en_stats->RDROP);
+	stats->tx_packets = be64_to_cpu(mlx4_en_stats->TTOT_prio_0) +
+			    be64_to_cpu(mlx4_en_stats->TTOT_prio_1) +
+			    be64_to_cpu(mlx4_en_stats->TTOT_prio_2) +
+			    be64_to_cpu(mlx4_en_stats->TTOT_prio_3) +
+			    be64_to_cpu(mlx4_en_stats->TTOT_prio_4) +
+			    be64_to_cpu(mlx4_en_stats->TTOT_prio_5) +
+			    be64_to_cpu(mlx4_en_stats->TTOT_prio_6) +
+			    be64_to_cpu(mlx4_en_stats->TTOT_prio_7) +
+			    be64_to_cpu(mlx4_en_stats->TTOT_novlan) +
+			    be64_to_cpu(mlx4_en_stats->TTOT_loopbk);
+	stats->rx_bytes = be64_to_cpu(mlx4_en_stats->ROCT_prio_0) +
+			  be64_to_cpu(mlx4_en_stats->ROCT_prio_1) +
+			  be64_to_cpu(mlx4_en_stats->ROCT_prio_2) +
+			  be64_to_cpu(mlx4_en_stats->ROCT_prio_3) +
+			  be64_to_cpu(mlx4_en_stats->ROCT_prio_4) +
+			  be64_to_cpu(mlx4_en_stats->ROCT_prio_5) +
+			  be64_to_cpu(mlx4_en_stats->ROCT_prio_6) +
+			  be64_to_cpu(mlx4_en_stats->ROCT_prio_7) +
+			  be64_to_cpu(mlx4_en_stats->ROCT_novlan);
+
+	stats->tx_bytes = be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_0) +
+			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_1) +
+			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_2) +
+			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_3) +
+			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_4) +
+			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_5) +
+			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_6) +
+			  be64_to_cpu(mlx4_en_stats->TTTLOCT_prio_7) +
+			  be64_to_cpu(mlx4_en_stats->TTTLOCT_novlan) +
+			  be64_to_cpu(mlx4_en_stats->TTTLOCT_loopbk);
+
+skip:
+	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
+			   be32_to_cpu(mlx4_en_stats->RdropLength) +
+			   be32_to_cpu(mlx4_en_stats->RJBBR) +
+			   be32_to_cpu(mlx4_en_stats->RCRC) +
+			   be32_to_cpu(mlx4_en_stats->RRUNT);
+	stats->tx_errors = be32_to_cpu(mlx4_en_stats->TDROP);
+	stats->multicast = be64_to_cpu(mlx4_en_stats->MCAST_prio_0) +
+			   be64_to_cpu(mlx4_en_stats->MCAST_prio_1) +
+			   be64_to_cpu(mlx4_en_stats->MCAST_prio_2) +
+			   be64_to_cpu(mlx4_en_stats->MCAST_prio_3) +
+			   be64_to_cpu(mlx4_en_stats->MCAST_prio_4) +
+			   be64_to_cpu(mlx4_en_stats->MCAST_prio_5) +
+			   be64_to_cpu(mlx4_en_stats->MCAST_prio_6) +
+			   be64_to_cpu(mlx4_en_stats->MCAST_prio_7) +
+			   be64_to_cpu(mlx4_en_stats->MCAST_novlan);
+	stats->collisions = 0;
+	stats->rx_length_errors = be32_to_cpu(mlx4_en_stats->RdropLength);
+	stats->rx_over_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
+	stats->rx_crc_errors = be32_to_cpu(mlx4_en_stats->RCRC);
+	stats->rx_frame_errors = 0;
+	stats->rx_fifo_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
+	stats->rx_missed_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
+	stats->tx_aborted_errors = 0;
+	stats->tx_carrier_errors = 0;
+	stats->tx_fifo_errors = 0;
+	stats->tx_heartbeat_errors = 0;
+	stats->tx_window_errors = 0;
+	memcpy(&priv->hw_stats, mlx4_en_stats, sizeof(*mlx4_en_stats));
+	spin_unlock_bh(&priv->stats_lock);
+
+out:
+	mlx4_free_cmd_mailbox(mdev->dev, mailbox);
+	return err;
+}
+
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
new file mode 100644
index 0000000..7e8ede6
--- /dev/null
+++ b/drivers/net/mlx4/en_port.h
@@ -0,0 +1,586 @@
+/*
+ * Copyright (c) 2007 Mellanox Technologies. All rights reserved.
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
+#ifndef _MLX4_EN_PORT_H_
+#define _MLX4_EN_PORT_H_
+
+
+#define MAC_VALID_SHIFT		63
+#define VLAN_VALID_SHIFT	31
+#define VLAN_MASK		0xfff
+#define QUERY_PORT_ETH_MASK	(1 << 1)
+#define QUERY_PORT_LINK_MASK	(0x2 << 4)
+#define SET_PORT_GEN_ALL_VALID	0x7
+#define SET_PORT_PROMISC_SHIFT	31
+
+enum {
+	MLX4_CMD_SET_VLAN_FLTR  = 0x47,
+	MLX4_CMD_SET_MCAST_FLTR = 0x48,
+	MLX4_CMD_DUMP_ETH_STATS = 0x49,
+};
+
+struct mlx4_query_port_context {
+	u8 port_type;
+	u8 link_state;
+	__be16 mtu;
+	u32 reserved2[3];
+	__be64 mac;
+};
+
+struct mlx4_set_port_general_context {
+	u8 reserved[3];
+	u8 flags;
+	u16 reserved2;
+	__be16 mtu;
+	u8 pptx;
+	u8 pfctx;
+	u16 reserved3;
+	u8 pprx;
+	u8 pfcrx;
+	u16 reserved4;
+};
+
+struct mlx4_set_port_rqp_calc_context {
+	__be32 base_qpn;
+	__be32 flags;
+	u8 reserved[3];
+	u8 mac_miss;
+	u8 reserved2;
+	u8 no_vlan;
+	u8 reserved3;
+	u8 vlan_miss;
+	u8 reserved4[3];
+	u8 no_vlan_prio;
+	__be32 promisc;
+	__be32 mcast;
+};
+
+#define VLAN_FLTR_SIZE	128
+struct mlx4_set_vlan_fltr_mbox {
+	__be32 entry[VLAN_FLTR_SIZE];
+};
+
+
+enum {
+	MLX4_MCAST_CONFIG       = 0,
+	MLX4_MCAST_DISABLE      = 1,
+	MLX4_MCAST_ENABLE       = 2,
+};
+
+struct mlx4_set_mcast_fltr_mbox {
+	__be64 mac;
+};
+
+struct mlx4_en_stat_out_mbox {
+	/* Received frames with a length of 64 octets */
+	__be64 R64_prio_0;
+	__be64 R64_prio_1;
+	__be64 R64_prio_2;
+	__be64 R64_prio_3;
+	__be64 R64_prio_4;
+	__be64 R64_prio_5;
+	__be64 R64_prio_6;
+	__be64 R64_prio_7;
+	__be64 R64_novlan;
+	/* Received frames with a length of 127 octets */
+	__be64 R127_prio_0;
+	__be64 R127_prio_1;
+	__be64 R127_prio_2;
+	__be64 R127_prio_3;
+	__be64 R127_prio_4;
+	__be64 R127_prio_5;
+	__be64 R127_prio_6;
+	__be64 R127_prio_7;
+	__be64 R127_novlan;
+	/* Received frames with a length of 255 octets */
+	__be64 R255_prio_0;
+	__be64 R255_prio_1;
+	__be64 R255_prio_2;
+	__be64 R255_prio_3;
+	__be64 R255_prio_4;
+	__be64 R255_prio_5;
+	__be64 R255_prio_6;
+	__be64 R255_prio_7;
+	__be64 R255_novlan;
+	/* Received frames with a length of 511 octets */
+	__be64 R511_prio_0;
+	__be64 R511_prio_1;
+	__be64 R511_prio_2;
+	__be64 R511_prio_3;
+	__be64 R511_prio_4;
+	__be64 R511_prio_5;
+	__be64 R511_prio_6;
+	__be64 R511_prio_7;
+	__be64 R511_novlan;
+	/* Received frames with a length of 1023 octets */
+	__be64 R1023_prio_0;
+	__be64 R1023_prio_1;
+	__be64 R1023_prio_2;
+	__be64 R1023_prio_3;
+	__be64 R1023_prio_4;
+	__be64 R1023_prio_5;
+	__be64 R1023_prio_6;
+	__be64 R1023_prio_7;
+	__be64 R1023_novlan;
+	/* Received frames with a length of 1518 octets */
+	__be64 R1518_prio_0;
+	__be64 R1518_prio_1;
+	__be64 R1518_prio_2;
+	__be64 R1518_prio_3;
+	__be64 R1518_prio_4;
+	__be64 R1518_prio_5;
+	__be64 R1518_prio_6;
+	__be64 R1518_prio_7;
+	__be64 R1518_novlan;
+	/* Received frames with a length of 1522 octets */
+	__be64 R1522_prio_0;
+	__be64 R1522_prio_1;
+	__be64 R1522_prio_2;
+	__be64 R1522_prio_3;
+	__be64 R1522_prio_4;
+	__be64 R1522_prio_5;
+	__be64 R1522_prio_6;
+	__be64 R1522_prio_7;
+	__be64 R1522_novlan;
+	/* Received frames with a length of 1548 octets */
+	__be64 R1548_prio_0;
+	__be64 R1548_prio_1;
+	__be64 R1548_prio_2;
+	__be64 R1548_prio_3;
+	__be64 R1548_prio_4;
+	__be64 R1548_prio_5;
+	__be64 R1548_prio_6;
+	__be64 R1548_prio_7;
+	__be64 R1548_novlan;
+	/* Received frames with a length of 1548 < octets < MTU */
+	__be64 R2MTU_prio_0;
+	__be64 R2MTU_prio_1;
+	__be64 R2MTU_prio_2;
+	__be64 R2MTU_prio_3;
+	__be64 R2MTU_prio_4;
+	__be64 R2MTU_prio_5;
+	__be64 R2MTU_prio_6;
+	__be64 R2MTU_prio_7;
+	__be64 R2MTU_novlan;
+	/* Received frames with a length of MTU< octets and good CRC */
+	__be64 RGIANT_prio_0;
+	__be64 RGIANT_prio_1;
+	__be64 RGIANT_prio_2;
+	__be64 RGIANT_prio_3;
+	__be64 RGIANT_prio_4;
+	__be64 RGIANT_prio_5;
+	__be64 RGIANT_prio_6;
+	__be64 RGIANT_prio_7;
+	__be64 RGIANT_novlan;
+	/* Received broadcast frames with good CRC */
+	__be64 RBCAST_prio_0;
+	__be64 RBCAST_prio_1;
+	__be64 RBCAST_prio_2;
+	__be64 RBCAST_prio_3;
+	__be64 RBCAST_prio_4;
+	__be64 RBCAST_prio_5;
+	__be64 RBCAST_prio_6;
+	__be64 RBCAST_prio_7;
+	__be64 RBCAST_novlan;
+	/* Received multicast frames with good CRC */
+	__be64 MCAST_prio_0;
+	__be64 MCAST_prio_1;
+	__be64 MCAST_prio_2;
+	__be64 MCAST_prio_3;
+	__be64 MCAST_prio_4;
+	__be64 MCAST_prio_5;
+	__be64 MCAST_prio_6;
+	__be64 MCAST_prio_7;
+	__be64 MCAST_novlan;
+	/* Received unicast not short or GIANT frames with good CRC */
+	__be64 RTOTG_prio_0;
+	__be64 RTOTG_prio_1;
+	__be64 RTOTG_prio_2;
+	__be64 RTOTG_prio_3;
+	__be64 RTOTG_prio_4;
+	__be64 RTOTG_prio_5;
+	__be64 RTOTG_prio_6;
+	__be64 RTOTG_prio_7;
+	__be64 RTOTG_novlan;
+
+	/* Count of total octets of received frames, includes framing characters */
+	__be64 RTTLOCT_prio_0;
+	/* Count of total octets of received frames, not including framing
+	   characters */
+	__be64 RTTLOCT_NOFRM_prio_0;
+	/* Count of Total number of octets received
+	   (only for frames without errors) */
+	__be64 ROCT_prio_0;
+
+	__be64 RTTLOCT_prio_1;
+	__be64 RTTLOCT_NOFRM_prio_1;
+	__be64 ROCT_prio_1;
+
+	__be64 RTTLOCT_prio_2;
+	__be64 RTTLOCT_NOFRM_prio_2;
+	__be64 ROCT_prio_2;
+
+	__be64 RTTLOCT_prio_3;
+	__be64 RTTLOCT_NOFRM_prio_3;
+	__be64 ROCT_prio_3;
+
+	__be64 RTTLOCT_prio_4;
+	__be64 RTTLOCT_NOFRM_prio_4;
+	__be64 ROCT_prio_4;
+
+	__be64 RTTLOCT_prio_5;
+	__be64 RTTLOCT_NOFRM_prio_5;
+	__be64 ROCT_prio_5;
+
+	__be64 RTTLOCT_prio_6;
+	__be64 RTTLOCT_NOFRM_prio_6;
+	__be64 ROCT_prio_6;
+
+	__be64 RTTLOCT_prio_7;
+	__be64 RTTLOCT_NOFRM_prio_7;
+	__be64 ROCT_prio_7;
+
+	__be64 RTTLOCT_novlan;
+	__be64 RTTLOCT_NOFRM_novlan;
+	__be64 ROCT_novlan;
+
+	/* Count of Total received frames including bad frames */
+	__be64 RTOT_prio_0;
+	/* Count of  Total number of received frames with 802.1Q encapsulation */
+	__be64 R1Q_prio_0;
+	__be64 reserved1;
+
+	__be64 RTOT_prio_1;
+	__be64 R1Q_prio_1;
+	__be64 reserved2;
+
+	__be64 RTOT_prio_2;
+	__be64 R1Q_prio_2;
+	__be64 reserved3;
+
+	__be64 RTOT_prio_3;
+	__be64 R1Q_prio_3;
+	__be64 reserved4;
+
+	__be64 RTOT_prio_4;
+	__be64 R1Q_prio_4;
+	__be64 reserved5;
+
+	__be64 RTOT_prio_5;
+	__be64 R1Q_prio_5;
+	__be64 reserved6;
+
+	__be64 RTOT_prio_6;
+	__be64 R1Q_prio_6;
+	__be64 reserved7;
+
+	__be64 RTOT_prio_7;
+	__be64 R1Q_prio_7;
+	__be64 reserved8;
+
+	__be64 RTOT_novlan;
+	__be64 R1Q_novlan;
+	__be64 reserved9;
+
+	/* Total number of Successfully Received Control Frames */
+	__be64 RCNTL;
+	__be64 reserved10;
+	__be64 reserved11;
+	__be64 reserved12;
+	/* Count of received frames with a length/type field  value between 46
+	   (42 for VLANtagged frames) and 1500 (also 1500 for VLAN-tagged frames),
+	   inclusive */
+	__be64 RInRangeLengthErr;
+	/* Count of received frames with length/type field between 1501 and 1535
+	   decimal, inclusive */
+	__be64 ROutRangeLengthErr;
+	/* Count of received frames that are longer than max allowed size for
+	   802.3 frames (1518/1522) */
+	__be64 RFrmTooLong;
+	/* Count frames received with PCS error */
+	__be64 PCS;
+
+	/* Transmit frames with a length of 64 octets */
+	__be64 T64_prio_0;
+	__be64 T64_prio_1;
+	__be64 T64_prio_2;
+	__be64 T64_prio_3;
+	__be64 T64_prio_4;
+	__be64 T64_prio_5;
+	__be64 T64_prio_6;
+	__be64 T64_prio_7;
+	__be64 T64_novlan;
+	__be64 T64_loopbk;
+	/* Transmit frames with a length of 65 to 127 octets. */
+	__be64 T127_prio_0;
+	__be64 T127_prio_1;
+	__be64 T127_prio_2;
+	__be64 T127_prio_3;
+	__be64 T127_prio_4;
+	__be64 T127_prio_5;
+	__be64 T127_prio_6;
+	__be64 T127_prio_7;
+	__be64 T127_novlan;
+	__be64 T127_loopbk;
+	/* Transmit frames with a length of 128 to 255 octets */
+	__be64 T255_prio_0;
+	__be64 T255_prio_1;
+	__be64 T255_prio_2;
+	__be64 T255_prio_3;
+	__be64 T255_prio_4;
+	__be64 T255_prio_5;
+	__be64 T255_prio_6;
+	__be64 T255_prio_7;
+	__be64 T255_novlan;
+	__be64 T255_loopbk;
+	/* Transmit frames with a length of 256 to 511 octets */
+	__be64 T511_prio_0;
+	__be64 T511_prio_1;
+	__be64 T511_prio_2;
+	__be64 T511_prio_3;
+	__be64 T511_prio_4;
+	__be64 T511_prio_5;
+	__be64 T511_prio_6;
+	__be64 T511_prio_7;
+	__be64 T511_novlan;
+	__be64 T511_loopbk;
+	/* Transmit frames with a length of 512 to 1023 octets */
+	__be64 T1023_prio_0;
+	__be64 T1023_prio_1;
+	__be64 T1023_prio_2;
+	__be64 T1023_prio_3;
+	__be64 T1023_prio_4;
+	__be64 T1023_prio_5;
+	__be64 T1023_prio_6;
+	__be64 T1023_prio_7;
+	__be64 T1023_novlan;
+	__be64 T1023_loopbk;
+	/* Transmit frames with a length of 1024 to 1518 octets */
+	__be64 T1518_prio_0;
+	__be64 T1518_prio_1;
+	__be64 T1518_prio_2;
+	__be64 T1518_prio_3;
+	__be64 T1518_prio_4;
+	__be64 T1518_prio_5;
+	__be64 T1518_prio_6;
+	__be64 T1518_prio_7;
+	__be64 T1518_novlan;
+	__be64 T1518_loopbk;
+	/* Counts transmit frames with a length of 1519 to 1522 bytes */
+	__be64 T1522_prio_0;
+	__be64 T1522_prio_1;
+	__be64 T1522_prio_2;
+	__be64 T1522_prio_3;
+	__be64 T1522_prio_4;
+	__be64 T1522_prio_5;
+	__be64 T1522_prio_6;
+	__be64 T1522_prio_7;
+	__be64 T1522_novlan;
+	__be64 T1522_loopbk;
+	/* Transmit frames with a length of 1523 to 1548 octets */
+	__be64 T1548_prio_0;
+	__be64 T1548_prio_1;
+	__be64 T1548_prio_2;
+	__be64 T1548_prio_3;
+	__be64 T1548_prio_4;
+	__be64 T1548_prio_5;
+	__be64 T1548_prio_6;
+	__be64 T1548_prio_7;
+	__be64 T1548_novlan;
+	__be64 T1548_loopbk;
+	/* Counts transmit frames with a length of 1549 to MTU bytes */
+	__be64 T2MTU_prio_0;
+	__be64 T2MTU_prio_1;
+	__be64 T2MTU_prio_2;
+	__be64 T2MTU_prio_3;
+	__be64 T2MTU_prio_4;
+	__be64 T2MTU_prio_5;
+	__be64 T2MTU_prio_6;
+	__be64 T2MTU_prio_7;
+	__be64 T2MTU_novlan;
+	__be64 T2MTU_loopbk;
+	/* Transmit frames with a length greater than MTU octets and a good CRC. */
+	__be64 TGIANT_prio_0;
+	__be64 TGIANT_prio_1;
+	__be64 TGIANT_prio_2;
+	__be64 TGIANT_prio_3;
+	__be64 TGIANT_prio_4;
+	__be64 TGIANT_prio_5;
+	__be64 TGIANT_prio_6;
+	__be64 TGIANT_prio_7;
+	__be64 TGIANT_novlan;
+	__be64 TGIANT_loopbk;
+	/* Transmit broadcast frames with a good CRC */
+	__be64 TBCAST_prio_0;
+	__be64 TBCAST_prio_1;
+	__be64 TBCAST_prio_2;
+	__be64 TBCAST_prio_3;
+	__be64 TBCAST_prio_4;
+	__be64 TBCAST_prio_5;
+	__be64 TBCAST_prio_6;
+	__be64 TBCAST_prio_7;
+	__be64 TBCAST_novlan;
+	__be64 TBCAST_loopbk;
+	/* Transmit multicast frames with a good CRC */
+	__be64 TMCAST_prio_0;
+	__be64 TMCAST_prio_1;
+	__be64 TMCAST_prio_2;
+	__be64 TMCAST_prio_3;
+	__be64 TMCAST_prio_4;
+	__be64 TMCAST_prio_5;
+	__be64 TMCAST_prio_6;
+	__be64 TMCAST_prio_7;
+	__be64 TMCAST_novlan;
+	__be64 TMCAST_loopbk;
+	/* Transmit good frames that are neither broadcast nor multicast */
+	__be64 TTOTG_prio_0;
+	__be64 TTOTG_prio_1;
+	__be64 TTOTG_prio_2;
+	__be64 TTOTG_prio_3;
+	__be64 TTOTG_prio_4;
+	__be64 TTOTG_prio_5;
+	__be64 TTOTG_prio_6;
+	__be64 TTOTG_prio_7;
+	__be64 TTOTG_novlan;
+	__be64 TTOTG_loopbk;
+
+	/* total octets of transmitted frames, including framing characters */
+	__be64 TTTLOCT_prio_0;
+	/* total octets of transmitted frames, not including framing characters */
+	__be64 TTTLOCT_NOFRM_prio_0;
+	/* ifOutOctets */
+	__be64 TOCT_prio_0;
+
+	__be64 TTTLOCT_prio_1;
+	__be64 TTTLOCT_NOFRM_prio_1;
+	__be64 TOCT_prio_1;
+
+	__be64 TTTLOCT_prio_2;
+	__be64 TTTLOCT_NOFRM_prio_2;
+	__be64 TOCT_prio_2;
+
+	__be64 TTTLOCT_prio_3;
+	__be64 TTTLOCT_NOFRM_prio_3;
+	__be64 TOCT_prio_3;
+
+	__be64 TTTLOCT_prio_4;
+	__be64 TTTLOCT_NOFRM_prio_4;
+	__be64 TOCT_prio_4;
+
+	__be64 TTTLOCT_prio_5;
+	__be64 TTTLOCT_NOFRM_prio_5;
+	__be64 TOCT_prio_5;
+
+	__be64 TTTLOCT_prio_6;
+	__be64 TTTLOCT_NOFRM_prio_6;
+	__be64 TOCT_prio_6;
+
+	__be64 TTTLOCT_prio_7;
+	__be64 TTTLOCT_NOFRM_prio_7;
+	__be64 TOCT_prio_7;
+
+	__be64 TTTLOCT_novlan;
+	__be64 TTTLOCT_NOFRM_novlan;
+	__be64 TOCT_novlan;
+
+	__be64 TTTLOCT_loopbk;
+	__be64 TTTLOCT_NOFRM_loopbk;
+	__be64 TOCT_loopbk;
+
+	/* Total frames transmitted with a good CRC that are not aborted  */
+	__be64 TTOT_prio_0;
+	/* Total number of frames transmitted with 802.1Q encapsulation */
+	__be64 T1Q_prio_0;
+	__be64 reserved13;
+
+	__be64 TTOT_prio_1;
+	__be64 T1Q_prio_1;
+	__be64 reserved14;
+
+	__be64 TTOT_prio_2;
+	__be64 T1Q_prio_2;
+	__be64 reserved15;
+
+	__be64 TTOT_prio_3;
+	__be64 T1Q_prio_3;
+	__be64 reserved16;
+
+	__be64 TTOT_prio_4;
+	__be64 T1Q_prio_4;
+	__be64 reserved17;
+
+	__be64 TTOT_prio_5;
+	__be64 T1Q_prio_5;
+	__be64 reserved18;
+
+	__be64 TTOT_prio_6;
+	__be64 T1Q_prio_6;
+	__be64 reserved19;
+
+	__be64 TTOT_prio_7;
+	__be64 T1Q_prio_7;
+	__be64 reserved20;
+
+	__be64 TTOT_novlan;
+	__be64 T1Q_novlan;
+	__be64 reserved21;
+
+	__be64 TTOT_loopbk;
+	__be64 T1Q_loopbk;
+	__be64 reserved22;
+
+	/* Received frames with a length greater than MTU octets and a bad CRC */
+	__be32 RJBBR;
+	/* Received frames with a bad CRC that are not runts, jabbers,
+	   or alignment errors */
+	__be32 RCRC;
+	/* Received frames with SFD with a length of less than 64 octets and a
+	   bad CRC */
+	__be32 RRUNT;
+	/* Received frames with a length less than 64 octets and a good CRC */
+	__be32 RSHORT;
+	/* Total Number of Received Packets Dropped */
+	__be32 RDROP;
+	/* Drop due to overflow  */
+	__be32 RdropOvflw;
+	/* Drop due to overflow */
+	__be32 RdropLength;
+	/* Total of good frames. Does not include frames received with
+	   frame-too-long, FCS, or length errors */
+	__be32 RTOTFRMS;
+	/* Total dropped Xmited packets */
+	__be32 TDROP;
+};
+
+
+#endif
-- 
1.5.4





