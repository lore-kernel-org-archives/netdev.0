From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 7/14] Spidernet Cleanup return codes
Date: Wed, 13 Dec 2006 15:17:39 -0600
Message-ID: <20061213211739.GG1915@austin.ibm.com>
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
Received: from e35.co.us.ibm.com ([32.97.110.153]:56894 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbWLMVS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 16:18:58 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDLIw0e012423
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:18:58 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDLHfaI166532
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:17:41 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDLHeDS010804
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:17:41 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061213210010.GR4329@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Simplify the somewhat convoluted use of return codes
in the rx buffer handling.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   32 ++++++++++++--------------------
 1 file changed, 12 insertions(+), 20 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-13 14:24:20.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-13 14:27:35.000000000 -0600
@@ -911,12 +911,10 @@ spider_net_do_ioctl(struct net_device *n
  * @descr: descriptor to process
  * @card: card structure
  *
- * returns 1 on success, 0 if no packet was passed to the stack
- *
  * Fills out skb structure and passes the data to the stack.
  * The descriptor state is not changed.
  */
-static int
+static void
 spider_net_pass_skb_up(struct spider_net_descr *descr,
 		       struct spider_net_card *card)
 {
@@ -961,8 +959,6 @@ spider_net_pass_skb_up(struct spider_net
 	/* update netdevice statistics */
 	card->netdev_stats.rx_packets++;
 	card->netdev_stats.rx_bytes += skb->len;
-
-	return 1;
 }
 
 /**
@@ -981,7 +977,6 @@ spider_net_decode_one_descr(struct spide
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	struct spider_net_descr *descr = chain->tail;
 	int status;
-	int result;
 
 	status = spider_net_get_descr_status(descr);
 
@@ -999,8 +994,6 @@ spider_net_decode_one_descr(struct spide
 	/* descriptor definitively used -- move on tail */
 	chain->tail = descr->next;
 
-	result = 0;
-
 	/* unmap descriptor */
 	pci_unmap_single(card->pdev, descr->buf_addr,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
@@ -1012,8 +1005,7 @@ spider_net_decode_one_descr(struct spide
 			pr_err("%s: dropping RX descriptor with state %d\n",
 			       card->netdev->name, status);
 		card->netdev_stats.rx_dropped++;
-		dev_kfree_skb_irq(descr->skb);
-		goto refill;
+		goto bad_desc;
 	}
 
 	if ( (status != SPIDER_NET_DESCR_COMPLETE) &&
@@ -1022,8 +1014,7 @@ spider_net_decode_one_descr(struct spide
 			pr_err("%s: RX descriptor with unkown state %d\n",
 			       card->netdev->name, status);
 		card->spider_stats.rx_desc_unk_state++;
-		dev_kfree_skb_irq(descr->skb);
-		goto refill;
+		goto bad_desc;
 	}
 
 	/* The cases we'll throw away the packet immediately */
@@ -1033,17 +1024,18 @@ spider_net_decode_one_descr(struct spide
 			       "data_status=x%08x, data_error=x%08x\n",
 			       card->netdev->name,
 			       descr->data_status, descr->data_error);
-		card->spider_stats.rx_desc_error++;
-		dev_kfree_skb_irq(descr->skb);
-		goto refill;
+		goto bad_desc;
 	}
 
-	/* ok, we've got a packet in descr */
-	result = spider_net_pass_skb_up(descr, card);
-refill:
-	/* change the descriptor state: */
+	/* Ok, we've got a packet in descr */
+	spider_net_pass_skb_up(descr, card);
 	descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
-	return result;
+	return 1;
+
+bad_desc:
+	dev_kfree_skb_irq(descr->skb);
+	descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
+	return 0;
 }
 
 /**
