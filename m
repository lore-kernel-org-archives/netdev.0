From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 1/5] rhashtable: optimize
	rhashtable_lookup routine
Date: Tue, 6 Jan 2015 15:23:19 +0800
Message-ID: <1420529003-22244-2-git-send-email-ying.xue@windriver.com>
References: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Define an internal compare function and relevant compare argument,
and then make use of rhashtable_lookup_compare() to lookup key in
hash table, reducing duplicated code between rhashtable_lookup()
and rhashtable_lookup_compare().

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c |   41 ++++++++++++++++++-----------------------
 1 file changed, 18 insertions(+), 23 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index cbad192..f2fdd7a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -612,6 +612,19 @@ restart:
 }
 EXPORT_SYMBOL_GPL(rhashtable_remove);
 
+struct rhashtable_compare_arg {
+	struct rhashtable *ht;
+	const void *key;
+};
+
+static bool rhashtable_compare(void *ptr, void *arg)
+{
+	struct rhashtable_compare_arg *x = arg;
+	struct rhashtable *ht = x->ht;
+
+	return !memcmp(ptr + ht->p.key_offset, x->key, ht->p.key_len);
+}
+
 /**
  * rhashtable_lookup - lookup key in hash table
  * @ht:		hash table
@@ -627,32 +640,14 @@ EXPORT_SYMBOL_GPL(rhashtable_remove);
  */
 void *rhashtable_lookup(struct rhashtable *ht, const void *key)
 {
-	const struct bucket_table *tbl, *old_tbl;
-	struct rhash_head *he;
-	u32 hash;
+	struct rhashtable_compare_arg arg = {
+		.ht = ht,
+		.key = key,
+	};
 
 	BUG_ON(!ht->p.key_len);
 
-	rcu_read_lock();
-	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	hash = key_hashfn(ht, key, ht->p.key_len);
-restart:
-	rht_for_each_rcu(he, tbl, rht_bucket_index(tbl, hash)) {
-		if (memcmp(rht_obj(ht, he) + ht->p.key_offset, key,
-			   ht->p.key_len))
-			continue;
-		rcu_read_unlock();
-		return rht_obj(ht, he);
-	}
-
-	if (unlikely(tbl != old_tbl)) {
-		tbl = old_tbl;
-		goto restart;
-	}
-
-	rcu_read_unlock();
-	return NULL;
+	return rhashtable_lookup_compare(ht, key, &rhashtable_compare, &arg);
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup);
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
