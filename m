From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/2] bnxt_en: Need memory barrier when processing the completion ring.
Date: Wed,  4 May 2016 16:56:43 -0400
Message-ID: <1462395404-21875-2-git-send-email-michael.chan@broadcom.com>
References: <1462395404-21875-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:14051 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbcEDU4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 16:56:45 -0400
In-Reply-To: <1462395404-21875-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code determines if the next ring entry is valid before proceeding
further to read the rest of the entry.  The CPU can re-order and read
the rest of the entry first, possibly reading a stale entry, if DMA
of a new entry happens right after reading it.  This issue can be
readily seen on a ppc64 system, causing it to crash.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 72eb29e..f33ff20 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1388,6 +1388,10 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 		if (!TX_CMP_VALID(txcmp, raw_cons))
 			break;
 
+		/* The valid test of the entry must be done first before
+		 * reading any further.
+		 */
+		rmb();
 		if (TX_CMP_TYPE(txcmp) == CMP_TYPE_TX_L2_CMP) {
 			tx_pkts++;
 			/* return full budget so NAPI will complete. */
-- 
1.8.3.1
