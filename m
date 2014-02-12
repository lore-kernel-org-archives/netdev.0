From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 04/14] tipc: redefine 'started'
	flag in struct link to bitmap
Date: Wed, 12 Feb 2014 13:31:04 -0500
Message-ID: <1392229874-29675-5-git-send-email-jon.maloy@ericsson.com>
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

Currently, the 'started' field in struct tipc_link represents only a
binary state, 'started' or 'not started'. We need it to represent
more link execution states in the coming commits in this series.
Hence, we rename the field to 'flags', and define the current
started/non-started state to be represented by the LSB bit of
that field.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |    4 ++--
 net/tipc/link.h |   22 +++++++++++-----------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 424e9f3..2070d03 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -500,7 +500,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 	struct tipc_link *other;
 	u32 cont_intv = l_ptr->continuity_interval;
 
-	if (!l_ptr->started && (event != STARTING_EVT))
+	if (!(l_ptr->flags & LINK_STARTED) && (event != STARTING_EVT))
 		return;		/* Not yet. */
 
 	/* Check whether changeover is going on */
@@ -626,7 +626,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		case STARTING_EVT:
-			l_ptr->started = 1;
+			l_ptr->flags |= LINK_STARTED;
 			/* fall through */
 		case TIMEOUT_EVT:
 			tipc_link_send_proto_msg(l_ptr, RESET_MSG, 0, 0, 0, 0, 0);
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 994ebd1..a900e74 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/link.h: Include file for TIPC link code
  *
- * Copyright (c) 1995-2006, Ericsson AB
+ * Copyright (c) 1995-2006, 2013, Ericsson AB
  * Copyright (c) 2004-2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -40,27 +40,27 @@
 #include "msg.h"
 #include "node.h"
 
-/*
- * Link reassembly status codes
+/* Link reassembly status codes
  */
 #define LINK_REASM_ERROR	-1
 #define LINK_REASM_COMPLETE	1
 
-/*
- * Out-of-range value for link sequence numbers
+/* Out-of-range value for link sequence numbers
  */
 #define INVALID_LINK_SEQ 0x10000
 
-/*
- * Link states
+/* Link working states
  */
 #define WORKING_WORKING 560810u
 #define WORKING_UNKNOWN 560811u
 #define RESET_UNKNOWN   560812u
 #define RESET_RESET     560813u
 
-/*
- * Starting value for maximum packet size negotiation on unicast links
+/* Link endpoint execution states
+ */
+#define LINK_STARTED    0x0001
+
+/* Starting value for maximum packet size negotiation on unicast links
  * (unless bearer MTU is less)
  */
 #define MAX_PKT_DEFAULT 1500
@@ -103,7 +103,7 @@ struct tipc_stats {
  * @timer: link timer
  * @owner: pointer to peer node
  * @link_list: adjacent links in bearer's list of links
- * @started: indicates if link has been started
+ * @flags: execution state flags for link endpoint instance
  * @checkpoint: reference point for triggering link continuity checking
  * @peer_session: link session # being used by peer end of link
  * @peer_bearer_id: bearer id used by link's peer endpoint
@@ -152,7 +152,7 @@ struct tipc_link {
 	struct list_head link_list;
 
 	/* Management and link supervision data */
-	int started;
+	unsigned int flags;
 	u32 checkpoint;
 	u32 peer_session;
 	u32 peer_bearer_id;
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
