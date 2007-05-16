From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 4/10] spidernet: zero out a pointer.
Date: Wed, 16 May 2007 17:09:28 -0500
Message-ID: <20070516220928.GD4997@austin.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:36474 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755039AbXEPWJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 18:09:30 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GM9TGG003797
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:09:29 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GM9Twk501332
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:09:29 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GM9TrA013429
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:09:29 -0400
Content-Disposition: inline
In-Reply-To: <20070516215605.GA4325@austin.ibm.com>
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
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-05-15 13:31:11.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-05-15 13:31:16.000000000 -0500
@@ -1068,6 +1068,7 @@ spider_net_decode_one_descr(struct spide
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	struct spider_net_descr *descr = chain->tail;
 	struct spider_net_hw_descr *hwdescr = descr->hwdescr;
+	u32 hw_buf_addr;
 	int status;
 
 	status = spider_net_get_descr_status(hwdescr);
@@ -1081,7 +1082,9 @@ spider_net_decode_one_descr(struct spide
 	chain->tail = descr->next;
 
 	/* unmap descriptor */
-	pci_unmap_single(card->pdev, hwdescr->buf_addr,
+	hw_buf_addr = hwdescr->buf_addr;
+	hwdescr->buf_addr = 0x0;
+	pci_unmap_single(card->pdev, hw_buf_addr,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
 
 	if ( (status == SPIDER_NET_DESCR_RESPONSE_ERROR) ||
@@ -1117,7 +1120,7 @@ spider_net_decode_one_descr(struct spide
 		pr_err("%s: bad status, cmd_status=x%08x\n",
 			       card->netdev->name,
 			       hwdescr->dmac_cmd_status);
-		pr_err("buf_addr=x%08x\n", hwdescr->buf_addr);
+		pr_err("buf_addr=x%08x\n", hw_buf_addr);
 		pr_err("buf_size=x%08x\n", hwdescr->buf_size);
 		pr_err("next_descr_addr=x%08x\n", hwdescr->next_descr_addr);
 		pr_err("result_size=x%08x\n", hwdescr->result_size);
