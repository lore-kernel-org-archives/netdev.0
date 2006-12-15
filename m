From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 11/14] e1000: Fix PBA allocation calculations
Date: Fri, 15 Dec 2006 10:39:45 +0100
Message-ID: <1166175585.3365.132.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751538AbWLOKBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:01:14 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9gxMC006186
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:59 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9gxbG006185
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:59 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: Fix PBA allocation calculations
From: Bruce Allan <bruce.w.allan@intel.com>

Assign the PBA to be large enough to contain at least 2 jumbo frames on
all adapters. This dramatically increases performance on several adapters
and fixes TX performance degradation issues where the PBA was misallocated
in the old algorithm.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_hw.h   |    1 
 drivers/net/e1000/e1000_main.c |   99 +++++++++++++++++++++++++++++++++++------
 2 files changed, 86 insertions(+), 14 deletions(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -661,16 +661,34 @@ e1000_reinit_locked(struct e1000_adapter
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
-	uint32_t pba;
+	uint32_t pba = 0, tx_space, min_tx_space, min_rx_space;
 	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
+	boolean_t legacy_pba_adjust = FALSE;
 
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
 	 */
 
 	switch (adapter->hw.mac_type) {
+	case e1000_82542_rev2_0:
+	case e1000_82542_rev2_1:
+	case e1000_82543:
+	case e1000_82544:
+	case e1000_82540:
+	case e1000_82541:
+	case e1000_82541_rev_2:
+		legacy_pba_adjust = TRUE;
+		pba = E1000_PBA_48K;
+		break;
+	case e1000_82545:
+	case e1000_82545_rev_3:
+	case e1000_82546:
+	case e1000_82546_rev_3:
+		pba = E1000_PBA_48K;
+		break;
 	case e1000_82547:
 	case e1000_82547_rev_2:
+		legacy_pba_adjust = TRUE;
 		pba = E1000_PBA_30K;
 		break;
 	case e1000_82571:
@@ -679,27 +697,80 @@ e1000_reset(struct e1000_adapter *adapte
 		pba = E1000_PBA_38K;
 		break;
 	case e1000_82573:
-		pba = E1000_PBA_12K;
+		pba = E1000_PBA_20K;
 		break;
 	case e1000_ich8lan:
 		pba = E1000_PBA_8K;
-		break;
-	default:
-		pba = E1000_PBA_48K;
+	case e1000_undefined:
+	case e1000_num_macs:
 		break;
 	}
 
-	if ((adapter->hw.mac_type != e1000_82573) &&
-	   (adapter->netdev->mtu > E1000_RXBUFFER_8192))
-		pba -= 8; /* allocate more FIFO for Tx */
+	if (legacy_pba_adjust == TRUE) {
+		if (adapter->netdev->mtu > E1000_RXBUFFER_8192)
+			pba -= 8; /* allocate more FIFO for Tx */
 
+		if (adapter->hw.mac_type == e1000_82547) {
+			adapter->tx_fifo_head = 0;
+			adapter->tx_head_addr = pba << E1000_TX_HEAD_ADDR_SHIFT;
+			adapter->tx_fifo_size =
+				(E1000_PBA_40K - pba) << E1000_PBA_BYTES_SHIFT;
+			atomic_set(&adapter->tx_fifo_stall, 0);
+		}
+	} else if (adapter->hw.max_frame_size > MAXIMUM_ETHERNET_FRAME_SIZE) {
+		/* adjust PBA for jumbo frames */
+		E1000_WRITE_REG(&adapter->hw, PBA, pba);
+
+		/* To maintain wire speed transmits, the Tx FIFO should be
+		 * large enough to accomodate two full transmit packets,
+		 * rounded up to the next 1KB and expressed in KB.  Likewise,
+		 * the Rx FIFO should be large enough to accomodate at least
+		 * one full receive packet and is similarly rounded up and
+		 * expressed in KB. */
+		pba = E1000_READ_REG(&adapter->hw, PBA);
+		/* upper 16 bits has Tx packet buffer allocation size in KB */
+		tx_space = pba >> 16;
+		/* lower 16 bits has Rx packet buffer allocation size in KB */
+		pba &= 0xffff;
+		/* don't include ethernet FCS because hardware appends/strips */
+		min_rx_space = adapter->netdev->mtu + ENET_HEADER_SIZE +
+		               VLAN_TAG_SIZE;
+		min_tx_space = min_rx_space;
+		min_tx_space *= 2;
+		E1000_ROUNDUP(min_tx_space, 1024);
+		min_tx_space >>= 10;
+		E1000_ROUNDUP(min_rx_space, 1024);
+		min_rx_space >>= 10;
+
+		/* If current Tx allocation is less than the min Tx FIFO size,
+		 * and the min Tx FIFO size is less than the current Rx FIFO
+		 * allocation, take space away from current Rx allocation */
+		if (tx_space < min_tx_space &&
+		    ((min_tx_space - tx_space) < pba)) {
+			pba = pba - (min_tx_space - tx_space);
 
-	if (adapter->hw.mac_type == e1000_82547) {
-		adapter->tx_fifo_head = 0;
-		adapter->tx_head_addr = pba << E1000_TX_HEAD_ADDR_SHIFT;
-		adapter->tx_fifo_size =
-			(E1000_PBA_40K - pba) << E1000_PBA_BYTES_SHIFT;
-		atomic_set(&adapter->tx_fifo_stall, 0);
+			/* PCI/PCIx hardware has PBA alignment constraints */
+			switch (adapter->hw.mac_type) {
+			case e1000_82545 ... e1000_82546_rev_3:
+				pba &= ~(E1000_PBA_8K - 1);
+				break;
+			default:
+				break;
+			}
+
+			/* if short on rx space, rx wins and must trump tx
+			 * adjustment or use Early Receive if available */
+			if (pba < min_rx_space) {
+				switch (adapter->hw.mac_type) {
+				case e1000_82573:
+					/* ERT enabled in e1000_configure_rx */
+					break;
+				default:
+					pba = min_rx_space;
+					break;
+				}
+			}
+		}
 	}
 
 	E1000_WRITE_REG(&adapter->hw, PBA, pba);
Index: linux-2.6/drivers/net/e1000/e1000_hw.h
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_hw.h
+++ linux-2.6/drivers/net/e1000/e1000_hw.h
@@ -2419,6 +2419,7 @@ struct e1000_host_command_info {
 #define E1000_PBA_8K 0x0008    /* 8KB, default Rx allocation */
 #define E1000_PBA_12K 0x000C    /* 12KB, default Rx allocation */
 #define E1000_PBA_16K 0x0010    /* 16KB, default TX allocation */
+#define E1000_PBA_20K 0x0014
 #define E1000_PBA_22K 0x0016
 #define E1000_PBA_24K 0x0018
 #define E1000_PBA_30K 0x001E

