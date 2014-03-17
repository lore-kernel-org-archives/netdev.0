From: roy.qing.li@gmail.com
Subject: [PATCH] netpoll: send arp reply on master device immediately
Date: Mon, 17 Mar 2014 15:41:46 +0800
Message-ID: <1395042106-25179-1-git-send-email-roy.qing.li@gmail.com>
Cc: amwang@redhat.com, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54830 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932413AbaCQHly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 03:41:54 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so5393631pab.10
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 00:41:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

1. the arp queue has been moved from slave device to master, so the
master device netpoll_info should be as input of service_arp_queue()
2. not need to check if ni is NULL or not, since it has been used before.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Cc: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
---
 net/core/netpoll.c |   26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a664f78..dd0a796 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -229,21 +229,19 @@ static void netpoll_poll_dev(struct net_device *dev)
 	up(&ni->dev_lock);
 
 	if (dev->flags & IFF_SLAVE) {
-		if (ni) {
-			struct net_device *bond_dev;
-			struct sk_buff *skb;
-			struct netpoll_info *bond_ni;
-
-			bond_dev = netdev_master_upper_dev_get_rcu(dev);
-			bond_ni = rcu_dereference_bh(bond_dev->npinfo);
-			while ((skb = skb_dequeue(&ni->neigh_tx))) {
-				skb->dev = bond_dev;
-				skb_queue_tail(&bond_ni->neigh_tx, skb);
-			}
-		}
-	}
+		struct net_device *bond_dev;
+		struct sk_buff *skb;
+		struct netpoll_info *bond_ni;
 
-	service_neigh_queue(ni);
+		bond_dev = netdev_master_upper_dev_get_rcu(dev);
+		bond_ni = rcu_dereference_bh(bond_dev->npinfo);
+		while ((skb = skb_dequeue(&ni->neigh_tx))) {
+			skb->dev = bond_dev;
+			skb_queue_tail(&bond_ni->neigh_tx, skb);
+		}
+		service_neigh_queue(bond_ni);
+	} else
+		service_neigh_queue(ni);
 
 	zap_completion_queue();
 }
-- 
1.7.10.4
