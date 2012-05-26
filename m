From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fwd: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x277/0x280()
Date: Sat, 26 May 2012 12:11:33 +0200
Message-ID: <20120526101133.GA6170@electric-eye.fr.zoreil.com>
References: <20120503064726.GA17337@electric-eye.fr.zoreil.com> <4FA2A6A4.1030308@ceibo.fiec.espol.edu.ec> <4FA3EE49.7070805@palosanto.com> <4FA59F5B.5000800@palosanto.com> <20120505230155.GA3300@electric-eye.fr.zoreil.com> <4FBE533E.6030107@palosanto.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ZPt4rx8FFjLCG7dd"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Alex =?utf-8?B?VmlsbGFjw63CrXM=?= Lasso <a_villacis@palosanto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45538 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab2EZKTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2012 06:19:39 -0400
Content-Disposition: inline
In-Reply-To: <4FBE533E.6030107@palosanto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Alex Villací­s Lasso <a_villacis@palosanto.com> :
[...]
> According to my bisection, the first bad commit is 036dafa28da1e2565a8529de2ae663c37b7a0060 . Here is my bisection log:

There would be something wrong with bql support.

Can you apply the attached patches on top of 3.4 or later then
send the kernel log output whent the bug happens ?

Thanks.

-- 
Ueimor

--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-r8169-avoid-clearing-the-end-of-Tx-descriptor-ring-m.patch"

>From 01e33a3f6c46db63ba90f1db3b99eaf62c7071d1 Mon Sep 17 00:00:00 2001
Message-Id: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 23 May 2012 22:18:35 +0200
Subject: [PATCH 1/6] r8169: avoid clearing the end of Tx descriptor ring
 marker bit.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 00b4f56..01f3367 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5345,7 +5345,7 @@ static void rtl8169_unmap_tx_skb(struct device *d, struct ring_info *tx_skb,
 
 	dma_unmap_single(d, le64_to_cpu(desc->addr), len, DMA_TO_DEVICE);
 
-	desc->opts1 = 0x00;
+	desc->opts1 &= cpu_to_le32(RingEnd);
 	desc->opts2 = 0x00;
 	desc->addr = 0x00;
 	tx_skb->len = 0;
-- 
1.7.7.6


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-r8169-TxPoll-hack-rework.patch"

>From 7ef658faa62dc1211cabd9a6291e0921c12562bf Mon Sep 17 00:00:00 2001
Message-Id: <7ef658faa62dc1211cabd9a6291e0921c12562bf.1338026442.git.romieu@fr.zoreil.com>
In-Reply-To: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
References: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 23 May 2012 23:21:13 +0200
Subject: [PATCH 2/6] r8169: TxPoll hack rework.
X-Organisation: Land of Sunshine Inc.

I don't want to try and convince myself that it is completely safe to
issue a TxPoll request from the NAPI handler right in the middle of
a start_xmit, whence the tx_lock.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   59 +++++++++++++++++++--------------
 1 files changed, 34 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 01f3367..655b293 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5544,19 +5544,20 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
 	txd->opts1 = cpu_to_le32(status);
 
+	smp_wmb();
+
 	tp->cur_tx += frags + 1;
 
-	wmb();
+	smp_wmb();
 
 	RTL_W8(TxPoll, NPQ);
 
 	mmiowb();
 
 	if (!TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
-		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
-		 * not miss a ring update when it notices a stopped queue.
-		 */
-		smp_wmb();
+		/* rtl_tx thread must not miss a ring update when it notices
+		 * a stopped queue. The TxPoll hack requires the smp_wmb
+		 * above so we can go ahead. */
 		netif_stop_queue(dev);
 		/* Sync with rtl_tx:
 		 * - publish queue status and cur_tx ring index (write barrier)
@@ -5640,22 +5641,36 @@ struct rtl_txc {
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
 	struct rtl8169_stats *tx_stats = &tp->tx_stats;
-	unsigned int dirty_tx, tx_left;
+	unsigned int dirty_tx, cur_tx;
 	struct rtl_txc txc = { 0, 0 };
 
 	dirty_tx = tp->dirty_tx;
-	smp_rmb();
-	tx_left = tp->cur_tx - dirty_tx;
-
-	while (tx_left > 0) {
+xmit_race:
+	for (cur_tx = tp->cur_tx; dirty_tx != cur_tx; dirty_tx++) {
 		unsigned int entry = dirty_tx % NUM_TX_DESC;
 		struct ring_info *tx_skb = tp->tx_skb + entry;
 		u32 status;
 
-		rmb();
 		status = le32_to_cpu(tp->TxDescArray[entry].opts1);
-		if (status & DescOwn)
+
+		/* 8168 (only ?) hack: TxPoll requests are lost when the Tx
+		 * packets are too close. Let's kick an extra TxPoll request
+		 * when a burst of start_xmit activity is detected (if it is
+		 * not detected, it is slow enough).
+		 * The NPQ bit is cleared automatically by the chipset.
+		 * The code assumes that the chipset is sane enough to clear
+		 * it at a sensible time.*/
+		if (unlikely(status & DescOwn)) {
+			void __iomem *ioaddr = tp->mmio_addr;
+
+			if (!(RTL_R8(TxPoll) & NPQ)) {
+				netif_tx_lock(dev);
+				RTL_W8(TxPoll, NPQ);
+				netif_tx_unlock(dev);
+				goto done;
+			}
 			break;
+		}
 
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
@@ -5667,10 +5682,15 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 			dev_kfree_skb(skb);
 			tx_skb->skb = NULL;
 		}
-		dirty_tx++;
-		tx_left--;
 	}
 
+	/* Rationale: if chipset stopped DMAing, enforce TxPoll write either
+	 * here or in start_xmit. If chipset is still DMAing, this code
+	 * will be run later anyway. */
+	smp_mb();
+	if (cur_tx != tp->cur_tx)
+		goto xmit_race;
+done:
 	u64_stats_update_begin(&tx_stats->syncp);
 	tx_stats->packets += txc.packets;
 	tx_stats->bytes += txc.bytes;
@@ -5692,17 +5712,6 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
-		/*
-		 * 8168 hack: TxPoll requests are lost when the Tx packets are
-		 * too close. Let's kick an extra TxPoll request when a burst
-		 * of start_xmit activity is detected (if it is not detected,
-		 * it is slow enough). -- FR
-		 */
-		if (tp->cur_tx != dirty_tx) {
-			void __iomem *ioaddr = tp->mmio_addr;
-
-			RTL_W8(TxPoll, NPQ);
-		}
 	}
 }
 
-- 
1.7.7.6


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0003-r8169-ring-debug-helper.patch"

>From c8fa99f5afe595348dd578c450681c056abb7bcc Mon Sep 17 00:00:00 2001
Message-Id: <c8fa99f5afe595348dd578c450681c056abb7bcc.1338026442.git.romieu@fr.zoreil.com>
In-Reply-To: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
References: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 25 May 2012 11:29:26 +0200
Subject: [PATCH 3/6] r8169: ring debug helper.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 655b293..3feb374 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5382,6 +5382,30 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 	netdev_reset_queue(tp->dev);
 }
 
+static void rtl_print_ring(struct rtl8169_private *tp)
+{
+	struct net_device *dev = tp->dev;
+	int i;
+
+	netif_info(tp, drv, dev, "Rx ring: dirty=%08x current=%08x\n",
+		   tp->dirty_rx, tp->cur_rx);
+	for (i = 0; i < NUM_RX_DESC; i++) {
+		struct RxDesc *desc = tp->RxDescArray + i;
+
+		netif_info(tp, drv, dev, "[%03d] %08x %08x %0llx\n", i,
+			   desc->opts1, desc->opts2, (u64)desc->addr);
+	}
+
+	netif_info(tp, drv, dev, "Tx ring: dirty=%08x current=%08x\n",
+		   tp->dirty_tx, tp->cur_tx);
+	for (i = 0; i < NUM_TX_DESC; i++) {
+		struct TxDesc *desc = tp->TxDescArray + i;
+
+		netif_info(tp, drv, dev, "[%03d] %08x %08x %0llx\n", i,
+			   desc->opts1, desc->opts2, (u64)desc->addr);
+	}
+}
+
 static void rtl_reset_work(struct rtl8169_private *tp)
 {
 	struct net_device *dev = tp->dev;
@@ -5391,6 +5415,8 @@ static void rtl_reset_work(struct rtl8169_private *tp)
 	netif_stop_queue(dev);
 	synchronize_sched();
 
+	rtl_print_ring(tp);
+
 	rtl8169_hw_reset(tp);
 
 	for (i = 0; i < NUM_RX_DESC; i++)
-- 
1.7.7.6


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0004-r8169-add-extra-Tx-descriptor-ring-room-for-debug.patch"

>From e7fa457acf502c73f4581cd975a37ace410da734 Mon Sep 17 00:00:00 2001
Message-Id: <e7fa457acf502c73f4581cd975a37ace410da734.1338026442.git.romieu@fr.zoreil.com>
In-Reply-To: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
References: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 25 May 2012 12:37:02 +0200
Subject: [PATCH 4/6] r8169: add extra Tx descriptor ring room for debug.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |  100 +++++++++++++++++++++++++++++-----
 1 files changed, 85 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3feb374..4812515 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -82,9 +82,11 @@ static const int multicast_filter_limit = 32;
 #define R8169_REGS_SIZE		256
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
+#define NUM_TX_DESC_DBG	16	/* Tx descriptor ring canary */
 #define NUM_RX_DESC	256	/* Number of Rx descriptor registers */
 #define RX_BUF_SIZE	1536	/* Rx Buffer size */
-#define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
+#define R8169_TX_RING_BYTES	\
+	((NUM_TX_DESC + NUM_TX_DESC_DBG) * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
 #define RTL8169_TX_TIMEOUT	(6*HZ)
@@ -774,6 +776,11 @@ struct rtl8169_private {
 		} phy_action;
 	} *rtl_fw;
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)
+
+	struct {
+		struct sk_buff *skb;
+		dma_addr_t mapping;
+	} guard;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -5326,28 +5333,90 @@ err_out:
 	return -ENOMEM;
 }
 
-static int rtl8169_init_ring(struct net_device *dev)
+static int rtl_init_ring_tx(struct rtl8169_private *tp)
+{
+	struct device *d = &tp->pci_dev->dev;
+	struct sk_buff *skb;
+	dma_addr_t mapping;
+	int i;
+
+	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
+
+	/* Paranoid debug helping stuff ony beyond this point. */
+
+#define RTL_DBG_SKB_LEN	80
+
+	skb = netdev_alloc_skb_ip_align(tp->dev, RTL_DBG_SKB_LEN);
+	if (!skb)
+		return -ENOMEM;
+
+	for (i = 0; i < RTL_DBG_SKB_LEN; i++)
+		skb->data[i] = 0xaa;
+
+	mapping = dma_map_single(d, skb->data, RTL_DBG_SKB_LEN, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(d, mapping))) {
+		dev_kfree_skb(skb);
+		return -EIO;
+	}
+
+	for (i = NUM_TX_DESC; i < (NUM_TX_DESC + NUM_TX_DESC_DBG); i++) {
+		struct TxDesc *txd = tp->TxDescArray + i;
+
+		txd->addr  = cpu_to_le64(mapping);
+		txd->opts1 = cpu_to_le32(DescOwn | FirstFrag | LastFrag |
+					 RTL_DBG_SKB_LEN);
+	}
+	tp->TxDescArray[i - 1].opts1 |= RingEnd;
+
+	tp->guard.skb = skb;
+	tp->guard.mapping = mapping;
+
+	return 0;
+}
+
+static void rtl_clean_ring_tx(struct rtl8169_private *tp)
+{
+	struct device *d = &tp->pci_dev->dev;
+
+	dev_kfree_skb(tp->guard.skb);
+	dma_unmap_single(d, tp->guard.mapping, RTL_DBG_SKB_LEN, DMA_TO_DEVICE);
+}
+
+static int rtl_init_ring_rx(struct rtl8169_private *tp)
+{
+	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
+	return rtl8169_rx_fill(tp);
+}
+
+static int rtl8169_init_rings(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	int rc;
 
 	rtl8169_init_ring_indexes(tp);
 
-	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
-	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
+	rc = rtl_init_ring_tx(tp);
+	if (rc < 0)
+		return rc;
 
-	return rtl8169_rx_fill(tp);
+	rc = rtl_init_ring_rx(tp);
+	if (rc < 0)
+		rtl_clean_ring_tx(tp);
+
+	return rc;
 }
 
-static void rtl8169_unmap_tx_skb(struct device *d, struct ring_info *tx_skb,
-				 struct TxDesc *desc)
+static void rtl_unmap_tx_skb(struct rtl8169_private *tp,
+			     struct ring_info *tx_skb, struct TxDesc *desc)
 {
+	struct device *d = &tp->pci_dev->dev;
 	unsigned int len = tx_skb->len;
 
 	dma_unmap_single(d, le64_to_cpu(desc->addr), len, DMA_TO_DEVICE);
 
 	desc->opts1 &= cpu_to_le32(RingEnd);
 	desc->opts2 = 0x00;
-	desc->addr = 0x00;
+	desc->addr = cpu_to_le64(tp->guard.mapping);
 	tx_skb->len = 0;
 }
 
@@ -5364,8 +5433,7 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
 		if (len) {
 			struct sk_buff *skb = tx_skb->skb;
 
-			rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
-					     tp->TxDescArray + entry);
+			rtl_unmap_tx_skb(tp, tx_skb, tp->TxDescArray + entry);
 			if (skb) {
 				tp->dev->stats.tx_dropped++;
 				dev_kfree_skb(skb);
@@ -5398,7 +5466,7 @@ static void rtl_print_ring(struct rtl8169_private *tp)
 
 	netif_info(tp, drv, dev, "Tx ring: dirty=%08x current=%08x\n",
 		   tp->dirty_tx, tp->cur_tx);
-	for (i = 0; i < NUM_TX_DESC; i++) {
+	for (i = 0; i < (NUM_TX_DESC + NUM_TX_DESC_DBG); i++) {
 		struct TxDesc *desc = tp->TxDescArray + i;
 
 		netif_info(tp, drv, dev, "[%03d] %08x %08x %0llx\n", i,
@@ -5600,7 +5668,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 
 err_dma_1:
-	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
+	rtl_unmap_tx_skb(tp, tp->tx_skb + entry, txd);
 err_dma_0:
 	dev_kfree_skb(skb);
 	dev->stats.tx_dropped++;
@@ -5698,8 +5766,7 @@ xmit_race:
 			break;
 		}
 
-		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
-				     tp->TxDescArray + entry);
+		rtl_unmap_tx_skb(tp, tx_skb, tp->TxDescArray + entry);
 		if (status & LastFrag) {
 			struct sk_buff *skb = tx_skb->skb;
 
@@ -6034,6 +6101,8 @@ static void rtl8169_down(struct net_device *dev)
 
 	rtl8169_rx_clear(tp);
 
+	rtl_clean_ring_tx(tp);
+
 	rtl_pll_power_down(tp);
 }
 
@@ -6099,7 +6168,7 @@ static int rtl_open(struct net_device *dev)
 	if (!tp->RxDescArray)
 		goto err_free_tx_0;
 
-	retval = rtl8169_init_ring(dev);
+	retval = rtl8169_init_rings(dev);
 	if (retval < 0)
 		goto err_free_rx_1;
 
@@ -6143,6 +6212,7 @@ out:
 err_release_fw_2:
 	rtl_release_firmware(tp);
 	rtl8169_rx_clear(tp);
+	rtl_clean_ring_tx(tp);
 err_free_rx_1:
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			  tp->RxPhyAddr);
-- 
1.7.7.6


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0005-r8169-debugfs-support.patch"

>From bf93ca2cd16948911a5cb978e1fc46f468464156 Mon Sep 17 00:00:00 2001
Message-Id: <bf93ca2cd16948911a5cb978e1fc46f468464156.1338026442.git.romieu@fr.zoreil.com>
In-Reply-To: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
References: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 25 May 2012 11:18:03 +0200
Subject: [PATCH 5/6] r8169: debugfs support.
X-Organisation: Land of Sunshine Inc.

Almost completely copied from Stephen Hemminger's sky2.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/Kconfig |    9 +++
 drivers/net/ethernet/realtek/r8169.c |  126 ++++++++++++++++++++++++++++++++++
 2 files changed, 135 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index 5821966..ae48c78 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -115,4 +115,13 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
+config R8169_DEBUGFS
+	bool "Realtek 8169 gigabit ethernet debugfs support"
+	depends on R8169
+	---help---
+	  Say Y here if you want to see the content of the descriptor rings
+	  and misc undocumented debug information.
+
+	  Debug data is available in the /sys/kernel/debug/r8169/ethX file.
+
 endif # NET_VENDOR_REALTEK
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 4812515..834ff62 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -28,6 +28,7 @@
 #include <linux/firmware.h>
 #include <linux/pci-aspm.h>
 #include <linux/prefetch.h>
+#include <linux/debugfs.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -60,6 +61,10 @@
 #define dprintk(fmt, args...)	do {} while (0)
 #endif /* RTL8169_DEBUG */
 
+#ifdef CONFIG_R8169_DEBUGFS
+static struct dentry *rtl_debug;
+#endif
+
 #define R8169_MSG_DEFAULT \
 	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN)
 
@@ -781,6 +786,10 @@ struct rtl8169_private {
 		struct sk_buff *skb;
 		dma_addr_t mapping;
 	} guard;
+
+#ifdef CONFIG_R8169_DEBUGFS
+	struct dentry *debugfs;
+#endif
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -6794,14 +6803,131 @@ static struct pci_driver rtl8169_pci_driver = {
 	.driver.pm	= RTL8169_PM_OPS,
 };
 
+#ifdef CONFIG_R8169_DEBUGFS
+
+static struct dentry *rtl_debug;
+
+static int rtl_debug_show(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	const struct rtl8169_private *tp = netdev_priv(dev);
+	int i;
+
+	if (!netif_running(dev)) {
+		seq_printf(seq, "network not running\n");
+		return 0;
+	}
+
+	seq_printf(seq, "queue: %s\n", netif_queue_stopped(dev) ? "off" : "on");
+
+	seq_printf(seq, "Rx ring: dirty=%08x current=%08x\n", tp->dirty_rx,
+		   tp->cur_rx);
+	for (i = 0; i < NUM_RX_DESC; i++) {
+		struct RxDesc *desc = tp->RxDescArray + i;
+
+		seq_printf(seq, "[%03d] %08x %08x %0llx\n", i, desc->opts1,
+			   desc->opts2, (u64)desc->addr);
+	}
+
+	seq_printf(seq, "Tx ring: dirty=%08x current=%08x\n", tp->dirty_tx,
+		   tp->cur_tx);
+	for (i = 0; i < (NUM_TX_DESC + NUM_TX_DESC_DBG); i++) {
+		struct TxDesc *desc = tp->TxDescArray + i;
+
+		seq_printf(seq, "[%03d] %08x %08x %0llx\n", i, desc->opts1,
+			   desc->opts2, (u64)desc->addr);
+	}
+
+	return 0;
+}
+
+static int rtl_debug_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, rtl_debug_show, inode->i_private);
+}
+
+static const struct file_operations rtl_debug_fops = {
+	.owner		= THIS_MODULE,
+	.open		= rtl_debug_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int rtl_device_event(struct notifier_block *unused, unsigned long event,
+			    void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	if (dev->netdev_ops->ndo_open != rtl_open || !rtl_debug)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_CHANGENAME:
+		if (tp->debugfs) {
+			tp->debugfs = debugfs_rename(rtl_debug, tp->debugfs,
+						     rtl_debug, dev->name);
+		}
+		break;
+
+	case NETDEV_GOING_DOWN:
+		if (tp->debugfs) {
+			netdev_printk(KERN_DEBUG, dev, "remove debugfs\n");
+			debugfs_remove(tp->debugfs);
+			tp->debugfs = NULL;
+		}
+		break;
+
+	case NETDEV_UP:
+		tp->debugfs = debugfs_create_file(dev->name, S_IRUGO, rtl_debug,
+						  dev, &rtl_debug_fops);
+		if (IS_ERR(tp->debugfs))
+			tp->debugfs = NULL;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block rtl_debug_notifier = {
+	.notifier_call = rtl_device_event,
+};
+
+static __init void rtl_debug_init(void)
+{
+	struct dentry *ent;
+
+	ent = debugfs_create_dir("r8169", NULL);
+	if (ent && !IS_ERR(ent)) {
+		rtl_debug = ent;
+		register_netdevice_notifier(&rtl_debug_notifier);
+	}
+}
+
+static __exit void rtl_debug_cleanup(void)
+{
+	if (rtl_debug) {
+		unregister_netdevice_notifier(&rtl_debug_notifier);
+		debugfs_remove(rtl_debug);
+		rtl_debug = NULL;
+	}
+}
+
+#else
+#define rtl_debug_init()
+#define rtl_debug_cleanup()
+#endif
+
 static int __init rtl8169_init_module(void)
 {
+	rtl_debug_init();
 	return pci_register_driver(&rtl8169_pci_driver);
 }
 
 static void __exit rtl8169_cleanup_module(void)
 {
 	pci_unregister_driver(&rtl8169_pci_driver);
+	rtl_debug_cleanup();
 }
 
 module_init(rtl8169_init_module);
-- 
1.7.7.6


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0006-r8169-print-some-device-queue-information.patch"

>From 00285a7d6308c9b22dc9ecd4da62ee4f33d88e26 Mon Sep 17 00:00:00 2001
Message-Id: <00285a7d6308c9b22dc9ecd4da62ee4f33d88e26.1338026442.git.romieu@fr.zoreil.com>
In-Reply-To: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
References: <01e33a3f6c46db63ba90f1db3b99eaf62c7071d1.1338026442.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 26 May 2012 11:59:33 +0200
Subject: [PATCH 6/6] r8169: print some device queue information.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 834ff62..3450248 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5483,6 +5483,28 @@ static void rtl_print_ring(struct rtl8169_private *tp)
 	}
 }
 
+static void rtl_print_queue(struct rtl8169_private *tp)
+{
+	struct net_device *dev = tp->dev;
+	struct netdev_queue *nq = netdev_get_tx_queue(dev, 0);
+	struct dql *dql = &nq->dql;
+
+	netif_info(tp, drv, dev, "Device queue: avail=%d\n", dql_avail(dql));
+	netif_info(tp, drv, dev, " num_queued=%d\n", dql->num_queued);
+	netif_info(tp, drv, dev, " adj_limit=%d\n", dql->adj_limit);
+	netif_info(tp, drv, dev, " last_obj_cnt=%d\n", dql->last_obj_cnt);
+	netif_info(tp, drv, dev, " limit=%d\n", dql->limit);
+	netif_info(tp, drv, dev, " num_completed=%d\n", dql->num_completed);
+	netif_info(tp, drv, dev, " prev_ovlimit=%d\n", dql->prev_ovlimit);
+	netif_info(tp, drv, dev, " prev_num_queued=%d\n", dql->prev_num_queued);
+	netif_info(tp, drv, dev, " prev_last_obj_cnt=%d\n", dql->prev_last_obj_cnt);
+	netif_info(tp, drv, dev, " lowest_slack=%d\n", dql->lowest_slack);
+	netif_info(tp, drv, dev, " slack_start_time=%ld\n", dql->slack_start_time);
+	netif_info(tp, drv, dev, " max_limit=%d\n", dql->max_limit);
+	netif_info(tp, drv, dev, " min_limit=%d\n", dql->min_limit);
+	netif_info(tp, drv, dev, " slack_hold_time=%d\n", dql->slack_hold_time);
+}
+
 static void rtl_reset_work(struct rtl8169_private *tp)
 {
 	struct net_device *dev = tp->dev;
@@ -5493,6 +5515,7 @@ static void rtl_reset_work(struct rtl8169_private *tp)
 	synchronize_sched();
 
 	rtl_print_ring(tp);
+	rtl_print_queue(tp);
 
 	rtl8169_hw_reset(tp);
 
-- 
1.7.7.6


--ZPt4rx8FFjLCG7dd--
