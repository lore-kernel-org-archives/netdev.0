From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH net v2 1/1] net: macb: fix the RX queue reset in macb_rx()
Date: Mon, 28 Nov 2016 14:40:55 +0100
Message-ID: <80ebb550eb6155e3b882cab1fb8d78a7385f8227.1480339901.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Andrei.Pistirica@microchip.com>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <soren.brinkmann@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:44038 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932469AbcK1NlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 08:41:14 -0500
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
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---

ChangeLog:

v1 -> v2:
- rebase on net/master (v1 was based on net-next/master)
- add "Acked-by:" tag from Nicolas Ferre.

 drivers/net/ethernet/cadence/macb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 533653bd7aec..3ede59c9cae0 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -975,6 +975,7 @@ static inline void macb_init_rx_ring(struct macb *bp)
 		addr += bp->rx_buffer_size;
 	}
 	bp->rx_ring[RX_RING_SIZE - 1].addr |= MACB_BIT(RX_WRAP);
+	bp->rx_tail = 0;
 }
 
 static int macb_rx(struct macb *bp, int budget)
@@ -1616,8 +1617,6 @@ static void macb_init_rings(struct macb *bp)
 	bp->queues[0].tx_head = 0;
 	bp->queues[0].tx_tail = 0;
 	bp->queues[0].tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
-
-	bp->rx_tail = 0;
 }
 
 static void macb_reset_hw(struct macb *bp)
-- 
2.7.4
