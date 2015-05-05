From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 08/14] sfc: get the PF number and record in nic_data
Date: Wed, 6 May 2015 00:57:53 +0100
Message-ID: <55495901.3050405@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:42600 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753571AbbEEX57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:57:59 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

Use MC_CMD_GET_FUNCTION_INFO to record the PF number in nic_data.
This will be needed when assigned vports to VFs.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 22 ++++++++++++++++++++++
 drivers/net/ethernet/sfc/nic.h  |  2 ++
 2 files changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 91a5896..4d6d194 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -96,6 +96,24 @@ static unsigned int efx_ef10_mem_map_size(struct efx_nic *efx)
 	return resource_size(&efx->pci_dev->resource[EFX_MEM_BAR]);
 }
 
+static int efx_ef10_get_pf_index(struct efx_nic *efx)
+{
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_FUNCTION_INFO_OUT_LEN);
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	size_t outlen;
+	int rc;
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_FUNCTION_INFO, NULL, 0, outbuf,
+			  sizeof(outbuf), &outlen);
+	if (rc)
+		return rc;
+	if (outlen < sizeof(outbuf))
+		return -EIO;
+
+	nic_data->pf_index = MCDI_DWORD(outbuf, GET_FUNCTION_INFO_OUT_PF);
+	return 0;
+}
+
 static int efx_ef10_init_datapath_caps(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_CAPABILITIES_OUT_LEN);
@@ -240,6 +258,10 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail3;
 
+	rc = efx_ef10_get_pf_index(efx);
+	if (rc)
+		goto fail3;
+
 	rc = efx_ef10_init_datapath_caps(efx);
 	if (rc < 0)
 		goto fail3;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index d7dcc01..3ab8840 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -495,6 +495,7 @@ enum {
  * @tx_dpcpu_fw_id: Firmware ID of the TxDPCPU
  * @vport_id: The function's vport ID, only relevant for PFs
  * @must_probe_vswitching: Flag: vswitching has yet to be setup after MC reboot
+ * @pf_index: The number for this PF, or the parent PF if this is a VF
  */
 struct efx_ef10_nic_data {
 	struct efx_buffer mcdi_buf;
@@ -517,6 +518,7 @@ struct efx_ef10_nic_data {
 	unsigned int tx_dpcpu_fw_id;
 	unsigned int vport_id;
 	bool must_probe_vswitching;
+	unsigned int pf_index;
 };
 
 int efx_init_sriov(void);
