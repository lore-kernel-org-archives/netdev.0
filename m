From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] net: count hw_addr syncs so that unsync works properly.
Date: Tue,  2 Apr 2013 17:10:07 -0400
Message-ID: <1364937007-23894-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761127Ab3DBVlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 17:41:05 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32LAEhm024428
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 2 Apr 2013 17:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few drivers use dev_uc_sync/unsync to synchronize the
address lists from master down to slave/lower devices.  In
some cases (bond/team) a single address list is synched down
to multiple devices.  At the time of unsync, we have a leak
in these lower devices, because "synced" is treated as a
boolean and the address will not be unsynced for anything after
the fist device/call.

Treat "synced" as a count (same as refcount) and allow all
unsync calls to work.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h | 2 +-
 net/core/dev_addr_lists.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8bfa956..6151e90 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -210,9 +210,9 @@ struct netdev_hw_addr {
 #define NETDEV_HW_ADDR_T_SLAVE		3
 #define NETDEV_HW_ADDR_T_UNICAST	4
 #define NETDEV_HW_ADDR_T_MULTICAST	5
-	bool			synced;
 	bool			global_use;
 	int			refcount;
+	int			synced;
 	struct rcu_head		rcu_head;
 };
 
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index bd2eb9d..abdc9e6 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -37,7 +37,7 @@ static int __hw_addr_create_ex(struct netdev_hw_addr_list *list,
 	ha->type = addr_type;
 	ha->refcount = 1;
 	ha->global_use = global;
-	ha->synced = false;
+	ha->synced = 0;
 	list_add_tail_rcu(&ha->list, &list->list);
 	list->count++;
 
@@ -165,7 +165,7 @@ int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
 					    addr_len, ha->type);
 			if (err)
 				break;
-			ha->synced = true;
+			ha->synced++;
 			ha->refcount++;
 		} else if (ha->refcount == 1) {
 			__hw_addr_del(to_list, ha->addr, addr_len, ha->type);
@@ -186,7 +186,7 @@ void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
 		if (ha->synced) {
 			__hw_addr_del(to_list, ha->addr,
 				      addr_len, ha->type);
-			ha->synced = false;
+			ha->synced--;
 			__hw_addr_del(from_list, ha->addr,
 				      addr_len, ha->type);
 		}
-- 
1.8.1.4
