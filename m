From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.8-rc3-mm1 1/2] 8139too: Rx fifo/overflow recovery
Date: Thu, 12 Aug 2004 22:28:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040812202853.GA22774@electric-eye.fr.zoreil.com>
References: <20040805234336.A15407@electric-eye.fr.zoreil.com> <411A70CB.8060101@pobox.com> <20040811223243.GA8584@electric-eye.fr.zoreil.com> <411AA42E.50804@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nFreZHaLTZJo0R7j"
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        Hector Martin <hector@marcansoft.com>,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Content-Disposition: inline
In-Reply-To: <411AA42E.50804@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Jeff Garzik <jgarzik@pobox.com> :
[...]
> Both branches is fine.
> 
> You'll quickly hit the RX-error-requiring-reset condition if you don't 
> update on each packet, though.

M. Sjoholm, can you apply the attached patch below to a vanilla 2.6.8-rc4
and report if the former bug reappears ?

If the bug is (partially) back, 8139too-20.patch on top of -10 may help.

If you want to test against 2.6.8-rc4-mm1:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-mm-revert.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-10.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-20.patch

--
Ueimor

--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="8139too-10.patch"


This patch allows to update the interrupt status register after an 
Rx overflow or a Rx fifo error even when the Rx buffer contains no packet.
The update must be kept in the packet processing loop to prevent an Rx
error storm.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>


 drivers/net/8139too.c |   45 ++++++++++++++++++++++++++++++---------------
 1 files changed, 30 insertions(+), 15 deletions(-)

diff -puN drivers/net/8139too.c~8139too-10 drivers/net/8139too.c
--- linux-2.6.8-rc4/drivers/net/8139too.c~8139too-10	2004-08-12 21:37:18.000000000 +0200
+++ linux-2.6.8-rc4-romieu/drivers/net/8139too.c	2004-08-12 22:10:21.000000000 +0200
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

--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="8139too-20.patch"


If the Rx buffer gets corrupted or the FIFO hangs in new interesting ways,
this code prevents the driver from looping in ksoftirqd context without
making any progress.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>


 drivers/net/8139too.c |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletion(-)

diff -puN drivers/net/8139too.c~8139too-20 drivers/net/8139too.c
--- linux-2.6.8-rc4/drivers/net/8139too.c~8139too-20	2004-08-12 22:13:18.000000000 +0200
+++ linux-2.6.8-rc4-romieu/drivers/net/8139too.c	2004-08-12 22:13:18.000000000 +0200
@@ -593,6 +593,7 @@ struct rtl8139_private {
 	int time_to_die;
 	struct mii_if_info mii;
 	unsigned int regs_len;
+	unsigned long fifo_copy_timeout;
 };
 
 MODULE_AUTHOR ("Jeff Garzik <jgarzik@pobox.com>");
@@ -1955,7 +1956,7 @@ static int rtl8139_rx(struct net_device 
 	u16 status;
 
 	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
-		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
+		 " free to %4.4x, Cmd %2.2x.\n", dev->name, (u16)cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
@@ -1995,10 +1996,24 @@ static int rtl8139_rx(struct net_device 
 		 * since EarlyRx is disabled.
 		 */
 		if (unlikely(rx_size == 0xfff0)) {
+			if (!tp->fifo_copy_timeout)
+				tp->fifo_copy_timeout = jiffies + 2;
+			else if (time_after(jiffies, tp->fifo_copy_timeout)) {
+				DPRINTK ("%s: hung FIFO. Reset.", dev->name);
+				rx_size = 0;
+				goto no_early_rx;
+			}
+			if (netif_msg_intr(tp)) {
+				printk(KERN_DEBUG "%s: fifo copy in progress.",
+				       dev->name);
+			}
 			tp->xstats.early_rx++;
 			break;
 		}
 
+no_early_rx:
+		tp->fifo_copy_timeout = 0;
+
 		/* If Rx err or invalid rx_size/rx_status received
 		 * (which happens if we get lost in the ring),
 		 * Rx process gets reset, so we abort any further
@@ -2061,6 +2076,14 @@ static int rtl8139_rx(struct net_device 
 #endif
 
 	tp->cur_rx = cur_rx;
+
+	/*
+	 * The receive buffer should be mostly empty.
+	 * Tell NAPI to reenable the Rx irq.
+	 */
+	if (tp->fifo_copy_timeout)
+		received = budget;
+
 out:
 	return received;
 }

_

--nFreZHaLTZJo0R7j--
