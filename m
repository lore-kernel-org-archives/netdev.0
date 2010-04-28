From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/17] sfc: Enable IPv6 RSS using random key for Toeplitz
 hash
Date: Wed, 28 Apr 2010 20:29:02 +0100
Message-ID: <1272482942.2549.25.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12533 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab0D1T3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:29:05 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.h   |    2 ++
 drivers/net/sfc/siena.c |   19 +++++++++++++++++++
 2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 7e3bec8..5825f37 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -135,12 +135,14 @@ static inline struct falcon_board *falcon_board(struct efx_nic *efx)
  * @fw_build: Firmware build number
  * @mcdi: Management-Controller-to-Driver Interface
  * @wol_filter_id: Wake-on-LAN packet filter id
+ * @ipv6_rss_key: Toeplitz hash key for IPv6 RSS
  */
 struct siena_nic_data {
 	u64 fw_version;
 	u32 fw_build;
 	struct efx_mcdi_iface mcdi;
 	int wol_filter_id;
+	u8 ipv6_rss_key[40];
 };
 
 extern void siena_print_fwver(struct efx_nic *efx, char *buf, size_t len);
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 38dcc42..7bf93fa 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -13,6 +13,7 @@
 #include <linux/pci.h>
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/random.h>
 #include "net_driver.h"
 #include "bitfield.h"
 #include "efx.h"
@@ -274,6 +275,9 @@ static int siena_probe_nic(struct efx_nic *efx)
 		goto fail5;
 	}
 
+	get_random_bytes(&nic_data->ipv6_rss_key,
+			 sizeof(nic_data->ipv6_rss_key));
+
 	return 0;
 
 fail5:
@@ -293,6 +297,7 @@ fail1:
  */
 static int siena_init_nic(struct efx_nic *efx)
 {
+	struct siena_nic_data *nic_data = efx->nic_data;
 	efx_oword_t temp;
 	int rc;
 
@@ -319,6 +324,20 @@ static int siena_init_nic(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(temp, FRF_BZ_RX_INGR_EN, 1);
 	efx_writeo(efx, &temp, FR_AZ_RX_CFG);
 
+	/* Enable IPv6 RSS */
+	BUILD_BUG_ON(sizeof(nic_data->ipv6_rss_key) !=
+		     2 * sizeof(temp) + FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8 ||
+		     FRF_CZ_RX_RSS_IPV6_TKEY_HI_LBN != 0);
+	memcpy(&temp, nic_data->ipv6_rss_key, sizeof(temp));
+	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG1);
+	memcpy(&temp, nic_data->ipv6_rss_key + sizeof(temp), sizeof(temp));
+	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG2);
+	EFX_POPULATE_OWORD_2(temp, FRF_CZ_RX_RSS_IPV6_THASH_ENABLE, 1,
+			     FRF_CZ_RX_RSS_IPV6_IP_THASH_ENABLE, 1);
+	memcpy(&temp, nic_data->ipv6_rss_key + 2 * sizeof(temp),
+	       FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8);
+	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG3);
+
 	if (efx_nic_rx_xoff_thresh >= 0 || efx_nic_rx_xon_thresh >= 0)
 		/* No MCDI operation has been defined to set thresholds */
 		EFX_ERR(efx, "ignoring RX flow control thresholds\n");
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

