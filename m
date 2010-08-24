From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 08/14] mlx4_en: Added self diagnostics test implementation
Date: Tue, 24 Aug 2010 16:46:18 +0300
Message-ID: <4C73CD2A.2000101@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50125 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755272Ab0HXNqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:46:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The selftest includes 5 features:
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
 drivers/net/mlx4/en_rx.c       |   20 +++++
 drivers/net/mlx4/en_selftest.c |  179 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/mlx4/en_tx.c       |   16 ++++
 drivers/net/mlx4/eq.c          |   44 ++++++++++
 drivers/net/mlx4/fw.c          |    3 +
 drivers/net/mlx4/fw.h          |    1 +
 drivers/net/mlx4/main.c        |    1 +
 drivers/net/mlx4/mlx4_en.h     |   19 ++++
 include/linux/mlx4/cmd.h       |    1 +
 include/linux/mlx4/device.h    |    2 +
 15 files changed, 388 insertions(+), 27 deletions(-)
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
index b275238..49a7003 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -125,6 +125,14 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 #define NUM_MAIN_STATS	21
 #define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + NUM_PERF_STATS)
 
+static const char mlx4_en_test_names[][ETH_GSTRING_LEN]= {
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
@@ -146,10 +154,15 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
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
@@ -181,6 +194,12 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 
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
@@ -188,30 +207,39 @@ static void mlx4_en_get_strings(struct net_device *dev,
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
+		for (i = 0; i< NUM_PORT_STATS; i++)
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
+		for (i = 0; i< NUM_PKT_STATS; i++)
+			strcpy(data + (index++) * ETH_GSTRING_LEN,
 			main_strings[i + NUM_MAIN_STATS + NUM_PORT_STATS]);
+		break;
+	}
 }
 
 static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -441,6 +469,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_strings = mlx4_en_get_strings,
 	.get_sset_count = mlx4_en_get_sset_count,
 	.get_ethtool_stats = mlx4_en_get_ethtool_stats,
+	.self_test = mlx4_en_self_test,
 	.get_wol = mlx4_en_get_wol,
 	.get_msglevel = mlx4_en_get_msglevel,
 	.set_msglevel = mlx4_en_set_msglevel,
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 92fd1ff..7a1e697 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -109,7 +109,7 @@ static void mlx4_en_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
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
index 394da29..ae17baa 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -541,6 +541,21 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	return skb;
 }
 
+static void validate_loopback(struct mlx4_en_priv *priv, struct sk_buff *skb)
+{
+	int i;
+	int offset = ETH_HLEN;
+
+	for (i = 0; i < MLX4_LOOPBACK_TEST_PAYLOAD; i++, offset++) {
+		if (*(skb->data + offset) != (unsigned char) (i & 0xff))
+			goto out_loopback;
+	}
+	/* Loopback found */
+	priv->loopback_ok = 1;
+
+out_loopback:
+	dev_kfree_skb_any(skb);
+}
 
 int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int budget)
 {
@@ -655,6 +670,11 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			goto next;
 		}
 
+                if (unlikely(priv->validate_loopback)) {
+			validate_loopback(priv, skb);
+			goto next;
+		}
+
 		skb->ip_summed = ip_summed;
 		skb->protocol = eth_type_trans(skb, dev);
 		skb_record_rx_queue(skb, cq->ring);
diff --git a/drivers/net/mlx4/en_selftest.c b/drivers/net/mlx4/en_selftest.c
new file mode 100644
index 0000000..43357d3
--- /dev/null
+++ b/drivers/net/mlx4/en_selftest.c
@@ -0,0 +1,179 @@
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
+	skb = netdev_alloc_skb(priv->dev, MLX4_LOOPBACK_TEST_PAYLOAD + ETH_HLEN + NET_IP_ALIGN);
+	if (!skb) {
+		en_err(priv, "-LOOPBACK_TEST_XMIT- failed to create skb for xmit\n");
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
+		packet[i] = (unsigned char)(i & 0xff);
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
+
+        priv->loopback_ok = 0;
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
+	return (!loopback_ok);
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
+	int i, carrier_ok;
+
+	memset(buf, 0, sizeof(u64) * MLX4_EN_NUM_SELF_TEST);
+
+	if (*flags & ETH_TEST_FL_OFFLINE) {
+		/* disable the interface */
+		carrier_ok = netif_carrier_ok(dev);
+
+		netif_carrier_off(dev);
+retry_tx:
+		/* Wait untill all tx queues are empty.
+		 * there should not be any additional incoming traffic
+		 * since we turned the carrier off */
+		msleep(200);
+		for (i = 0; i < priv->tx_ring_num && carrier_ok; i++) {
+			tx_ring = &priv->tx_ring[i];
+			if (tx_ring->prod != (tx_ring->cons + tx_ring->last_nr_txbb))
+				goto retry_tx;
+		}
+
+		if (priv->mdev->dev->caps.loopback_support){
+			buf[3] = mlx4_en_test_registers(priv);
+			buf[4] = mlx4_en_test_loopback(priv);
+		}
+
+		if (carrier_ok)
+			netif_carrier_on(dev);
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
index 3deabd1..b875f9c 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -600,6 +600,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct mlx4_wqe_data_seg *data;
 	struct skb_frag_struct *frag;
 	struct mlx4_en_tx_info *tx_info;
+	struct ethhdr *ethh;
+	u64 mac;
+	u32 mac_l, mac_h;
 	int tx_ind = 0;
 	int nr_txbb;
 	int desc_size;
@@ -679,6 +682,19 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->port_stats.tx_chksum_offload++;
 	}
 
+	if (unlikely(priv->validate_loopback)) {
+		/* Copy dst mac address to wqe */
+		skb_reset_mac_header(skb);
+		ethh = eth_hdr(skb);
+		if (ethh && ethh->h_dest) {
+			mac = mlx4_en_mac_to_u64(ethh->h_dest);
+			mac_h = (u32) ((mac & 0xffff00000000ULL) >> 16);
+			mac_l = (u32) (mac & 0xffffffff);
+			tx_desc->ctrl.srcrb_flags |= cpu_to_be32(mac_h);
+			tx_desc->ctrl.imm = cpu_to_be32(mac_l);
+		}
+	}
+
 	/* Handle LSO (TSO) packets */
 	if (lso_header_size) {
 		/* Mark opcode as LSO */
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 6d7b2bf..552d0fc 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -699,3 +699,47 @@ void mlx4_cleanup_eq_table(struct mlx4_dev *dev)
 
 	kfree(priv->eq_table.uar_map);
 }
+
+/* A test that verifies that we can accept interrupts on all
+ * the irq vectors of the device.
+ * Interrupts are checked using the NOP command.
+ */
+int mlx4_test_interrupts(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int i;
+	int err;
+
+	err = mlx4_NOP(dev);
+	/* When not in MSI_X, there is only one irq to check */
+	if (!(dev->flags & MLX4_FLAG_MSI_X))
+		return err;
+
+	/* A loop over all completion vectors, for each vector we will check
+	 * whether it works by mapping command completions to that vector
+	 * and performing a NOP command
+	 */
+	for(i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
+		/* Temporary use polling for command completions */
+		mlx4_cmd_use_polling(dev);
+
+		/* Map the new eq to handle all asyncronous events */
+		err = mlx4_MAP_EQ(dev, MLX4_ASYNC_EVENT_MASK, 0,
+				  priv->eq_table.eq[i].eqn);
+		if (err) {
+			mlx4_warn(dev, "Failed mapping eq for interrupt test\n");
+			mlx4_cmd_use_events(dev);
+			break;
+		}
+
+		/* Go back to using events */
+		mlx4_cmd_use_events(dev);
+		err = mlx4_NOP(dev);
+	}
+
+	/* Return to default */
+	mlx4_MAP_EQ(dev, MLX4_ASYNC_EVENT_MASK, 0,
+		    priv->eq_table.eq[dev->caps.num_comp_vectors].eqn);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_test_interrupts);
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 04f42ae..a87bf3c 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -178,6 +178,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MAX_GID_OFFSET		0x3b
 #define QUERY_DEV_CAP_RATE_SUPPORT_OFFSET	0x3c
 #define QUERY_DEV_CAP_MAX_PKEY_OFFSET		0x3f
+#define QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET	0x43
 #define QUERY_DEV_CAP_FLAGS_OFFSET		0x44
 #define QUERY_DEV_CAP_RSVD_UAR_OFFSET		0x48
 #define QUERY_DEV_CAP_UAR_SZ_OFFSET		0x49
@@ -268,6 +269,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->max_msg_sz = 1 << (field & 0x1f);
 	MLX4_GET(stat_rate, outbox, QUERY_DEV_CAP_RATE_SUPPORT_OFFSET);
 	dev_cap->stat_rate_support = stat_rate;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET);
+	dev_cap->loopback_support = field & 0x1;
 	MLX4_GET(dev_cap->flags, outbox, QUERY_DEV_CAP_FLAGS_OFFSET);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_UAR_OFFSET);
 	dev_cap->reserved_uars = field >> 4;
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index 526d7f3..2cc1ba5 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -74,6 +74,7 @@ struct mlx4_dev_cap {
 	u64 def_mac[MLX4_MAX_PORTS + 1];
 	u16 eth_mtu[MLX4_MAX_PORTS + 1];
 	u16 stat_rate_support;
+	int loopback_support;
 	u32 flags;
 	int reserved_uars;
 	int uar_size;
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 5102ab1..7390cdb 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -221,6 +221,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.bmme_flags	     = dev_cap->bmme_flags;
 	dev->caps.reserved_lkey	     = dev_cap->reserved_lkey;
 	dev->caps.stat_rate_support  = dev_cap->stat_rate_support;
+	dev->caps.loopback_support   = dev_cap->loopback_support;
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 
 	dev->caps.log_num_macs  = log_num_mac;
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 747f04a..bd39d81 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -45,6 +45,7 @@
 #include <linux/mlx4/cq.h>
 #include <linux/mlx4/srq.h>
 #include <linux/mlx4/doorbell.h>
+#include <linux/mlx4/cmd.h>
 
 #include "en_port.h"
 
@@ -139,10 +140,14 @@ enum {
 
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
@@ -357,6 +362,12 @@ struct mlx4_en_rss_context {
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
@@ -405,6 +416,7 @@ struct mlx4_en_priv {
 	struct vlan_group *vlgrp;
 	struct net_device_stats stats;
 	struct net_device_stats ret_stats;
+	struct mlx4_en_port_state port_state;
 	spinlock_t stats_lock;
 
 	unsigned long last_moder_packets;
@@ -423,6 +435,8 @@ struct mlx4_en_priv {
 	u16 sample_interval;
 	u16 adaptive_rx_coal;
 	u32 msg_enable;
+	u32 loopback_ok;
+	u32 validate_loopback;
 
 	struct mlx4_hwq_resources res;
 	int link_state;
@@ -531,6 +545,11 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 			   u8 promisc);
 
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
+int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
+
+#define MLX4_EN_NUM_SELF_TEST	5
+void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf);
+u64 mlx4_en_mac_to_u64(u8 *addr);
 
 /*
  * Globals
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 0f82293..78a1b96 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -56,6 +56,7 @@ enum {
 	MLX4_CMD_QUERY_HCA	 = 0xb,
 	MLX4_CMD_QUERY_PORT	 = 0x43,
 	MLX4_CMD_SENSE_PORT	 = 0x4d,
+	MLX4_CMD_HW_HEALTH_CHECK = 0x50,
 	MLX4_CMD_SET_PORT	 = 0xc,
 	MLX4_CMD_ACCESS_DDR	 = 0x2e,
 	MLX4_CMD_MAP_ICM	 = 0xffa,
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 7a7f9c1..2cec587 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -229,6 +229,7 @@ struct mlx4_caps {
 	u32			bmme_flags;
 	u32			reserved_lkey;
 	u16			stat_rate_support;
+	int			loopback_support;
 	u8			port_width_cap[MLX4_MAX_PORTS + 1];
 	int			max_gso_sz;
 	int                     reserved_qps_cnt[MLX4_NUM_QP_REGION];
@@ -480,5 +481,6 @@ void mlx4_fmr_unmap(struct mlx4_dev *dev, struct mlx4_fmr *fmr,
 		    u32 *lkey, u32 *rkey);
 int mlx4_fmr_free(struct mlx4_dev *dev, struct mlx4_fmr *fmr);
 int mlx4_SYNC_TPT(struct mlx4_dev *dev);
+int mlx4_test_interrupts(struct mlx4_dev *dev);
 
 #endif /* MLX4_DEVICE_H */
-- 
1.6.1.3


