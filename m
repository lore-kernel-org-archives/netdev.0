From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: remove synchronize_net() from
 netdev_set_master()
Date: Fri, 20 May 2011 07:37:40 +0200
Message-ID: <1305869860.3156.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jiri Pirko <jpirko@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39377 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935210Ab1ETFhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 01:37:46 -0400
Received: by wya21 with SMTP id 21so2461207wya.19
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 22:37:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the old days, we used to access dev->master in __netif_receive_skb()
in a rcu_read_lock section.

So one synchronize_net() call was needed in netdev_set_master() to make
sure another cpu could not use old master while/after we release it.

We now use netdev_rx_handler infrastructure and added one
synchronize_net() call in bond_release()/bond_release_all()

Remove the obsolete synchronize_net() from netdev_set_master() and add
one in bridge del_nbp() after its netdev_rx_handler_unregister() call.

This makes enslave -d a bit faster.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jiri Pirko <jpirko@redhat.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 net/bridge/br_if.c |    1 +
 net/core/dev.c     |    4 +---
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 5dbdfdf..3e18d14 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -147,6 +147,7 @@ static void del_nbp(struct net_bridge_port *p)
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
 	netdev_rx_handler_unregister(dev);
+	synchronize_net();
 
 	netdev_set_master(dev, NULL);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 155de20..29b3f7a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4294,10 +4294,8 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 
 	slave->master = master;
 
-	if (old) {
-		synchronize_net();
+	if (old)
 		dev_put(old);
-	}
 	return 0;
 }
 EXPORT_SYMBOL(netdev_set_master);


