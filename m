From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 1/2] 8139too: Rx fifo/overflow recovery
Date: Sun, 22 Aug 2004 23:42:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040822214208.GA30478@electric-eye.fr.zoreil.com>
References: <20040822213954.GA29997@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040822213954.GA29997@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch allows to update the interrupt status register after an 
Rx overflow or a Rx fifo error even when the Rx buffer contains no packet.
The update must be kept in the packet processing loop to prevent an Rx
error storm. As an interesting behavior, the status of the interrupt status
register must not be read early.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/8139too.c~8139too-10 drivers/net/8139too.c
--- linux-2.6.8.1/drivers/net/8139too.c~8139too-10	2004-08-22 23:25:16.000000000 +0200
+++ linux-2.6.8.1-romieu/drivers/net/8139too.c	2004-08-22 23:25:16.000000000 +0200
@@ -1927,6 +1927,24 @@ static __inline__ void wrap_copy(struct 
 }
 #endif
 
+static void rtl8139_isr_ack(struct rtl8139_private *tp)
+{
+	void *ioaddr = tp->mmio_addr;
+	u16 status;
+
+	status = RTL_R16 (IntrStatus) & RxAckBits;
+
+	/* Clear out errors and receive interrupts */
+	if (likely(status != 0)) {
+		if (unlikely(status & (RxFIFOOver | RxOverflow))) {
+			tp->stats.rx_errors++;
+			if (status & RxFIFOOver)
+				tp->stats.rx_fifo_errors++;
+		}
+		RTL_W16_F (IntrStatus, RxAckBits);
+	}
+}
+
 static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		      int budget)
 {
@@ -1934,6 +1952,7 @@ static int rtl8139_rx(struct net_device 
 	int received = 0;
 	unsigned char *rx_ring = tp->rx_ring;
 	unsigned int cur_rx = tp->cur_rx;
+	unsigned int rx_size = 0;
 
 	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
@@ -1944,10 +1963,8 @@ static int rtl8139_rx(struct net_device 
 	       && (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
 		u32 ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
-		unsigned int rx_size;
 		unsigned int pkt_size;
 		struct sk_buff *skb;
-		u16 status;
 
 		rmb();
 
@@ -1977,7 +1994,7 @@ static int rtl8139_rx(struct net_device 
 		 */
 		if (unlikely(rx_size == 0xfff0)) {
 			tp->xstats.early_rx++;
-			goto done;
+			break;
 		}
 
 		/* If Rx err or invalid rx_size/rx_status received
@@ -1989,7 +2006,8 @@ static int rtl8139_rx(struct net_device 
 			     (rx_size < 8) ||
 			     (!(rx_status & RxStatusOK)))) {
 			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
-			return -1;
+			received = -1;
+			goto out;
 		}
 
 		/* Malloc up new buffer, compatible with net-2e. */
@@ -2025,19 +2043,11 @@ static int rtl8139_rx(struct net_device 
 		cur_rx = (cur_rx + rx_size + 4 + 3) & ~3;
 		RTL_W16 (RxBufPtr, (u16) (cur_rx - 16));
 
-		/* Clear out errors and receive interrupts */
-		status = RTL_R16 (IntrStatus) & RxAckBits;
-		if (likely(status != 0)) {
-			if (unlikely(status & (RxFIFOOver | RxOverflow))) {
-				tp->stats.rx_errors++;
-				if (status & RxFIFOOver)
-					tp->stats.rx_fifo_errors++;
-			}
-			RTL_W16_F (IntrStatus, RxAckBits);
-		}
+		rtl8139_isr_ack(tp);
 	}
 
- done:
+	if (unlikely(!received || rx_size == 0xfff0))
+		rtl8139_isr_ack(tp);
 
 #if RTL8139_DEBUG > 1
 	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
@@ -2047,6 +2057,7 @@ static int rtl8139_rx(struct net_device 
 #endif
 
 	tp->cur_rx = cur_rx;
+out:
 	return received;
 }
 

_
