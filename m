From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 19/20] ixgbe: update all DESC_ADV macros to
	accept a ring pointer
Date: Thu, 19 Aug 2010 16:40:31 -0700
Message-ID: <20100819234028.10335.95335.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:40306
	"EHLO qmta07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752158Ab0HSXkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:40:51 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

All of the DESC_ADV macros are currently needing the pointers to be
de-referenced before accessing the ring.  Instead of having to add all of
the asterisks it is easier to just update the macro to expect a pointer to
the ring.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    6 +++---
 drivers/net/ixgbe/ixgbe_ethtool.c |    4 ++--
 drivers/net/ixgbe/ixgbe_fcoe.c    |    2 +-
 drivers/net/ixgbe/ixgbe_main.c    |   24 ++++++++++++------------
 4 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 7233fef..ac4b90e 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -256,11 +256,11 @@ struct ixgbe_q_vector {
 	(R)->next_to_clean - (R)->next_to_use - 1)
 
 #define IXGBE_RX_DESC_ADV(R, i)	    \
-	(&(((union ixgbe_adv_rx_desc *)((R).desc))[i]))
+	(&(((union ixgbe_adv_rx_desc *)((R)->desc))[i]))
 #define IXGBE_TX_DESC_ADV(R, i)	    \
-	(&(((union ixgbe_adv_tx_desc *)((R).desc))[i]))
+	(&(((union ixgbe_adv_tx_desc *)((R)->desc))[i]))
 #define IXGBE_TX_CTXTDESC_ADV(R, i)	    \
-	(&(((struct ixgbe_adv_tx_context_desc *)((R).desc))[i]))
+	(&(((struct ixgbe_adv_tx_context_desc *)((R)->desc))[i]))
 
 #define IXGBE_MAX_JUMBO_FRAME_SIZE        16128
 #ifdef IXGBE_FCOE
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index fb6d8e8..4d74f4b 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1560,7 +1560,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TXDCTL(0), reg_data);
 
 	for (i = 0; i < tx_ring->count; i++) {
-		union ixgbe_adv_tx_desc *desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
+		union ixgbe_adv_tx_desc *desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 		struct sk_buff *skb;
 		unsigned int size = 1024;
 
@@ -1661,7 +1661,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 
 	for (i = 0; i < rx_ring->count; i++) {
 		union ixgbe_adv_rx_desc *rx_desc =
-		                                 IXGBE_RX_DESC_ADV(*rx_ring, i);
+		                                 IXGBE_RX_DESC_ADV(rx_ring, i);
 		struct sk_buff *skb;
 
 		skb = alloc_skb(IXGBE_RXBUFFER_2048 + NET_IP_ALIGN, GFP_KERNEL);
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 072327c..86fa07c 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -471,7 +471,7 @@ int ixgbe_fso(struct ixgbe_adapter *adapter,
 
 	/* write context desc */
 	i = tx_ring->next_to_use;
-	context_desc = IXGBE_TX_CTXTDESC_ADV(*tx_ring, i);
+	context_desc = IXGBE_TX_CTXTDESC_ADV(tx_ring, i);
 	context_desc->vlan_macip_lens	= cpu_to_le32(vlan_macip_lens);
 	context_desc->seqnum_seed	= cpu_to_le32(fcoe_sof_eof);
 	context_desc->type_tucmd_mlhl	= cpu_to_le32(type_tucmd);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c88ba13..85ecf0e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -385,7 +385,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 			"leng  ntw timestamp        bi->skb\n");
 
 		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
-			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
+			tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
 			printk(KERN_INFO "T [0x%03X]    %016llX %016llX %016llX"
@@ -466,7 +466,7 @@ rx_ring_summary:
 
 		for (i = 0; i < rx_ring->count; i++) {
 			rx_buffer_info = &rx_ring->rx_buffer_info[i];
-			rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
+			rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
 			u0 = (struct my_u0 *)rx_desc;
 			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 			if (staterr & IXGBE_RXD_STAT_DD) {
@@ -695,7 +695,7 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 	    ixgbe_tx_xon_state(adapter, tx_ring)) {
 		/* detected Tx unit hang */
 		union ixgbe_adv_tx_desc *tx_desc;
-		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
+		tx_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
 		e_err(drv, "Detected Tx Unit Hang\n"
 		      "  Tx Queue             <%d>\n"
 		      "  TDH, TDT             <%x>, <%x>\n"
@@ -743,7 +743,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->tx_buffer_info[i].next_to_watch;
-	eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
+	eop_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
 
 	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
 	       (count < tx_ring->work_limit)) {
@@ -751,7 +751,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		rmb(); /* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
 			struct sk_buff *skb;
-			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
+			tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			cleaned = (i == eop);
 			skb = tx_buffer_info->skb;
@@ -791,7 +791,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 		eop = tx_ring->tx_buffer_info[i].next_to_watch;
-		eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
+		eop_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
 	}
 
 	tx_ring->next_to_clean = i;
@@ -1047,7 +1047,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 	bi = &rx_ring->rx_buffer_info[i];
 
 	while (cleaned_count--) {
-		rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
+		rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
 
 		if (!bi->page_dma &&
 		    (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)) {
@@ -1188,7 +1188,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 #endif /* IXGBE_FCOE */
 
 	i = rx_ring->next_to_clean;
-	rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
+	rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	rx_buffer_info = &rx_ring->rx_buffer_info[i];
 
@@ -1263,7 +1263,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		if (i == rx_ring->count)
 			i = 0;
 
-		next_rxd = IXGBE_RX_DESC_ADV(*rx_ring, i);
+		next_rxd = IXGBE_RX_DESC_ADV(rx_ring, i);
 		prefetch(next_rxd);
 		cleaned_count++;
 
@@ -5813,7 +5813,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		i = tx_ring->next_to_use;
 
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		context_desc = IXGBE_TX_CTXTDESC_ADV(*tx_ring, i);
+		context_desc = IXGBE_TX_CTXTDESC_ADV(tx_ring, i);
 
 		/* VLAN MACLEN IPLEN */
 		if (tx_flags & IXGBE_TX_FLAGS_VLAN)
@@ -5872,7 +5872,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 	    (tx_flags & IXGBE_TX_FLAGS_VLAN)) {
 		i = tx_ring->next_to_use;
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		context_desc = IXGBE_TX_CTXTDESC_ADV(*tx_ring, i);
+		context_desc = IXGBE_TX_CTXTDESC_ADV(tx_ring, i);
 
 		if (tx_flags & IXGBE_TX_FLAGS_VLAN)
 			vlan_macip_lens |=
@@ -6101,7 +6101,7 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 	i = tx_ring->next_to_use;
 	while (count--) {
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
+		tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 		tx_desc->read.buffer_addr = cpu_to_le64(tx_buffer_info->dma);
 		tx_desc->read.cmd_type_len =
 		        cpu_to_le32(cmd_type_len | tx_buffer_info->length);

