From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.35-rc3-git7] axnet_cs: local_irq_save before
 calling ei_irq_wrapper
Date: Tue, 6 Jul 2010 20:22:43 +0900
Message-ID: <20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defg500.nifty.com ([202.248.238.127]:49346 "EHLO
	defg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726Ab0GFL2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jul 2010 07:28:22 -0400
Received: from userg508.nifty.com (userg508p.nifty.com [172.22.128.88])by defg500.nifty.com with ESMTP id o66BNnXU000926
	for <netdev@vger.kernel.org>; Tue, 6 Jul 2010 20:23:49 +0900
Received: from localhost.localdomain (eaoska325197.adsl.ppp.infoweb.ne.jp [115.176.54.197])by userg508.nifty.com with SMTP id o66BMrEP032396
	for <netdev@vger.kernel.org>; Tue, 6 Jul 2010 20:22:53 +0900
In-Reply-To: <20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


axnet_cs:
    local_irq_save before calling ei_irq_wrapper.


Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.35-git7/drivers/net/pcmcia/axnet_cs.c.orig	2010-07-04 08:28:15.000000000 +0900
+++ linux-2.6.35-git7/drivers/net/pcmcia/axnet_cs.c	2010-07-04 08:40:23.000000000 +0900
@@ -606,6 +606,7 @@ static void ei_watchdog(u_long arg)
     unsigned int nic_base = dev->base_addr;
     unsigned int mii_addr = nic_base + AXNET_MII_EEP;
     u_short link;
+    unsigned long flags;
 
     if (!netif_device_present(dev)) goto reschedule;
 
@@ -614,7 +615,10 @@ static void ei_watchdog(u_long arg)
     if (info->stale++ && (inb_p(nic_base + EN0_ISR) & ENISR_ALL)) {
 	if (!info->fast_poll)
 	    printk(KERN_INFO "%s: interrupt(s) dropped!\n", dev->name);
+	local_irq_save(flags);
 	ei_irq_wrapper(dev->irq, dev);
+	local_irq_restore(flags);
+
 	info->fast_poll = HZ;
     }
     if (info->fast_poll) {
