From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 13/18] spidernet: Cure RX ram full bug
Date: Thu, 7 Jun 2007 14:51:54 -0500
Message-ID: <20070607195154.GM16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	joseferr@br.ibm.com, mlui@us.ibm.com,
	Utz Bacher <utz.bacher@de.ibm.com>,
	Abdullah Dagli <dagli@de.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	MOKUNO Masakazu <mokuno@sm.sony.co.jp>,
	Tsutomu OWA <tsutomu.owa@toshiba.co.jp>,
	Kou Ishizaki <kou.ishizaki@toshiba.co.jp>,
	Geoff Levand <geoffrey.levand@am.sony.com>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:59378 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761120AbXFGTwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 15:52:01 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57Jr3eu006818
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:53:03 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JpxMh164640
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:51:59 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57Jpvnq030981
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:51:59 -0400
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



This patch fixes a rare deadlock that can occur when the kernel
is not able to empty out the RX ring quickly enough. Below follows
a detailed description of the bug and te fix.

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
 drivers/net/spider_net.h |    1 
 2 files changed, 81 insertions(+), 6 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:52:24.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:53:55.000000000 -0500
@@ -1111,6 +1111,65 @@ static void show_rx_chain(struct spider_
 }
 
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
+	if ((i != 0) && (i != chain->num_desc))
+		return 0;
+	return 1;
+}
+
+/**
  * spider_net_decode_one_descr - processes an RX descriptor
  * @card: card structure
  *
@@ -1237,6 +1296,12 @@ spider_net_poll(struct net_device *netde
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
@@ -1520,15 +1585,16 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GRFAFLLINT: /* fallthrough */
 	case SPIDER_NET_GRMFLLINT:
 		if (netif_msg_intr(card) && net_ratelimit()) {
-			dev_err(&card->netdev->dev, "Spider RX RAM full, "
+			dev_info(&card->netdev->dev, "Spider RX RAM full, "
 			        "incoming packets might be discarded!\n");
 			show_rx_chain(card);
 		}
-		spider_net_rx_irq_off(card);
-
-		/* If the card is spewing rxramfulls, then reset */
-		atomic_inc(&card->tx_timeout_task_counter);
-		schedule_work(&card->tx_timeout_task);
+		/* Could happen when rx chain is full */
+		spider_net_resync_head_ptr(card);
+		spider_net_refill_rx_chain(card);
+		spider_net_enable_rxdmac(card);
+		card->num_rx_ints ++;
+		netif_rx_schedule(card->netdev);
 		show_error = 0;
 		break;
 
@@ -1544,8 +1610,11 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GDBDCEINT: /* fallthrough */
 	case SPIDER_NET_GDADCEINT:
 		/* Could happen when rx chain is full */
+		spider_net_resync_head_ptr(card);
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
+		card->num_rx_ints ++;
+		netif_rx_schedule(card->netdev);
 		show_error = 0;
 		break;
 
@@ -1555,8 +1624,11 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GDBINVDINT: /* fallthrough */
 	case SPIDER_NET_GDAINVDINT:
 		/* Could happen when rx chain is full */
+		spider_net_resync_head_ptr(card);
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
+		card->num_rx_ints ++;
+		netif_rx_schedule(card->netdev);
 		show_error = 0;
 		break;
 
@@ -1648,6 +1720,7 @@ spider_net_interrupt(int irq, void *ptr)
 	if (status_reg & SPIDER_NET_RXINT ) {
 		spider_net_rx_irq_off(card);
 		netif_rx_schedule(netdev);
+		card->num_rx_ints ++;
 	}
 	if (status_reg & SPIDER_NET_TXINT)
 		netif_rx_schedule(netdev);
@@ -2300,6 +2373,7 @@ spider_net_setup_netdev(struct spider_ne
 	 *		NETIF_F_HW_VLAN_FILTER */
 
 	netdev->irq = card->pdev->irq;
+	card->num_rx_ints = 0;
 
 	dn = pci_device_to_OF_node(card->pdev);
 	if (!dn)
Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-07 11:52:22.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-07 11:52:35.000000000 -0500
@@ -466,6 +466,7 @@ struct spider_net_card {
 	struct work_struct tx_timeout_task;
 	atomic_t tx_timeout_task_counter;
 	wait_queue_head_t waitq;
+	int num_rx_ints;
 
 	/* for ethtool */
 	int msg_enable;
