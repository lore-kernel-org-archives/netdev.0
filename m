From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] [rft] Re: of 2.6.2-rc2-mm2 and r8169
Date: Tue, 10 Feb 2004 00:57:18 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040210005718.A10307@electric-eye.fr.zoreil.com>
References: <20040130014108.09c964fd.akpm@osdl.org> <20040201100340.GA12436@neuffer.info> <20040207001756.A26645@electric-eye.fr.zoreil.com> <20040207115054.GC5704@neuffer.info> <20040207132124.A7344@electric-eye.fr.zoreil.com> <20040208064859.GA29384@neuffer.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Neuffer <neuffer@neuffer.info>
Content-Disposition: inline
In-Reply-To: <20040208064859.GA29384@neuffer.info>; from neuffer@neuffer.info on Sun, Feb 08, 2004 at 07:48:59AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch below compiles but I don't know if it will apply against
current -mm. Complain if it's broken and I'll clean it once I have got some
sleep.

Idea behind the change: assume that there is no invocation of the r8169 irq
handler while the asic fills all the available rx buffers. When it is
finally called, the rx irq handler will not be stopped by a descriptor
which is owned by the r8169 asic. The skb refill logic is only called once
the handler has stopped looping over the ring and the rx handler will happily
process skb entries that were just NULLed -> Oops

--- drivers/net/r8169.c	2004-02-10 00:20:48.000000000 +0100
+++ drivers/net/r8169.c	2004-02-10 00:26:18.000000000 +0100
@@ -1471,17 +1471,20 @@ static void
 rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 		     void *ioaddr)
 {
-	int cur_rx, delta;
+	int delta, rx_left;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
 	assert(ioaddr != NULL);
 
-	cur_rx = tp->cur_rx % NUM_RX_DESC;
+	rx_left = tp->cur_rx - tp->dirty_rx;
 
-	while (!(le32_to_cpu(tp->RxDescArray[cur_rx].status) & OWNbit)) {
+	while (rx_left > 0) {
+		int cur_rx = tp->cur_rx % NUM_RX_DESC;
 		u32 status = le32_to_cpu(tp->RxDescArray[cur_rx].status);
 
+		if (status & OWNbit)
+			break;
 		if (status & RxRES) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
 			tp->stats.rx_errors++;
@@ -1517,7 +1520,7 @@ rtl8169_rx_interrupt(struct net_device *
 		}
 		
 		tp->cur_rx++; 
-		cur_rx = tp->cur_rx % NUM_RX_DESC;
+		rx_left--;
 	}
 
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
