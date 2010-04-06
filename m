From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH 1/1] TIPC: Updated topology subscription
	protocol according to latest spec
Date: Tue, 6 Apr 2010 17:40:52 -0400
Message-ID: <1270590052-975-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, Jon
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch makes it explicit in the API that all fields in subscriptions and events exchanged with the Topology Server must be in
network byte order.
It also ensures that all fields of a subscription are compared when cancelling a subscription, in order to avoid inadvertent
cancelling of the wrong subscription.
Finally, the tipc module version is updated to 2.0.0, to reflect the API change.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/linux/tipc.h |   30 ++++++++++++------------------
 net/tipc/core.c      |    2 +-
 net/tipc/subscr.c    |   15 ++++++++++-----
 3 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index 3d92396..9536d8a 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -127,23 +127,17 @@ static inline unsigned int tipc_node(__u32 addr)
  * TIPC topology subscription service definitions
  */
 
-#define TIPC_SUB_PORTS     	0x01  	/* filter for port availability */
-#define TIPC_SUB_SERVICE     	0x02  	/* filter for service availability */
-#define TIPC_SUB_CANCEL         0x04    /* cancel a subscription */
-#if 0
-/* The following filter options are not currently implemented */
-#define TIPC_SUB_NO_BIND_EVTS	0x04	/* filter out "publish" events */
-#define TIPC_SUB_NO_UNBIND_EVTS	0x08	/* filter out "withdraw" events */
-#define TIPC_SUB_SINGLE_EVT	0x10	/* expire after first event */
-#endif
+#define TIPC_SUB_SERVICE     	0x00  	/* Filter for service availability    */
+#define TIPC_SUB_PORTS     	0x01  	/* Filter for port availability  */
+#define TIPC_SUB_CANCEL         0x04    /* Cancel a subscription         */
 
 #define TIPC_WAIT_FOREVER	~0	/* timeout for permanent subscription */
 
 struct tipc_subscr {
-	struct tipc_name_seq seq;	/* name sequence of interest */
-	__u32 timeout;			/* subscription duration (in ms) */
-        __u32 filter;   		/* bitmask of filter options */
-	char usr_handle[8];		/* available for subscriber use */
+	struct tipc_name_seq seq;	/* NBO. Name sequence of interest */
+	__u32 timeout;			/* NBO. Subscription duration (in ms) */
+        __u32 filter;   		/* NBO. Bitmask of filter options */
+	char usr_handle[8];		/* Opaque. Available for subscriber use */
 };
 
 #define TIPC_PUBLISHED		1	/* publication event */
@@ -151,11 +145,11 @@ struct tipc_subscr {
 #define TIPC_SUBSCR_TIMEOUT	3	/* subscription timeout event */
 
 struct tipc_event {
-	__u32 event;			/* event type */
-	__u32 found_lower;		/* matching name seq instances */
-	__u32 found_upper;		/*    "      "    "     "      */
-	struct tipc_portid port;	/* associated port */
-	struct tipc_subscr s;		/* associated subscription */
+	__u32 event;			/* NBO. Event type, as defined above */
+	__u32 found_lower;		/* NBO. Matching name seq instances  */
+	__u32 found_upper;		/*  "      "       "   "    "        */
+	struct tipc_portid port;	/* NBO. Associated port              */
+	struct tipc_subscr s;		/* Original, associated subscription */
 };
 
 /*
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 52c571f..4e84c84 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -49,7 +49,7 @@
 #include "config.h"
 
 
-#define TIPC_MOD_VER "1.6.4"
+#define TIPC_MOD_VER "2.0.0"
 
 #ifndef CONFIG_TIPC_ZONES
 #define CONFIG_TIPC_ZONES 3
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index ff123e5..ab6eab4 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -274,7 +274,7 @@ static void subscr_cancel(struct tipc_subscr *s,
 {
 	struct subscription *sub;
 	struct subscription *sub_temp;
-	__u32 type, lower, upper;
+	__u32 type, lower, upper, timeout, filter;
 	int found = 0;
 
 	/* Find first matching subscription, exit if not found */
@@ -282,12 +282,18 @@ static void subscr_cancel(struct tipc_subscr *s,
 	type = ntohl(s->seq.type);
 	lower = ntohl(s->seq.lower);
 	upper = ntohl(s->seq.upper);
+	timeout = ntohl(s->timeout);
+	filter = ntohl(s->filter) & ~TIPC_SUB_CANCEL;
 
 	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
 				 subscription_list) {
 			if ((type == sub->seq.type) &&
 			    (lower == sub->seq.lower) &&
-			    (upper == sub->seq.upper)) {
+			    (upper == sub->seq.upper) &&
+			    (timeout == sub->timeout) &&
+                            (filter == sub->filter) &&
+                             !memcmp(s->usr_handle,sub->evt.s.usr_handle,
+				     sizeof(s->usr_handle)) ){
 				found = 1;
 				break;
 			}
@@ -304,7 +310,7 @@ static void subscr_cancel(struct tipc_subscr *s,
 		k_term_timer(&sub->timer);
 		spin_lock_bh(subscriber->lock);
 	}
-	dbg("Cancel: removing sub %u,%u,%u from subscriber %x list\n",
+	dbg("Cancel: removing sub %u,%u,%u from subscriber %p list\n",
 	    sub->seq.type, sub->seq.lower, sub->seq.upper, subscriber);
 	subscr_del(sub);
 }
@@ -352,8 +358,7 @@ static struct subscription *subscr_subscribe(struct tipc_subscr *s,
 	sub->seq.upper = ntohl(s->seq.upper);
 	sub->timeout = ntohl(s->timeout);
 	sub->filter = ntohl(s->filter);
-	if ((!(sub->filter & TIPC_SUB_PORTS) ==
-	     !(sub->filter & TIPC_SUB_SERVICE)) ||
+	if ((sub->filter && (sub->filter != TIPC_SUB_PORTS)) ||
 	    (sub->seq.lower > sub->seq.upper)) {
 		warn("Subscription rejected, illegal request\n");
 		kfree(sub);
-- 
1.5.4.3


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
