From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH] spidernet: enable poll() before registering interrupts
Date: Wed, 22 Aug 2007 09:27:57 +0900 (JST)
Message-ID: <20070822.092757.-432817388.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org, arnd@arndb.de
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx12.toshiba.co.jp ([61.202.160.132]:62058 "EHLO
	imx12.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbXHVA2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 20:28:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We must not call netif_poll_enable after enabling interrupts,
because an interrupt might come in and set the __LINK_STATE_RX_SCHED
bit before we get to clear that bit again. If that happens,
the next call to the ->poll() function will oops.

Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>
Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

I refreshed Arnd-san's patch.


Index: linux-powerpc-git/drivers/net/spider_net.c
===================================================================
--- linux-powerpc-git.orig/drivers/net/spider_net.c	2007-08-21 16:58:44.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.c	2007-08-21 17:11:07.000000000 +0900
@@ -2030,6 +2030,7 @@ spider_net_open(struct net_device *netde
 	/* further enhancement: setup hw vlan, if needed */
 
 	result = -EBUSY;
+	netif_poll_enable(netdev);
 	if (request_irq(netdev->irq, spider_net_interrupt,
 			     IRQF_SHARED, netdev->name, netdev))
 		goto register_int_failed;
@@ -2038,13 +2039,13 @@ spider_net_open(struct net_device *netde
 
 	netif_start_queue(netdev);
 	netif_carrier_on(netdev);
-	netif_poll_enable(netdev);
 
 	spider_net_enable_interrupts(card);
 
 	return 0;
 
 register_int_failed:
+	netif_poll_disable(netdev);
 	spider_net_free_rx_chain_contents(card);
 alloc_skbs_failed:
 	spider_net_free_chain(card, &card->rx_chain);
