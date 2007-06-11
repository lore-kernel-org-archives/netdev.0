From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 9/15] spidernet: enhance the dump routine
Date: Mon, 11 Jun 2007 13:48:55 -0500
Message-ID: <20070611184855.GI13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:56280 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbXFKSs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:48:58 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BImwUd023466
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:48:58 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BImuHt041300
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:48:57 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BImuK3005674
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:48:56 -0600
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
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
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-11 11:50:03.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-11 11:51:19.000000000 -0500
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
  * spider_net_resync_head_ptr - Advance head ptr past empty descrs
  *
@@ -1197,6 +1257,8 @@ spider_net_decode_one_descr(struct spide
 	return 1;
 
 bad_desc:
+	if (netif_msg_rx_err(card))
+		show_rx_chain(card);
 	dev_kfree_skb_irq(descr->skb);
 	descr->skb = NULL;
 	hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
