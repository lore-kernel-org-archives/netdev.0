From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.26-git] enc28j60: don't specify (wrong) IRQ type
Date: Thu, 24 Jul 2008 17:47:56 -0700
Message-ID: <200807241747.56954.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.sbc.mail.sp1.yahoo.com ([69.147.64.94]:48600 "HELO
	smtp121.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753227AbYGYAr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 20:47:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

Recent changes to the IRQ framework have made passing the wrong
trigger type to request_irq() become a fatal error.  In the case
of the enc28j60 driver, it stopped working in my test harness.

(Specifically:  the signal detects "pin change" events, both edges,
not just falling edges.  Similarly, other boards might route it
through an inverter.  Trigger type are board-specific.)

This fixes that problem by the usual fix of expecting board setup
code to have set up the correct IRQ trigger type.  The best known
example of that being x86 setup.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1547,8 +1547,10 @@ static int __devinit enc28j60_probe(struct spi_device *spi)
 	random_ether_addr(dev->dev_addr);
 	enc28j60_set_hw_macaddr(dev);
 
-	ret = request_irq(spi->irq, enc28j60_irq, IRQF_TRIGGER_FALLING,
-			  DRV_NAME, priv);
+	/* Board setup must set the relevant edge trigger type;
+	 * level triggers won't currently work.
+	 */
+	ret = request_irq(spi->irq, enc28j60_irq, 0, DRV_NAME, priv);
 	if (ret < 0) {
 		if (netif_msg_probe(priv))
 			dev_err(&spi->dev, DRV_NAME ": request irq %d failed "
