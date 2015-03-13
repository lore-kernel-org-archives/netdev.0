From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 7/7] tipc: clean up handling of
	message priorities
Date: Fri, 13 Mar 2015 10:27:40 -0400
Message-ID: <1426256860-31208-8-git-send-email-jon.maloy@ericsson.com>
References: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Messages transferred by TIPC are assigned an "importance priority", -an
integer value indicating how to treat the message when there is link or
destination socket congestion.

There is no separate header field for this value. Instead, the message
user values have been chosen in ascending order according to perceived
importance, so that the message user field can be used for this.

This is not a good solution. First, we have many more users than the
needed priority levels, so we end up with treating more priority
levels than necessary. Second, the user field cannot always
accurately reflect the priority of the message. E.g., a message
fragment packet should really have the priority of the enveloped
user data message, and not the priority of the MSG_FRAGMENTER user.
Until now, we have been working around this problem in different ways,
but it it now time to implement a consistent way of handling such
priorities, although still within the constraint that we cannot
allocate any more bits in the regular data message header for this.

In this commit, we define a new priority level, TIPC_SYSTEM_IMPORTANCE,
that will be the only one used apart from the four (lower) user data
levels. All non-data messages map down to this priority. Furthermore,
we take some free bits from the MSG_FRAGMENTER header and allocate
them to store the priority of the enveloped message. We then adjust
the functions msg_importance()/msg_set_importance() so that they
read/set the correct header fields depending on user type.

This small protocol change is fully compatible, because the code on
on the receiving end of a link currently reads the importance level
only from user data messages, where there is no change.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |  1 -
 net/tipc/link.c  | 40 +++++++++++++---------------------
 net/tipc/msg.c   |  5 +----
 net/tipc/msg.h   | 65 +++++++++++++++++++++++++++++---------------------------
 4 files changed, 50 insertions(+), 61 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 17cb0ff..5aff084 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -383,7 +383,6 @@ int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
 		__skb_queue_purge(list);
 		return -EHOSTUNREACH;
 	}
-
 	/* Broadcast to all nodes */
 	if (likely(bclink)) {
 		tipc_bclink_lock(net);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 7e0036f..bc49120 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -35,6 +35,7 @@
  */
 
 #include "core.h"
+#include "subscr.h"
 #include "link.h"
 #include "bcast.h"
 #include "socket.h"
@@ -305,12 +306,10 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	msg_set_session(msg, (tn->random & 0xffff));
 	msg_set_bearer_id(msg, b_ptr->identity);
 	strcpy((char *)msg_data(msg), if_name);
-
-	l_ptr->priority = b_ptr->priority;
-	tipc_link_set_queue_limits(l_ptr, b_ptr->window);
-
 	l_ptr->net_plane = b_ptr->net_plane;
 	link_init_max_pkt(l_ptr);
+	l_ptr->priority = b_ptr->priority;
+	tipc_link_set_queue_limits(l_ptr, b_ptr->window);
 
 	l_ptr->next_out_no = 1;
 	__skb_queue_head_init(&l_ptr->transmq);
@@ -708,7 +707,7 @@ static int tipc_link_cong(struct tipc_link *link, struct sk_buff_head *list)
 {
 	struct sk_buff *skb = skb_peek(list);
 	struct tipc_msg *msg = buf_msg(skb);
-	uint imp = tipc_msg_tot_importance(msg);
+	int imp = msg_importance(msg);
 	u32 oport = msg_tot_origport(msg);
 
 	if (unlikely(imp > TIPC_CRITICAL_IMPORTANCE)) {
@@ -745,7 +744,7 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 {
 	struct tipc_msg *msg = buf_msg(skb_peek(list));
 	unsigned int maxwin = link->window;
-	uint imp = tipc_msg_tot_importance(msg);
+	unsigned int imp = msg_importance(msg);
 	uint mtu = link->max_pkt;
 	uint ack = mod(link->next_in_no - 1);
 	uint seqno = link->next_out_no;
@@ -755,7 +754,7 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 	struct sk_buff_head *backlogq = &link->backlogq;
 	struct sk_buff *skb, *tmp;
 
-	/* Match queue limits against msg importance: */
+	/* Match queue limit against msg importance: */
 	if (unlikely(skb_queue_len(backlogq) >= link->queue_limit[imp]))
 		return tipc_link_cong(link, list);
 
@@ -1811,25 +1810,16 @@ static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol)
 	l_ptr->abort_limit = tol / (jiffies_to_msecs(l_ptr->cont_intv) / 4);
 }
 
-void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
+void tipc_link_set_queue_limits(struct tipc_link *l, u32 win)
 {
-	l_ptr->window = window;
-
-	/* Data messages from this node, inclusive FIRST_FRAGM */
-	l_ptr->queue_limit[TIPC_LOW_IMPORTANCE] = window;
-	l_ptr->queue_limit[TIPC_MEDIUM_IMPORTANCE] = (window / 3) * 4;
-	l_ptr->queue_limit[TIPC_HIGH_IMPORTANCE] = (window / 3) * 5;
-	l_ptr->queue_limit[TIPC_CRITICAL_IMPORTANCE] = (window / 3) * 6;
-	/* Transiting data messages,inclusive FIRST_FRAGM */
-	l_ptr->queue_limit[TIPC_LOW_IMPORTANCE + 4] = 300;
-	l_ptr->queue_limit[TIPC_MEDIUM_IMPORTANCE + 4] = 600;
-	l_ptr->queue_limit[TIPC_HIGH_IMPORTANCE + 4] = 900;
-	l_ptr->queue_limit[TIPC_CRITICAL_IMPORTANCE + 4] = 1200;
-	l_ptr->queue_limit[CONN_MANAGER] = 1200;
-	l_ptr->queue_limit[CHANGEOVER_PROTOCOL] = 2500;
-	l_ptr->queue_limit[NAME_DISTRIBUTOR] = 3000;
-	/* FRAGMENT and LAST_FRAGMENT packets */
-	l_ptr->queue_limit[MSG_FRAGMENTER] = 4000;
+	int max_bulk = TIPC_MAX_PUBLICATIONS / (l->max_pkt / ITEM_SIZE);
+
+	l->window = win;
+	l->queue_limit[TIPC_LOW_IMPORTANCE]      = win / 2;
+	l->queue_limit[TIPC_MEDIUM_IMPORTANCE]   = win;
+	l->queue_limit[TIPC_HIGH_IMPORTANCE]     = win / 2 * 3;
+	l->queue_limit[TIPC_CRITICAL_IMPORTANCE] = win * 2;
+	l->queue_limit[TIPC_SYSTEM_IMPORTANCE]   = max_bulk;
 }
 
 /* tipc_link_find_owner - locate owner node of link by link's name
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index a3b4715..59a2213 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -270,6 +270,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		      FIRST_FRAGMENT, INT_H_SIZE, msg_destnode(mhdr));
 	msg_set_size(&pkthdr, pktmax);
 	msg_set_fragm_no(&pkthdr, pktno);
+	msg_set_importance(&pkthdr, msg_importance(mhdr));
 
 	/* Prepare first fragment */
 	skb = tipc_buf_acquire(pktmax);
@@ -469,7 +470,6 @@ bool tipc_msg_reverse(u32 own_addr,  struct sk_buff *buf, u32 *dnode,
 		      int err)
 {
 	struct tipc_msg *msg = buf_msg(buf);
-	uint imp = msg_importance(msg);
 	struct tipc_msg ohdr;
 	uint rdsz = min_t(uint, msg_data_sz(msg), MAX_FORWARD_SIZE);
 
@@ -481,9 +481,6 @@ bool tipc_msg_reverse(u32 own_addr,  struct sk_buff *buf, u32 *dnode,
 	if (msg_errcode(msg))
 		goto exit;
 	memcpy(&ohdr, msg, msg_hdr_sz(msg));
-	imp = min_t(uint, imp + 1, TIPC_CRITICAL_IMPORTANCE);
-	if (msg_isdata(msg))
-		msg_set_importance(msg, imp);
 	msg_set_errcode(msg, err);
 	msg_set_origport(msg, msg_destport(&ohdr));
 	msg_set_destport(msg, msg_origport(&ohdr));
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index e5fc5fd..bd3969a 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -54,6 +54,8 @@ struct plist;
  * - TIPC_HIGH_IMPORTANCE
  * - TIPC_CRITICAL_IMPORTANCE
  */
+#define TIPC_SYSTEM_IMPORTANCE	4
+
 
 /*
  * Payload message types
@@ -64,6 +66,19 @@ struct plist;
 #define TIPC_DIRECT_MSG		3
 
 /*
+ * Internal message users
+ */
+#define  BCAST_PROTOCOL       5
+#define  MSG_BUNDLER          6
+#define  LINK_PROTOCOL        7
+#define  CONN_MANAGER         8
+#define  CHANGEOVER_PROTOCOL  10
+#define  NAME_DISTRIBUTOR     11
+#define  MSG_FRAGMENTER       12
+#define  LINK_CONFIG          13
+#define  SOCK_WAKEUP          14       /* pseudo user */
+
+/*
  * Message header sizes
  */
 #define SHORT_H_SIZE              24	/* In-cluster basic payload message */
@@ -170,16 +185,6 @@ static inline void msg_set_user(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 0, 25, 0xf, n);
 }
 
-static inline u32 msg_importance(struct tipc_msg *m)
-{
-	return msg_bits(m, 0, 25, 0xf);
-}
-
-static inline void msg_set_importance(struct tipc_msg *m, u32 i)
-{
-	msg_set_user(m, i);
-}
-
 static inline u32 msg_hdr_sz(struct tipc_msg *m)
 {
 	return msg_bits(m, 0, 21, 0xf) << 2;
@@ -336,6 +341,25 @@ static inline void msg_set_seqno(struct tipc_msg *m, u32 n)
 /*
  * Words 3-10
  */
+static inline u32 msg_importance(struct tipc_msg *m)
+{
+	if (unlikely(msg_user(m) == MSG_FRAGMENTER))
+		return msg_bits(m, 5, 13, 0x7);
+	if (likely(msg_isdata(m) && !msg_errcode(m)))
+		return msg_user(m);
+	return TIPC_SYSTEM_IMPORTANCE;
+}
+
+static inline void msg_set_importance(struct tipc_msg *m, u32 i)
+{
+	if (unlikely(msg_user(m) == MSG_FRAGMENTER))
+		msg_set_bits(m, 5, 13, 0x7, i);
+	else if (likely(i < TIPC_SYSTEM_IMPORTANCE))
+		msg_set_user(m, i);
+	else
+		pr_warn("Trying to set illegal importance in message\n");
+}
+
 static inline u32 msg_prevnode(struct tipc_msg *m)
 {
 	return msg_word(m, 3);
@@ -458,20 +482,6 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
  */
 
 /*
- * Internal message users
- */
-#define  BCAST_PROTOCOL       5
-#define  MSG_BUNDLER          6
-#define  LINK_PROTOCOL        7
-#define  CONN_MANAGER         8
-#define  ROUTE_DISTRIBUTOR    9		/* obsoleted */
-#define  CHANGEOVER_PROTOCOL  10
-#define  NAME_DISTRIBUTOR     11
-#define  MSG_FRAGMENTER       12
-#define  LINK_CONFIG          13
-#define  SOCK_WAKEUP          14       /* pseudo user */
-
-/*
  *  Connection management protocol message types
  */
 #define CONN_PROBE        0
@@ -743,13 +753,6 @@ static inline void msg_set_link_tolerance(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 9, 0, 0xffff, n);
 }
 
-static inline u32 tipc_msg_tot_importance(struct tipc_msg *m)
-{
-	if ((msg_user(m) == MSG_FRAGMENTER) && (msg_type(m) == FIRST_FRAGMENT))
-		return msg_importance(msg_get_wrapped(m));
-	return msg_importance(m);
-}
-
 static inline u32 msg_tot_origport(struct tipc_msg *m)
 {
 	if ((msg_user(m) == MSG_FRAGMENTER) && (msg_type(m) == FIRST_FRAGMENT))
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
