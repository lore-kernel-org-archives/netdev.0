From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/7] mlxsw: Simplify mlxsw_sx_port_xmit function
Date: Thu,  6 Aug 2015 16:41:56 +0200
Message-ID: <1438872118-16869-6-git-send-email-jiri@resnulli.us>
References: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:36781 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865AbbHFOmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 10:42:15 -0400
Received: by wicgj17 with SMTP id gj17so25583779wic.1
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 07:42:14 -0700 (PDT)
In-Reply-To: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Previously we only checked if the transmission queue is not full in the
middle of the xmit function. This lead to complex logic due to the fact
that sometimes we need to reallocate the headroom for our Tx header.

Allow the switch driver to know if the transmission queue is not full
before sending the packet and remove this complex logic.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 10 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  5 +++++
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 20 +++++++++++++++-----
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 25 ++++++++++---------------
 4 files changed, 40 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index ad66ae4..7562802 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -865,6 +865,16 @@ static struct mlxsw_core *__mlxsw_core_get(void *driver_priv)
 	return container_of(driver_priv, struct mlxsw_core, driver_priv);
 }
 
+bool mlxsw_core_skb_transmit_busy(void *driver_priv,
+				  const struct mlxsw_tx_info *tx_info)
+{
+	struct mlxsw_core *mlxsw_core = __mlxsw_core_get(driver_priv);
+
+	return mlxsw_core->bus->skb_transmit_busy(mlxsw_core->bus_priv,
+						  tx_info);
+}
+EXPORT_SYMBOL(mlxsw_core_skb_transmit_busy);
+
 int mlxsw_core_skb_transmit(void *driver_priv, struct sk_buff *skb,
 			    const struct mlxsw_tx_info *tx_info)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 2280b31..1658084 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -73,6 +73,9 @@ struct mlxsw_tx_info {
 	bool is_emad;
 };
 
+bool mlxsw_core_skb_transmit_busy(void *driver_priv,
+				  const struct mlxsw_tx_info *tx_info);
+
 int mlxsw_core_skb_transmit(void *driver_priv, struct sk_buff *skb,
 			    const struct mlxsw_tx_info *tx_info);
 
@@ -177,6 +180,8 @@ struct mlxsw_bus {
 	int (*init)(void *bus_priv, struct mlxsw_core *mlxsw_core,
 		    const struct mlxsw_config_profile *profile);
 	void (*fini)(void *bus_priv);
+	bool (*skb_transmit_busy)(void *bus_priv,
+				  const struct mlxsw_tx_info *tx_info);
 	int (*skb_transmit)(void *bus_priv, struct sk_buff *skb,
 			    const struct mlxsw_tx_info *tx_info);
 	int (*cmd_exec)(void *bus_priv, u16 opcode, u8 opcode_mod,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 3ec52ea..a34f474 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1443,6 +1443,15 @@ mlxsw_pci_sdq_pick(struct mlxsw_pci *mlxsw_pci,
 	return mlxsw_pci_sdq_get(mlxsw_pci, sdqn);
 }
 
+static bool mlxsw_pci_skb_transmit_busy(void *bus_priv,
+					const struct mlxsw_tx_info *tx_info)
+{
+	struct mlxsw_pci *mlxsw_pci = bus_priv;
+	struct mlxsw_pci_queue *q = mlxsw_pci_sdq_pick(mlxsw_pci, tx_info);
+
+	return !mlxsw_pci_queue_elem_info_producer_get(q);
+}
+
 static int mlxsw_pci_skb_transmit(void *bus_priv, struct sk_buff *skb,
 				  const struct mlxsw_tx_info *tx_info)
 {
@@ -1625,11 +1634,12 @@ err_in_mbox_map:
 }
 
 static const struct mlxsw_bus mlxsw_pci_bus = {
-	.kind		= "pci",
-	.init		= mlxsw_pci_init,
-	.fini		= mlxsw_pci_fini,
-	.skb_transmit	= mlxsw_pci_skb_transmit,
-	.cmd_exec	= mlxsw_pci_cmd_exec,
+	.kind			= "pci",
+	.init			= mlxsw_pci_init,
+	.fini			= mlxsw_pci_fini,
+	.skb_transmit_busy	= mlxsw_pci_skb_transmit_busy,
+	.skb_transmit		= mlxsw_pci_skb_transmit,
+	.cmd_exec		= mlxsw_pci_cmd_exec,
 };
 
 static int mlxsw_pci_sw_reset(struct mlxsw_pci *mlxsw_pci)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 7eb045e..fce9b45 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -300,31 +300,26 @@ static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
 		.local_port = mlxsw_sx_port->local_port,
 		.is_emad = false,
 	};
-	struct sk_buff *skb_old = NULL;
 	int err;
 
+	if (mlxsw_core_skb_transmit_busy(mlxsw_sx, &tx_info))
+		return NETDEV_TX_BUSY;
+
 	if (unlikely(skb_headroom(skb) < MLXSW_TXHDR_LEN)) {
-		struct sk_buff *skb_new;
+		struct sk_buff *skb_orig = skb;
 
-		skb_old = skb;
-		skb_new = skb_realloc_headroom(skb, MLXSW_TXHDR_LEN);
-		if (!skb_new) {
+		skb = skb_realloc_headroom(skb, MLXSW_TXHDR_LEN);
+		if (!skb) {
 			this_cpu_inc(mlxsw_sx_port->pcpu_stats->tx_dropped);
-			dev_kfree_skb_any(skb_old);
+			dev_kfree_skb_any(skb_orig);
 			return NETDEV_TX_OK;
 		}
-		skb = skb_new;
 	}
 	mlxsw_sx_txhdr_construct(skb, &tx_info);
+	/* Due to a race we might fail here because of a full queue. In that
+	 * unlikely case we simply drop the packet.
+	 */
 	err = mlxsw_core_skb_transmit(mlxsw_sx, skb, &tx_info);
-	if (err == -EAGAIN) {
-		if (skb_old)
-			dev_kfree_skb_any(skb);
-		return NETDEV_TX_BUSY;
-	}
-
-	if (skb_old)
-		dev_kfree_skb_any(skb_old);
 
 	if (!err) {
 		pcpu_stats = this_cpu_ptr(mlxsw_sx_port->pcpu_stats);
-- 
1.9.3
