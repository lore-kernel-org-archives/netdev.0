From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: don't report RX hash keys to ethtool when RSS wasn't
 enabled
Date: Wed, 4 Jan 2017 15:10:56 +0000
Message-ID: <5a4ac10d-3b4b-bf48-e4ca-c435eed29dc3@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:60095 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S968259AbdADPLH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 10:11:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we failed to set up RSS on EF10 (e.g. because firmware declared
 RX_RSS_LIMITED), ethtool --show-nfc $dev rx-flow-hash ... should report
 no fields, rather than confusingly reporting what fields we _would_ be
 hashing on if RSS was working.

Fixes: dcb4123cbec0 ("sfc: disable RSS when unsupported")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 3 ++-
 drivers/net/ethernet/sfc/ethtool.c    | 2 ++
 drivers/net/ethernet/sfc/net_driver.h | 2 ++
 drivers/net/ethernet/sfc/siena.c      | 1 +
 4 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index de2947c..5eb0e68 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1323,7 +1323,8 @@ static int efx_ef10_init_nic(struct efx_nic *efx)
 	}
 
 	/* don't fail init if RSS setup doesn't work */
-	efx->type->rx_push_rss_config(efx, false, efx->rx_indir_table);
+	rc = efx->type->rx_push_rss_config(efx, false, efx->rx_indir_table);
+	efx->rss_active = (rc == 0);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 87bdc56..18ebaea 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -975,6 +975,8 @@ efx_ethtool_get_rxnfc(struct net_device *net_dev,
 
 	case ETHTOOL_GRXFH: {
 		info->data = 0;
+		if (!efx->rss_active) /* No RSS */
+			return 0;
 		switch (info->flow_type) {
 		case UDP_V4_FLOW:
 			if (efx->rx_hash_udp_4tuple)
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 1a635ce..1c62c1a 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -860,6 +860,7 @@ struct vfdi_status;
  * @rx_hash_key: Toeplitz hash key for RSS
  * @rx_indir_table: Indirection table for RSS
  * @rx_scatter: Scatter mode enabled for receives
+ * @rss_active: RSS enabled on hardware
  * @rx_hash_udp_4tuple: UDP 4-tuple hashing enabled
  * @int_error_count: Number of internal errors seen recently
  * @int_error_expire: Time at which error count will be expired
@@ -998,6 +999,7 @@ struct efx_nic {
 	u8 rx_hash_key[40];
 	u32 rx_indir_table[128];
 	bool rx_scatter;
+	bool rss_active;
 	bool rx_hash_udp_4tuple;
 
 	unsigned int_error_count;
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index a3901bc..4e54e5d 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -403,6 +403,7 @@ static int siena_init_nic(struct efx_nic *efx)
 	efx_writeo(efx, &temp, FR_AZ_RX_CFG);
 
 	siena_rx_push_rss_config(efx, false, efx->rx_indir_table);
+	efx->rss_active = true;
 
 	/* Enable event logging */
 	rc = efx_mcdi_log_ctrl(efx, true, false, 0);
