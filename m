From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 08/18] tipc: add second source address to recvmsg()/recvfrom()
Date: Thu, 12 Oct 2017 16:02:29 +0200
Message-ID: <1507816959-31787-9-git-send-email-jon.maloy@ericsson.com>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:51926 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751725AbdJLOCz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:02:55 -0400
In-Reply-To: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With group communication, it becomes important for a message receiver to
identify not only from which socket (identfied by a node:port tuple) the
message was sent, but also the logical identity (type:instance) of the
sending member.

We fix this by adding a second instance of struct sockaddr_tipc to the
source address area when a message is read. The extra address struct
is filled in with data found in the received message header (type,) and
in the local member representation struct (instance.)

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/group.c  |  3 +++
 net/tipc/msg.h    |  1 +
 net/tipc/socket.c | 52 ++++++++++++++++++++++++++++++++++------------------
 3 files changed, 38 insertions(+), 18 deletions(-)

diff --git a/net/tipc/group.c b/net/tipc/group.c
index 20663e5..b30e24a 100644
--- a/net/tipc/group.c
+++ b/net/tipc/group.c
@@ -61,6 +61,7 @@ struct tipc_member {
 	struct list_head list;
 	u32 node;
 	u32 port;
+	u32 instance;
 	enum mbr_state state;
 	u16 bc_rcv_nxt;
 };
@@ -282,6 +283,7 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 	if (!tipc_group_is_receiver(m))
 		goto drop;
 
+	TIPC_SKB_CB(skb)->orig_member = m->instance;
 	__skb_queue_tail(inputq, skb);
 
 	m->bc_rcv_nxt = msg_grp_bc_seqno(hdr) + 1;
@@ -388,6 +390,7 @@ void tipc_group_member_evt(struct tipc_group *grp,
 			m->state = MBR_PUBLISHED;
 		else
 			m->state = MBR_JOINED;
+		m->instance = evt->found_lower;
 		tipc_group_proto_xmit(grp, m, GRP_JOIN_MSG, xmitq);
 	} else if (evt->event == TIPC_WITHDRAWN) {
 		if (!m)
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 7ba1045..6bf9840 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -100,6 +100,7 @@ struct plist;
 
 struct tipc_skb_cb {
 	u32 bytes_read;
+	u32 orig_member;
 	struct sk_buff *tail;
 	bool validated;
 	u16 chain_imp;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1e5de367..43a74b8 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1222,26 +1222,42 @@ static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 }
 
 /**
- * set_orig_addr - capture sender's address for received message
+ * tipc_sk_set_orig_addr - capture sender's address for received message
  * @m: descriptor for message info
- * @msg: received message header
+ * @hdr: received message header
  *
  * Note: Address is not captured if not requested by receiver.
  */
-static void set_orig_addr(struct msghdr *m, struct tipc_msg *msg)
-{
-	DECLARE_SOCKADDR(struct sockaddr_tipc *, addr, m->msg_name);
-
-	if (addr) {
-		addr->family = AF_TIPC;
-		addr->addrtype = TIPC_ADDR_ID;
-		memset(&addr->addr, 0, sizeof(addr->addr));
-		addr->addr.id.ref = msg_origport(msg);
-		addr->addr.id.node = msg_orignode(msg);
-		addr->addr.name.domain = 0;	/* could leave uninitialized */
-		addr->scope = 0;		/* could leave uninitialized */
-		m->msg_namelen = sizeof(struct sockaddr_tipc);
-	}
+static void tipc_sk_set_orig_addr(struct msghdr *m, struct sk_buff *skb)
+{
+	struct tipc_msg *hdr = buf_msg(skb);
+	struct sockaddr_pair {
+		struct sockaddr_tipc sock;
+		struct sockaddr_tipc member;
+	};
+	DECLARE_SOCKADDR(struct sockaddr_pair *, srcaddr, m->msg_name);
+
+	if (!srcaddr)
+		return;
+
+	srcaddr->sock.family = AF_TIPC;
+	srcaddr->sock.addrtype = TIPC_ADDR_ID;
+	srcaddr->sock.addr.id.ref = msg_origport(hdr);
+	srcaddr->sock.addr.id.node = msg_orignode(hdr);
+	srcaddr->sock.addr.name.domain = 0;
+	srcaddr->sock.scope = 0;
+	m->msg_namelen = sizeof(struct sockaddr_tipc);
+
+	if (!msg_in_group(hdr))
+		return;
+
+	/* Group message users may also want to know sending member's id */
+	srcaddr->member.family = AF_TIPC;
+	srcaddr->member.addrtype = TIPC_ADDR_NAME;
+	srcaddr->member.addr.name.name.type = msg_nametype(hdr);
+	srcaddr->member.addr.name.name.instance = TIPC_SKB_CB(skb)->orig_member;
+	srcaddr->member.addr.name.domain = 0;
+	m->msg_namelen = sizeof(*srcaddr);
 }
 
 /**
@@ -1432,7 +1448,7 @@ static int tipc_recvmsg(struct socket *sock, struct msghdr *m,
 	} while (1);
 
 	/* Collect msg meta data, including error code and rejected data */
-	set_orig_addr(m, hdr);
+	tipc_sk_set_orig_addr(m, skb);
 	rc = tipc_sk_anc_data_recv(m, hdr, tsk);
 	if (unlikely(rc))
 		goto exit;
@@ -1526,7 +1542,7 @@ static int tipc_recvstream(struct socket *sock, struct msghdr *m,
 
 		/* Collect msg meta data, incl. error code and rejected data */
 		if (!copied) {
-			set_orig_addr(m, hdr);
+			tipc_sk_set_orig_addr(m, skb);
 			rc = tipc_sk_anc_data_recv(m, hdr, tsk);
 			if (rc)
 				break;
-- 
2.1.4
