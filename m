From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] 8139too: fix improper usage of workqueue
Date: Wed, 27 Aug 2008 13:16:49 -0700
Message-ID: <20080827131649.409acf91@extreme>
References: <20080827085126.29e673db@extreme>
	<20080827192656.GA27499@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:49243 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032AbYH0UQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 16:16:51 -0400
In-Reply-To: <20080827192656.GA27499@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The driver uses flush_scheduled_work() when the pci device is removed.
> 
> Where would the workqueue be scheduled after / during the removal ?

The timer can fire after removal causing workqueue to be scheduled.
flush_scheduled_work only impacts work already scheduled not delayed.

How about this (simpler) version.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/8139too.c	2008-08-27 08:30:11.000000000 -0700
+++ b/drivers/net/8139too.c	2008-08-27 13:15:06.000000000 -0700
@@ -592,9 +592,9 @@ struct rtl8139_private {
 				/* Twister tune state. */
 	char			twistie, twist_row, twist_col;
 
-	unsigned int		watchdog_fired : 1;
-	unsigned int		default_port : 4; /* Last dev->if_port value. */
-	unsigned int		have_thread : 1;
+	bool			watchdog_fired;
+	bool			have_thread;
+	u8			default_port; /* Last dev->if_port value. */
 
 	spinlock_t		lock;
 	spinlock_t		rx_lock;
@@ -1692,10 +1692,9 @@ static void rtl8139_tx_timeout (struct n
 	struct rtl8139_private *tp = netdev_priv(dev);
 
 	tp->watchdog_fired = 1;
-	if (!tp->have_thread) {
-		INIT_DELAYED_WORK(&tp->thread, rtl8139_thread);
+
+	if (!tp->have_thread)
 		schedule_delayed_work(&tp->thread, next_tick);
-	}
 }
 
 static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
@@ -2217,6 +2216,8 @@ static int rtl8139_close (struct net_dev
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
+	cancel_delayed_work(&tp->thread);
+
 	netif_stop_queue(dev);
 	napi_disable(&tp->napi);
 

