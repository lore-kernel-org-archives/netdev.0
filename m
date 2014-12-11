From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v7 resubmit 3/4] r8169: Use dma_rmb() and dma_wmb()
 for DescOwn checks
Date: Thu, 11 Dec 2014 15:02:17 -0800
Message-ID: <20141211230217.25464.5870.stgit@ahduyck-server>
References: <20141211225250.25464.30291.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mathieu.desnoyers@polymtl.ca, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	mingo@kernel.org, linux-arch@vger.kernel.org, mikey@neuling.org,
	linux@arm.linux.org.uk, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, geert@linux-m68k.org,
	jeffrey.t.kirsher@intel.com, romieu@fr.zoreil.com,
	paulmck@linux.vnet.ibm.com, nic_swsd@realtek.com, arnd@arndb.de,
	will.deacon@arm.com, michael@ellerman.id.au, tony.luck@intel.com,
	torvalds@linux-foundation.org, oleg@redhat.com,
	schwidefsky@de.ibm.com, fweisbec@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141211225250.25464.30291.stgit@ahduyck-server>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The r8169 use a pair of wmb() calls when setting up the descriptor rings.
The first is to synchronize the descriptor data with the descriptor status,
and the second is to synchronize the descriptor status with the use of the
MMIO doorbell to notify the device that descriptors are ready.  This can
come at a heavy price on some systems, and is not really necessary on
systems such as x86 as a simple barrier() would suffice to order store/store
accesses.  As such we can replace the first memory barrier with
dma_wmb() to reduce the cost for these accesses.

In addition the r8169 uses a rmb() to prevent compiler optimization in the
cleanup paths, however by moving the barrier down a few lines and replacing
it with a dma_rmb() we should be able to use it to guarantee
descriptor accesses do not occur until the device has updated the DescOwn
bit from its end.

One last change I made is to move the update of cur_tx in the xmit path to
after the wmb.  This way we can guarantee the device and all CPUs should
see the DescOwn update before they see the cur_tx value update.

Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c |   29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3dad7e8..088136b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6605,6 +6605,9 @@ static inline void rtl8169_mark_to_asic(struct RxDesc *desc, u32 rx_buf_sz)
 {
 	u32 eor = le32_to_cpu(desc->opts1) & RingEnd;
 
+	/* Force memory writes to complete before releasing descriptor */
+	dma_wmb();
+
 	desc->opts1 = cpu_to_le32(DescOwn | eor | rx_buf_sz);
 }
 
@@ -6612,7 +6615,6 @@ static inline void rtl8169_map_to_asic(struct RxDesc *desc, dma_addr_t mapping,
 				       u32 rx_buf_sz)
 {
 	desc->addr = cpu_to_le64(mapping);
-	wmb();
 	rtl8169_mark_to_asic(desc, rx_buf_sz);
 }
 
@@ -7073,16 +7075,18 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	wmb();
+	/* Force memory writes to complete before releasing descriptor */
+	dma_wmb();
 
 	/* Anti gcc 2.95.3 bugware (sic) */
 	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
 	txd->opts1 = cpu_to_le32(status);
 
-	tp->cur_tx += frags + 1;
-
+	/* Force all memory writes to complete before notifying device */
 	wmb();
 
+	tp->cur_tx += frags + 1;
+
 	RTL_W8(TxPoll, NPQ);
 
 	mmiowb();
@@ -7181,11 +7185,16 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		struct ring_info *tx_skb = tp->tx_skb + entry;
 		u32 status;
 
-		rmb();
 		status = le32_to_cpu(tp->TxDescArray[entry].opts1);
 		if (status & DescOwn)
 			break;
 
+		/* This barrier is needed to keep us from reading
+		 * any other fields out of the Tx descriptor until
+		 * we know the status of DescOwn
+		 */
+		dma_rmb();
+
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
@@ -7280,11 +7289,16 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 		struct RxDesc *desc = tp->RxDescArray + entry;
 		u32 status;
 
-		rmb();
 		status = le32_to_cpu(desc->opts1) & tp->opts1_mask;
-
 		if (status & DescOwn)
 			break;
+
+		/* This barrier is needed to keep us from reading
+		 * any other fields out of the Rx descriptor until
+		 * we know the status of DescOwn
+		 */
+		dma_rmb();
+
 		if (unlikely(status & RxRES)) {
 			netif_info(tp, rx_err, dev, "Rx ERROR. status = %08x\n",
 				   status);
@@ -7346,7 +7360,6 @@ process_pkt:
 		}
 release_descriptor:
 		desc->opts2 = 0;
-		wmb();
 		rtl8169_mark_to_asic(desc, rx_buf_sz);
 	}
 
