From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] net: Correctly sync addresses from multiple sources to single device
Date: Fri, 17 Jan 2014 14:52:12 -0500
Message-ID: <1389988332-22472-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752805AbaAQTwf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 14:52:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we have multiple devices attempting to sync the same address
to a single destination, each device should be permitted to sync
it once.  To accomplish this, pass the sync count of the source
address to __hw_addr_add_ex().  'sync_cnt' tracks how many time
a given address has been successfully synced.  If the address
is found in the destination list, but the 'sync_cnt' of the source
is 0, then this address has not been synced from this interface
and we need to allow the sync operation to succeed thus incrementing
reference counts.

Reported-by: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
CC: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/core/dev_addr_lists.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index ec40a84..bd1b880 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -48,7 +48,8 @@ static int __hw_addr_create_ex(struct netdev_hw_addr_list *list,
 
 static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
 			    const unsigned char *addr, int addr_len,
-			    unsigned char addr_type, bool global, bool sync)
+			    unsigned char addr_type, bool global, bool sync,
+			    int sync_count)
 {
 	struct netdev_hw_addr *ha;
 
@@ -66,7 +67,7 @@ static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
 					ha->global_use = true;
 			}
 			if (sync) {
-				if (ha->synced)
+				if (ha->synced && sync_count)
 					return -EEXIST;
 				else
 					ha->synced = true;
@@ -84,7 +85,8 @@ static int __hw_addr_add(struct netdev_hw_addr_list *list,
 			 const unsigned char *addr, int addr_len,
 			 unsigned char addr_type)
 {
-	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false, false);
+	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false, false,
+				0);
 }
 
 static int __hw_addr_del_entry(struct netdev_hw_addr_list *list,
@@ -139,7 +141,7 @@ static int __hw_addr_sync_one(struct netdev_hw_addr_list *to_list,
 	int err;
 
 	err = __hw_addr_add_ex(to_list, ha->addr, addr_len, ha->type,
-			       false, true);
+			       false, true, ha->sync_count);
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
