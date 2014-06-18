From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net] at86rf230: fix irq setup
Date: Wed, 18 Jun 2014 16:28:49 +0200
Message-ID: <1403101729-29448-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:52084 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967088AbaFRO3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 10:29:22 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.4/8.14.4/Debian-7) with ESMTP id s5IETGjg026421
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 16:29:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8eba0eefae24953962067 ("at86rf230: remove irq_type in
request_irq") removed the trigger configuration when requesting an irq,
and instead relied on the interrupt trigger to be properly configured
already. This does not seem to be an assumption that can be safely made,
since boards disable all interrupt triggers on boot.

On these boards, force the irq to trigger on rising edge, which is also
the default for the chip.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 4517b14..5089941 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1137,6 +1137,8 @@ static int at86rf230_probe(struct spi_device *spi)
 	dev->flags = IEEE802154_HW_OMIT_CKSUM | IEEE802154_HW_AACK;
 
 	irq_type = irq_get_trigger_type(spi->irq);
+	if (!irq_type)
+		irq_type = IRQF_TRIGGER_RISING;
 	if (irq_type & (IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING)) {
 		irq_worker = at86rf230_irqwork;
 		irq_handler = at86rf230_isr;
@@ -1168,7 +1170,8 @@ static int at86rf230_probe(struct spi_device *spi)
 	if (rc)
 		goto err_hw_init;
 
-	rc = devm_request_irq(&spi->dev, spi->irq, irq_handler, IRQF_SHARED,
+	rc = devm_request_irq(&spi->dev, spi->irq, irq_handler,
+			      IRQF_SHARED | irq_type,
 			      dev_name(&spi->dev), lp);
 	if (rc)
 		goto err_hw_init;
-- 
1.7.9.5
