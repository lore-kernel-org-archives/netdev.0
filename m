From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 04/16] sfc: Store vf_index in nic_data for Ef10.
Date: Wed, 20 May 2015 11:09:15 +0100
Message-ID: <555C5D4B.2070700@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:56225 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751341AbbETKJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:09:21 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added function efx_ef10_get_vf_index to store the vf_index
in nic_data during probe

vf_index is needed in future patches to access a particular
VF in the VF data structure.

Moved efx_ef10_probe_pf and efx_ef10_probe_vf in order to
used efx_ef10_remove

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 68 ++++++++++++++++++++++++++++++-----------
 drivers/net/ethernet/sfc/nic.h  |  1 +
 2 files changed, 52 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 70cbad3..8b6579a 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -119,6 +119,26 @@ static int efx_ef10_get_pf_index(struct efx_nic *efx)
 	return 0;
 }
 
+#ifdef CONFIG_SFC_SRIOV
+static int efx_ef10_get_vf_index(struct efx_nic *efx)
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
+	nic_data->vf_index = MCDI_DWORD(outbuf, GET_FUNCTION_INFO_OUT_VF);
+	return 0;
+}
+#endif
+
 static int efx_ef10_init_datapath_caps(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_CAPABILITIES_OUT_LEN);
@@ -328,23 +348,6 @@ fail1:
 	return rc;
 }
 
-static int efx_ef10_probe_pf(struct efx_nic *efx)
-{
-	return efx_ef10_probe(efx);
-}
-
-#ifdef CONFIG_SFC_SRIOV
-static int efx_ef10_probe_vf(struct efx_nic *efx)
-{
-	return efx_ef10_probe(efx);
-}
-#else
-static int efx_ef10_probe_vf(struct efx_nic *efx __attribute__ ((unused)))
-{
-	return 0;
-}
-#endif
-
 static int efx_ef10_free_vis(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF_OUT_OR_ERR(outbuf, 0);
@@ -561,6 +564,37 @@ static void efx_ef10_remove(struct efx_nic *efx)
 	kfree(nic_data);
 }
 
+static int efx_ef10_probe_pf(struct efx_nic *efx)
+{
+	return efx_ef10_probe(efx);
+}
+
+#ifdef CONFIG_SFC_SRIOV
+static int efx_ef10_probe_vf(struct efx_nic *efx)
+{
+	int rc;
+
+	rc = efx_ef10_probe(efx);
+	if (rc)
+		return rc;
+
+	rc = efx_ef10_get_vf_index(efx);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	efx_ef10_remove(efx);
+	return rc;
+}
+#else
+static int efx_ef10_probe_vf(struct efx_nic *efx __attribute__ ((unused)))
+{
+	return 0;
+}
+#endif
+
 static int efx_ef10_alloc_vis(struct efx_nic *efx,
 			      unsigned int min_vis, unsigned int max_vis)
 {
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 2fd3055..db8562e 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -525,6 +525,7 @@ struct efx_ef10_nic_data {
 	bool must_probe_vswitching;
 	unsigned int pf_index;
 #ifdef CONFIG_SFC_SRIOV
+	unsigned int vf_index;
 	struct ef10_vf *vf;
 #endif
 	u8 vport_mac[ETH_ALEN];
