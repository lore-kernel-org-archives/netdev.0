From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] net: atl1c: add BQL support
Date: Thu, 13 Aug 2015 00:40:20 +0200
Message-ID: <20150812224020.GA31826@electric-eye.fr.zoreil.com>
References: <55CAE130.8040406@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Cc: netdev@vger.kernel.org
To: Ron Angeles <ronangeles@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34379 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbbHLWkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 18:40:41 -0400
Content-Disposition: inline
In-Reply-To: <55CAE130.8040406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Ron Angeles <ronangeles@gmail.com> :
> This BQL implementation is mostly derived from its related driver, alx.
> Tested on AR8131 (rev c0) [1969:1063]. Saturated a 100mbps link with 5
> concurrent runs of netperf. Ping latency dropped from 14ms to 3ms.

Could you use some time to test the attached experimental stuff as well ?

-- 
Ueimor

--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-atl1c-use-return-value-where-argument-pointer-makes-.patch"

>From 3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f Mon Sep 17 00:00:00 2001
Message-Id: <3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f.1439418772.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, 19 Apr 2015 00:23:51 +0200
Subject: [PATCH 1/5] atl1c: use return value where argument pointer makes no
 sense.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 932bd18..282ec17 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -56,8 +56,7 @@ static int atl1c_stop_mac(struct atl1c_hw *hw);
 static void atl1c_disable_l0s_l1(struct atl1c_hw *hw);
 static void atl1c_set_aspm(struct atl1c_hw *hw, u16 link_speed);
 static void atl1c_start_mac(struct atl1c_adapter *adapter);
-static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter,
-		   int *work_done, int work_to_do);
+static int atl1c_clean_rx_irq(struct atl1c_adapter *adapter, int budget);
 static int atl1c_up(struct atl1c_adapter *adapter);
 static void atl1c_down(struct atl1c_adapter *adapter);
 static int atl1c_reset_mac(struct atl1c_hw *hw);
@@ -1787,11 +1786,10 @@ static void atl1c_clean_rfd(struct atl1c_rfd_ring *rfd_ring,
 	rfd_ring->next_to_clean = rfd_index;
 }
 
-static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter,
-		   int *work_done, int work_to_do)
+static int atl1c_clean_rx_irq(struct atl1c_adapter *adapter, int budget)
 {
 	u16 rfd_num, rfd_index;
-	u16 count = 0;
+	u16 count;
 	u16 length;
 	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev  = adapter->netdev;
@@ -1801,9 +1799,7 @@ static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter,
 	struct atl1c_recv_ret_status *rrs;
 	struct atl1c_buffer *buffer_info;
 
-	while (1) {
-		if (*work_done >= work_to_do)
-			break;
+	for (count = 0; count < budget; count++) {
 		rrs = ATL1C_RRD_DESC(rrd_ring, rrd_ring->next_to_clean);
 		if (likely(RRS_RXD_IS_VALID(rrs->word3))) {
 			rfd_num = (rrs->word0 >> RRS_RX_RFD_CNT_SHIFT) &
@@ -1857,12 +1853,11 @@ rrs_checked:
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan);
 		}
 		netif_receive_skb(skb);
-
-		(*work_done)++;
-		count++;
 	}
 	if (count)
 		atl1c_alloc_rx_buffer(adapter);
+
+	return count;
 }
 
 /**
@@ -1875,10 +1870,10 @@ static int atl1c_clean(struct napi_struct *napi, int budget)
 	int work_done = 0;
 
 	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(adapter->netdev))
+	if (unlikely(!netif_carrier_ok(adapter->netdev)))
 		goto quit_polling;
 	/* just enable one RXQ */
-	atl1c_clean_rx_irq(adapter, &work_done, budget);
+	work_done = atl1c_clean_rx_irq(adapter, budget);
 
 	if (work_done < budget) {
 quit_polling:
-- 
2.4.3


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-atl1c-highlight-normal-code-path-in-receive-poller-a.patch"

>From c1eb6bb4817ed04155e829df435264be675aeab4 Mon Sep 17 00:00:00 2001
Message-Id: <c1eb6bb4817ed04155e829df435264be675aeab4.1439418772.git.romieu@fr.zoreil.com>
In-Reply-To: <3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f.1439418772.git.romieu@fr.zoreil.com>
References: <3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f.1439418772.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, 19 Apr 2015 00:45:09 +0200
Subject: [PATCH 2/5] atl1c: highlight normal code path in receive poller
 atl1c_clean_rx_irq.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 46 +++++++++++--------------
 1 file changed, 20 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 282ec17..35ea3ec 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1801,46 +1801,40 @@ static int atl1c_clean_rx_irq(struct atl1c_adapter *adapter, int budget)
 
 	for (count = 0; count < budget; count++) {
 		rrs = ATL1C_RRD_DESC(rrd_ring, rrd_ring->next_to_clean);
-		if (likely(RRS_RXD_IS_VALID(rrs->word3))) {
-			rfd_num = (rrs->word0 >> RRS_RX_RFD_CNT_SHIFT) &
-				RRS_RX_RFD_CNT_MASK;
-			if (unlikely(rfd_num != 1))
-				/* TODO support mul rfd*/
-				if (netif_msg_rx_err(adapter))
-					dev_warn(&pdev->dev,
-						"Multi rfd not support yet!\n");
-			goto rrs_checked;
-		} else {
+		if (unlikely(!RRS_RXD_IS_VALID(rrs->word3)))
 			break;
+
+		rfd_num = (rrs->word0 >> RRS_RX_RFD_CNT_SHIFT) &
+			   RRS_RX_RFD_CNT_MASK;
+		if (unlikely(rfd_num != 1)) {
+			/* TODO support mul rfd*/
+			netif_warn(adapter, rx_err, netdev,
+				   "Multi rfd not support yet!\n");
 		}
-rrs_checked:
+
 		atl1c_clean_rrd(rrd_ring, rrs, rfd_num);
 		if (rrs->word3 & (RRS_RX_ERR_SUM | RRS_802_3_LEN_ERR)) {
 			atl1c_clean_rfd(rfd_ring, rrs, rfd_num);
-				if (netif_msg_rx_err(adapter))
-					dev_warn(&pdev->dev,
-						"wrong packet! rrs word3 is %x\n",
-						rrs->word3);
+			netif_warn(adapter, rx_err, netdev,
+				   "wrong packet! rrs word3: %x\n", rrs->word3);
 			continue;
 		}
 
 		length = le16_to_cpu((rrs->word3 >> RRS_PKT_SIZE_SHIFT) &
 				RRS_PKT_SIZE_MASK);
 		/* Good Receive */
-		if (likely(rfd_num == 1)) {
-			rfd_index = (rrs->word0 >> RRS_RX_RFD_INDEX_SHIFT) &
-					RRS_RX_RFD_INDEX_MASK;
-			buffer_info = &rfd_ring->buffer_info[rfd_index];
-			pci_unmap_single(pdev, buffer_info->dma,
-				buffer_info->length, PCI_DMA_FROMDEVICE);
-			skb = buffer_info->skb;
-		} else {
+		if (unlikely(rfd_num != 1)) {
 			/* TODO */
-			if (netif_msg_rx_err(adapter))
-				dev_warn(&pdev->dev,
-					"Multi rfd not support yet!\n");
 			break;
 		}
+
+		rfd_index = (rrs->word0 >> RRS_RX_RFD_INDEX_SHIFT) &
+			    RRS_RX_RFD_INDEX_MASK;
+		buffer_info = &rfd_ring->buffer_info[rfd_index];
+		pci_unmap_single(pdev, buffer_info->dma, buffer_info->length,
+				 PCI_DMA_FROMDEVICE);
+		skb = buffer_info->skb;
+
 		atl1c_clean_rfd(rfd_ring, rrs, rfd_num);
 		skb_put(skb, length - ETH_FCS_LEN);
 		skb->protocol = eth_type_trans(skb, netdev);
-- 
2.4.3


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0003-atl1c-remove-useless-forward-declaration-and-useless.patch"

>From 60b6eef77b3256e67c1ba1970df8d8488d76164a Mon Sep 17 00:00:00 2001
Message-Id: <60b6eef77b3256e67c1ba1970df8d8488d76164a.1439418772.git.romieu@fr.zoreil.com>
In-Reply-To: <3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f.1439418772.git.romieu@fr.zoreil.com>
References: <3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f.1439418772.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 2 May 2015 22:33:09 +0200
Subject: [PATCH 3/5] atl1c: remove useless forward declaration and useless
 variable.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 35ea3ec..4150118 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -56,7 +56,6 @@ static int atl1c_stop_mac(struct atl1c_hw *hw);
 static void atl1c_disable_l0s_l1(struct atl1c_hw *hw);
 static void atl1c_set_aspm(struct atl1c_hw *hw, u16 link_speed);
 static void atl1c_start_mac(struct atl1c_adapter *adapter);
-static int atl1c_clean_rx_irq(struct atl1c_adapter *adapter, int budget);
 static int atl1c_up(struct atl1c_adapter *adapter);
 static void atl1c_down(struct atl1c_adapter *adapter);
 static int atl1c_reset_mac(struct atl1c_hw *hw);
@@ -1689,7 +1688,6 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	struct atl1c_buffer *buffer_info, *next_info;
 	struct sk_buff *skb;
-	void *vir_addr = NULL;
 	u16 num_alloc = 0;
 	u16 rfd_next_to_use, next_next;
 	struct atl1c_rx_free_desc *rfd_desc;
@@ -1716,13 +1714,11 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter)
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
 		 */
-		vir_addr = skb->data;
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
-		mapping = pci_map_single(pdev, vir_addr,
-						buffer_info->length,
-						PCI_DMA_FROMDEVICE);
+		mapping = pci_map_single(pdev, skb->data, buffer_info->length,
+					 PCI_DMA_FROMDEVICE);
 		if (unlikely(pci_dma_mapping_error(pdev, mapping))) {
 			dev_kfree_skb(skb);
 			buffer_info->skb = NULL;
-- 
2.4.3


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0004-atl1c-move-tx-packet-completion-to-NAPI-context.patch"

>From a4897d6d64d5e880dd3a6f30b17c3cb1c02a244e Mon Sep 17 00:00:00 2001
Message-Id: <a4897d6d64d5e880dd3a6f30b17c3cb1c02a244e.1439418772.git.romieu@fr.zoreil.com>
In-Reply-To: <3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f.1439418772.git.romieu@fr.zoreil.com>
References: <3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f.1439418772.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 13 Aug 2015 00:15:48 +0200
Subject: [PATCH 4/5] atl1c: move tx packet completion to NAPI context.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 57 +++++++++++++++++++++----
 1 file changed, 49 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 4150118..5624b58 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1570,6 +1570,8 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 	return true;
 }
 
+#define ISR_NAPI	(ISR_RX_PKT | ISR_TX_PKT)
+
 /**
  * atl1c_intr - Interrupt Handler
  * @irq: interrupt number
@@ -1583,6 +1585,7 @@ static irqreturn_t atl1c_intr(int irq, void *data)
 	struct atl1c_hw *hw = &adapter->hw;
 	int max_ints = AT_MAX_INT_WORK;
 	int handled = IRQ_NONE;
+	u32 intr_mask = 0;
 	u32 status;
 	u32 reg_data;
 
@@ -1598,17 +1601,22 @@ static irqreturn_t atl1c_intr(int irq, void *data)
 		/* link event */
 		if (status & ISR_GPHY)
 			atl1c_clear_phy_int(adapter);
-		/* Ack ISR */
+
+		if (status & ISR_NAPI)
+			intr_mask = ~ISR_NAPI;
+
+		status &= intr_mask;
+
+		/* Ack non-NAPI events. */
 		AT_WRITE_REG(hw, REG_ISR, status | ISR_DIS_INT);
-		if (status & ISR_RX_PKT) {
+
+		if (intr_mask) {
 			if (likely(napi_schedule_prep(&adapter->napi))) {
-				hw->intr_mask &= ~ISR_RX_PKT;
+				hw->intr_mask &= intr_mask;
 				AT_WRITE_REG(hw, REG_IMR, hw->intr_mask);
 				__napi_schedule(&adapter->napi);
 			}
 		}
-		if (status & ISR_TX_PKT)
-			atl1c_clean_tx_irq(adapter, atl1c_trans_normal);
 
 		handled = IRQ_HANDLED;
 		/* check if PCIE PHY Link down */
@@ -1850,6 +1858,15 @@ static int atl1c_clean_rx_irq(struct atl1c_adapter *adapter, int budget)
 	return count;
 }
 
+static u32 atl1c_read_napi_events(struct atl1c_hw *hw)
+{
+	u32 data;
+
+	AT_READ_REG(hw, REG_ISR, &data);
+
+	return data & ISR_NAPI;
+}
+
 /**
  * atl1c_clean - NAPI Rx polling callback
  */
@@ -1857,19 +1874,43 @@ static int atl1c_clean(struct napi_struct *napi, int budget)
 {
 	struct atl1c_adapter *adapter =
 			container_of(napi, struct atl1c_adapter, napi);
+	struct atl1c_hw *hw = &adapter->hw;
+	u32 *intr_mask = &hw->intr_mask;
 	int work_done = 0;
+	u32 status;
 
 	/* Keep link state information with original netdev */
 	if (unlikely(!netif_carrier_ok(adapter->netdev)))
 		goto quit_polling;
+
+work:
+	status = atl1c_read_napi_events(hw);
+	/* Ack NAPI events. */
+	AT_WRITE_REG(hw, REG_ISR, status);
+
+	if (status & ISR_TX_PKT)
+		atl1c_clean_tx_irq(adapter, atl1c_trans_normal);
+
 	/* just enable one RXQ */
-	work_done = atl1c_clean_rx_irq(adapter, budget);
+	if (status & ISR_RX_PKT)
+		work_done = atl1c_clean_rx_irq(adapter, budget - work_done);
 
 	if (work_done < budget) {
 quit_polling:
 		napi_complete(napi);
-		adapter->hw.intr_mask |= ISR_RX_PKT;
-		AT_WRITE_REG(&adapter->hw, REG_IMR, adapter->hw.intr_mask);
+
+		*intr_mask |= ISR_NAPI;
+		AT_WRITE_REG(&adapter->hw, REG_IMR, *intr_mask);
+
+		/* Play safe if the chipset doesn't honor level triggered irq. */
+		status = atl1c_read_napi_events(hw);
+		if (status) {
+			*intr_mask &= ~ISR_NAPI;
+			AT_WRITE_REG(&adapter->hw, REG_IMR, *intr_mask);
+
+			if (likely(napi_schedule_prep(&adapter->napi)))
+				goto work;
+		}
 	}
 	return work_done;
 }
-- 
2.4.3


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0005-atl1c-remove-tx_lock.patch"

>From defdd6f990b188a819902d4f3f36b956c2e63d9b Mon Sep 17 00:00:00 2001
Message-Id: <defdd6f990b188a819902d4f3f36b956c2e63d9b.1439418772.git.romieu@fr.zoreil.com>
In-Reply-To: <3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f.1439418772.git.romieu@fr.zoreil.com>
References: <3f5bcfcc93ecc8634e5da95cc58a751e39a1ec9f.1439418772.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 13 Aug 2015 00:21:04 +0200
Subject: [PATCH 5/5] atl1c: remove tx_lock.
X-Organisation: Land of Sunshine Inc.

Being only used in atl1c_xmit_frame makes it a good candidate for removal,
especially as tx completion now happens in softirq context.

TODO: check the details / elaborate...

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |  3 +--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 11 -----------
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index b9203d9..c46b489 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -488,7 +488,7 @@ struct atl1c_tpd_ring {
 	dma_addr_t dma;		/* descriptor ring physical address */
 	u16 size;		/* descriptor ring length in bytes */
 	u16 count;		/* number of descriptors in the ring */
-	u16 next_to_use; 	/* this is protectd by adapter->tx_lock */
+	u16 next_to_use;
 	atomic_t next_to_clean;
 	struct atl1c_buffer *buffer_info;
 };
@@ -542,7 +542,6 @@ struct atl1c_adapter {
 	u16 link_duplex;
 
 	spinlock_t mdio_lock;
-	spinlock_t tx_lock;
 	atomic_t irq_sem;
 
 	struct work_struct common_task;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 5624b58..63b65e3 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -823,7 +823,6 @@ static int atl1c_sw_init(struct atl1c_adapter *adapter)
 	atl1c_set_rxbufsize(adapter, adapter->netdev);
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->mdio_lock);
-	spin_lock_init(&adapter->tx_lock);
 	set_bit(__AT_DOWN, &adapter->flags);
 
 	return 0;
@@ -2228,7 +2227,6 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 					  struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
-	unsigned long flags;
 	u16 tpd_req = 1;
 	struct atl1c_tpd_desc *tpd;
 	enum atl1c_trans_queue type = atl1c_trans_normal;
@@ -2239,16 +2237,10 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 	}
 
 	tpd_req = atl1c_cal_tpd_req(skb);
-	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
-		if (netif_msg_pktdata(adapter))
-			dev_info(&adapter->pdev->dev, "tx locked\n");
-		return NETDEV_TX_LOCKED;
-	}
 
 	if (atl1c_tpd_avail(adapter, type) < tpd_req) {
 		/* no enough descriptor, just stop queue */
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -2256,7 +2248,6 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 
 	/* do TSO and check sum */
 	if (atl1c_tso_csum(adapter, skb, &tpd, type) != 0) {
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -2279,11 +2270,9 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 			   "tx-skb droppted due to dma error\n");
 		/* roll back tpd/buffer */
 		atl1c_tx_rollback(adapter, tpd, type);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		dev_kfree_skb_any(skb);
 	} else {
 		atl1c_tx_queue(adapter, skb, tpd, type);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	}
 
 	return NETDEV_TX_OK;
-- 
2.4.3


--NzB8fVQJ5HfG6fxh--
