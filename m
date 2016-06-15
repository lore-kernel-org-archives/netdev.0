From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 12/17] sfc: Refactor checks for invalid filter ID
Date: Wed, 15 Jun 2016 17:49:05 +0100
Message-ID: <39555fab-2654-0d26-90d6-825cc478a8ed@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:5195 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753237AbcFOQuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:40 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nearly every time we call efx_ef10_filter_remove_unsafe, we first check
for EFX_EF10_FILTER_ID_INVALID, in which case we do nothing.  So move
that check into the function, simplifying all the call sites.

Also, change the return type to void, since none of the callers check it.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 39 +++++++++++++--------------------------
 1 file changed, 13 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index add9f46..d4f9e94 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3568,12 +3568,13 @@ static u32 efx_ef10_filter_get_unsafe_id(struct efx_nic *efx, u32 filter_id)
 	return filter_id % HUNT_FILTER_TBL_ROWS;
 }
 
-static int efx_ef10_filter_remove_unsafe(struct efx_nic *efx,
-					 enum efx_filter_priority priority,
-					 u32 filter_id)
+static void efx_ef10_filter_remove_unsafe(struct efx_nic *efx,
+					  enum efx_filter_priority priority,
+					  u32 filter_id)
 {
-	return efx_ef10_filter_remove_internal(efx, 1U << priority,
-					       filter_id, true);
+	if (filter_id == EFX_EF10_FILTER_ID_INVALID)
+		return;
+	efx_ef10_filter_remove_internal(efx, 1U << priority, filter_id, true);
 }
 
 static int efx_ef10_filter_get_safe(struct efx_nic *efx,
@@ -4229,8 +4230,6 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 					   rc);
 				/* Fall back to promiscuous */
 				for (j = 0; j < i; j++) {
-					if (ids[j] == EFX_EF10_FILTER_ID_INVALID)
-						continue;
 					efx_ef10_filter_remove_unsafe(
 						efx, EFX_FILTER_PRI_AUTO,
 						ids[j]);
@@ -4256,8 +4255,6 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 				   "Broadcast filter insert failed rc=%d\n", rc);
 			/* Fall back to promiscuous */
 			for (j = 0; j < i; j++) {
-				if (ids[j] == EFX_EF10_FILTER_ID_INVALID)
-					continue;
 				efx_ef10_filter_remove_unsafe(
 					efx, EFX_FILTER_PRI_AUTO,
 					ids[j]);
@@ -4616,25 +4613,15 @@ static void efx_ef10_filter_del_vlan_internal(struct efx_nic *efx,
 
 	list_del(&vlan->list);
 
-	for (i = 0; i < ARRAY_SIZE(vlan->uc); i++) {
-		if (vlan->uc[i] != EFX_EF10_FILTER_ID_INVALID)
-			efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
-						      vlan->uc[i]);
-	}
-	for (i = 0; i < ARRAY_SIZE(vlan->mc); i++) {
-		if (vlan->mc[i] != EFX_EF10_FILTER_ID_INVALID)
-			efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
-						      vlan->mc[i]);
-	}
-	if (vlan->ucdef != EFX_EF10_FILTER_ID_INVALID)
-		efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
-					      vlan->ucdef);
-	if (vlan->bcast != EFX_EF10_FILTER_ID_INVALID)
+	for (i = 0; i < ARRAY_SIZE(vlan->uc); i++)
 		efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
-					      vlan->bcast);
-	if (vlan->mcdef != EFX_EF10_FILTER_ID_INVALID)
+					      vlan->uc[i]);
+	for (i = 0; i < ARRAY_SIZE(vlan->mc); i++)
 		efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
-					      vlan->mcdef);
+					      vlan->mc[i]);
+	efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO, vlan->ucdef);
+	efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO, vlan->bcast);
+	efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO, vlan->mcdef);
 
 	kfree(vlan);
 }
