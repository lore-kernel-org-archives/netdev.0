From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 07/20] igb: change the head and tail offsets into
	pointers
Date: Tue, 27 Oct 2009 18:51:27 -0700
Message-ID: <20091028015126.12470.13190.stgit@localhost.localdomain>
References: <20091028014858.12470.99520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:46057
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756807AbZJ1BzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:55:10 -0400
In-Reply-To: <20091028014858.12470.99520.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since we are writting to the head/tail pointers frequently we might as well
save ourselves some processing time by converting the head and tail offsets
directly to pointers.  This will shave a few cycles off the rx/tx path and
allows us to move one step closer to the rings being a bit more independant of
each other.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    4 ++--
 drivers/net/igb/igb_main.c |   32 ++++++++++++++++----------------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 303df02..e52fee4 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -178,8 +178,8 @@ struct igb_ring {
 	unsigned int count;            /* number of desc. in the ring */
 	u16 next_to_use;
 	u16 next_to_clean;
-	u16 head;
-	u16 tail;
+	void __iomem *head;
+	void __iomem *tail;
 	struct igb_buffer *buffer_info; /* array of buffer info structs */
 
 	u8 queue_index;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index dfca821..2728f93 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2124,10 +2124,10 @@ static void igb_configure_tx_ring(struct igb_adapter *adapter,
 	                tdba & 0x00000000ffffffffULL);
 	wr32(E1000_TDBAH(reg_idx), tdba >> 32);
 
-	ring->head = E1000_TDH(reg_idx);
-	ring->tail = E1000_TDT(reg_idx);
-	writel(0, hw->hw_addr + ring->tail);
-	writel(0, hw->hw_addr + ring->head);
+	ring->head = hw->hw_addr + E1000_TDH(reg_idx);
+	ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
+	writel(0, ring->head);
+	writel(0, ring->tail);
 
 	txdctl |= IGB_TX_PTHRESH;
 	txdctl |= IGB_TX_HTHRESH << 8;
@@ -2354,10 +2354,10 @@ static void igb_configure_rx_ring(struct igb_adapter *adapter,
 	               ring->count * sizeof(union e1000_adv_rx_desc));
 
 	/* initialize head and tail */
-	ring->head = E1000_RDH(reg_idx);
-	ring->tail = E1000_RDT(reg_idx);
-	writel(0, hw->hw_addr + ring->head);
-	writel(0, hw->hw_addr + ring->tail);
+	ring->head = hw->hw_addr + E1000_RDH(reg_idx);
+	ring->tail = hw->hw_addr + E1000_RDT(reg_idx);
+	writel(0, ring->head);
+	writel(0, ring->tail);
 
 	/* set descriptor configuration */
 	if (adapter->rx_buffer_len < IGB_RXBUFFER_1024) {
@@ -2567,8 +2567,8 @@ static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 
-	writel(0, adapter->hw.hw_addr + tx_ring->head);
-	writel(0, adapter->hw.hw_addr + tx_ring->tail);
+	writel(0, tx_ring->head);
+	writel(0, tx_ring->tail);
 }
 
 /**
@@ -2667,8 +2667,8 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 
-	writel(0, adapter->hw.hw_addr + rx_ring->head);
-	writel(0, adapter->hw.hw_addr + rx_ring->tail);
+	writel(0, rx_ring->head);
+	writel(0, rx_ring->tail);
 }
 
 /**
@@ -3556,7 +3556,7 @@ static inline void igb_tx_queue_adv(struct igb_adapter *adapter,
 	wmb();
 
 	tx_ring->next_to_use = i;
-	writel(i, adapter->hw.hw_addr + tx_ring->tail);
+	writel(i, tx_ring->tail);
 	/* we need this if more than one processor can write to our tail
 	 * at a time, it syncronizes IO on IA64/Altix systems */
 	mmiowb();
@@ -4761,8 +4761,8 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 				"  jiffies              <%lx>\n"
 				"  desc.status          <%x>\n",
 				tx_ring->queue_index,
-				readl(adapter->hw.hw_addr + tx_ring->head),
-				readl(adapter->hw.hw_addr + tx_ring->tail),
+				readl(tx_ring->head),
+				readl(tx_ring->tail),
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
 				tx_ring->buffer_info[i].time_stamp,
@@ -5103,7 +5103,7 @@ no_buffers:
 		 * applicable for weak-ordered memory model archs,
 		 * such as IA-64). */
 		wmb();
-		writel(i, adapter->hw.hw_addr + rx_ring->tail);
+		writel(i, rx_ring->tail);
 	}
 }
 

