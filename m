From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 13/17] sfc: Move xmac_poll_required into
 struct falcon_nic_data
Date: Thu, 02 Dec 2010 23:47:51 +0000
Message-ID: <1291333671.3259.36.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13117 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358Ab0LBXry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:47:54 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c        |    3 ++-
 drivers/net/sfc/falcon_boards.c |    3 ++-
 drivers/net/sfc/falcon_xmac.c   |   13 +++++++++----
 drivers/net/sfc/net_driver.h    |    2 --
 drivers/net/sfc/nic.h           |    2 ++
 5 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index fd5bf0b..07f684e 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -886,6 +886,7 @@ static bool
 falcon_handle_global_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	struct efx_nic *efx = channel->efx;
+	struct falcon_nic_data *nic_data = efx->nic_data;
 
 	if (EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_G_PHY0_INTR) ||
 	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XG_PHY0_INTR) ||
@@ -895,7 +896,7 @@ falcon_handle_global_event(struct efx_channel *channel, efx_qword_t *event)
 
 	if ((efx_nic_rev(efx) == EFX_REV_FALCON_B0) &&
 	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_XG_MGT_INTR)) {
-		efx->xmac_poll_required = true;
+		nic_data->xmac_poll_required = true;
 		return true;
 	}
 
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index a6fc5ce..2dd16f0 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -415,10 +415,11 @@ static void sfe4001_fini(struct efx_nic *efx)
 
 static int sfe4001_check_hw(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	s32 status;
 
 	/* If XAUI link is up then do not monitor */
-	if (EFX_WORKAROUND_7884(efx) && !efx->xmac_poll_required)
+	if (EFX_WORKAROUND_7884(efx) && !nic_data->xmac_poll_required)
 		return 0;
 
 	/* Check the powered status of the PHY. Lack of power implies that
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index e293e25..b49e843 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -87,6 +87,7 @@ int falcon_reset_xaui(struct efx_nic *efx)
 
 static void falcon_ack_status_intr(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	efx_oword_t reg;
 
 	if ((efx_nic_rev(efx) != EFX_REV_FALCON_B0) || LOOPBACK_INTERNAL(efx))
@@ -98,7 +99,7 @@ static void falcon_ack_status_intr(struct efx_nic *efx)
 
 	/* We can only use this interrupt to signal the negative edge of
 	 * xaui_align [we have to poll the positive edge]. */
-	if (efx->xmac_poll_required)
+	if (nic_data->xmac_poll_required)
 		return;
 
 	efx_reado(efx, &reg, FR_AB_XM_MGT_INT_MSK);
@@ -276,12 +277,14 @@ static bool falcon_xmac_check_fault(struct efx_nic *efx)
 
 static int falcon_reconfigure_xmac(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data = efx->nic_data;
+
 	falcon_reconfigure_xgxs_core(efx);
 	falcon_reconfigure_xmac_core(efx);
 
 	falcon_reconfigure_mac_wrapper(efx);
 
-	efx->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 5);
+	nic_data->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 5);
 	falcon_ack_status_intr(efx);
 
 	return 0;
@@ -349,11 +352,13 @@ static void falcon_update_stats_xmac(struct efx_nic *efx)
 
 void falcon_poll_xmac(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data = efx->nic_data;
+
 	if (!EFX_WORKAROUND_5147(efx) || !efx->link_state.up ||
-	    !efx->xmac_poll_required)
+	    !nic_data->xmac_poll_required)
 		return;
 
-	efx->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 1);
+	nic_data->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 1);
 	falcon_ack_status_intr(efx);
 }
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index f9d53a0..b7e8fe9 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -684,7 +684,6 @@ struct efx_filter_state;
  * @mdio: PHY MDIO interface
  * @mdio_bus: PHY MDIO bus ID (only used by Siena)
  * @phy_mode: PHY operating mode. Serialised by @mac_lock.
- * @xmac_poll_required: XMAC link state needs polling
  * @link_advertising: Autonegotiation advertising flags
  * @link_state: Current state of the link
  * @n_link_state_changes: Number of times the link has changed state
@@ -771,7 +770,6 @@ struct efx_nic {
 	unsigned int mdio_bus;
 	enum efx_phy_mode phy_mode;
 
-	bool xmac_poll_required;
 	u32 link_advertising;
 	struct efx_link_state link_state;
 	unsigned int n_link_state_changes;
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 980cf4b..f107dc7 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -118,6 +118,7 @@ struct falcon_board {
  * @spi_eeprom: SPI EEPROM device
  * @spi_lock: SPI bus lock
  * @mdio_lock: MDIO bus lock
+ * @xmac_poll_required: XMAC link state needs polling
  */
 struct falcon_nic_data {
 	struct pci_dev *pci_dev2;
@@ -130,6 +131,7 @@ struct falcon_nic_data {
 	struct efx_spi_device spi_eeprom;
 	struct mutex spi_lock;
 	struct mutex mdio_lock;
+	bool xmac_poll_required;
 };
 
 static inline struct falcon_board *falcon_board(struct efx_nic *efx)
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

