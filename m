From: "Choi, David" <David.Choi@Micrel.Com>
Subject: RE: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Tue, 29 Jan 2013 18:24:57 +0000
Message-ID: <FD9AD8C5375B924CABC56D982DB3A802079D382B@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Doong, Ping" <Ping.Doong@Micrel.Com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: "joe@perches.com" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o145.mxlogic.net ([208.65.145.68]:34012 "EHLO
	p01c12o145.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab3A2SZJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 13:25:09 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David J. Choi <david.choi@micrel.com>
 
Implement to collect basic statistical information about Ethernet packets.
 
Signed-off-by: David J. Choi <david.choi@micrel.com>
---

--- net-next/drivers/net/ethernet/micrel/ks8851_mll.c.orig	2013-01-22 17:25:59.000000000 -0800
+++ net-next/drivers/net/ethernet/micrel/ks8851_mll.c	2013-01-29 10:06:09.000000000 -0800
@@ -793,19 +793,35 @@ static void ks_rcv(struct ks_net *ks, st
 	frame_hdr = ks->frame_head_info;
 	while (ks->frame_cnt--) {
 		skb = netdev_alloc_skb(netdev, frame_hdr->len + 16);
-		if (likely(skb && (frame_hdr->sts & RXFSHR_RXFV) &&
-			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {
+		if (unlikely(!skb)) {
+			/* discard the packet from the device */
+			ks_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_RRXEF);
+			netdev->stats.rx_dropped++;
+		} else if (likely((frame_hdr->sts & RXFSHR_RXFV) &&
+				frame_hdr->len > 0 &&
+				frame_hdr->len <= RX_BUF_SIZE)) {
 			skb_reserve(skb, 2);
 			/* read data block including CRC 4 bytes */
 			ks_read_qmu(ks, (u16 *)skb->data, frame_hdr->len);
-			skb_put(skb, frame_hdr->len);
+
+			/* exclude the size of CRC */
+			skb_put(skb, frame_hdr->len - 4);
 			skb->protocol = eth_type_trans(skb, netdev);
 			netif_rx(skb);
+			netdev->stats.rx_packets++;
+
+			/* crc field */
+			netdev->stats.rx_bytes += frame_hdr->len - 4;
 		} else {
-			pr_err("%s: err:skb alloc\n", __func__);
-			ks_wrreg16(ks, KS_RXQCR, (ks->rc_rxqcr | RXQCR_RRXEF));
-			if (skb)
-				dev_kfree_skb_irq(skb);
+			/* discard the packet from the device */
+			ks_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_RRXEF);
+			netdev->stats.rx_dropped++;
+			if (frame_hdr->len >= RX_BUF_SIZE || !frame_hdr->len)
+				netdev->stats.rx_length_errors++;
+			if (!(frame_hdr->sts & RXFSHR_RXFV))
+				netdev->stats.rx_frame_errors++;
+
+			dev_kfree_skb_irq(skb);
 		}
 		frame_hdr++;
 	}
@@ -876,6 +892,8 @@ static irqreturn_t ks_irq(int irq, void 
 		pmecr &= ~PMECR_WKEVT_MASK;
 		ks_wrreg16(ks, KS_PMECR, pmecr | PMECR_WKEVT_LINK);
 	}
+	if (unlikely(status & IRQ_RXOI))
+		ks->netdev->stats.rx_over_errors++;
 
 	/* this should be the last in IRQ handler*/
 	ks_restore_cmd_reg(ks);
@@ -1015,6 +1033,8 @@ static int ks_start_xmit(struct sk_buff 
 
 	if (likely(ks_tx_fifo_space(ks) >= skb->len + 12)) {
 		ks_write_qmu(ks, skb->data, skb->len);
+		netdev->stats.tx_bytes += skb->len;
+		netdev->stats.tx_packets++;
 		dev_kfree_skb(skb);
 	} else
 		retv = NETDEV_TX_BUSY;

---
