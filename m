From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH 1/1] net: macb: fix the RX queue reset in macb_rx()
Date: Fri, 25 Nov 2016 09:49:32 +0100
Message-ID: <fd8131cbe6c0546b2b8ee35bcaac5e7eb1a1647f.1480063339.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Andrei.Pistirica@microchip.com>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <soren.brinkmann@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:20117 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752985AbcKYItw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 03:49:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On macb only (not gem), when a RX queue corruption was detected from
macb_rx(), the RX queue was reset: during this process the RX ring
buffer descriptor was initialized by macb_init_rx_ring() but we forgot
to also set bp->rx_tail to 0.

Indeed, when processing the received frames, bp->rx_tail provides the
macb driver with the index in the RX ring buffer of the next buffer to
process. So when the whole ring buffer is reset we must also reset
bp->rx_tail so the driver is synchronized again with the hardware.

Since macb_init_rx_ring() is called from many locations, currently from
macb_rx() and macb_init_rings(), we'd rather add the "bp->rx_tail = 0;"
line inside macb_init_rx_ring() than add the very same line after each
call of this function.

Without this fix, the rx queue is not reset properly to recover from
queue corruption and connection drop may occur.

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Fixes: 9ba723b081a2 ("net: macb: remove BUG_ON() and reset the queue to handle RX errors")
---
 drivers/net/ethernet/cadence/macb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 0e489bb82456..8ee303b8da08 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -991,6 +991,7 @@ static inline void macb_init_rx_ring(struct macb *bp)
 		addr += bp->rx_buffer_size;
 	}
 	bp->rx_ring[bp->rx_ring_size - 1].addr |= MACB_BIT(RX_WRAP);
+	bp->rx_tail = 0;
 }
 
 static int macb_rx(struct macb *bp, int budget)
@@ -1736,8 +1737,6 @@ static void macb_init_rings(struct macb *bp)
 	bp->queues[0].tx_head = 0;
 	bp->queues[0].tx_tail = 0;
 	bp->queues[0].tx_ring[bp->tx_ring_size - 1].ctrl |= MACB_BIT(TX_WRAP);
-
-	bp->rx_tail = 0;
 }
 
 static void macb_reset_hw(struct macb *bp)
-- 
2.7.4
