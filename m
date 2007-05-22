From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 7/10] spidernet: enhance the dump routine
Date: Tue, 22 May 2007 18:42:26 -0500
Message-ID: <20070522234226.GF2147@austin.ibm.com>
References: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:47880 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757398AbXEVXm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:42:28 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MNgRiD002209
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:42:28 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MNgRXG211314
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:42:27 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MNgQx4028722
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:42:27 -0600
Content-Disposition: inline
In-Reply-To: <20070522230942.GT5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Crazy device problems are hard to debug, when one does not have
good trace info. This patch makes a major enhancement to the
device dump routine.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   62 ++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 54 insertions(+), 8 deletions(-)

Index: netdev-2.6/drivers/net/spider_net.c
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.c	2007-05-22 18:03:35.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.c	2007-05-22 18:03:37.000000000 -0500
@@ -1024,34 +1024,78 @@ spider_net_pass_skb_up(struct spider_net
 	netif_receive_skb(skb);
 }
 
-#ifdef DEBUG
 static void show_rx_chain(struct spider_net_card *card)
 {
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	struct spider_net_descr *start= chain->tail;
 	struct spider_net_descr *descr= start;
+	struct spider_net_hw_descr *hwd = start->hwdescr;
+	char *iface = card->netdev->name;
+	u32 curr_desc, next_desc;
 	int status;
 
 	int cnt = 0;
-	int cstat = spider_net_get_descr_status(descr);
-	printk(KERN_INFO "RX chain tail at descr=%ld\n",
-	     (start - card->descr) - card->tx_chain.num_desc);
+	int off = 0;
+	int cstat = hwd->dmac_cmd_status;
+
+	printk(KERN_INFO "%s: Total number of descrs=%d\n",
+		iface, chain->num_desc);
+	printk(KERN_INFO "%s: Chain tail located at descr=%d\n",
+		iface, (int) (start - chain->ring));
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
+		if (descr==chain->head)
+			printk(KERN_INFO "%s: chain head is at %d\n", iface, off);
+		if (curr_desc == descr->bus_addr)
+			printk(KERN_INFO "%s: hw curr desc is at %d\n", iface, off);
+		if (next_desc == descr->bus_addr)
+			printk(KERN_INFO "%s: hw next desc is at %d\n", iface, off);
+		if (hwd->next_descr_addr == 0)
+			printk(KERN_INFO "%s: chain is cut at %d\n", iface, off);
+		status = hwd->dmac_cmd_status;
 		if (cstat != status) {
-			printk(KERN_INFO "Have %d descrs with stat=x%08x\n", cnt, cstat);
+			printk(KERN_INFO "%s: Have %d descrs with stat=x%08x\n",
+				iface, cnt, cstat);
 			cstat = status;
 			cnt = 0;
 		}
 		cnt ++;
 		descr = descr->next;
 	} while (descr != start);
-	printk(KERN_INFO "Last %d descrs with stat=x%08x\n", cnt, cstat);
-}
+	printk(KERN_INFO "%s: Last %d descrs with stat=x%08x\n",
+		iface, cnt, cstat);
+
+#ifdef DEBUG
+	/* Now dump the whole ring */
+	descr = start;
+	do
+	{
+		struct spider_net_hw_descr *hwd = descr->hwdescr;
+		status = spider_net_get_descr_status(hwd);
+		cnt = descr - chain->ring;
+		printk(KERN_INFO "Descr %d stat=0x%08x skb=%p\n",
+			cnt, status, descr->skb);
+		printk(KERN_INFO "bus addr=%08x buf addr=%08x sz=%d\n",
+			descr->bus_addr, hwd->buf_addr, hwd->buf_size);
+		printk(KERN_INFO "next=%08x result sz=%d valid sz=%d\n",
+			hwd->next_descr_addr, hwd->result_size, hwd->valid_size);
+		printk(KERN_INFO "dmac=%08x data stat=%08x data err=%08x\n",
+			hwd->dmac_cmd_status, hwd->data_status, hwd->data_error);
+		printk(KERN_INFO "\n");
+
+		descr = descr->next;
+	} while (descr != start);
 #endif
 
+}
+
 /**
  * spider_net_decode_one_descr - processes an RX descriptor
  * @card: card structure
@@ -1141,6 +1185,8 @@ spider_net_decode_one_descr(struct spide
 	return 1;
 
 bad_desc:
+	if (netif_msg_rx_err(card))
+		show_rx_chain(card);
 	dev_kfree_skb_irq(descr->skb);
 	descr->skb = NULL;
 	hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
