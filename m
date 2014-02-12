From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 03/14] tipc: move code for
	deleting links from bearer.c to link.c
Date: Wed, 12 Feb 2014 13:31:03 -0500
Message-ID: <1392229874-29675-4-git-send-email-jon.maloy@ericsson.com>
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

We break out the code for deleting attached links in the
function bearer_disable(), and define a new function named
tipc_link_delete_list() to do this job.

This commit incurs no functional changes, but makes the code of
function bearer_disable() cleaner. It is also a preparation
for a more important change to the bearer code, in a subsequent
commit in this series.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c |    6 +-----
 net/tipc/link.c   |    9 +++++++++
 net/tipc/link.h   |    1 +
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index a3bdf5c..a5be053 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -366,16 +366,12 @@ static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
  */
 static void bearer_disable(struct tipc_bearer *b_ptr)
 {
-	struct tipc_link *l_ptr;
-	struct tipc_link *temp_l_ptr;
 	struct tipc_link_req *temp_req;
 
 	pr_info("Disabling bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->media->disable_media(b_ptr);
-	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
-		tipc_link_delete(l_ptr);
-	}
+	tipc_link_delete_list(b_ptr);
 	temp_req = b_ptr->link_req;
 	b_ptr->link_req = NULL;
 	spin_unlock_bh(&b_ptr->lock);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 3ff34e8..424e9f3 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -313,6 +313,15 @@ void tipc_link_delete(struct tipc_link *l_ptr)
 	kfree(l_ptr);
 }
 
+void tipc_link_delete_list(struct tipc_bearer *b_ptr)
+{
+	struct tipc_link *l_ptr;
+	struct tipc_link *temp_l_ptr;
+
+	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
+		tipc_link_delete(l_ptr);
+	}
+}
 
 /**
  * link_schedule_port - schedule port for deferred sending
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 73beecb..994ebd1 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -219,6 +219,7 @@ void tipc_link_delete(struct tipc_link *l_ptr);
 void tipc_link_failover_send_queue(struct tipc_link *l_ptr);
 void tipc_link_dup_send_queue(struct tipc_link *l_ptr,
 			      struct tipc_link *dest);
+void tipc_link_delete_list(struct tipc_bearer *b_ptr);
 void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
