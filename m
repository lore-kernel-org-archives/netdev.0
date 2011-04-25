From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/6] tg3: Add TSO loopback test
Date: Mon, 25 Apr 2011 15:42:47 -0700
Message-ID: <1303771370-32579-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Benjamin Li" <benli@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2534 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756690Ab1DYWai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 18:30:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to exercise the TSO portion of the device through
a phy loopback test.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  158 +++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 123 insertions(+), 35 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 88cd231..fb2139a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11076,11 +11076,35 @@ static int tg3_test_memory(struct tg3 *tp)
 
 #define TG3_MAC_LOOPBACK	0
 #define TG3_PHY_LOOPBACK	1
+#define TG3_TSO_LOOPBACK	2
+
+#define TG3_TSO_MSS		500
+
+#define TG3_TSO_IP_HDR_LEN	20
+#define TG3_TSO_TCP_HDR_LEN	20
+#define TG3_TSO_TCP_OPT_LEN	12
+
+static const u8 tg3_tso_header[] = {
+0x08, 0x00,
+0x45, 0x00, 0x00, 0x00,
+0x00, 0x00, 0x40, 0x00,
+0x40, 0x06, 0x00, 0x00,
+0x0a, 0x00, 0x00, 0x01,
+0x0a, 0x00, 0x00, 0x02,
+0x0d, 0x00, 0xe0, 0x00,
+0x00, 0x00, 0x01, 0x00,
+0x00, 0x00, 0x02, 0x00,
+0x80, 0x10, 0x10, 0x00,
+0x14, 0x09, 0x00, 0x00,
+0x01, 0x01, 0x08, 0x0a,
+0x11, 0x11, 0x11, 0x11,
+0x11, 0x11, 0x11, 0x11,
+};
 
 static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 {
 	u32 mac_mode, rx_start_idx, rx_idx, tx_idx, opaque_key;
-	u32 desc_idx, coal_now;
+	u32 base_flags = 0, mss = 0, desc_idx, coal_now, data_off, val;
 	struct sk_buff *skb, *rx_skb;
 	u8 *tx_data;
 	dma_addr_t map;
@@ -11119,9 +11143,7 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 		else
 			mac_mode |= MAC_MODE_PORT_MODE_GMII;
 		tw32(MAC_MODE, mac_mode);
-	} else if (loopback_mode == TG3_PHY_LOOPBACK) {
-		u32 val;
-
+	} else {
 		if (tp->phy_flags & TG3_PHYFLG_IS_FET) {
 			tg3_phy_fet_toggle_apd(tp, false);
 			val = BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED100;
@@ -11169,8 +11191,6 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 				break;
 			mdelay(1);
 		}
-	} else {
-		return -EINVAL;
 	}
 
 	err = -EIO;
@@ -11186,7 +11206,54 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 
 	tw32(MAC_RX_MTU_SIZE, tx_len + ETH_FCS_LEN);
 
-	for (i = 14; i < tx_len; i++)
+	if (loopback_mode == TG3_TSO_LOOPBACK) {
+		struct iphdr *iph = (struct iphdr *)&tx_data[ETH_HLEN];
+
+		u32 hdr_len = TG3_TSO_IP_HDR_LEN + TG3_TSO_TCP_HDR_LEN +
+			      TG3_TSO_TCP_OPT_LEN;
+
+		memcpy(tx_data + ETH_ALEN * 2, tg3_tso_header,
+		       sizeof(tg3_tso_header));
+		mss = TG3_TSO_MSS;
+
+		val = tx_len - ETH_ALEN * 2 - sizeof(tg3_tso_header);
+		num_pkts = DIV_ROUND_UP(val, TG3_TSO_MSS);
+
+		/* Set the total length field in the IP header */
+		iph->tot_len = htons((u16)(mss + hdr_len));
+
+		base_flags = (TXD_FLAG_CPU_PRE_DMA |
+			      TXD_FLAG_CPU_POST_DMA);
+
+		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
+			struct tcphdr *th;
+			val = ETH_HLEN + TG3_TSO_IP_HDR_LEN;
+			th = (struct tcphdr *)&tx_data[val];
+			th->check = 0;
+		} else
+			base_flags |= TXD_FLAG_TCPUDP_CSUM;
+
+		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) {
+			mss |= (hdr_len & 0xc) << 12;
+			if (hdr_len & 0x10)
+				base_flags |= 0x00000010;
+			base_flags |= (hdr_len & 0x3e0) << 5;
+		} else if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)
+			mss |= hdr_len << 9;
+		else if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_1) ||
+			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+			mss |= (TG3_TSO_TCP_OPT_LEN << 9);
+		} else {
+			base_flags |= (TG3_TSO_TCP_OPT_LEN << 10);
+		}
+
+		data_off = ETH_ALEN * 2 + sizeof(tg3_tso_header);
+	} else {
+		num_pkts = 1;
+		data_off = ETH_HLEN;
+	}
+
+	for (i = data_off; i < tx_len; i++)
 		tx_data[i] = (u8) (i & 0xff);
 
 	map = pci_map_single(tp->pdev, skb->data, tx_len, PCI_DMA_TODEVICE);
@@ -11202,12 +11269,10 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 
 	rx_start_idx = rnapi->hw_status->idx[0].rx_producer;
 
-	num_pkts = 0;
-
-	tg3_set_txd(tnapi, tnapi->tx_prod, map, tx_len, 0, 1);
+	tg3_set_txd(tnapi, tnapi->tx_prod, map, tx_len,
+		    base_flags, (mss << 1) | 1);
 
 	tnapi->tx_prod++;
-	num_pkts++;
 
 	tw32_tx_mbox(tnapi->prodmbox, tnapi->tx_prod);
 	tr32_mailbox(tnapi->prodmbox);
@@ -11237,38 +11302,56 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 	if (rx_idx != rx_start_idx + num_pkts)
 		goto out;
 
-	desc = &rnapi->rx_rcb[rx_start_idx];
-	desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
-	opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
+	val = data_off;
+	while (rx_idx != rx_start_idx) {
+		desc = &rnapi->rx_rcb[rx_start_idx++];
+		desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
+		opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
 
-	if ((desc->err_vlan & RXD_ERR_MASK) != 0 &&
-	    (desc->err_vlan != RXD_ERR_ODD_NIBBLE_RCVD_MII))
-		goto out;
+		if ((desc->err_vlan & RXD_ERR_MASK) != 0 &&
+		    (desc->err_vlan != RXD_ERR_ODD_NIBBLE_RCVD_MII))
+			goto out;
 
-	rx_len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) - 4;
-	if (rx_len != tx_len)
-		goto out;
+		rx_len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT)
+			 - ETH_FCS_LEN;
 
-	if (pktsz <= TG3_RX_STD_DMA_SZ - ETH_FCS_LEN) {
-		if (opaque_key != RXD_OPAQUE_RING_STD)
-			goto out;
+		if (loopback_mode != TG3_TSO_LOOPBACK) {
+			if (rx_len != tx_len)
+				goto out;
 
-		rx_skb = tpr->rx_std_buffers[desc_idx].skb;
-		map = dma_unmap_addr(&tpr->rx_std_buffers[desc_idx], mapping);
-	} else {
-		if (opaque_key != RXD_OPAQUE_RING_JUMBO)
+			if (pktsz <= TG3_RX_STD_DMA_SZ - ETH_FCS_LEN) {
+				if (opaque_key != RXD_OPAQUE_RING_STD)
+					goto out;
+			} else {
+				if (opaque_key != RXD_OPAQUE_RING_JUMBO)
+					goto out;
+			}
+		} else if ((desc->type_flags & RXD_FLAG_TCPUDP_CSUM) &&
+			   (desc->ip_tcp_csum & RXD_TCPCSUM_MASK)
+			    >> RXD_TCPCSUM_SHIFT == 0xffff) {
 			goto out;
+		}
 
-		rx_skb = tpr->rx_jmb_buffers[desc_idx].skb;
-		map = dma_unmap_addr(&tpr->rx_jmb_buffers[desc_idx], mapping);
-	}
+		if (opaque_key == RXD_OPAQUE_RING_STD) {
+			rx_skb = tpr->rx_std_buffers[desc_idx].skb;
+			map = dma_unmap_addr(&tpr->rx_std_buffers[desc_idx],
+					     mapping);
+		} else if (opaque_key == RXD_OPAQUE_RING_JUMBO) {
+			rx_skb = tpr->rx_jmb_buffers[desc_idx].skb;
+			map = dma_unmap_addr(&tpr->rx_jmb_buffers[desc_idx],
+					     mapping);
+		} else
+			goto out;
 
-	pci_dma_sync_single_for_cpu(tp->pdev, map, rx_len, PCI_DMA_FROMDEVICE);
+		pci_dma_sync_single_for_cpu(tp->pdev, map, rx_len,
+					    PCI_DMA_FROMDEVICE);
 
-	for (i = 14; i < tx_len; i++) {
-		if (*(rx_skb->data + i) != (u8) (i & 0xff))
-			goto out;
+		for (i = data_off; i < rx_len; i++, val++) {
+			if (*(rx_skb->data + i) != (u8) (val & 0xff))
+				goto out;
+		}
 	}
+
 	err = 0;
 
 	/* tg3_free_rings will unmap and free the rx_skb */
@@ -11278,10 +11361,11 @@ out:
 
 #define TG3_STD_LOOPBACK_FAILED		1
 #define TG3_JMB_LOOPBACK_FAILED		2
+#define TG3_TSO_LOOPBACK_FAILED		4
 
 #define TG3_MAC_LOOPBACK_SHIFT		0
 #define TG3_PHY_LOOPBACK_SHIFT		4
-#define TG3_LOOPBACK_FAILED			0x00000033
+#define TG3_LOOPBACK_FAILED		0x00000077
 
 static int tg3_test_loopback(struct tg3 *tp)
 {
@@ -11358,6 +11442,10 @@ static int tg3_test_loopback(struct tg3 *tp)
 		if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_PHY_LOOPBACK))
 			err |= TG3_STD_LOOPBACK_FAILED <<
 			       TG3_PHY_LOOPBACK_SHIFT;
+		if ((tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
+		    tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_TSO_LOOPBACK))
+			err |= TG3_TSO_LOOPBACK_FAILED <<
+			       TG3_PHY_LOOPBACK_SHIFT;
 		if ((tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) &&
 		    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_PHY_LOOPBACK))
 			err |= TG3_JMB_LOOPBACK_FAILED <<
-- 
1.7.3.4


