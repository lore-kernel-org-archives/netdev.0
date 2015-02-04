From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v3 10/18] tipc: tipc ->sendmsg() conversion
Date: Wed,  4 Feb 2015 06:40:01 +0000
Message-ID: <1423032009-18367-10-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150204063730.GG29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43099 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbbBDGkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 01:40:12 -0500
In-Reply-To: <20150204063730.GG29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

This one needs to copy the same data from user potentially more than
once.  Sadly, MTU changes can trigger that ;-/

Cc: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/tipc/msg.c    |  7 ++-----
 net/tipc/socket.c | 14 ++++++++++++--
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 18aba9e..da67c8d 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -189,7 +189,6 @@ err:
  * tipc_msg_build - create buffer chain containing specified header and data
  * @mhdr: Message header, to be prepended to data
  * @m: User message
- * @offset: Posision in iov to start copying from
  * @dsz: Total length of user data
  * @pktmax: Max packet size that can be used
  * @list: Buffer or chain of buffers to be returned to caller
@@ -221,8 +220,7 @@ int tipc_msg_build(struct net *net, struct tipc_msg *mhdr, struct msghdr *m,
 		__skb_queue_tail(list, skb);
 		skb_copy_to_linear_data(skb, mhdr, mhsz);
 		pktpos = skb->data + mhsz;
-		if (!dsz || !memcpy_fromiovecend(pktpos, m->msg_iter.iov, offset,
-						 dsz))
+		if (copy_from_iter(pktpos, dsz, &m->msg_iter) == dsz)
 			return dsz;
 		rc = -EFAULT;
 		goto error;
@@ -252,12 +250,11 @@ int tipc_msg_build(struct net *net, struct tipc_msg *mhdr, struct msghdr *m,
 		if (drem < pktrem)
 			pktrem = drem;
 
-		if (memcpy_fromiovecend(pktpos, m->msg_iter.iov, offset, pktrem)) {
+		if (copy_from_iter(pktpos, pktrem, &m->msg_iter) != pktrem) {
 			rc = -EFAULT;
 			goto error;
 		}
 		drem -= pktrem;
-		offset += pktrem;
 
 		if (!drem)
 			break;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 679a220..caa4d66 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -733,6 +733,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 	struct net *net = sock_net(sk);
 	struct tipc_msg *mhdr = &tipc_sk(sk)->phdr;
 	struct sk_buff_head head;
+	struct iov_iter save = msg->msg_iter;
 	uint mtu;
 	int rc;
 
@@ -758,8 +759,10 @@ new_mtu:
 			rc = dsz;
 			break;
 		}
-		if (rc == -EMSGSIZE)
+		if (rc == -EMSGSIZE) {
+			msg->msg_iter = save;
 			goto new_mtu;
+		}
 		if (rc != -ELINKCONG)
 			break;
 		tipc_sk(sk)->link_cong = 1;
@@ -895,6 +898,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff_head head;
 	struct sk_buff *skb;
 	struct tipc_name_seq *seq = &dest->addr.nameseq;
+	struct iov_iter save;
 	u32 mtu;
 	long timeo;
 	int rc;
@@ -963,6 +967,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 		msg_set_hdr_sz(mhdr, BASIC_H_SIZE);
 	}
 
+	save = m->msg_iter;
 new_mtu:
 	mtu = tipc_node_get_mtu(net, dnode, tsk->portid);
 	__skb_queue_head_init(&head);
@@ -980,8 +985,10 @@ new_mtu:
 			rc = dsz;
 			break;
 		}
-		if (rc == -EMSGSIZE)
+		if (rc == -EMSGSIZE) {
+			m->msg_iter = save;
 			goto new_mtu;
+		}
 		if (rc != -ELINKCONG)
 			break;
 		tsk->link_cong = 1;
@@ -1052,6 +1059,7 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 	long timeo;
 	u32 dnode;
 	uint mtu, send, sent = 0;
+	struct iov_iter save;
 
 	/* Handle implied connection establishment */
 	if (unlikely(dest)) {
@@ -1078,6 +1086,7 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 	dnode = tsk_peer_node(tsk);
 
 next:
+	save = m->msg_iter;
 	mtu = tsk->max_pkt;
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
 	__skb_queue_head_init(&head);
@@ -1097,6 +1106,7 @@ next:
 			if (rc == -EMSGSIZE) {
 				tsk->max_pkt = tipc_node_get_mtu(net, dnode,
 								 portid);
+				m->msg_iter = save;
 				goto next;
 			}
 			if (rc != -ELINKCONG)
-- 
2.1.4
