From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next v2 3/5] sfc: Make failed filter removal less noisy
Date: Wed, 23 Dec 2015 08:57:36 +0000
Message-ID: <567A6200.8050008@solarflare.com>
References: <567A6170.6010104@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:42295 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932716AbbLWI5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 03:57:49 -0500
In-Reply-To: <567A6170.6010104@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are situations - mostly reset related - where our view of the
filter table differs from the hardware. In this case we may try and
remove filters that aren't actually installed. This isn't that
interesting in most situations, so downgrade the logging.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 48 ++++++++++++++++++++++++++---------------
 1 file changed, 31 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 230fabd..b0c6c61 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3833,13 +3833,12 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 			       MC_CMD_FILTER_OP_IN_OP_UNSUBSCRIBE);
 		MCDI_SET_QWORD(inbuf, FILTER_OP_IN_HANDLE,
 			       table->entry[filter_idx].handle);
-		rc = efx_mcdi_rpc(efx, MC_CMD_FILTER_OP, inbuf, sizeof(inbuf),
-				  NULL, 0, NULL);
+		rc = efx_mcdi_rpc_quiet(efx, MC_CMD_FILTER_OP, inbuf,
+					sizeof(inbuf), NULL, 0, NULL);
 		if (rc)
-			netdev_WARN(efx->net_dev,
-				    "filter_idx=%#x handle=%#llx\n",
-				    filter_idx,
-				    table->entry[filter_idx].handle);
+			netif_info(efx, drv, efx->net_dev,
+				   "%s: filter %04x remove failed\n",
+				   __func__, filter_idx);
 		kfree(spec);
 	}
 
@@ -3848,11 +3847,14 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 }
 
 #define EFX_EF10_FILTER_DO_MARK_OLD(id) \
-		if (id != EFX_EF10_FILTER_ID_INVALID) { \
-			filter_idx = efx_ef10_filter_get_unsafe_id(efx, id); \
-			WARN_ON(!table->entry[filter_idx].spec); \
-			table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD; \
-		}
+	if (id != EFX_EF10_FILTER_ID_INVALID) { \
+		filter_idx = efx_ef10_filter_get_unsafe_id(efx, id); \
+		if (!table->entry[filter_idx].spec) \
+			netif_dbg(efx, drv, efx->net_dev, \
+				  "%s: marked null spec old %04x:%04x\n", \
+				  __func__, id, filter_idx); \
+		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;\
+	}
 static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
@@ -4070,19 +4072,31 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 static void efx_ef10_filter_remove_old(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
-	bool remove_failed = false;
+	int remove_failed = 0;
+	int remove_noent = 0;
+	int rc;
 	int i;
 
 	for (i = 0; i < HUNT_FILTER_TBL_ROWS; i++) {
 		if (ACCESS_ONCE(table->entry[i].spec) &
 		    EFX_EF10_FILTER_FLAG_AUTO_OLD) {
-			if (efx_ef10_filter_remove_internal(
-				    efx, 1U << EFX_FILTER_PRI_AUTO,
-				    i, true) < 0)
-				remove_failed = true;
+			rc = efx_ef10_filter_remove_internal(efx,
+					1U << EFX_FILTER_PRI_AUTO, i, true);
+			if (rc == -ENOENT)
+				remove_noent++;
+			else if (rc)
+				remove_failed++;
 		}
 	}
-	WARN_ON(remove_failed);
+
+	if (remove_failed)
+		netif_info(efx, drv, efx->net_dev,
+			   "%s: failed to remove %d filters\n",
+			   __func__, remove_failed);
+	if (remove_noent)
+		netif_info(efx, drv, efx->net_dev,
+			   "%s: failed to remove %d non-existent filters\n",
+			   __func__, remove_noent);
 }
 
 static int efx_ef10_vport_set_mac_address(struct efx_nic *efx)
-- 
2.4.3
