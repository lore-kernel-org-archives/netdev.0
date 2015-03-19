From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 3/3] tipc: add support for
	connect() on dgram/rdm sockets
Date: Thu, 19 Mar 2015 09:02:19 +0100
Message-ID: <1426752139-31519-4-git-send-email-erik.hugne@ericsson.com>
References: <1426752139-31519-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <richard.alpe@ericsson.com>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1426752139-31519-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

Following the example of ip4_datagram_connect, we store the
address in the socket structure for dgram/rdm sockets and use
that as the default destination for subsequent send() calls.
It is allowed to connect to any address types, and the behaviour
of send() will be the same as a normal sendto() with this address
provided. Binding to an AF_UNSPEC address clears the association.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 38 ++++++++++++++++++++++++--------------
 1 file changed, 24 insertions(+), 14 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b6295c0..20b4f10 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -74,6 +74,7 @@
  * @link_cong: non-zero if owner must sleep because of link congestion
  * @sent_unacked: # messages sent by socket, and not yet acked by peer
  * @rcv_unacked: # messages read by user, but not yet acked back to peer
+ * @remote: 'connected' peer for dgram/rdm
  * @node: hash table node
  * @rcu: rcu struct for tipc_sock
  */
@@ -96,6 +97,7 @@ struct tipc_sock {
 	bool link_cong;
 	uint sent_unacked;
 	uint rcv_unacked;
+	struct sockaddr_tipc remote;
 	struct rhash_head node;
 	struct rcu_head rcu;
 };
@@ -854,22 +856,23 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 	u32 dnode, dport;
 	struct sk_buff_head *pktchain = &sk->sk_write_queue;
 	struct sk_buff *skb;
-	struct tipc_name_seq *seq = &dest->addr.nameseq;
+	struct tipc_name_seq *seq;
 	struct iov_iter save;
 	u32 mtu;
 	long timeo;
 	int rc;
 
-	if (unlikely(!dest))
-		return -EDESTADDRREQ;
-
-	if (unlikely((m->msg_namelen < sizeof(*dest)) ||
-		     (dest->family != AF_TIPC)))
-		return -EINVAL;
-
 	if (dsz > TIPC_MAX_USER_MSG_SIZE)
 		return -EMSGSIZE;
-
+	if (unlikely(!dest)) {
+		if (tsk->connected && sock->state == SS_READY)
+			dest = &tsk->remote;
+		else
+			return -EDESTADDRREQ;
+	} else if (unlikely(m->msg_namelen < sizeof(*dest)) ||
+		   dest->family != AF_TIPC) {
+		return -EINVAL;
+	}
 	if (unlikely(sock->state != SS_READY)) {
 		if (sock->state == SS_LISTENING)
 			return -EPIPE;
@@ -882,7 +885,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 			tsk->conn_instance = dest->addr.name.name.instance;
 		}
 	}
-
+	seq = &dest->addr.nameseq;
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
 
 	if (dest->addrtype == TIPC_ADDR_MCAST) {
@@ -1833,17 +1836,24 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 			int destlen, int flags)
 {
 	struct sock *sk = sock->sk;
+	struct tipc_sock *tsk = tipc_sk(sk);
 	struct sockaddr_tipc *dst = (struct sockaddr_tipc *)dest;
 	struct msghdr m = {NULL,};
-	long timeout = (flags & O_NONBLOCK) ? 0 : tipc_sk(sk)->conn_timeout;
+	long timeout = (flags & O_NONBLOCK) ? 0 : tsk->conn_timeout;
 	socket_state previous;
-	int res;
+	int res = 0;
 
 	lock_sock(sk);
 
-	/* For now, TIPC does not allow use of connect() with DGRAM/RDM types */
+	/* DGRAM/RDM connect(), just save the destaddr */
 	if (sock->state == SS_READY) {
-		res = -EOPNOTSUPP;
+		if (dst->family == AF_UNSPEC) {
+			memset(&tsk->remote, 0, sizeof(struct sockaddr_tipc));
+			tsk->connected = 0;
+		} else {
+			memcpy(&tsk->remote, dest, destlen);
+			tsk->connected = 1;
+		}
 		goto exit;
 	}
 
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
