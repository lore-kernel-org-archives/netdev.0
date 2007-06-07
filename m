From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 5/18] spidernet: zero out a pointer.
Date: Thu, 7 Jun 2007 14:27:41 -0500
Message-ID: <20070607192741.GE16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:57684 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933932AbXFGT1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:27:43 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JRgpH005898
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:27:42 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JRgKF078062
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:27:42 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JRfJS003619
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:27:42 -0600
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
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
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:51:48.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:51:51.000000000 -0500
@@ -1067,6 +1067,7 @@ spider_net_decode_one_descr(struct spide
 	struct spider_net_descr_chain *chain = &card->rx_chain;
 	struct spider_net_descr *descr = chain->tail;
 	struct spider_net_hw_descr *hwdescr = descr->hwdescr;
+	u32 hw_buf_addr;
 	int status;
 
 	status = spider_net_get_descr_status(hwdescr);
@@ -1080,7 +1081,9 @@ spider_net_decode_one_descr(struct spide
 	chain->tail = descr->next;
 
 	/* unmap descriptor */
-	pci_unmap_single(card->pdev, hwdescr->buf_addr,
+	hw_buf_addr = hwdescr->buf_addr;
+	hwdescr->buf_addr = 0xffffffff;
+	pci_unmap_single(card->pdev, hw_buf_addr,
 			SPIDER_NET_MAX_FRAME, PCI_DMA_FROMDEVICE);
 
 	if ( (status == SPIDER_NET_DESCR_RESPONSE_ERROR) ||
@@ -1114,7 +1117,7 @@ spider_net_decode_one_descr(struct spide
 	if (hwdescr->dmac_cmd_status & 0xfefe) {
 		dev_err(&card->netdev->dev, "bad status, cmd_status=x%08x\n",
 			       hwdescr->dmac_cmd_status);
-		pr_err("buf_addr=x%08x\n", hwdescr->buf_addr);
+		pr_err("buf_addr=x%08x\n", hw_buf_addr);
 		pr_err("buf_size=x%08x\n", hwdescr->buf_size);
 		pr_err("next_descr_addr=x%08x\n", hwdescr->next_descr_addr);
 		pr_err("result_size=x%08x\n", hwdescr->result_size);
