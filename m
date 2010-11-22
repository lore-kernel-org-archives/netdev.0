From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 8/9] AF_UNIX: add options on multicast connected socket
Date: Mon, 22 Nov 2010 18:36:21 +0000
Message-ID: <1290450982-17480-8-git-send-email-alban.crequy@collabora.co.uk>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

autojoin and send-to-peer

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 include/net/af_unix.h |   27 +++++++++++++++++++++------
 net/unix/af_unix.c    |   44 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 64 insertions(+), 7 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index bf114d5..c82b5f8 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -40,18 +40,31 @@ struct unix_skb_parms {
 				spin_lock_nested(&unix_sk(s)->lock, \
 				SINGLE_DEPTH_NESTING)
 
-#define UNIX_MREQ_LOOPBACK	0x01
+/* UNIX socket options */
+#define UNIX_CREATE_GROUP	1
+#define UNIX_JOIN_GROUP		2
+#define UNIX_LEAVE_GROUP	3
+
+/* Flags on unix_mreq */
+
+/* On UNIX_JOIN_GROUP: the socket will receive its own messages
+ * On UNIX_CREATE_GROUP: the accepted sockets will receive their own messages
+ */
+#define UNIX_MREQ_LOOPBACK		0x01
+
+/* On UNIX_CREATE_GROUP: the accepted socket will be member of the multicast
+ * group */
+#define UNIX_MREQ_AUTOJOIN		0x02
+
+/* ON UNIX_JOIN_GROUP: the messages will also be received by the peer */
+#define UNIX_MREQ_SEND_TO_PEER		0x04
+
 struct unix_mreq
 {
 	struct sockaddr_un	address;
 	unsigned int		flags;
 };
 
-/* UNIX socket options */
-#define UNIX_CREATE_GROUP	1
-#define UNIX_JOIN_GROUP		2
-#define UNIX_LEAVE_GROUP	3
-
 #ifdef __KERNEL__
 /* The AF_UNIX socket */
 struct unix_sock {
@@ -69,6 +82,8 @@ struct unix_sock {
 	unsigned int		gc_candidate : 1;
 	unsigned int		gc_maybe_cycle : 1;
 	unsigned int		is_mcast_addr : 1;
+	unsigned int		mcast_auto_join : 1;
+	unsigned int		mcast_send_to_peer : 1;
 
 	/* These multicast fields are protected by the global spinlock
 	 * unix_multicast_lock */
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 52e2aa2..d3d6270 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -878,6 +878,17 @@ static int unix_find_multicast_members(struct sock_set *set,
 		set->items[set->cnt].to_deliver = 1;
 		set->cnt++;
 	}
+
+	if (unix_peer(sender) && unix_sk(sender)->mcast_send_to_peer) {
+		if (set->cnt + 1 > recipient_cnt)
+			return -ENOMEM;
+		sock_hold(unix_peer(sender));
+		set->items[set->cnt].s = unix_peer(sender);
+		set->items[set->cnt].skb = NULL;
+		set->items[set->cnt].to_deliver = 1;
+		set->cnt++;
+	}
+
 	return 0;
 }
 
@@ -1226,6 +1237,7 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	int st;
 	int err;
 	long timeo;
+	struct unix_mcast *node = NULL;
 
 	err = unix_mkname(sunaddr, addr_len, &hash);
 	if (err < 0)
@@ -1245,6 +1257,12 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 
 	err = -ENOMEM;
 
+	node = kmalloc(sizeof(struct unix_mcast), GFP_KERNEL);
+	if (!node) {
+		err = -ENOMEM;
+		goto out;
+	}
+
 	/* create new sock for complete connection */
 	newsk = unix_create1(sock_net(sk), NULL);
 	if (newsk == NULL)
@@ -1261,6 +1279,8 @@ restart:
 	if (!other)
 		goto out;
 
+	otheru = unix_sk(other);
+
 	/* Latch state of peer */
 	unix_state_lock(other);
 
@@ -1332,6 +1352,21 @@ restart:
 		goto out_unlock;
 	}
 
+	/* Multicast sockets */
+	spin_lock(&unix_multicast_lock);
+	if (otheru->is_mcast_addr && otheru->mcast_auto_join) {
+		node->member = unix_sk(newsk);
+		node->addr = otheru;
+		node->flags = 0;
+
+		hlist_add_head(&node->member_node, &otheru->mcast_members);
+		hlist_add_head(&node->subscription_node,
+			       &unix_sk(newsk)->mcast_subscriptions);
+		otheru->mcast_members_cnt++;
+		u->mcast_subscriptions_cnt++;
+	}
+	spin_unlock(&unix_multicast_lock);
+
 	/* The way is open! Fastly set all the necessary fields... */
 
 	sock_hold(sk);
@@ -1341,7 +1376,6 @@ restart:
 	init_peercred(newsk);
 	newu = unix_sk(newsk);
 	newsk->sk_wq		= &newu->peer_wq;
-	otheru = unix_sk(other);
 
 	/* copy address information from listening to new sock*/
 	if (otheru->addr) {
@@ -1380,6 +1414,8 @@ out_unlock:
 
 out:
 	kfree_skb(skb);
+	if (node)
+		kfree(node);
 	if (newsk)
 		unix_release_sock(newsk, 0);
 	if (other)
@@ -1868,6 +1904,8 @@ static int unix_mc_create(struct socket *sock, struct unix_mreq *mreq)
 
 	unix_state_lock(sock->sk);
 	unix_sk(sock->sk)->is_mcast_addr = 1;
+	if (mreq->flags & UNIX_MREQ_AUTOJOIN)
+		unix_sk(sock->sk)->mcast_auto_join = 1;
 	unix_state_unlock(sock->sk);
 
 	return 0;
@@ -1918,6 +1956,10 @@ static int unix_mc_join(struct socket *sock, struct unix_mreq *mreq)
 	node->addr = otheru;
 	node->flags = mreq->flags;
 
+	unix_state_lock(sock->sk);
+	unix_sk(sock->sk)->mcast_send_to_peer = !!(mreq->flags & UNIX_MREQ_SEND_TO_PEER);
+	unix_state_unlock(sock->sk);
+
 	spin_lock(&unix_multicast_lock);
 	hlist_add_head(&node->member_node, &otheru->mcast_members);
 	hlist_add_head(&node->subscription_node, &u->mcast_subscriptions);
-- 
1.7.1
