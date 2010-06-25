From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/4] sfc: Use Toeplitz IPv4 hash for RSS and
 hash insertion
Date: Fri, 25 Jun 2010 18:05:56 +0100
Message-ID: <1277485556.2094.16.camel@achroite.uk.solarflarecom.com>
References: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20374 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520Ab0FYRGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 13:06:00 -0400
In-Reply-To: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Insertion of the Falcon hash is unreliable.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   14 ++++++++++++--
 drivers/net/sfc/siena.c  |   11 ++++++++++-
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 5a40145..4f9d33f 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1581,8 +1581,14 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_MAC_TH, data_xoff_thr);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_TX_TH, ctrl_xon_thr);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_TX_TH, ctrl_xoff_thr);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_HASH_INSRT_HDR, 1);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
+
+		/* Enable hash insertion. This is broken for the
+		 * 'Falcon' hash so also select Toeplitz TCP/IPv4 and
+		 * IPv4 hashes. */
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_HASH_INSRT_HDR, 1);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_HASH_ALG, 1);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_IP_HASH, 1);
 	}
 	/* Always enable XOFF signal from RX FIFO.  We enable
 	 * or disable transmission of pause frames at the MAC. */
@@ -1656,8 +1662,12 @@ static int falcon_init_nic(struct efx_nic *efx)
 
 	falcon_init_rx_cfg(efx);
 
-	/* Set destination of both TX and RX Flush events */
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
+		/* Set hash key for IPv4 */
+		memcpy(&temp, efx->rx_hash_key, sizeof(temp));
+		efx_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
+
+		/* Set destination of both TX and RX Flush events */
 		EFX_POPULATE_OWORD_1(temp, FRF_BZ_FLS_EVQ_ID, 0);
 		efx_writeo(efx, &temp, FR_BZ_DP_CTRL);
 	}
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 7fd258c..3fab030 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -327,10 +327,19 @@ static int siena_init_nic(struct efx_nic *efx)
 
 	efx_reado(efx, &temp, FR_AZ_RX_CFG);
 	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_DESC_PUSH_EN, 0);
-	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_HASH_INSRT_HDR, 1);
 	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_INGR_EN, 1);
+	/* Enable hash insertion. This is broken for the 'Falcon' hash
+	 * if IPv6 hashing is also enabled, so also select Toeplitz
+	 * TCP/IPv4 and IPv4 hashes. */
+	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_HASH_INSRT_HDR, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_HASH_ALG, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_IP_HASH, 1);
 	efx_writeo(efx, &temp, FR_AZ_RX_CFG);
 
+	/* Set hash key for IPv4 */
+	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
+	efx_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
+
 	/* Enable IPv6 RSS */
 	BUILD_BUG_ON(sizeof(efx->rx_hash_key) <
 		     2 * sizeof(temp) + FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8 ||
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

