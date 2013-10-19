From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 7/9] inet: convert inet_ehash_secret and ipv6_hash_secret to net_get_random_once
Date: Sat, 19 Oct 2013 21:48:57 +0200
Message-ID: <1382212139-20301-8-git-send-email-hannes@stressinduktion.org>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initialize the ehash and ipv6_hash_secrets with net_get_random_once.

Each compilation unit gets its own secret now:
  ipv4/inet_hashtables.o
  ipv4/udp.o
  ipv6/inet6_hashtables.o
  ipv6/udp.o
  rds/connection.o

The functions still get inlined into the hashing functions. In the fast
path we have at most two (needed in ipv6) if (unlikely(...)).

Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_sock.h     |  4 ----
 net/ipv4/af_inet.c          | 27 ---------------------------
 net/ipv4/inet_hashtables.c  |  4 ++++
 net/ipv4/udp.c              |  6 +++++-
 net/ipv6/af_inet6.c         |  5 -----
 net/ipv6/inet6_hashtables.c | 15 ++++++++++++---
 net/ipv6/udp.c              | 17 ++++++++++++++---
 net/rds/connection.c        | 12 +++++++++---
 8 files changed, 44 insertions(+), 46 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 7a6c7f8..1833c3f 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -204,10 +204,6 @@ static inline void inet_sk_copy_descendant(struct sock *sk_to,
 
 int inet_sk_rebuild_header(struct sock *sk);
 
-extern u32 inet_ehash_secret;
-extern u32 ipv6_hash_secret;
-void build_ehash_secret(void);
-
 static inline unsigned int __inet_ehashfn(const __be32 laddr,
 					  const __u16 lport,
 					  const __be32 faddr,
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 35913fb..b6bdd82 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -245,29 +245,6 @@ out:
 }
 EXPORT_SYMBOL(inet_listen);
 
-u32 inet_ehash_secret __read_mostly;
-EXPORT_SYMBOL(inet_ehash_secret);
-
-u32 ipv6_hash_secret __read_mostly;
-EXPORT_SYMBOL(ipv6_hash_secret);
-
-/*
- * inet_ehash_secret must be set exactly once, and to a non nul value
- * ipv6_hash_secret must be set exactly once.
- */
-void build_ehash_secret(void)
-{
-	u32 rnd;
-
-	do {
-		get_random_bytes(&rnd, sizeof(rnd));
-	} while (rnd == 0);
-
-	if (cmpxchg(&inet_ehash_secret, 0, rnd) == 0)
-		get_random_bytes(&ipv6_hash_secret, sizeof(ipv6_hash_secret));
-}
-EXPORT_SYMBOL(build_ehash_secret);
-
 /*
  *	Create an inet socket.
  */
@@ -284,10 +261,6 @@ static int inet_create(struct net *net, struct socket *sock, int protocol,
 	int try_loading_module = 0;
 	int err;
 
-	if (unlikely(!inet_ehash_secret))
-		if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
-			build_ehash_secret();
-
 	sock->state = SS_UNCONNECTED;
 
 	/* Look for the requested type/protocol pair. */
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 18aa668..8b9cf27 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -28,6 +28,10 @@ static unsigned int inet_ehashfn(struct net *net, const __be32 laddr,
 				 const __u16 lport, const __be32 faddr,
 				 const __be16 fport)
 {
+	static u32 inet_ehash_secret __read_mostly;
+
+	net_get_random_once(&inet_ehash_secret, sizeof(inet_ehash_secret));
+
 	return __inet_ehashfn(laddr, lport, faddr, fport,
 			      inet_ehash_secret + net_hash_mix(net));
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b4437c7..89909dd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -411,8 +411,12 @@ static unsigned int udp_ehashfn(struct net *net, const __be32 laddr,
 				 const __u16 lport, const __be32 faddr,
 				 const __be16 fport)
 {
+	static u32 udp_ehash_secret __read_mostly;
+
+	net_get_random_once(&udp_ehash_secret, sizeof(udp_ehash_secret));
+
 	return __inet_ehashfn(laddr, lport, faddr, fport,
-			      inet_ehash_secret + net_hash_mix(net));
+			      udp_ehash_secret + net_hash_mix(net));
 }
 
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a2cb07c..20af1fb 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -110,11 +110,6 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 	int try_loading_module = 0;
 	int err;
 
-	if (sock->type != SOCK_RAW &&
-	    sock->type != SOCK_DGRAM &&
-	    !inet_ehash_secret)
-		build_ehash_secret();
-
 	/* Look for the requested type/protocol pair. */
 lookup_protocol:
 	err = -ESOCKTNOSUPPORT;
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index fa7dd38..262e13c 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -29,10 +29,19 @@ static unsigned int inet6_ehashfn(struct net *net,
 				  const struct in6_addr *faddr,
 				  const __be16 fport)
 {
-	const u32 lhash = (__force u32)laddr->s6_addr32[3];
-	const u32 fhash = __ipv6_addr_jhash(faddr, ipv6_hash_secret);
+	static u32 inet6_ehash_secret __read_mostly;
+	static u32 ipv6_hash_secret __read_mostly;
+
+	u32 lhash, fhash;
+
+	net_get_random_once(&inet6_ehash_secret, sizeof(inet6_ehash_secret));
+	net_get_random_once(&ipv6_hash_secret, sizeof(ipv6_hash_secret));
+
+	lhash = (__force u32)laddr->s6_addr32[3];
+	fhash = __ipv6_addr_jhash(faddr, ipv6_hash_secret);
+
 	return __inet6_ehashfn(lhash, lport, fhash, fport,
-			       inet_ehash_secret + net_hash_mix(net));
+			       inet6_ehash_secret + net_hash_mix(net));
 }
 
 static int inet6_sk_ehashfn(const struct sock *sk)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 324bd36..44fc4e3 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -59,10 +59,21 @@ static unsigned int udp6_ehashfn(struct net *net,
 				  const struct in6_addr *faddr,
 				  const __be16 fport)
 {
-	const u32 lhash = (__force u32)laddr->s6_addr32[3];
-	const u32 fhash = __ipv6_addr_jhash(faddr, ipv6_hash_secret);
+	static u32 udp6_ehash_secret __read_mostly;
+	static u32 udp_ipv6_hash_secret __read_mostly;
+
+	u32 lhash, fhash;
+
+	net_get_random_once(&udp6_ehash_secret,
+			    sizeof(udp6_ehash_secret));
+	net_get_random_once(&udp_ipv6_hash_secret,
+			    sizeof(udp_ipv6_hash_secret));
+
+	lhash = (__force u32)laddr->s6_addr32[3];
+	fhash = __ipv6_addr_jhash(faddr, udp_ipv6_hash_secret);
+
 	return __inet6_ehashfn(lhash, lport, fhash, fport,
-			       inet_ehash_secret + net_hash_mix(net));
+			       udp_ipv6_hash_secret + net_hash_mix(net));
 }
 
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
diff --git a/net/rds/connection.c b/net/rds/connection.c
index 45e2366..378c3a6 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -51,10 +51,16 @@ static struct kmem_cache *rds_conn_slab;
 
 static struct hlist_head *rds_conn_bucket(__be32 laddr, __be32 faddr)
 {
+	static u32 rds_hash_secret __read_mostly;
+
+	unsigned long hash;
+
+	net_get_random_once(&rds_hash_secret, sizeof(rds_hash_secret));
+
 	/* Pass NULL, don't need struct net for hash */
-	unsigned long hash = __inet_ehashfn(be32_to_cpu(laddr), 0,
-					    be32_to_cpu(faddr), 0,
-					    inet_ehash_secret);
+	hash = __inet_ehashfn(be32_to_cpu(laddr), 0,
+			      be32_to_cpu(faddr), 0,
+			      rds_hash_secret);
 	return &rds_conn_hash[hash & RDS_CONNECTION_HASH_MASK];
 }
 
-- 
1.8.3.1
