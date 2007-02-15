From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock
Date: Thu, 15 Feb 2007 23:37:44 +0100
Message-ID: <20070215223744.GC19840@electric-eye.fr.zoreil.com>
References: <20070214132729.479793ac@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59165 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161604AbXBOWph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 17:45:37 -0500
Content-Disposition: inline
In-Reply-To: <20070214132729.479793ac@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Your usual dont-flush_scheduled_work-with-RTNL-held stuff.

It is a bit different here since the thread runs permanently
or is only occasionally kicked for recovery depending on the
hardware revision.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/8139too.c |   40 +++++++++++++++++-----------------------
 1 files changed, 17 insertions(+), 23 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 35ad5cf..99304b2 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1109,6 +1109,8 @@ static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
 
 	assert (dev != NULL);
 
+	flush_scheduled_work();
+
 	unregister_netdev (dev);
 
 	__rtl8139_cleanup_dev (dev);
@@ -1603,18 +1605,21 @@ static void rtl8139_thread (struct work_struct *work)
 	struct net_device *dev = tp->mii.dev;
 	unsigned long thr_delay = next_tick;
 
+	rtnl_lock();
+
+	if (!netif_running(dev))
+		goto out_unlock;
+
 	if (tp->watchdog_fired) {
 		tp->watchdog_fired = 0;
 		rtl8139_tx_timeout_task(work);
-	} else if (rtnl_trylock()) {
-		rtl8139_thread_iter (dev, tp, tp->mmio_addr);
-		rtnl_unlock ();
-	} else {
-		/* unlikely race.  mitigate with fast poll. */
-		thr_delay = HZ / 2;
-	}
+	} else
+		rtl8139_thread_iter(dev, tp, tp->mmio_addr);
 
-	schedule_delayed_work(&tp->thread, thr_delay);
+	if (tp->have_thread)
+		schedule_delayed_work(&tp->thread, thr_delay);
+out_unlock:
+	rtnl_unlock ();
 }
 
 static void rtl8139_start_thread(struct rtl8139_private *tp)
@@ -1626,19 +1631,11 @@ static void rtl8139_start_thread(struct rtl8139_private *tp)
 		return;
 
 	tp->have_thread = 1;
+	tp->watchdog_fired = 0;
 
 	schedule_delayed_work(&tp->thread, next_tick);
 }
 
-static void rtl8139_stop_thread(struct rtl8139_private *tp)
-{
-	if (tp->have_thread) {
-		cancel_rearming_delayed_work(&tp->thread);
-		tp->have_thread = 0;
-	} else
-		flush_scheduled_work();
-}
-
 static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
 {
 	tp->cur_tx = 0;
@@ -1696,12 +1693,11 @@ static void rtl8139_tx_timeout (struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 
+	tp->watchdog_fired = 1;
 	if (!tp->have_thread) {
-		INIT_DELAYED_WORK(&tp->thread, rtl8139_tx_timeout_task);
+		INIT_DELAYED_WORK(&tp->thread, rtl8139_thread);
 		schedule_delayed_work(&tp->thread, next_tick);
-	} else
-		tp->watchdog_fired = 1;
-
+	}
 }
 
 static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
@@ -2233,8 +2229,6 @@ static int rtl8139_close (struct net_device *dev)
 
 	netif_stop_queue (dev);
 
-	rtl8139_stop_thread(tp);
-
 	if (netif_msg_ifdown(tp))
 		printk(KERN_DEBUG "%s: Shutting down ethercard, status was 0x%4.4x.\n",
 			dev->name, RTL_R16 (IntrStatus));
-- 
1.4.4.4

