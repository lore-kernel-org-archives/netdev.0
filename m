From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: fix attempt to translate invalid filter ID
Date: Thu, 29 Jun 2017 16:50:06 +0100
Message-ID: <ac506723-66ef-0945-ff1e-c0132f0c71c0@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:37342 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751669AbdF2PuT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 11:50:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When filter insertion fails with no rollback, we were trying to convert
 EFX_EF10_FILTER_ID_INVALID to an id to store in 'ids' (which is either
 vlan->uc or vlan->mc).  This would WARN_ON_ONCE and then record a bogus
 filter ID of 0x1fff, neither of which is a good thing.

Fixes: 0ccb998bf46d ("sfc: fix filter_id misinterpretation in edge case")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index a808966..78f9e43 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -5105,6 +5105,7 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 
 	/* Insert/renew filters */
 	for (i = 0; i < addr_count; i++) {
+		EFX_WARN_ON_PARANOID(ids[i] != EFX_EF10_FILTER_ID_INVALID);
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO, filter_flags, 0);
 		efx_filter_set_eth_local(&spec, vlan->vid, addr_list[i].addr);
 		rc = efx_ef10_filter_insert(efx, &spec, true);
@@ -5122,11 +5123,11 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 				}
 				return rc;
 			} else {
-				/* mark as not inserted, and carry on */
-				rc = EFX_EF10_FILTER_ID_INVALID;
+				/* keep invalid ID, and carry on */
 			}
+		} else {
+			ids[i] = efx_ef10_filter_get_unsafe_id(rc);
 		}
-		ids[i] = efx_ef10_filter_get_unsafe_id(rc);
 	}
 
 	if (multicast && rollback) {
