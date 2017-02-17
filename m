From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/3] sfc: forget filters from sw table if hw replies
 ENOENT on removing them
Date: Fri, 17 Feb 2017 15:50:12 +0000
Message-ID: <35d4cc02-e51c-5a69-45f8-da998e965603@solarflare.com>
References: <f49743cd-3227-4d30-9d6d-bd2f8400df62@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:15125 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934537AbdBQPuW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 10:50:22 -0500
In-Reply-To: <f49743cd-3227-4d30-9d6d-bd2f8400df62@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

If the hw doesn't think they exist, we should defer to its authority.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 7da9699..ec976ff 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -4309,13 +4309,18 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 			       MC_CMD_FILTER_OP_IN_OP_UNSUBSCRIBE);
 		MCDI_SET_QWORD(inbuf, FILTER_OP_IN_HANDLE,
 			       table->entry[filter_idx].handle);
-		rc = efx_mcdi_rpc(efx, MC_CMD_FILTER_OP,
-				  inbuf, sizeof(inbuf), NULL, 0, NULL);
+		rc = efx_mcdi_rpc_quiet(efx, MC_CMD_FILTER_OP,
+					inbuf, sizeof(inbuf), NULL, 0, NULL);
 
 		spin_lock_bh(&efx->filter_lock);
-		if (rc == 0) {
+		if ((rc == 0) || (rc == -ENOENT)) {
+			/* Filter removed OK or didn't actually exist */
 			kfree(spec);
 			efx_ef10_filter_set_entry(table, filter_idx, NULL, 0);
+		} else {
+			efx_mcdi_display_error(efx, MC_CMD_FILTER_OP,
+					       MC_CMD_FILTER_OP_IN_LEN,
+					       NULL, 0, rc);
 		}
 	}
 
