From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/2][SOCK]: Add udp_hash member to struct proto.
Date: Tue, 18 Mar 2008 14:49:24 +0300
Message-ID: <47DFAC44.9020704@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37210 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311AbYCRLuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2008 07:50:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inspired by the commit ab1e0a13 ([SOCK] proto: Add hashinfo member to 
struct proto) from Arnaldo, I made similar thing for UDP/-Lite IPv4 
and -v6 protocols.

The result is not that exciting, but it removes some levels of
indirection in udpxxx_get_port and saves some space in code and text.

The first step is to union existing hashinfo and new udp_hash on the
struct proto and give a name to this union, since future initialization 
of tcpxxx_prot, dccp_vx_protinfo and udpxxx_protinfo will cause gcc 
warning about inability to initialize anonymous member this way.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

 include/net/inet_hashtables.h   |    2 +-
 include/net/sock.h              |    5 ++++-
 net/dccp/ipv4.c                 |    2 +-
 net/dccp/ipv6.c                 |    2 +-
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/inet_hashtables.c      |    8 ++++----
 net/ipv4/tcp_ipv4.c             |    2 +-
 net/ipv6/inet6_hashtables.c     |    2 +-
 net/ipv6/tcp_ipv6.c             |    2 +-
 9 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 97dc35a..d99c1ba 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -223,7 +223,7 @@ static inline int inet_sk_listen_hashfn(const struct sock *sk)
 /* Caller must disable local BH processing. */
 static inline void __inet_inherit_port(struct sock *sk, struct sock *child)
 {
-	struct inet_hashinfo *table = sk->sk_prot->hashinfo;
+	struct inet_hashinfo *table = sk->sk_prot->h.hashinfo;
 	const int bhash = inet_bhashfn(inet_sk(child)->num, table->bhash_size);
 	struct inet_bind_hashbucket *head = &table->bhash[bhash];
 	struct inet_bind_bucket *tb;
diff --git a/include/net/sock.h b/include/net/sock.h
index 39112e7..b2d7fa1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -580,7 +580,10 @@ struct proto {
 	struct request_sock_ops	*rsk_prot;
 	struct timewait_sock_ops *twsk_prot;
 
-	struct inet_hashinfo	*hashinfo;
+	union {
+		struct inet_hashinfo	*hashinfo;
+		struct hlist_head	*udp_hash;
+	} h;
 
 	struct module		*owner;
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 17ad69e..4ca8b0c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -941,7 +941,7 @@ static struct proto dccp_v4_prot = {
 	.obj_size		= sizeof(struct dccp_sock),
 	.rsk_prot		= &dccp_request_sock_ops,
 	.twsk_prot		= &dccp_timewait_sock_ops,
-	.hashinfo		= &dccp_hashinfo,
+	.h.hashinfo		= &dccp_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt	= compat_dccp_setsockopt,
 	.compat_getsockopt	= compat_dccp_getsockopt,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 1a5e50b..2fec1af 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1126,7 +1126,7 @@ static struct proto dccp_v6_prot = {
 	.obj_size	   = sizeof(struct dccp6_sock),
 	.rsk_prot	   = &dccp6_request_sock_ops,
 	.twsk_prot	   = &dccp6_timewait_sock_ops,
-	.hashinfo	   = &dccp_hashinfo,
+	.h.hashinfo	   = &dccp_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_dccp_setsockopt,
 	.compat_getsockopt = compat_dccp_getsockopt,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index c0e0fa0..7139ee1 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -80,7 +80,7 @@ EXPORT_SYMBOL_GPL(inet_csk_bind_conflict);
  */
 int inet_csk_get_port(struct sock *sk, unsigned short snum)
 {
-	struct inet_hashinfo *hashinfo = sk->sk_prot->hashinfo;
+	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct inet_bind_hashbucket *head;
 	struct hlist_node *node;
 	struct inet_bind_bucket *tb;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 1aba606..8cd1ad9 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -68,7 +68,7 @@ void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
  */
 static void __inet_put_port(struct sock *sk)
 {
-	struct inet_hashinfo *hashinfo = sk->sk_prot->hashinfo;
+	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	const int bhash = inet_bhashfn(inet_sk(sk)->num, hashinfo->bhash_size);
 	struct inet_bind_hashbucket *head = &hashinfo->bhash[bhash];
 	struct inet_bind_bucket *tb;
@@ -318,7 +318,7 @@ static inline u32 inet_sk_port_offset(const struct sock *sk)
 
 void __inet_hash_nolisten(struct sock *sk)
 {
-	struct inet_hashinfo *hashinfo = sk->sk_prot->hashinfo;
+	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct hlist_head *list;
 	rwlock_t *lock;
 	struct inet_ehash_bucket *head;
@@ -339,7 +339,7 @@ EXPORT_SYMBOL_GPL(__inet_hash_nolisten);
 
 static void __inet_hash(struct sock *sk)
 {
-	struct inet_hashinfo *hashinfo = sk->sk_prot->hashinfo;
+	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct hlist_head *list;
 	rwlock_t *lock;
 
@@ -372,7 +372,7 @@ EXPORT_SYMBOL_GPL(inet_hash);
 void inet_unhash(struct sock *sk)
 {
 	rwlock_t *lock;
-	struct inet_hashinfo *hashinfo = sk->sk_prot->hashinfo;
+	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 
 	if (sk_unhashed(sk))
 		goto out;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a79e324..868f06a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2434,7 +2434,7 @@ struct proto tcp_prot = {
 	.obj_size		= sizeof(struct tcp_sock),
 	.twsk_prot		= &tcp_timewait_sock_ops,
 	.rsk_prot		= &tcp_request_sock_ops,
-	.hashinfo		= &tcp_hashinfo,
+	.h.hashinfo		= &tcp_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 99fd25f..c0c8d2d 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -24,7 +24,7 @@
 
 void __inet6_hash(struct sock *sk)
 {
-	struct inet_hashinfo *hashinfo = sk->sk_prot->hashinfo;
+	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct hlist_head *list;
 	rwlock_t *lock;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index caf0cc1..28b1c32 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2172,7 +2172,7 @@ struct proto tcpv6_prot = {
 	.obj_size		= sizeof(struct tcp6_sock),
 	.twsk_prot		= &tcp6_timewait_sock_ops,
 	.rsk_prot		= &tcp6_request_sock_ops,
-	.hashinfo		= &tcp_hashinfo,
+	.h.hashinfo		= &tcp_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
