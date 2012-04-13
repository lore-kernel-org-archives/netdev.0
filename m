From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 7/9] atl1: enable errors and link ints when rx/tx scheduled
Date: Fri, 13 Apr 2012 20:09:52 +0400
Message-ID: <1334333394-38404-8-git-send-email-antonz@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54721 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754748Ab2DMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:09:59 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |   32 ++++++++++++++++++++---------
 drivers/net/ethernet/atheros/atlx/atl1.h |   10 ++++++--
 2 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 4fcdf57..5781597 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2460,20 +2460,33 @@ static int atl1_rings_clean(struct napi_struct *napi, int budget)
 
 	napi_complete(napi);
 	/* re-enable Interrupt */
-	iowrite32(ISR_DIS_SMB | ISR_DIS_DMA, adapter->hw.hw_addr + REG_ISR);
+	if (likely(adapter->int_enabled))
+		atlx_imr_set(adapter, IMR_NORMAL_MASK);
 	return work_done;
 }
 
 static inline int atl1_sched_rings_clean(struct atl1_adapter* adapter)
 {
-	if (likely(napi_schedule_prep(&adapter->napi))) {
-		__napi_schedule(&adapter->napi);
+	if (!napi_schedule_prep(&adapter->napi))
+		/* It is possible in case even the RX/TX ints are disabled via IMR
+		 * register the ISR bits are set anyway (but do not produce IRQ).
+		 * To handle such situation the napi functions used to check is
+		 * something scheduled or not.
+		 */
+		return 0;
+
+	__napi_schedule(&adapter->napi);
+
+	/*
+	 * Disable RX/TX ints via IMR register if it is
+	 * allowed. NAPI handler must reenable them in same
+	 * way.
+	 */
+	if (!adapter->int_enabled)
 		return 1;
-	}
 
-	dev_printk(KERN_ERR, &adapter->pdev->dev,
-		   "rx: INTs must be disabled!");
-	return 0;
+	atlx_imr_set(adapter, IMR_NORXTX_MASK);
+	return 1;
 }
 
 /*
@@ -2538,8 +2551,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 		/* transmit or receive event */
 		if (status & (ISR_CMB_TX | ISR_CMB_RX) &&
 		    atl1_sched_rings_clean(adapter))
-			/* Go away with INTs disabled */
-			return IRQ_HANDLED;
+			break;
 
 		/* rx exception */
 		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
@@ -2551,7 +2563,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 					"rx exception, ISR = 0x%x\n",
 					status);
 			if (atl1_sched_rings_clean(adapter))
-				return IRQ_HANDLED;
+				break;
 		}
 
 		if (--max_ints < 0)
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.h b/drivers/net/ethernet/atheros/atlx/atl1.h
index 5209875..3bf79a5 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.h
+++ b/drivers/net/ethernet/atheros/atlx/atl1.h
@@ -275,13 +275,17 @@ static u32 atl1_check_link(struct atl1_adapter *adapter);
 #define ISR_DIS_SMB				0x20000000
 #define ISR_DIS_DMA				0x40000000
 
-/* Normal Interrupt mask  */
-#define IMR_NORMAL_MASK	(\
+/* Normal Interrupt mask without RX/TX enabled */
+#define IMR_NORXTX_MASK	(\
 	ISR_SMB		|\
 	ISR_GPHY	|\
 	ISR_PHY_LINKDOWN|\
 	ISR_DMAR_TO_RST	|\
-	ISR_DMAW_TO_RST	|\
+	ISR_DMAW_TO_RST)
+
+/* Normal Interrupt mask  */
+#define IMR_NORMAL_MASK	(\
+	IMR_NORXTX_MASK	|\
 	ISR_CMB_TX	|\
 	ISR_CMB_RX)
 
-- 
1.7.1
