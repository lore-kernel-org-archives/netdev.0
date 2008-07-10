From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/6] cxgb: delete non NAPI code from the driver.
Date: Fri, 11 Jul 2008 00:29:19 +0200
Message-ID: <20080710222919.GA31019@electric-eye.fr.zoreil.com>
References: <20080707.224336.59099363.davem@davemloft.net> <20080708070106.GA30382@electric-eye.fr.zoreil.com> <20080708.015548.127198943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Divy Le Ray <divy@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59384 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752880AbYGJW3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:29:43 -0400
Content-Disposition: inline
In-Reply-To: <20080708.015548.127198943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/Kconfig         |    8 -----
 drivers/net/chelsio/cxgb2.c |    2 -
 drivers/net/chelsio/sge.c   |   70 +++---------------------------------------
 3 files changed, 5 insertions(+), 75 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4675c1b..50ca1cf 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2378,14 +2378,6 @@ config CHELSIO_T1_1G
           Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
           are using only 10G cards say 'N' here.
 
-config CHELSIO_T1_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on CHELSIO_T1
-	default y
-	help
-	  NAPI is a driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card.
-
 config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
 	depends on PCI && INET
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index a509337..638c9a2 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1153,9 +1153,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 		netdev->poll_controller = t1_netpoll;
 #endif
-#ifdef CONFIG_CHELSIO_T1_NAPI
 		netif_napi_add(netdev, &adapter->napi, t1_poll, 64);
-#endif
 
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
 	}
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 8a7efd3..d6c7d2a 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1396,20 +1396,10 @@ static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 
 	if (unlikely(adapter->vlan_grp && p->vlan_valid)) {
 		st->vlan_xtract++;
-#ifdef CONFIG_CHELSIO_T1_NAPI
-			vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
-						 ntohs(p->vlan));
-#else
-			vlan_hwaccel_rx(skb, adapter->vlan_grp,
-					ntohs(p->vlan));
-#endif
-	} else {
-#ifdef CONFIG_CHELSIO_T1_NAPI
+		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
+					 ntohs(p->vlan));
+	} else
 		netif_receive_skb(skb);
-#else
-		netif_rx(skb);
-#endif
-	}
 }
 
 /*
@@ -1568,7 +1558,6 @@ static inline int responses_pending(const struct adapter *adapter)
 	return (e->GenerationBit == Q->genbit);
 }
 
-#ifdef CONFIG_CHELSIO_T1_NAPI
 /*
  * A simpler version of process_responses() that handles only pure (i.e.,
  * non data-carrying) responses.  Such respones are too light-weight to justify
@@ -1636,9 +1625,6 @@ int t1_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-/*
- * NAPI version of the main interrupt handler.
- */
 irqreturn_t t1_interrupt(int irq, void *data)
 {
 	struct adapter *adapter = data;
@@ -1656,7 +1642,8 @@ irqreturn_t t1_interrupt(int irq, void *data)
 			else {
 				/* no data, no NAPI needed */
 				writel(sge->respQ.cidx, adapter->regs + A_SG_SLEEPING);
-				napi_enable(&adapter->napi);	/* undo schedule_prep */
+				/* undo schedule_prep */
+				napi_enable(&adapter->napi);
 			}
 		}
 		return IRQ_HANDLED;
@@ -1672,53 +1659,6 @@ irqreturn_t t1_interrupt(int irq, void *data)
 	return IRQ_RETVAL(handled != 0);
 }
 
-#else
-/*
- * Main interrupt handler, optimized assuming that we took a 'DATA'
- * interrupt.
- *
- * 1. Clear the interrupt
- * 2. Loop while we find valid descriptors and process them; accumulate
- *      information that can be processed after the loop
- * 3. Tell the SGE at which index we stopped processing descriptors
- * 4. Bookkeeping; free TX buffers, ring doorbell if there are any
- *      outstanding TX buffers waiting, replenish RX buffers, potentially
- *      reenable upper layers if they were turned off due to lack of TX
- *      resources which are available again.
- * 5. If we took an interrupt, but no valid respQ descriptors was found we
- *      let the slow_intr_handler run and do error handling.
- */
-irqreturn_t t1_interrupt(int irq, void *cookie)
-{
-	int work_done;
-	struct adapter *adapter = cookie;
-	struct respQ *Q = &adapter->sge->respQ;
-
-	spin_lock(&adapter->async_lock);
-
-	writel(F_PL_INTR_SGE_DATA, adapter->regs + A_PL_CAUSE);
-
-	if (likely(responses_pending(adapter)))
-		work_done = process_responses(adapter, -1);
-	else
-		work_done = t1_slow_intr_handler(adapter);
-
-	/*
-	 * The unconditional clearing of the PL_CAUSE above may have raced
-	 * with DMA completion and the corresponding generation of a response
-	 * to cause us to miss the resulting data interrupt.  The next write
-	 * is also unconditional to recover the missed interrupt and render
-	 * this race harmless.
-	 */
-	writel(Q->cidx, adapter->regs + A_SG_SLEEPING);
-
-	if (!work_done)
-		adapter->sge->stats.unhandled_irqs++;
-	spin_unlock(&adapter->async_lock);
-	return IRQ_RETVAL(work_done != 0);
-}
-#endif
-
 /*
  * Enqueues the sk_buff onto the cmdQ[qid] and has hardware fetch it.
  *
-- 
1.5.3.3

