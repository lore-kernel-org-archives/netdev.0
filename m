From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 3/8] tipc: ensure all name
	sequences are released when name table is stopped
Date: Tue, 2 Dec 2014 15:00:25 +0800
Message-ID: <1417503630-31352-4-git-send-email-ying.xue@windriver.com>
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

As TIPC subscriber server is terminated before name table, no user
depends on subscription list of name sequence when name table is
stopped. Therefore, all name sequences stored in name table should
be released whatever their subscriptions lists are empty or not,
otherwise, memory leak might happen.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_table.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index df3da29..ba0ee3e 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -964,10 +964,6 @@ static void tipc_purge_publications(struct name_seq *seq)
 	struct sub_seq *sseq;
 	struct name_info *info;
 
-	if (!seq->sseqs) {
-		nameseq_delete_empty(seq);
-		return;
-	}
 	sseq = seq->sseqs;
 	info = sseq->info;
 	list_for_each_entry_safe(publ, safe, &info->zone_list, zone_list) {
@@ -975,6 +971,9 @@ static void tipc_purge_publications(struct name_seq *seq)
 					 publ->ref, publ->key);
 		kfree(publ);
 	}
+	hlist_del_init(&seq->ns_list);
+	kfree(seq->sseqs);
+	kfree(seq);
 }
 
 void tipc_nametbl_stop(void)
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
