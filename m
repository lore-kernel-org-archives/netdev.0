From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v4 1/7] sock: struct proto hash function may error
Date: Wed, 10 Feb 2016 11:50:35 -0500
Message-ID: <1455123041-22638-2-git-send-email-kraigatgoog@gmail.com>
References: <1455123041-22638-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34486 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044AbcBJQus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 11:50:48 -0500
Received: by mail-qg0-f50.google.com with SMTP id b67so17946746qgb.1
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 08:50:47 -0800 (PST)
In-Reply-To: <1455123041-22638-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

In order to support fast reuseport lookups in TCP, the hash function
defined in struct proto must be capable of returning an error code.
This patch changes the function signature of all related hash functions
to return an integer and handles or propagates this return value at
all call sites.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/inet_hashtables.h   |  2 +-
 include/net/phonet/phonet.h     |  2 +-
 include/net/ping.h              |  2 +-
 include/net/raw.h               |  2 +-
 include/net/sock.h              |  6 +++---
 include/net/udp.h               |  3 ++-
 net/ieee802154/socket.c         | 17 +++++++++++++----
 net/ipv4/af_inet.c              |  9 ++++++---
 net/ipv4/inet_connection_sock.c |  8 +++++---
 net/ipv4/inet_hashtables.c      |  4 +++-
 net/ipv4/ping.c                 |  4 +++-
 net/ipv4/raw.c                  |  4 +++-
 net/ipv6/af_inet6.c             |  6 +++++-
 net/phonet/socket.c             |  6 ++++--
 net/sctp/socket.c               |  3 ++-
 15 files changed, 53 insertions(+), 25 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index de2e3ade6102..554440e7f83d 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -208,7 +208,7 @@ void inet_hashinfo_init(struct inet_hashinfo *h);
 bool inet_ehash_insert(struct sock *sk, struct sock *osk);
 bool inet_ehash_nolisten(struct sock *sk, struct sock *osk);
 void __inet_hash(struct sock *sk, struct sock *osk);
-void inet_hash(struct sock *sk);
+int inet_hash(struct sock *sk);
 void inet_unhash(struct sock *sk);
 
 struct sock *__inet_lookup_listener(struct net *net,
diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index 68e509750caa..039cc29cb4a8 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -51,7 +51,7 @@ void pn_sock_init(void);
 struct sock *pn_find_sock_by_sa(struct net *net, const struct sockaddr_pn *sa);
 void pn_deliver_sock_broadcast(struct net *net, struct sk_buff *skb);
 void phonet_get_local_port_range(int *min, int *max);
-void pn_sock_hash(struct sock *sk);
+int pn_sock_hash(struct sock *sk);
 void pn_sock_unhash(struct sock *sk);
 int pn_sock_get_port(struct sock *sk, unsigned short sport);
 
diff --git a/include/net/ping.h b/include/net/ping.h
index ac80cb45e630..5fd7cc244833 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -65,7 +65,7 @@ struct pingfakehdr {
 };
 
 int  ping_get_port(struct sock *sk, unsigned short ident);
-void ping_hash(struct sock *sk);
+int ping_hash(struct sock *sk);
 void ping_unhash(struct sock *sk);
 
 int  ping_init_sock(struct sock *sk);
diff --git a/include/net/raw.h b/include/net/raw.h
index 6a40c6562dd2..3e789008394d 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -57,7 +57,7 @@ int raw_seq_open(struct inode *ino, struct file *file,
 
 #endif
 
-void raw_hash_sk(struct sock *sk);
+int raw_hash_sk(struct sock *sk);
 void raw_unhash_sk(struct sock *sk);
 
 struct raw_sock {
diff --git a/include/net/sock.h b/include/net/sock.h
index f5ea148853e2..255d3e03727b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -984,7 +984,7 @@ struct proto {
 	void		(*release_cb)(struct sock *sk);
 
 	/* Keeping track of sk's, looking them up, and port selection methods. */
-	void			(*hash)(struct sock *sk);
+	int			(*hash)(struct sock *sk);
 	void			(*unhash)(struct sock *sk);
 	void			(*rehash)(struct sock *sk);
 	int			(*get_port)(struct sock *sk, unsigned short snum);
@@ -1194,10 +1194,10 @@ static inline void sock_prot_inuse_add(struct net *net, struct proto *prot,
 /* With per-bucket locks this operation is not-atomic, so that
  * this version is not worse.
  */
-static inline void __sk_prot_rehash(struct sock *sk)
+static inline int __sk_prot_rehash(struct sock *sk)
 {
 	sk->sk_prot->unhash(sk);
-	sk->sk_prot->hash(sk);
+	return sk->sk_prot->hash(sk);
 }
 
 void sk_prot_clear_portaddr_nulls(struct sock *sk, int size);
diff --git a/include/net/udp.h b/include/net/udp.h
index 2842541e28e7..92927f729ac8 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -177,9 +177,10 @@ static inline struct udphdr *udp_gro_udphdr(struct sk_buff *skb)
 }
 
 /* hash routines shared between UDPv4/6 and UDP-Litev4/6 */
-static inline void udp_lib_hash(struct sock *sk)
+static inline int udp_lib_hash(struct sock *sk)
 {
 	BUG();
+	return 0;
 }
 
 void udp_lib_unhash(struct sock *sk);
diff --git a/net/ieee802154/socket.c b/net/ieee802154/socket.c
index a548be247e15..e0bd013a1e5e 100644
--- a/net/ieee802154/socket.c
+++ b/net/ieee802154/socket.c
@@ -182,12 +182,14 @@ static int ieee802154_sock_ioctl(struct socket *sock, unsigned int cmd,
 static HLIST_HEAD(raw_head);
 static DEFINE_RWLOCK(raw_lock);
 
-static void raw_hash(struct sock *sk)
+static int raw_hash(struct sock *sk)
 {
 	write_lock_bh(&raw_lock);
 	sk_add_node(sk, &raw_head);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	write_unlock_bh(&raw_lock);
+
+	return 0;
 }
 
 static void raw_unhash(struct sock *sk)
@@ -462,12 +464,14 @@ static inline struct dgram_sock *dgram_sk(const struct sock *sk)
 	return container_of(sk, struct dgram_sock, sk);
 }
 
-static void dgram_hash(struct sock *sk)
+static int dgram_hash(struct sock *sk)
 {
 	write_lock_bh(&dgram_lock);
 	sk_add_node(sk, &dgram_head);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	write_unlock_bh(&dgram_lock);
+
+	return 0;
 }
 
 static void dgram_unhash(struct sock *sk)
@@ -1026,8 +1030,13 @@ static int ieee802154_create(struct net *net, struct socket *sock,
 	/* Checksums on by default */
 	sock_set_flag(sk, SOCK_ZAPPED);
 
-	if (sk->sk_prot->hash)
-		sk->sk_prot->hash(sk);
+	if (sk->sk_prot->hash) {
+		rc = sk->sk_prot->hash(sk);
+		if (rc) {
+			sk_common_release(sk);
+			goto out;
+		}
+	}
 
 	if (sk->sk_prot->init) {
 		rc = sk->sk_prot->init(sk);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5c5db6636704..eade66db214e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -370,7 +370,11 @@ lookup_protocol:
 		 */
 		inet->inet_sport = htons(inet->inet_num);
 		/* Add to protocol hash chains. */
-		sk->sk_prot->hash(sk);
+		err = sk->sk_prot->hash(sk);
+		if (err) {
+			sk_common_release(sk);
+			goto out;
+		}
 	}
 
 	if (sk->sk_prot->init) {
@@ -1142,8 +1146,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	 * Besides that, it does not check for connection
 	 * uniqueness. Wait for troubles.
 	 */
-	__sk_prot_rehash(sk);
-	return 0;
+	return __sk_prot_rehash(sk);
 }
 
 int inet_sk_rebuild_header(struct sock *sk)
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 9b17c1792dce..12c8d389dc18 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -734,6 +734,7 @@ int inet_csk_listen_start(struct sock *sk, int backlog)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_sock *inet = inet_sk(sk);
+	int err = -EADDRINUSE;
 
 	reqsk_queue_alloc(&icsk->icsk_accept_queue);
 
@@ -751,13 +752,14 @@ int inet_csk_listen_start(struct sock *sk, int backlog)
 		inet->inet_sport = htons(inet->inet_num);
 
 		sk_dst_reset(sk);
-		sk->sk_prot->hash(sk);
+		err = sk->sk_prot->hash(sk);
 
-		return 0;
+		if (likely(!err))
+			return 0;
 	}
 
 	sk->sk_state = TCP_CLOSE;
-	return -EADDRINUSE;
+	return err;
 }
 EXPORT_SYMBOL_GPL(inet_csk_listen_start);
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ccc5980797fc..b6023b7baae0 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -468,13 +468,15 @@ void __inet_hash(struct sock *sk, struct sock *osk)
 }
 EXPORT_SYMBOL(__inet_hash);
 
-void inet_hash(struct sock *sk)
+int inet_hash(struct sock *sk)
 {
 	if (sk->sk_state != TCP_CLOSE) {
 		local_bh_disable();
 		__inet_hash(sk, NULL);
 		local_bh_enable();
 	}
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(inet_hash);
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index c117b21b937d..f6f93fc2c61f 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -145,10 +145,12 @@ fail:
 }
 EXPORT_SYMBOL_GPL(ping_get_port);
 
-void ping_hash(struct sock *sk)
+int ping_hash(struct sock *sk)
 {
 	pr_debug("ping_hash(sk->port=%u)\n", inet_sk(sk)->inet_num);
 	BUG(); /* "Please do not press this button again." */
+
+	return 0;
 }
 
 void ping_unhash(struct sock *sk)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index bc35f1842512..d6352515d738 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -93,7 +93,7 @@ static struct raw_hashinfo raw_v4_hashinfo = {
 	.lock = __RW_LOCK_UNLOCKED(raw_v4_hashinfo.lock),
 };
 
-void raw_hash_sk(struct sock *sk)
+int raw_hash_sk(struct sock *sk)
 {
 	struct raw_hashinfo *h = sk->sk_prot->h.raw_hash;
 	struct hlist_head *head;
@@ -104,6 +104,8 @@ void raw_hash_sk(struct sock *sk)
 	sk_add_node(sk, head);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	write_unlock_bh(&h->lock);
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(raw_hash_sk);
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 9f5137cd604e..b11c37cfd67c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -235,7 +235,11 @@ lookup_protocol:
 		 * creation time automatically shares.
 		 */
 		inet->inet_sport = htons(inet->inet_num);
-		sk->sk_prot->hash(sk);
+		err = sk->sk_prot->hash(sk);
+		if (err) {
+			sk_common_release(sk);
+			goto out;
+		}
 	}
 	if (sk->sk_prot->init) {
 		err = sk->sk_prot->init(sk);
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index d575ef4e9aa6..ffd5f2297584 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -140,13 +140,15 @@ void pn_deliver_sock_broadcast(struct net *net, struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
-void pn_sock_hash(struct sock *sk)
+int pn_sock_hash(struct sock *sk)
 {
 	struct hlist_head *hlist = pn_hash_list(pn_sk(sk)->sobject);
 
 	mutex_lock(&pnsocks.lock);
 	sk_add_node_rcu(sk, hlist);
 	mutex_unlock(&pnsocks.lock);
+
+	return 0;
 }
 EXPORT_SYMBOL(pn_sock_hash);
 
@@ -200,7 +202,7 @@ static int pn_socket_bind(struct socket *sock, struct sockaddr *addr, int len)
 	pn->resource = spn->spn_resource;
 
 	/* Enable RX on the socket */
-	sk->sk_prot->hash(sk);
+	err = sk->sk_prot->hash(sk);
 out_port:
 	mutex_unlock(&port_mutex);
 out:
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 5ca2ebfe0be8..6427b9d1197e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6101,9 +6101,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 	return retval;
 }
 
-static void sctp_hash(struct sock *sk)
+static int sctp_hash(struct sock *sk)
 {
 	/* STUB */
+	return 0;
 }
 
 static void sctp_unhash(struct sock *sk)
-- 
2.7.0.rc3.207.g0ac5344
