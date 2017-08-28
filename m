From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 06/11] bnxt_en: Improve -ENOMEM logic in NAPI poll loop.
Date: Mon, 28 Aug 2017 13:40:30 -0400
Message-ID: <1503942035-24924-7-git-send-email-michael.chan@broadcom.com>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Martin KaFai Lau <kafai@fb.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:33373 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbdH1Rk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:40:57 -0400
Received: by mail-qt0-f182.google.com with SMTP id e2so5349035qta.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:40:56 -0700 (PDT)
In-Reply-To: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we cannot allocate RX buffers in the NAPI poll loop when processing
an RX event, the current code does not count that event towards the NAPI
budget.  This can cause us to potentially loop forever in NAPI if we
consistently cannot allocate new buffers.  Improve it by counting
-ENOMEM event as 1 towards the NAPI budget.

Cc: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 1afb408..a34fcdd 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1850,6 +1850,13 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 							   &event);
 			if (likely(rc >= 0))
 				rx_pkts += rc;
+			/* Increment rx_pkts when rc is -ENOMEM to count towards
+			 * the NAPI budget.  Otherwise, we may potentially loop
+			 * here forever if we consistently cannot allocate
+			 * buffers.
+			 */
+			else if (rc == -ENOMEM)
+				rx_pkts++;
 			else if (rc == -EBUSY)	/* partial completion */
 				break;
 		} else if (unlikely((TX_CMP_TYPE(txcmp) ==
-- 
1.8.3.1
