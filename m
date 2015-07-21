From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 4/9] sfc: add output flag decoding to efx_mcdi_set_workaround
Date: Tue, 21 Jul 2015 15:09:43 +0100
Message-ID: <55AE52A7.8070909@solarflare.com>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:27898 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752877AbbGUOOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:14:02 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The initial use of this will be to check a flag reporting if an FLR was
performed on other functions when enabling cascaded multicast filters.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c |  7 ++++---
 drivers/net/ethernet/sfc/mcdi.c | 22 +++++++++++++++++++---
 drivers/net/ethernet/sfc/mcdi.h |  3 ++-
 3 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4407117..2b93f63 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -387,7 +387,7 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	 * First try to enable it, then if we get EPERM, just
 	 * ask if it's already enabled
 	 */
-	rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG35388, true);
+	rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG35388, true, NULL);
 	if (rc == 0) {
 		nic_data->workaround_35388 = true;
 	} else if (rc == -EPERM) {
@@ -2291,8 +2291,9 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 
 		if (implemented & MC_CMD_GET_WORKAROUNDS_OUT_BUG26807 &&
 		    !nic_data->workaround_26807) {
-			rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG26807,
-						     true);
+			rc = efx_mcdi_set_workaround(efx,
+						     MC_CMD_WORKAROUND_BUG26807,
+						     true, NULL);
 			if (!rc)
 				nic_data->workaround_26807 = true;
 			else if (rc == -EPERM)
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 58232e7..98d172b 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1779,15 +1779,31 @@ int efx_mcdi_wol_filter_reset(struct efx_nic *efx)
 	return rc;
 }
 
-int efx_mcdi_set_workaround(struct efx_nic *efx, u32 type, bool enabled)
+int efx_mcdi_set_workaround(struct efx_nic *efx, u32 type, bool enabled,
+			    unsigned int *flags)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_WORKAROUND_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_WORKAROUND_EXT_OUT_LEN);
+	size_t outlen;
+	int rc;
 
 	BUILD_BUG_ON(MC_CMD_WORKAROUND_OUT_LEN != 0);
 	MCDI_SET_DWORD(inbuf, WORKAROUND_IN_TYPE, type);
 	MCDI_SET_DWORD(inbuf, WORKAROUND_IN_ENABLED, enabled);
-	return efx_mcdi_rpc(efx, MC_CMD_WORKAROUND, inbuf, sizeof(inbuf),
-			    NULL, 0, NULL);
+	rc = efx_mcdi_rpc(efx, MC_CMD_WORKAROUND, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		return rc;
+
+	if (!flags)
+		return 0;
+
+	if (outlen >= MC_CMD_WORKAROUND_EXT_OUT_LEN)
+		*flags = MCDI_DWORD(outbuf, WORKAROUND_EXT_OUT_FLAGS);
+	else
+		*flags = 0;
+
+	return 0;
 }
 
 int efx_mcdi_get_workarounds(struct efx_nic *efx, unsigned int *impl_out,
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 1838afe..025d504 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -346,7 +346,8 @@ void efx_mcdi_mac_pull_stats(struct efx_nic *efx);
 bool efx_mcdi_mac_check_fault(struct efx_nic *efx);
 enum reset_type efx_mcdi_map_reset_reason(enum reset_type reason);
 int efx_mcdi_reset(struct efx_nic *efx, enum reset_type method);
-int efx_mcdi_set_workaround(struct efx_nic *efx, u32 type, bool enabled);
+int efx_mcdi_set_workaround(struct efx_nic *efx, u32 type, bool enabled,
+			    unsigned int *flags);
 int efx_mcdi_get_workarounds(struct efx_nic *efx, unsigned int *impl_out,
 			     unsigned int *enabled_out);
 
