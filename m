From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] get rid of warnings from 8139too driver
Date: Tue, 22 Jun 2004 13:51:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622135122.05be2be1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of sparse warnings from 8139too driver. 
	* move start_thread which was inline into the open routine (only place called).
	* handle #if constructs

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	2004-06-22 13:45:03 -07:00
+++ b/drivers/net/8139too.c	2004-06-22 13:45:03 -07:00
@@ -613,7 +613,7 @@
 static int mdio_read (struct net_device *dev, int phy_id, int location);
 static void mdio_write (struct net_device *dev, int phy_id, int location,
 			int val);
-static inline void rtl8139_start_thread(struct net_device *dev);
+static int rtl8139_thread (void *data);
 static void rtl8139_tx_timeout (struct net_device *dev);
 static void rtl8139_init_ring (struct net_device *dev);
 static int rtl8139_start_xmit (struct sk_buff *skb,
@@ -1359,7 +1359,19 @@
 			dev->irq, RTL_R8 (MediaStatus),
 			tp->mii.full_duplex ? "full" : "half");
 
-	rtl8139_start_thread(dev);
+
+	tp->thr_pid = -1;
+	tp->twistie = 0;
+	tp->time_to_die = 0;
+	if (tp->chipset == CH_8139_K)
+		tp->twistie = 1;
+	else if (!(tp->drv_flags & HAS_LNK_CHNG)) {
+		tp->thr_pid = kernel_thread(rtl8139_thread, dev, CLONE_FS|CLONE_FILES);
+		if (tp->thr_pid < 0) {
+			printk (KERN_WARNING "%s: unable to start kernel thread\n",
+				dev->name);
+		}
+	}
 
 	return 0;
 }
@@ -1643,25 +1655,6 @@
 	complete_and_exit (&tp->thr_exited, 0);
 }
 
-static inline void rtl8139_start_thread(struct net_device *dev)
-{
-	struct rtl8139_private *tp = dev->priv;
-
-	tp->thr_pid = -1;
-	tp->twistie = 0;
-	tp->time_to_die = 0;
-	if (tp->chipset == CH_8139_K)
-		tp->twistie = 1;
-	else if (tp->drv_flags & HAS_LNK_CHNG)
-		return;
-
-	tp->thr_pid = kernel_thread(rtl8139_thread, dev, CLONE_FS|CLONE_FILES);
-	if (tp->thr_pid < 0) {
-		printk (KERN_WARNING "%s: unable to start kernel thread\n",
-			dev->name);
-	}
-}
-
 static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
 {
 	tp->cur_tx = 0;
@@ -1960,7 +1953,7 @@
 			printk(KERN_DEBUG "%s:  rtl8139_rx() status %4.4x, size %4.4x,"
 				" cur %4.4x.\n", dev->name, rx_status,
 			 rx_size, cur_rx);
-#if RTL8139_DEBUG > 2
+#if defined(RTL8139_DEBUG) && RTL8139_DEBUG > 2
 		{
 			int i;
 			DPRINTK ("%s: Frame contents ", dev->name);
@@ -2039,7 +2032,7 @@
 
  done:
 
-#if RTL8139_DEBUG > 1
+#if defined(RTL8139_DEBUG) &&  RTL8139_DEBUG > 1
 	DPRINTK ("%s: Done rtl8139_rx(), current %4.4x BufAddr %4.4x,"
 		 " free to %4.4x, Cmd %2.2x.\n", dev->name, cur_rx,
 		 RTL_R16 (RxBufAddr),
