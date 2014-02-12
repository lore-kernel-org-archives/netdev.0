From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 08/10] ieee802154: ensure that first RF212 state comes from TRX_OFF
Date: Wed, 12 Feb 2014 17:37:12 +0100
Message-ID: <1392223034-19955-9-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:46837 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261AbaBLQht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:37:49 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s1CGbhWW030933
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 17:37:44 +0100
In-Reply-To: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
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
 drivers/net/ieee802154/at86rf230.c |   25 +++----------------------
 1 file changed, 3 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 9e3bb34..77b8111 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -930,18 +930,9 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	if (rc)
 		return rc;
 
-	dev_info(&lp->spi->dev, "Status: %02x\n", status);
-	if (status == STATE_P_ON) {
-		rc = at86rf230_write_subreg(lp, SR_TRX_CMD,
-			STATE_FORCE_TRX_OFF);
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
@@ -969,16 +960,6 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
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
1.7.9.5
