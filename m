From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 15/18] spidernet: minor RX optimization
Date: Thu, 7 Jun 2007 14:55:08 -0500
Message-ID: <20070607195508.GO16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:54545 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965659AbXFGTzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:55:11 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JtARh016756
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:55:10 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57Jt90P177482
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:55:09 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57Jt9SB006694
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:55:09 -0600
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



A minor optimization on the RX side is that the hardware does 
not need to be kicked if space did not open up in the RX ring.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:56:10.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:56:23.000000000 -0500
@@ -525,6 +525,7 @@ spider_net_refill_rx_chain(struct spider
 {
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	unsigned long flags;
+	int cnt = 0;
 
 	/* one context doing the refill (and a second context seeing that
 	 * and omitting it) is ok. If called by NAPI, we'll be called again
@@ -538,9 +539,13 @@ spider_net_refill_rx_chain(struct spider
 		if (spider_net_prepare_rx_descr(card, chain->head))
 			break;
 		chain->head = chain->head->next;
+		cnt ++;
 	}
 
 	spin_unlock_irqrestore(&chain->lock, flags);
+
+	if (cnt)
+		spider_net_enable_rxdmac(card);
 }
 
 /**
@@ -573,7 +578,6 @@ spider_net_alloc_rx_skbs(struct spider_n
 	/* This will allocate the rest of the rx buffers;
 	 * if not, it's business as usual later on. */
 	spider_net_refill_rx_chain(card);
-	spider_net_enable_rxdmac(card);
 	return 0;
 
 error:
@@ -1305,7 +1309,6 @@ spider_net_poll(struct net_device *netde
 	netdev->quota -= packets_done;
 	*budget -= packets_done;
 	spider_net_refill_rx_chain(card);
-	spider_net_enable_rxdmac(card);
 
 	spider_net_cleanup_tx_ring(card);
 
@@ -1590,7 +1593,6 @@ spider_net_handle_error_irq(struct spide
 			card->ignore_rx_ramfull = 1;
 			spider_net_resync_head_ptr(card);
 			spider_net_refill_rx_chain(card);
-			spider_net_enable_rxdmac(card);
 			card->num_rx_ints ++;
 			netif_rx_schedule(card->netdev);
 		}
@@ -1611,7 +1613,6 @@ spider_net_handle_error_irq(struct spide
 		/* Could happen when rx chain is full */
 		spider_net_resync_head_ptr(card);
 		spider_net_refill_rx_chain(card);
-		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
 		netif_rx_schedule(card->netdev);
 		show_error = 0;
@@ -1625,7 +1626,6 @@ spider_net_handle_error_irq(struct spide
 		/* Could happen when rx chain is full */
 		spider_net_resync_head_ptr(card);
 		spider_net_refill_rx_chain(card);
-		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
 		netif_rx_schedule(card->netdev);
 		show_error = 0;
