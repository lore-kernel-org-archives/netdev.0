From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/16] batman-adv: don't use call_rcu if not needed
Date: Sun, 13 Oct 2013 13:22:49 +0200
Message-ID: <1381663381-626-5-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:19730 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370Ab3JMLYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:24:21 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

batadv_tt_global_entry_free_ref uses call_rcu to schedule a
function which will only free the global entry itself.

For this reason call_rcu is useless and kfree_rcu can be
used to simplify the code.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index b3c4369..34fa6cc 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -117,25 +117,17 @@ batadv_tt_local_entry_free_ref(struct batadv_tt_local_entry *tt_local_entry)
 		kfree_rcu(tt_local_entry, common.rcu);
 }
 
-static void batadv_tt_global_entry_free_rcu(struct rcu_head *rcu)
-{
-	struct batadv_tt_common_entry *tt_common_entry;
-	struct batadv_tt_global_entry *tt_global_entry;
-
-	tt_common_entry = container_of(rcu, struct batadv_tt_common_entry, rcu);
-	tt_global_entry = container_of(tt_common_entry,
-				       struct batadv_tt_global_entry, common);
-
-	kfree(tt_global_entry);
-}
-
+/**
+ * batadv_tt_global_entry_free_ref - decrement the refcounter for a
+ *  tt_global_entry and possibly free it
+ * @tt_global_entry: the object to free
+ */
 static void
 batadv_tt_global_entry_free_ref(struct batadv_tt_global_entry *tt_global_entry)
 {
 	if (atomic_dec_and_test(&tt_global_entry->common.refcount)) {
 		batadv_tt_global_del_orig_list(tt_global_entry);
-		call_rcu(&tt_global_entry->common.rcu,
-			 batadv_tt_global_entry_free_rcu);
+		kfree_rcu(tt_global_entry, common.rcu);
 	}
 }
 
-- 
1.8.3.2
