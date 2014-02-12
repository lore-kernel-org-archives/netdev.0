From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 02/14] tipc: move code for
	resetting links from bearer.c to link.c
Date: Wed, 12 Feb 2014 13:31:02 -0500
Message-ID: <1392229874-29675-3-git-send-email-jon.maloy@ericsson.com>
References: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>

We break out the code for resetting attached links in the
function tipc_reset_bearer(), and define a new function named
tipc_link_reset_list() to do this job.

This commit incurs no functional changes, but makes the code
of function tipc_reset_bearer() cleaner. It is also a preparation
for a more important change to the bearer code, in a subsequent
commit in this series.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c |   11 +----------
 net/tipc/link.c   |   12 ++++++++++++
 net/tipc/link.h   |    1 +
 3 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index a38c899..a3bdf5c 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -350,19 +350,10 @@ exit:
  */
 static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
 {
-	struct tipc_link *l_ptr;
-	struct tipc_link *temp_l_ptr;
-
 	read_lock_bh(&tipc_net_lock);
 	pr_info("Resetting bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
-	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
-		struct tipc_node *n_ptr = l_ptr->owner;
-
-		spin_lock_bh(&n_ptr->lock);
-		tipc_link_reset(l_ptr);
-		spin_unlock_bh(&n_ptr->lock);
-	}
+	tipc_link_reset_list(b_ptr);
 	spin_unlock_bh(&b_ptr->lock);
 	read_unlock_bh(&tipc_net_lock);
 	return 0;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 17fbd15..3ff34e8 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -461,6 +461,18 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	link_reset_statistics(l_ptr);
 }
 
+void tipc_link_reset_list(struct tipc_bearer *b_ptr)
+{
+	struct tipc_link *l_ptr;
+
+	list_for_each_entry(l_ptr, &b_ptr->links, link_list) {
+		struct tipc_node *n_ptr = l_ptr->owner;
+
+		spin_lock_bh(&n_ptr->lock);
+		tipc_link_reset(l_ptr);
+		spin_unlock_bh(&n_ptr->lock);
+	}
+}
 
 static void link_activate(struct tipc_link *l_ptr)
 {
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 8addc5e..73beecb 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -231,6 +231,7 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area,
 struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area,
 					  int req_tlv_space);
 void tipc_link_reset(struct tipc_link *l_ptr);
+void tipc_link_reset_list(struct tipc_bearer *b_ptr);
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector);
 void tipc_link_send_names(struct list_head *message_list, u32 dest);
 int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf);
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
