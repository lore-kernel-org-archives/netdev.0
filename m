From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 4/5] AF_UNIX: find peers on multicast Unix stream sockets
Date: Fri, 24 Sep 2010 18:25:15 +0100
Message-ID: <1285349116-17529-4-git-send-email-alban.crequy@collabora.co.uk>
References: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbus@freedesktop.org, Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:39592 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677Ab0IXRfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 13:35:23 -0400
In-Reply-To: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multicast sockets are stored in the hash table unix_multicast_socket_table.

unix_find_socket_byname() is extended to return an array of sockets matching
the name instead of only one socket. Then unix_stream_sendmsg() can find all
the multicast peers.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 net/unix/af_unix.c |  134 ++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 99 insertions(+), 35 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a8d9de7..f259849 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -115,11 +115,13 @@
 #include <net/checksum.h>
 #include <linux/security.h>
 
-static struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
+static struct hlist_head unix_socket_table[2 * UNIX_HASH_SIZE + 1];
 static DEFINE_SPINLOCK(unix_table_lock);
 static atomic_t unix_nr_socks = ATOMIC_INIT(0);
+static atomic_t unix_nr_multicast_socks = ATOMIC_INIT(0);
 
-#define unix_sockets_unbound	(&unix_socket_table[UNIX_HASH_SIZE])
+#define unix_multicast_socket_table	(&unix_socket_table[UNIX_HASH_SIZE])
+#define unix_sockets_unbound		(&unix_socket_table[2 * UNIX_HASH_SIZE])
 
 #define UNIX_ABSTRACT(sk)	(unix_sk(sk)->addr->hash != UNIX_HASH_SIZE)
 
@@ -227,7 +229,6 @@ static void __unix_remove_socket(struct sock *sk)
 
 static void __unix_insert_socket(struct hlist_head *list, struct sock *sk)
 {
-	WARN_ON(!sk_unhashed(sk));
 	sk_add_node(sk, list);
 }
 
@@ -247,12 +248,14 @@ static inline void unix_insert_socket(struct hlist_head *list, struct sock *sk)
 
 static struct sock *__unix_find_socket_byname(struct net *net,
 					      struct sockaddr_un *sunname,
-					      int len, int type, unsigned hash)
+					      int len, int type,
+					      unsigned hash, int multicast)
 {
 	struct sock *s;
 	struct hlist_node *node;
+	unsigned int index = (multicast ? UNIX_HASH_SIZE : 0) + (hash ^ type);
 
-	sk_for_each(s, node, &unix_socket_table[hash ^ type]) {
+	sk_for_each(s, node, &unix_socket_table[index]) {
 		struct unix_sock *u = unix_sk(s);
 
 		if (!net_eq(sock_net(s), net))
@@ -267,29 +270,50 @@ found:
 	return s;
 }
 
-static inline struct sock *unix_find_socket_byname(struct net *net,
-						   struct sockaddr_un *sunname,
-						   int len, int type,
-						   unsigned hash)
+static inline void unix_find_socket_byname(struct net *net,
+					   struct sockaddr_un *sunname,
+					   int len, int type,
+					   unsigned hash,
+					   int multicast,
+					   struct sock **others, int max_others)
 {
 	struct sock *s;
+	struct hlist_node *node;
+	int i = 0;
+	unsigned int index = (multicast ? UNIX_HASH_SIZE : 0) + (hash ^ type);
 
 	spin_lock(&unix_table_lock);
-	s = __unix_find_socket_byname(net, sunname, len, type, hash);
-	if (s)
-		sock_hold(s);
+
+	sk_for_each(s, node, &unix_socket_table[index]) {
+		struct unix_sock *u = unix_sk(s);
+
+		if (!net_eq(sock_net(s), net))
+			continue;
+
+		if (u->addr->len == len &&
+		    !memcmp(u->addr->name, sunname, len)) {
+
+			others[i++] = s;
+			sock_hold(s);
+			if (i == max_others)
+				break;
+		}
+	}
+
 	spin_unlock(&unix_table_lock);
-	return s;
 }
 
-static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
+static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i,
+					     int multicast)
 {
 	struct sock *s;
 	struct hlist_node *node;
+	unsigned int index = (multicast ? UNIX_HASH_SIZE : 0)
+	  + (i->i_ino & (UNIX_HASH_SIZE - 1));
 
 	spin_lock(&unix_table_lock);
 	sk_for_each(s, node,
-		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
+		    &unix_socket_table[index]) {
 		struct dentry *dentry = unix_sk(s)->dentry;
 
 		if (!net_eq(sock_net(s), net))
@@ -363,6 +387,9 @@ static void unix_sock_destructor(struct sock *sk)
 	if (u->addr)
 		unix_release_addr(u->addr);
 
+	if (u->multicast)
+		atomic_dec(&unix_nr_multicast_socks);
+
 	atomic_dec(&unix_nr_socks);
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
@@ -700,7 +727,7 @@ retry:
 	ordernum = (ordernum+1)&0xFFFFF;
 
 	if (__unix_find_socket_byname(net, addr->name, addr->len, sock->type,
-				      addr->hash)) {
+				      addr->hash, 0)) {
 		spin_unlock(&unix_table_lock);
 		/* Sanity yield. It is unusual case, but yet... */
 		if (!(ordernum&0xFF))
@@ -719,9 +746,11 @@ out:	mutex_unlock(&u->readlock);
 	return err;
 }
 
-static struct sock *unix_find_other(struct net *net,
-				    struct sockaddr_un *sunname, int len,
-				    int type, unsigned hash, int *error)
+static void unix_find_other(struct net *net,
+			    struct sockaddr_un *sunname, int len,
+			    int type, unsigned hash, int multicast,
+			    struct sock **others, int max_others,
+			    int *error)
 {
 	struct sock *u;
 	struct path path;
@@ -740,7 +769,7 @@ static struct sock *unix_find_other(struct net *net,
 		err = -ECONNREFUSED;
 		if (!S_ISSOCK(inode->i_mode))
 			goto put_fail;
-		u = unix_find_socket_byinode(net, inode);
+		u = unix_find_socket_byinode(net, inode, multicast);
 		if (!u)
 			goto put_fail;
 
@@ -754,24 +783,26 @@ static struct sock *unix_find_other(struct net *net,
 			sock_put(u);
 			goto fail;
 		}
+		others[0] = u;
 	} else {
+		int i;
 		err = -ECONNREFUSED;
-		u = unix_find_socket_byname(net, sunname, len, type, hash);
-		if (u) {
+		unix_find_socket_byname(net, sunname, len, type, hash,
+                    multicast, others, max_others);
+		for(i = 0 ; i < max_others && others[i] != NULL ; i++) {
 			struct dentry *dentry;
-			dentry = unix_sk(u)->dentry;
+			dentry = unix_sk(others[i])->dentry;
 			if (dentry)
-				touch_atime(unix_sk(u)->mnt, dentry);
-		} else
-			goto fail;
+				touch_atime(unix_sk(others[i])->mnt, dentry);
+		}
 	}
-	return u;
+	return;
 
 put_fail:
 	path_put(&path);
 fail:
 	*error = err;
-	return NULL;
+	return;
 }
 
 
@@ -862,7 +893,7 @@ out_mknod_drop_write:
 	if (!sunaddr->sun_path[0]) {
 		err = -EADDRINUSE;
 		if (__unix_find_socket_byname(net, sunaddr, addr_len,
-					      sk->sk_type, hash)) {
+					      sk->sk_type, hash, 0)) {
 			unix_release_addr(addr);
 			goto out_unlock;
 		}
@@ -929,7 +960,7 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)addr;
-	struct sock *other;
+	struct sock *other = NULL;
 	unsigned hash;
 	int err;
 
@@ -944,7 +975,8 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 			goto out;
 
 restart:
-		other = unix_find_other(net, sunaddr, alen, sock->type, hash, &err);
+		unix_find_other(net, sunaddr, alen, sock->type, hash,
+                    0, &other, 1, &err);
 		if (!other)
 			goto out;
 
@@ -1063,7 +1095,8 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 
 restart:
 	/*  Find listening sock. */
-	other = unix_find_other(net, sunaddr, addr_len, sk->sk_type, hash, &err);
+	unix_find_other(net, sunaddr, addr_len, sk->sk_type, hash, 0, &other,
+            1, &err);
 	if (!other && !u->multicast)
 		goto out;
 
@@ -1075,6 +1108,26 @@ restart:
 	if (u->multicast) {
 		sock->state = SS_CONNECTED;
 		sk->sk_state  = TCP_ESTABLISHED;
+
+		unix_find_other(net, sunaddr, addr_len, sk->sk_type,
+		    hash, 1, &other, 1, &err);
+		if (other) {
+			otheru = unix_sk(other);
+			atomic_inc(&otheru->addr->refcnt);
+			u->addr = otheru->addr;
+		} else {
+			err = -ENOMEM;
+			u->addr = kmalloc(sizeof(*u->addr)+addr_len, GFP_KERNEL);
+			if (!u->addr)
+				return err;
+
+			memcpy(u->addr->name, sunaddr, addr_len);
+			u->addr->len = addr_len;
+			u->addr->hash = hash ^ sk->sk_type;
+			atomic_set(&u->addr->refcnt, 1);
+		}
+
+		unix_insert_socket(&unix_multicast_socket_table[u->addr->hash], sk);
 		return 0;
 	}
 
@@ -1427,8 +1480,8 @@ restart:
 		if (sunaddr == NULL)
 			goto out_free;
 
-		other = unix_find_other(net, sunaddr, namelen, sk->sk_type,
-					hash, &err);
+		unix_find_other(net, sunaddr, namelen, sk->sk_type,
+					hash, 0, &other, 1, &err);
 		if (other == NULL)
 			goto out_free;
 	}
@@ -1530,8 +1583,12 @@ static int unix_stream_setsockopt(struct socket *sock, int level, int optname,
 			return -EINVAL;
 
 		if (val != 0) {
+			if (!u->multicast)
+				atomic_inc(&unix_nr_multicast_socks);
 			u->multicast = 1;
 		} else {
+			if (u->multicast)
+				atomic_dec(&unix_nr_multicast_socks);
 			u->multicast = 0;
 		}
 		break;
@@ -1582,6 +1639,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
+	struct sock **others = NULL;
+	int max_others;
 	struct sockaddr_un *sunaddr = msg->msg_name;
 	int err, size;
 	struct sk_buff *skb;
@@ -1612,7 +1671,12 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	} else {
 		sunaddr = NULL;
 		err = -ENOTCONN;
-		other = NULL; /* FIXME: get the list of other connection */
+		max_others = atomic_read(&unix_nr_multicast_socks);
+		others = kzalloc((max_others + 1) * sizeof(void *), GFP_KERNEL);
+		unix_find_other(sock_net(sk), u->addr->name,
+		    u->addr->len, 0, u->addr->hash, 1, others, max_others, &err);
+		other = others[0];
+		kfree(others);
 		if (!other)
 			goto out_err;
 	}
-- 
1.7.1

