From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Thu, 15 Feb 2007 00:54:20 +0100
Message-ID: <20070214235420.GA13816@electric-eye.fr.zoreil.com>
References: <20070214132729.479793ac@freekitty> <45D382B7.9020901@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38813 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751111AbXBNX61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 18:58:27 -0500
Content-Disposition: inline
In-Reply-To: <45D382B7.9020901@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> :
[...]
> I seem to be able to trigger this within about 1 minute on a
> particular 2.6.18.2 system with some 8139too devices, so if someone
> has a patch that could be tested, I'll gladly test it.  For
> whatever reason, I haven't hit this problem on 2.6.20 yet, but
> that could easily be dumb luck, and I haven't been running .20
> very much.

Bandaid below. It is not complete if your device hits the tx_watchdog
hard but it should help.

I'll return in 24h.

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 35ad5cf..cbee350 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1603,18 +1603,20 @@ static void rtl8139_thread (struct work_struct *work)
 	struct net_device *dev = tp->mii.dev;
 	unsigned long thr_delay = next_tick;
 
+	rtnl_lock();
+
+	if (!netif_running(dev))
+		goto unlock;
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
 
 	schedule_delayed_work(&tp->thread, thr_delay);
+unlock:
+	rtnl_unlock ();
 }
 
 static void rtl8139_start_thread(struct rtl8139_private *tp)
@@ -1626,19 +1628,11 @@ static void rtl8139_start_thread(struct rtl8139_private *tp)
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
@@ -2233,8 +2227,6 @@ static int rtl8139_close (struct net_device *dev)
 
 	netif_stop_queue (dev);
 
-	rtl8139_stop_thread(tp);
-
 	if (netif_msg_ifdown(tp))
 		printk(KERN_DEBUG "%s: Shutting down ethercard, status was 0x%4.4x.\n",
 			dev->name, RTL_R16 (IntrStatus));
