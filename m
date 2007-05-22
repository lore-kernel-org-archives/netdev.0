From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 6/10] spidernet: Don't terminate the RX ring
Date: Tue, 22 May 2007 18:40:59 -0500
Message-ID: <20070522234059.GE2147@austin.ibm.com>
References: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:55358 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755821AbXEVXlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 19:41:01 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MNf0qO007739
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:41:00 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MNf0ce398360
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:41:00 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MNex8N015347
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:41:00 -0400
Content-Disposition: inline
In-Reply-To: <20070522230942.GT5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is no real reason to terminate the RX ring; it
doesn't make the operation any smooother, and it does
require an extra sync. So don't do it.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

Index: netdev-2.6/drivers/net/spider_net.c
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.c	2007-05-22 18:03:34.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.c	2007-05-22 18:03:35.000000000 -0500
@@ -462,13 +462,9 @@ spider_net_prepare_rx_descr(struct spide
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
@@ -557,12 +553,16 @@ spider_net_refill_rx_chain(struct spider
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
@@ -579,7 +579,7 @@ spider_net_alloc_rx_skbs(struct spider_n
 
 error:
 	spider_net_free_rx_chain_contents(card);
-	return result;
+	return -ENOMEM;
 }
 
 /**
