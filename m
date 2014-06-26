From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 08/13] tipc: RDM/DGRAM transport uses new fragmenting and sending functions
Date: Wed, 25 Jun 2014 20:41:37 -0500
Message-ID: <1403746902-20408-9-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24163 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757329AbaFZBtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:49:01 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We merge the code for sending port name and port identity addressed
messages into the corresponding send functions in socket.c, and start
using the new fragmenting and transmit functions we just have introduced.

This saves a call level and quite a few code lines, as well as making
this part of the code easier to follow. As a consequence, the functions
tipc_send2name() and tipc_send2port() in port.c can be removed.

For practical reasons, we break out the code for sending multicast messages
from tipc_sendmsg() and move it into a separate function, tipc_sendmcast(),
but we do not yet convert it into using the new build/send functions.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/port.c   |   90 ------------------------------
 net/tipc/port.h   |   11 ----
 net/tipc/socket.c |  158 +++++++++++++++++++++++++++++++++++++----------------
 3 files changed, 110 insertions(+), 149 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 5fd7acc..8350ec9 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -806,93 +806,3 @@ int tipc_send(struct tipc_port *p_ptr,
 	}
 	return -ELINKCONG;
 }
-
-/**
- * tipc_send2name - send message sections to port name
- */
-int tipc_send2name(struct tipc_port *p_ptr,
-		   struct tipc_name const *name,
-		   unsigned int domain,
-		   struct iovec const *msg_sect,
-		   unsigned int len)
-{
-	struct tipc_msg *msg;
-	u32 destnode = domain;
-	u32 destport;
-	int res;
-
-	if (p_ptr->connected)
-		return -EINVAL;
-
-	msg = &p_ptr->phdr;
-	msg_set_type(msg, TIPC_NAMED_MSG);
-	msg_set_hdr_sz(msg, NAMED_H_SIZE);
-	msg_set_nametype(msg, name->type);
-	msg_set_nameinst(msg, name->instance);
-	msg_set_lookup_scope(msg, tipc_addr_scope(domain));
-	destport = tipc_nametbl_translate(name->type, name->instance, &destnode);
-	msg_set_destnode(msg, destnode);
-	msg_set_destport(msg, destport);
-
-	if (likely(destport || destnode)) {
-		if (likely(in_own_node(destnode)))
-			res = tipc_port_iovec_rcv(p_ptr, msg_sect, len);
-		else if (tipc_own_addr)
-			res = tipc_link_iovec_xmit_fast(p_ptr, msg_sect, len,
-							destnode);
-		else
-			res = tipc_port_iovec_reject(p_ptr, msg, msg_sect,
-						     len, TIPC_ERR_NO_NODE);
-		if (likely(res != -ELINKCONG)) {
-			if (res > 0)
-				p_ptr->sent++;
-			return res;
-		}
-		if (tipc_port_unreliable(p_ptr))
-			return len;
-
-		return -ELINKCONG;
-	}
-	return tipc_port_iovec_reject(p_ptr, msg, msg_sect, len,
-				      TIPC_ERR_NO_NAME);
-}
-
-/**
- * tipc_send2port - send message sections to port identity
- */
-int tipc_send2port(struct tipc_port *p_ptr,
-		   struct tipc_portid const *dest,
-		   struct iovec const *msg_sect,
-		   unsigned int len)
-{
-	struct tipc_msg *msg;
-	int res;
-
-	if (p_ptr->connected)
-		return -EINVAL;
-
-	msg = &p_ptr->phdr;
-	msg_set_type(msg, TIPC_DIRECT_MSG);
-	msg_set_lookup_scope(msg, 0);
-	msg_set_destnode(msg, dest->node);
-	msg_set_destport(msg, dest->ref);
-	msg_set_hdr_sz(msg, BASIC_H_SIZE);
-
-	if (in_own_node(dest->node))
-		res =  tipc_port_iovec_rcv(p_ptr, msg_sect, len);
-	else if (tipc_own_addr)
-		res = tipc_link_iovec_xmit_fast(p_ptr, msg_sect, len,
-						dest->node);
-	else
-		res = tipc_port_iovec_reject(p_ptr, msg, msg_sect, len,
-						TIPC_ERR_NO_NODE);
-	if (likely(res != -ELINKCONG)) {
-		if (res > 0)
-			p_ptr->sent++;
-		return res;
-	}
-	if (tipc_port_unreliable(p_ptr))
-		return len;
-
-	return -ELINKCONG;
-}
diff --git a/net/tipc/port.h b/net/tipc/port.h
index cf4ca5b..e566d55 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -140,17 +140,6 @@ int tipc_send(struct tipc_port *port,
 	      struct iovec const *msg_sect,
 	      unsigned int len);
 
-int tipc_send2name(struct tipc_port *port,
-		   struct tipc_name const *name,
-		   u32 domain,
-		   struct iovec const *msg_sect,
-		   unsigned int len);
-
-int tipc_send2port(struct tipc_port *port,
-		   struct tipc_portid const *dest,
-		   struct iovec const *msg_sect,
-		   unsigned int len);
-
 int tipc_port_mcast_xmit(struct tipc_port *port,
 			 struct tipc_name_seq const *seq,
 			 struct iovec const *msg,
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e642ed5..5690751 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -36,8 +36,9 @@
 
 #include "core.h"
 #include "port.h"
+#include "name_table.h"
 #include "node.h"
-
+#include "link.h"
 #include <linux/export.h>
 #include "link.h"
 
@@ -545,6 +546,8 @@ static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
 {
 	struct tipc_cfg_msg_hdr hdr;
 
+	if (unlikely(dest->addrtype == TIPC_ADDR_ID))
+		return 0;
 	if (likely(dest->addr.name.name.type >= TIPC_RESERVED_TYPES))
 		return 0;
 	if (likely(dest->addr.name.name.type == TIPC_TOP_SRV))
@@ -587,13 +590,49 @@ static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
 	return 0;
 }
 
+/**
+ * tipc_sendmcast - send multicast message
+ * @sock: socket structure
+ * @seq: destination address
+ * @iov: message data to send
+ * @dsz: total length of message data
+ * @timeo: timeout to wait for wakeup
+ *
+ * Called from function tipc_sendmsg(), which has done all sanity checks
+ * Returns the number of bytes sent on success, or errno
+ */
+static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
+			  struct iovec *iov, size_t dsz, long timeo)
+{
+	struct sock *sk = sock->sk;
+	struct tipc_sock *tsk = tipc_sk(sk);
+	int rc;
+
+	do {
+		if (sock->state != SS_READY) {
+			rc = -EOPNOTSUPP;
+			break;
+		}
+		rc = tipc_port_mcast_xmit(&tsk->port, seq, iov, dsz);
+		if (likely(rc >= 0)) {
+			if (sock->state != SS_READY)
+				sock->state = SS_CONNECTING;
+			break;
+		}
+		if (rc != -ELINKCONG)
+			break;
+		rc = tipc_wait_for_sndmsg(sock, &timeo);
+	} while (!rc);
+
+	return rc;
+}
 
 /**
  * tipc_sendmsg - send message in connectionless manner
  * @iocb: if NULL, indicates that socket lock is already held
  * @sock: socket structure
  * @m: message to send
- * @total_len: length of message
+ * @dsz: amount of user data to be sent
  *
  * Message must have an destination specified explicitly.
  * Used for SOCK_RDM and SOCK_DGRAM messages,
@@ -603,93 +642,116 @@ static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
  * Returns the number of bytes sent on success, or errno otherwise
  */
 static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *m, size_t total_len)
+			struct msghdr *m, size_t dsz)
 {
+	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_port *port = &tsk->port;
-	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
-	int needs_conn;
+	struct tipc_msg *mhdr = &port->phdr;
+	struct iovec *iov = m->msg_iov;
+	u32 dnode, dport;
+	struct sk_buff *buf;
+	struct tipc_name_seq *seq = &dest->addr.nameseq;
+	u32 mtu;
 	long timeo;
-	int res = -EINVAL;
+	int rc = -EINVAL;
 
 	if (unlikely(!dest))
 		return -EDESTADDRREQ;
+
 	if (unlikely((m->msg_namelen < sizeof(*dest)) ||
 		     (dest->family != AF_TIPC)))
 		return -EINVAL;
-	if (total_len > TIPC_MAX_USER_MSG_SIZE)
+
+	if (dsz > TIPC_MAX_USER_MSG_SIZE)
 		return -EMSGSIZE;
 
 	if (iocb)
 		lock_sock(sk);
 
-	needs_conn = (sock->state != SS_READY);
-	if (unlikely(needs_conn)) {
+	if (unlikely(sock->state != SS_READY)) {
 		if (sock->state == SS_LISTENING) {
-			res = -EPIPE;
+			rc = -EPIPE;
 			goto exit;
 		}
 		if (sock->state != SS_UNCONNECTED) {
-			res = -EISCONN;
+			rc = -EISCONN;
 			goto exit;
 		}
 		if (tsk->port.published) {
-			res = -EOPNOTSUPP;
+			rc = -EOPNOTSUPP;
 			goto exit;
 		}
 		if (dest->addrtype == TIPC_ADDR_NAME) {
 			tsk->port.conn_type = dest->addr.name.name.type;
 			tsk->port.conn_instance = dest->addr.name.name.instance;
 		}
-
-		/* Abort any pending connection attempts (very unlikely) */
-		reject_rx_queue(sk);
 	}
+	rc = dest_name_check(dest, m);
+	if (rc)
+		goto exit;
 
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
-	do {
-		if (dest->addrtype == TIPC_ADDR_NAME) {
-			res = dest_name_check(dest, m);
-			if (res)
-				break;
-			res = tipc_send2name(port,
-					     &dest->addr.name.name,
-					     dest->addr.name.domain,
-					     m->msg_iov,
-					     total_len);
-		} else if (dest->addrtype == TIPC_ADDR_ID) {
-			res = tipc_send2port(port,
-					     &dest->addr.id,
-					     m->msg_iov,
-					     total_len);
-		} else if (dest->addrtype == TIPC_ADDR_MCAST) {
-			if (needs_conn) {
-				res = -EOPNOTSUPP;
-				break;
-			}
-			res = dest_name_check(dest, m);
-			if (res)
-				break;
-			res = tipc_port_mcast_xmit(port,
-						   &dest->addr.nameseq,
-						   m->msg_iov,
-						   total_len);
+
+	if (dest->addrtype == TIPC_ADDR_MCAST) {
+		rc = tipc_sendmcast(sock, seq, iov, dsz, timeo);
+		goto exit;
+	} else if (dest->addrtype == TIPC_ADDR_NAME) {
+		u32 type = dest->addr.name.name.type;
+		u32 inst = dest->addr.name.name.instance;
+		u32 domain = dest->addr.name.domain;
+
+		dnode = domain;
+		msg_set_type(mhdr, TIPC_NAMED_MSG);
+		msg_set_hdr_sz(mhdr, NAMED_H_SIZE);
+		msg_set_nametype(mhdr, type);
+		msg_set_nameinst(mhdr, inst);
+		msg_set_lookup_scope(mhdr, tipc_addr_scope(domain));
+		dport = tipc_nametbl_translate(type, inst, &dnode);
+		msg_set_destnode(mhdr, dnode);
+		msg_set_destport(mhdr, dport);
+		if (unlikely(!dport && !dnode)) {
+			rc = -EHOSTUNREACH;
+			goto exit;
 		}
-		if (likely(res != -ELINKCONG)) {
-			if (needs_conn && (res >= 0))
+	} else if (dest->addrtype == TIPC_ADDR_ID) {
+		dnode = dest->addr.id.node;
+		msg_set_type(mhdr, TIPC_DIRECT_MSG);
+		msg_set_lookup_scope(mhdr, 0);
+		msg_set_destnode(mhdr, dnode);
+		msg_set_destport(mhdr, dest->addr.id.ref);
+		msg_set_hdr_sz(mhdr, BASIC_H_SIZE);
+	}
+
+new_mtu:
+	mtu = tipc_node_get_mtu(dnode, tsk->port.ref);
+	rc = tipc_msg_build2(mhdr, iov, 0, dsz, mtu, &buf);
+	if (rc < 0)
+		goto exit;
+
+	do {
+		rc = tipc_link_xmit2(buf, dnode, tsk->port.ref);
+		if (likely(rc >= 0)) {
+			if (sock->state != SS_READY)
 				sock->state = SS_CONNECTING;
+			rc = dsz;
 			break;
 		}
-		res = tipc_wait_for_sndmsg(sock, &timeo);
-		if (res)
+		if (rc == -EMSGSIZE)
+			goto new_mtu;
+
+		if (rc != -ELINKCONG)
 			break;
-	} while (1);
+
+		rc = tipc_wait_for_sndmsg(sock, &timeo);
+	} while (!rc);
 
 exit:
 	if (iocb)
 		release_sock(sk);
-	return res;
+
+	return rc;
 }
 
 static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
-- 
1.7.9.5
