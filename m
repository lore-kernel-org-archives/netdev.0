From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 8/18] spidernet: enhance the dump routine
Date: Thu, 7 Jun 2007 14:35:05 -0500
Message-ID: <20070607193505.GH16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:46332 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935046AbXFGTfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 15:35:13 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JZBhd002271
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:35:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JZBXn500282
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:35:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JZA7o011109
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:35:11 -0400
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Crazy device problems are hard to debug, when one does not have
good trace info. This patch makes a major enhancement to the
device dump routine.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   78 ++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 70 insertions(+), 8 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 14:07:26.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 14:07:55.000000000 -0500
@@ -1022,34 +1022,94 @@ spider_net_pass_skb_up(struct spider_net
 	netif_receive_skb(skb);
 }
 
-#ifdef DEBUG
 static void show_rx_chain(struct spider_net_card *card)
 {
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	struct spider_net_descr *start= chain->tail;
 	struct spider_net_descr *descr= start;
+	struct spider_net_hw_descr *hwd = start->hwdescr;
+	struct device *dev = &card->netdev->dev;
+	u32 curr_desc, next_desc;
 	int status;
 
+	int tot = 0;
 	int cnt = 0;
-	int cstat = spider_net_get_descr_status(descr);
-	printk(KERN_INFO "RX chain tail at descr=%ld\n",
-	     (start - card->descr) - card->tx_chain.num_desc);
+	int off = start - chain->ring;
+	int cstat = hwd->dmac_cmd_status;
+
+	dev_info(dev, "Total number of descrs=%d\n",
+		chain->num_desc);
+	dev_info(dev, "Chain tail located at descr=%d, status=0x%x\n",
+		off, cstat);
+
+	curr_desc = spider_net_read_reg(card, SPIDER_NET_GDACTDPA);
+	next_desc = spider_net_read_reg(card, SPIDER_NET_GDACNEXTDA);
+
 	status = cstat;
 	do
 	{
-		status = spider_net_get_descr_status(descr);
+		hwd = descr->hwdescr;
+		off = descr - chain->ring;
+		status = hwd->dmac_cmd_status;
+
+		if (descr == chain->head)
+			dev_info(dev, "Chain head is at %d, head status=0x%x\n",
+			         off, status);
+
+		if (curr_desc == descr->bus_addr)
+			dev_info(dev, "HW curr desc (GDACTDPA) is at %d, status=0x%x\n",
+			         off, status);
+
+		if (next_desc == descr->bus_addr)
+			dev_info(dev, "HW next desc (GDACNEXTDA) is at %d, status=0x%x\n",
+			         off, status);
+
+		if (hwd->next_descr_addr == 0)
+			dev_info(dev, "chain is cut at %d\n", off);
+
 		if (cstat != status) {
-			printk(KERN_INFO "Have %d descrs with stat=x%08x\n", cnt, cstat);
+			int from = (chain->num_desc + off - cnt) % chain->num_desc;
+			int to = (chain->num_desc + off - 1) % chain->num_desc;
+			dev_info(dev, "Have %d (from %d to %d) descrs "
+			         "with stat=0x%08x\n", cnt, from, to, cstat);
 			cstat = status;
 			cnt = 0;
 		}
+
 		cnt ++;
+		tot ++;
+		descr = descr->next;
+	} while (descr != start);
+
+	dev_info(dev, "Last %d descrs with stat=0x%08x "
+	         "for a total of %d descrs\n", cnt, cstat, tot);
+
+#ifdef DEBUG
+	/* Now dump the whole ring */
+	descr = start;
+	do
+	{
+		struct spider_net_hw_descr *hwd = descr->hwdescr;
+		status = spider_net_get_descr_status(hwd);
+		cnt = descr - chain->ring;
+		dev_info(dev, "Descr %d stat=0x%08x skb=%p\n",
+		         cnt, status, descr->skb);
+		dev_info(dev, "bus addr=%08x buf addr=%08x sz=%d\n",
+		         descr->bus_addr, hwd->buf_addr, hwd->buf_size);
+		dev_info(dev, "next=%08x result sz=%d valid sz=%d\n",
+		         hwd->next_descr_addr, hwd->result_size,
+		         hwd->valid_size);
+		dev_info(dev, "dmac=%08x data stat=%08x data err=%08x\n",
+		         hwd->dmac_cmd_status, hwd->data_status,
+		         hwd->data_error);
+		dev_info(dev, "\n");
+
 		descr = descr->next;
 	} while (descr != start);
-	printk(KERN_INFO "Last %d descrs with stat=x%08x\n", cnt, cstat);
-}
 #endif
 
+}
+
 /**
  * spider_net_decode_one_descr - processes an RX descriptor
  * @card: card structure
@@ -1137,6 +1197,8 @@ spider_net_decode_one_descr(struct spide
 	return 1;
 
 bad_desc:
+	if (netif_msg_rx_err(card))
+		show_rx_chain(card);
 	dev_kfree_skb_irq(descr->skb);
 	descr->skb = NULL;
 	hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
