From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [PATCH V1] ks8851_mll: basic ethernet statistics
Date: Fri, 8 Mar 2013 22:58:20 +0000
Message-ID: <FD9AD8C5375B924CABC56D982DB3A8020B4F7D67@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Li, Charles" <Charles.Li@Micrel.Com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o142.mxlogic.net ([208.65.144.65]:58589 "EHLO
	p01c11o142.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933426Ab3CHXE3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 18:04:29 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From f8a50c5e9d01aa633033bd622bd83706d86f85cc Mon Sep 17 00:00:00 2001
From: "David J. Choi" <david.choi@micrel.com>
Date: Fri, 8 Mar 2013 13:02:23 -0800
Subject: [PATCH V1] ks8851_mll: basic ethernet statistics

Implement to collect ethernet statistical information on ks8851_mll device.

Signed-off-by: David J. Choi <david.choi@micrel.com>
---
 drivers/net/ethernet/micrel/ks8851_mll.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index a343066..db108e7 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -792,20 +792,35 @@ static void ks_rcv(struct ks_net *ks, struct net_device *netdev)
 
 	frame_hdr = ks->frame_head_info;
 	while (ks->frame_cnt--) {
+		if (unlikely(!(frame_hdr->sts & RXFSHR_RXFV) ||
+		    frame_hdr->len >= RX_BUF_SIZE ||
+		    frame_hdr->len <= 0)) {
+
+			/* discard an invalid packet */
+			ks_wrreg16(ks, KS_RXQCR, (ks->rc_rxqcr | RXQCR_RRXEF));
+			netdev->stats.rx_dropped++;
+			if (!(frame_hdr->sts & RXFSHR_RXFV))
+				netdev->stats.rx_frame_errors++;
+			else
+				netdev->stats.rx_length_errors++;
+			frame_hdr++;
+			continue;
+		}
+
 		skb = netdev_alloc_skb(netdev, frame_hdr->len + 16);
-		if (likely(skb && (frame_hdr->sts & RXFSHR_RXFV) &&
-			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {
+		if (likely(skb)) {
 			skb_reserve(skb, 2);
 			/* read data block including CRC 4 bytes */
 			ks_read_qmu(ks, (u16 *)skb->data, frame_hdr->len);
-			skb_put(skb, frame_hdr->len);
+			skb_put(skb, frame_hdr->len - 4);
 			skb->protocol = eth_type_trans(skb, netdev);
 			netif_rx(skb);
+			/* exclude CRC size */
+			netdev->stats.rx_bytes += frame_hdr->len - 4;
+			netdev->stats.rx_packets++;
 		} else {
-			pr_err("%s: err:skb alloc\n", __func__);
 			ks_wrreg16(ks, KS_RXQCR, (ks->rc_rxqcr | RXQCR_RRXEF));
-			if (skb)
-				dev_kfree_skb_irq(skb);
+			netdev->stats.rx_dropped++;
 		}
 		frame_hdr++;
 	}
@@ -877,6 +892,8 @@ static irqreturn_t ks_irq(int irq, void *pw)
 		ks_wrreg16(ks, KS_PMECR, pmecr | PMECR_WKEVT_LINK);
 	}
 
+	if (unlikely(status & IRQ_RXOI))
+		ks->netdev->stats.rx_over_errors++;
 	/* this should be the last in IRQ handler*/
 	ks_restore_cmd_reg(ks);
 	return IRQ_HANDLED;
@@ -1015,6 +1032,9 @@ static int ks_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	if (likely(ks_tx_fifo_space(ks) >= skb->len + 12)) {
 		ks_write_qmu(ks, skb->data, skb->len);
+		/* add tx statistics */
+		netdev->stats.tx_bytes += skb->len;
+		netdev->stats.tx_packets++;
 		dev_kfree_skb(skb);
 	} else
 		retv = NETDEV_TX_BUSY;
-- 
1.7.11.7
