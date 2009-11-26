From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/16] sfc: Treat all MAC registers as 128-bit
Date: Thu, 26 Nov 2009 02:08:41 +0000
Message-ID: <1259201321.2806.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31081 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbZKZCIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:08:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although all the defined fields in these registers are within 32 bits,
they are architecturally defined as 128-bit like most other Falcon
registers.  In particular, we must use efx_reado() to ensure proper
locking when reading MD_STAT_REG.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c      |   14 +++++++-------
 drivers/net/sfc/falcon_xmac.c |   14 +++++++-------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 7b19686..f97ef3e 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2042,18 +2042,18 @@ int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
 /* Wait for GMII access to complete */
 static int falcon_gmii_wait(struct efx_nic *efx)
 {
-	efx_dword_t md_stat;
+	efx_oword_t md_stat;
 	int count;
 
 	/* wait upto 50ms - taken max from datasheet */
 	for (count = 0; count < 5000; count++) {
-		efx_readd(efx, &md_stat, FR_AB_MD_STAT);
-		if (EFX_DWORD_FIELD(md_stat, FRF_AB_MD_BSY) == 0) {
-			if (EFX_DWORD_FIELD(md_stat, FRF_AB_MD_LNFL) != 0 ||
-			    EFX_DWORD_FIELD(md_stat, FRF_AB_MD_BSERR) != 0) {
+		efx_reado(efx, &md_stat, FR_AB_MD_STAT);
+		if (EFX_OWORD_FIELD(md_stat, FRF_AB_MD_BSY) == 0) {
+			if (EFX_OWORD_FIELD(md_stat, FRF_AB_MD_LNFL) != 0 ||
+			    EFX_OWORD_FIELD(md_stat, FRF_AB_MD_BSERR) != 0) {
 				EFX_ERR(efx, "error from GMII access "
-					EFX_DWORD_FMT"\n",
-					EFX_DWORD_VAL(md_stat));
+					EFX_OWORD_FMT"\n",
+					EFX_OWORD_VAL(md_stat));
 				return -EIO;
 			}
 			return 0;
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 69cb55f..cf24513 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -64,7 +64,7 @@ int falcon_reset_xaui(struct efx_nic *efx)
 	int count;
 
 	/* Start reset sequence */
-	EFX_POPULATE_DWORD_1(reg, FRF_AB_XX_RST_XX_EN, 1);
+	EFX_POPULATE_OWORD_1(reg, FRF_AB_XX_RST_XX_EN, 1);
 	efx_writeo(efx, &reg, FR_AB_XX_PWR_RST);
 
 	/* Wait up to 10 ms for completion, then reinitialise */
@@ -146,14 +146,14 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 	bool rx_fc = !!(efx->link_state.fc & EFX_FC_RX);
 
 	/* Configure MAC  - cut-thru mode is hard wired on */
-	EFX_POPULATE_DWORD_3(reg,
+	EFX_POPULATE_OWORD_3(reg,
 			     FRF_AB_XM_RX_JUMBO_MODE, 1,
 			     FRF_AB_XM_TX_STAT_EN, 1,
 			     FRF_AB_XM_RX_STAT_EN, 1);
 	efx_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
 
 	/* Configure TX */
-	EFX_POPULATE_DWORD_6(reg,
+	EFX_POPULATE_OWORD_6(reg,
 			     FRF_AB_XM_TXEN, 1,
 			     FRF_AB_XM_TX_PRMBL, 1,
 			     FRF_AB_XM_AUTO_PAD, 1,
@@ -163,7 +163,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 	efx_writeo(efx, &reg, FR_AB_XM_TX_CFG);
 
 	/* Configure RX */
-	EFX_POPULATE_DWORD_5(reg,
+	EFX_POPULATE_OWORD_5(reg,
 			     FRF_AB_XM_RXEN, 1,
 			     FRF_AB_XM_AUTO_DEPAD, 0,
 			     FRF_AB_XM_ACPT_ALL_MCAST, 1,
@@ -173,14 +173,14 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 
 	/* Set frame length */
 	max_frame_len = EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
-	EFX_POPULATE_DWORD_1(reg, FRF_AB_XM_MAX_RX_FRM_SIZE, max_frame_len);
+	EFX_POPULATE_OWORD_1(reg, FRF_AB_XM_MAX_RX_FRM_SIZE, max_frame_len);
 	efx_writeo(efx, &reg, FR_AB_XM_RX_PARAM);
-	EFX_POPULATE_DWORD_2(reg,
+	EFX_POPULATE_OWORD_2(reg,
 			     FRF_AB_XM_MAX_TX_FRM_SIZE, max_frame_len,
 			     FRF_AB_XM_TX_JUMBO_MODE, 1);
 	efx_writeo(efx, &reg, FR_AB_XM_TX_PARAM);
 
-	EFX_POPULATE_DWORD_2(reg,
+	EFX_POPULATE_OWORD_2(reg,
 			     FRF_AB_XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
 			     FRF_AB_XM_DIS_FCNTL, !rx_fc);
 	efx_writeo(efx, &reg, FR_AB_XM_FC);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

