From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] netpoll: trapping fix/cleanup
Date: Fri, 30 Mar 2007 23:40:27 +0400
Message-ID: <200703302340.27343.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	mhuth@mvista.com, kgdb-bugreport@lists.sourceforge.net
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:3285 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752331AbXC3Tjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 15:39:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CONFIG_NETPOLL_TRAP causes the TX queue controls to be completely bypassed in
the netpoll's "trapped" mode which easily causes overflows in the drivers with
short TX queues (most notably, in 8139too with its 4-deep queue).
Make this option more sensible by only bypassing TX softirq wakeup and remove
CONFIG_NETPOLL_RX option completely since there is *no* code depending on it.

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---

 drivers/net/Kconfig       |    5 -----
 include/linux/netdevice.h |    8 +++-----
 2 files changed, 3 insertions(+), 10 deletions(-)

Index: linux-2.6/include/linux/netdevice.h
===================================================================
--- linux-2.6.orig/include/linux/netdevice.h
+++ linux-2.6/include/linux/netdevice.h
@@ -647,8 +647,10 @@ static inline void netif_start_queue(str
 static inline void netif_wake_queue(struct net_device *dev)
 {
 #ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap())
+	if (netpoll_trap()) {
+		clear_bit(__LINK_STATE_XOFF, &dev->state);
 		return;
+	}
 #endif
 	if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state))
 		__netif_schedule(dev);
@@ -656,10 +658,6 @@ static inline void netif_wake_queue(stru
 
 static inline void netif_stop_queue(struct net_device *dev)
 {
-#ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap())
-		return;
-#endif
 	set_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
Index: linux-2.6/drivers/net/Kconfig
===================================================================
--- linux-2.6.orig/drivers/net/Kconfig
+++ linux-2.6/drivers/net/Kconfig
@@ -2928,11 +2928,6 @@ endif #NETDEVICES
 config NETPOLL
 	def_bool NETCONSOLE
 
-config NETPOLL_RX
-	bool "Netpoll support for trapping incoming packets"
-	default n
-	depends on NETPOLL
-
 config NETPOLL_TRAP
 	bool "Netpoll traffic trapping"
 	default n

