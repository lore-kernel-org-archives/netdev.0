From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 07/10] e1000: Buffer optimizations for small MTU
Date: Fri, 14 Apr 2006 11:37:03 -0700
Message-ID: <20060414183702.3461.61292.stgit@gitlost.site>
References: <20060414183423.3461.32772.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:55300 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751402AbWDNSdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:33:25 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060414183423.3461.32772.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove multi-descriptor support from legacy recieve path

Add memory usage efficiency by using more correct size descriptors for
small MTU sizes and optimize using LPE for <= 1522 byte frame sizes

An extra performance fix that effected our TCP window size growth
as a receiver.  Set our initial buffer to be 128 bytes instead of 256
to prevent over-socket charge when truesize is computed in the stack.
old way: truesize = 256 + l1 = 256 + 1460 = 1716
new way: truesize = 128 + l1 = 128 + 1460 = 1588
The magic value that we can't cross is 1648.


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/e1000/e1000.h      |    2 +
 drivers/net/e1000/e1000_main.c |   87 +++++++++++++++++++++++-----------------
 2 files changed, 52 insertions(+), 37 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 764808f..2dfabdb 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -114,6 +114,8 @@ struct e1000_adapter;
 /* Supported Rx Buffer Sizes */
 #define E1000_RXBUFFER_128   128    /* Used for packet split */
 #define E1000_RXBUFFER_256   256    /* Used for packet split */
+#define E1000_RXBUFFER_512   512
+#define E1000_RXBUFFER_1024  1024
 #define E1000_RXBUFFER_2048  2048
 #define E1000_RXBUFFER_4096  4096
 #define E1000_RXBUFFER_8192  8192
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 6d7ba0b..f604a1d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -972,8 +972,8 @@ e1000_sw_init(struct e1000_adapter *adap
 
 	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
 
-	adapter->rx_buffer_len = E1000_RXBUFFER_2048;
-	adapter->rx_ps_bsize0 = E1000_RXBUFFER_256;
+	adapter->rx_buffer_len = MAXIMUM_ETHERNET_FRAME_SIZE;
+	adapter->rx_ps_bsize0 = E1000_RXBUFFER_128;
 	hw->max_frame_size = netdev->mtu +
 			     ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
 	hw->min_frame_size = MINIMUM_ETHERNET_FRAME_SIZE;
@@ -1599,14 +1599,21 @@ e1000_setup_rctl(struct e1000_adapter *a
 		rctl |= E1000_RCTL_LPE;
 
 	/* Setup buffer sizes */
-	if (adapter->hw.mac_type >= e1000_82571) {
-		/* We can now specify buffers in 1K increments.
-		 * BSIZE and BSEX are ignored in this case. */
-		rctl |= adapter->rx_buffer_len << 0x11;
-	} else {
-		rctl &= ~E1000_RCTL_SZ_4096;
-		rctl |= E1000_RCTL_BSEX; 
-		switch (adapter->rx_buffer_len) {
+	rctl &= ~E1000_RCTL_SZ_4096;
+	rctl |= E1000_RCTL_BSEX;
+	switch (adapter->rx_buffer_len) {
+		case E1000_RXBUFFER_256:
+			rctl |= E1000_RCTL_SZ_256;
+			rctl &= ~E1000_RCTL_BSEX;
+			break;
+		case E1000_RXBUFFER_512:
+			rctl |= E1000_RCTL_SZ_512;
+			rctl &= ~E1000_RCTL_BSEX;
+			break;
+		case E1000_RXBUFFER_1024:
+			rctl |= E1000_RCTL_SZ_1024;
+			rctl &= ~E1000_RCTL_BSEX;
+			break;
 		case E1000_RXBUFFER_2048:
 		default:
 			rctl |= E1000_RCTL_SZ_2048;
@@ -1621,7 +1628,6 @@ e1000_setup_rctl(struct e1000_adapter *a
 		case E1000_RXBUFFER_16384:
 			rctl |= E1000_RCTL_SZ_16384;
 			break;
-		}
 	}
 
 #ifndef CONFIG_E1000_DISABLE_PACKET_SPLIT
@@ -2982,8 +2988,7 @@ e1000_change_mtu(struct net_device *netd
 
 	/* Adapter-specific max frame size limits. */
 	switch (adapter->hw.mac_type) {
-	case e1000_82542_rev2_0:
-	case e1000_82542_rev2_1:
+	case e1000_undefined ... e1000_82542_rev2_1:
 		if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
 			DPRINTK(PROBE, ERR, "Jumbo Frames not supported.\n");
 			return -EINVAL;
@@ -3017,27 +3022,32 @@ e1000_change_mtu(struct net_device *netd
 		break;
 	}
 
-
-	if (adapter->hw.mac_type > e1000_82547_rev_2) {
-		adapter->rx_buffer_len = max_frame;
-		E1000_ROUNDUP(adapter->rx_buffer_len, 1024);
-	} else {
-		if(unlikely((adapter->hw.mac_type < e1000_82543) &&
-		   (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE))) {
-			DPRINTK(PROBE, ERR, "Jumbo Frames not supported "
-					    "on 82542\n");
-			return -EINVAL;
-		} else {
-			if(max_frame <= E1000_RXBUFFER_2048)
-				adapter->rx_buffer_len = E1000_RXBUFFER_2048;
-			else if(max_frame <= E1000_RXBUFFER_4096)
-				adapter->rx_buffer_len = E1000_RXBUFFER_4096;
-			else if(max_frame <= E1000_RXBUFFER_8192)
-				adapter->rx_buffer_len = E1000_RXBUFFER_8192;
-			else if(max_frame <= E1000_RXBUFFER_16384)
-				adapter->rx_buffer_len = E1000_RXBUFFER_16384;
-		}
-	}
+	/* NOTE: dev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
+	 * means we reserve 2 more, this pushes us to allocate from the next
+	 * larger slab size
+	 * i.e. RXBUFFER_2048 --> size-4096 slab */
+
+	if (max_frame <= E1000_RXBUFFER_256)
+		adapter->rx_buffer_len = E1000_RXBUFFER_256;
+	else if (max_frame <= E1000_RXBUFFER_512)
+		adapter->rx_buffer_len = E1000_RXBUFFER_512;
+	else if (max_frame <= E1000_RXBUFFER_1024)
+		adapter->rx_buffer_len = E1000_RXBUFFER_1024;
+	else if (max_frame <= E1000_RXBUFFER_2048)
+		adapter->rx_buffer_len = E1000_RXBUFFER_2048;
+	else if (max_frame <= E1000_RXBUFFER_4096)
+		adapter->rx_buffer_len = E1000_RXBUFFER_4096;
+	else if (max_frame <= E1000_RXBUFFER_8192)
+		adapter->rx_buffer_len = E1000_RXBUFFER_8192;
+	else if (max_frame <= E1000_RXBUFFER_16384)
+		adapter->rx_buffer_len = E1000_RXBUFFER_16384;
+
+	/* adjust allocation if LPE protects us, and we aren't using SBP */
+#define MAXIMUM_ETHERNET_VLAN_SIZE 1522
+	if (!adapter->hw.tbi_compatibility_on &&
+	    ((max_frame == MAXIMUM_ETHERNET_FRAME_SIZE) ||
+	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE)))
+		adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 
 	netdev->mtu = new_mtu;
 
@@ -3568,10 +3578,12 @@ e1000_clean_rx_irq(struct e1000_adapter 
 				                       flags);
 				length--;
 			} else {
-				dev_kfree_skb_irq(skb);
+				/* recycle */
+				buffer_info->skb = skb;
 				goto next_desc;
 			}
-		}
+		} else
+			skb_put(skb, length);
 
 		/* code added for copybreak, this should improve
 		 * performance for small packets with large amounts
@@ -3676,6 +3688,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 	i = rx_ring->next_to_clean;
 	rx_desc = E1000_RX_DESC_PS(*rx_ring, i);
 	staterr = le32_to_cpu(rx_desc->wb.middle.status_error);
+	buffer_info = &rx_ring->buffer_info[i];
 
 	while (staterr & E1000_RXD_STAT_DD) {
 		buffer_info = &rx_ring->buffer_info[i];
@@ -3736,7 +3749,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 
 		/* page alloc/put takes too long and effects small packet
 		 * throughput, so unsplit small packets and save the alloc/put*/
-		if (l1 && ((length + l1) < E1000_CB_LENGTH)) {
+		if (l1 && ((length + l1) <= adapter->rx_ps_bsize0)) {
 			u8 *vaddr;
 			/* there is no documentation about how to call 
 			 * kmap_atomic, so we can't hold the mapping



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
