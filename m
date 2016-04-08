From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] mlxsw: Pass mlxsw_core as a param of mlxsw_core_skb_transmit*
Date: Fri,  8 Apr 2016 17:45:22 +0200
Message-ID: <1460130325-14931-3-git-send-email-jiri@resnulli.us>
References: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32872 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbcDHPpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:45:32 -0400
Received: by mail-wm0-f65.google.com with SMTP id y144so5276542wmd.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 08:45:31 -0700 (PDT)
In-Reply-To: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Instead of passing around driver priv, pass struct mlxsw_core *
directly.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 15 +++------------
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  5 ++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  4 ++--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  4 ++--
 4 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 004fb8b..39161fb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -381,7 +381,7 @@ static int __mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
 
 	mlxsw_core->emad.trans_active = true;
 
-	err = mlxsw_core_skb_transmit(mlxsw_core->driver_priv, skb, tx_info);
+	err = mlxsw_core_skb_transmit(mlxsw_core, skb, tx_info);
 	if (err) {
 		dev_err(mlxsw_core->bus_info->dev, "Failed to transmit EMAD (tid=%llx)\n",
 			mlxsw_core->emad.tid);
@@ -929,26 +929,17 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 }
 EXPORT_SYMBOL(mlxsw_core_bus_device_unregister);
 
-static struct mlxsw_core *__mlxsw_core_get(void *driver_priv)
-{
-	return container_of(driver_priv, struct mlxsw_core, driver_priv);
-}
-
-bool mlxsw_core_skb_transmit_busy(void *driver_priv,
+bool mlxsw_core_skb_transmit_busy(struct mlxsw_core *mlxsw_core,
 				  const struct mlxsw_tx_info *tx_info)
 {
-	struct mlxsw_core *mlxsw_core = __mlxsw_core_get(driver_priv);
-
 	return mlxsw_core->bus->skb_transmit_busy(mlxsw_core->bus_priv,
 						  tx_info);
 }
 EXPORT_SYMBOL(mlxsw_core_skb_transmit_busy);
 
-int mlxsw_core_skb_transmit(void *driver_priv, struct sk_buff *skb,
+int mlxsw_core_skb_transmit(struct mlxsw_core *mlxsw_core, struct sk_buff *skb,
 			    const struct mlxsw_tx_info *tx_info)
 {
-	struct mlxsw_core *mlxsw_core = __mlxsw_core_get(driver_priv);
-
 	return mlxsw_core->bus->skb_transmit(mlxsw_core->bus_priv, skb,
 					     tx_info);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 06631a0..0454212 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -75,10 +75,9 @@ struct mlxsw_tx_info {
 	bool is_emad;
 };
 
-bool mlxsw_core_skb_transmit_busy(void *driver_priv,
+bool mlxsw_core_skb_transmit_busy(struct mlxsw_core *mlxsw_core,
 				  const struct mlxsw_tx_info *tx_info);
-
-int mlxsw_core_skb_transmit(void *driver_priv, struct sk_buff *skb,
+int mlxsw_core_skb_transmit(struct mlxsw_core *mlxsw_core, struct sk_buff *skb,
 			    const struct mlxsw_tx_info *tx_info);
 
 struct mlxsw_rx_listener {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3216f2b..8abe1a6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -390,7 +390,7 @@ static netdev_tx_t mlxsw_sp_port_xmit(struct sk_buff *skb,
 	u64 len;
 	int err;
 
-	if (mlxsw_core_skb_transmit_busy(mlxsw_sp, &tx_info))
+	if (mlxsw_core_skb_transmit_busy(mlxsw_sp->core, &tx_info))
 		return NETDEV_TX_BUSY;
 
 	if (unlikely(skb_headroom(skb) < MLXSW_TXHDR_LEN)) {
@@ -414,7 +414,7 @@ static netdev_tx_t mlxsw_sp_port_xmit(struct sk_buff *skb,
 	/* Due to a race we might fail here because of a full queue. In that
 	 * unlikely case we simply drop the packet.
 	 */
-	err = mlxsw_core_skb_transmit(mlxsw_sp, skb, &tx_info);
+	err = mlxsw_core_skb_transmit(mlxsw_sp->core, skb, &tx_info);
 
 	if (!err) {
 		pcpu_stats = this_cpu_ptr(mlxsw_sp_port->pcpu_stats);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 2417f09..2518c84 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -302,7 +302,7 @@ static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
 	u64 len;
 	int err;
 
-	if (mlxsw_core_skb_transmit_busy(mlxsw_sx, &tx_info))
+	if (mlxsw_core_skb_transmit_busy(mlxsw_sx->core, &tx_info))
 		return NETDEV_TX_BUSY;
 
 	if (unlikely(skb_headroom(skb) < MLXSW_TXHDR_LEN)) {
@@ -320,7 +320,7 @@ static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
 	/* Due to a race we might fail here because of a full queue. In that
 	 * unlikely case we simply drop the packet.
 	 */
-	err = mlxsw_core_skb_transmit(mlxsw_sx, skb, &tx_info);
+	err = mlxsw_core_skb_transmit(mlxsw_sx->core, skb, &tx_info);
 
 	if (!err) {
 		pcpu_stats = this_cpu_ptr(mlxsw_sx_port->pcpu_stats);
-- 
2.5.5
