From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 4/15] spidernet: silence the ramfull messages
Date: Mon, 11 Jun 2007 13:26:50 -0500
Message-ID: <20070611182650.GD13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:38071 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839AbXFKS1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:27:04 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l5BIMWQE020390
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:22:32 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIQpF0081756
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:26:52 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BIQo0r011384
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:26:51 -0600
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Although the previous patch resolved issues with hangs when the
RX ram full interrupt is encountered, there are still situations
where lots of RX ramfull interrupts arrive, resulting in a noisy
log in syslog. There is no need for this.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   20 +++++++++++---------
 drivers/net/spider_net.h |    1 +
 2 files changed, 12 insertions(+), 9 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-11 10:02:34.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-11 11:45:25.000000000 -0500
@@ -1172,7 +1172,7 @@ spider_net_decode_one_descr(struct spide
 		goto bad_desc;
 	}
 
-	if (hwdescr->dmac_cmd_status & 0xfefe) {
+	if (hwdescr->dmac_cmd_status & 0xfcf4) {
 		pr_err("%s: bad status, cmd_status=x%08x\n",
 			       card->netdev->name,
 			       hwdescr->dmac_cmd_status);
@@ -1251,6 +1251,7 @@ spider_net_poll(struct net_device *netde
 	if (no_more_packets) {
 		netif_rx_complete(netdev);
 		spider_net_rx_irq_on(card);
+		card->ignore_rx_ramfull = 0;
 		return 0;
 	}
 
@@ -1521,15 +1522,15 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GRFBFLLINT: /* fallthrough */
 	case SPIDER_NET_GRFAFLLINT: /* fallthrough */
 	case SPIDER_NET_GRMFLLINT:
-		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("Spider RX RAM full, incoming packets "
-			       "might be discarded!\n");
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
 
@@ -2305,6 +2306,7 @@ spider_net_setup_netdev(struct spider_ne
 
 	netdev->irq = card->pdev->irq;
 	card->num_rx_ints = 0;
+	card->ignore_rx_ramfull = 0;
 
 	dn = pci_device_to_OF_node(card->pdev);
 	if (!dn)
Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-11 10:02:25.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-11 11:45:50.000000000 -0500
@@ -462,6 +462,7 @@ struct spider_net_card {
 	atomic_t tx_timeout_task_counter;
 	wait_queue_head_t waitq;
 	int num_rx_ints;
+	int ignore_rx_ramfull;
 
 	/* for ethtool */
 	int msg_enable;
