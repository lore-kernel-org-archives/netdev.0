From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 3.0-rc1] smc91c92_cs: set smc->base to NULL before
 iounmap
Date: Sun, 5 Jun 2011 08:20:16 +0900
Message-ID: <20110605082016.5a26f61a.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
	<20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
	<20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
	<20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
	<20100829074501.946ebcb8.ken_kawasaki@spring.nifty.jp>
	<20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
	<20110111205558.98fcab01.ken_kawasaki@spring.nifty.jp>
	<20110131061616.05b2fa6f.ken_kawasaki@spring.nifty.jp>
	<20110221000720.e93225c1.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defg500.nifty.com ([202.248.238.127]:32692 "EHLO
	defg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754307Ab1FDX2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2011 19:28:53 -0400
Received: from userg507.nifty.com (userg507p.nifty.com [172.22.128.87])by defg500.nifty.com with ESMTP id p54NMJJN002666
	for <netdev@vger.kernel.org>; Sun, 5 Jun 2011 08:22:19 +0900
Received: from localhost.localdomain (eaoska102210.adsl.ppp.infoweb.ne.jp [218.226.17.210])by userg507.nifty.com with SMTP id p54NLriB024230
	for <netdev@vger.kernel.org>; Sun, 5 Jun 2011 08:21:53 +0900
In-Reply-To: <20110221000720.e93225c1.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


smc91c92_cs:
    set smc->base to NULL before iounmap
    to avoid writing to smc->base in smc_interrupt.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-3.0-rc1/drivers/net/pcmcia/smc91c92_cs.c.orig	2011-06-04 19:38:07.000000000 +0900
+++ linux-3.0-rc1/drivers/net/pcmcia/smc91c92_cs.c	2011-06-05 07:59:51.000000000 +0900
@@ -315,6 +315,7 @@ static int smc91c92_probe(struct pcmcia_
     smc = netdev_priv(dev);
     smc->p_dev = link;
     link->priv = dev;
+    smc->base = NULL;
 
     spin_lock_init(&smc->lock);
 
@@ -954,11 +955,17 @@ config_failed:
 
 static void smc91c92_release(struct pcmcia_device *link)
 {
+	struct net_device *dev = link->priv;
+	struct smc_private *smc = netdev_priv(dev);
+
 	dev_dbg(&link->dev, "smc91c92_release\n");
-	if (link->resource[2]->end) {
-		struct net_device *dev = link->priv;
-		struct smc_private *smc = netdev_priv(dev);
-		iounmap(smc->base);
+
+	if (smc->base != NULL) {
+ 		u_char __iomem *tmp;
+
+		tmp = smc->base;
+		smc->base = NULL;    /* set NULL before iounmap */
+		iounmap(tmp);
 	}
 	pcmcia_disable_device(link);
 }
@@ -1444,7 +1451,7 @@ irq_done:
 	mask_bits(0x00ff, ioaddr-0x10+OSITECH_RESET_ISR);
 	set_bits(0x0300, ioaddr-0x10+OSITECH_RESET_ISR);
     }
-    if (smc->manfid == MANFID_MOTOROLA) {
+    if ((smc->base != NULL) && (smc->manfid == MANFID_MOTOROLA)) {
 	u_char cor;
 	cor = readb(smc->base + MOT_UART + CISREG_COR);
 	writeb(cor & ~COR_IREQ_ENA, smc->base + MOT_UART + CISREG_COR);
