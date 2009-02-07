From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 13/26] igb: add counter for dma out of sync errors
Date: Sat, 07 Feb 2009 01:19:08 -0800
Message-ID: <20090207091908.15697.1202.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:39105
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752106AbZBGJTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:19:30 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Add a counter for dma out of sync errors reported via interrupt.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_defines.h |    6 +++++-
 drivers/net/igb/e1000_hw.h      |    1 +
 drivers/net/igb/igb_ethtool.c   |    1 +
 drivers/net/igb/igb_main.c      |   19 +++++++++++++++++--
 4 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 54a1489..bff62dd 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -413,6 +413,7 @@
 /* LAN connected device generates an interrupt */
 #define E1000_ICR_PHYINT        0x00001000
 #define E1000_ICR_EPRST         0x00100000 /* ME handware reset occurs */
+#define E1000_ICR_DOUTSYNC      0x10000000 /* NIC DMA out of sync */
 
 /* Extended Interrupt Cause Read */
 #define E1000_EICR_RX_QUEUE0    0x00000001 /* Rx Queue 0 Interrupt */
@@ -441,7 +442,8 @@
     E1000_IMS_TXDW   |    \
     E1000_IMS_RXDMT0 |    \
     E1000_IMS_RXSEQ  |    \
-    E1000_IMS_LSC)
+    E1000_IMS_LSC    |    \
+    E1000_IMS_DOUTSYNC)
 
 /* Interrupt Mask Set */
 #define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
@@ -449,6 +451,7 @@
 #define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
 #define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
 #define E1000_IMS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
+#define E1000_IMS_DOUTSYNC  E1000_ICR_DOUTSYNC /* NIC DMA out of sync */
 
 /* Extended Interrupt Mask Set */
 #define E1000_EIMS_TCP_TIMER    E1000_EICR_TCP_TIMER /* TCP Timer */
@@ -457,6 +460,7 @@
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
 #define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
+#define E1000_ICS_DOUTSYNC  E1000_ICR_DOUTSYNC /* NIC DMA out of sync */
 
 /* Extended Interrupt Cause Set */
 
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index acb42a2..62ccd49 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -359,6 +359,7 @@ struct e1000_hw_stats {
 	u64 lenerrs;
 	u64 scvpc;
 	u64 hrmpc;
+	u64 doosync;
 };
 
 struct e1000_phy_stats {
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 33c23a1..de09430 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -88,6 +88,7 @@ static const struct igb_stats igb_gstrings_stats[] = {
 	{ "rx_long_byte_count", IGB_STAT(stats.gorc) },
 	{ "rx_csum_offload_good", IGB_STAT(hw_csum_good) },
 	{ "rx_csum_offload_errors", IGB_STAT(hw_csum_err) },
+	{ "tx_dma_out_of_sync", IGB_STAT(stats.doosync) },
 	{ "alloc_rx_buff_failed", IGB_STAT(alloc_rx_buff_failed) },
 	{ "tx_smbus", IGB_STAT(stats.mgptc) },
 	{ "rx_smbus", IGB_STAT(stats.mgprc) },
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8c27e0a..c05ca34 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -689,7 +689,7 @@ static void igb_irq_enable(struct igb_adapter *adapter)
 		wr32(E1000_EIAC, adapter->eims_enable_mask);
 		wr32(E1000_EIAM, adapter->eims_enable_mask);
 		wr32(E1000_EIMS, adapter->eims_enable_mask);
-		wr32(E1000_IMS, E1000_IMS_LSC);
+		wr32(E1000_IMS, E1000_IMS_LSC | E1000_IMS_DOUTSYNC);
 	} else {
 		wr32(E1000_IMS, IMS_ENABLE_MASK);
 		wr32(E1000_IAM, IMS_ENABLE_MASK);
@@ -3287,6 +3287,11 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 	u32 icr = rd32(E1000_ICR);
 
 	/* reading ICR causes bit 31 of EICR to be cleared */
+
+	if(icr & E1000_ICR_DOUTSYNC) {
+		/* HW is reporting DMA is out of sync */
+		adapter->stats.doosync++;
+	}
 	if (!(icr & E1000_ICR_LSC))
 		goto no_link_interrupt;
 	hw->mac.get_link_status = 1;
@@ -3295,7 +3300,7 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 		mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	
 no_link_interrupt:
-	wr32(E1000_IMS, E1000_IMS_LSC);
+	wr32(E1000_IMS, E1000_IMS_LSC | E1000_IMS_DOUTSYNC);
 	wr32(E1000_EIMS, adapter->eims_other);
 
 	return IRQ_HANDLED;
@@ -3499,6 +3504,11 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 
 	igb_write_itr(adapter->rx_ring);
 
+	if(icr & E1000_ICR_DOUTSYNC) {
+		/* HW is reporting DMA is out of sync */
+		adapter->stats.doosync++;
+	}
+
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
 		if (!test_bit(__IGB_DOWN, &adapter->state))
@@ -3534,6 +3544,11 @@ static irqreturn_t igb_intr(int irq, void *data)
 	if (!(icr & E1000_ICR_INT_ASSERTED))
 		return IRQ_NONE;
 
+	if(icr & E1000_ICR_DOUTSYNC) {
+		/* HW is reporting DMA is out of sync */
+		adapter->stats.doosync++;
+	}
+
 	eicr = rd32(E1000_EICR);
 
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {

