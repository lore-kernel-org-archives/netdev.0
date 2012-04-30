From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/10] tipc: Enhance error checking of published names
Date: Mon, 30 Apr 2012 18:37:06 -0400
Message-ID: <1335825428-16053-9-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45990 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757361Ab2D3WhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:23 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Consolidates validation of scope and name sequence range values into
a single routine where it applies both to local name publications
and to name publications issued by other nodes in the network. This
change means that the scope value for non-local publications is now
validated and the name sequence range for local publications is now
validated only once. Additionally, a publication attempt that fails
validation now creates an entry in the system log file only if debugging
capabilities have been enabled; this prevents the system log from being
cluttered up with messages caused by a defective application or network
node.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |    7 ++++---
 net/tipc/port.c       |    4 ----
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 4222121..4de58de 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -516,9 +516,10 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 {
 	struct name_seq *seq = nametbl_find_seq(type);
 
-	if (lower > upper) {
-		warn("Failed to publish illegal {%u,%u,%u}\n",
-		     type, lower, upper);
+	if ((scope < TIPC_ZONE_SCOPE) || (scope > TIPC_NODE_SCOPE) ||
+	    (lower > upper)) {
+		dbg("Failed to publish illegal {%u,%u,%u} with scope %u\n",
+		     type, lower, upper, scope);
 		return NULL;
 	}
 
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 4aede40..e684170 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -992,10 +992,6 @@ int tipc_publish(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 
 	if (p_ptr->connected)
 		goto exit;
-	if (seq->lower > seq->upper)
-		goto exit;
-	if ((scope < TIPC_ZONE_SCOPE) || (scope > TIPC_NODE_SCOPE))
-		goto exit;
 	key = ref + p_ptr->pub_count + 1;
 	if (key == ref) {
 		res = -EADDRINUSE;
-- 
1.7.9.6
