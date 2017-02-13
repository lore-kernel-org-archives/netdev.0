From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: MSI-X is the only interrupt mode for EF10
 VFs
Date: Mon, 13 Feb 2017 14:57:39 +0000
Message-ID: <d330fd2c-9ab3-3026-0958-dc696a4d268f@solarflare.com>
References: <2af4ea1f-cdf7-48b2-1712-e25590919f15@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:17391 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751765AbdBMO5r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:57:47 -0500
In-Reply-To: <2af4ea1f-cdf7-48b2-1712-e25590919f15@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

Add min_interrupt_mode specification per NIC type.
It is a bit confusing because of "highest interrupt mode is less capable".

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  2 ++
 drivers/net/ethernet/sfc/efx.c        | 11 +++++++++--
 drivers/net/ethernet/sfc/net_driver.h |  5 ++++-
 drivers/net/ethernet/sfc/siena.c      |  1 +
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 761ccc6..b29a819 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -6456,6 +6456,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.rx_ts_offset = ES_DZ_RX_PREFIX_TSTAMP_OFST,
 	.can_rx_scatter = true,
 	.always_rx_scatter = true,
+	.min_interrupt_mode = EFX_INT_MODE_MSIX,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.timer_period_max = 1 << ERF_DD_EVQ_IND_TIMER_VAL_WIDTH,
 	.offload_features = EF10_OFFLOAD_FEATURES,
@@ -6588,6 +6589,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.can_rx_scatter = true,
 	.always_rx_scatter = true,
 	.option_descriptors = true,
+	.min_interrupt_mode = EFX_INT_MODE_LEGACY,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.timer_period_max = 1 << ERF_DD_EVQ_IND_TIMER_VAL_WIDTH,
 	.offload_features = EF10_OFFLOAD_FEATURES,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index cb8e2c3..88a9f97 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2935,7 +2935,7 @@ static const struct efx_phy_operations efx_dummy_phy_operations = {
 static int efx_init_struct(struct efx_nic *efx,
 			   struct pci_dev *pci_dev, struct net_device *net_dev)
 {
-	int i;
+	int rc = -ENOMEM, i;
 
 	/* Initialise common structures */
 	INIT_LIST_HEAD(&efx->node);
@@ -2976,8 +2976,15 @@ static int efx_init_struct(struct efx_nic *efx,
 	}
 
 	/* Higher numbered interrupt modes are less capable! */
+	if (WARN_ON_ONCE(efx->type->max_interrupt_mode >
+			 efx->type->min_interrupt_mode)) {
+		rc = -EIO;
+		goto fail;
+	}
 	efx->interrupt_mode = max(efx->type->max_interrupt_mode,
 				  interrupt_mode);
+	efx->interrupt_mode = min(efx->type->min_interrupt_mode,
+				  interrupt_mode);
 
 	/* Would be good to use the net_dev name, but we're too early */
 	snprintf(efx->workqueue_name, sizeof(efx->workqueue_name), "sfc%s",
@@ -2990,7 +2997,7 @@ static int efx_init_struct(struct efx_nic *efx,
 
 fail:
 	efx_fini_struct(efx);
-	return -ENOMEM;
+	return rc;
 }
 
 static void efx_fini_struct(struct efx_nic *efx)
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 5cb8112..c0537ea 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1142,8 +1142,10 @@ struct efx_udp_tunnel {
  * @can_rx_scatter: NIC is able to scatter packets to multiple buffers
  * @always_rx_scatter: NIC will always scatter packets to multiple buffers
  * @option_descriptors: NIC supports TX option descriptors
+ * @min_interrupt_mode: Lowest capability interrupt mode supported
+ *	from &enum efx_int_mode.
  * @max_interrupt_mode: Highest capability interrupt mode supported
- *	from &enum efx_init_mode.
+ *	from &enum efx_int_mode.
  * @timer_period_max: Maximum period of interrupt timer (in ticks)
  * @offload_features: net_device feature flags for protocol offload
  *	features implemented in hardware
@@ -1306,6 +1308,7 @@ struct efx_nic_type {
 	bool can_rx_scatter;
 	bool always_rx_scatter;
 	bool option_descriptors;
+	unsigned int min_interrupt_mode;
 	unsigned int max_interrupt_mode;
 	unsigned int timer_period_max;
 	netdev_features_t offload_features;
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index b1d36df..a617f65 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -1069,6 +1069,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.rx_buffer_padding = 0,
 	.can_rx_scatter = true,
 	.option_descriptors = false,
+	.min_interrupt_mode = EFX_INT_MODE_LEGACY,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.timer_period_max = 1 << FRF_CZ_TC_TIMER_VAL_WIDTH,
 	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
