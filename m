From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.37-rc1] axnet_cs: fix resume problem for some
 Ax88790 chip
Date: Sun, 7 Nov 2010 00:11:24 +0900
Message-ID: <20101107001124.7d8ef6c4.ken_kawasaki@spring.nifty.jp>
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
	<20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
	<20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
	<20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
	<20100829074501.946ebcb8.ken_kawasaki@spring.nifty.jp>
	<20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defg501.nifty.com ([202.248.238.128]:40930 "EHLO
	defg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061Ab0KFPUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Nov 2010 11:20:16 -0400
Received: from userg508.nifty.com (userg508p.nifty.com [172.22.128.88])by defg501.nifty.com with ESMTP id oA6FCaQT011855
	for <netdev@vger.kernel.org>; Sun, 7 Nov 2010 00:12:36 +0900
Received: from localhost.localdomain (eaoska101220.adsl.ppp.infoweb.ne.jp [218.226.16.220])by userg508.nifty.com with SMTP id oA6FBqeh004479
	for <netdev@vger.kernel.org>; Sun, 7 Nov 2010 00:11:52 +0900
In-Reply-To: <20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


axnet_cs:
    Some Ax88790 chip need to reinitialize the CISREG_CCSR register
    after resume.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.37-rc1/drivers/net/pcmcia/axnet_cs.c.orig	2010-11-06 07:48:17.000000000 +0900
+++ linux-2.6.37-rc1/drivers/net/pcmcia/axnet_cs.c	2010-11-06 08:08:40.000000000 +0900
@@ -111,13 +111,14 @@ static irqreturn_t ax_interrupt(int irq,
 CISREG_CCSR
 typedef struct axnet_dev_t {
 	struct pcmcia_device	*p_dev;
-    caddr_t		base;
-    struct timer_list	watchdog;
-    int			stale, fast_poll;
-    u_short		link_status;
-    u_char		duplex_flag;
-    int			phy_id;
-    int			flags;
+	caddr_t	base;
+	struct timer_list	watchdog;
+	int	stale, fast_poll;
+	u_short	link_status;
+	u_char	duplex_flag;
+	int	phy_id;
+	int	flags;
+	int	active_low;
 } axnet_dev_t;
 
 static inline axnet_dev_t *PRIV(struct net_device *dev)
@@ -322,6 +323,8 @@ static int axnet_config(struct pcmcia_de
     if (info->flags & IS_AX88790)
 	outb(0x10, dev->base_addr + AXNET_GPIO);  /* select Internal PHY */
 
+    info->active_low = 0;
+
     for (i = 0; i < 32; i++) {
 	j = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 1);
 	j2 = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 2);
@@ -329,15 +332,18 @@ static int axnet_config(struct pcmcia_de
 	if ((j != 0) && (j != 0xffff)) break;
     }
 
-    /* Maybe PHY is in power down mode. (PPD_SET = 1) 
-       Bit 2 of CCSR is active low. */ 
     if (i == 32) {
+	/* Maybe PHY is in power down mode. (PPD_SET = 1)
+	   Bit 2 of CCSR is active low. */
 	pcmcia_write_config_byte(link, CISREG_CCSR, 0x04);
 	for (i = 0; i < 32; i++) {
 	    j = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 1);
 	    j2 = mdio_read(dev->base_addr + AXNET_MII_EEP, i, 2);
 	    if (j == j2) continue;
-	    if ((j != 0) && (j != 0xffff)) break;
+	    if ((j != 0) && (j != 0xffff)) {
+		info->active_low = 1;
+		break;
+	    }
 	}
     }
 
@@ -383,8 +389,12 @@ static int axnet_suspend(struct pcmcia_d
 static int axnet_resume(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
+	axnet_dev_t *info = PRIV(dev);
 
 	if (link->open) {
+		if (info->active_low == 1)
+			pcmcia_write_config_byte(link, CISREG_CCSR, 0x04);
+
 		axnet_reset_8390(dev);
 		AX88190_init(dev, 1);
 		netif_device_attach(dev);
