From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/6] netpoll: Move rx enable/disable into __dev_close_many
Date: Mon, 17 Mar 2014 23:26:41 -0700
Message-ID: <87r460f2e6.fsf_-_@xmission.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58413 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaCRG0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 02:26:49 -0400
In-Reply-To: <87iorcgh5d.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 17 Mar 2014 23:22:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Today netpoll_rx_enable and netpoll_rx_disable are called
from dev_close and and __dev_close, and not from dev_close_many.

That is too many call sites for a simple operations.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/dev.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 55f8e64c03a2..f660448d992d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1313,6 +1313,9 @@ static int __dev_close_many(struct list_head *head)
 	might_sleep();
 
 	list_for_each_entry(dev, head, close_list) {
+		/* Temporarily disable netpoll until the interface is down */
+		netpoll_rx_disable(dev);
+
 		call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
 
 		clear_bit(__LINK_STATE_START, &dev->state);
@@ -1343,6 +1346,7 @@ static int __dev_close_many(struct list_head *head)
 
 		dev->flags &= ~IFF_UP;
 		net_dmaengine_put();
+		netpoll_rx_enable(dev);
 	}
 
 	return 0;
@@ -1353,14 +1357,10 @@ static int __dev_close(struct net_device *dev)
 	int retval;
 	LIST_HEAD(single);
 
-	/* Temporarily disable netpoll until the interface is down */
-	netpoll_rx_disable(dev);
-
 	list_add(&dev->close_list, &single);
 	retval = __dev_close_many(&single);
 	list_del(&single);
 
-	netpoll_rx_enable(dev);
 	return retval;
 }
 
@@ -1398,14 +1398,9 @@ int dev_close(struct net_device *dev)
 	if (dev->flags & IFF_UP) {
 		LIST_HEAD(single);
 
-		/* Block netpoll rx while the interface is going down */
-		netpoll_rx_disable(dev);
-
 		list_add(&dev->close_list, &single);
 		dev_close_many(&single);
 		list_del(&single);
-
-		netpoll_rx_enable(dev);
 	}
 	return 0;
 }
-- 
1.7.5.4
