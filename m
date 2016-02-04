From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 1/7] sock: struct proto hash function may error
Date: Thu,  4 Feb 2016 10:34:30 -0500
Message-ID: <1454600076-30067-2-git-send-email-kraigatgoog@gmail.com>
References: <1454600076-30067-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, cgallek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:34940 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756600AbcBDPem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 10:34:42 -0500
Received: by mail-qg0-f54.google.com with SMTP id o11so44056311qge.2
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 07:34:41 -0800 (PST)
In-Reply-To: <1454600076-30067-1-git-send-email-kraigatgoog@gmail.com>
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
 include/net/inet_hashtables.h   | 2 +-
 include/net/ping.h              | 2 +-
 include/net/raw.h               | 2 +-
 include/net/sock.h              | 6 +++---
 include/net/udp.h               | 2 +-
 net/ieee802154/socket.c         | 9 +++++++--
 net/ipv4/af_inet.c              | 9 ++++++---
 net/ipv4/inet_connection_sock.c | 8 +++++---
 net/ipv4/inet_hashtables.c      | 4 +++-
 net/ipv4/ping.c                 | 4 +++-
 net/ipv4/raw.c                  | 4 +++-
 net/ipv6/af_inet6.c             | 6 +++++-
 net/phonet/socket.c             | 2 +-
 13 files changed, 40 insertions(+), 20 deletions(-)

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
index 2842541e28e7..ecaeec1acd50 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -177,7 +177,7 @@ static inline struct udphdr *udp_gro_udphdr(struct sk_buff *skb)
 }
 
 /* hash routines shared between UDPv4/6 and UDP-Litev4/6 */
-static inline void udp_lib_hash(struct sock *sk)
+static inline int udp_lib_hash(struct sock *sk)
 {
 	BUG();
 }
diff --git a/net/ieee802154/socket.c b/net/ieee802154/socket.c
index a548be247e15..1b9c528e4818 100644
--- a/net/ieee802154/socket.c
+++ b/net/ieee802154/socket.c
@@ -1026,8 +1026,13 @@ static int ieee802154_create(struct net *net, struct socket *sock,
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
index 46b9c887bede..4c457c492b1f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -737,6 +737,7 @@ int inet_csk_listen_start(struct sock *sk, int backlog)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_sock *inet = inet_sk(sk);
+	int err = -EADDRINUSE;
 
 	reqsk_queue_alloc(&icsk->icsk_accept_queue);
 
@@ -754,13 +755,14 @@ int inet_csk_listen_start(struct sock *sk, int backlog)
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
index d575ef4e9aa6..6273d57762bb 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -200,7 +200,7 @@ static int pn_socket_bind(struct socket *sock, struct sockaddr *addr, int len)
 	pn->resource = spn->spn_resource;
 
 	/* Enable RX on the socket */
-	sk->sk_prot->hash(sk);
+	err = sk->sk_prot->hash(sk);
 out_port:
 	mutex_unlock(&port_mutex);
 out:
-- 
2.7.0.rc3.207.g0ac5344
