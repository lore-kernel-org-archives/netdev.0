From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 4/16] Spidernet Refactor RX refill
Date: Wed, 6 Dec 2006 17:33:16 -0600
Message-ID: <20061206233316.GD4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:58802 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937794AbWLFXdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 18:33:19 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6NXILo031649
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:33:18 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6NXIJr305644
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:33:18 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6NXGri020634
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:33:17 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Refactor how spider_net_refill_rx_chain() is called. 
No functional change; this just simplifies the code
by moving the subroutine call to a more appropriate spot.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 16:01:49.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 16:02:58.000000000 -0600
@@ -1023,10 +1023,8 @@ spider_net_decode_one_descr(struct spide
 	/* ok, we've got a packet in descr */
 	result = spider_net_pass_skb_up(descr, card, napi);
 refill:
-	descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	/* change the descriptor state: */
-	if (!napi)
-		spider_net_refill_rx_chain(card);
+	descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	return result;
 }
 
@@ -1205,8 +1203,11 @@ spider_net_set_mac(struct net_device *ne
 static void
 spider_net_handle_rxram_full(struct spider_net_card *card)
 {
-	while (spider_net_decode_one_descr(card, 0))
-		;
+	int rc = 1;
+	while (rc) {
+		rc = spider_net_decode_one_descr(card, 0);
+		spider_net_refill_rx_chain(card);
+	}
 	spider_net_enable_rxchtails(card);
 	spider_net_enable_rxdmac(card);
 	netif_rx_schedule(card->netdev);
