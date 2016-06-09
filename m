From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 4/5] net: macvlan: call netdev_lockdep_set_classes()
Date: Thu,  9 Jun 2016 07:45:14 -0700
Message-ID: <1465483515-10821-5-git-send-email-edumazet@google.com>
References: <1465483515-10821-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36556 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932251AbcFIOpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 10:45:31 -0400
Received: by mail-pa0-f47.google.com with SMTP id b5so13439479pas.3
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 07:45:31 -0700 (PDT)
In-Reply-To: <1465483515-10821-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case a qdisc is used on a macvlan device, we need to use different
lockdep classes to avoid false positives.

Use the new netdev_lockdep_set_classes() generic helper.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/macvlan.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0c65bd914aed..cd9b53834bf6 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -788,7 +788,6 @@ static int macvlan_change_mtu(struct net_device *dev, int new_mtu)
  * "super class" of normal network devices; split their locks off into a
  * separate class since they always nest.
  */
-static struct lock_class_key macvlan_netdev_xmit_lock_key;
 static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define ALWAYS_ON_FEATURES \
@@ -809,20 +808,12 @@ static int macvlan_get_nest_level(struct net_device *dev)
 	return ((struct macvlan_dev *)netdev_priv(dev))->nest_level;
 }
 
-static void macvlan_set_lockdep_class_one(struct net_device *dev,
-					  struct netdev_queue *txq,
-					  void *_unused)
-{
-	lockdep_set_class(&txq->_xmit_lock,
-			  &macvlan_netdev_xmit_lock_key);
-}
-
 static void macvlan_set_lockdep_class(struct net_device *dev)
 {
+	netdev_lockdep_set_classes(dev);
 	lockdep_set_class_and_subclass(&dev->addr_list_lock,
 				       &macvlan_netdev_addr_lock_key,
 				       macvlan_get_nest_level(dev));
-	netdev_for_each_tx_queue(dev, macvlan_set_lockdep_class_one, NULL);
 }
 
 static int macvlan_init(struct net_device *dev)
-- 
2.8.0.rc3.226.g39d4020
