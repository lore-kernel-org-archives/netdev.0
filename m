From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 -> 2.6.8-rc4-mm1
Date: Sat, 14 Aug 2004 21:27:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814192740.GB23427@electric-eye.fr.zoreil.com>
References: <20040814060948.GA7842@middle.of.nowhere> <20040814121533.GB18754@electric-eye.fr.zoreil.com> <20040814135606.GA6001@middle.of.nowhere> <20040814150824.GA21843@electric-eye.fr.zoreil.com> <20040814161039.GA1985@middle.of.nowhere> <20040814172835.GA23427@electric-eye.fr.zoreil.com> <20040814190140.GA1954@middle.of.nowhere>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jurriaan <thunder7@xs4all.nl>
Content-Disposition: inline
In-Reply-To: <20040814190140.GA1954@middle.of.nowhere>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Jurriaan <thunder7@xs4all.nl> :
[...]
> Indeed they do. Both with -10 and with -10+-20 added on my working
> 2.6.8-rc4-mm1 the booting process hangs somewhere while iptables is
> installing my ipv6 firewall. This is reproducable, I've not tried to
> install my firewall by hand after booting (call me paranoid).
> 
> Thus:
> 
> 2.6.8-rc4-mm1: boots, slow network
> 2.6.8-rc4-mm1 + 8139too-mm-revert: boots, fast network
> 2.6.8-rc4-mm1 + 8139too-mm-revert + 8139too-10: doesn't boot
> 2.6.8-rc4-mm1 + 8139too-mm-revert + 8139too-10 + 8139too-20: doesn't boot

Thanks. Erm... not exactly what I had expected.

Could you return to 2.6.8-rc4-mm1 + 8139too-mm-revert.patch and try each
of the three patches attached ?

I.e.:
- apply patch #1
- boot test (success/crash)
- revert patch #1
- apply patch #2
- boot test (success/crash)
- revert patch #2
- apply patch #3
- boot test (success/crash)
- revert patch #3

--
Ueimor

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="8139-a.patch"


This patch allows to update the interrupt status register after an 
Rx overflow or a Rx fifo error even when the Rx buffer contains no packet.
The update must be kept in the packet processing loop to prevent an Rx
error storm.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>


 drivers/net/8139too.c |   45 ++++++++++++++++++++++++++++++---------------
 1 files changed, 30 insertions(+), 15 deletions(-)

diff -puN drivers/net/8139too.c~8139too-10 drivers/net/8139too.c
--- linux-2.6.8-rc4/drivers/net/8139too.c~8139too-10	2004-08-12 21:37:18.000000000 +0200
+++ linux-2.6.8-rc4-fr/drivers/net/8139too.c	2004-08-12 22:10:21.000000000 +0200
@@ -1927,6 +1927,23 @@ static __inline__ void wrap_copy(struct 
 }
 #endif
 
+static void rtl8139_isr_ack(struct rtl8139_private *tp, u16 status)
+{
+	void *ioaddr = tp->mmio_addr;
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
@@ -1934,20 +1951,22 @@ static int rtl8139_rx(struct net_device 
 	int received = 0;
 	unsigned char *rx_ring = tp->rx_ring;
 	unsigned int cur_rx = tp->cur_rx;
+	unsigned int rx_size = 0;
+	u16 status = 0;
 
 	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
+	// status = RTL_R16 (IntrStatus);
+
 	while (netif_running(dev) && received < budget 
 	       && (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
 		u32 ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
-		unsigned int rx_size;
 		unsigned int pkt_size;
 		struct sk_buff *skb;
-		u16 status;
 
 		rmb();
 
@@ -1977,7 +1996,7 @@ static int rtl8139_rx(struct net_device 
 		 */
 		if (unlikely(rx_size == 0xfff0)) {
 			tp->xstats.early_rx++;
-			goto done;
+			break;
 		}
 
 		/* If Rx err or invalid rx_size/rx_status received
@@ -1989,7 +2008,8 @@ static int rtl8139_rx(struct net_device 
 			     (rx_size < 8) ||
 			     (!(rx_status & RxStatusOK)))) {
 			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
-			return -1;
+			received = -1;
+			goto out;
 		}
 
 		/* Malloc up new buffer, compatible with net-2e. */
@@ -2025,19 +2045,13 @@ static int rtl8139_rx(struct net_device 
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
+		rtl8139_isr_ack(tp, status);
+
+		status = RTL_R16 (IntrStatus);
 	}
 
- done:
+	if (unlikely(!received || rx_size == 0xfff0))
+		rtl8139_isr_ack(tp, status);
 
 #if RTL8139_DEBUG > 1
 	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
@@ -2047,6 +2061,7 @@ static int rtl8139_rx(struct net_device 
 #endif
 
 	tp->cur_rx = cur_rx;
+out:
 	return received;
 }
 

_

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="8139-b.patch"


This patch allows to update the interrupt status register after an 
Rx overflow or a Rx fifo error even when the Rx buffer contains no packet.
The update must be kept in the packet processing loop to prevent an Rx
error storm.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>


 drivers/net/8139too.c |   45 ++++++++++++++++++++++++++++++---------------
 1 files changed, 30 insertions(+), 15 deletions(-)

diff -puN drivers/net/8139too.c~8139too-10 drivers/net/8139too.c
--- linux-2.6.8-rc4/drivers/net/8139too.c~8139too-10	2004-08-12 21:37:18.000000000 +0200
+++ linux-2.6.8-rc4-fr/drivers/net/8139too.c	2004-08-12 22:10:21.000000000 +0200
@@ -1927,6 +1927,23 @@ static __inline__ void wrap_copy(struct 
 }
 #endif
 
+static void rtl8139_isr_ack(struct rtl8139_private *tp, u16 status)
+{
+	void *ioaddr = tp->mmio_addr;
+
+	status &= RxAckBits;
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
@@ -1934,20 +1951,22 @@ static int rtl8139_rx(struct net_device 
 	int received = 0;
 	unsigned char *rx_ring = tp->rx_ring;
 	unsigned int cur_rx = tp->cur_rx;
+	unsigned int rx_size = 0;
+	u16 status;
 
 	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
+	status = RTL_R16 (IntrStatus);
+
 	while (netif_running(dev) && received < budget 
 	       && (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
 		u32 ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
-		unsigned int rx_size;
 		unsigned int pkt_size;
 		struct sk_buff *skb;
-		u16 status;
 
 		rmb();
 
@@ -1977,7 +1996,7 @@ static int rtl8139_rx(struct net_device 
 		 */
 		if (unlikely(rx_size == 0xfff0)) {
 			tp->xstats.early_rx++;
-			goto done;
+			break;
 		}
 
 		/* If Rx err or invalid rx_size/rx_status received
@@ -1989,7 +2008,8 @@ static int rtl8139_rx(struct net_device 
 			     (rx_size < 8) ||
 			     (!(rx_status & RxStatusOK)))) {
 			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
-			return -1;
+			received = -1;
+			goto out;
 		}
 
 		/* Malloc up new buffer, compatible with net-2e. */
@@ -2025,19 +2045,13 @@ static int rtl8139_rx(struct net_device 
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
+		rtl8139_isr_ack(tp, status);
+
+		status = RTL_R16 (IntrStatus);
 	}
 
- done:
+	if (0)
+		rtl8139_isr_ack(tp, status);
 
 #if RTL8139_DEBUG > 1
 	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
@@ -2047,6 +2061,7 @@ static int rtl8139_rx(struct net_device 
 #endif
 
 	tp->cur_rx = cur_rx;
+out:
 	return received;
 }
 

_

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="8139-c.patch"


This patch allows to update the interrupt status register after an 
Rx overflow or a Rx fifo error even when the Rx buffer contains no packet.
The update must be kept in the packet processing loop to prevent an Rx
error storm.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>


 drivers/net/8139too.c |   45 ++++++++++++++++++++++++++++++---------------
 1 files changed, 30 insertions(+), 15 deletions(-)

diff -puN drivers/net/8139too.c~8139too-10 drivers/net/8139too.c
--- linux-2.6.8-rc4/drivers/net/8139too.c~8139too-10	2004-08-12 21:37:18.000000000 +0200
+++ linux-2.6.8-rc4-fr/drivers/net/8139too.c	2004-08-12 22:10:21.000000000 +0200
@@ -1927,6 +1927,23 @@ static __inline__ void wrap_copy(struct 
 }
 #endif
 
+static void rtl8139_isr_ack(struct rtl8139_private *tp, u16 status)
+{
+	void *ioaddr = tp->mmio_addr;
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
@@ -1934,20 +1951,22 @@ static int rtl8139_rx(struct net_device 
 	int received = 0;
 	unsigned char *rx_ring = tp->rx_ring;
 	unsigned int cur_rx = tp->cur_rx;
+	unsigned int rx_size = 0;
+	u16 status = 0;
 
 	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
+	// status = RTL_R16 (IntrStatus);
+
 	while (netif_running(dev) && received < budget 
 	       && (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {
 		u32 ring_offset = cur_rx % RX_BUF_LEN;
 		u32 rx_status;
-		unsigned int rx_size;
 		unsigned int pkt_size;
 		struct sk_buff *skb;
-		u16 status;
 
 		rmb();
 
@@ -1977,7 +1996,7 @@ static int rtl8139_rx(struct net_device 
 		 */
 		if (unlikely(rx_size == 0xfff0)) {
 			tp->xstats.early_rx++;
-			goto done;
+			break;
 		}
 
 		/* If Rx err or invalid rx_size/rx_status received
@@ -1989,7 +2008,8 @@ static int rtl8139_rx(struct net_device 
 			     (rx_size < 8) ||
 			     (!(rx_status & RxStatusOK)))) {
 			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
-			return -1;
+			received = -1;
+			goto out;
 		}
 
 		/* Malloc up new buffer, compatible with net-2e. */
@@ -2025,19 +2045,13 @@ static int rtl8139_rx(struct net_device 
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
+		rtl8139_isr_ack(tp, status);
+
+		status = RTL_R16 (IntrStatus);
 	}
 
- done:
+	if (0)
+		rtl8139_isr_ack(tp, status);
 
 #if RTL8139_DEBUG > 1
 	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
@@ -2047,6 +2061,7 @@ static int rtl8139_rx(struct net_device 
 #endif
 
 	tp->cur_rx = cur_rx;
+out:
 	return received;
 }
 

_

--gKMricLos+KVdGMg--
