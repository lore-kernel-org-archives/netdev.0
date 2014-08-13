From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/4] rhashtable: fix annotations for rht_for_each_entry_rcu()
Date: Wed, 13 Aug 2014 16:38:31 +0200
Message-ID: <c5111b2af20d30e8f5da12002eb3c5d7293413e1.1407939963.git.tgraf@suug.ch>
References: <cover.1407939963.git.tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54741 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbaHMOij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 10:38:39 -0400
Received: from 77-56-195-25.dclient.hispeed.ch ([77.56.195.25] helo=lsx.localdomain)
	by bombadil.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XHZhH-00056M-64
	for netdev@vger.kernel.org; Wed, 13 Aug 2014 14:38:39 +0000
In-Reply-To: <cover.1407939963.git.tgraf@suug.ch>
In-Reply-To: <cover.1407939963.git.tgraf@suug.ch>
References: <cover.1407939963.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call rcu_deference_raw() directly from within rht_for_each_entry_rcu()
as list_for_each_entry_rcu() does.

Fixes the following sparse warnings:
net/netlink/af_netlink.c:2906:25:    expected struct rhash_head const *__mptr
net/netlink/af_netlink.c:2906:25:    got struct rhash_head [noderef] <asn:4>*<noident>

Fixes: e341694e3eb57fc ("netlink: Convert netlink_lookup() to use RCU protected hash table")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index af967c4..36826c0 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -123,11 +123,6 @@ void rhashtable_destroy(const struct rhashtable *ht);
 	typeof(ptr) __ptr = (ptr); \
 	   __ptr ? rht_entry(__ptr, type, member) : NULL; \
 })
-#define rht_entry_safe_rcu(ptr, type, member) \
-({ \
-	typeof(*ptr) __rcu *__ptr = (typeof(*ptr) __rcu __force *)ptr; \
-	__ptr ? container_of((typeof(ptr))rcu_dereference_raw(__ptr), type, member) : NULL; \
-})
 
 #define rht_next_entry_safe(pos, ht, member) \
 ({ \
@@ -204,9 +199,10 @@ void rhashtable_destroy(const struct rhashtable *ht);
  * traversal is guarded by rcu_read_lock().
  */
 #define rht_for_each_entry_rcu(pos, head, member) \
-	for (pos = rht_entry_safe_rcu(head, typeof(*(pos)), member); \
+	for (pos = rht_entry_safe(rcu_dereference_raw(head), \
+				  typeof(*(pos)), member); \
 	     pos; \
-	     pos = rht_entry_safe_rcu((pos)->member.next, \
-				      typeof(*(pos)), member))
+	     pos = rht_entry_safe(rcu_dereference_raw((pos)->member.next), \
+				  typeof(*(pos)), member))
 
 #endif /* _LINUX_RHASHTABLE_H */
-- 
1.9.3
