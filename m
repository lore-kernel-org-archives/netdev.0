From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 3/9] AF_UNIX: create, join and leave multicast groups with setsockopt
Date: Mon, 22 Nov 2010 18:36:16 +0000
Message-ID: <1290450982-17480-3-git-send-email-alban.crequy@collabora.co.uk>
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

Multicast is implemented on SOCK_DGRAM and SOCK_SEQPACKET Unix sockets.

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
---
 include/net/af_unix.h |   31 +++++++
 net/unix/af_unix.c    |  217 ++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 247 insertions(+), 1 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 90c9e28..bf114d5 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -40,6 +40,18 @@ struct unix_skb_parms {
 				spin_lock_nested(&unix_sk(s)->lock, \
 				SINGLE_DEPTH_NESTING)
 
+#define UNIX_MREQ_LOOPBACK	0x01
+struct unix_mreq
+{
+	struct sockaddr_un	address;
+	unsigned int		flags;
+};
+
+/* UNIX socket options */
+#define UNIX_CREATE_GROUP	1
+#define UNIX_JOIN_GROUP		2
+#define UNIX_LEAVE_GROUP	3
+
 #ifdef __KERNEL__
 /* The AF_UNIX socket */
 struct unix_sock {
@@ -56,8 +68,27 @@ struct unix_sock {
 	spinlock_t		lock;
 	unsigned int		gc_candidate : 1;
 	unsigned int		gc_maybe_cycle : 1;
+	unsigned int		is_mcast_addr : 1;
+
+	/* These multicast fields are protected by the global spinlock
+	 * unix_multicast_lock */
+	struct hlist_head	mcast_subscriptions;
+	struct hlist_head	mcast_members;
+	int			mcast_subscriptions_cnt;
+	int			mcast_members_cnt;
+
 	struct socket_wq	peer_wq;
 };
+
+struct unix_mcast
+{
+	struct unix_sock	*member;
+	struct unix_sock	*addr;
+	unsigned int		flags;
+	struct hlist_node	subscription_node;
+	struct hlist_node	member_node;
+};
+
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
 #define peer_wait peer_wq.wait
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 6eca106..2278829 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -379,6 +379,9 @@ static int unix_release_sock(struct sock *sk, int embrion)
 	struct sock *skpair;
 	struct sk_buff *skb;
 	int state;
+	struct unix_mcast *node;
+	struct hlist_node *pos;
+	struct hlist_node *pos_tmp;
 
 	unix_remove_socket(sk);
 
@@ -392,6 +395,24 @@ static int unix_release_sock(struct sock *sk, int embrion)
 	u->mnt	     = NULL;
 	state = sk->sk_state;
 	sk->sk_state = TCP_CLOSE;
+	spin_lock(&unix_multicast_lock);
+	hlist_for_each_entry_safe(node, pos, pos_tmp, &u->mcast_subscriptions,
+				  subscription_node) {
+		hlist_del(&node->member_node);
+		hlist_del(&node->subscription_node);
+		node->addr->mcast_members_cnt--;
+		node->member->mcast_subscriptions_cnt--;
+		kfree(node);
+	}
+	hlist_for_each_entry_safe(node, pos, pos_tmp, &u->mcast_members,
+				  member_node) {
+		hlist_del(&node->member_node);
+		hlist_del(&node->subscription_node);
+		node->addr->mcast_members_cnt--;
+		node->member->mcast_subscriptions_cnt--;
+		kfree(node);
+	}
+	spin_unlock(&unix_multicast_lock);
 	unix_state_unlock(sk);
 
 	wake_up_interruptible_all(&u->peer_wait);
@@ -631,6 +652,8 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 	atomic_long_set(&u->inflight, 0);
 	INIT_LIST_HEAD(&u->link);
 	mutex_init(&u->readlock); /* single task reading lock */
+	INIT_HLIST_HEAD(&u->mcast_subscriptions);
+	INIT_HLIST_HEAD(&u->mcast_members);
 	init_waitqueue_head(&u->peer_wait);
 	unix_insert_socket(unix_sockets_unbound, sk);
 out:
@@ -1535,10 +1558,202 @@ out:
 }
 
 
+static int unix_mc_create(struct socket *sock, struct unix_mreq *mreq)
+{
+	struct sock *other;
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
+	if (other)
+		return -EADDRINUSE;
+
+	err = sock->ops->bind(sock,
+		(struct sockaddr*)&mreq->address,
+		sizeof(struct sockaddr_un));
+	if (err < 0)
+		return err;
+
+	unix_state_lock(sock->sk);
+	unix_sk(sock->sk)->is_mcast_addr = 1;
+	unix_state_unlock(sock->sk);
+
+	return 0;
+}
+
+
+static int unix_mc_join(struct socket *sock, struct unix_mreq *mreq)
+{
+	struct unix_sock *u = unix_sk(sock->sk);
+	struct sock *other;
+	struct unix_sock *otheru;
+	struct unix_mcast *node;
+	int err;
+	unsigned hash;
+	int namelen;
+
+	if (mreq->address.sun_family != AF_UNIX ||
+	    mreq->address.sun_path[0] != '\0')
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
+	if (other && !unix_sk(other)->is_mcast_addr) {
+		err = -EADDRINUSE;
+		goto sock_put_out;
+	}
+
+	otheru = unix_sk(other);
+
+	node = kmalloc(sizeof(struct unix_mcast), GFP_KERNEL);
+	if (!node) {
+		err = -ENOMEM;
+		goto sock_put_out;
+	}
+	node->member = u;
+	node->addr = otheru;
+	node->flags = mreq->flags;
+
+	spin_lock(&unix_multicast_lock);
+	hlist_add_head(&node->member_node, &otheru->mcast_members);
+	hlist_add_head(&node->subscription_node, &u->mcast_subscriptions);
+	otheru->mcast_members_cnt++;
+	u->mcast_subscriptions_cnt++;
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
+	struct unix_sock *otheru;
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
+	otheru = unix_sk(other);
+
+	if (!otheru->is_mcast_addr) {
+		err = -EINVAL;
+		goto sock_put_out;
+	}
+
+	spin_lock(&unix_multicast_lock);
+
+	hlist_for_each_entry(node, pos, &u->mcast_subscriptions,
+			     subscription_node) {
+		if (node->addr == otheru)
+			break;
+	}
+
+	if (!pos) {
+		spin_unlock(&unix_multicast_lock);
+		err = -EINVAL;
+		goto sock_put_out;
+	}
+
+	hlist_del(&node->member_node);
+	hlist_del(&node->subscription_node);
+	otheru->mcast_members_cnt--;
+	u->mcast_subscriptions_cnt--;
+	spin_unlock(&unix_multicast_lock);
+	kfree(node);
+	err = 0;
+
+sock_put_out:
+	sock_put(other);
+	return err;
+}
+
+
 static int unix_setsockopt(struct socket *sock, int level, int optname,
 			   char __user *optval, unsigned int optlen)
 {
-	return -EOPNOTSUPP;
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
 }
 
 
-- 
1.7.1
