From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2] net: Correctly sync addresses from multiple sources to single device
Date: Wed, 22 Jan 2014 12:54:15 -0500
Message-ID: <1390413255-32223-1-git-send-email-vyasevic@redhat.com>
References: <52DFD32D.4060805@oktetlabs.ru>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <Konstantin.Ushakov@oktetlabs.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311AbaAVRys (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 12:54:48 -0500
In-Reply-To: <52DFD32D.4060805@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we have multiple devices attempting to sync the same address
to a single destination, each device should be permitted to sync
it once.  To accomplish this, pass the 'sync_cnt' of the source
address when adding the addresss to the lower device.  'sync_cnt'
tracks how many time a given address has been succefully synced.
This way, we know that if the 'sync_cnt' passed in is 0, we should
sync this address.

Also, turn 'synced' member back into the counter as was originally
done in
   commit 4543fbefe6e06a9e40d9f2b28d688393a299f079.
   net: count hw_addr syncs so that unsync works properly.
It tracks how many time a given address has been added via a
'sync' operation.  For every successfull 'sync' the counter is
incremented, and for ever 'unsync', the counter is decremented.
This makes sure that the address will be properly removed from
the the lower device when all the upper devices have removed it.

Reported-by: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
CC: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
CC: Alexandra N. Kossovsky <Alexandra.Kossovsky@oktetlabs.ru>
CC: Konstantin Ushakov <Konstantin.Ushakov@oktetlabs.ru>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/core/dev_addr_lists.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index ec40a84..9974f48 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -38,7 +38,7 @@ static int __hw_addr_create_ex(struct netdev_hw_addr_list *list,
 	ha->type = addr_type;
 	ha->refcount = 1;
 	ha->global_use = global;
-	ha->synced = sync;
+	ha->synced = sync ? 1 : 0;
 	ha->sync_cnt = 0;
 	list_add_tail_rcu(&ha->list, &list->list);
 	list->count++;
@@ -48,7 +48,8 @@ static int __hw_addr_create_ex(struct netdev_hw_addr_list *list,
 
 static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
 			    const unsigned char *addr, int addr_len,
-			    unsigned char addr_type, bool global, bool sync)
+			    unsigned char addr_type, bool global, bool sync,
+			    int sync_count)
 {
 	struct netdev_hw_addr *ha;
 
@@ -66,10 +67,10 @@ static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
 					ha->global_use = true;
 			}
 			if (sync) {
-				if (ha->synced)
+				if (ha->synced && sync_count)
 					return -EEXIST;
 				else
-					ha->synced = true;
+					ha->synced++;
 			}
 			ha->refcount++;
 			return 0;
@@ -84,7 +85,8 @@ static int __hw_addr_add(struct netdev_hw_addr_list *list,
 			 const unsigned char *addr, int addr_len,
 			 unsigned char addr_type)
 {
-	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false, false);
+	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false, false,
+				0);
 }
 
 static int __hw_addr_del_entry(struct netdev_hw_addr_list *list,
@@ -101,7 +103,7 @@ static int __hw_addr_del_entry(struct netdev_hw_addr_list *list,
 		ha->global_use = false;
 
 	if (sync)
-		ha->synced = false;
+		ha->synced--;
 
 	if (--ha->refcount)
 		return 0;
@@ -139,7 +141,7 @@ static int __hw_addr_sync_one(struct netdev_hw_addr_list *to_list,
 	int err;
 
 	err = __hw_addr_add_ex(to_list, ha->addr, addr_len, ha->type,
-			       false, true);
+			       false, true, ha->sync_cnt);
 	if (err && err != -EEXIST)
 		return err;
 
@@ -676,7 +678,7 @@ static int __dev_mc_add(struct net_device *dev, const unsigned char *addr,
 
 	netif_addr_lock_bh(dev);
 	err = __hw_addr_add_ex(&dev->mc, addr, dev->addr_len,
-			       NETDEV_HW_ADDR_T_MULTICAST, global, false);
+			       NETDEV_HW_ADDR_T_MULTICAST, global, false, 0);
 	if (!err)
 		__dev_set_rx_mode(dev);
 	netif_addr_unlock_bh(dev);
-- 
1.8.4.2
