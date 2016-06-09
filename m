From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 5/5] net: ipvlan: call netdev_lockdep_set_classes()
Date: Thu,  9 Jun 2016 07:45:15 -0700
Message-ID: <1465483515-10821-6-git-send-email-edumazet@google.com>
References: <1465483515-10821-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33150 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932251AbcFIOpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 10:45:34 -0400
Received: by mail-pf0-f177.google.com with SMTP id y124so14135610pfy.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 07:45:34 -0700 (PDT)
In-Reply-To: <1465483515-10821-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case a qdisc is used on a ipvlan device, we need to use different
lockdep classes to avoid false positives.

Use the new netdev_lockdep_set_classes() generic helper.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 1c4d395fbd49..18b4e8c7f68a 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -80,13 +80,6 @@ static void ipvlan_port_destroy(struct net_device *dev)
 	kfree_rcu(port, rcu);
 }
 
-/* ipvlan network devices have devices nesting below it and are a special
- * "super class" of normal network devices; split their locks off into a
- * separate class since they always nest.
- */
-static struct lock_class_key ipvlan_netdev_xmit_lock_key;
-static struct lock_class_key ipvlan_netdev_addr_lock_key;
-
 #define IPVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
@@ -96,19 +89,6 @@ static struct lock_class_key ipvlan_netdev_addr_lock_key;
 #define IPVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
 
-static void ipvlan_set_lockdep_class_one(struct net_device *dev,
-					 struct netdev_queue *txq,
-					 void *_unused)
-{
-	lockdep_set_class(&txq->_xmit_lock, &ipvlan_netdev_xmit_lock_key);
-}
-
-static void ipvlan_set_lockdep_class(struct net_device *dev)
-{
-	lockdep_set_class(&dev->addr_list_lock, &ipvlan_netdev_addr_lock_key);
-	netdev_for_each_tx_queue(dev, ipvlan_set_lockdep_class_one, NULL);
-}
-
 static int ipvlan_init(struct net_device *dev)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
@@ -123,7 +103,7 @@ static int ipvlan_init(struct net_device *dev)
 	dev->gso_max_segs = phy_dev->gso_max_segs;
 	dev->hard_header_len = phy_dev->hard_header_len;
 
-	ipvlan_set_lockdep_class(dev);
+	netdev_lockdep_set_classes(dev);
 
 	ipvlan->pcpu_stats = alloc_percpu(struct ipvl_pcpu_stats);
 	if (!ipvlan->pcpu_stats)
-- 
2.8.0.rc3.226.g39d4020
