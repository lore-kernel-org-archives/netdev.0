From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 12/18] spidernet: don't flag rare packets as bad packets
Date: Thu, 7 Jun 2007 14:45:30 -0500
Message-ID: <20070607194530.GL16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:48888 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936153AbXFGTpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:45:31 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JjVkq015483
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:45:31 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JjUtR270138
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:45:30 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JjU8M004703
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:45:30 -0600
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The current error checking is flagging some perfectly normal, but
usually rare packets as being bad. Do not flag these packets.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:52:20.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:52:24.000000000 -0500
@@ -1174,7 +1174,7 @@ spider_net_decode_one_descr(struct spide
 		goto bad_desc;
 	}
 
-	if (hwdescr->dmac_cmd_status & 0xfefe) {
+	if (hwdescr->dmac_cmd_status & 0xfcf4) {
 		dev_err(&card->netdev->dev, "bad status, cmd_status=x%08x\n",
 			       hwdescr->dmac_cmd_status);
 		pr_err("buf_addr=x%08x\n", hw_buf_addr);
@@ -1543,10 +1543,7 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GDCDCEINT: /* fallthrough */
 	case SPIDER_NET_GDBDCEINT: /* fallthrough */
 	case SPIDER_NET_GDADCEINT:
-		if (netif_msg_intr(card) && net_ratelimit())
-			dev_err(&card->netdev->dev, "got descriptor chain end interrupt, "
-			       "restarting DMAC %c.\n",
-			       'D'-(i-SPIDER_NET_GDDDCEINT)/3);
+		/* Could happen when rx chain is full */
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		show_error = 0;
@@ -1557,7 +1554,7 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GDCINVDINT: /* fallthrough */
 	case SPIDER_NET_GDBINVDINT: /* fallthrough */
 	case SPIDER_NET_GDAINVDINT:
-		/* could happen when rx chain is full */
+		/* Could happen when rx chain is full */
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		show_error = 0;
