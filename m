From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 4/14] Spidernet cleanup un-needed API
Date: Wed, 13 Dec 2006 15:12:26 -0600
Message-ID: <20061213211226.GD1915@austin.ibm.com>
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
Received: from e31.co.us.ibm.com ([32.97.110.149]:42025 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbWLMVM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 16:12:28 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDLCSGC010245
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:12:28 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDLCSBS447274
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:12:28 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDLCQEh010082
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:12:28 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061213210010.GR4329@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is no need to pass a flag into spider_net_decode_one_descr()
so remove this, and perform some othre minor cleanup.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   35 ++++++++++++-----------------------
 1 file changed, 12 insertions(+), 23 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-13 14:24:07.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-13 14:24:13.000000000 -0600
@@ -910,7 +910,6 @@ spider_net_do_ioctl(struct net_device *n
  * spider_net_pass_skb_up - takes an skb from a descriptor and passes it on
  * @descr: descriptor to process
  * @card: card structure
- * @napi: whether caller is in NAPI context
  *
  * returns 1 on success, 0 if no packet was passed to the stack
  *
@@ -919,7 +918,7 @@ spider_net_do_ioctl(struct net_device *n
  */
 static int
 spider_net_pass_skb_up(struct spider_net_descr *descr,
-		       struct spider_net_card *card, int napi)
+		       struct spider_net_card *card)
 {
 	struct sk_buff *skb;
 	struct net_device *netdev;
@@ -972,10 +971,7 @@ spider_net_pass_skb_up(struct spider_net
 	}
 
 	/* pass skb up to stack */
-	if (napi)
-		netif_receive_skb(skb);
-	else
-		netif_rx_ni(skb);
+	netif_receive_skb(skb);
 
 	/* update netdevice statistics */
 	card->netdev_stats.rx_packets++;
@@ -987,16 +983,15 @@ spider_net_pass_skb_up(struct spider_net
 /**
  * spider_net_decode_one_descr - processes an rx descriptor
  * @card: card structure
- * @napi: whether caller is in NAPI context
  *
- * returns 1 if a packet has been sent to the stack, otherwise 0
+ * Returns 1 if a packet has been sent to the stack, otherwise 0
  *
- * processes an rx descriptor by iommu-unmapping the data buffer and passing
+ * Processes an rx descriptor by iommu-unmapping the data buffer and passing
  * the packet up to the stack. This function is called in softirq
  * context, e.g. either bottom half from interrupt or NAPI polling context
  */
 static int
-spider_net_decode_one_descr(struct spider_net_card *card, int napi)
+spider_net_decode_one_descr(struct spider_net_card *card)
 {
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	struct spider_net_descr *descr = chain->tail;
@@ -1005,18 +1000,15 @@ spider_net_decode_one_descr(struct spide
 
 	status = spider_net_get_descr_status(descr);
 
-	if (status == SPIDER_NET_DESCR_CARDOWNED) {
-		/* nothing in the descriptor yet */
-		result=0;
-		goto out;
-	}
+	/* nothing in the descriptor yet */
+	if (status == SPIDER_NET_DESCR_CARDOWNED)
+		return 0;
 
 	if (status == SPIDER_NET_DESCR_NOT_IN_USE) {
 		/* not initialized yet, the ring must be empty */
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
-		result=0;
-		goto out;
+		return 0;
 	}
 
 	/* descriptor definitively used -- move on tail */
@@ -1046,13 +1038,10 @@ spider_net_decode_one_descr(struct spide
 	}
 
 	/* ok, we've got a packet in descr */
-	result = spider_net_pass_skb_up(descr, card, napi);
+	result = spider_net_pass_skb_up(descr, card);
 refill:
-	descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	/* change the descriptor state: */
-	if (!napi)
-		spider_net_refill_rx_chain(card);
-out:
+	descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	return result;
 }
 
@@ -1079,7 +1068,7 @@ spider_net_poll(struct net_device *netde
 	packets_to_do = min(*budget, netdev->quota);
 
 	while (packets_to_do) {
-		if (spider_net_decode_one_descr(card, 1)) {
+		if (spider_net_decode_one_descr(card)) {
 			packets_done++;
 			packets_to_do--;
 		} else {
