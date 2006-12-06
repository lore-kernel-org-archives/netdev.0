From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 7/16] Spidernet Cleanup return codes
Date: Wed, 6 Dec 2006 17:37:33 -0600
Message-ID: <20061206233733.GG4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:45490 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937802AbWLFXhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 18:37:38 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6NbZwu026516
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:37:35 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6NbZcv543720
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 16:37:35 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6NbYG1031090
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 16:37:35 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Simplify the somewhat convoluted use of return codes
in the rx buffre handling.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 16:03:04.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 16:03:06.000000000 -0600
@@ -882,12 +882,10 @@ spider_net_do_ioctl(struct net_device *n
  * @card: card structure
  * @napi: whether caller is in NAPI context
  *
- * returns 1 on success, 0 if no packet was passed to the stack
- *
  * Fills out skb structure and passes the data to the stack.
  * The descriptor state is not changed.
  */
-static int
+static void
 spider_net_pass_skb_up(struct spider_net_descr *descr,
 		       struct spider_net_card *card, int napi)
 {
@@ -935,8 +933,6 @@ spider_net_pass_skb_up(struct spider_net
 	/* update netdevice statistics */
 	card->netdev_stats.rx_packets++;
 	card->netdev_stats.rx_bytes += skb->len;
-
-	return 1;
 }
 
 /**
@@ -956,7 +952,6 @@ spider_net_decode_one_descr(struct spide
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	struct spider_net_descr *descr;
 	int status;
-	int result;
 	unsigned long flags;
 
 	spin_lock_irqsave(&chain->lock, flags);
@@ -982,8 +977,6 @@ spider_net_decode_one_descr(struct spide
 	chain->tail = descr->next;
 	spin_unlock_irqrestore(&chain->lock, flags);
 
-	result = 0;
-
 	/* unmap descriptor */
 	pci_unmap_single(card->pdev, descr->buf_addr,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
@@ -995,8 +988,7 @@ spider_net_decode_one_descr(struct spide
 			pr_err("%s: dropping RX descriptor with state %d\n",
 			       card->netdev->name, status);
 		card->netdev_stats.rx_dropped++;
-		dev_kfree_skb_irq(descr->skb);
-		goto refill;
+		goto bad_desc;
 	}
 
 	if ( (status != SPIDER_NET_DESCR_COMPLETE) &&
@@ -1005,8 +997,7 @@ spider_net_decode_one_descr(struct spide
 			pr_err("%s: RX descriptor with unkown state %d\n",
 			       card->netdev->name, status);
 		card->spider_stats.rx_desc_unk_state++;
-		dev_kfree_skb_irq(descr->skb);
-		goto refill;
+		goto bad_desc;
 	}
 
 	/* The cases we'll throw away the packet immediately */
@@ -1017,16 +1008,18 @@ spider_net_decode_one_descr(struct spide
 			       card->netdev->name,
 			       descr->data_status, descr->data_error);
 		card->spider_stats.rx_desc_error++;
-		dev_kfree_skb_irq(descr->skb);
-		goto refill;
+		goto bad_desc;
 	}
 
-	/* ok, we've got a packet in descr */
-	result = spider_net_pass_skb_up(descr, card, napi);
-refill:
-	/* change the descriptor state: */
+	/* Ok, we've got a packet in descr */
+	spider_net_pass_skb_up(descr, card, napi);
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
