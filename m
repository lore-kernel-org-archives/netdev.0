From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH]  axnet_cs: fix phy_id detection for bogus Asix chip.
Date: Sun, 5 Apr 2009 09:49:07 +0900
Message-ID: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defg501.nifty.com ([202.248.238.128]:64433 "EHLO
	defg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755892AbZDEAyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 20:54:31 -0400
Received: from userg500.nifty.com (userg500p.nifty.com [172.22.128.80])by defg501.nifty.com with ESMTP id n350npcB024533
	for <netdev@vger.kernel.org>; Sun, 5 Apr 2009 09:49:51 +0900
Received: from localhost.localdomain (eaoska168017.adsl.ppp.infoweb.ne.jp [219.116.17.17])by userg500.nifty.com with SMTP id n350n9qf020595
	for <netdev@vger.kernel.org>; Sun, 5 Apr 2009 09:49:09 +0900
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



axnet_cs:

(1) Some Asix phy return bogus value except 0 or 0xffff.
    Skip this phy_id.

(2) Some Asix chip need to set "select Internal PHY" bit
    at AX88190_init.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.29-git1/drivers/net/pcmcia/axnet_cs.c.orig	2009-03-29 11:55:26.000000000 +0900
+++ linux-2.6.29-git1/drivers/net/pcmcia/axnet_cs.c	2009-03-29 12:01:40.000000000 +0900
@@ -339,7 +339,7 @@ static int axnet_config(struct pcmcia_de
 {
     struct net_device *dev = link->priv;
     axnet_dev_t *info = PRIV(dev);
-    int i, j, last_ret, last_fn;
+    int i, j, j2, last_ret, last_fn;
 
     DEBUG(0, "axnet_config(0x%p)\n", link);
 
@@ -388,6 +388,8 @@ static int axnet_config(struct pcmcia_de
 
     for (i = 0; i < 32; i++) {
 	j = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 1);
+	j2 = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 2);
+	if (j == j2) continue;
 	if ((j != 0) && (j != 0xffff)) break;
     }
 
@@ -398,6 +400,8 @@ static int axnet_config(struct pcmcia_de
  	pcmcia_access_configuration_register(link, &reg);
 	for (i = 0; i < 32; i++) {
 	    j = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 1);
+	    j2 = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 2);
+	    if (j == j2) continue;
 	    if ((j != 0) && (j != 0xffff)) break;
 	}
     }
@@ -1767,6 +1771,9 @@ static void AX88190_init(struct net_devi
 	ei_local->tx1 = ei_local->tx2 = 0;
 	ei_local->txing = 0;
 
+	if (info->flags & IS_AX88790)	/* select Internal PHY */
+		outb(0x10, e8390_base + AXNET_GPIO);
+
 	if (startp) 
 	{
 		outb_p(0xff,  e8390_base + EN0_ISR);


