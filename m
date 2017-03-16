From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] bridge: resolve a false alarm of lockdep
Date: Thu, 16 Mar 2017 10:32:42 -0700
Message-ID: <1489685562-1436-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: avagin@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35013 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752140AbdCPRcy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 13:32:54 -0400
Received: by mail-pg0-f68.google.com with SMTP id g2so6795905pge.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 10:32:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrei reported a false alarm of lockdep at net/bridge/br_fdb.c:109,
this is because in Andrei's case, a spin_bug() was already triggered
before this, therefore the debug_locks is turned off, lockdep_is_held()
is no longer accurate after that. We should use lockdep_assert_held_once()
instead of lockdep_is_held() to respect debug_locks.

Reported-by: Andrei Vagin <avagin@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/bridge/br_fdb.c     | 2 +-
 net/bridge/br_private.h | 9 ---------
 2 files changed, 1 insertion(+), 10 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 4f598dc..6e08b71 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -106,7 +106,7 @@ static struct net_bridge_fdb_entry *br_fdb_find(struct net_bridge *br,
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
 
-	WARN_ON_ONCE(!br_hash_lock_held(br));
+	lockdep_assert_held_once(&br->hash_lock);
 
 	rcu_read_lock();
 	fdb = fdb_find_rcu(head, addr, vid);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2288fca..6136818 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -531,15 +531,6 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid);
 
-static inline bool br_hash_lock_held(struct net_bridge *br)
-{
-#ifdef CONFIG_LOCKDEP
-	return lockdep_is_held(&br->hash_lock);
-#else
-	return true;
-#endif
-}
-
 /* br_forward.c */
 enum br_pkt_type {
 	BR_PKT_UNICAST,
-- 
2.5.5
