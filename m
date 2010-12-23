From: Jason Wang <jason77.wang@gmail.com>
Subject: [PATCH] smsc911x: add disable and re-enable Rx int to de-assert interrupt pin
Date: Thu, 23 Dec 2010 18:43:13 +0800
Message-ID: <1293100993-3956-1-git-send-email-jason77.wang@gmail.com>
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	linux-omap@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50081 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab0LWKiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 05:38:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When kernel enters irqhanlder, it will check the Rx interrupt status
bit, if Rx status is set but can't call napi_schedule(), it will do
nothing and directly return form irqhandler. This situation is prone
to be produced when we repeatly call irqhandler through netpoll
interface(i.e kgdboe connecting).

This is a potential risk for those level triggered platforms(i.e
ti_omap3evm), because if we don't handle Rx int and just return from
irqhandler, the irq pin will be keeping asserted, the level triggered
platforms will have no chance to jump out from the Rx irq. The whole
system will hung into the irq subsystem.

To solve it, we add a disable/re-enable Rx int operation for this
situation, this operation can de-assert interrupt pin for this time
and will leave the received data and status in the FIFO for later
interrupts to handle.

Signed-off-by: Jason Wang <jason77.wang@gmail.com>
---
 drivers/net/smsc911x.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 64bfdae..dd6312f 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1492,14 +1492,20 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 	}
 
 	if (likely(intsts & inten & INT_STS_RSFL_)) {
-		if (likely(napi_schedule_prep(&pdata->napi))) {
-			/* Disable Rx interrupts */
-			temp = smsc911x_reg_read(pdata, INT_EN);
-			temp &= (~INT_EN_RSFL_EN_);
-			smsc911x_reg_write(pdata, INT_EN, temp);
+		/* Disable Rx interrupts first, if doesn't meet
+		 * napi_schedule_prep(), we will re-enable Rx interrupts. This
+		 * disable and re-enable pair operation can De-assert interrupt
+		 * line and is more safer to those level triggered platforms. */
+		temp = smsc911x_reg_read(pdata, INT_EN);
+		temp &= (~INT_EN_RSFL_EN_);
+		smsc911x_reg_write(pdata, INT_EN, temp);
+
+		if (likely(napi_schedule_prep(&pdata->napi)))
 			/* Schedule a NAPI poll */
 			__napi_schedule(&pdata->napi);
-		} else {
+		else {
+			temp |= INT_EN_RSFL_EN_;
+			smsc911x_reg_write(pdata, INT_EN, temp);
 			SMSC_WARNING(RX_ERR,
 				"napi_schedule_prep failed");
 		}
-- 
1.5.6.5

