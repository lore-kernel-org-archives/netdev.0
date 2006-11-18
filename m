From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/2] chelsio: use __netif_rx_schedule_prep
Date: Fri, 17 Nov 2006 17:00:34 -0800
Message-ID: <20061117170034.5b599fc6@zqx3.pdx.osdl.net>
References: <20061117112523.399e4122@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:37797 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1753733AbWKRBAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 20:00:49 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061117112523.399e4122@zqx3.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The chelsio driver can use __netif_rx_schedule_prep instead of it's own
test_and_set inline.  Applies after the previous 4 patches.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- chelsio-t2.orig/drivers/net/chelsio/sge.c
+++ chelsio-t2/drivers/net/chelsio/sge.c
@@ -929,18 +929,6 @@ static inline void reclaim_completed_tx(
 # define __netif_rx_complete(dev) netif_rx_complete(dev)
 #endif
 
-/*
- * We cannot use the standard netif_rx_schedule_prep() because we have multiple
- * ports plus the TOE all multiplexing onto a single response queue, therefore
- * accepting new responses cannot depend on the state of any particular port.
- * So define our own equivalent that omits the netif_running() test.
- */
-static inline int napi_schedule_prep(struct net_device *dev)
-{
-	return !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
-}
-
-
 /**
  *	sge_rx - process an ingress ethernet packet
  *	@sge: the sge structure
@@ -1241,10 +1229,10 @@ static irqreturn_t t1_interrupt_napi(int
 		if (e->GenerationBit == q->genbit) {
 			if (e->DataValid ||
 			    process_pure_responses(adapter, e)) {
-				if (likely(napi_schedule_prep(sge->netdev)))
+				if (likely(__netif_rx_schedule_prep(sge->netdev)))
 					__netif_rx_schedule(sge->netdev);
-				else
-					printk(KERN_CRIT
+				else if (net_ratelimit())
+					printk(KERN_INFO
 					       "NAPI schedule failure!\n");
 			} else
 			writel(q->cidx, adapter->regs + A_SG_SLEEPING);

