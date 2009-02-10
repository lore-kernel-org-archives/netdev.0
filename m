From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH net-next 1/4] enic: bug fix: return notify intr credits
Date: Mon, 09 Feb 2009 16:57:11 -0800
Message-ID: <20090210005711.24315.325.stgit@palito_client100.nuovasystems.com>
References: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:51689 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbZBJA5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 19:57:12 -0500
Received: from sj-core-5.cisco.com (sj-core-5.cisco.com [171.71.177.238])
	by sj-dkim-2.cisco.com (8.12.11/8.12.11) with ESMTP id n1A0vBwt012767
	for <netdev@vger.kernel.org>; Mon, 9 Feb 2009 16:57:11 -0800
Received: from palito_client100.nuovasystems.com (savbu-palito-client100.cisco.com [10.193.70.13])
	by sj-core-5.cisco.com (8.13.8/8.13.8) with ESMTP id n1A0vBMk024739
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 00:57:11 GMT
In-Reply-To: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: bug fix: return notify intr credits

Return notify intr credits after notify intr from firmware.  This is especially important for legacy PCI intr mode, where not returning credits would cause PBA to remain asserted which would get us right back into the ISR.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |   17 +++++++++++------
 drivers/net/enic/vnic_intr.h |   14 ++++++++++++++
 3 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index a832cc5..86b8c15 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -33,7 +33,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco 10G Ethernet Driver"
-#define DRV_VERSION		"1.0.0.648"
+#define DRV_VERSION		"1.0.0.933"
 #define DRV_COPYRIGHT		"Copyright 2008 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 7d60551..35fc9ea 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -400,10 +400,13 @@ static irqreturn_t enic_isr_legacy(int irq, void *data)
 		return IRQ_NONE;	/* not our interrupt */
 	}
 
-	if (ENIC_TEST_INTR(pba, ENIC_INTX_NOTIFY))
+	if (ENIC_TEST_INTR(pba, ENIC_INTX_NOTIFY)) {
+		vnic_intr_return_all_credits(&enic->intr[ENIC_INTX_NOTIFY]);
 		enic_notify_check(enic);
+	}
 
 	if (ENIC_TEST_INTR(pba, ENIC_INTX_ERR)) {
+		vnic_intr_return_all_credits(&enic->intr[ENIC_INTX_ERR]);
 		enic_log_q_error(enic);
 		/* schedule recovery from WQ/RQ error */
 		schedule_work(&enic->reset);
@@ -476,6 +479,8 @@ static irqreturn_t enic_isr_msix_err(int irq, void *data)
 {
 	struct enic *enic = data;
 
+	vnic_intr_return_all_credits(&enic->intr[ENIC_MSIX_ERR]);
+
 	enic_log_q_error(enic);
 
 	/* schedule recovery from WQ/RQ error */
@@ -488,8 +493,8 @@ static irqreturn_t enic_isr_msix_notify(int irq, void *data)
 {
 	struct enic *enic = data;
 
+	vnic_intr_return_all_credits(&enic->intr[ENIC_MSIX_NOTIFY]);
 	enic_notify_check(enic);
-	vnic_intr_unmask(&enic->intr[ENIC_MSIX_NOTIFY]);
 
 	return IRQ_HANDLED;
 }
@@ -616,7 +621,7 @@ static inline void enic_queue_wq_skb(struct enic *enic,
 			vlan_tag_insert, vlan_tag);
 }
 
-/* netif_tx_lock held, process context with BHs disabled */
+/* netif_tx_lock held, process context with BHs disabled, or BH */
 static int enic_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
@@ -1069,7 +1074,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 			lro_flush_all(&enic->lro_mgr);
 
 		netif_rx_complete(napi);
-		vnic_intr_unmask(&enic->intr[ENIC_MSIX_RQ]);
+		vnic_intr_unmask(&enic->intr[ENIC_INTX_WQ_RQ]);
 	}
 
 	return rq_work_done;
@@ -1095,9 +1100,9 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 
 		vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
 
-		/* Accumulate intr event credits for this polling
+		/* Return intr event credits for this polling
 		 * cycle.  An intr event is the completion of a
-		 * a WQ or RQ packet.
+		 * RQ packet.
 		 */
 
 		vnic_intr_return_credits(&enic->intr[ENIC_MSIX_RQ],
diff --git a/drivers/net/enic/vnic_intr.h b/drivers/net/enic/vnic_intr.h
index ce633a5..9a53604 100644
--- a/drivers/net/enic/vnic_intr.h
+++ b/drivers/net/enic/vnic_intr.h
@@ -76,6 +76,20 @@ static inline void vnic_intr_return_credits(struct vnic_intr *intr,
 	iowrite32(int_credit_return, &intr->ctrl->int_credit_return);
 }
 
+static inline unsigned int vnic_intr_credits(struct vnic_intr *intr)
+{
+	return ioread32(&intr->ctrl->int_credits);
+}
+
+static inline void vnic_intr_return_all_credits(struct vnic_intr *intr)
+{
+	unsigned int credits = vnic_intr_credits(intr);
+	int unmask = 1;
+	int reset_timer = 1;
+
+	vnic_intr_return_credits(intr, credits, unmask, reset_timer);
+}
+
 static inline u32 vnic_intr_legacy_pba(u32 __iomem *legacy_pba)
 {
 	/* read PBA without clearing */

