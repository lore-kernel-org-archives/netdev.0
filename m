From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v3 08/10] ieee802154: ensure that first RF212 state comes from TRX_OFF
Date: Mon, 17 Feb 2014 11:34:13 +0100
Message-ID: <1392633255-26605-9-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392633255-26605-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:59604 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbaBQKeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 05:34:22 -0500
In-Reply-To: <1392633255-26605-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A documented erratum of the RF212 chip describes that some versions of
RF212 may not be properly reset by the standard reset procedure. The
described workaround seems to not fully work either; my RF212 chips will
not correctly receive any frames unless they are taken from RX mode to
TRX_OFF and back to RX mode, effectively forcing a up-down-up-cycle.
Going to TRX_OFF and to RX without intermediate state changes at least
once fixes this.

The same transition is allowed for RF230, so simply do it all the time.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c | 25 +++----------------------
 1 file changed, 3 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 20596be..345b2ee 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -926,18 +926,9 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	if (rc)
 		return rc;
 
-	dev_info(&lp->spi->dev, "Status: %02x\n", status);
-	if (status == STATE_P_ON) {
-		rc = at86rf230_write_subreg(lp, SR_TRX_CMD,
-					    STATE_FORCE_TRX_OFF);
-		if (rc)
-			return rc;
-		msleep(1);
-		rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
-		if (rc)
-			return rc;
-		dev_info(&lp->spi->dev, "Status: %02x\n", status);
-	}
+	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_FORCE_TRX_OFF);
+	if (rc)
+		return rc;
 
 	/* configure irq polarity, defaults to high active */
 	if (pdata->irq_type & (IRQF_TRIGGER_FALLING | IRQF_TRIGGER_LOW))
@@ -965,16 +956,6 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	/* Wait the next SLEEP cycle */
 	msleep(100);
 
-	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_TX_ON);
-	if (rc)
-		return rc;
-	msleep(1);
-
-	rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
-	if (rc)
-		return rc;
-	dev_info(&lp->spi->dev, "Status: %02x\n", status);
-
 	rc = at86rf230_read_subreg(lp, SR_DVDD_OK, &status);
 	if (rc)
 		return rc;
-- 
1.9.0
