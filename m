From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 3/16] Spidernet RX Locking
Date: Wed, 6 Dec 2006 17:31:34 -0600
Message-ID: <20061206233134.GC4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:57131 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937783AbWLFXbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 18:31:43 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6NVcWj011024
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:31:38 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6NVccs447276
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 16:31:38 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6NVbq9015471
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 16:31:38 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The RX packet handling can be called from several
places, yet does not protect the rx ring structure.
This patch places the ring buffer pointers under a lock.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 15:58:27.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 16:01:49.000000000 -0600
@@ -969,28 +969,33 @@ static int
 spider_net_decode_one_descr(struct spider_net_card *card, int napi)
 {
 	struct spider_net_descr_chain *chain = &card->rx_chain;
-	struct spider_net_descr *descr = chain->tail;
+	struct spider_net_descr *descr;
 	int status;
 	int result;
+	unsigned long flags;
+
+	spin_lock_irqsave(&chain->lock, flags);
+	descr = chain->tail;
 
 	status = spider_net_get_descr_status(descr);
 
 	if (status == SPIDER_NET_DESCR_CARDOWNED) {
 		/* nothing in the descriptor yet */
-		result=0;
-		goto out;
+		spin_unlock_irqrestore(&chain->lock, flags);
+		return 0;
 	}
 
 	if (status == SPIDER_NET_DESCR_NOT_IN_USE) {
 		/* not initialized yet, the ring must be empty */
+		spin_unlock_irqrestore(&chain->lock, flags);
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
-		result=0;
-		goto out;
+		return 0;
 	}
 
 	/* descriptor definitively used -- move on tail */
 	chain->tail = descr->next;
+	spin_unlock_irqrestore(&chain->lock, flags);
 
 	result = 0;
 	if ( (status == SPIDER_NET_DESCR_RESPONSE_ERROR) ||
@@ -1022,7 +1027,6 @@ refill:
 	/* change the descriptor state: */
 	if (!napi)
 		spider_net_refill_rx_chain(card);
-out:
 	return result;
 }
 
