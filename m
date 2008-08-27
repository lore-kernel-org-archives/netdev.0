From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] 8139too: fix improper usage of workqueue
Date: Wed, 27 Aug 2008 08:51:26 -0700
Message-ID: <20080827085126.29e673db@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:34599 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754650AbYH0Pv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 11:51:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver was confused about how workqueue's work. It is save to
schedule multiple times, and the flag (bitfield) was unnecessary and racy.
The workqueue was never canceled either, so it is possible that the thread
could run after driver was removes [OOPS]. As a bonus, get rid the other
wasteful usage of bitfields.

Compile tested only, but based on some internal work done to fix reported
oops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/8139too.c	2008-08-27 08:30:11.000000000 -0700
+++ b/drivers/net/8139too.c	2008-08-27 08:38:18.000000000 -0700
@@ -592,9 +592,8 @@ struct rtl8139_private {
 				/* Twister tune state. */
 	char			twistie, twist_row, twist_col;
 
-	unsigned int		watchdog_fired : 1;
-	unsigned int		default_port : 4; /* Last dev->if_port value. */
-	unsigned int		have_thread : 1;
+	unsigned char		watchdog_fired;
+	unsigned char		default_port; /* Last dev->if_port value. */
 
 	spinlock_t		lock;
 	spinlock_t		rx_lock;
@@ -1614,8 +1613,7 @@ static void rtl8139_thread (struct work_
 	} else
 		rtl8139_thread_iter(dev, tp, tp->mmio_addr);
 
-	if (tp->have_thread)
-		schedule_delayed_work(&tp->thread, thr_delay);
+	schedule_delayed_work(&tp->thread, thr_delay);
 out_unlock:
 	rtnl_unlock ();
 }
@@ -1628,7 +1626,6 @@ static void rtl8139_start_thread(struct 
 	else if (tp->drv_flags & HAS_LNK_CHNG)
 		return;
 
-	tp->have_thread = 1;
 	tp->watchdog_fired = 0;
 
 	schedule_delayed_work(&tp->thread, next_tick);
@@ -1692,10 +1689,8 @@ static void rtl8139_tx_timeout (struct n
 	struct rtl8139_private *tp = netdev_priv(dev);
 
 	tp->watchdog_fired = 1;
-	if (!tp->have_thread) {
-		INIT_DELAYED_WORK(&tp->thread, rtl8139_thread);
-		schedule_delayed_work(&tp->thread, next_tick);
-	}
+
+	schedule_delayed_work(&tp->thread, next_tick);
 }
 
 static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
@@ -2217,6 +2212,8 @@ static int rtl8139_close (struct net_dev
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
+	cancel_delayed_work(&tp->thread);
+
 	netif_stop_queue(dev);
 	napi_disable(&tp->napi);
 
