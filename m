From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] netpoll: don't dereference NULL dev from np
Date: Mon, 11 May 2009 14:36:35 +0400
Message-ID: <4A07FFB3.70308@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17493 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbZEKKh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 06:37:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like the dev in netpoll_poll can be NULL - at lease it's 
checked at the function beginning. Thus the dev->netde_ops dereference 
looks dangerous.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index b5873bd..64f51ee 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -175,9 +175,13 @@ static void service_arp_queue(struct netpoll_info *npi)
 void netpoll_poll(struct netpoll *np)
 {
 	struct net_device *dev = np->dev;
-	const struct net_device_ops *ops = dev->netdev_ops;
+	const struct net_device_ops *ops;
+
+	if (!dev || !netif_running(dev))
+		return;
 
-	if (!dev || !netif_running(dev) || !ops->ndo_poll_controller)
+	ops = dev->netdev_ops;
+	if (!ops->ndo_poll_controller)
 		return;
 
 	/* Process pending work on NIC */
