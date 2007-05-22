From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 8/10] spidernet: reset the card when an rxramfull is seen
Date: Tue, 22 May 2007 18:45:32 -0500
Message-ID: <20070522234532.GG2147@austin.ibm.com>
References: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:40330 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758361AbXEVXph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:45:37 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MNjXHS009531
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:45:33 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MNjXPE216546
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:45:33 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MNjW6j025364
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:45:33 -0600
Content-Disposition: inline
In-Reply-To: <20070522230942.GT5921@austin.ibm.com>
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

Index: netdev-2.6/drivers/net/spider_net.c
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.c	2007-05-22 18:03:37.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.c	2007-05-22 18:03:39.000000000 -0500
@@ -1506,11 +1506,17 @@ spider_net_handle_error_irq(struct spide
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
 
@@ -2087,6 +2093,8 @@ spider_net_workaround_rxramfull(struct s
 {
 	int i, sequencer = 0;
 
+	printk(KERN_INFO "%s: calling rxramfull workaround\n", card->netdev->name);
+
 	/* cancel reset */
 	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
 			     SPIDER_NET_CKRCTRL_RUN_VALUE);
