From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 2/15] spidernet: Cure RX ram full bug
Date: Mon, 11 Jun 2007 13:21:13 -0500
Message-ID: <20070611182113.GB13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:50910 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473AbXFKScL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:32:11 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIWB0x012254
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:32:11 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIQDsV220998
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:32:10 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BILDZX020306
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:21:14 -0600
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch fixes a rare deadlock that can occur when the kernel
is not able to empty out the RX ring quickly enough. Below follows
a detailed description of the bug and the fix.

As long as the OS can empty out the RX buffers at a rate faster than
the hardware can fill them, there is no problem. If, for some reason,
the OS fails to empty the RX ring fast enough, the hardware GDACTDPA
pointer will catch up to the head, notice the not-empty condition,
ad stop. However, RX packets may still continue arriving on the wire.
The spidernet chip can save some limited number of these in local RAM.
When this local ram fills up, the spider chip will issue an interrupt
indicating this (GHIINT0STS will show ERRINT, and the GRMFLLINT bit
will be set in GHIINT1STS).  When te RX ram full condition occurs, 
a certain bug/feature is triggered that has to be specially handled. 
This section describes the special handling for this condition.

When the OS finally has a chance to run, it will empty out the RX ring.
In particular, it will clear the descriptor on which the hardware had
stopped. However, once the hardware has decided that a certain
descriptor is invalid, it will not restart at that descriptor; instead
it will restart at the next descr. This potentially will lead to a 
deadlock condition, as the tail pointer will be pointing at this descr, 
which, from the OS point of view, is empty; the OS will be waiting for 
this descr to be filled. However, the hardware has skipped this descr, 
and is filling the next descrs. Since the OS doesn't see this, there
is a potential deadlock, with the OS waiting for one descr to fill, 
while the hardware is waiting for a differen set of descrs to become
empty.

A call to show_rx_chain() at this point indicates the nature of the
problem. A typical print when the network is hung shows the following:

net eth1: Spider RX RAM full, incoming packets might be discarded!
net eth1: Total number of descrs=256
net eth1: Chain tail located at descr=255
net eth1: Chain head is at 255
net eth1: HW curr desc (GDACTDPA) is at 0
net eth1: Have 1 descrs with stat=xa0800000
net eth1: HW next desc (GDACNEXTDA) is at 1
net eth1: Have 127 descrs with stat=x40800101
net eth1: Have 1 descrs with stat=x40800001
net eth1: Have 126 descrs with stat=x40800101
net eth1: Last 1 descrs with stat=xa0800000

Both the tail and head pointers are pointing at descr 255, which is
marked xa... which is "empty". Thus, from the OS point of view, there
is nothing to be done. In particular, there is the implicit assumption
that everything in front of the "empty" descr must surely also be empty,
as explained in the last section. The OS is waiting for descr 255 to
become non-empty, which, in this case, will never happen.

The HW pointer is at descr 0. This descr is marked 0x4.. or "full". 
Since its already full, the hardware can do nothing more, and thus has
halted processing. Notice that descrs 0 through 254 are all marked
"full", while descr 254 and 255 are empty. (The "Last 1 descrs" is 
descr 254, since tail was at 255.) Thus, the system is deadlocked, 
and there can be no forward progress; the OS thinks there's nothing 
to do, and the hardware has nowhere to put incoming data.

This bug/feature is worked around with the spider_net_resync_head_ptr()
routine. When the driver receives RX interrupts, but an examination
of the RX chain seems to show it is empty, then it is probable that
the hardware has skipped a descr or two (sometimes dozens under heavy
network conditions). The spider_net_resync_head_ptr() subroutine will
search the ring for the next full descr, and the driver will resume
operations there.  Since this will leave "holes" in the ring, there
is also a spider_net_resync_tail_ptr() that will skip over such holes. 


Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   86 +++++++++++++++++++++++++++++++++++++++++++----
 drivers/net/spider_net.h |    3 +
 2 files changed, 82 insertions(+), 7 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-08 15:48:10.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-11 10:02:12.000000000 -0500
@@ -1051,6 +1051,66 @@ static void show_rx_chain(struct spider_
 #endif
 
 /**
+ * spider_net_resync_head_ptr - Advance head ptr past empty descrs
+ *
+ * If the driver fails to keep up and empty the queue, then the
+ * hardware wil run out of room to put incoming packets. This
+ * will cause the hardware to skip descrs that are full (instead
+ * of halting/retrying). Thus, once the driver runs, it wil need
+ * to "catch up" to where the hardware chain pointer is at.
+ */
+static void spider_net_resync_head_ptr(struct spider_net_card *card)
+{
+	unsigned long flags;
+	struct spider_net_descr_chain *chain = &card->rx_chain;
+	struct spider_net_descr *descr;
+	int i, status;
+
+	/* Advance head pointer past any empty descrs */
+	descr = chain->head;
+	status = spider_net_get_descr_status(descr->hwdescr);
+
+	if (status == SPIDER_NET_DESCR_NOT_IN_USE)
+		return;
+
+	spin_lock_irqsave(&chain->lock, flags);
+
+	descr = chain->head;
+	status = spider_net_get_descr_status(descr->hwdescr);
+	for (i=0; i<chain->num_desc; i++) {
+		if (status != SPIDER_NET_DESCR_CARDOWNED) break;
+		descr = descr->next;
+		status = spider_net_get_descr_status(descr->hwdescr);
+	}
+	chain->head = descr;
+
+	spin_unlock_irqrestore(&chain->lock, flags);
+}
+
+static int spider_net_resync_tail_ptr(struct spider_net_card *card)
+{
+	struct spider_net_descr_chain *chain = &card->rx_chain;
+	struct spider_net_descr *descr;
+	int i, status;
+
+	/* Advance tail pointer past any empty and reaped descrs */
+	descr = chain->tail;
+	status = spider_net_get_descr_status(descr->hwdescr);
+
+	for (i=0; i<chain->num_desc; i++) {
+		if ((status != SPIDER_NET_DESCR_CARDOWNED) &&
+		    (status != SPIDER_NET_DESCR_NOT_IN_USE)) break;
+		descr = descr->next;
+		status = spider_net_get_descr_status(descr->hwdescr);
+	}
+	chain->tail = descr;
+
+	if ((i == chain->num_desc) || (i == 0))
+		return 1;
+	return 0;
+}
+
+/**
  * spider_net_decode_one_descr - processes an RX descriptor
  * @card: card structure
  *
@@ -1175,6 +1235,12 @@ spider_net_poll(struct net_device *netde
 		}
 	}
 
+	if ((packets_done == 0) && (card->num_rx_ints != 0)) {
+		no_more_packets = spider_net_resync_tail_ptr(card);
+		spider_net_resync_head_ptr(card);
+	}
+	card->num_rx_ints = 0;
+
 	netdev->quota -= packets_done;
 	*budget -= packets_done;
 	spider_net_refill_rx_chain(card);
@@ -1458,7 +1524,11 @@ spider_net_handle_error_irq(struct spide
 		if (netif_msg_intr(card) && net_ratelimit())
 			pr_err("Spider RX RAM full, incoming packets "
 			       "might be discarded!\n");
-		spider_net_rx_irq_off(card);
+		/* Could happen when rx chain is full */
+		spider_net_resync_head_ptr(card);
+		spider_net_refill_rx_chain(card);
+		spider_net_enable_rxdmac(card);
+		card->num_rx_ints ++;
 		netif_rx_schedule(card->netdev);
 		show_error = 0;
 		break;
@@ -1474,12 +1544,11 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GDCDCEINT: /* fallthrough */
 	case SPIDER_NET_GDBDCEINT: /* fallthrough */
 	case SPIDER_NET_GDADCEINT:
-		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("got descriptor chain end interrupt, "
-			       "restarting DMAC %c.\n",
-			       'D'-(i-SPIDER_NET_GDDDCEINT)/3);
+		spider_net_resync_head_ptr(card);
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
+		card->num_rx_ints ++;
+		netif_rx_schedule(card->netdev);
 		show_error = 0;
 		break;
 
@@ -1488,9 +1557,12 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GDCINVDINT: /* fallthrough */
 	case SPIDER_NET_GDBINVDINT: /* fallthrough */
 	case SPIDER_NET_GDAINVDINT:
-		/* could happen when rx chain is full */
+		/* Could happen when rx chain is full */
+		spider_net_resync_head_ptr(card);
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
+		card->num_rx_ints ++;
+		netif_rx_schedule(card->netdev);
 		show_error = 0;
 		break;
 
@@ -1583,6 +1655,7 @@ spider_net_interrupt(int irq, void *ptr)
 	if (status_reg & SPIDER_NET_RXINT ) {
 		spider_net_rx_irq_off(card);
 		netif_rx_schedule(netdev);
+		card->num_rx_ints ++;
 	}
 	if (status_reg & SPIDER_NET_TXINT)
 		netif_rx_schedule(netdev);
@@ -2231,6 +2304,7 @@ spider_net_setup_netdev(struct spider_ne
 	 *		NETIF_F_HW_VLAN_FILTER */
 
 	netdev->irq = card->pdev->irq;
+	card->num_rx_ints = 0;
 
 	dn = pci_device_to_OF_node(card->pdev);
 	if (!dn)
Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-08 15:45:32.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-11 10:02:25.000000000 -0500
@@ -25,7 +25,7 @@
 #ifndef _SPIDER_NET_H
 #define _SPIDER_NET_H
 
-#define VERSION "2.0 A"
+#define VERSION "2.0 B"
 
 #include "sungem_phy.h"
 
@@ -461,6 +461,7 @@ struct spider_net_card {
 	struct work_struct tx_timeout_task;
 	atomic_t tx_timeout_task_counter;
 	wait_queue_head_t waitq;
+	int num_rx_ints;
 
 	/* for ethtool */
 	int msg_enable;
