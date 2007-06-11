From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 10/15] spidernet: invalidate unused pointer.
Date: Mon, 11 Jun 2007 13:52:03 -0500
Message-ID: <20070611185203.GJ13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:34769 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756948AbXFKSwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:52:13 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIqBhP032526
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:52:11 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIq9fQ225352
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:52:10 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BIq9Ux018192
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:52:09 -0600
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Invalidate a pointer as its pci_unmap'ed; this is a bit of 
paranoia to make sure hardware doesn't continue trying to 
DMA to it. 

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-11 11:51:19.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-11 11:53:21.000000000 -0500
@@ -1187,6 +1187,7 @@ spider_net_decode_one_descr(struct spide
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	struct spider_net_descr *descr = chain->tail;
 	struct spider_net_hw_descr *hwdescr = descr->hwdescr;
+	u32 hw_buf_addr;
 	int status;
 
 	status = spider_net_get_descr_status(hwdescr);
@@ -1200,7 +1201,9 @@ spider_net_decode_one_descr(struct spide
 	chain->tail = descr->next;
 
 	/* unmap descriptor */
-	pci_unmap_single(card->pdev, hwdescr->buf_addr,
+	hw_buf_addr = hwdescr->buf_addr;
+	hwdescr->buf_addr = 0xffffffff;
+	pci_unmap_single(card->pdev, hw_buf_addr,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
 
 	if ( (status == SPIDER_NET_DESCR_RESPONSE_ERROR) ||
@@ -1237,7 +1240,7 @@ spider_net_decode_one_descr(struct spide
 		dev_err(&card->netdev->dev, "bad status, cmd_status=x%08x\n",
 			       card->netdev->name,
 			       hwdescr->dmac_cmd_status);
-		pr_err("buf_addr=x%08x\n", hwdescr->buf_addr);
+		pr_err("buf_addr=x%08x\n", hw_buf_addr);
 		pr_err("buf_size=x%08x\n", hwdescr->buf_size);
 		pr_err("next_descr_addr=x%08x\n", hwdescr->next_descr_addr);
 		pr_err("result_size=x%08x\n", hwdescr->result_size);
