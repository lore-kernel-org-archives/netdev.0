From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next 3/6] sfc: retrieve second word of datapath
 capabilities
Date: Thu, 11 Aug 2016 13:01:35 +0100
Message-ID: <78a0e0d4-dd2d-5a6e-3755-00cc000e22c7@solarflare.com>
References: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	<netdev@vger.kernel.org>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:21253 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751266AbcHKMRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 08:17:45 -0400
In-Reply-To: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 10 ++++++++--
 drivers/net/ethernet/sfc/nic.h  |  3 +++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index f658fee..fd5d086 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -177,7 +177,7 @@ static int efx_ef10_get_vf_index(struct efx_nic *efx)
 
 static int efx_ef10_init_datapath_caps(struct efx_nic *efx)
 {
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_CAPABILITIES_OUT_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_CAPABILITIES_V2_OUT_LEN);
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	size_t outlen;
 	int rc;
@@ -188,7 +188,7 @@ static int efx_ef10_init_datapath_caps(struct efx_nic *efx)
 			  outbuf, sizeof(outbuf), &outlen);
 	if (rc)
 		return rc;
-	if (outlen < sizeof(outbuf)) {
+	if (outlen < MC_CMD_GET_CAPABILITIES_OUT_LEN) {
 		netif_err(efx, drv, efx->net_dev,
 			  "unable to read datapath firmware capabilities\n");
 		return -EIO;
@@ -197,6 +197,12 @@ static int efx_ef10_init_datapath_caps(struct efx_nic *efx)
 	nic_data->datapath_caps =
 		MCDI_DWORD(outbuf, GET_CAPABILITIES_OUT_FLAGS1);
 
+	if (outlen >= MC_CMD_GET_CAPABILITIES_V2_OUT_LEN)
+		nic_data->datapath_caps2 = MCDI_DWORD(outbuf,
+				GET_CAPABILITIES_V2_OUT_FLAGS2);
+	else
+		nic_data->datapath_caps2 = 0;
+
 	/* record the DPCPU firmware IDs to determine VEB vswitching support.
 	 */
 	nic_data->rx_dpcpu_fw_id =
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 96944c3..531c5a8 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -511,6 +511,8 @@ enum {
  *	after MC reboot
  * @datapath_caps: Capabilities of datapath firmware (FLAGS1 field of
  *	%MC_CMD_GET_CAPABILITIES response)
+ * @datapath_caps2: Further Capabilities of datapath firmware (FLAGS2 field of
+ * %MC_CMD_GET_CAPABILITIES response)
  * @rx_dpcpu_fw_id: Firmware ID of the RxDPCPU
  * @tx_dpcpu_fw_id: Firmware ID of the TxDPCPU
  * @vport_id: The function's vport ID, only relevant for PFs
@@ -542,6 +544,7 @@ struct efx_ef10_nic_data {
 	bool workaround_26807;
 	bool must_check_datapath_caps;
 	u32 datapath_caps;
+	u32 datapath_caps2;
 	unsigned int rx_dpcpu_fw_id;
 	unsigned int tx_dpcpu_fw_id;
 	unsigned int vport_id;
-- 
2.7.4
