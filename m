From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 8/16] Spidernet RX Refill
Date: Wed, 6 Dec 2006 17:39:12 -0600
Message-ID: <20061206233912.GH4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36682 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937799AbWLFXj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 18:39:29 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6NdeDo019720
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:39:40 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6NdEus210742
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:39:14 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6NdDW8031946
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:39:13 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The invocation of the rx ring refill routine is haphazard;
centralize and make its usage consistent.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 16:03:06.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 16:03:08.000000000 -0600
@@ -968,8 +968,6 @@ spider_net_decode_one_descr(struct spide
 	if (status == SPIDER_NET_DESCR_NOT_IN_USE) {
 		/* not initialized yet, the ring must be empty */
 		spin_unlock_irqrestore(&chain->lock, flags);
-		spider_net_refill_rx_chain(card);
-		spider_net_enable_rxdmac(card);
 		return 0;
 	}
 
@@ -1058,6 +1056,7 @@ spider_net_poll(struct net_device *netde
 	netdev->quota -= packets_done;
 	*budget -= packets_done;
 	spider_net_refill_rx_chain(card);
+	spider_net_enable_rxdmac(card);
 
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
@@ -1197,11 +1196,9 @@ spider_net_set_mac(struct net_device *ne
 static void
 spider_net_handle_rxram_full(struct spider_net_card *card)
 {
-	int rc = 1;
-	while (rc) {
-		rc = spider_net_decode_one_descr(card, 0);
-		spider_net_refill_rx_chain(card);
-	}
+	while (spider_net_decode_one_descr(card, 0));
+
+	spider_net_refill_rx_chain(card);
 	spider_net_enable_rxchtails(card);
 	spider_net_enable_rxdmac(card);
 	netif_rx_schedule(card->netdev);
