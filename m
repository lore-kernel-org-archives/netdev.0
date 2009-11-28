From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/12] sfc: Always start Falcon using the XMAC
Date: Sat, 28 Nov 2009 15:35:00 +0000
Message-ID: <1259422500.3709.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59098 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbZK1Pe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:34:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

The strap bits are only important on Falcon A and all production
boards using it have fixed-speed 10G PHYs.

Replace dummy MAC operations with default MAC operations.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    6 +-----
 drivers/net/sfc/falcon.c     |   15 ++++++++++++---
 drivers/net/sfc/net_driver.h |    3 +++
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 6338ad8..bed45a5 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1891,10 +1891,6 @@ bool efx_port_dummy_op_poll(struct efx_nic *efx)
 	return false;
 }
 
-static struct efx_mac_operations efx_dummy_mac_operations = {
-	.reconfigure	= efx_port_dummy_op_void,
-};
-
 static struct efx_phy_operations efx_dummy_phy_operations = {
 	.init		 = efx_port_dummy_op_int,
 	.reconfigure	 = efx_port_dummy_op_void,
@@ -1936,7 +1932,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	spin_lock_init(&efx->netif_stop_lock);
 	spin_lock_init(&efx->stats_lock);
 	mutex_init(&efx->mac_lock);
-	efx->mac_op = &efx_dummy_mac_operations;
+	efx->mac_op = type->default_mac_ops;
 	efx->phy_op = &efx_dummy_phy_operations;
 	efx->mdio.dev = net_dev;
 	INIT_WORK(&efx->mac_work, efx_mac_work);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 372dbbc..9c4f898 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2291,6 +2291,10 @@ int falcon_probe_port(struct efx_nic *efx)
 	efx->mdio.mdio_read = falcon_mdio_read;
 	efx->mdio.mdio_write = falcon_mdio_write;
 
+	/* Initial assumption */
+	efx->link_state.speed = 10000;
+	efx->link_state.fd = true;
+
 	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation */
 	if (falcon_rev(efx) >= FALCON_REV_B0)
 		efx->wanted_fc = EFX_FC_RX | EFX_FC_TX;
@@ -2809,6 +2813,10 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 		return -ENODEV;
 
 	case FALCON_REV_A1:
+		if (EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) == 0) {
+			EFX_ERR(efx, "Falcon rev A1 1G not supported\n");
+			return -ENODEV;
+		}
 		if (EFX_OWORD_FIELD(nic_stat, FRF_AA_STRAP_PCIE) == 0) {
 			EFX_ERR(efx, "Falcon rev A1 PCI-X not supported\n");
 			return -ENODEV;
@@ -2823,9 +2831,6 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 		return -ENODEV;
 	}
 
-	/* Initial assumed speed */
-	efx->link_state.speed = EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) ? 10000 : 1000;
-
 	return 0;
 }
 
@@ -3238,6 +3243,8 @@ void falcon_stop_nic_stats(struct efx_nic *efx)
  */
 
 struct efx_nic_type falcon_a_nic_type = {
+	.default_mac_ops = &falcon_xmac_operations,
+
 	.mem_map_size = 0x20000,
 	.txd_ptr_tbl_base = FR_AA_TX_DESC_PTR_TBL_KER,
 	.rxd_ptr_tbl_base = FR_AA_RX_DESC_PTR_TBL_KER,
@@ -3251,6 +3258,8 @@ struct efx_nic_type falcon_a_nic_type = {
 };
 
 struct efx_nic_type falcon_b_nic_type = {
+	.default_mac_ops = &falcon_xmac_operations,
+
 	/* Map everything up to and including the RSS indirection
 	 * table.  Don't map MSI-X table, MSI-X PBA since Linux
 	 * requires that they not be mapped.  */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 0aeaeda..57f8614 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -843,6 +843,7 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
 
 /**
  * struct efx_nic_type - Efx device type definition
+ * @default_mac_ops: efx_mac_operations to set at startup
  * @mem_map_size: Memory BAR mapped size
  * @txd_ptr_tbl_base: TX descriptor ring base address
  * @rxd_ptr_tbl_base: RX descriptor ring base address
@@ -857,6 +858,8 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  *	descriptors
  */
 struct efx_nic_type {
+	struct efx_mac_operations *default_mac_ops;
+
 	unsigned int mem_map_size;
 	unsigned int txd_ptr_tbl_base;
 	unsigned int rxd_ptr_tbl_base;
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

