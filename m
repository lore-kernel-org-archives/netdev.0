From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 12/13] ixgbe: fix dca hints going to wrong processor
Date: Tue, 26 Aug 2008 04:27:27 -0700
Message-ID: <20080826112727.15787.47874.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756161AbYHZL12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:28 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099738rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:28 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

hardware was configured incorrectly which led all hints to be
sent to queue[0]'s DCA configuration.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   90 +++++++++++++++++++++++++++++-----------
 drivers/net/ixgbe/ixgbe_type.h |   10 ++--
 2 files changed, 69 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6b96c41..28d3321 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1410,10 +1410,51 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 	}
 }
 
-#define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
-			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
+#define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT	2
+
+static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
+{
+	struct ixgbe_ring *rx_ring;
+	u32 srrctl;
+	int queue0;
+	unsigned long *mask, maskval = 1;
+	long shift, len;
+
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
+		mask = (unsigned long *) &adapter->ring_feature[RING_F_RSS].mask;
+		len = sizeof(adapter->ring_feature[RING_F_RSS].mask) * 8;
+	} else {
+		mask = &maskval;
+		len = 1;
+	}
+	shift = find_first_bit(mask, len);
+	queue0 = index << shift;
+	rx_ring = &adapter->rx_ring[queue0];
+
+	srrctl = IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(index));
+
+	srrctl &= ~IXGBE_SRRCTL_BSIZEHDR_MASK;
+	srrctl &= ~IXGBE_SRRCTL_BSIZEPKT_MASK;
+
+	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+		srrctl |= IXGBE_RXBUFFER_2048 >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+		srrctl |= IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
+		srrctl |= ((IXGBE_RX_HDR_SIZE <<
+			    IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
+			   IXGBE_SRRCTL_BSIZEHDR_MASK);
+	} else {
+		srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
+
+		if (rx_ring->rx_buf_len == MAXIMUM_ETHERNET_VLAN_SIZE)
+			srrctl |= IXGBE_RXBUFFER_2048 >>
+			          IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+		else
+			srrctl |= rx_ring->rx_buf_len >>
+			          IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+	}
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
+}
 
-#define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT			2
 /**
  * ixgbe_get_skb_hdr - helper function for LRO header processing
  * @skb: pointer to sk_buff to be added to LRO packet
@@ -1441,6 +1482,9 @@ static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
 	return 0;
 }
 
+#define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
+			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
+
 /**
  * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
@@ -1460,7 +1504,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	                  0x6A3E67EA, 0x14364D17, 0x3BED200D};
 	u32 fctrl, hlreg0;
 	u32 pages;
-	u32 reta = 0, mrqc, srrctl;
+	u32 reta = 0, mrqc;
+	u32 rdrxctl;
 	int rx_buf_len;
 
 	/* Decide whether to use packet split mode or not */
@@ -1493,27 +1538,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 
 	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
 
-	srrctl = IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(0));
-	srrctl &= ~IXGBE_SRRCTL_BSIZEHDR_MASK;
-	srrctl &= ~IXGBE_SRRCTL_BSIZEPKT_MASK;
-
-	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-		srrctl |= PAGE_SIZE >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-		srrctl |= IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
-		srrctl |= ((IXGBE_RX_HDR_SIZE <<
-			    IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
-			   IXGBE_SRRCTL_BSIZEHDR_MASK);
-	} else {
-		srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
-
-		if (rx_buf_len == MAXIMUM_ETHERNET_VLAN_SIZE)
-			srrctl |=
-			     IXGBE_RXBUFFER_2048 >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-		else
-			srrctl |= rx_buf_len >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-	}
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(0), srrctl);
-
 	rdlen = adapter->rx_ring[0].count * sizeof(union ixgbe_adv_rx_desc);
 	/* disable receives while setting up the descriptors */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
@@ -1542,8 +1566,24 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].lro_mgr.dev = adapter->netdev;
 		adapter->rx_ring[i].lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
 		adapter->rx_ring[i].lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
+
+		ixgbe_configure_srrctl(adapter, j);
 	}
 
+	/*
+	 * For VMDq support of different descriptor types or
+	 * buffer sizes through the use of multiple SRRCTL
+	 * registers, RDRXCTL.MVMEN must be set to 1
+	 *
+	 * also, the manual doesn't mention it clearly but DCA hints
+	 * will only use queue 0's tags unless this bit is set.  Side
+	 * effects of setting this bit are only that SRRCTL must be
+	 * fully programmed [0..15]
+	 */
+	rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
+	rdrxctl |= IXGBE_RDRXCTL_MVMEN;
+	IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
+
 
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		/* Fill out redirection table */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 85eb03c..3e9c483 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -356,12 +356,10 @@
 #define IXGBE_ANLP2     0x042B4
 #define IXGBE_ATLASCTL  0x04800
 
-/* RSCCTL Bit Masks */
-#define IXGBE_RSCCTL_RSCEN          0x01
-#define IXGBE_RSCCTL_MAXDESC_1      0x00
-#define IXGBE_RSCCTL_MAXDESC_4      0x04
-#define IXGBE_RSCCTL_MAXDESC_8      0x08
-#define IXGBE_RSCCTL_MAXDESC_16     0x0C
+/* RDRXCTL Bit Masks */
+#define IXGBE_RDRXCTL_RDMTS_1_2     0x00000000 /* Rx Desc Min Threshold Size */
+#define IXGBE_RDRXCTL_MVMEN         0x00000020
+#define IXGBE_RDRXCTL_DMAIDONE      0x00000008 /* DMA init cycle done */
 
 /* CTRL Bit Masks */
 #define IXGBE_CTRL_GIO_DIS      0x00000004 /* Global IO Master Disable bit */

