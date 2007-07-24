From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] possible deadlock in tulip driver
Date: Tue, 24 Jul 2007 11:49:08 +0400
Message-ID: <20070724074908.GA15258@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tulip-users@lists.sourceforge.net, devel@openvz.org
To: netdev@vger.kernel.org, davem@davemloft.net, val@nmt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:56628 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932217AbXGXIVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 04:21:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calling flush_scheduled_work() may deadlock if called under rtnl_lock
(from dev->stop) as linkwatch_event() may be on the workqueue and it will try
to get the rtnl_lock

Signed-off-by: Denis V. Lunev <den@openvz.org>
---

 tulip_core.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- ./drivers/net/tulip/tulip_core.c.tulip	2007-07-16 12:54:29.000000000 +0400
+++ ./drivers/net/tulip/tulip_core.c	2007-07-23 19:06:24.000000000 +0400
@@ -726,8 +726,6 @@ static void tulip_down (struct net_devic
 	void __iomem *ioaddr = tp->base_addr;
 	unsigned long flags;
 
-	flush_scheduled_work();
-
 	del_timer_sync (&tp->timer);
 #ifdef CONFIG_TULIP_NAPI
 	del_timer_sync (&tp->oom_timer);
@@ -1788,6 +1786,8 @@ static void __devexit tulip_remove_one (
 	if (!dev)
 		return;
 
+	flush_scheduled_work();
+
 	tp = netdev_priv(dev);
 	unregister_netdev(dev);
 	pci_free_consistent (pdev,
