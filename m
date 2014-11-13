From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 2/3] r8169: Use load_acquire() and store_release() to reduce
 memory barrier overhead
Date: Thu, 13 Nov 2014 11:27:35 -0800
Message-ID: <20141113192735.12579.22892.stgit@ahduyck-server>
References: <20141113191250.12579.19694.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mikey@neuling.org, tony.luck@intel.com,
	mathieu.desnoyers@polymtl.ca, donald.c.skidmore@intel.com,
	peterz@infradead.org, benh@kernel.crashing.org,
	heiko.carstens@de.ibm.com, oleg@redhat.com, will.deacon@arm.com,
	davem@davemloft.net, michael@ellerman.id.au,
	matthew.vick@intel.com, nic_swsd@realtek.com, geert@linux-m68k.org,
	jeffrey.t.kirsher@intel.com, fweisbec@gmail.com,
	schwidefsky@de.ibm.com, linux@arm.linux.org.uk,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@kernel.org
To: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933528AbaKMT2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 14:28:45 -0500
In-Reply-To: <20141113191250.12579.19694.stgit@ahduyck-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The r8169 use a pair of wmb() calls when setting up the descriptor rings.
The first is to synchronize the descriptor data with the descriptor status,
and the second is to synchronize the descriptor status with the use of the
MMIO doorbell to notify the device that descriptors are ready.  This can come
at a heavy price on some systems, and is not really necessary on systems such
as x86 as a simple barrier() would suffice to order store/store accesses.

In addition the r8169 uses a rmb() however I believe it is placed incorrectly
as I assume it supposed to be ordering descriptor reads after the check for
ownership.  As such I believe this is actually an acquire access pattern so
I have updated the code and removed the barrier using a load_acquire() call.

Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c |   23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index cf154f7..42b4645 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6601,14 +6601,13 @@ static inline void rtl8169_mark_to_asic(struct RxDesc *desc, u32 rx_buf_sz)
 {
 	u32 eor = le32_to_cpu(desc->opts1) & RingEnd;
 
-	desc->opts1 = cpu_to_le32(DescOwn | eor | rx_buf_sz);
+	store_release(&desc->opts1, cpu_to_le32(DescOwn | eor | rx_buf_sz));
 }
 
 static inline void rtl8169_map_to_asic(struct RxDesc *desc, dma_addr_t mapping,
 				       u32 rx_buf_sz)
 {
 	desc->addr = cpu_to_le64(mapping);
-	wmb();
 	rtl8169_mark_to_asic(desc, rx_buf_sz);
 }
 
@@ -7077,11 +7076,9 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	wmb();
-
 	/* Anti gcc 2.95.3 bugware (sic) */
 	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
-	txd->opts1 = cpu_to_le32(status);
+	store_release(&txd->opts1, cpu_to_le32(status));
 
 	tp->cur_tx += frags + 1;
 
@@ -7183,16 +7180,15 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 	while (tx_left > 0) {
 		unsigned int entry = dirty_tx % NUM_TX_DESC;
 		struct ring_info *tx_skb = tp->tx_skb + entry;
-		u32 status;
+		__le32 status;
 
-		rmb();
-		status = le32_to_cpu(tp->TxDescArray[entry].opts1);
-		if (status & DescOwn)
+		status = load_acquire(&tp->TxDescArray[entry].opts1);
+		if (status & cpu_to_le32(DescOwn))
 			break;
 
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
-		if (status & LastFrag) {
+		if (status & cpu_to_le32(LastFrag)) {
 			pkts_compl++;
 			bytes_compl += tx_skb->skb->len;
 			dev_kfree_skb_any(tx_skb->skb);
@@ -7284,11 +7280,11 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 		struct RxDesc *desc = tp->RxDescArray + entry;
 		u32 status;
 
-		rmb();
-		status = le32_to_cpu(desc->opts1) & tp->opts1_mask;
-
+		status = cpu_to_le32(load_acquire(&desc->opts1));
 		if (status & DescOwn)
 			break;
+
+		status &= tp->opts1_mask;
 		if (unlikely(status & RxRES)) {
 			netif_info(tp, rx_err, dev, "Rx ERROR. status = %08x\n",
 				   status);
@@ -7350,7 +7346,6 @@ process_pkt:
 		}
 release_descriptor:
 		desc->opts2 = 0;
-		wmb();
 		rtl8169_mark_to_asic(desc, rx_buf_sz);
 	}
 
