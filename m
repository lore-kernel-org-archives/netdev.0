From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 6/14] Spidernet another skb mem leak
Date: Wed, 13 Dec 2006 15:16:18 -0600
Message-ID: <20061213211618.GF1915@austin.ibm.com>
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
Received: from e31.co.us.ibm.com ([32.97.110.149]:46359 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbWLMVQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 16:16:21 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDLGLuE021408
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 16:16:21 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDLGKbT501728
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:16:20 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDLGJQF027771
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 14:16:20 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061213210010.GR4329@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Another skb leak in an error branch. Fix this by adding
call to dev_kfree_skb_irq() after moving to a more
appropriate spot.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-13 14:24:16.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-13 14:24:20.000000000 -0600
@@ -926,19 +926,8 @@ spider_net_pass_skb_up(struct spider_net
 
 	data_status = descr->data_status;
 	data_error = descr->data_error;
-
 	netdev = card->netdev;
 
-	/* the cases we'll throw away the packet immediately */
-	if (data_error & SPIDER_NET_DESTROY_RX_FLAGS) {
-		if (netif_msg_rx_err(card))
-			pr_err("error in received descriptor found, "
-			       "data_status=x%08x, data_error=x%08x\n",
-			       data_status, data_error);
-		card->spider_stats.rx_desc_error++;
-		return 0;
-	}
-
 	skb = descr->skb;
 	skb->dev = netdev;
 	skb_put(skb, descr->valid_size);
@@ -1037,6 +1026,18 @@ spider_net_decode_one_descr(struct spide
 		goto refill;
 	}
 
+	/* The cases we'll throw away the packet immediately */
+	if (descr->data_error & SPIDER_NET_DESTROY_RX_FLAGS) {
+		if (netif_msg_rx_err(card))
+			pr_err("%s: error in received descriptor found, "
+			       "data_status=x%08x, data_error=x%08x\n",
+			       card->netdev->name,
+			       descr->data_status, descr->data_error);
+		card->spider_stats.rx_desc_error++;
+		dev_kfree_skb_irq(descr->skb);
+		goto refill;
+	}
+
 	/* ok, we've got a packet in descr */
 	result = spider_net_pass_skb_up(descr, card);
 refill:
