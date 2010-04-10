From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.34-rc3-git9] smc91c92_cs: define multicast_table
 as unsigned char
Date: Sun, 11 Apr 2010 07:50:14 +0900
Message-ID: <20100411075014.d3e80847.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100328055537.13ef6c01.ken_kawasaki@spring.nifty.jp>
	<20100404061434.eb98ef3e.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg507.nifty.com ([202.248.238.87]:60733 "EHLO
	userg507.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357Ab0DJWu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Apr 2010 18:50:59 -0400
Received: from localhost.localdomain (eaoska170123.adsl.ppp.infoweb.ne.jp [219.116.19.123])by userg507.nifty.com with SMTP id o3AMoj6p012527
	for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 07:50:45 +0900
In-Reply-To: <20100404061434.eb98ef3e.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


smc91c92_cs:
  * define multicast_table as unsigned char
  * remove unnecessary "#ifndef final_version"

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.34-rc3-git9/drivers/net/pcmcia/smc91c92_cs.c.orig	2010-04-10 07:08:09.000000000 +0900
+++ linux-2.6.34-rc3-git9/drivers/net/pcmcia/smc91c92_cs.c	2010-04-10 07:31:47.000000000 +0900
@@ -1608,9 +1608,12 @@ static void set_rx_mode(struct net_devic
 {
     unsigned int ioaddr = dev->base_addr;
     struct smc_private *smc = netdev_priv(dev);
-    u_int multicast_table[ 2 ] = { 0, };
+    unsigned char multicast_table[8];
     unsigned long flags;
     u_short rx_cfg_setting;
+    int i;
+
+    memset(multicast_table, 0, sizeof(multicast_table));
 
     if (dev->flags & IFF_PROMISC) {
 	rx_cfg_setting = RxStripCRC | RxEnable | RxPromisc | RxAllMulti;
@@ -1622,10 +1625,6 @@ static void set_rx_mode(struct net_devic
 
 	    netdev_for_each_mc_addr(mc_addr, dev) {
 		u_int position = ether_crc(6, mc_addr->dmi_addr);
-#ifndef final_version		/* Verify multicast address. */
-		if ((mc_addr->dmi_addr[0] & 1) == 0)
-		    continue;
-#endif
 		multicast_table[position >> 29] |= 1 << ((position >> 26) & 7);
 	    }
 	}
@@ -1635,8 +1634,8 @@ static void set_rx_mode(struct net_devic
     /* Load MC table and Rx setting into the chip without interrupts. */
     spin_lock_irqsave(&smc->lock, flags);
     SMC_SELECT_BANK(3);
-    outl(multicast_table[0], ioaddr + MULTICAST0);
-    outl(multicast_table[1], ioaddr + MULTICAST4);
+    for (i = 0; i < 8; i++)
+	outb(multicast_table[i], ioaddr + MULTICAST0 + i);
     SMC_SELECT_BANK(0);
     outw(rx_cfg_setting, ioaddr + RCR);
     SMC_SELECT_BANK(2);
