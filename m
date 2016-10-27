From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next 1/3] net: core: Add a UID field to struct sock.
Date: Fri, 28 Oct 2016 02:20:39 +0900
Message-ID: <1477588841-140767-2-git-send-email-lorenzo@google.com>
References: <1477588841-140767-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, ek@google.com, eric.dumazet@gmail.com,
        zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34340 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933406AbcJ0RU4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 13:20:56 -0400
Received: by mail-pf0-f174.google.com with SMTP id n85so21389188pfi.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 10:20:56 -0700 (PDT)
In-Reply-To: <1477588841-140767-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Protocol sockets (struct sock) don't have UIDs, but most of the
time, they map 1:1 to userspace sockets (struct socket) which do.

Various operations such as the iptables xt_owner match need
access to the "UID of a socket", and do so by following the
backpointer to the struct socket. This involves taking
sk_callback_lock and doesn't work when there is no socket
because userspace has already called close().

Simplify this by adding a sk_uid field to struct sock whose value
matches the UID of the corresponding struct socket. The semantics
are as follows:

1. Whenever sk_socket is non-null: sk_uid is the same as the UID
   in sk_socket, i.e., matches the return value of sock_i_uid.
   Specifically, the UID is set when userspace calls socket(),
   fchown(), or accept().
2. When sk_socket is null, sk_uid is defined as follows:
   - For a socket that no longer has a sk_socket because
     userspace has called close(): the previous UID.
   - For a cloned socket (e.g., an incoming connection that is
     established but on which userspace has not yet called
     accept): the UID of the socket it was cloned from.
   - For a socket that has never had an sk_socket (e.g., a kernel
     ICMP socket): UID 0 inside the user namespace corresponding
     to the network namespace the socket belongs to. This is
     arguably better than GLOBAL_ROOT_UID because it allows
     "--owner-uid 0" to match kernel-originated packets in
     non-root namespaces.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/sock.h |  7 +++++++
 net/core/sock.c    |  6 +++++-
 net/socket.c       | 14 ++++++++++++++
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2764895..2086922 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -417,6 +417,7 @@ struct sock {
 	u32			sk_max_ack_backlog;
 	__u32			sk_priority;
 	__u32			sk_mark;
+	kuid_t			sk_uid;
 	struct pid		*sk_peer_pid;
 	const struct cred	*sk_peer_cred;
 	long			sk_rcvtimeo;
@@ -1651,6 +1652,7 @@ static inline void sock_graft(struct sock *sk, struct socket *parent)
 	sk->sk_wq = parent->wq;
 	parent->sk = sk;
 	sk_set_socket(sk, parent);
+	sk->sk_uid = SOCK_INODE(parent)->i_uid;
 	security_sock_graft(sk, parent);
 	write_unlock_bh(&sk->sk_callback_lock);
 }
@@ -1658,6 +1660,11 @@ static inline void sock_graft(struct sock *sk, struct socket *parent)
 kuid_t sock_i_uid(struct sock *sk);
 unsigned long sock_i_ino(struct sock *sk);
 
+static inline kuid_t sock_net_uid(struct net *net, const struct sock *sk)
+{
+	return sk ? sk->sk_uid : make_kuid(net->user_ns, 0);
+}
+
 static inline u32 net_tx_rndhash(void)
 {
 	u32 v = prandom_u32();
diff --git a/net/core/sock.c b/net/core/sock.c
index d8e4532e..831e4e8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1570,6 +1570,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		 */
 		sk_refcnt_debug_inc(newsk);
 		sk_set_socket(newsk, NULL);
+		newsk->sk_uid = sk->sk_uid;
 		newsk->sk_wq = NULL;
 
 		if (newsk->sk_prot->sockets_allocated)
@@ -2460,8 +2461,11 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 		sk->sk_type	=	sock->type;
 		sk->sk_wq	=	sock->wq;
 		sock->sk	=	sk;
-	} else
+		sk->sk_uid	=	SOCK_INODE(sock)->i_uid;
+	} else {
 		sk->sk_wq	=	NULL;
+		sk->sk_uid	=	make_kuid(sock_net(sk)->user_ns, 0);
+	}
 
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
diff --git a/net/socket.c b/net/socket.c
index 5a9bf5e..5a4747e 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -518,8 +518,22 @@ static ssize_t sockfs_listxattr(struct dentry *dentry, char *buffer,
 	return used;
 }
 
+int sockfs_setattr(struct dentry *dentry, struct iattr *iattr)
+{
+	int err = simple_setattr(dentry, iattr);
+
+	if (!err) {
+		struct socket *sock = SOCKET_I(d_inode(dentry));
+
+		sock->sk->sk_uid = iattr->ia_uid;
+	}
+
+	return err;
+}
+
 static const struct inode_operations sockfs_inode_ops = {
 	.listxattr = sockfs_listxattr,
+	.setattr = sockfs_setattr,
 };
 
 /**
-- 
2.8.0.rc3.226.g39d4020
