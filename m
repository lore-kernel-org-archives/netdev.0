From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/4] mlxsw: Add bus capability flag
Date: Wed, 16 Nov 2016 15:20:43 +0100
Message-ID: <1479306046-13324-2-git-send-email-jiri@resnulli.us>
References: <1479306046-13324-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, vadimp@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34730 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbcKPOUv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:20:51 -0500
Received: by mail-wm0-f68.google.com with SMTP id g23so11664831wme.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:20:51 -0800 (PST)
In-Reply-To: <1479306046-13324-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Pasternak <vadimp@mellanox.com>

The mlxsw core infrastructure currently assumes that communication with
the ASIC is always possible using Ethernet management datagrams (EMADs),
but this is only possible when the PCI bus is used.

The bus capability flag is added to indicate EMAD support and make core
initialize EMAD communication only when it's set. Otherwise, register
access is done using command interface.

Signed-off-by: Vadim Pasternak <vadimp@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 6 ++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h | 3 +++
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 1 +
 3 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 7874e30..33b0cd4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -598,6 +598,9 @@ static int mlxsw_emad_init(struct mlxsw_core *mlxsw_core)
 	u64 tid;
 	int err;
 
+	if (!(mlxsw_core->bus->features & MLXSW_BUS_F_TXRX))
+		return 0;
+
 	/* Set the upper 32 bits of the transaction ID field to a random
 	 * number. This allows us to discard EMADs addressed to other
 	 * devices.
@@ -634,6 +637,9 @@ static void mlxsw_emad_fini(struct mlxsw_core *mlxsw_core)
 {
 	char hpkt_pl[MLXSW_REG_HPKT_LEN];
 
+	if (!(mlxsw_core->bus->features & MLXSW_BUS_F_TXRX))
+		return;
+
 	mlxsw_core->emad.use_emad = false;
 	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_DISCARD,
 			    MLXSW_TRAP_ID_ETHEMAD);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index e382ed0..a2bd6c6a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -269,6 +269,8 @@ u64 mlxsw_core_res_get(struct mlxsw_core *mlxsw_core,
 #define MLXSW_CORE_RES_GET(res, short_res_id)			\
 	mlxsw_core_res_get(res, MLXSW_RES_ID_##short_res_id)
 
+#define MLXSW_BUS_F_TXRX	BIT(0)
+
 struct mlxsw_bus {
 	const char *kind;
 	int (*init)(void *bus_priv, struct mlxsw_core *mlxsw_core,
@@ -284,6 +286,7 @@ struct mlxsw_bus {
 			char *in_mbox, size_t in_mbox_size,
 			char *out_mbox, size_t out_mbox_size,
 			u8 *p_status);
+	u8 features;
 };
 
 struct mlxsw_bus_info {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index d5cf1ea..a223c85 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1755,6 +1755,7 @@ static const struct mlxsw_bus mlxsw_pci_bus = {
 	.skb_transmit_busy	= mlxsw_pci_skb_transmit_busy,
 	.skb_transmit		= mlxsw_pci_skb_transmit,
 	.cmd_exec		= mlxsw_pci_cmd_exec,
+	.features		= MLXSW_BUS_F_TXRX,
 };
 
 static int mlxsw_pci_sw_reset(struct mlxsw_pci *mlxsw_pci,
-- 
2.7.4
