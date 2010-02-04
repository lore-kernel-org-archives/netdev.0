From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 23/23 v3] mlx4_en: querying link state
Date: Thu, 04 Feb 2010 17:57:16 +0200
Message-ID: <4B6AEE5C.2080105@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49933 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933253Ab0BDP5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:57:19 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In multifunction device, a certain function can initialize its port after some
other function already done that. In that case link event would not be generated.
Need to query the port to retrieve the port state.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   10 ++++++++++
 drivers/net/mlx4/en_port.c   |   31 +++++++++++++++++++++++++++++++
 drivers/net/mlx4/en_port.h   |   15 +++++++++++++++
 drivers/net/mlx4/mlx4_en.h   |    8 ++++++++
 4 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 947fb2f..22511ec 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -229,6 +229,16 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		goto out;
 	}
 
+	if (!netif_carrier_ok(dev)) {
+		if (!mlx4_en_QUERY_PORT(mdev, priv->port)) {
+			if (priv->port_state.link_state) {
+				priv->last_link_state = MLX4_DEV_EVENT_PORT_UP;
+				netif_carrier_on(dev);
+				en_dbg(LINK, priv, "Link Up\n");
+			}
+		}
+	}
+
 	/*
 	 * Promsicuous mode: disable all filters
 	 */
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index 2863a30..8b3c537 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -41,6 +41,37 @@
 #include "mlx4_en.h"
 
 
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
+
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 {
 	struct mlx4_en_stat_out_mbox *mlx4_en_stats;
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index 40918ab..8c387a0 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -42,6 +42,21 @@ enum {
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
+
 struct mlx4_en_stat_out_mbox {
 	/* Received frames with a length of 64 octets */
 	__be64 R64_prio_0;
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 834fd24..5f6c080 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -391,6 +391,12 @@ struct mlx4_en_rss_context {
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
@@ -439,6 +445,7 @@ struct mlx4_en_priv {
 	struct vlan_group *vlgrp;
 	struct net_device_stats stats;
 	struct net_device_stats ret_stats;
+	struct mlx4_en_port_state port_state;
 	spinlock_t stats_lock;
 
 	unsigned long last_moder_packets;
@@ -563,6 +570,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 			   u8 promisc);
 
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
+int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
 
 u64 mlx4_en_mac_to_u64(u8 *addr);
 /*
-- 
1.6.1.3


