From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 14/18] spidernet: silence the ramfull messages
Date: Thu, 7 Jun 2007 14:53:47 -0500
Message-ID: <20070607195347.GN16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:34536 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965322AbXFGTx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:53:58 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57Jrt36011566
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:53:55 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JrtJP208024
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:53:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JrsSL002835
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:53:55 -0600
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Altough the previous patch resolved issues with hangs when the
RX ram full interrupt is encountered, there are still situations
where lots of RX ramfull interrupts arrive, rsulting in a noisy
log in syslog. There is no need for this.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   20 ++++++++++----------
 drivers/net/spider_net.h |    3 ++-
 2 files changed, 12 insertions(+), 11 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:53:55.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:56:10.000000000 -0500
@@ -1314,6 +1314,7 @@ spider_net_poll(struct net_device *netde
 	if (no_more_packets) {
 		netif_rx_complete(netdev);
 		spider_net_rx_irq_on(card);
+		card->ignore_rx_ramfull = 0;
 		return 0;
 	}
 
@@ -1584,17 +1585,15 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GRFBFLLINT: /* fallthrough */
 	case SPIDER_NET_GRFAFLLINT: /* fallthrough */
 	case SPIDER_NET_GRMFLLINT:
-		if (netif_msg_intr(card) && net_ratelimit()) {
-			dev_info(&card->netdev->dev, "Spider RX RAM full, "
-			        "incoming packets might be discarded!\n");
-			show_rx_chain(card);
-		}
 		/* Could happen when rx chain is full */
-		spider_net_resync_head_ptr(card);
-		spider_net_refill_rx_chain(card);
-		spider_net_enable_rxdmac(card);
-		card->num_rx_ints ++;
-		netif_rx_schedule(card->netdev);
+		if (card->ignore_rx_ramfull == 0) {
+			card->ignore_rx_ramfull = 1;
+			spider_net_resync_head_ptr(card);
+			spider_net_refill_rx_chain(card);
+			spider_net_enable_rxdmac(card);
+			card->num_rx_ints ++;
+			netif_rx_schedule(card->netdev);
+		}
 		show_error = 0;
 		break;
 
@@ -2374,6 +2373,7 @@ spider_net_setup_netdev(struct spider_ne
 
 	netdev->irq = card->pdev->irq;
 	card->num_rx_ints = 0;
+	card->ignore_rx_ramfull = 0;
 
 	dn = pci_device_to_OF_node(card->pdev);
 	if (!dn)
Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-07 11:52:35.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-07 11:55:06.000000000 -0500
@@ -164,7 +164,7 @@ extern char spider_net_driver_name[];
 
 /** interrupt mask registers */
 #define SPIDER_NET_INT0_MASK_VALUE	0x3f7fe2c7
-#define SPIDER_NET_INT1_MASK_VALUE	0xffff7ff7
+#define SPIDER_NET_INT1_MASK_VALUE	0xffff5ff5
 /* no MAC aborts -> auto retransmission */
 #define SPIDER_NET_INT2_MASK_VALUE	0xffef7ff1
 
@@ -467,6 +467,7 @@ struct spider_net_card {
 	atomic_t tx_timeout_task_counter;
 	wait_queue_head_t waitq;
 	int num_rx_ints;
+	int ignore_rx_ramfull;
 
 	/* for ethtool */
 	int msg_enable;
