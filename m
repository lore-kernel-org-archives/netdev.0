From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 14/14] Spidernet Rework RX linked list
Date: Wed, 13 Dec 2006 15:25:05 -0600
Message-ID: <20061213212505.GN1915@austin.ibm.com>
References: <20061213210010.GR4329@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	Christoph Hellwig <hch@infradead.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	James K Lewis <jim@jklewis.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:46913 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751080AbWLMVZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 16:25:08 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDLPYUj005473
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:25:34 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDLP7UF270250
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:25:07 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDLP5UY032148
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:25:07 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061213210010.GR4329@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Make the hardware perceive the RX descriptor ring as a 
null-terminated linked list, instead of a circular ring.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-13 14:32:13.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-13 14:33:21.000000000 -0600
@@ -419,9 +419,13 @@ spider_net_prepare_rx_descr(struct spide
 		card->spider_stats.rx_iommu_map_error++;
 		descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	} else {
+		descr->next_descr_addr = 0;
 		wmb();
 		descr->dmac_cmd_status = SPIDER_NET_DESCR_CARDOWNED |
 					 SPIDER_NET_DMAC_NOINTR_COMPLETE;
+
+		wmb();
+		descr->prev->next_descr_addr = descr->bus_addr;
 	}
 
 	return 0;
@@ -1650,7 +1654,6 @@ int
 spider_net_open(struct net_device *netdev)
 {
 	struct spider_net_card *card = netdev_priv(netdev);
-	struct spider_net_descr *descr;
 	int result;
 
 	result = spider_net_init_chain(card, &card->tx_chain);
@@ -1662,13 +1665,6 @@ spider_net_open(struct net_device *netde
 	if (result)
 		goto alloc_rx_failed;
 
-	/* Make a ring of of bus addresses */
-	descr = card->rx_chain.ring;
-	do {
-		descr->next_descr_addr = descr->next->bus_addr;
-		descr = descr->next;
-	} while (descr != card->rx_chain.ring);
-
 	/* Allocate rx skbs */
 	if (spider_net_alloc_rx_skbs(card))
 		goto alloc_skbs_failed;
