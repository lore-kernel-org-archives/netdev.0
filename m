From: <gregkh@suse.de>
Subject: patch 8139too-rtnl-and-flush_scheduled_work-deadlock.patch queued to -stable tree
Date: Wed, 11 Apr 2007 11:53:03 -0700
Message-ID: <20070411185335.65C78D2F0FB@imap.suse.de>
References: <4615E00C.9070406@candelatech.com>
Cc: <stable@kernel.org>
To: romieu@fr.zoreil.com, greearb@candelatech.com, gregkh@suse.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37416 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964780AbXDKSxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 14:53:45 -0400
In-Reply-To: <4615E00C.9070406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a note to let you know that we have just queued up the patch titled

     Subject: 8139too: RTNL and flush_scheduled_work deadlock

to the 2.6.20-stable tree.  Its filename is

     8139too-rtnl-and-flush_scheduled_work-deadlock.patch

A git repo of this tree can be found at 
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary


>From greearb@candelatech.com Thu Apr  5 22:52:18 2007
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 05 Apr 2007 22:52:12 -0700
Subject: 8139too: RTNL and flush_scheduled_work deadlock
To: gregkh@suse.de, NetDev <netdev@vger.kernel.org>
Message-ID: <4615E00C.9070406@candelatech.com>

From: Francois Romieu <romieu@fr.zoreil.com>

Your usual dont-flush_scheduled_work-with-RTNL-held stuff.

It is a bit different here since the thread runs permanently
or is only occasionally kicked for recovery depending on the
hardware revision.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Ben Greear <greearb@candelatech.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

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

-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


Patches currently in stable-queue which might be from romieu@fr.zoreil.com are

