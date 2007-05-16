From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 8/10] spidernet: reset the card when an rxramfull is seen
Date: Wed, 16 May 2007 17:19:46 -0500
Message-ID: <20070516221946.GH4997@austin.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:56300 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755456AbXEPWTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 18:19:52 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GMJl1A024114
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:19:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GMJlnB269930
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 16:19:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GMJkXm018741
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 16:19:46 -0600
Content-Disposition: inline
In-Reply-To: <20070516215605.GA4325@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some versions of the spider have a firmware bug, where the
RX ring sequencer goes crazy when the RX RAM on the device
fills up. Appearently the only viable wrkaround is a soft
reset of the card.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-05-15 14:48:06.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-05-15 16:34:46.000000000 -0500
@@ -1505,11 +1505,17 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GRFBFLLINT: /* fallthrough */
 	case SPIDER_NET_GRFAFLLINT: /* fallthrough */
 	case SPIDER_NET_GRMFLLINT:
-		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("%s: Spider RX RAM full, incoming packets "
-			       "might be discarded!\n", card->netdev->name);
+		if (netif_msg_intr(card) && net_ratelimit()) {
+			pr_err("%s: Spider RX RAM full, reseting device.\n",
+			       card->netdev->name);
+			show_rx_chain(card);
+		}
 		spider_net_rx_irq_off(card);
 		netif_rx_schedule(card->netdev);
+
+		/* If the card is spewing rxramfulls, then reset */
+		atomic_inc(&card->tx_timeout_task_counter);
+		schedule_work(&card->tx_timeout_task);
 		show_error = 0;
 		break;
 
@@ -2086,6 +2092,8 @@ spider_net_workaround_rxramfull(struct s
 {
 	int i, sequencer = 0;
 
+	printk(KERN_INFO "%s: calling rxramfull workaround\n", card->netdev->name);
+
 	/* cancel reset */
 	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
 			     SPIDER_NET_CKRCTRL_RUN_VALUE);
