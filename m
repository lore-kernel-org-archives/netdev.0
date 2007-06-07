From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 9/18] spidernet: reset the card when an rxramfull is seen
Date: Thu, 7 Jun 2007 14:39:46 -0500
Message-ID: <20070607193946.GI16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:40721 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760927AbXFGTjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:39:49 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57Jdn9O009178
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:39:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JdlwP251874
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:39:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57Jdk1h028089
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:39:46 -0600
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some versions of the spider have a firmware bug, where the
RX ring sequencer goes crazy when the RX RAM on the device
fills up. Appearently the only viable wrkaround is a soft
reset of the card.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:52:12.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:52:17.000000000 -0500
@@ -1518,11 +1518,16 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GRFBFLLINT: /* fallthrough */
 	case SPIDER_NET_GRFAFLLINT: /* fallthrough */
 	case SPIDER_NET_GRMFLLINT:
-		if (netif_msg_intr(card) && net_ratelimit())
-			dev_err(&card->netdev->dev, "Spider RX RAM full, incoming packets "
-			       "might be discarded!\n");
+		if (netif_msg_intr(card) && net_ratelimit()) {
+			dev_err(&card->netdev->dev, "Spider RX RAM full, "
+			        "incoming packets might be discarded!\n");
+			show_rx_chain(card);
+		}
 		spider_net_rx_irq_off(card);
-		netif_rx_schedule(card->netdev);
+
+		/* If the card is spewing rxramfulls, then reset */
+		atomic_inc(&card->tx_timeout_task_counter);
+		schedule_work(&card->tx_timeout_task);
 		show_error = 0;
 		break;
 
@@ -2100,6 +2105,8 @@ spider_net_workaround_rxramfull(struct s
 {
 	int i, sequencer = 0;
 
+	dev_info(&card->pdev->dev, "calling rxramfull workaround\n");
+
 	/* cancel reset */
 	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
 			     SPIDER_NET_CKRCTRL_RUN_VALUE);
