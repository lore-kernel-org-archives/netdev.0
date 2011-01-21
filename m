From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 4/8] af_unix: create, join and leave multicast groups with setsockopt
Date: Fri, 21 Jan 2011 14:39:44 +0000
Message-ID: <1295620788-6002-4-git-send-email-alban.crequy@collabora.co.uk>
References: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	Ian Molton <ian.molton@collabora.co.uk>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Multicast is implemented on SOCK_DGRAM and SOCK_SEQPACKET unix sockets.

An userspace application can create a multicast group with:
  struct unix_mreq mreq;
  mreq.address.sun_family = AF_UNIX;
  mreq.address.sun_path[0] = '\0';
  strcpy(mreq.address.sun_path + 1, "socket-address");
  mreq.flags = 0;

  sockfd = socket(AF_UNIX, SOCK_DGRAM, 0);
  ret = setsockopt(sockfd, SOL_UNIX, UNIX_CREATE_GROUP, &mreq, sizeof(mreq));

Then a multicast group can be joined and left with:
  ret = setsockopt(sockfd, SOL_UNIX, UNIX_JOIN_GROUP, &mreq, sizeof(mreq));
  ret = setsockopt(sockfd, SOL_UNIX, UNIX_LEAVE_GROUP, &mreq, sizeof(mreq));

A socket can be a member of several multicast group.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Signed-off-by: Ian Molton <ian.molton@collabora.co.uk>
---
 include/net/af_unix.h |   77 +++++++++++
 net/unix/Kconfig      |   10 ++
 net/unix/af_unix.c    |  339 ++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 424 insertions(+), 2 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 18e5c3f..f2b605b 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -41,7 +41,62 @@ struct unix_skb_parms {
 				spin_lock_nested(&unix_sk(s)->lock, \
 				SINGLE_DEPTH_NESTING)
 
+/* UNIX socket options */
+#define UNIX_CREATE_GROUP	1
+#define UNIX_JOIN_GROUP		2
+#define UNIX_LEAVE_GROUP	3
+
+/* Flags on unix_mreq */
+
+/* On UNIX_JOIN_GROUP: the socket will receive its own messages */
+#define UNIX_MREQ_LOOPBACK		0x01
+
+/* ON UNIX_JOIN_GROUP: the messages will also be received by the peer */
+#define UNIX_MREQ_SEND_TO_PEER		0x02
+
+/* ON UNIX_JOIN_GROUP: just drop the message instead of blocking if the
+ * receiving queue is full */
+#define UNIX_MREQ_DROP_WHEN_FULL	0x04
+
+struct unix_mreq {
+	struct sockaddr_un	address;
+	unsigned int		flags;
+};
+
 #ifdef __KERNEL__
+
+struct unix_mcast_group {
+	/* RCU list of (struct unix_mcast)->member_node
+	 * Messages sent to the multicast group are delivered to this list of
+	 * members */
+	struct hlist_head	mcast_members;
+
+	/* RCU list of (struct unix_mcast)->member_dead_node
+	 * When the group dies, previous members' reference counters must be
+	 * decremented */
+	struct hlist_head	mcast_dead_members;
+
+	/* RCU list of (struct sock_set)->list */
+	struct hlist_head	mcast_members_lists;
+
+	atomic_t		mcast_members_cnt;
+
+	/* The generation is incremented each time a peer joins or
+	 * leaves the group. It is used to invalidate old lists
+	 * struct sock_set */
+	atomic_t		mcast_membership_generation;
+
+	/* Locks to guarantee causal order in deliveries */
+#define MCAST_LOCK_CLASS_COUNT	8
+	spinlock_t		lock[MCAST_LOCK_CLASS_COUNT];
+
+	/* The group is referenced by:
+	 * - the socket who created the multicast group
+	 * - the accepted sockets (SOCK_SEQPACKET only)
+	 * - the current members of the group */
+	atomic_t		refcnt;
+};
+
 /* The AF_UNIX socket */
 struct unix_sock {
 	/* WARNING: sk has to be the first member */
@@ -57,9 +112,31 @@ struct unix_sock {
 	spinlock_t		lock;
 	unsigned int		gc_candidate : 1;
 	unsigned int		gc_maybe_cycle : 1;
+	unsigned int		mcast_send_to_peer : 1;
+	unsigned int		mcast_drop_when_peer_full : 1;
 	unsigned char		recursion_level;
+	struct unix_mcast_group	*mcast_group;
+
+	/* RCU List of (struct unix_mcast)->subscription_node
+	 * A socket can subscribe to several multicast group
+	 */
+	struct hlist_head	mcast_subscriptions;
+
 	struct socket_wq	peer_wq;
 };
+
+struct unix_mcast {
+	struct unix_sock	*member;
+	struct unix_mcast_group	*group;
+	unsigned int		flags;
+	struct hlist_node	subscription_node;
+	/* A subscription cannot be both alive and dead but we cannot use the
+	 * same field because RCU readers run lockless. member_dead_node is
+	 * not read by lockless RCU readers. */
+	struct hlist_node	member_node;
+	struct hlist_node	member_dead_node;
+};
+
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
 #define peer_wait peer_wq.wait
diff --git a/net/unix/Kconfig b/net/unix/Kconfig
index 5a69733..e3e5d9b 100644
--- a/net/unix/Kconfig
+++ b/net/unix/Kconfig
@@ -19,3 +19,13 @@ config UNIX
 
 	  Say Y unless you know what you are doing.
 
+config UNIX_MULTICAST
+	depends on UNIX && EXPERIMENTAL
+	bool "Multicast over Unix domain sockets"
+	---help---
+	  If you say Y here, you will include support for multicasting on Unix
+	  domain sockets. Support is available for SOCK_DGRAM and
+	  SOCK_SEQPACKET. Certain types of delivery synchronisation are
+	  provided, see Documentation/networking/multicast-unix-sockets.txt
+
+
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7ea85de..f25c020 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -117,6 +117,9 @@
 
 static struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 static DEFINE_SPINLOCK(unix_table_lock);
+#ifdef CONFIG_UNIX_MULTICAST
+static DEFINE_SPINLOCK(unix_multicast_lock);
+#endif
 static atomic_long_t unix_nr_socks;
 
 #define unix_sockets_unbound	(&unix_socket_table[UNIX_HASH_SIZE])
@@ -371,6 +374,28 @@ static void unix_sock_destructor(struct sock *sk)
 #endif
 }
 
+#ifdef CONFIG_UNIX_MULTICAST
+static void
+destroy_mcast_group(struct unix_mcast_group *group)
+{
+	struct unix_mcast *node;
+	struct hlist_node *pos;
+	struct hlist_node *pos_tmp;
+
+	BUG_ON(atomic_read(&group->refcnt) != 0);
+	BUG_ON(!hlist_empty(&group->mcast_members));
+
+	hlist_for_each_entry_safe(node, pos, pos_tmp,
+				  &group->mcast_dead_members,
+				  member_dead_node) {
+		hlist_del_rcu(&node->member_dead_node);
+		sock_put(&node->member->sk);
+		kfree(node);
+	}
+	kfree(group);
+}
+#endif
+
 static int unix_release_sock(struct sock *sk, int embrion)
 {
 	struct unix_sock *u = unix_sk(sk);
@@ -379,6 +404,11 @@ static int unix_release_sock(struct sock *sk, int embrion)
 	struct sock *skpair;
 	struct sk_buff *skb;
 	int state;
+#ifdef CONFIG_UNIX_MULTICAST
+	struct unix_mcast *node;
+	struct hlist_node *pos;
+	struct hlist_node *pos_tmp;
+#endif
 
 	unix_remove_socket(sk);
 
@@ -392,6 +422,23 @@ static int unix_release_sock(struct sock *sk, int embrion)
 	u->mnt	     = NULL;
 	state = sk->sk_state;
 	sk->sk_state = TCP_CLOSE;
+#ifdef CONFIG_UNIX_MULTICAST
+	spin_lock(&unix_multicast_lock);
+	hlist_for_each_entry_safe(node, pos, pos_tmp, &u->mcast_subscriptions,
+				  subscription_node) {
+		hlist_del_rcu(&node->member_node);
+		hlist_del_rcu(&node->subscription_node);
+		atomic_dec(&node->group->mcast_members_cnt);
+		atomic_inc(&node->group->mcast_membership_generation);
+		hlist_add_head_rcu(&node->member_dead_node,
+				   &node->group->mcast_dead_members);
+		if (atomic_dec_and_test(&node->group->refcnt))
+			destroy_mcast_group(node->group);
+	}
+	if (u->mcast_group && atomic_dec_and_test(&u->mcast_group->refcnt))
+		destroy_mcast_group(u->mcast_group);
+	spin_unlock(&unix_multicast_lock);
+#endif
 	unix_state_unlock(sk);
 
 	wake_up_interruptible_all(&u->peer_wait);
@@ -631,6 +678,9 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 	atomic_long_set(&u->inflight, 0);
 	INIT_LIST_HEAD(&u->link);
 	mutex_init(&u->readlock); /* single task reading lock */
+#ifdef CONFIG_UNIX_MULTICAST
+	INIT_HLIST_HEAD(&u->mcast_subscriptions);
+#endif
 	init_waitqueue_head(&u->peer_wait);
 	unix_insert_socket(unix_sockets_unbound, sk);
 out:
@@ -1055,6 +1105,10 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	struct sock *newsk = NULL;
 	struct sock *other = NULL;
 	struct sk_buff *skb = NULL;
+#ifdef CONFIG_UNIX_MULTICAST
+	struct unix_mcast *node;
+	struct hlist_node *pos;
+#endif
 	unsigned hash;
 	int st;
 	int err;
@@ -1082,6 +1136,7 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	newsk = unix_create1(sock_net(sk), NULL);
 	if (newsk == NULL)
 		goto out;
+	newu = unix_sk(newsk);
 
 	/* Allocate skb for sending to listening sock */
 	skb = sock_wmalloc(newsk, 1, 0, GFP_KERNEL);
@@ -1094,6 +1149,8 @@ restart:
 	if (!other)
 		goto out;
 
+	otheru = unix_sk(other);
+
 	/* Latch state of peer */
 	unix_state_lock(other);
 
@@ -1165,6 +1222,18 @@ restart:
 		goto out_unlock;
 	}
 
+#ifdef CONFIG_UNIX_MULTICAST
+	/* Multicast sockets */
+	hlist_for_each_entry_rcu(node, pos, &u->mcast_subscriptions,
+				 subscription_node) {
+		if (node->group == otheru->mcast_group) {
+			atomic_inc(&otheru->mcast_group->refcnt);
+			newu->mcast_group = otheru->mcast_group;
+			break;
+		}
+	}
+#endif
+
 	/* The way is open! Fastly set all the necessary fields... */
 
 	sock_hold(sk);
@@ -1172,9 +1241,7 @@ restart:
 	newsk->sk_state		= TCP_ESTABLISHED;
 	newsk->sk_type		= sk->sk_type;
 	init_peercred(newsk);
-	newu = unix_sk(newsk);
 	newsk->sk_wq		= &newu->peer_wq;
-	otheru = unix_sk(other);
 
 	/* copy address information from listening to new sock*/
 	if (otheru->addr) {
@@ -1563,10 +1630,278 @@ out:
 }
 
 
+#ifdef CONFIG_UNIX_MULTICAST
+static int unix_mc_create(struct socket *sock, struct unix_mreq *mreq)
+{
+	struct sock *other;
+	int err;
+	unsigned hash;
+	int namelen;
+	struct unix_mcast_group *mcast_group;
+	int i;
+
+	if (mreq->address.sun_family != AF_UNIX ||
+	    mreq->address.sun_path[0] != '\0')
+		return -EINVAL;
+
+	err = unix_mkname(&mreq->address, sizeof(struct sockaddr_un), &hash);
+	if (err < 0)
+		return err;
+
+	namelen = err;
+	other = unix_find_other(sock_net(sock->sk), &mreq->address, namelen,
+				sock->type, hash, &err);
+	if (other) {
+		sock_put(other);
+		return -EADDRINUSE;
+	}
+
+	mcast_group = kmalloc(sizeof(struct unix_mcast_group), GFP_KERNEL);
+	if (!mcast_group)
+		return -ENOBUFS;
+
+	INIT_HLIST_HEAD(&mcast_group->mcast_members);
+	INIT_HLIST_HEAD(&mcast_group->mcast_dead_members);
+	INIT_HLIST_HEAD(&mcast_group->mcast_members_lists);
+	atomic_set(&mcast_group->mcast_members_cnt, 0);
+	atomic_set(&mcast_group->mcast_membership_generation, 1);
+	atomic_set(&mcast_group->refcnt, 1);
+	for (i = 0 ; i < MCAST_LOCK_CLASS_COUNT ; i++) {
+		spin_lock_init(&mcast_group->lock[i]);
+		lockdep_set_subclass(&mcast_group->lock[i], i);
+	}
+
+	err = sock->ops->bind(sock,
+		(struct sockaddr *)&mreq->address,
+		sizeof(struct sockaddr_un));
+	if (err < 0) {
+		kfree(mcast_group);
+		return err;
+	}
+
+	unix_state_lock(sock->sk);
+	unix_sk(sock->sk)->mcast_group = mcast_group;
+	unix_state_unlock(sock->sk);
+
+	return 0;
+}
+
+
+static int unix_mc_join(struct socket *sock, struct unix_mreq *mreq)
+{
+	struct unix_sock *u = unix_sk(sock->sk);
+	struct sock *other, *peer;
+	struct unix_mcast_group *group;
+	struct unix_mcast *node;
+	int err;
+	unsigned hash;
+	int namelen;
+
+	if (mreq->address.sun_family != AF_UNIX ||
+	    mreq->address.sun_path[0] != '\0')
+		return -EINVAL;
+
+	/* sockets which represent a group are not allowed to join another
+	 * group */
+	if (u->mcast_group)
+		return -EINVAL;
+
+	err = unix_autobind(sock);
+	if (err < 0)
+		return err;
+
+	err = unix_mkname(&mreq->address, sizeof(struct sockaddr_un), &hash);
+	if (err < 0)
+		return err;
+
+	namelen = err;
+	other = unix_find_other(sock_net(sock->sk), &mreq->address, namelen,
+				sock->type, hash, &err);
+	if (!other)
+		return -EINVAL;
+
+	group = unix_sk(other)->mcast_group;
+
+	if (!group) {
+		err = -EADDRINUSE;
+		goto sock_put_out;
+	}
+
+	node = kmalloc(sizeof(struct unix_mcast), GFP_KERNEL);
+	if (!node) {
+		err = -ENOMEM;
+		goto sock_put_out;
+	}
+	node->member = u;
+	node->group = group;
+	node->flags = mreq->flags;
+
+	if (sock->sk->sk_type == SOCK_SEQPACKET) {
+		peer = unix_peer_get(sock->sk);
+		if (peer) {
+			atomic_inc(&group->refcnt);
+			unix_sk(peer)->mcast_group = group;
+			sock_put(peer);
+		}
+	}
+
+	unix_state_lock(sock->sk);
+	unix_sk(sock->sk)->mcast_send_to_peer =
+		!!(mreq->flags & UNIX_MREQ_SEND_TO_PEER);
+	unix_sk(sock->sk)->mcast_drop_when_peer_full =
+		!!(mreq->flags & UNIX_MREQ_DROP_WHEN_FULL);
+	unix_state_unlock(sock->sk);
+
+	/* Keep a reference */
+	sock_hold(sock->sk);
+	atomic_inc(&group->refcnt);
+
+	spin_lock(&unix_multicast_lock);
+	hlist_add_head_rcu(&node->member_node,
+			   &group->mcast_members);
+	hlist_add_head_rcu(&node->subscription_node, &u->mcast_subscriptions);
+	atomic_inc(&group->mcast_members_cnt);
+	atomic_inc(&group->mcast_membership_generation);
+	spin_unlock(&unix_multicast_lock);
+
+	return 0;
+
+sock_put_out:
+	sock_put(other);
+	return err;
+}
+
+
+static int unix_mc_leave(struct socket *sock, struct unix_mreq *mreq)
+{
+	struct unix_sock *u = unix_sk(sock->sk);
+	struct sock *other;
+	struct unix_mcast_group *group;
+	struct unix_mcast *node;
+	struct hlist_node *pos;
+	int err;
+	unsigned hash;
+	int namelen;
+
+	if (mreq->address.sun_family != AF_UNIX ||
+	    mreq->address.sun_path[0] != '\0')
+		return -EINVAL;
+
+	err = unix_mkname(&mreq->address, sizeof(struct sockaddr_un), &hash);
+	if (err < 0)
+		return err;
+
+	namelen = err;
+	other = unix_find_other(sock_net(sock->sk), &mreq->address, namelen,
+				sock->type, hash, &err);
+	if (!other)
+		return -EINVAL;
+
+	group = unix_sk(other)->mcast_group;
+
+	if (!group) {
+		err = -EINVAL;
+		goto sock_put_out;
+	}
+
+	spin_lock(&unix_multicast_lock);
+
+	hlist_for_each_entry_rcu(node, pos, &u->mcast_subscriptions,
+			     subscription_node) {
+		if (node->group == group)
+			break;
+	}
+
+	if (!pos) {
+		spin_unlock(&unix_multicast_lock);
+		err = -EINVAL;
+		goto sock_put_out;
+	}
+
+	hlist_del_rcu(&node->member_node);
+	hlist_del_rcu(&node->subscription_node);
+	atomic_dec(&group->mcast_members_cnt);
+	atomic_inc(&group->mcast_membership_generation);
+	hlist_add_head_rcu(&node->member_dead_node,
+			   &group->mcast_dead_members);
+	spin_unlock(&unix_multicast_lock);
+
+	if (sock->sk->sk_type == SOCK_SEQPACKET) {
+		struct sock *peer = unix_peer_get(sock->sk);
+		if (peer) {
+			unix_sk(peer)->mcast_group = NULL;
+			atomic_dec(&group->refcnt);
+			sock_put(peer);
+		}
+	}
+
+	synchronize_rcu();
+
+	if (atomic_dec_and_test(&group->refcnt)) {
+		spin_lock(&unix_multicast_lock);
+		destroy_mcast_group(group);
+		spin_unlock(&unix_multicast_lock);
+	}
+
+	err = 0;
+
+	/* If the receiving queue of that socket was full, some writers on the
+	 * multicast group may be blocked */
+	wake_up_interruptible_sync_poll(&u->peer_wait,
+					POLLOUT | POLLWRNORM | POLLWRBAND);
+
+sock_put_out:
+	sock_put(other);
+	return err;
+}
+#endif
+
 static int unix_setsockopt(struct socket *sock, int level, int optname,
 			   char __user *optval, unsigned int optlen)
 {
+#ifdef CONFIG_UNIX_MULTICAST
+	struct unix_mreq mreq;
+	int err = 0;
+
+	if (level != SOL_UNIX)
+		return -ENOPROTOOPT;
+
+	switch (optname) {
+	case UNIX_CREATE_GROUP:
+	case UNIX_JOIN_GROUP:
+	case UNIX_LEAVE_GROUP:
+		if (optlen < sizeof(struct unix_mreq))
+			return -EINVAL;
+		if (copy_from_user(&mreq, optval, sizeof(struct unix_mreq)))
+			return -EFAULT;
+		break;
+
+	default:
+		break;
+	}
+
+	switch (optname) {
+	case UNIX_CREATE_GROUP:
+		err = unix_mc_create(sock, &mreq);
+		break;
+
+	case UNIX_JOIN_GROUP:
+		err = unix_mc_join(sock, &mreq);
+		break;
+
+	case UNIX_LEAVE_GROUP:
+		err = unix_mc_leave(sock, &mreq);
+		break;
+
+	default:
+		err = -ENOPROTOOPT;
+		break;
+	}
+
+	return err;
+#else
 	return -EOPNOTSUPP;
+#endif
 }
 
 
-- 
1.7.2.3
