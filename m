From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 6/8] tipc: simplify relationship
	between name table lock and node lock
Date: Tue, 2 Dec 2014 15:00:28 +0800
Message-ID: <1417503630-31352-7-git-send-email-ying.xue@windriver.com>
References: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When tipc name sequence is published, name table lock is released
before name sequence buffer is delivered to remote nodes through its
underlying unicast links. However, when name sequence is withdrawn,
the name table lock is held until the transmission of the removal
message of name sequence is finished. During the process, node lock
is nested in name table lock. To prevent node lock from being nested
in name table lock, while withdrawing name, we should adopt the same
locking policy of publishing name sequence: name table lock should
be released before message is sent.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_table.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 93bac40..bc3e7ed 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -685,27 +685,28 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 {
 	struct publication *publ;
-	struct sk_buff *buf;
+	struct sk_buff *skb = NULL;
 
 	write_lock_bh(&tipc_nametbl_lock);
 	publ = tipc_nametbl_remove_publ(type, lower, tipc_own_addr, ref, key);
 	if (likely(publ)) {
 		tipc_nametbl->local_publ_count--;
-		buf = tipc_named_withdraw(publ);
+		skb = tipc_named_withdraw(publ);
 		/* Any pending external events? */
 		tipc_named_process_backlog();
-		write_unlock_bh(&tipc_nametbl_lock);
 		list_del_init(&publ->pport_list);
 		kfree(publ);
+	} else {
+		pr_err("Unable to remove local publication\n"
+		       "(type=%u, lower=%u, ref=%u, key=%u)\n",
+		       type, lower, ref, key);
+	}
+	write_unlock_bh(&tipc_nametbl_lock);
 
-		if (buf)
-			named_cluster_distribute(buf);
+	if (skb) {
+		named_cluster_distribute(skb);
 		return 1;
 	}
-	write_unlock_bh(&tipc_nametbl_lock);
-	pr_err("Unable to remove local publication\n"
-	       "(type=%u, lower=%u, ref=%u, key=%u)\n",
-	       type, lower, ref, key);
 	return 0;
 }
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
