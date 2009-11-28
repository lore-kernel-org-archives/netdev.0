From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/32] sfc: Turn pause frame generation on and off at the
	MAC, not the RX FIFO
Date: Sat, 28 Nov 2009 03:49:02 +0000
Message-ID: <1259380142.2811.36.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42630 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbZK1Ds6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:48:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pause frame generation is gated by both RX_XOFF_MAC_EN and an enable
bit in each MAC.  RX_XOFF_MAC_EN bit always reads back as 0 so we need
to set it correctly every time we modify RX_CFG_REG.  Simplify this by
always setting it to 1 and only changing the enable bits in the MACs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c      |   13 ++++++-------
 drivers/net/sfc/falcon_xmac.c |    3 ++-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9868e4a..744fce9 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1939,7 +1939,6 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	struct efx_link_state *link_state = &efx->link_state;
 	efx_oword_t reg;
 	int link_speed;
-	bool tx_fc;
 
 	switch (link_state->speed) {
 	case 10000: link_speed = 3; break;
@@ -1969,13 +1968,10 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	/* Restore the multicast hash registers. */
 	falcon_push_multicast_hash(efx);
 
-	/* Transmission of pause frames when RX crosses the threshold is
-	 * covered by RX_XOFF_MAC_EN and XM_TX_CFG_REG:XM_FCNTL.
-	 * Action on receipt of pause frames is controller by XM_DIS_FCNTL */
-	tx_fc = !!(efx->link_state.fc & EFX_FC_TX);
 	efx_reado(efx, &reg, FR_AZ_RX_CFG);
-	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, tx_fc);
-
+	/* Enable XOFF signal from RX FIFO (we enabled it during NIC
+	 * initialisation but it may read back as 0) */
+	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, 1);
 	/* Unisolate the MAC -> RX */
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
@@ -3000,6 +2996,9 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_TX_TH, ctrl_xoff_thr);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
 	}
+	/* Always enable XOFF signal from RX FIFO.  We enable
+	 * or disable transmission of pause frames at the MAC. */
+	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, 1);
 	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 }
 
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 1523efd..60dc097 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -148,6 +148,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 	unsigned int max_frame_len;
 	efx_oword_t reg;
 	bool rx_fc = !!(efx->link_state.fc & EFX_FC_RX);
+	bool tx_fc = !!(efx->link_state.fc & EFX_FC_TX);
 
 	/* Configure MAC  - cut-thru mode is hard wired on */
 	EFX_POPULATE_OWORD_3(reg,
@@ -162,7 +163,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 			     FRF_AB_XM_TX_PRMBL, 1,
 			     FRF_AB_XM_AUTO_PAD, 1,
 			     FRF_AB_XM_TXCRC, 1,
-			     FRF_AB_XM_FCNTL, 1,
+			     FRF_AB_XM_FCNTL, tx_fc,
 			     FRF_AB_XM_IPG, 0x3);
 	efx_writeo(efx, &reg, FR_AB_XM_TX_CFG);
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

