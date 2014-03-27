From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 05/10] tipc: remove active flag
	from tipc_bearer structure
Date: Thu, 27 Mar 2014 12:54:34 +0800
Message-ID: <1395896080-7926-6-git-send-email-ying.xue@windriver.com>
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

After the allocation of tipc_bearer structure instance is converted
from statical way to dynamical way, we identify whether a certain
tipc_bearer structure pointer is valid by checking whether the pointer
is NULL or not. So the active flag in tipc_bearer structure becomes
redundant.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c  |    2 +-
 net/tipc/bearer.c |    9 ++++-----
 net/tipc/bearer.h |    2 --
 net/tipc/link.c   |    4 ----
 4 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index b4f8c62..47bb07a 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -669,7 +669,7 @@ void tipc_bcbearer_sort(void)
 
 	for (b_index = 0; b_index < MAX_BEARERS; b_index++) {
 		struct tipc_bearer *b = bearer_list[b_index];
-		if (!b || !b->active || !b->nodes.count)
+		if (!b || !b->nodes.count)
 			continue;
 
 		if (!bp_temp[b->priority].primary)
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 7ff98ef..826b701 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -179,7 +179,7 @@ struct tipc_bearer *tipc_bearer_find(const char *name)
 
 	for (i = 0; i < MAX_BEARERS; i++) {
 		b_ptr = bearer_list[i];
-		if (b_ptr && b_ptr->active && (!strcmp(b_ptr->name, name)))
+		if (b_ptr && (!strcmp(b_ptr->name, name)))
 			return b_ptr;
 	}
 	return NULL;
@@ -204,7 +204,7 @@ struct sk_buff *tipc_bearer_get_names(void)
 			b = bearer_list[j];
 			if (!b)
 				continue;
-			if (b->active && (b->media == media_info_array[i])) {
+			if (b->media == media_info_array[i]) {
 				tipc_cfg_append_tlv(buf, TIPC_TLV_BEARER_NAME,
 						    b->name,
 						    strlen(b->name) + 1);
@@ -288,7 +288,7 @@ restart:
 	with_this_prio = 1;
 	for (i = MAX_BEARERS; i-- != 0; ) {
 		b_ptr = bearer_list[i];
-		if (!b_ptr || !b_ptr->active) {
+		if (!b_ptr) {
 			bearer_id = i;
 			continue;
 		}
@@ -333,7 +333,6 @@ restart:
 	b_ptr->tolerance = m_ptr->tolerance;
 	b_ptr->window = m_ptr->window;
 	b_ptr->net_plane = bearer_id + 'A';
-	b_ptr->active = 1;
 	b_ptr->priority = priority;
 
 	res = tipc_disc_create(b_ptr, &b_ptr->bcast_addr, disc_domain);
@@ -628,7 +627,7 @@ void tipc_bearer_stop(void)
 
 	for (i = 0; i < MAX_BEARERS; i++) {
 		b_ptr = bearer_list[i];
-		if (b_ptr && b_ptr->active) {
+		if (b_ptr) {
 			bearer_disable(b_ptr, true);
 			bearer_list[i] = NULL;
 		}
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index f4e72ca..3f6d7d0 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -118,7 +118,6 @@ struct tipc_media {
  * @tolerance: default link tolerance for bearer
  * @identity: array index of this bearer within TIPC bearer array
  * @link_req: ptr to (optional) structure making periodic link setup requests
- * @active: non-zero if bearer structure is represents a bearer
  * @net_plane: network plane ('A' through 'H') currently associated with bearer
  * @nodes: indicates which nodes in cluster can be reached through bearer
  *
@@ -138,7 +137,6 @@ struct tipc_bearer {
 	u32 tolerance;
 	u32 identity;
 	struct tipc_link_req *link_req;
-	int active;
 	char net_plane;
 	struct tipc_node_map nodes;
 };
diff --git a/net/tipc/link.c b/net/tipc/link.c
index a42f4a1..882c5c9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1458,10 +1458,6 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		head = head->next;
 		buf->next = NULL;
 
-		/* Ensure bearer is still enabled */
-		if (unlikely(!b_ptr->active))
-			goto discard;
-
 		/* Ensure message is well-formed */
 		if (unlikely(!link_recv_buf_validate(buf)))
 			goto discard;
-- 
1.7.9.5


------------------------------------------------------------------------------
