From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [patch 3.8-rc2] drivers/net/ethernet/micrel/ks8851_mll
Date: Wed, 9 Jan 2013 20:17:29 +0000
Message-ID: <FD9AD8C5375B924CABC56D982DB3A802079D2520@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, David" <David.Choi@Micrel.Com>,
	"Doong, Ping" <Ping.Doong@Micrel.Com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o149.mxlogic.net ([208.65.145.72]:38704 "EHLO
	p01c12o149.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106Ab3AIURe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 15:17:34 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David J. Choi <david.choi@micrel.com>

Summary of changes:
.add codes to collect statistical information(for example rx/tx packets/bytes, error packets) 
 about Ethernet packets.

Signed-off-by: David J. Choi <david.choi@micrel.com>
---

--- linux-3.8-rc2/drivers/net/ethernet/micrel/ks8851_mll.c.orig	2013-01-03 09:45:57.830447923 -0800
+++ linux-3.8-rc2/drivers/net/ethernet/micrel/ks8851_mll.c	2013-01-03 10:05:57.675756568 -0800
@@ -801,7 +801,14 @@ static void ks_rcv(struct ks_net *ks, st
 			skb_put(skb, frame_hdr->len);
 			skb->protocol = eth_type_trans(skb, netdev);
 			netif_rx(skb);
+			netdev->stats.rx_packets++;
+			netdev->stats.rx_bytes += (frame_hdr->len - 4);
 		} else {
+			netdev->stats.rx_dropped++;
+			if ((frame_hdr->len >= RX_BUF_SIZE) || (frame_hdr->len == 0))
+			    netdev->stats.rx_length_errors++;
+			if (frame_hdr->sts & RXFSHR_RXFV) 
+			    netdev->stats.rx_frame_errors++;
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
