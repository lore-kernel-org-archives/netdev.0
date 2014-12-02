From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 5/8] tipc: any name table member
	must be protected under name table lock
Date: Tue, 2 Dec 2014 15:00:27 +0800
Message-ID: <1417503630-31352-6-git-send-email-ying.xue@windriver.com>
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

As tipc_nametbl_lock is used to protect name_table structure, the lock
must be held while all members of name_table structure are accessed.
However, the lock is not obtained while a member of name_table
structure - local_publ_count is read in tipc_nametbl_publish(), as
a consequence, an inconsistent value of local_publ_count might be got.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_table.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 0d61f58..93bac40 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -656,13 +656,14 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 	struct publication *publ;
 	struct sk_buff *buf = NULL;
 
+	write_lock_bh(&tipc_nametbl_lock);
 	if (tipc_nametbl->local_publ_count >= TIPC_MAX_PUBLICATIONS) {
 		pr_warn("Publication failed, local publication limit reached (%u)\n",
 			TIPC_MAX_PUBLICATIONS);
+		write_unlock_bh(&tipc_nametbl_lock);
 		return NULL;
 	}
 
-	write_lock_bh(&tipc_nametbl_lock);
 	publ = tipc_nametbl_insert_publ(type, lower, upper, scope,
 				   tipc_own_addr, port_ref, key);
 	if (likely(publ)) {
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
