From: Ben Greear <greearb@candelatech.com>
Subject: [Fwd: [PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock]
Date: Thu, 05 Apr 2007 22:52:12 -0700
Message-ID: <4615E00C.9070406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: gregkh@suse.de, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:41698 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709AbXDFFwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 01:52:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please consider this for the 2.6.20 stable branch.  This fixes a 
deadlock between the
bridging code and the 8139too driver.  I am not the author of this 
patch, but I have
tested a slightly modified version (so that it works with the 2.6.18 
kernel) extensively
and it solves the deadlock.  Mr. Romieu suggested I forward this to you...

Thanks,
Ben

-------- Original Message --------
Subject: 	[PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock
Date: 	Thu, 15 Feb 2007 23:37:44 +0100
From: 	Francois Romieu <romieu@fr.zoreil.com>
To: 	jeff@garzik.org
CC: 	Stephen Hemminger <shemminger@linux-foundation.org>, 
akpm@linux-foundation.org, netdev@vger.kernel.org, Ben Greear 
<greearb@candelatech.com>, Kyle Lucke <klucke@us.ibm.com>, Raghavendra 
Koushik <raghavendra.koushik@neterion.com>, Al Viro <viro@ftp.linux.org.uk>



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

-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


