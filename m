From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3]: TSO workaround fixes.
Date: Tue, 20 Feb 2007 19:50:15 -0800
Message-ID: <1172029816.3644.4.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1810 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030200AbXBUDGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 22:06:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: TSO workaround fixes.

1.  Add race condition check after netif_stop_queue().  tg3_tx() runs
    without netif_tx_lock and can race with tg3_start_xmit_dma_bug() ->
    tg3_tso_bug().

2.  Firmware TSO in 5703/5704/5705 also have the same TSO limitation,
    i.e. they cannot handle TSO headers bigger than 80 bytes.  Rename
    TG3_FL2_HW_TSO_1_BUG to TG3_FL2_TSO_BUG and set this flag on
    these chips as well.

3.  Update version to 3.74.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 81a1c2e..26c6ac4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.73"
-#define DRV_MODULE_RELDATE	"February 12, 2007"
+#define DRV_MODULE_VERSION	"3.74"
+#define DRV_MODULE_RELDATE	"February 20, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -3993,7 +3993,10 @@ static int tg3_tso_bug(struct tg3 *tp, s
 	/* Estimate the number of fragments in the worst case */
 	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
 		netif_stop_queue(tp->dev);
-		return NETDEV_TX_BUSY;
+		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))
+			return NETDEV_TX_BUSY;
+
+		netif_wake_queue(tp->dev);
 	}
 
 	segs = skb_gso_segment(skb, tp->dev->features & ~NETIF_F_TSO);
@@ -4061,7 +4064,7 @@ static int tg3_start_xmit_dma_bug(struct
 
 		hdr_len = ip_tcp_len + tcp_opt_len;
 		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
-			     (tp->tg3_flags2 & TG3_FLG2_HW_TSO_1_BUG))
+			     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
 			return (tg3_tso_bug(tp, skb));
 
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
@@ -8137,7 +8140,7 @@ static int tg3_set_ringparam(struct net_
 	    (ering->rx_jumbo_pending > TG3_RX_JUMBO_RING_SIZE - 1) ||
 	    (ering->tx_pending > TG3_TX_RING_SIZE - 1) ||
 	    (ering->tx_pending <= MAX_SKB_FRAGS) ||
-	    ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_1_BUG) &&
+	    ((tp->tg3_flags2 & TG3_FLG2_TSO_BUG) &&
 	     (ering->tx_pending <= (MAX_SKB_FRAGS * 3))))
 		return -EINVAL;
 
@@ -10557,12 +10560,11 @@ static int __devinit tg3_get_invariants(
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
 		} else {
-			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1 |
-					  TG3_FLG2_HW_TSO_1_BUG;
+			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1 | TG3_FLG2_TSO_BUG;
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
 				ASIC_REV_5750 &&
 	     		    tp->pci_chip_rev_id >= CHIPREV_ID_5750_C2)
-				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_1_BUG;
+				tp->tg3_flags2 &= ~TG3_FLG2_TSO_BUG;
 		}
 	}
 
@@ -11867,7 +11869,7 @@ static int __devinit tg3_init_one(struct
 	    (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0) {
 		tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
 	} else {
-		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
+		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE | TG3_FLG2_TSO_BUG;
 	}
 
 	/* TSO is on by default on chips that support hardware TSO.
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 45d477e..086892d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2227,7 +2227,7 @@ struct tg3 {
 #define TG3_FLAG_INIT_COMPLETE		0x80000000
 	u32				tg3_flags2;
 #define TG3_FLG2_RESTART_TIMER		0x00000001
-#define TG3_FLG2_HW_TSO_1_BUG		0x00000002
+#define TG3_FLG2_TSO_BUG		0x00000002
 #define TG3_FLG2_NO_ETH_WIRE_SPEED	0x00000004
 #define TG3_FLG2_IS_5788		0x00000008
 #define TG3_FLG2_MAX_RXPEND_64		0x00000010


