From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/15] sfc: split setup of hardware timestamping
 into NIC-type operation
Date: Sat, 14 Dec 2013 23:03:59 +0000
Message-ID: <1387062239.12172.66.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17359 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338Ab3LNXEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:04:04 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

I added efx_ptp_get_mode() to avoid moving the definition for
efx_ptp_data, since the current PTP mode is needed for
siena.c:siena_set_ptp_hwtstamp.

[bwh: Also move the rx_filters mask, and add kernel-doc]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    9 ++++
 drivers/net/ethernet/sfc/nic.h        |    3 +
 drivers/net/ethernet/sfc/ptp.c        |   69 +++++----------------------------
 drivers/net/ethernet/sfc/siena.c      |   69 ++++++++++++++++++++++++++------
 4 files changed, 78 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f47bac78b92c..01ffbe849683 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -91,6 +91,7 @@
 
 /* Forward declare Precision Time Protocol (PTP) support structure. */
 struct efx_ptp_data;
+struct hwtstamp_config;
 
 struct efx_self_tests;
 
@@ -1042,6 +1043,10 @@ struct efx_mtd_partition {
  * @mtd_sync: Wait for write-back to complete on MTD partition.  This
  *	also notifies the driver that a writer has finished using this
  *	partition.
+ * @ptp_write_host_time: Send host time to MC as part of sync protocol
+ * @ptp_set_ts_config: Set hardware timestamp configuration.  The flags
+ *	and tx_type will already have been validated but this operation
+ *	must validate and update rx_filter.
  * @revision: Hardware architecture revision
  * @txd_ptr_tbl_base: TX descriptor ring base address
  * @rxd_ptr_tbl_base: RX descriptor ring base address
@@ -1060,6 +1065,7 @@ struct efx_mtd_partition {
  * @offload_features: net_device feature flags for protocol offload
  *	features implemented in hardware
  * @mcdi_max_ver: Maximum MCDI version supported
+ * @hwtstamp_filters: Mask of hardware timestamp filter types supported
  */
 struct efx_nic_type {
 	unsigned int (*mem_map_size)(struct efx_nic *efx);
@@ -1161,6 +1167,8 @@ struct efx_nic_type {
 	int (*mtd_sync)(struct mtd_info *mtd);
 #endif
 	void (*ptp_write_host_time)(struct efx_nic *efx, u32 host_time);
+	int (*ptp_set_ts_config)(struct efx_nic *efx,
+				 struct hwtstamp_config *init);
 
 	int revision;
 	unsigned int txd_ptr_tbl_base;
@@ -1179,6 +1187,7 @@ struct efx_nic_type {
 	netdev_features_t offload_features;
 	int mcdi_max_ver;
 	unsigned int max_rx_ip_filters;
+	u32 hwtstamp_filters;
 };
 
 /**************************************************************************
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 25178536f053..999ef285662d 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -561,6 +561,9 @@ int efx_ptp_set_ts_config(struct efx_nic *efx, struct ifreq *ifr);
 int efx_ptp_get_ts_config(struct efx_nic *efx, struct ifreq *ifr);
 void efx_ptp_get_ts_info(struct efx_nic *efx, struct ethtool_ts_info *ts_info);
 bool efx_ptp_is_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
+int efx_ptp_get_mode(struct efx_nic *efx);
+int efx_ptp_change_mode(struct efx_nic *efx, bool enable_wanted,
+			unsigned int new_mode);
 int efx_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
 void efx_ptp_event(struct efx_nic *efx, efx_qword_t *ev);
 void efx_ptp_start_datapath(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index cf2ae11b13f1..1d1a6f7325da 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1361,8 +1361,13 @@ int efx_ptp_tx(struct efx_nic *efx, struct sk_buff *skb)
 	return NETDEV_TX_OK;
 }
 
-static int efx_ptp_change_mode(struct efx_nic *efx, bool enable_wanted,
-			       unsigned int new_mode)
+int efx_ptp_get_mode(struct efx_nic *efx)
+{
+	return efx->ptp_data->mode;
+}
+
+int efx_ptp_change_mode(struct efx_nic *efx, bool enable_wanted,
+			unsigned int new_mode)
 {
 	if ((enable_wanted != efx->ptp_data->enabled) ||
 	    (enable_wanted && (efx->ptp_data->mode != new_mode))) {
@@ -1406,8 +1411,6 @@ static int efx_ptp_change_mode(struct efx_nic *efx, bool enable_wanted,
 
 static int efx_ptp_ts_init(struct efx_nic *efx, struct hwtstamp_config *init)
 {
-	bool enable_wanted = false;
-	unsigned int new_mode;
 	int rc;
 
 	if (init->flags)
@@ -1417,57 +1420,11 @@ static int efx_ptp_ts_init(struct efx_nic *efx, struct hwtstamp_config *init)
 	    (init->tx_type != HWTSTAMP_TX_ON))
 		return -ERANGE;
 
-	new_mode = efx->ptp_data->mode;
-	/* Determine whether any PTP HW operations are required */
-	switch (init->rx_filter) {
-	case HWTSTAMP_FILTER_NONE:
-		break;
-	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
-	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
-	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
-		init->rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
-		new_mode = MC_CMD_PTP_MODE_V1;
-		enable_wanted = true;
-		break;
-	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
-	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
-	/* Although these three are accepted only IPV4 packets will be
-	 * timestamped
-	 */
-		init->rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
-		new_mode = MC_CMD_PTP_MODE_V2_ENHANCED;
-		enable_wanted = true;
-		break;
-	case HWTSTAMP_FILTER_PTP_V2_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_SYNC:
-	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
-	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
-	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
-		/* Non-IP + IPv6 timestamping not supported */
-		return -ERANGE;
-		break;
-	default:
-		return -ERANGE;
-	}
-
-	if (init->tx_type != HWTSTAMP_TX_OFF)
-		enable_wanted = true;
-
-	/* Old versions of the firmware do not support the improved
-	 * UUID filtering option (SF bug 33070).  If the firmware does
-	 * not accept the enhanced mode, fall back to the standard PTP
-	 * v2 UUID filtering.
-	 */
-	rc = efx_ptp_change_mode(efx, enable_wanted, new_mode);
-	if ((rc != 0) && (new_mode == MC_CMD_PTP_MODE_V2_ENHANCED))
-		rc = efx_ptp_change_mode(efx, enable_wanted, MC_CMD_PTP_MODE_V2);
-	if (rc != 0)
+	rc = efx->type->ptp_set_ts_config(efx, init);
+	if (rc)
 		return rc;
 
 	efx->ptp_data->config = *init;
-
 	return 0;
 }
 
@@ -1483,13 +1440,7 @@ void efx_ptp_get_ts_info(struct efx_nic *efx, struct ethtool_ts_info *ts_info)
 				     SOF_TIMESTAMPING_RAW_HARDWARE);
 	ts_info->phc_index = ptp_clock_index(ptp->phc_clock);
 	ts_info->tx_types = 1 << HWTSTAMP_TX_OFF | 1 << HWTSTAMP_TX_ON;
-	ts_info->rx_filters = (1 << HWTSTAMP_FILTER_NONE |
-			       1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT |
-			       1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC |
-			       1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ |
-			       1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT |
-			       1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC |
-			       1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ);
+	ts_info->rx_filters = ptp->efx->type->hwtstamp_filters;
 }
 
 int efx_ptp_set_ts_config(struct efx_nic *efx, struct ifreq *ifr)
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 53b4ce67be0e..f65db356fe09 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -118,6 +118,54 @@ out:
 
 /**************************************************************************
  *
+ * PTP
+ *
+ **************************************************************************
+ */
+
+static void siena_ptp_write_host_time(struct efx_nic *efx, u32 host_time)
+{
+	_efx_writed(efx, cpu_to_le32(host_time),
+		    FR_CZ_MC_TREG_SMEM + MC_SMEM_P0_PTP_TIME_OFST);
+}
+
+static int siena_ptp_set_ts_config(struct efx_nic *efx,
+				   struct hwtstamp_config *init)
+{
+	int rc;
+
+	switch (init->rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		/* if TX timestamping is still requested then leave PTP on */
+		return efx_ptp_change_mode(efx,
+					   init->tx_type != HWTSTAMP_TX_OFF,
+					   efx_ptp_get_mode(efx));
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		init->rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+		return efx_ptp_change_mode(efx, true, MC_CMD_PTP_MODE_V1);
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		init->rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
+		rc = efx_ptp_change_mode(efx, true,
+					 MC_CMD_PTP_MODE_V2_ENHANCED);
+		/* bug 33070 - old versions of the firmware do not support the
+		 * improved UUID filtering option. Similarly old versions of the
+		 * application do not expect it to be enabled. If the firmware
+		 * does not accept the enhanced mode, fall back to the standard
+		 * PTP v2 UUID filtering. */
+		if (rc != 0)
+			rc = efx_ptp_change_mode(efx, true, MC_CMD_PTP_MODE_V2);
+		return rc;
+	default:
+		return -ERANGE;
+	}
+}
+
+/**************************************************************************
+ *
  * Device reset
  *
  **************************************************************************
@@ -839,19 +887,6 @@ fail:
 
 /**************************************************************************
  *
- * PTP
- *
- **************************************************************************
- */
-
-static void siena_ptp_write_host_time(struct efx_nic *efx, u32 host_time)
-{
-	_efx_writed(efx, cpu_to_le32(host_time),
-		    FR_CZ_MC_TREG_SMEM + MC_SMEM_P0_PTP_TIME_OFST);
-}
-
-/**************************************************************************
- *
  * Revision-dependent attributes used by efx.c and nic.c
  *
  **************************************************************************
@@ -942,6 +977,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.mtd_sync = efx_mcdi_mtd_sync,
 #endif
 	.ptp_write_host_time = siena_ptp_write_host_time,
+	.ptp_set_ts_config = siena_ptp_set_ts_config,
 
 	.revision = EFX_REV_SIENA_A0,
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
@@ -960,4 +996,11 @@ const struct efx_nic_type siena_a0_nic_type = {
 			     NETIF_F_RXHASH | NETIF_F_NTUPLE),
 	.mcdi_max_ver = 1,
 	.max_rx_ip_filters = FR_BZ_RX_FILTER_TBL0_ROWS,
+	.hwtstamp_filters = (1 << HWTSTAMP_FILTER_NONE |
+			     1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT |
+			     1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC |
+			     1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ |
+			     1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT |
+			     1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC |
+			     1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ),
 };


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
