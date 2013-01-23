From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll: Implement
 basic statistics
Date: Wed, 23 Jan 2013 01:40:41 +0000
Message-ID: <FD9AD8C5375B924CABC56D982DB3A802079D32D1@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Doong, Ping" <Ping.Doong@Micrel.Com>,
	"Choi, David" <David.Choi@Micrel.Com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o149.mxlogic.net ([208.65.145.72]:44746 "EHLO
	p01c12o149.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753Ab3AWBkm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 20:40:42 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David J. Choi <david.choi@micrel.com>
 
Summary of changes:
  add codes to collect basic statistical information about Ethernet packets.
 
Signed-off-by: David J. Choi <david.choi@micrel.com>
---

--- net-next/drivers/net/ethernet/micrel/ks8851_mll.c.orig	2013-01-22 17:25:59.000000000 -0800
+++ net-next/drivers/net/ethernet/micrel/ks8851_mll.c	2013-01-22 17:27:57.000000000 -0800
@@ -798,10 +798,17 @@ static void ks_rcv(struct ks_net *ks, st
 			skb_reserve(skb, 2);
 			/* read data block including CRC 4 bytes */
 			ks_read_qmu(ks, (u16 *)skb->data, frame_hdr->len);
-			skb_put(skb, frame_hdr->len);
+			skb_put(skb, frame_hdr->len - 4); /*exclude size of CRC */
 			skb->protocol = eth_type_trans(skb, netdev);
 			netif_rx(skb);
+			netdev->stats.rx_packets++;
+			netdev->stats.rx_bytes += (frame_hdr->len - 4); /*crc field*/
 		} else {
+			netdev->stats.rx_dropped++;
+			if ((frame_hdr->len >= RX_BUF_SIZE) || (frame_hdr->len == 0))
+				netdev->stats.rx_length_errors++;
+			if (frame_hdr->sts & RXFSHR_RXFV) 
+				netdev->stats.rx_frame_errors++;
 			pr_err("%s: err:skb alloc\n", __func__);
 			ks_wrreg16(ks, KS_RXQCR, (ks->rc_rxqcr | RXQCR_RRXEF));
 			if (skb)
@@ -876,6 +883,8 @@ static irqreturn_t ks_irq(int irq, void 
 		pmecr &= ~PMECR_WKEVT_MASK;
 		ks_wrreg16(ks, KS_PMECR, pmecr | PMECR_WKEVT_LINK);
 	}
+	if (unlikely(status & IRQ_RXOI))
+		ks->netdev->stats.rx_over_errors++;
 
 	/* this should be the last in IRQ handler*/
 	ks_restore_cmd_reg(ks);
@@ -1015,6 +1024,8 @@ static int ks_start_xmit(struct sk_buff 
 
 	if (likely(ks_tx_fifo_space(ks) >= skb->len + 12)) {
 		ks_write_qmu(ks, skb->data, skb->len);
+		netdev->stats.tx_bytes += skb->len;
+		netdev->stats.tx_packets++;
 		dev_kfree_skb(skb);
 	} else
 		retv = NETDEV_TX_BUSY;

---
