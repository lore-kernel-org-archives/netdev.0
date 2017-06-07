From: Ivan Delalande <colona@arista.com>
Subject: [PATCH 1/2] tcp: md5: add an address prefix for key lookup
Date: Tue,  6 Jun 2017 17:54:13 -0700
Message-ID: <20170607005414.25361-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows the keys used for TCP MD5 signature to be used for whole
range of addresses, specified with a prefix length, instead of only one
address as it currently is.

Signed-off-by: Bob Gilligan <gilligan@arista.com>
Signed-off-by: Eric Mowat <mowat@arista.com>
Signed-off-by: Ivan Delalande <colona@arista.com>
---
 include/net/tcp.h   |  6 +++--
 net/ipv4/tcp_ipv4.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++-------
 net/ipv6/tcp_ipv6.c | 12 ++++++----
 3 files changed, 70 insertions(+), 16 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 38a7427ae902..2b68023ab095 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1395,6 +1395,7 @@ struct tcp_md5sig_key {
 	u8			keylen;
 	u8			family; /* AF_INET or AF_INET6 */
 	union tcp_md5_addr	addr;
+	u8			prefixlen;
 	u8			key[TCP_MD5SIG_MAXKEYLEN];
 	struct rcu_head		rcu;
 };
@@ -1438,9 +1439,10 @@ struct tcp_md5sig_pool {
 int tcp_v4_md5_hash_skb(char *md5_hash, const struct tcp_md5sig_key *key,
 			const struct sock *sk, const struct sk_buff *skb);
 int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
-		   int family, const u8 *newkey, u8 newkeylen, gfp_t gfp);
+		   int family, u8 prefixlen, const u8 *newkey, u8 newkeylen,
+		   gfp_t gfp);
 int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr,
-		   int family);
+		   int family, u8 prefixlen);
 struct tcp_md5sig_key *tcp_v4_md5_lookup(const struct sock *sk,
 					 const struct sock *addr_sk);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5ab2aac5ca19..51ca3bd5a8a3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -80,6 +80,7 @@
 #include <linux/stddef.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/inetdevice.h>
 
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
@@ -906,6 +907,9 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 	struct tcp_md5sig_key *key;
 	unsigned int size = sizeof(struct in_addr);
 	const struct tcp_md5sig_info *md5sig;
+	__be32 mask;
+	struct tcp_md5sig_key *best_match = NULL;
+	bool match;
 
 	/* caller either holds rcu_read_lock() or socket lock */
 	md5sig = rcu_dereference_check(tp->md5sig_info,
@@ -919,12 +923,55 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 	hlist_for_each_entry_rcu(key, &md5sig->head, node) {
 		if (key->family != family)
 			continue;
-		if (!memcmp(&key->addr, addr, size))
+
+		if (family == AF_INET) {
+			mask = inet_make_mask(key->prefixlen);
+			match = (key->addr.a4.s_addr & mask) ==
+				(addr->a4.s_addr & mask);
+#if IS_ENABLED(CONFIG_IPV6)
+		} else if (family == AF_INET6) {
+			match = ipv6_prefix_equal(&key->addr.a6, &addr->a6,
+						  key->prefixlen);
+#endif
+		} else {
+			match = false;
+		}
+
+		if (match && (!best_match ||
+			      key->prefixlen > best_match->prefixlen))
+			best_match = key;
+	}
+	return best_match;
+}
+EXPORT_SYMBOL(tcp_md5_do_lookup);
+
+struct tcp_md5sig_key *tcp_md5_do_lookup_exact(const struct sock *sk,
+					       const union tcp_md5_addr *addr,
+					       int family, u8 prefixlen)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_md5sig_key *key;
+	unsigned int size = sizeof(struct in_addr);
+	const struct tcp_md5sig_info *md5sig;
+
+	/* caller either holds rcu_read_lock() or socket lock */
+	md5sig = rcu_dereference_check(tp->md5sig_info,
+				       lockdep_sock_is_held(sk));
+	if (!md5sig)
+		return NULL;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (family == AF_INET6)
+		size = sizeof(struct in6_addr);
+#endif
+	hlist_for_each_entry_rcu(key, &md5sig->head, node) {
+		if (key->family != family)
+			continue;
+		if (!memcmp(&key->addr, addr, size) &&
+		    key->prefixlen == prefixlen)
 			return key;
 	}
 	return NULL;
 }
-EXPORT_SYMBOL(tcp_md5_do_lookup);
 
 struct tcp_md5sig_key *tcp_v4_md5_lookup(const struct sock *sk,
 					 const struct sock *addr_sk)
@@ -938,14 +985,15 @@ EXPORT_SYMBOL(tcp_v4_md5_lookup);
 
 /* This can be called on a newly created socket, from other files */
 int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
-		   int family, const u8 *newkey, u8 newkeylen, gfp_t gfp)
+		   int family, u8 prefixlen, const u8 *newkey, u8 newkeylen,
+		   gfp_t gfp)
 {
 	/* Add Key to the list */
 	struct tcp_md5sig_key *key;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_md5sig_info *md5sig;
 
-	key = tcp_md5_do_lookup(sk, addr, family);
+	key = tcp_md5_do_lookup_exact(sk, addr, family, prefixlen);
 	if (key) {
 		/* Pre-existing entry - just update that one. */
 		memcpy(key->key, newkey, newkeylen);
@@ -976,6 +1024,7 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 	memcpy(key->key, newkey, newkeylen);
 	key->keylen = newkeylen;
 	key->family = family;
+	key->prefixlen = prefixlen;
 	memcpy(&key->addr, addr,
 	       (family == AF_INET6) ? sizeof(struct in6_addr) :
 				      sizeof(struct in_addr));
@@ -984,11 +1033,12 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 }
 EXPORT_SYMBOL(tcp_md5_do_add);
 
-int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr, int family)
+int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr, int family,
+		   u8 prefixlen)
 {
 	struct tcp_md5sig_key *key;
 
-	key = tcp_md5_do_lookup(sk, addr, family);
+	key = tcp_md5_do_lookup_exact(sk, addr, family, prefixlen);
 	if (!key)
 		return -ENOENT;
 	hlist_del_rcu(&key->node);
@@ -1031,13 +1081,13 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 
 	if (!cmd.tcpm_keylen)
 		return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin->sin_addr.s_addr,
-				      AF_INET);
+				      AF_INET, 32);
 
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
 		return -EINVAL;
 
 	return tcp_md5_do_add(sk, (union tcp_md5_addr *)&sin->sin_addr.s_addr,
-			      AF_INET, cmd.tcpm_key, cmd.tcpm_keylen,
+			      AF_INET, 32, cmd.tcpm_key, cmd.tcpm_keylen,
 			      GFP_KERNEL);
 }
 
@@ -1340,7 +1390,7 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 		 * across. Shucks.
 		 */
 		tcp_md5_do_add(newsk, (union tcp_md5_addr *)&newinet->inet_daddr,
-			       AF_INET, key->key, key->keylen, GFP_ATOMIC);
+			       AF_INET, 32, key->key, key->keylen, GFP_ATOMIC);
 		sk_nocaps_add(newsk, NETIF_F_GSO_MASK);
 	}
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7a8237acd210..5cf19dab60aa 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -532,9 +532,9 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 	if (!cmd.tcpm_keylen) {
 		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
 			return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin6->sin6_addr.s6_addr32[3],
-					      AF_INET);
+					      AF_INET, 32);
 		return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin6->sin6_addr,
-				      AF_INET6);
+				      AF_INET6, 128);
 	}
 
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
@@ -542,10 +542,12 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 
 	if (ipv6_addr_v4mapped(&sin6->sin6_addr))
 		return tcp_md5_do_add(sk, (union tcp_md5_addr *)&sin6->sin6_addr.s6_addr32[3],
-				      AF_INET, cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
+				      AF_INET, 32, cmd.tcpm_key,
+				      cmd.tcpm_keylen, GFP_KERNEL);
 
 	return tcp_md5_do_add(sk, (union tcp_md5_addr *)&sin6->sin6_addr,
-			      AF_INET6, cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
+			      AF_INET6, 128, cmd.tcpm_key, cmd.tcpm_keylen,
+			      GFP_KERNEL);
 }
 
 static int tcp_v6_md5_hash_headers(struct tcp_md5sig_pool *hp,
@@ -1183,7 +1185,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 		 * across. Shucks.
 		 */
 		tcp_md5_do_add(newsk, (union tcp_md5_addr *)&newsk->sk_v6_daddr,
-			       AF_INET6, key->key, key->keylen,
+			       AF_INET6, 128, key->key, key->keylen,
 			       sk_gfp_mask(sk, GFP_ATOMIC));
 	}
 #endif
-- 
2.13.0
