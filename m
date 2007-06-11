From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 3/15] spidernet: Don't terminate the RX ring
Date: Mon, 11 Jun 2007 13:23:42 -0500
Message-ID: <20070611182342.GC13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:41933 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752969AbXFKSXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 14:23:44 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIOnI3025381
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:24:49 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BINhUa559446
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:23:43 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BINgkR018196
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:23:43 -0400
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



The terminated RX ring will cause trouble during the RX ram full
conditions, leading to a hung driver, as the hardware can't find
the next descr.  There is no real reason to terminate the RX ring; 
it doesn't make the operation any smooother, and it does
require an extra sync. So don't do it.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-08 17:35:33.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-08 17:36:19.000000000 -0500
@@ -460,13 +460,9 @@ spider_net_prepare_rx_descr(struct spide
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
@@ -541,12 +537,16 @@ spider_net_refill_rx_chain(struct spider
 static int
 spider_net_alloc_rx_skbs(struct spider_net_card *card)
 {
-	int result;
-	struct spider_net_descr_chain *chain;
+	struct spider_net_descr_chain *chain = &card->rx_chain;
+	struct spider_net_descr *start = chain->tail;
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
@@ -563,7 +563,7 @@ spider_net_alloc_rx_skbs(struct spider_n
 
 error:
 	spider_net_free_rx_chain_contents(card);
-	return result;
+	return -ENOMEM;
 }
 
 /**
