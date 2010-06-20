From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.35-rc3] smc91c92_cs: fix the problem that lan &
 modem does not work simultaneously
Date: Sun, 20 Jun 2010 10:24:27 +0900
Message-ID: <20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:32808 "EHLO
	defg302.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab0FTB3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jun 2010 21:29:31 -0400
Received: from userg507.nifty.com (userg507p.nifty.com [172.22.128.87])by defg302.nifty.com with ESMTP id o5K1PpxA020607
	for <netdev@vger.kernel.org>; Sun, 20 Jun 2010 10:25:51 +0900
Received: from localhost.localdomain (eaoska141023.adsl.ppp.infoweb.ne.jp [219.104.14.23])by userg507.nifty.com with SMTP id o5K1POdK028347
	for <netdev@vger.kernel.org>; Sun, 20 Jun 2010 10:25:24 +0900
In-Reply-To: <20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


smc91c92_cs:
  Fix the problem that lan & modem does not work simultaneously
  in the Megahertz multi-function card.
  We need to write MEGAHERTZ_ISR to retrigger interrupt.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

--

--- linux-2.6.35-rc3/drivers/net/pcmcia/smc91c92_cs.c.orig	2010-06-19 09:42:59.000000000 +0900
+++ linux-2.6.35-rc3/drivers/net/pcmcia/smc91c92_cs.c	2010-06-19 11:25:34.000000000 +0900
@@ -1505,12 +1505,20 @@ irq_done:
 	writeb(cor & ~COR_IREQ_ENA, smc->base + MOT_LAN + CISREG_COR);
 	writeb(cor, smc->base + MOT_LAN + CISREG_COR);
     }
-#ifdef DOES_NOT_WORK
-    if (smc->base != NULL) { /* Megahertz MFC's */
-	readb(smc->base+MEGAHERTZ_ISR);
-	readb(smc->base+MEGAHERTZ_ISR);
+
+    if ((smc->base != NULL) &&  /* Megahertz MFC's */
+	(smc->manfid == MANFID_MEGAHERTZ) &&
+	(smc->cardid == PRODID_MEGAHERTZ_EM3288)) {
+
+	u_char tmp;
+	tmp = readb(smc->base+MEGAHERTZ_ISR);
+	tmp = readb(smc->base+MEGAHERTZ_ISR);
+
+	/* Retrigger interrupt if needed */
+	writeb(tmp, smc->base + MEGAHERTZ_ISR);
+	writeb(tmp, smc->base + MEGAHERTZ_ISR);
     }
-#endif
+
     spin_unlock(&smc->lock);
     return IRQ_RETVAL(handled);
 }
