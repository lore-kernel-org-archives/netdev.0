From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8-rc3-mm1 1/2] 8139too: Rx fifo/overflow recovery
Date: Thu, 5 Aug 2004 23:43:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040805234336.A15407@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Pasi Sjoholm <ptsjohol@cc.jyu.fi>,
        Hector Martin <hector@marcansoft.com>,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch allows to update the interrupt status register after an 
Rx overflow or a Rx fifo error even when the Rx buffer contains no packet.
As a side effect it saves a few heavy (i.e. flushed) pci ops per received
packet when several packets are received at the same time.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/8139too.c~r8139-10 drivers/net/8139too.c
--- linux-2.6.8-rc3/drivers/net/8139too.c~r8139-10	2004-08-05 23:09:26.000000000 +0200
+++ linux-2.6.8-rc3-romieu/drivers/net/8139too.c	2004-08-05 23:14:31.000000000 +0200
@@ -1934,12 +1934,15 @@ static int rtl8139_rx(struct net_device 
 	int received = 0;
 	unsigned char *rx_ring = tp->rx_ring;
 	unsigned int cur_rx = tp->cur_rx;
+	u16 status;
 
 	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
+	status = RTL_R16 (IntrStatus) & RxAckBits;
+
 	while (netif_running(dev) && received < budget 
 	       && (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
 		u32 ring_offset = cur_rx % RX_BUF_LEN;
@@ -1947,7 +1950,6 @@ static int rtl8139_rx(struct net_device 
 		unsigned int rx_size;
 		unsigned int pkt_size;
 		struct sk_buff *skb;
-		u16 status;
 
 		rmb();
 
@@ -1977,7 +1979,7 @@ static int rtl8139_rx(struct net_device 
 		 */
 		if (unlikely(rx_size == 0xfff0)) {
 			tp->xstats.early_rx++;
-			goto done;
+			break;
 		}
 
 		/* If Rx err or invalid rx_size/rx_status received
@@ -1989,7 +1991,8 @@ static int rtl8139_rx(struct net_device 
 			     (rx_size < 8) ||
 			     (!(rx_status & RxStatusOK)))) {
 			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
-			return -1;
+			received = -1;
+			goto out;
 		}
 
 		/* Malloc up new buffer, compatible with net-2e. */
@@ -2024,21 +2027,18 @@ static int rtl8139_rx(struct net_device 
 
 		cur_rx = (cur_rx + rx_size + 4 + 3) & ~3;
 		RTL_W16 (RxBufPtr, (u16) (cur_rx - 16));
+	}
 
-		/* Clear out errors and receive interrupts */
-		status = RTL_R16 (IntrStatus) & RxAckBits;
-		if (likely(status != 0)) {
-			if (unlikely(status & (RxFIFOOver | RxOverflow))) {
-				tp->stats.rx_errors++;
-				if (status & RxFIFOOver)
-					tp->stats.rx_fifo_errors++;
-			}
-			RTL_W16_F (IntrStatus, RxAckBits);
+	/* Clear out errors and receive interrupts */
+	if (likely(status != 0)) {
+		if (unlikely(status & (RxFIFOOver | RxOverflow))) {
+			tp->stats.rx_errors++;
+			if (status & RxFIFOOver)
+				tp->stats.rx_fifo_errors++;
 		}
+		RTL_W16_F (IntrStatus, RxAckBits);
 	}
 
- done:
-
 #if RTL8139_DEBUG > 1
 	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
@@ -2047,6 +2047,7 @@ static int rtl8139_rx(struct net_device 
 #endif
 
 	tp->cur_rx = cur_rx;
+out:
 	return received;
 }
 

_
