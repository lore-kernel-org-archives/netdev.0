From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 21/21] tipc: Revise timings used when sending link request messages
Date: Tue, 10 May 2011 16:44:37 -0400
Message-ID: <1305060277-15600-22-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52470 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737Ab1EJUpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:13 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Revises the algorithm governing the sending of link request messages
to take into account the number of nodes each bearer is currently in
contact with, and to ensure more rapid rediscovery of neighboring nodes
if a bearer fails and then recovers.

The discovery object now sends requests at least once a second if it
is not in contact with any other nodes, and at least once a minute if
it has at least one neighbor; if contact with the only neighbor is
lost, the object immediately reverts to its initial rapid-fire search
timing to accelerate the rediscovery process.

In addition, the discovery object now stops issuing link request
messages if it is in contact with the only neighboring node it is
configured to communicate with, since further searching is unnecessary.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |   66 +++++++++++++++++++++++++++-----------------------
 1 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 3cb232d..0987933 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -39,13 +39,9 @@
 #include "discover.h"
 
 #define TIPC_LINK_REQ_INIT	125	/* min delay during bearer start up */
-#define TIPC_LINK_REQ_FAST	2000	/* normal delay if bearer has no links */
-#define TIPC_LINK_REQ_SLOW	600000	/* normal delay if bearer has links */
-
-/*
- * TODO: Most of the inter-cluster setup stuff should be
- * rewritten, and be made conformant with specification.
- */
+#define TIPC_LINK_REQ_FAST	1000	/* max delay if bearer has no links */
+#define TIPC_LINK_REQ_SLOW	60000	/* max delay if bearer has links */
+#define TIPC_LINK_REQ_INACTIVE	0xffffffff /* indicates no timer in use */
 
 
 /**
@@ -220,22 +216,19 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 /**
  * disc_update - update frequency of periodic link setup requests
  * @req: ptr to link request structure
+ *
+ * Reinitiates discovery process if discovery object has no associated nodes
+ * and is either not currently searching or is searching at a slow rate
  */
 
 static void disc_update(struct link_req *req)
 {
-	if (req->timer_intv == TIPC_LINK_REQ_SLOW) {
-		if (!req->bearer->nodes.count) {
-			req->timer_intv = TIPC_LINK_REQ_FAST;
+	if (!req->num_nodes) {
+		if ((req->timer_intv == TIPC_LINK_REQ_INACTIVE) ||
+		    (req->timer_intv > TIPC_LINK_REQ_FAST)) {
+			req->timer_intv = TIPC_LINK_REQ_INIT;
 			k_start_timer(&req->timer, req->timer_intv);
 		}
-	} else if (req->timer_intv == TIPC_LINK_REQ_FAST) {
-		if (req->bearer->nodes.count) {
-			req->timer_intv = TIPC_LINK_REQ_SLOW;
-			k_start_timer(&req->timer, req->timer_intv);
-		}
-	} else {
-		/* leave timer "as is" if haven't yet reached a "normal" rate */
 	}
 }
 
@@ -247,7 +240,6 @@ static void disc_update(struct link_req *req)
 void tipc_disc_add_dest(struct link_req *req)
 {
 	req->num_nodes++;
-	disc_update(req);
 }
 
 /**
@@ -281,23 +273,37 @@ static void disc_send_msg(struct link_req *req)
 
 static void disc_timeout(struct link_req *req)
 {
+	int max_delay;
+
 	spin_lock_bh(&req->bearer->lock);
 
-	disc_send_msg(req);
+	/* Stop searching if only desired node has been found */
 
-	if ((req->timer_intv == TIPC_LINK_REQ_SLOW) ||
-	    (req->timer_intv == TIPC_LINK_REQ_FAST)) {
-		/* leave timer interval "as is" if already at a "normal" rate */
-	} else {
-		req->timer_intv *= 2;
-		if (req->timer_intv > TIPC_LINK_REQ_FAST)
-			req->timer_intv = TIPC_LINK_REQ_FAST;
-		if ((req->timer_intv == TIPC_LINK_REQ_FAST) &&
-		    (req->bearer->nodes.count))
-			req->timer_intv = TIPC_LINK_REQ_SLOW;
+	if (tipc_node(req->domain) && req->num_nodes) {
+		req->timer_intv = TIPC_LINK_REQ_INACTIVE;
+		goto exit;
 	}
-	k_start_timer(&req->timer, req->timer_intv);
 
+	/*
+	 * Send discovery message, then update discovery timer
+	 *
+	 * Keep doubling time between requests until limit is reached;
+	 * hold at fast polling rate if don't have any associated nodes,
+	 * otherwise hold at slow polling rate
+	 */
+
+	disc_send_msg(req);
+
+	req->timer_intv *= 2;
+	if (req->num_nodes)
+		max_delay = TIPC_LINK_REQ_SLOW;
+	else
+		max_delay = TIPC_LINK_REQ_FAST;
+	if (req->timer_intv > max_delay)
+		req->timer_intv = max_delay;
+
+	k_start_timer(&req->timer, req->timer_intv);
+exit:
 	spin_unlock_bh(&req->bearer->lock);
 }
 
-- 
1.7.4.4

