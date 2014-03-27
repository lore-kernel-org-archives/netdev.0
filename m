From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 06/10] tipc: make broadcast
	bearer store in bearer_list array
Date: Thu, 27 Mar 2014 12:54:35 +0800
Message-ID: <1395896080-7926-7-git-send-email-ying.xue@windriver.com>
References: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Now unicast bearer is dynamically allocated and placed into its
identity specified slot of bearer_list array. When we search
bearer_list array with a bearer identity, the corresponding bearer
instance can be found. But broadcast bearer is statically allocated
and it is not located in the bearer_list array yet. So we decide to
enlarge bearer_list array into MAX_BEARERS + 1 slots, and its last
slot stores the broadcast bearer so that the broadcast bearer can
be found from bearer_list array with MAX_BEARERS as index. The
change will help us reduce the complex relationship between bearer
and link in the future.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c  |    8 +++++---
 net/tipc/bearer.c |    2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 47bb07a..26c2c1e 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -41,9 +41,9 @@
 #include "bcast.h"
 #include "name_distr.h"
 
-#define MAX_PKT_DEFAULT_MCAST 1500	/* bcast link max packet size (fixed) */
-
-#define BCLINK_WIN_DEFAULT 20		/* bcast link window size (default) */
+#define	MAX_PKT_DEFAULT_MCAST	1500	/* bcast link max packet size (fixed) */
+#define	BCLINK_WIN_DEFAULT	20	/* bcast link window size (default) */
+#define	BCBEARER		MAX_BEARERS
 
 /**
  * struct tipc_bcbearer_pair - a pair of bearers used by broadcast link
@@ -784,6 +784,7 @@ void tipc_bclink_init(void)
 	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
 	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
 	bcl->b_ptr = &bcbearer->bearer;
+	bearer_list[BCBEARER] = &bcbearer->bearer;
 	bcl->state = WORKING_WORKING;
 	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 }
@@ -794,6 +795,7 @@ void tipc_bclink_stop(void)
 	tipc_link_purge_queues(bcl);
 	spin_unlock_bh(&bc_lock);
 
+	bearer_list[BCBEARER] = NULL;
 	memset(bclink, 0, sizeof(*bclink));
 	memset(bcbearer, 0, sizeof(*bcbearer));
 }
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 826b701..ed45f97 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -49,7 +49,7 @@ static struct tipc_media * const media_info_array[] = {
 	NULL
 };
 
-struct tipc_bearer *bearer_list[MAX_BEARERS];
+struct tipc_bearer *bearer_list[MAX_BEARERS + 1];
 
 static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down);
 
-- 
1.7.9.5


------------------------------------------------------------------------------
