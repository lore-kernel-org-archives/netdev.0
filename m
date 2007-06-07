From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 7/18] spidernet: Don't terminate the RX ring
Date: Thu, 7 Jun 2007 14:33:28 -0500
Message-ID: <20070607193328.GG16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:35429 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765421AbXFGTda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:33:30 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JXTlS002990
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:33:29 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JXTak248836
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:33:29 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JXTsn019953
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:33:29 -0600
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Subject: [PATCH 7/18] spidernet: Don't terminate the RX ring

There is no real reason to terminate the RX ring; it
doesn't make the operation any smooother, and it does
require an extra sync. So don't do it.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:51:52.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:51:55.000000000 -0500
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
@@ -578,7 +578,7 @@ spider_net_alloc_rx_skbs(struct spider_n
 
 error:
 	spider_net_free_rx_chain_contents(card);
-	return result;
+	return -ENOMEM;
 }
 
 /**
