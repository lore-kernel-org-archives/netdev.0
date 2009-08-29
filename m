From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 11/17] tg3: Move napi to per-int struct
Date: Fri, 28 Aug 2009 17:01:37 -0700
Message-ID: <1251585288.29693@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2861 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640AbZH2Weu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a per-interrupt data structure, moves the napi
member over, and creates a tg3 pointer back to the device structure.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   39 +++++++++++++++++----------------------
 drivers/net/tg3.h |    9 ++++++++-
 2 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 37a4629..b308c40 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -687,7 +687,7 @@ static void tg3_restart_ints(struct tg3 *tp)
 static inline void tg3_netif_stop(struct tg3 *tp)
 {
 	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
-	napi_disable(&tp->napi);
+	napi_disable(&tp->napi[0].napi);
 	netif_tx_disable(tp->dev);
 }
 
@@ -698,7 +698,7 @@ static inline void tg3_netif_start(struct tg3 *tp)
 	 * so long as all callers are assured to have free tx slots
 	 * (such as after tg3_init_hw)
 	 */
-	napi_enable(&tp->napi);
+	napi_enable(&tp->napi[0].napi);
 	tp->hw_status->status |= SD_STATUS_UPDATED;
 	tg3_enable_ints(tp);
 }
@@ -4447,13 +4447,6 @@ static void tg3_recycle_rx(struct tg3 *tp, u32 opaque_key,
 	src_map->skb = NULL;
 }
 
-#if TG3_VLAN_TAG_USED
-static int tg3_vlan_rx(struct tg3 *tp, struct sk_buff *skb, u16 vlan_tag)
-{
-	return vlan_gro_receive(&tp->napi, tp->vlgrp, vlan_tag, skb);
-}
-#endif
-
 /* The RX ring scheme is composed of multiple rings which post fresh
  * buffers to the chip, and one special ring the chip uses to report
  * status back to the host.
@@ -4591,11 +4584,11 @@ static int tg3_rx(struct tg3 *tp, int budget)
 #if TG3_VLAN_TAG_USED
 		if (tp->vlgrp != NULL &&
 		    desc->type_flags & RXD_FLAG_VLAN) {
-			tg3_vlan_rx(tp, skb,
-				    desc->err_vlan & RXD_VLAN_MASK);
+			vlan_gro_receive(&tp->napi[0].napi, tp->vlgrp,
+					 desc->err_vlan & RXD_VLAN_MASK, skb);
 		} else
 #endif
-			napi_gro_receive(&tp->napi, skb);
+			napi_gro_receive(&tp->napi[0].napi, skb);
 
 		received++;
 		budget--;
@@ -4686,7 +4679,8 @@ static int tg3_poll_work(struct tg3 *tp, int work_done, int budget)
 
 static int tg3_poll(struct napi_struct *napi, int budget)
 {
-	struct tg3 *tp = container_of(napi, struct tg3, napi);
+	struct tg3_napi *tnapi = container_of(napi, struct tg3_napi, napi);
+	struct tg3 *tp = tnapi->tp;
 	int work_done = 0;
 	struct tg3_hw_status *sblk = tp->hw_status;
 
@@ -4770,7 +4764,7 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
-		napi_schedule(&tp->napi);
+		napi_schedule(&tp->napi[0].napi);
 
 	return IRQ_HANDLED;
 }
@@ -4795,7 +4789,7 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (likely(!tg3_irq_sync(tp)))
-		napi_schedule(&tp->napi);
+		napi_schedule(&tp->napi[0].napi);
 
 	return IRQ_RETVAL(1);
 }
@@ -4837,7 +4831,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp))) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-		napi_schedule(&tp->napi);
+		napi_schedule(&tp->napi[0].napi);
 	} else {
 		/* No work, shared interrupt perhaps?  re-enable
 		 * interrupts, and flush that PCI write
@@ -4895,7 +4889,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 
-	napi_schedule(&tp->napi);
+	napi_schedule(&tp->napi[0].napi);
 
 out:
 	return IRQ_RETVAL(handled);
@@ -4936,7 +4930,7 @@ static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
 		tg3_full_unlock(tp);
 		del_timer_sync(&tp->timer);
 		tp->irq_sync = 0;
-		napi_enable(&tp->napi);
+		napi_enable(&tp->napi[0].napi);
 		dev_close(tp->dev);
 		tg3_full_lock(tp, 0);
 	}
@@ -7935,7 +7929,7 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_ints_init(tp);
 
-	napi_enable(&tp->napi);
+	napi_enable(&tp->napi[0].napi);
 
 	err = tg3_request_irq(tp);
 
@@ -8011,7 +8005,7 @@ err_out2:
 	free_irq(tp->pdev->irq, dev);
 
 err_out1:
-	napi_disable(&tp->napi);
+	napi_disable(&tp->napi[0].napi);
 	tg3_ints_fini(tp);
 	tg3_free_consistent(tp);
 	return err;
@@ -8252,7 +8246,7 @@ static int tg3_close(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	napi_disable(&tp->napi);
+	napi_disable(&tp->napi[0].napi);
 	cancel_work_sync(&tp->reset_task);
 
 	netif_stop_queue(dev);
@@ -13396,7 +13390,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
 	tp->tx_pending = TG3_DEF_TX_RING_PENDING;
 
-	netif_napi_add(dev, &tp->napi, tg3_poll, 64);
+	tp->napi[0].tp = tp;
+	netif_napi_add(dev, &tp->napi[0].napi, tg3_poll, 64);
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->irq = pdev->irq;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 982171f..aff3f04 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2487,6 +2487,13 @@ struct tg3_rx_prodring_set {
 	dma_addr_t			rx_jmb_mapping;
 };
 
+#define TG3_IRQ_MAX_VECS 1
+
+struct tg3_napi {
+	struct napi_struct		napi	____cacheline_aligned;
+	struct tg3			*tp;
+};
+
 struct tg3 {
 	/* begin "general, frequently-used members" cacheline section */
 
@@ -2558,7 +2565,7 @@ struct tg3 {
 	dma_addr_t			tx_desc_mapping;
 
 	/* begin "rx thread" cacheline section */
-	struct napi_struct		napi;
+	struct tg3_napi			napi[TG3_IRQ_MAX_VECS];
 	void				(*write32_rx_mbox) (struct tg3 *, u32,
 							    u32);
 	u32				rx_rcb_ptr;
-- 
1.6.3.3


