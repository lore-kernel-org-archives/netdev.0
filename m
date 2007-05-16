From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 6/10] spidernet: Don't terminate the RX ring
Date: Wed, 16 May 2007 17:15:05 -0500
Message-ID: <20070516221505.GF4997@austin.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:49042 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760714AbXEPWPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 18:15:06 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GMF60u018137
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:15:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GMF646557254
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:15:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GMF5NV007731
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:15:05 -0400
Content-Disposition: inline
In-Reply-To: <20070516215605.GA4325@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is no real reason to terminate the RX ring; it
doesn't make the operation any smooother, and it does
require an extra sync. So don't do it.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-05-15 13:31:16.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-05-15 13:51:39.000000000 -0500
@@ -461,13 +461,9 @@ spider_net_prepare_rx_descr(struct spide
 		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	} else {
 		hwdescr->buf_addr = buf;
-		hwdescr->next_descr_addr = 0;
 		wmb();
 		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_CARDOWNED |
 					 SPIDER_NET_DMAC_NOINTR_COMPLETE;
-
-		wmb();
-		descr->prev->hwdescr->next_descr_addr = descr->bus_addr;
 	}
 
 	return 0;
@@ -556,12 +552,16 @@ spider_net_refill_rx_chain(struct spider
 static int
 spider_net_alloc_rx_skbs(struct spider_net_card *card)
 {
-	int result;
-	struct spider_net_descr_chain *chain;
+	struct spider_net_descr_chain *chain = &card->rx_chain;
+	struct spider_net_descr *start= chain->tail;
+	struct spider_net_descr *descr = start;
 
-	result = -ENOMEM;
+	/* Link up the hardware chain pointers */
+	do {
+		descr->prev->hwdescr->next_descr_addr = descr->bus_addr;
+		descr = descr->next;
+	} while (descr != start);
 
-	chain = &card->rx_chain;
 	/* Put at least one buffer into the chain. if this fails,
 	 * we've got a problem. If not, spider_net_refill_rx_chain
 	 * will do the rest at the end of this function. */
@@ -578,7 +578,7 @@ spider_net_alloc_rx_skbs(struct spider_n
 
 error:
 	spider_net_free_rx_chain_contents(card);
-	return result;
+	return -ENOMEM;
 }
 
 /**
