From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] macvlan: remove one synchronize_rcu() call
Date: Fri, 20 May 2011 00:24:16 +0200
Message-ID: <1305843856.3156.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56472 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab1ESWYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:24:21 -0400
Received: by wya21 with SMTP id 21so2325349wya.19
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:24:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When one macvlan device is dismantled, we can avoid one
synchronize_rcu() call done after deletion from hash list, since caller
will perform a synchronize_net() call after its ndo_stop() call.

Add a new netdev->dismantle field to signal this dismantle intent.

Reduces RTNL hold time.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Ben Greear <greearb@candelatech.com>
---
 drivers/net/macvlan.c     |    9 +++++----
 include/linux/netdevice.h |    4 +++-
 net/core/dev.c            |    2 +-
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d7c0bc62..07bcb80 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -70,16 +70,17 @@ static void macvlan_hash_add(struct macvlan_dev *vlan)
 	hlist_add_head_rcu(&vlan->hlist, &port->vlan_hash[addr[5]]);
 }
 
-static void macvlan_hash_del(struct macvlan_dev *vlan)
+static void macvlan_hash_del(struct macvlan_dev *vlan, bool sync)
 {
 	hlist_del_rcu(&vlan->hlist);
-	synchronize_rcu();
+	if (sync)
+		synchronize_rcu();
 }
 
 static void macvlan_hash_change_addr(struct macvlan_dev *vlan,
 					const unsigned char *addr)
 {
-	macvlan_hash_del(vlan);
+	macvlan_hash_del(vlan, true);
 	/* Now that we are unhashed it is safe to change the device
 	 * address without confusing packet delivery.
 	 */
@@ -345,7 +346,7 @@ static int macvlan_stop(struct net_device *dev)
 	dev_uc_del(lowerdev, dev->dev_addr);
 
 hash_del:
-	macvlan_hash_del(vlan);
+	macvlan_hash_del(vlan, !dev->dismantle);
 	return 0;
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a134d80..ca333e7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1293,7 +1293,9 @@ struct net_device {
 	       NETREG_UNREGISTERED,	/* completed unregister todo */
 	       NETREG_RELEASED,		/* called free_netdev */
 	       NETREG_DUMMY,		/* dummy device for NAPI poll */
-	} reg_state:16;
+	} reg_state:8;
+
+	bool dismantle; /* device is going do be freed */
 
 	enum {
 		RTNL_LINK_INITIALIZED,
diff --git a/net/core/dev.c b/net/core/dev.c
index 155de20..d945379 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5126,7 +5126,7 @@ static void rollback_registered_many(struct list_head *head)
 			list_del(&dev->unreg_list);
 			continue;
 		}
-
+		dev->dismantle = true;
 		BUG_ON(dev->reg_state != NETREG_REGISTERED);
 	}
 


