From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 4/7] rhashtable: future table
	needs to be traversed when remove an object
Date: Wed, 7 Jan 2015 13:41:55 +0800
Message-ID: <1420609318-3261-5-git-send-email-ying.xue@windriver.com>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When remove an object from hash table, we currently only traverse old
bucket table to check whether the object exists. If the object is not
found in it, we will try again. But in the second search loop, we still
search the object from the old table instead of future table. As a
result, the object may be not removed from hash table especially when
resizing is currently in progress and the object is just saved in the
future table.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 4430233..1aef942 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -608,10 +608,10 @@ restart:
 		return true;
 	}
 
-	if (tbl != rht_dereference_rcu(ht->tbl, ht)) {
+	if (tbl != rht_dereference_rcu(ht->future_tbl, ht)) {
 		spin_unlock_bh(lock);
 
-		tbl = rht_dereference_rcu(ht->tbl, ht);
+		tbl = rht_dereference_rcu(ht->future_tbl, ht);
 		hash = head_hashfn(ht, tbl, obj);
 
 		lock = bucket_lock(tbl, hash);
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
