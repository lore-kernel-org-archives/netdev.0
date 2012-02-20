From: Javier Martinez Canillas <javier@collabora.co.uk>
Subject: [PATCH 09/10] Allow server side of SOCK_SEQPACKET sockets to accept a new member on the multicast groujoin seqpacket multicast group
Date: Mon, 20 Feb 2012 17:33:48 +0100
Message-ID: <1329755629-10644-6-git-send-email-javier@collabora.co.uk>
References: <1329755629-10644-1-git-send-email-javier@collabora.co.uk>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	Bart Cerneels <bart.cerneels@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329755629-10644-1-git-send-email-javier@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 include/net/af_unix.h |    2 +
 net/unix/af_unix.c    |  145 ++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 116 insertions(+), 31 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index c543f76..80e793d 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -48,6 +48,7 @@ struct unix_skb_parms {
 #define UNIX_CREATE_GROUP	1
 #define UNIX_JOIN_GROUP		2
 #define UNIX_LEAVE_GROUP	3
+#define UNIX_ACCEPT_GROUP	4
 
 /* Flags on unix_mreq */
 
@@ -115,6 +116,7 @@ struct unix_sock {
 	unsigned int		gc_maybe_cycle : 1;
 	unsigned int		mcast_send_to_peer : 1;
 	unsigned int		mcast_drop_when_peer_full : 1;
+	unsigned int		mcast_multicast_delivery : 1;
 	unsigned char		recursion_level;
 	struct unix_mcast_group	*mcast_group;
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 07e6b05..330c0a2 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -759,6 +759,8 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 	mutex_init(&u->readlock); /* single task reading lock */
 #ifdef CONFIG_UNIX_MULTICAST
 	INIT_HLIST_HEAD(&u->mcast_subscriptions);
+	u->mcast_group = NULL;
+	u->mcast_multicast_delivery = 0;
 #endif
 	init_waitqueue_head(&u->peer_wait);
 	unix_insert_socket(unix_sockets_unbound, sk);
@@ -1345,10 +1347,6 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	struct sock *newsk = NULL;
 	struct sock *other = NULL;
 	struct sk_buff *skb = NULL;
-#ifdef CONFIG_UNIX_MULTICAST
-	struct unix_mcast *node;
-	struct hlist_node *pos;
-#endif
 	unsigned hash;
 	int st;
 	int err;
@@ -1464,14 +1462,11 @@ restart:
 
 #ifdef CONFIG_UNIX_MULTICAST
 	/* Multicast sockets */
-	hlist_for_each_entry_rcu(node, pos, &u->mcast_subscriptions,
-				 subscription_node) {
-		if (node->group == otheru->mcast_group) {
-			atomic_inc(&otheru->mcast_group->refcnt);
-			newu->mcast_group = otheru->mcast_group;
-			break;
-		}
+	if (otheru->mcast_group) {
+		atomic_inc(&otheru->mcast_group->refcnt);
+		newu->mcast_group = otheru->mcast_group;
 	}
+	newu->mcast_multicast_delivery = 0;
 #endif
 
 	/* The way is open! Fastly set all the necessary fields... */
@@ -1976,7 +1971,8 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out;
 
 #ifdef CONFIG_UNIX_MULTICAST
-		group = unix_sk(other)->mcast_group;
+		group = unix_sk(other)->mcast_multicast_delivery ?
+			unix_sk(other)->mcast_group : NULL;
 		if (group) {
 			others_set = unix_find_multicast_recipients(sk,
 				group, &err);
@@ -2024,7 +2020,8 @@ restart:
 			goto out_free;
 
 #ifdef CONFIG_UNIX_MULTICAST
-		group = unix_sk(other)->mcast_group;
+		group = unix_sk(other)->mcast_multicast_delivery ?
+			unix_sk(other)->mcast_group : NULL;
 		if (group) {
 			others_set = unix_find_multicast_recipients(sk,
 				group, &err);
@@ -2184,6 +2181,7 @@ static int unix_mc_create(struct socket *sock, struct unix_mreq *mreq)
 
 	unix_state_lock(sock->sk);
 	unix_sk(sock->sk)->mcast_group = mcast_group;
+	unix_sk(sock->sk)->mcast_multicast_delivery = 1;
 	unix_state_unlock(sock->sk);
 
 	return 0;
@@ -2192,8 +2190,9 @@ static int unix_mc_create(struct socket *sock, struct unix_mreq *mreq)
 
 static int unix_mc_join(struct socket *sock, struct unix_mreq *mreq)
 {
-	struct unix_sock *u = unix_sk(sock->sk);
-	struct sock *other, *peer;
+	struct unix_sock *u;
+	struct sock *other = NULL;
+	struct sock *peer = NULL;
 	struct unix_mcast_group *group;
 	struct unix_mcast *node;
 	int err;
@@ -2204,8 +2203,12 @@ static int unix_mc_join(struct socket *sock, struct unix_mreq *mreq)
 	    mreq->address.sun_path[0] != '\0')
 		return -EINVAL;
 
-	/* sockets which represent a group are not allowed to join another
-	 * group */
+	if (sock->type != SOCK_DGRAM)
+		return -EINVAL;
+
+	/* sockets which represent a group are not allowed to join
+	 * another group */
+	u = unix_sk(sock->sk);
 	if (u->mcast_group)
 		return -EINVAL;
 
@@ -2213,16 +2216,16 @@ static int unix_mc_join(struct socket *sock, struct unix_mreq *mreq)
 	if (err < 0)
 		return err;
 
-	err = unix_mkname(&mreq->address, sizeof(struct sockaddr_un), &hash);
+	err = unix_mkname(&mreq->address, sizeof(struct sockaddr_un),
+			  &hash);
 	if (err < 0)
 		return err;
 
 	namelen = err;
-	other = unix_find_other(sock_net(sock->sk), &mreq->address, namelen,
-				sock->type, hash, &err);
+	other = unix_find_other(sock_net(sock->sk), &mreq->address,
+				namelen, sock->type, hash, &err);
 	if (!other)
 		return -EINVAL;
-
 	group = unix_sk(other)->mcast_group;
 
 	if (!group) {
@@ -2239,15 +2242,6 @@ static int unix_mc_join(struct socket *sock, struct unix_mreq *mreq)
 	node->group = group;
 	node->flags = mreq->flags;
 
-	if (sock->sk->sk_type == SOCK_SEQPACKET) {
-		peer = unix_peer_get(sock->sk);
-		if (peer) {
-			atomic_inc(&group->refcnt);
-			unix_sk(peer)->mcast_group = group;
-			sock_put(peer);
-		}
-	}
-
 	unix_state_lock(sock->sk);
 	unix_sk(sock->sk)->mcast_send_to_peer =
 		!!(mreq->flags & UNIX_MREQ_SEND_TO_PEER);
@@ -2270,7 +2264,87 @@ static int unix_mc_join(struct socket *sock, struct unix_mreq *mreq)
 	return 0;
 
 sock_put_out:
-	sock_put(other);
+	if (other)
+		sock_put(other);
+	if (peer)
+		sock_put(peer);
+	return err;
+}
+
+static int unix_mc_accept(struct socket *sock, struct unix_mreq *mreq)
+{
+	struct unix_sock *u = unix_sk(sock->sk);
+	struct unix_sock *peeru;
+	struct sock *peer = NULL;
+	struct unix_mcast_group *group;
+	struct unix_mcast *node;
+	int err;
+
+	if (mreq->address.sun_family != AF_UNIX ||
+	    mreq->address.sun_path[0] != '\0')
+		return -EINVAL;
+
+	if (sock->type != SOCK_SEQPACKET)
+		return -EINVAL;
+
+	/* The reference is kept as long as peer is member of the group */
+	peer = unix_peer_get(sock->sk);
+	if (!peer)
+		return -ENOTCONN;
+	peeru = unix_sk(peer);
+
+	if (sock->sk->sk_state != TCP_ESTABLISHED)
+		return -ENOTCONN;
+
+	if (peer->sk_shutdown != 0) {
+		err = -ENOTCONN;
+		goto sock_put_out;
+	}
+
+	group = u->mcast_group;
+	if (!group) {
+		err = -EINVAL;
+		goto sock_put_out;
+	}
+
+	node = kmalloc(sizeof(struct unix_mcast), GFP_KERNEL);
+	if (!node) {
+		err = -ENOMEM;
+		goto sock_put_out;
+	}
+	node->member = peeru;
+	node->group = group;
+	node->flags = mreq->flags;
+
+	unix_state_lock(peer);
+	peeru->mcast_send_to_peer =
+		!!(mreq->flags & UNIX_MREQ_SEND_TO_PEER);
+	peeru->mcast_drop_when_peer_full =
+		!!(mreq->flags & UNIX_MREQ_DROP_WHEN_FULL);
+	unix_state_unlock(peer);
+
+	unix_state_lock(sock->sk);
+	u->mcast_multicast_delivery = 1;
+	unix_state_unlock(sock->sk);
+
+	/* Keep a reference for the socket and the peer */
+	atomic_inc(&group->refcnt);
+	atomic_inc(&group->refcnt);
+
+	spin_lock(&unix_multicast_lock);
+	hlist_add_head_rcu(&node->member_node,
+			   &group->mcast_members);
+	hlist_add_head_rcu(&node->subscription_node,
+			   &peeru->mcast_subscriptions);
+	atomic_inc(&group->mcast_members_cnt);
+	atomic_inc(&group->mcast_membership_generation);
+	spin_unlock(&unix_multicast_lock);
+
+	return 0;
+
+sock_put_out:
+	if (peer)
+		sock_put(peer);
 	return err;
 }
 
@@ -2290,6 +2364,9 @@ static int unix_mc_leave(struct socket *sock, struct unix_mreq *mreq)
 	    mreq->address.sun_path[0] != '\0')
 		return -EINVAL;
 
+	if (sock->type != SOCK_DGRAM)
+		return -EINVAL;
+
 	err = unix_mkname(&mreq->address, sizeof(struct sockaddr_un), &hash);
 	if (err < 0)
 		return err;
@@ -2333,6 +2410,7 @@ static int unix_mc_leave(struct socket *sock, struct unix_mreq *mreq)
 		struct sock *peer = unix_peer_get(sock->sk);
 		if (peer) {
 			unix_sk(peer)->mcast_group = NULL;
+			unix_sk(peer)->mcast_multicast_delivery = 0;
 			atomic_dec(&group->refcnt);
 			sock_put(peer);
 		}
@@ -2373,6 +2451,7 @@ static int unix_setsockopt(struct socket *sock, int level, int optname,
 	case UNIX_CREATE_GROUP:
 	case UNIX_JOIN_GROUP:
 	case UNIX_LEAVE_GROUP:
+	case UNIX_ACCEPT_GROUP:
 		if (optlen < sizeof(struct unix_mreq))
 			return -EINVAL;
 		if (copy_from_user(&mreq, optval, sizeof(struct unix_mreq)))
@@ -2396,6 +2475,10 @@ static int unix_setsockopt(struct socket *sock, int level, int optname,
 		err = unix_mc_leave(sock, &mreq);
 		break;
 
+	case UNIX_ACCEPT_GROUP:
+		err = unix_mc_accept(sock, &mreq);
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
-- 
1.7.7.6
