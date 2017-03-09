From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Enable IRQs only if napi_complete_done() is
 true
Date: Thu, 9 Mar 2017 17:48:23 -0600
Message-ID: <20170309234823.11010.87592.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Jeremy Linton <jeremy.linton@arm.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0047.outbound.protection.outlook.com ([104.47.38.47]:23887
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752332AbdCIXs2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 18:48:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Depending on the hardware, the amd-xgbe driver may use disable_irq_nosync()
and enable_irq() when an interrupt is received to process Rx packets. If
the napi_complete_done() return value isn't checked an unbalanced enable
for the IRQ could result, generating a warning stack trace.

Update the driver to only enable interrupts if napi_complete_done() returns
true.

Reported-by: Jeremy Linton <jeremy.linton@arm.com>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 248f60d..ffea985 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -2272,10 +2272,7 @@ static int xgbe_one_poll(struct napi_struct *napi, int budget)
 	processed = xgbe_rx_poll(channel, budget);
 
 	/* If we processed everything, we are done */
-	if (processed < budget) {
-		/* Turn off polling */
-		napi_complete_done(napi, processed);
-
+	if ((processed < budget) && napi_complete_done(napi, processed)) {
 		/* Enable Tx and Rx interrupts */
 		if (pdata->channel_irq_mode)
 			xgbe_enable_rx_tx_int(pdata, channel);
@@ -2317,10 +2314,7 @@ static int xgbe_all_poll(struct napi_struct *napi, int budget)
 	} while ((processed < budget) && (processed != last_processed));
 
 	/* If we processed everything, we are done */
-	if (processed < budget) {
-		/* Turn off polling */
-		napi_complete_done(napi, processed);
-
+	if ((processed < budget) && napi_complete_done(napi, processed)) {
 		/* Enable Tx and Rx interrupts */
 		xgbe_enable_rx_tx_ints(pdata);
 	}
