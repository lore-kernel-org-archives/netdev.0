From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8-rc3-mm1 2/2] 8139too: be sure to progress durin rtl8139_rx()
Date: Thu, 5 Aug 2004 23:45:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040805234537.A16153@electric-eye.fr.zoreil.com>
References: <20040805234336.A15407@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Pasi Sjoholm <ptsjohol@cc.jyu.fi>,
        Hector Martin <hector@marcansoft.com>,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040805234336.A15407@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Thu, Aug 05, 2004 at 11:43:36PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If the Rx buffer gets corrupted or the FIFO hangs in new interesting ways,
this code prevents the driver from looping in ksoftirqd context without
making any progress.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/8139too.c~r8139-20 drivers/net/8139too.c
--- linux-2.6.8-rc3/drivers/net/8139too.c~r8139-20	2004-08-05 23:24:47.000000000 +0200
+++ linux-2.6.8-rc3-romieu/drivers/net/8139too.c	2004-08-05 23:24:47.000000000 +0200
@@ -593,6 +593,7 @@ struct rtl8139_private {
 	int time_to_die;
 	struct mii_if_info mii;
 	unsigned int regs_len;
+	unsigned long fifo_copy_timeout;
 };
 
 MODULE_AUTHOR ("Jeff Garzik <jgarzik@pobox.com>");
@@ -1937,7 +1938,7 @@ static int rtl8139_rx(struct net_device 
 	u16 status;
 
 	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
-		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
+		 " free to %4.4x, Cmd %2.2x.\n", dev->name, (u16)cur_rx,
 		 RTL_R16 (RxBufAddr),
 		 RTL_R16 (RxBufPtr), RTL_R8 (ChipCmd));
 
@@ -1978,10 +1979,24 @@ static int rtl8139_rx(struct net_device 
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
@@ -2047,6 +2062,14 @@ static int rtl8139_rx(struct net_device 
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
