From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 4/7] mlx4_en: Added self diagnostics test implementation
Date: Thu, 01 Oct 2009 16:33:57 +0200
Message-ID: <4AC4BDD5.9010204@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:60238 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756415AbZJALfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 07:35:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The test includes 5 tests:
1. Interrupt test: Executing commands and receiving command completion
   on all our interrupt vectors.
2. Link test: Verifying we are connected to valid link partner.
3. Speed test: Check that we negotiated link speed correctly.
4. Registers test: Activate HW health check command.
5. Loopback test: Send a packet on loopback interface and catch it on RX side.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/Makefile      |    2 +-
 drivers/net/mlx4/en_ethtool.c  |   79 ++++++++++++------
 drivers/net/mlx4/en_netdev.c   |    2 +-
 drivers/net/mlx4/en_port.c     |   32 +++++++
 drivers/net/mlx4/en_port.h     |   14 +++
 drivers/net/mlx4/en_rx.c       |    7 ++
 drivers/net/mlx4/en_selftest.c |  182 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/mlx4/en_tx.c       |   16 ++++
 drivers/net/mlx4/mlx4_en.h     |   21 +++++-
 9 files changed, 327 insertions(+), 28 deletions(-)
 create mode 100644 drivers/net/mlx4/en_selftest.c

diff --git a/drivers/net/mlx4/Makefile b/drivers/net/mlx4/Makefile
index 1fd068e..d1aa45a 100644
--- a/drivers/net/mlx4/Makefile
+++ b/drivers/net/mlx4/Makefile
@@ -6,4 +6,4 @@ mlx4_core-y :=	alloc.o catas.o cmd.o cq.o eq.o fw.o icm.o intf.o main.o mcg.o \
 obj-$(CONFIG_MLX4_EN)               += mlx4_en.o
 
 mlx4_en-y := 	en_main.o en_tx.o en_rx.o en_ethtool.o en_port.o en_cq.o \
-		en_resources.o en_netdev.o
+		en_resources.o en_netdev.o en_selftest.o
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 86467b4..745a204 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -125,6 +125,14 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 #define NUM_MAIN_STATS	21
 #define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + NUM_PERF_STATS)
 
+static const char mlx4_en_test_names[][ETH_GSTRING_LEN] = {
+	"Interupt Test",
+	"Link Test",
+	"Speed Test",
+	"Register Test",
+	"Loopback Test",
+};
+
 static u32 mlx4_en_get_msglevel(struct net_device *dev)
 {
 	return ((struct mlx4_en_priv *) netdev_priv(dev))->msg_enable;
@@ -148,10 +156,15 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
-	if (sset != ETH_SS_STATS)
+	switch (sset) {
+	case ETH_SS_STATS:
+		return NUM_ALL_STATS +
+			(priv->tx_ring_num + priv->rx_ring_num) * 2;
+	case ETH_SS_TEST:
+		return MLX4_EN_NUM_SELF_TEST - !(priv->mdev->dev->caps.loopback_support) * 2;
+	default:
 		return -EOPNOTSUPP;
-
-	return NUM_ALL_STATS + (priv->tx_ring_num + priv->rx_ring_num) * 2;
+	}
 }
 
 static void mlx4_en_get_ethtool_stats(struct net_device *dev,
@@ -183,6 +196,12 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 
 }
 
+static void mlx4_en_self_test(struct net_device *dev,
+			      struct ethtool_test *etest, u64 *buf)
+{
+	mlx4_en_ex_selftest(dev, &etest->flags, buf);
+}
+
 static void mlx4_en_get_strings(struct net_device *dev,
 				uint32_t stringset, uint8_t *data)
 {
@@ -190,30 +209,39 @@ static void mlx4_en_get_strings(struct net_device *dev,
 	int index = 0;
 	int i;
 
-	if (stringset != ETH_SS_STATS)
-		return;
-
-	/* Add main counters */
-	for (i = 0; i < NUM_MAIN_STATS; i++)
-		strcpy(data + (index++) * ETH_GSTRING_LEN, main_strings[i]);
-	for (i = 0; i < NUM_PORT_STATS; i++)
-		strcpy(data + (index++) * ETH_GSTRING_LEN,
+	switch (stringset) {
+	case ETH_SS_TEST:
+		for (i = 0; i < MLX4_EN_NUM_SELF_TEST - 2; i++)
+			strcpy(data + i * ETH_GSTRING_LEN, mlx4_en_test_names[i]);
+		if (priv->mdev->dev->caps.loopback_support)
+			for (; i < MLX4_EN_NUM_SELF_TEST; i++)
+				strcpy(data + i * ETH_GSTRING_LEN, mlx4_en_test_names[i]);
+		break;
+
+	case ETH_SS_STATS:
+		/* Add main counters */
+		for (i = 0; i < NUM_MAIN_STATS; i++)
+			strcpy(data + (index++) * ETH_GSTRING_LEN, main_strings[i]);
+		for (i = 0; i < NUM_PORT_STATS; i++)
+			strcpy(data + (index++) * ETH_GSTRING_LEN,
 			main_strings[i + NUM_MAIN_STATS]);
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		sprintf(data + (index++) * ETH_GSTRING_LEN,
-			"tx%d_packets", i);
-		sprintf(data + (index++) * ETH_GSTRING_LEN,
-			"tx%d_bytes", i);
-	}
-	for (i = 0; i < priv->rx_ring_num; i++) {
-		sprintf(data + (index++) * ETH_GSTRING_LEN,
-			"rx%d_packets", i);
-		sprintf(data + (index++) * ETH_GSTRING_LEN,
-			"rx%d_bytes", i);
-	}
-	for (i = 0; i < NUM_PKT_STATS; i++)
-		strcpy(data + (index++) * ETH_GSTRING_LEN,
+		for (i = 0; i < priv->tx_ring_num; i++) {
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"tx%d_packets", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"tx%d_bytes", i);
+		}
+		for (i = 0; i < priv->rx_ring_num; i++) {
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_packets", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_bytes", i);
+		}
+		for (i = 0; i < NUM_PKT_STATS; i++)
+			strcpy(data + (index++) * ETH_GSTRING_LEN,
 			main_strings[i + NUM_MAIN_STATS + NUM_PORT_STATS]);
+		break;
+	}
 }
 
 static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -407,6 +435,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_strings = mlx4_en_get_strings,
 	.get_sset_count = mlx4_en_get_sset_count,
 	.get_ethtool_stats = mlx4_en_get_ethtool_stats,
+	.self_test = mlx4_en_self_test,
 	.get_wol = mlx4_en_get_wol,
 	.get_msglevel = mlx4_en_get_msglevel,
 	.set_msglevel = mlx4_en_set_msglevel,
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index c48b0f4..922ae1f 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -108,7 +108,7 @@ static void mlx4_en_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	mutex_unlock(&mdev->state_lock);
 }
 
-static u64 mlx4_en_mac_to_u64(u8 *addr)
+u64 mlx4_en_mac_to_u64(u8 *addr)
 {
 	u64 mac = 0;
 	int i;
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index a29abe8..aa3ef2a 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -142,6 +142,38 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	return err;
 }
 
+int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port)
+{
+	struct mlx4_en_query_port_context *qport_context;
+	struct mlx4_en_priv *priv = netdev_priv(mdev->pndev[port]);
+	struct mlx4_en_port_state *state = &priv->port_state;
+	struct mlx4_cmd_mailbox *mailbox;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(mdev->dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	memset(mailbox->buf, 0, sizeof(*qport_context));
+	err = mlx4_cmd_box(mdev->dev, 0, mailbox->dma, port, 0,
+			   MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B);
+	if (err)
+		goto out;
+	qport_context = mailbox->buf;
+
+	/* This command is always accessed from Ethtool context
+	 * already synchronized, no need in locking */
+	state->link_state = !!(qport_context->link_up & MLX4_EN_LINK_UP_MASK);
+	if ((qport_context->link_speed & MLX4_EN_SPEED_MASK) ==
+	    MLX4_EN_1G_SPEED)
+		state->link_speed = 1000;
+	else
+		state->link_speed = 10000;
+	state->transciver = qport_context->transceiver;
+
+out:
+	mlx4_free_cmd_mailbox(mdev->dev, mailbox);
+	return err;
+}
 
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 {
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index e6477f1..f6511aa 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -84,6 +84,20 @@ enum {
 	MLX4_MCAST_ENABLE       = 2,
 };
 
+struct mlx4_en_query_port_context {
+	u8 link_up;
+#define MLX4_EN_LINK_UP_MASK	0x80
+	u8 reserved;
+	__be16 mtu;
+	u8 reserved2;
+	u8 link_speed;
+#define MLX4_EN_SPEED_MASK	0x3
+#define MLX4_EN_1G_SPEED	0x2
+	u16 reserved3[5];
+	__be64 mac;
+	u8 transceiver;
+};
+
 
 struct mlx4_en_stat_out_mbox {
 	/* Received frames with a length of 64 octets */
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 03b781a..247a408 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -654,6 +654,13 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			goto next;
 		}
 
+		if (unlikely(priv->validate_loopback)) {
+			priv->loopback_ok =
+				!strcmp((skb->data + ETH_HLEN), "MLX4 Loopback");
+			dev_kfree_skb_any(skb);
+			goto next;
+		}
+
 		skb->ip_summed = ip_summed;
 		skb->protocol = eth_type_trans(skb, dev);
 		skb_record_rx_queue(skb, cq->ring);
diff --git a/drivers/net/mlx4/en_selftest.c b/drivers/net/mlx4/en_selftest.c
new file mode 100644
index 0000000..8e2042e
--- /dev/null
+++ b/drivers/net/mlx4/en_selftest.c
@@ -0,0 +1,182 @@
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
+#include <linux/kernel.h>
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+#include <linux/delay.h>
+#include <linux/mlx4/driver.h>
+
+#include "mlx4_en.h"
+
+
+static int mlx4_en_test_registers(struct mlx4_en_priv *priv)
+{
+	return mlx4_cmd(priv->mdev->dev, 0, 0, 0, MLX4_CMD_HW_HEALTH_CHECK,
+			MLX4_CMD_TIME_CLASS_A);
+}
+
+static int mlx4_en_test_loopback_xmit(struct mlx4_en_priv *priv)
+{
+	struct sk_buff *skb;
+	struct ethhdr *ethh;
+	unsigned char *packet;
+	unsigned int packet_size = MLX4_LOOPBACK_TEST_PAYLOAD;
+	unsigned int i;
+	int err;
+
+
+	/* build the pkt before xmit */
+	skb = netdev_alloc_skb(priv->dev,
+			MLX4_LOOPBACK_TEST_PAYLOAD + ETH_HLEN + NET_IP_ALIGN);
+	if (!skb) {
+		en_err(priv, "failed to allocate skb for xmit\n");
+		return -ENOMEM;
+	}
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	ethh = (struct ethhdr *)skb_put(skb, sizeof(struct ethhdr));
+	packet	= (unsigned char *)skb_put(skb, packet_size);
+	memcpy(ethh->h_dest, priv->dev->dev_addr, ETH_ALEN);
+	memset(ethh->h_source, 0, ETH_ALEN);
+	ethh->h_proto = htons(ETH_P_ARP);
+	skb_set_mac_header(skb, 0);
+	for (i = 0; i < packet_size; ++i)	/* fill our packet */
+		sprintf(packet, "MLX4 Loopback");
+
+	/* xmit the pkt */
+	err = mlx4_en_xmit(skb, priv->dev);
+	return err;
+}
+
+static int mlx4_en_test_loopback(struct mlx4_en_priv *priv)
+{
+	u32 loopback_ok = 0;
+	int i;
+
+	priv->loopback_ok = 0;
+	priv->validate_loopback = 1;
+
+	/* xmit */
+	if (mlx4_en_test_loopback_xmit(priv)) {
+		en_err(priv, "Transmitting loopback packet failed\n");
+		goto mlx4_en_test_loopback_exit;
+	}
+
+	/* polling for result */
+	for (i = 0; i < MLX4_EN_LOOPBACK_RETRIES; ++i) {
+		msleep(MLX4_EN_LOOPBACK_TIMEOUT);
+		if (priv->loopback_ok) {
+			loopback_ok = 1;
+			break;
+		}
+	}
+	if (!loopback_ok)
+		en_err(priv, "Loopback packet didn't arrive\n");
+
+mlx4_en_test_loopback_exit:
+
+	priv->validate_loopback = 0;
+	return !loopback_ok;
+}
+
+
+static int mlx4_en_test_link(struct mlx4_en_priv *priv)
+{
+	if (mlx4_en_QUERY_PORT(priv->mdev, priv->port))
+		return -ENOMEM;
+	if (priv->port_state.link_state == 1)
+		return 0;
+	else
+		return 1;
+}
+
+static int mlx4_en_test_speed(struct mlx4_en_priv *priv)
+{
+
+	if (mlx4_en_QUERY_PORT(priv->mdev, priv->port))
+		return -ENOMEM;
+
+	/* The device currently only supports 10G speed */
+	if (priv->port_state.link_speed != SPEED_10000)
+		return priv->port_state.link_speed;
+	return 0;
+}
+
+
+void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_tx_ring *tx_ring;
+	int i, running;
+
+	memset(buf, 0, sizeof(u64) * MLX4_EN_NUM_SELF_TEST);
+
+	if (*flags & ETH_TEST_FL_OFFLINE) {
+		/* disable the interface */
+		running = netif_running(dev);
+
+		if (running) {
+			netif_tx_disable(dev);
+			dev->trans_start = jiffies;
+		}
+retry_tx:
+		/* Wait untill all tx queues are empty.
+		 * there should not be any additional incoming traffic
+		 * since we turned the carrier off */
+		msleep(200);
+		for (i = 0; i < priv->tx_ring_num && running; i++) {
+			tx_ring = &priv->tx_ring[i];
+			if (tx_ring->prod != (tx_ring->cons + tx_ring->last_nr_txbb))
+				goto retry_tx;
+		}
+
+		if (priv->mdev->dev->caps.loopback_support) {
+			buf[3] = mlx4_en_test_registers(priv);
+			buf[4] = mlx4_en_test_loopback(priv);
+		}
+
+		if (running)
+			netif_tx_wake_all_queues(dev);
+
+	}
+	buf[0] = mlx4_test_interrupts(mdev->dev);
+	buf[1] = mlx4_en_test_link(priv);
+	buf[2] = mlx4_en_test_speed(priv);
+
+	for (i = 0; i < MLX4_EN_NUM_SELF_TEST; i++) {
+		if (buf[i])
+			*flags |= ETH_TEST_FL_FAILED;
+	}
+}
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 8c72799..47de091 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -599,6 +599,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct mlx4_wqe_data_seg *data;
 	struct skb_frag_struct *frag;
 	struct mlx4_en_tx_info *tx_info;
+	struct ethhdr *ethh;
+	u64 mac;
+	u32 mac_l, mac_h;
 	int tx_ind = 0;
 	int nr_txbb;
 	int desc_size;
@@ -675,6 +678,19 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->port_stats.tx_chksum_offload++;
 	}
 
+	if (unlikely(priv->validate_loopback)) {
+		/* Copy dst mac address to wqe */
+		skb_reset_mac_header(skb);
+		ethh = eth_hdr(skb);
+		if (ethh && ethh->h_dest) {
+			mac = mlx4_en_mac_to_u64(ethh->h_dest);
+			mac_h = (u32) ((mac & 0xffff00000000) >> 16);
+			mac_l = (u32) (mac & 0xffffffff);
+			tx_desc->ctrl.srcrb_flags |= cpu_to_be32(mac_h);
+			tx_desc->ctrl.imm = cpu_to_be32(mac_l);
+		}
+	}
+
 	/* Handle LSO (TSO) packets */
 	if (lso_header_size) {
 		/* Mark opcode as LSO */
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 4376147..8655624 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -45,6 +45,7 @@
 #include <linux/mlx4/cq.h>
 #include <linux/mlx4/srq.h>
 #include <linux/mlx4/doorbell.h>
+#include <linux/mlx4/cmd.h>
 
 #include "en_port.h"
 
@@ -52,7 +53,6 @@
 #define DRV_VERSION	"1.4.1.1"
 #define DRV_RELDATE	"June 2009"
 
-
 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
 
 #define en_print(level, priv, format, arg...)			\
@@ -171,10 +171,14 @@ enum {
 
 #define SMALL_PACKET_SIZE      (256 - NET_IP_ALIGN)
 #define HEADER_COPY_SIZE       (128 - NET_IP_ALIGN)
+#define MLX4_LOOPBACK_TEST_PAYLOAD (HEADER_COPY_SIZE - ETH_HLEN)
 
 #define MLX4_EN_MIN_MTU		46
 #define ETH_BCAST		0xffffffffffffULL
 
+#define MLX4_EN_LOOPBACK_RETRIES	5
+#define MLX4_EN_LOOPBACK_TIMEOUT	100
+
 #ifdef MLX4_EN_PERF_STAT
 /* Number of samples to 'average' */
 #define AVG_SIZE			128
@@ -389,6 +393,12 @@ struct mlx4_en_rss_context {
 	__be32 rss_key[10];
 };
 
+struct mlx4_en_port_state {
+	int link_state;
+	int link_speed;
+	int transciver;
+};
+
 struct mlx4_en_pkt_stats {
 	unsigned long broadcast;
 	unsigned long rx_prio[8];
@@ -437,6 +447,7 @@ struct mlx4_en_priv {
 	struct vlan_group *vlgrp;
 	struct net_device_stats stats;
 	struct net_device_stats ret_stats;
+	struct mlx4_en_port_state port_state;
 	spinlock_t stats_lock;
 
 	unsigned long last_moder_packets;
@@ -455,6 +466,8 @@ struct mlx4_en_priv {
 	u16 sample_interval;
 	u16 adaptive_rx_coal;
 	u32 msg_enable;
+	u32 loopback_ok;
+	u32 validate_loopback;
 
 	struct mlx4_hwq_resources res;
 	int link_state;
@@ -494,6 +507,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_port_stats port_stats;
 	struct dev_mc_list *mc_list;
 	struct mlx4_en_stat_out_mbox hw_stats;
+
 };
 
 
@@ -562,6 +576,11 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 			   u8 promisc);
 
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
+int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
+
+#define MLX4_EN_NUM_SELF_TEST	5
+void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf);
+u64 mlx4_en_mac_to_u64(u8 *addr);
 
 /*
  * Globals
-- 
1.6.1.3


