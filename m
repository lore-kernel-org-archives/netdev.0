From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] net_sched: potential jiffy wrap bug in dev_watchdog
Date: Mon, 15 May 2006 16:28:58 -0700
Message-ID: <20060515162858.35eee987@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19175 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750758AbWEOX3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 19:29:03 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a potential jiffy wraparound bug in the transmit watchdog
that is easily avoided by using time_after().

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.orig/net/sched/sch_generic.c
+++ linux-2.6/net/sched/sch_generic.c
@@ -193,8 +193,10 @@ static void dev_watchdog(unsigned long a
 		    netif_running(dev) &&
 		    netif_carrier_ok(dev)) {
 			if (netif_queue_stopped(dev) &&
-			    (jiffies - dev->trans_start) > dev->watchdog_timeo) {
-				printk(KERN_INFO "NETDEV WATCHDOG: %s: transmit timed out\n", dev->name);
+			    time_after(jiffies, dev->trans_start + dev->watchdog_timeo)) {
+
+				printk(KERN_INFO "NETDEV WATCHDOG: %s: transmit timed out\n",
+				       dev->name);
 				dev->tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
