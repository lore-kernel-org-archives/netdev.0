From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/4] sfc: Move siena_nic_data::ipv6_rss_key to
 efx_nic::rx_hash_key
Date: Fri, 25 Jun 2010 18:05:43 +0100
Message-ID: <1277485543.2094.15.camel@achroite.uk.solarflarecom.com>
References: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20338 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520Ab0FYRFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 13:05:46 -0400
In-Reply-To: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will use this hash key for Toeplitz IPv4 hashing too.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    3 +++
 drivers/net/sfc/net_driver.h |    1 +
 drivers/net/sfc/nic.h        |    1 -
 drivers/net/sfc/siena.c      |   12 ++++--------
 4 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d68f061..2a90bf9 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1134,6 +1134,9 @@ static int efx_probe_nic(struct efx_nic *efx)
 	 * in MSI-X interrupts. */
 	efx_probe_interrupts(efx);
 
+	if (efx->n_channels > 1)
+		get_random_bytes(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
+
 	efx_set_channels(efx);
 	efx->net_dev->real_num_tx_queues = efx->n_tx_channels;
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 8b17c92..ba272a4 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -733,6 +733,7 @@ struct efx_nic {
 	unsigned n_tx_channels;
 	unsigned int rx_buffer_len;
 	unsigned int rx_buffer_order;
+	u8 rx_hash_key[40];
 
 	unsigned int_error_count;
 	unsigned long int_error_expire;
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 534461f..a39822d 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -142,7 +142,6 @@ struct siena_nic_data {
 	u32 fw_build;
 	struct efx_mcdi_iface mcdi;
 	int wol_filter_id;
-	u8 ipv6_rss_key[40];
 };
 
 extern void siena_print_fwver(struct efx_nic *efx, char *buf, size_t len);
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index f1741b4..7fd258c 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -285,9 +285,6 @@ static int siena_probe_nic(struct efx_nic *efx)
 		goto fail5;
 	}
 
-	get_random_bytes(&nic_data->ipv6_rss_key,
-			 sizeof(nic_data->ipv6_rss_key));
-
 	return 0;
 
 fail5:
@@ -307,7 +304,6 @@ fail1:
  */
 static int siena_init_nic(struct efx_nic *efx)
 {
-	struct siena_nic_data *nic_data = efx->nic_data;
 	efx_oword_t temp;
 	int rc;
 
@@ -336,16 +332,16 @@ static int siena_init_nic(struct efx_nic *efx)
 	efx_writeo(efx, &temp, FR_AZ_RX_CFG);
 
 	/* Enable IPv6 RSS */
-	BUILD_BUG_ON(sizeof(nic_data->ipv6_rss_key) !=
+	BUILD_BUG_ON(sizeof(efx->rx_hash_key) <
 		     2 * sizeof(temp) + FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8 ||
 		     FRF_CZ_RX_RSS_IPV6_TKEY_HI_LBN != 0);
-	memcpy(&temp, nic_data->ipv6_rss_key, sizeof(temp));
+	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
 	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG1);
-	memcpy(&temp, nic_data->ipv6_rss_key + sizeof(temp), sizeof(temp));
+	memcpy(&temp, efx->rx_hash_key + sizeof(temp), sizeof(temp));
 	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG2);
 	EFX_POPULATE_OWORD_2(temp, FRF_CZ_RX_RSS_IPV6_THASH_ENABLE, 1,
 			     FRF_CZ_RX_RSS_IPV6_IP_THASH_ENABLE, 1);
-	memcpy(&temp, nic_data->ipv6_rss_key + 2 * sizeof(temp),
+	memcpy(&temp, efx->rx_hash_key + 2 * sizeof(temp),
 	       FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8);
 	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG3);
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

