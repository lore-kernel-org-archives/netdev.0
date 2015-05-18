From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] sfc: nicer log message on Siena SR-IOV probe fail
Date: Mon, 18 May 2015 14:18:27 +0100
Message-ID: <5559E6A3.1090109@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:40388 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751148AbbERNSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 09:18:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We expect that MC_CMD_SRIOV will fail if the card has no VFs configured.
So output a readable message instead of a cryptic MCDI error.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/siena_sriov.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index caf701a..2a5f352 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -208,8 +208,8 @@ static int efx_siena_sriov_cmd(struct efx_nic *efx, bool enable,
 	MCDI_SET_DWORD(inbuf, SRIOV_IN_VI_BASE, EFX_VI_BASE);
 	MCDI_SET_DWORD(inbuf, SRIOV_IN_VF_COUNT, efx->vf_count);
 
-	rc = efx_mcdi_rpc(efx, MC_CMD_SRIOV, inbuf, MC_CMD_SRIOV_IN_LEN,
-			  outbuf, MC_CMD_SRIOV_OUT_LEN, &outlen);
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_SRIOV, inbuf, MC_CMD_SRIOV_IN_LEN,
+				outbuf, MC_CMD_SRIOV_OUT_LEN, &outlen);
 	if (rc)
 		return rc;
 	if (outlen < MC_CMD_SRIOV_OUT_LEN)
@@ -1058,8 +1058,10 @@ void efx_siena_sriov_probe(struct efx_nic *efx)
 	if (!max_vfs)
 		return;
 
-	if (efx_siena_sriov_cmd(efx, false, &efx->vi_scale, &count))
+	if (efx_siena_sriov_cmd(efx, false, &efx->vi_scale, &count)) {
+		netif_info(efx, probe, efx->net_dev, "no SR-IOV VFs probed\n");
 		return;
+	}
 	if (count > 0 && count > max_vfs)
 		count = max_vfs;
 
