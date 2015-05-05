From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 05/14] sfc: Record [rt]x_dpcpu_fw_id in EF10 nic_data
Date: Wed, 6 May 2015 00:56:55 +0100
Message-ID: <554958C7.9060502@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:22081 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755580AbbEEX5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:57:07 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The (future) code to add/remove vswitches and vports will be
dependent on the firmware variant.
To simplify the checking of the firmware variant, record
values for rx_dpcpu_fw_id and tx_dpcpu_fw_id in EF10 nic_data.

There was only one place where this was previously used:
efx_mcdi_print_fwver() in ethtool.c.
The MC_CMD_GET_CAPABILITIES can be replaced and the values from
nic_data used instead.

Note that the printing of "?" if the MC command fails or if the
outlength is incorrect no longer apply, because errors are returned
in efx_ef10_init_datapath_caps() in both of these cases.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c |  7 +++++++
 drivers/net/ethernet/sfc/mcdi.c | 22 ++++++----------------
 drivers/net/ethernet/sfc/nic.h  |  4 ++++
 3 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index ad23018..4f9775f 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -118,6 +118,13 @@ static int efx_ef10_init_datapath_caps(struct efx_nic *efx)
 	nic_data->datapath_caps =
 		MCDI_DWORD(outbuf, GET_CAPABILITIES_OUT_FLAGS1);
 
+	/* record the DPCPU firmware IDs to determine VEB vswitching support.
+	 */
+	nic_data->rx_dpcpu_fw_id =
+		MCDI_WORD(outbuf, GET_CAPABILITIES_OUT_RX_DPCPU_FW_ID);
+	nic_data->tx_dpcpu_fw_id =
+		MCDI_WORD(outbuf, GET_CAPABILITIES_OUT_TX_DPCPU_FW_ID);
+
 	if (!(nic_data->datapath_caps &
 	      (1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN))) {
 		netif_err(efx, drv, efx->net_dev,
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 6502ada..6e0c789 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1083,9 +1083,7 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 
 void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len)
 {
-	MCDI_DECLARE_BUF(outbuf,
-			 max(MC_CMD_GET_VERSION_OUT_LEN,
-			     MC_CMD_GET_CAPABILITIES_OUT_LEN));
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_VERSION_OUT_LEN);
 	size_t outlength;
 	const __le16 *ver_words;
 	size_t offset;
@@ -1110,19 +1108,11 @@ void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len)
 	 * single version.  Report which variants are running.
 	 */
 	if (efx_nic_rev(efx) >= EFX_REV_HUNT_A0) {
-		BUILD_BUG_ON(MC_CMD_GET_CAPABILITIES_IN_LEN != 0);
-		rc = efx_mcdi_rpc(efx, MC_CMD_GET_CAPABILITIES, NULL, 0,
-				  outbuf, sizeof(outbuf), &outlength);
-		if (rc || outlength < MC_CMD_GET_CAPABILITIES_OUT_LEN)
-			offset += snprintf(
-				buf + offset, len - offset, " rx? tx?");
-		else
-			offset += snprintf(
-				buf + offset, len - offset, " rx%x tx%x",
-				MCDI_WORD(outbuf,
-					  GET_CAPABILITIES_OUT_RX_DPCPU_FW_ID),
-				MCDI_WORD(outbuf,
-					  GET_CAPABILITIES_OUT_TX_DPCPU_FW_ID));
+		struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+		offset += snprintf(buf + offset, len - offset, " rx%x tx%x",
+				   nic_data->rx_dpcpu_fw_id,
+				   nic_data->tx_dpcpu_fw_id);
 
 		/* It's theoretically possible for the string to exceed 31
 		 * characters, though in practice the first three version
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 65dcbc7..17ee3ae 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -491,6 +491,8 @@ enum {
  *	after MC reboot
  * @datapath_caps: Capabilities of datapath firmware (FLAGS1 field of
  *	%MC_CMD_GET_CAPABILITIES response)
+ * @rx_dpcpu_fw_id: Firmware ID of the RxDPCPU
+ * @tx_dpcpu_fw_id: Firmware ID of the TxDPCPU
  */
 struct efx_ef10_nic_data {
 	struct efx_buffer mcdi_buf;
@@ -509,6 +511,8 @@ struct efx_ef10_nic_data {
 	bool workaround_35388;
 	bool must_check_datapath_caps;
 	u32 datapath_caps;
+	unsigned int rx_dpcpu_fw_id;
+	unsigned int tx_dpcpu_fw_id;
 };
 
 int efx_init_sriov(void);
