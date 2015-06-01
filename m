From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v2 01/14] sfc: Add code to export port_num in netdev->dev_port
Date: Mon, 1 Jun 2015 14:00:12 +0100
Message-ID: <556C575C.2040403@solarflare.com>
References: <556C5704.4060901@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:2130 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752825AbbFANAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 09:00:19 -0400
In-Reply-To: <556C5704.4060901@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case where we have multiple functions (PFs and VFs), this
sysfs entry is useful to identify the physical port corresponding
to the function we are interested in.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index a547ceb..dacf9f8 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -249,6 +249,7 @@ static int efx_ef10_get_mac_address_vf(struct efx_nic *efx, u8 *mac_address)
 static int efx_ef10_probe(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data;
+	struct net_device *net_dev = efx->net_dev;
 	int i, rc;
 
 	/* We can have one VI for each 8K region.  However, until we
@@ -326,6 +327,7 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail3;
 	efx->port_num = rc;
+	net_dev->dev_port = rc;
 
 	rc = efx->type->get_mac_address(efx, efx->net_dev->perm_addr);
 	if (rc)
@@ -334,6 +336,7 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	rc = efx_ef10_get_sysclk_freq(efx);
 	if (rc < 0)
 		goto fail3;
+
 	efx->timer_quantum_ns = 1536000 / rc; /* 1536 cycles */
 
 	/* Check whether firmware supports bug 35388 workaround.
@@ -341,9 +344,9 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	 * ask if it's already enabled
 	 */
 	rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG35388, true);
-	if (rc == 0)
+	if (rc == 0) {
 		nic_data->workaround_35388 = true;
-	else if (rc == -EPERM) {
+	} else if (rc == -EPERM) {
 		unsigned int enabled;
 
 		rc = efx_mcdi_get_workarounds(efx, NULL, &enabled);
@@ -351,9 +354,10 @@ static int efx_ef10_probe(struct efx_nic *efx)
 			goto fail3;
 		nic_data->workaround_35388 = enabled &
 			MC_CMD_GET_WORKAROUNDS_OUT_BUG35388;
-	}
-	else if (rc != -ENOSYS && rc != -ENOENT)
+	} else if (rc != -ENOSYS && rc != -ENOENT) {
 		goto fail3;
+	}
+
 	netif_dbg(efx, probe, efx->net_dev,
 		  "workaround for bug 35388 is %sabled\n",
 		  nic_data->workaround_35388 ? "en" : "dis");
