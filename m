From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] spidernet: enable poll() before registering interrupts
Date: Thu, 12 Jul 2007 01:19:11 +0200
Message-ID: <200707120119.12589.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	Christian Krafft <krafft@de.ibm.com>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:63378 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758355AbXGKXV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 19:21:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We must not call netif_poll_enable after enabling interrupts,
because an interrupt might come in and set the __LINK_STATE_RX_SCHED
bit before we get to clear that bit again. If that happens,
the next call to the ->poll() function will oops.

Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>
---
This was found during testing with the fedora kernel,
with all patches from netdev-2.6.git applied.

It may not be the right fix, but this is currently the
only way I can get that kernel to boot.

One part I don't understand at the moment is that Christian
Krafft reported the same problem with tg3, but that driver
has all interrupts disabled at the device while calling
the request_irq() function, which seems to be the best
solution for avoiding the bug in the first place.

Index: linux-2.6/drivers/net/spider_net.c
===================================================================
--- linux-2.6.orig/drivers/net/spider_net.c
+++ linux-2.6/drivers/net/spider_net.c
@@ -1997,6 +1997,7 @@ spider_net_open(struct net_device *netde
 	/* further enhancement: setup hw vlan, if needed */
 
 	result = -EBUSY;
+	netif_poll_enable(netdev);
 	if (request_irq(netdev->irq, spider_net_interrupt,
 			     IRQF_SHARED, netdev->name, netdev))
 		goto register_int_failed;
@@ -2005,11 +2006,11 @@ spider_net_open(struct net_device *netde
 
 	netif_start_queue(netdev);
 	netif_carrier_on(netdev);
-	netif_poll_enable(netdev);
 
 	return 0;
 
 register_int_failed:
+	netif_poll_disable(netdev);
 	spider_net_free_rx_chain_contents(card);
 alloc_skbs_failed:
 	spider_net_free_chain(card, &card->rx_chain);
