From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/7] tipc: add new functions for
	multicast and broadcast distribution
Date: Tue, 15 Jul 2014 13:46:06 -0400
Message-ID: <1405446370-11781-4-git-send-email-jon.maloy@ericsson.com>
References: <1405446370-11781-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1405446370-11781-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

We add a new broadcast link transmit function in bclink.c and a new
receive function in socket.c. The purpose is to move the branching
between external and internal destination down to the link layer,
just as we have done with unicast in earlier commits. We also make
use of the new link-independent fragmentation support that was
introduced in an earlier commit series.

This gives a shorter and simpler code path, and makes it possible
to obtain copy-free buffer delivery to all node local destination
sockets.

The new transmission code is added in parallel with the existing one,
and will be used by the socket multicast send function in the next
commit in this series.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c  |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 net/tipc/bcast.h  |    4 +++-
 net/tipc/msg.c    |   38 ++++++++++++++++++++++++++++++++++++
 net/tipc/msg.h    |    2 ++
 net/tipc/socket.c |   40 ++++++++++++++++++++++++++++++++++++++
 net/tipc/socket.h |    2 ++
 6 files changed, 139 insertions(+), 2 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 2663167..4742d60 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/bcast.c: TIPC broadcast code
  *
- * Copyright (c) 2004-2006, Ericsson AB
+ * Copyright (c) 2004-2006, 2014, Ericsson AB
  * Copyright (c) 2004, Intel Corporation.
  * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
@@ -38,6 +38,8 @@
 #include "core.h"
 #include "link.h"
 #include "port.h"
+#include "socket.h"
+#include "msg.h"
 #include "bcast.h"
 #include "name_distr.h"
 
@@ -138,6 +140,11 @@ static void tipc_bclink_unlock(void)
 		tipc_link_reset_all(node);
 }
 
+uint  tipc_bclink_get_mtu(void)
+{
+	return MAX_PKT_DEFAULT_MCAST;
+}
+
 void tipc_bclink_set_flags(unsigned int flags)
 {
 	bclink->flags |= flags;
@@ -408,6 +415,52 @@ exit:
 	return res;
 }
 
+/* tipc_bclink_xmit2 - broadcast buffer chain to all nodes in cluster
+ *                     and to identified node local sockets
+ * @buf: chain of buffers containing message
+ * Consumes the buffer chain, except when returning -ELINKCONG
+ * Returns 0 if success, otherwise errno: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE
+ */
+int tipc_bclink_xmit2(struct sk_buff *buf)
+{
+	int rc = 0;
+	int bc = 0;
+	struct sk_buff *clbuf;
+
+	/* Prepare clone of message for local node */
+	clbuf = tipc_msg_reassemble(buf);
+	if (unlikely(!clbuf)) {
+		kfree_skb_list(buf);
+		return -EHOSTUNREACH;
+	}
+
+	/* Broadcast to all other nodes */
+	if (likely(bclink)) {
+		tipc_bclink_lock();
+		if (likely(bclink->bcast_nodes.count)) {
+			rc = __tipc_link_xmit(bcl, buf);
+			if (likely(!rc)) {
+				bclink_set_last_sent();
+				bcl->stats.queue_sz_counts++;
+				bcl->stats.accu_queue_sz += bcl->out_queue_size;
+			}
+			bc = 1;
+		}
+		tipc_bclink_unlock();
+	}
+
+	if (unlikely(!bc))
+		kfree_skb_list(buf);
+
+	/* Deliver message clone */
+	if (likely(!rc))
+		tipc_sk_mcast_rcv(clbuf);
+	else
+		kfree_skb(clbuf);
+
+	return rc;
+}
+
 /**
  * bclink_accept_pkt - accept an incoming, in-sequence broadcast packet
  *
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 00330c4..d90645f 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/bcast.h: Include file for TIPC broadcast code
  *
- * Copyright (c) 2003-2006, Ericsson AB
+ * Copyright (c) 2003-2006, 2014, Ericsson AB
  * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -98,5 +98,7 @@ int  tipc_bclink_stats(char *stats_buf, const u32 buf_size);
 int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
 void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action);
+uint  tipc_bclink_get_mtu(void);
+int tipc_bclink_xmit2(struct sk_buff *buf);
 
 #endif
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 6ec9584..4662b16 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -412,3 +412,41 @@ int tipc_msg_eval(struct sk_buff *buf, u32 *dnode)
 	msg_set_destport(msg, dport);
 	return TIPC_OK;
 }
+
+/* tipc_msg_reassemble() - clone a buffer chain of fragments and
+ *                         reassemble the clones into one message
+ */
+struct sk_buff *tipc_msg_reassemble(struct sk_buff *chain)
+{
+	struct sk_buff *buf = chain;
+	struct sk_buff *frag = buf;
+	struct sk_buff *head = NULL;
+	int hdr_sz;
+
+	/* Copy header if single buffer */
+	if (!buf->next) {
+		hdr_sz = skb_headroom(buf) + msg_hdr_sz(buf_msg(buf));
+		head = __pskb_copy(buf, hdr_sz, GFP_ATOMIC);
+		if (likely(head))
+			return head;
+		return NULL;
+	}
+
+	/* Clone all fragments and reassemble */
+	while (buf) {
+		frag = skb_clone(buf, GFP_ATOMIC);
+		if (!frag)
+			goto error;
+		frag->next = NULL;
+		if (tipc_buf_append(&head, &frag))
+			break;
+		if (!head)
+			goto error;
+		buf = buf->next;
+	}
+	return frag;
+error:
+	pr_warn("Failed do clone local mcast rcv buffer\n");
+	kfree_skb(head);
+	return NULL;
+}
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 7d57434..a15d596 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -744,4 +744,6 @@ bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode);
 int tipc_msg_build2(struct tipc_msg *mhdr, struct iovec const *iov,
 		    int offset, int dsz, int mtu , struct sk_buff **chain);
 
+struct sk_buff *tipc_msg_reassemble(struct sk_buff *chain);
+
 #endif
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 8c5600c..d16550f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -534,6 +534,46 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 	return mask;
 }
 
+/* tipc_sk_mcast_rcv - Deliver multicast message to all destination sockets
+ */
+void tipc_sk_mcast_rcv(struct sk_buff *buf)
+{
+	struct tipc_msg *msg = buf_msg(buf);
+	struct tipc_port_list dports = {0, NULL, };
+	struct tipc_port_list *item;
+	struct sk_buff *b;
+	uint i, last, dst = 0;
+	u32 scope = TIPC_CLUSTER_SCOPE;
+
+	if (in_own_node(msg_orignode(msg)))
+		scope = TIPC_NODE_SCOPE;
+
+	/* Create destination port list: */
+	tipc_nametbl_mc_translate(msg_nametype(msg),
+				  msg_namelower(msg),
+				  msg_nameupper(msg),
+				  scope,
+				  &dports);
+	last = dports.count;
+	if (!last) {
+		kfree_skb(buf);
+		return;
+	}
+
+	for (item = &dports; item; item = item->next) {
+		for (i = 0; i < PLSIZE && ++dst <= last; i++) {
+			b = (dst != last) ? skb_clone(buf, GFP_ATOMIC) : buf;
+			if (!b) {
+				pr_warn("Failed do clone mcast rcv buffer\n");
+				continue;
+			}
+			msg_set_destport(msg, item->ports[i]);
+			tipc_sk_rcv(b);
+		}
+	}
+	tipc_port_list_free(&dports);
+}
+
 /**
  * tipc_sk_proto_rcv - receive a connection mng protocol message
  * @tsk: receiving socket
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 2cdede9..43b75b3 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -85,4 +85,6 @@ static inline int tipc_sk_conn_cong(struct tipc_sock *tsk)
 
 int tipc_sk_rcv(struct sk_buff *buf);
 
+void tipc_sk_mcast_rcv(struct sk_buff *buf);
+
 #endif
-- 
1.7.9.5


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
