From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 04/10] tipc: convert tipc_bearers
	array to pointer list
Date: Thu, 27 Mar 2014 12:54:33 +0800
Message-ID: <1395896080-7926-5-git-send-email-ying.xue@windriver.com>
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

As part of the effort to introduce RCU protection for the bearer
list, we first need to change it to a list of pointers.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c  |    5 ++---
 net/tipc/bearer.c |   46 +++++++++++++++++++++++++++++++++++-----------
 net/tipc/bearer.h |    2 +-
 3 files changed, 38 insertions(+), 15 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e0feb7e..b4f8c62 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -668,9 +668,8 @@ void tipc_bcbearer_sort(void)
 	memset(bp_temp, 0, sizeof(bcbearer->bpairs_temp));
 
 	for (b_index = 0; b_index < MAX_BEARERS; b_index++) {
-		struct tipc_bearer *b = &tipc_bearers[b_index];
-
-		if (!b->active || !b->nodes.count)
+		struct tipc_bearer *b = bearer_list[b_index];
+		if (!b || !b->active || !b->nodes.count)
 			continue;
 
 		if (!bp_temp[b->priority].primary)
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 7f1f95c..7ff98ef 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -49,7 +49,7 @@ static struct tipc_media * const media_info_array[] = {
 	NULL
 };
 
-struct tipc_bearer tipc_bearers[MAX_BEARERS];
+struct tipc_bearer *bearer_list[MAX_BEARERS];
 
 static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down);
 
@@ -177,8 +177,9 @@ struct tipc_bearer *tipc_bearer_find(const char *name)
 	struct tipc_bearer *b_ptr;
 	u32 i;
 
-	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
-		if (b_ptr->active && (!strcmp(b_ptr->name, name)))
+	for (i = 0; i < MAX_BEARERS; i++) {
+		b_ptr = bearer_list[i];
+		if (b_ptr && b_ptr->active && (!strcmp(b_ptr->name, name)))
 			return b_ptr;
 	}
 	return NULL;
@@ -200,7 +201,9 @@ struct sk_buff *tipc_bearer_get_names(void)
 	read_lock_bh(&tipc_net_lock);
 	for (i = 0; media_info_array[i] != NULL; i++) {
 		for (j = 0; j < MAX_BEARERS; j++) {
-			b = &tipc_bearers[j];
+			b = bearer_list[j];
+			if (!b)
+				continue;
 			if (b->active && (b->media == media_info_array[i])) {
 				tipc_cfg_append_tlv(buf, TIPC_TLV_BEARER_NAME,
 						    b->name,
@@ -284,16 +287,17 @@ restart:
 	bearer_id = MAX_BEARERS;
 	with_this_prio = 1;
 	for (i = MAX_BEARERS; i-- != 0; ) {
-		if (!tipc_bearers[i].active) {
+		b_ptr = bearer_list[i];
+		if (!b_ptr || !b_ptr->active) {
 			bearer_id = i;
 			continue;
 		}
-		if (!strcmp(name, tipc_bearers[i].name)) {
+		if (!strcmp(name, b_ptr->name)) {
 			pr_warn("Bearer <%s> rejected, already enabled\n",
 				name);
 			goto exit;
 		}
-		if ((tipc_bearers[i].priority == priority) &&
+		if ((b_ptr->priority == priority) &&
 		    (++with_this_prio > 2)) {
 			if (priority-- == 0) {
 				pr_warn("Bearer <%s> rejected, duplicate priority\n",
@@ -311,7 +315,11 @@ restart:
 		goto exit;
 	}
 
-	b_ptr = &tipc_bearers[bearer_id];
+	b_ptr = kzalloc(sizeof(*b_ptr), GFP_ATOMIC);
+	if (!b_ptr) {
+		res = -ENOMEM;
+		goto exit;
+	}
 	strcpy(b_ptr->name, name);
 	b_ptr->media = m_ptr;
 	res = m_ptr->enable_media(b_ptr);
@@ -335,6 +343,9 @@ restart:
 			name);
 		goto exit;
 	}
+
+	bearer_list[bearer_id] = b_ptr;
+
 	pr_info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
 		name,
 		tipc_addr_string_fill(addr_string, disc_domain), priority);
@@ -362,13 +373,22 @@ static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
  */
 static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down)
 {
+	u32 i;
+
 	pr_info("Disabling bearer <%s>\n", b_ptr->name);
 	b_ptr->media->disable_media(b_ptr);
 
 	tipc_link_delete_list(b_ptr->identity, shutting_down);
 	if (b_ptr->link_req)
 		tipc_disc_delete(b_ptr->link_req);
-	memset(b_ptr, 0, sizeof(struct tipc_bearer));
+
+	for (i = 0; i < MAX_BEARERS; i++) {
+		if (b_ptr == bearer_list[i]) {
+			bearer_list[i] = NULL;
+			break;
+		}
+	}
+	kfree(b_ptr);
 }
 
 int tipc_disable_bearer(const char *name)
@@ -603,10 +623,14 @@ void tipc_bearer_cleanup(void)
 
 void tipc_bearer_stop(void)
 {
+	struct tipc_bearer *b_ptr;
 	u32 i;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		if (tipc_bearers[i].active)
-			bearer_disable(&tipc_bearers[i], true);
+		b_ptr = bearer_list[i];
+		if (b_ptr && b_ptr->active) {
+			bearer_disable(b_ptr, true);
+			bearer_list[i] = NULL;
+		}
 	}
 }
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 425dd81..f4e72ca 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -150,7 +150,7 @@ struct tipc_bearer_names {
 
 struct tipc_link;
 
-extern struct tipc_bearer tipc_bearers[];
+extern struct tipc_bearer *bearer_list[];
 
 /*
  * TIPC routines available to supported media types
-- 
1.7.9.5


------------------------------------------------------------------------------
