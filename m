From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next] sfc: reduce severity of PIO buffer alloc failures
Date: Wed, 25 Jan 2017 13:48:17 +0000
Message-ID: <4bb401da-f76d-38e8-2368-d36edeb4ac44@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?B?VG9tw6HFoSBQaWxhxZk=?= <tpilar@solarflare.com>,
        Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>,
        netdev <netdev@vger.kernel.org>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:51417 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751753AbdAYNs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 08:48:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomáš Pilař <tpilar@solarflare.com>

PIO buffer allocation can fail for two valid reasons:
 - we've run out of them (results in -ENOSPC)
 - the NIC configuration doesn't support them (results in -EPERM)
Since both these failures are expected netif_err is excessive.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index dccbbd323616..7c53da28ad64 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1170,7 +1170,13 @@ static int efx_ef10_dimension_resources(struct efx_nic *efx)
 				     nic_data->piobuf_size / efx_piobuf_size);
 
 		rc = efx_ef10_alloc_piobufs(efx, n_piobufs);
-		if (rc)
+		if (rc == -ENOSPC)
+			netif_dbg(efx, probe, efx->net_dev,
+				  "out of PIO buffers; cannot allocate more\n");
+		else if (rc == -EPERM)
+			netif_dbg(efx, probe, efx->net_dev,
+				  "not permitted to allocate PIO buffers\n");
+		else if (rc)
 			netif_err(efx, probe, efx->net_dev,
 				  "failed to allocate PIO buffers (%d)\n", rc);
 		else
@@ -1317,8 +1323,14 @@ static int efx_ef10_init_nic(struct efx_nic *efx)
 				efx_ef10_free_piobufs(efx);
 		}
 
-		/* Log an error on failure, but this is non-fatal */
-		if (rc)
+		/* Log an error on failure, but this is non-fatal.
+		 * Permission errors are less important - we've presumably
+		 * had the PIO buffer licence removed.
+		 */
+		if (rc == -EPERM)
+			netif_dbg(efx, drv, efx->net_dev,
+				  "not permitted to restore PIO buffers\n");
+		else if (rc)
 			netif_err(efx, drv, efx->net_dev,
 				  "failed to restore PIO buffers (%d)\n", rc);
 		nic_data->must_restore_piobufs = false;
-- 
2.7.4
