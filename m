From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: net: add a core netdev->tx_dropped counter
Date: Thu, 27 Mar 2014 08:45:56 -0700
Message-ID: <1395935156.12610.295.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:43825 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755179AbaC0Pp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 11:45:58 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so3528412pde.15
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 08:45:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dropping packets in __dev_queue_xmit() when transmit queue
is stopped (NIC TX ring buffer full or BQL limit reached) currently
outputs a syslog message.

It would be better to get a precise count of such events available in
netdevice stats so that monitoring tools can have a clue.

This extends the work done in caf586e5f23ce
("net: add a core netdev->rx_dropped counter")

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Google-Bug-Id: 11288639

 include/linux/netdevice.h |    7 ++++---
 net/core/dev.c            |    2 ++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4b6d12c7b803..159c7e7945f8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1311,9 +1311,10 @@ struct net_device {
 	int			iflink;
 
 	struct net_device_stats	stats;
-	atomic_long_t		rx_dropped; /* dropped packets by core network
-					     * Do not use this in drivers.
-					     */
+
+	/* dropped packets by core network, Do not use this in drivers */
+	atomic_long_t		rx_dropped;
+	atomic_long_t		tx_dropped;
 
 #ifdef CONFIG_WIRELESS_EXT
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
diff --git a/net/core/dev.c b/net/core/dev.c
index 48dd323d5918..98ba581b89f0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2880,6 +2880,7 @@ recursion_alert:
 	rc = -ENETDOWN;
 	rcu_read_unlock_bh();
 
+	atomic_long_inc(&dev->tx_dropped);
 	kfree_skb(skb);
 	return rc;
 out:
@@ -6238,6 +6239,7 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 		netdev_stats_to_stats64(storage, &dev->stats);
 	}
 	storage->rx_dropped += atomic_long_read(&dev->rx_dropped);
+	storage->tx_dropped += atomic_long_read(&dev->tx_dropped);
 	return storage;
 }
 EXPORT_SYMBOL(dev_get_stats);
