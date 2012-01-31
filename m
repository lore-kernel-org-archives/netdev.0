From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: rcu conversion
Date: Tue, 31 Jan 2012 16:18:33 +0100
Message-ID: <1328023113.2297.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327975638-16530-1-git-send-email-shawn.lu@ericsson.com>
	 <CAL4WiipdO5+1Fi_ig5hB25d2LJvc+cjzyAbo8mxx3e4EiRx9YA@mail.gmail.com>
	 <62162DF05402B341B3DB59932A1FA992B5B5B929BD@EUSAACMS0702.eamcs.ericsson.se>
	 <1328000712.2422.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328016828.2297.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52473 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235Ab2AaPSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 10:18:38 -0500
Received: by bkcjm19 with SMTP id jm19so50904bkc.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 07:18:36 -0800 (PST)
In-Reply-To: <1328016828.2297.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to be able to support proper RST messages for TCP MD5 flows, we
need to allow access to MD5 keys without locking listener socket.

This conversion is a nice cleanup, and shrinks size of timewait sockets
by 80 bytes.

IPv6 code reuses generic code found in IPv4 instead of duplicating it.

Control path uses GFP_KERNEL allocations instead of GFP_ATOMIC.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Shawn Lu <shawn.lu@ericsson.com>
---
 include/linux/tcp.h      |    3 
 include/net/tcp.h        |   61 ++++-----
 net/ipv4/tcp_ipv4.c      |  227 +++++++++++++++----------------------
 net/ipv4/tcp_minisocks.c |   12 -
 net/ipv6/tcp_ipv6.c      |  173 +---------------------------
 5 files changed, 141 insertions(+), 335 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 46a85c9..c2025f1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -486,8 +486,7 @@ struct tcp_timewait_sock {
 	u32			  tw_ts_recent;
 	long			  tw_ts_recent_stamp;
 #ifdef CONFIG_TCP_MD5SIG
-	u16			  tw_md5_keylen;
-	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
+	struct tcp_md5sig_key	*tw_md5_key;
 #endif
 	/* Few sockets in timewait have cookies; in that case, then this
 	 * object holds a reference to them (tw_cookie_values->kref).
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3c90346..10ae4c7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1130,35 +1130,26 @@ static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
 /* MD5 Signature */
 struct crypto_hash;
 
+union tcp_md5_addr {
+	struct in_addr  a4;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct in6_addr	a6;
+#endif
+};
+
 /* - key database */
 struct tcp_md5sig_key {
-	u8			*key;
+	struct hlist_node	node;
 	u8			keylen;
-};
-
-struct tcp4_md5sig_key {
-	struct tcp_md5sig_key	base;
-	__be32			addr;
-};
-
-struct tcp6_md5sig_key {
-	struct tcp_md5sig_key	base;
-#if 0
-	u32			scope_id;	/* XXX */
-#endif
-	struct in6_addr		addr;
+	u8			family; /* AF_INET or AF_INET6 */
+	union tcp_md5_addr	addr;
+	u8			key[TCP_MD5SIG_MAXKEYLEN];
+	struct rcu_head		rcu;
 };
 
 /* - sock block */
 struct tcp_md5sig_info {
-	struct tcp4_md5sig_key	*keys4;
-#if IS_ENABLED(CONFIG_IPV6)
-	struct tcp6_md5sig_key	*keys6;
-	u32			entries6;
-	u32			alloced6;
-#endif
-	u32			entries4;
-	u32			alloced4;
+	struct hlist_head	head;
 };
 
 /* - pseudo header */
@@ -1195,19 +1186,25 @@ extern int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 			       const struct sock *sk,
 			       const struct request_sock *req,
 			       const struct sk_buff *skb);
-extern struct tcp_md5sig_key * tcp_v4_md5_lookup(struct sock *sk,
-						 struct sock *addr_sk);
-extern int tcp_v4_md5_do_add(struct sock *sk, __be32 addr, u8 *newkey,
-			     u8 newkeylen);
-extern int tcp_v4_md5_do_del(struct sock *sk, __be32 addr);
+extern int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
+			  int family, const u8 *newkey,
+			  u8 newkeylen, gfp_t gfp);
+extern int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr,
+			  int family);
+extern struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
+					 struct sock *addr_sk);
 
 #ifdef CONFIG_TCP_MD5SIG
-#define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_keylen ? 		 \
-				 &(struct tcp_md5sig_key) {		 \
-					.key = (twsk)->tw_md5_key,	 \
-					.keylen = (twsk)->tw_md5_keylen, \
-				} : NULL)
+extern struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+			const union tcp_md5_addr *addr, int family);
+#define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_key)
 #else
+static inline struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+					 const union tcp_md5_addr *addr,
+					 int family)
+{
+	return NULL;
+}
 #define tcp_twsk_md5_key(twsk)	NULL
 #endif
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 345e249..1d5fd82 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -90,16 +90,8 @@ EXPORT_SYMBOL(sysctl_tcp_low_latency);
 
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
-						   __be32 addr);
-static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
+static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 			       __be32 daddr, __be32 saddr, const struct tcphdr *th);
-#else
-static inline
-struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
-{
-	return NULL;
-}
 #endif
 
 struct inet_hashinfo tcp_hashinfo;
@@ -631,7 +623,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	arg.iov[0].iov_len  = sizeof(rep.th);
 
 #ifdef CONFIG_TCP_MD5SIG
-	key = sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->saddr) : NULL;
+	key = sk ? tcp_md5_do_lookup(sk,
+				     (union tcp_md5_addr *)&ip_hdr(skb)->saddr,
+				     AF_INET) : NULL;
 	if (key) {
 		rep.opt[0] = htonl((TCPOPT_NOP << 24) |
 				   (TCPOPT_NOP << 16) |
@@ -759,7 +753,8 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
 			req->ts_recent,
 			0,
-			tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr),
+			tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&ip_hdr(skb)->daddr,
+					  AF_INET),
 			inet_rsk(req)->no_srccheck ? IP_REPLY_ARG_NOSRCCHECK : 0,
 			ip_hdr(skb)->tos);
 }
@@ -876,146 +871,124 @@ static struct ip_options_rcu *tcp_v4_save_options(struct sock *sk,
  */
 
 /* Find the Key structure for an address.  */
-static struct tcp_md5sig_key *
-			tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+					 const union tcp_md5_addr *addr,
+					 int family)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int i;
+	struct tcp_md5sig_key *key;
+	struct hlist_node *pos;
+	unsigned int size = sizeof(struct in_addr);
 
-	if (!tp->md5sig_info || !tp->md5sig_info->entries4)
+	if (!tp->md5sig_info)
 		return NULL;
-	for (i = 0; i < tp->md5sig_info->entries4; i++) {
-		if (tp->md5sig_info->keys4[i].addr == addr)
-			return &tp->md5sig_info->keys4[i].base;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (family == AF_INET6)
+		size = sizeof(struct in6_addr);
+#endif
+	hlist_for_each_entry_rcu(key, pos, &tp->md5sig_info->head, node) {
+		if (key->family != family)
+			continue;
+		if (!memcmp(&key->addr, addr, size))
+			return key;
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(tcp_md5_do_lookup);
 
 struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
 					 struct sock *addr_sk)
 {
-	return tcp_v4_md5_do_lookup(sk, inet_sk(addr_sk)->inet_daddr);
+	union tcp_md5_addr *addr;
+
+	addr = (union tcp_md5_addr *)&inet_sk(addr_sk)->inet_daddr;
+	return tcp_md5_do_lookup(sk, addr, AF_INET);
 }
 EXPORT_SYMBOL(tcp_v4_md5_lookup);
 
 static struct tcp_md5sig_key *tcp_v4_reqsk_md5_lookup(struct sock *sk,
 						      struct request_sock *req)
 {
-	return tcp_v4_md5_do_lookup(sk, inet_rsk(req)->rmt_addr);
+	union tcp_md5_addr *addr;
+
+	addr = (union tcp_md5_addr *)&inet_rsk(req)->rmt_addr;
+	return tcp_md5_do_lookup(sk, addr, AF_INET);
 }
 
 /* This can be called on a newly created socket, from other files */
-int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
-		      u8 *newkey, u8 newkeylen)
+int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
+		   int family, const u8 *newkey, u8 newkeylen, gfp_t gfp)
 {
 	/* Add Key to the list */
 	struct tcp_md5sig_key *key;
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp4_md5sig_key *keys;
+	struct tcp_md5sig_info *md5sig;
 
-	key = tcp_v4_md5_do_lookup(sk, addr);
+	key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&addr, AF_INET);
 	if (key) {
 		/* Pre-existing entry - just update that one. */
-		kfree(key->key);
-		key->key = newkey;
+		memcpy(key->key, newkey, newkeylen);
 		key->keylen = newkeylen;
-	} else {
-		struct tcp_md5sig_info *md5sig;
-
-		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info),
-						  GFP_ATOMIC);
-			if (!tp->md5sig_info) {
-				kfree(newkey);
-				return -ENOMEM;
-			}
-			sk_nocaps_add(sk, NETIF_F_GSO_MASK);
-		}
+		return 0;
+	}
 
-		md5sig = tp->md5sig_info;
-		if (md5sig->entries4 == 0 &&
-		    tcp_alloc_md5sig_pool(sk) == NULL) {
-			kfree(newkey);
+	md5sig = tp->md5sig_info;
+	if (!md5sig) {
+		md5sig = kmalloc(sizeof(*md5sig), gfp);
+		if (!md5sig)
 			return -ENOMEM;
-		}
-
-		if (md5sig->alloced4 == md5sig->entries4) {
-			keys = kmalloc((sizeof(*keys) *
-					(md5sig->entries4 + 1)), GFP_ATOMIC);
-			if (!keys) {
-				kfree(newkey);
-				if (md5sig->entries4 == 0)
-					tcp_free_md5sig_pool();
-				return -ENOMEM;
-			}
 
-			if (md5sig->entries4)
-				memcpy(keys, md5sig->keys4,
-				       sizeof(*keys) * md5sig->entries4);
+		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
+		INIT_HLIST_HEAD(&md5sig->head);
+		tp->md5sig_info = md5sig;
+	}
 
-			/* Free old key list, and reference new one */
-			kfree(md5sig->keys4);
-			md5sig->keys4 = keys;
-			md5sig->alloced4++;
-		}
-		md5sig->entries4++;
-		md5sig->keys4[md5sig->entries4 - 1].addr        = addr;
-		md5sig->keys4[md5sig->entries4 - 1].base.key    = newkey;
-		md5sig->keys4[md5sig->entries4 - 1].base.keylen = newkeylen;
+	key = kmalloc(sizeof(*key), gfp);
+	if (!key)
+		return -ENOMEM;
+	if (hlist_empty(&md5sig->head) && !tcp_alloc_md5sig_pool(sk)) {
+		kfree(key);
+		return -ENOMEM;
 	}
+
+	memcpy(key->key, newkey, newkeylen);
+	key->keylen = newkeylen;
+	key->family = family;
+	memcpy(&key->addr, addr,
+	       (family == AF_INET6) ? sizeof(struct in6_addr) :
+				      sizeof(struct in_addr));
+	hlist_add_head_rcu(&key->node, &md5sig->head);
 	return 0;
 }
-EXPORT_SYMBOL(tcp_v4_md5_do_add);
+EXPORT_SYMBOL(tcp_md5_do_add);
 
-int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
+int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr, int family)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int i;
-
-	for (i = 0; i < tp->md5sig_info->entries4; i++) {
-		if (tp->md5sig_info->keys4[i].addr == addr) {
-			/* Free the key */
-			kfree(tp->md5sig_info->keys4[i].base.key);
-			tp->md5sig_info->entries4--;
-
-			if (tp->md5sig_info->entries4 == 0) {
-				kfree(tp->md5sig_info->keys4);
-				tp->md5sig_info->keys4 = NULL;
-				tp->md5sig_info->alloced4 = 0;
-				tcp_free_md5sig_pool();
-			} else if (tp->md5sig_info->entries4 != i) {
-				/* Need to do some manipulation */
-				memmove(&tp->md5sig_info->keys4[i],
-					&tp->md5sig_info->keys4[i+1],
-					(tp->md5sig_info->entries4 - i) *
-					 sizeof(struct tcp4_md5sig_key));
-			}
-			return 0;
-		}
-	}
-	return -ENOENT;
+	struct tcp_md5sig_key *key;
+
+	key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&addr, AF_INET);
+	if (!key)
+		return -ENOENT;
+	hlist_del_rcu(&key->node);
+	kfree_rcu(key, rcu);
+	if (hlist_empty(&tp->md5sig_info->head))
+		tcp_free_md5sig_pool();
+	return 0;
 }
-EXPORT_SYMBOL(tcp_v4_md5_do_del);
+EXPORT_SYMBOL(tcp_md5_do_del);
 
-static void tcp_v4_clear_md5_list(struct sock *sk)
+void tcp_clear_md5_list(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_md5sig_key *key;
+	struct hlist_node *pos, *n;
 
-	/* Free each key, then the set of key keys,
-	 * the crypto element, and then decrement our
-	 * hold on the last resort crypto.
-	 */
-	if (tp->md5sig_info->entries4) {
-		int i;
-		for (i = 0; i < tp->md5sig_info->entries4; i++)
-			kfree(tp->md5sig_info->keys4[i].base.key);
-		tp->md5sig_info->entries4 = 0;
+	if (!hlist_empty(&tp->md5sig_info->head))
 		tcp_free_md5sig_pool();
-	}
-	if (tp->md5sig_info->keys4) {
-		kfree(tp->md5sig_info->keys4);
-		tp->md5sig_info->keys4 = NULL;
-		tp->md5sig_info->alloced4  = 0;
+	hlist_for_each_entry_safe(key, pos, n, &tp->md5sig_info->head, node) {
+		hlist_del_rcu(&key->node);
+		kfree_rcu(key, rcu);
 	}
 }
 
@@ -1024,7 +997,6 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
-	u8 *newkey;
 
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
@@ -1038,29 +1010,16 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 	if (!cmd.tcpm_key || !cmd.tcpm_keylen) {
 		if (!tcp_sk(sk)->md5sig_info)
 			return -ENOENT;
-		return tcp_v4_md5_do_del(sk, sin->sin_addr.s_addr);
+		return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin->sin_addr.s_addr,
+				      AF_INET);
 	}
 
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
 		return -EINVAL;
 
-	if (!tcp_sk(sk)->md5sig_info) {
-		struct tcp_sock *tp = tcp_sk(sk);
-		struct tcp_md5sig_info *p;
-
-		p = kzalloc(sizeof(*p), sk->sk_allocation);
-		if (!p)
-			return -EINVAL;
-
-		tp->md5sig_info = p;
-		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
-	}
-
-	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, sk->sk_allocation);
-	if (!newkey)
-		return -ENOMEM;
-	return tcp_v4_md5_do_add(sk, sin->sin_addr.s_addr,
-				 newkey, cmd.tcpm_keylen);
+	return tcp_md5_do_add(sk, (union tcp_md5_addr *)&sin->sin_addr.s_addr,
+			      AF_INET, cmd.tcpm_key, cmd.tcpm_keylen,
+			      GFP_KERNEL);
 }
 
 static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
@@ -1086,7 +1045,7 @@ static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
 }
 
-static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
+static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 			       __be32 daddr, __be32 saddr, const struct tcphdr *th)
 {
 	struct tcp_md5sig_pool *hp;
@@ -1186,7 +1145,8 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 	int genhash;
 	unsigned char newhash[16];
 
-	hash_expected = tcp_v4_md5_do_lookup(sk, iph->saddr);
+	hash_expected = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&iph->saddr,
+					  AF_INET);
 	hash_location = tcp_parse_md5sig_option(th);
 
 	/* We've parsed the options - do we have a hash? */
@@ -1474,7 +1434,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
-	key = tcp_v4_md5_do_lookup(sk, newinet->inet_daddr);
+	key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&newinet->inet_daddr,
+				AF_INET);
 	if (key != NULL) {
 		/*
 		 * We're using one, so create a matching key
@@ -1482,10 +1443,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 * memory, then we end up not copying the key
 		 * across. Shucks.
 		 */
-		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
-		if (newkey != NULL)
-			tcp_v4_md5_do_add(newsk, newinet->inet_daddr,
-					  newkey, key->keylen);
+		tcp_md5_do_add(newsk, (union tcp_md5_addr *)&newinet->inet_daddr,
+			       AF_INET, key->key, key->keylen, GFP_ATOMIC);
 		sk_nocaps_add(newsk, NETIF_F_GSO_MASK);
 	}
 #endif
@@ -1934,7 +1893,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 #ifdef CONFIG_TCP_MD5SIG
 	/* Clean up the MD5 key list, if any */
 	if (tp->md5sig_info) {
-		tcp_v4_clear_md5_list(sk);
+		tcp_clear_md5_list(sk);
 		kfree(tp->md5sig_info);
 		tp->md5sig_info = NULL;
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 550e755..3cabafb 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -359,13 +359,11 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		 */
 		do {
 			struct tcp_md5sig_key *key;
-			memset(tcptw->tw_md5_key, 0, sizeof(tcptw->tw_md5_key));
-			tcptw->tw_md5_keylen = 0;
+			tcptw->tw_md5_key = NULL;
 			key = tp->af_specific->md5_lookup(sk, sk);
 			if (key != NULL) {
-				memcpy(&tcptw->tw_md5_key, key->key, key->keylen);
-				tcptw->tw_md5_keylen = key->keylen;
-				if (tcp_alloc_md5sig_pool(sk) == NULL)
+				tcptw->tw_md5_key = kmemdup(key, sizeof(*key), GFP_ATOMIC);
+				if (tcptw->tw_md5_key && tcp_alloc_md5sig_pool(sk) == NULL)
 					BUG();
 			}
 		} while (0);
@@ -405,8 +403,10 @@ void tcp_twsk_destructor(struct sock *sk)
 {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
-	if (twsk->tw_md5_keylen)
+	if (twsk->tw_md5_key) {
 		tcp_free_md5sig_pool();
+		kfree_rcu(twsk->tw_md5_key, rcu);
+	}
 #endif
 }
 EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f37769e..bec41f9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -540,19 +540,7 @@ static void tcp_v6_reqsk_destructor(struct request_sock *req)
 static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
 						   const struct in6_addr *addr)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	int i;
-
-	BUG_ON(tp == NULL);
-
-	if (!tp->md5sig_info || !tp->md5sig_info->entries6)
-		return NULL;
-
-	for (i = 0; i < tp->md5sig_info->entries6; i++) {
-		if (ipv6_addr_equal(&tp->md5sig_info->keys6[i].addr, addr))
-			return &tp->md5sig_info->keys6[i].base;
-	}
-	return NULL;
+	return tcp_md5_do_lookup(sk, (union tcp_md5_addr *)addr, AF_INET6);
 }
 
 static struct tcp_md5sig_key *tcp_v6_md5_lookup(struct sock *sk,
@@ -567,129 +555,11 @@ static struct tcp_md5sig_key *tcp_v6_reqsk_md5_lookup(struct sock *sk,
 	return tcp_v6_md5_do_lookup(sk, &inet6_rsk(req)->rmt_addr);
 }
 
-static int tcp_v6_md5_do_add(struct sock *sk, const struct in6_addr *peer,
-			     char *newkey, u8 newkeylen)
-{
-	/* Add key to the list */
-	struct tcp_md5sig_key *key;
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp6_md5sig_key *keys;
-
-	key = tcp_v6_md5_do_lookup(sk, peer);
-	if (key) {
-		/* modify existing entry - just update that one */
-		kfree(key->key);
-		key->key = newkey;
-		key->keylen = newkeylen;
-	} else {
-		/* reallocate new list if current one is full. */
-		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
-			if (!tp->md5sig_info) {
-				kfree(newkey);
-				return -ENOMEM;
-			}
-			sk_nocaps_add(sk, NETIF_F_GSO_MASK);
-		}
-		if (tp->md5sig_info->entries6 == 0 &&
-			tcp_alloc_md5sig_pool(sk) == NULL) {
-			kfree(newkey);
-			return -ENOMEM;
-		}
-		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
-			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
-				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
-
-			if (!keys) {
-				kfree(newkey);
-				if (tp->md5sig_info->entries6 == 0)
-					tcp_free_md5sig_pool();
-				return -ENOMEM;
-			}
-
-			if (tp->md5sig_info->entries6)
-				memmove(keys, tp->md5sig_info->keys6,
-					(sizeof (tp->md5sig_info->keys6[0]) *
-					 tp->md5sig_info->entries6));
-
-			kfree(tp->md5sig_info->keys6);
-			tp->md5sig_info->keys6 = keys;
-			tp->md5sig_info->alloced6++;
-		}
-
-		tp->md5sig_info->keys6[tp->md5sig_info->entries6].addr = *peer;
-		tp->md5sig_info->keys6[tp->md5sig_info->entries6].base.key = newkey;
-		tp->md5sig_info->keys6[tp->md5sig_info->entries6].base.keylen = newkeylen;
-
-		tp->md5sig_info->entries6++;
-	}
-	return 0;
-}
-
-static int tcp_v6_md5_do_del(struct sock *sk, const struct in6_addr *peer)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	int i;
-
-	for (i = 0; i < tp->md5sig_info->entries6; i++) {
-		if (ipv6_addr_equal(&tp->md5sig_info->keys6[i].addr, peer)) {
-			/* Free the key */
-			kfree(tp->md5sig_info->keys6[i].base.key);
-			tp->md5sig_info->entries6--;
-
-			if (tp->md5sig_info->entries6 == 0) {
-				kfree(tp->md5sig_info->keys6);
-				tp->md5sig_info->keys6 = NULL;
-				tp->md5sig_info->alloced6 = 0;
-				tcp_free_md5sig_pool();
-			} else {
-				/* shrink the database */
-				if (tp->md5sig_info->entries6 != i)
-					memmove(&tp->md5sig_info->keys6[i],
-						&tp->md5sig_info->keys6[i+1],
-						(tp->md5sig_info->entries6 - i)
-						* sizeof (tp->md5sig_info->keys6[0]));
-			}
-			return 0;
-		}
-	}
-	return -ENOENT;
-}
-
-static void tcp_v6_clear_md5_list (struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	int i;
-
-	if (tp->md5sig_info->entries6) {
-		for (i = 0; i < tp->md5sig_info->entries6; i++)
-			kfree(tp->md5sig_info->keys6[i].base.key);
-		tp->md5sig_info->entries6 = 0;
-		tcp_free_md5sig_pool();
-	}
-
-	kfree(tp->md5sig_info->keys6);
-	tp->md5sig_info->keys6 = NULL;
-	tp->md5sig_info->alloced6 = 0;
-
-	if (tp->md5sig_info->entries4) {
-		for (i = 0; i < tp->md5sig_info->entries4; i++)
-			kfree(tp->md5sig_info->keys4[i].base.key);
-		tp->md5sig_info->entries4 = 0;
-		tcp_free_md5sig_pool();
-	}
-
-	kfree(tp->md5sig_info->keys4);
-	tp->md5sig_info->keys4 = NULL;
-	tp->md5sig_info->alloced4 = 0;
-}
-
 static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 				  int optlen)
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
-	u8 *newkey;
 
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
@@ -704,33 +574,21 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 		if (!tcp_sk(sk)->md5sig_info)
 			return -ENOENT;
 		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
-			return tcp_v4_md5_do_del(sk, sin6->sin6_addr.s6_addr32[3]);
-		return tcp_v6_md5_do_del(sk, &sin6->sin6_addr);
+			return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin6->sin6_addr.s6_addr32[3],
+					      AF_INET);
+		return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin6->sin6_addr,
+				      AF_INET6);
 	}
 
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
 		return -EINVAL;
 
-	if (!tcp_sk(sk)->md5sig_info) {
-		struct tcp_sock *tp = tcp_sk(sk);
-		struct tcp_md5sig_info *p;
-
-		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
-		if (!p)
-			return -ENOMEM;
-
-		tp->md5sig_info = p;
-		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
-	}
+	if (ipv6_addr_v4mapped(&sin6->sin6_addr))
+		return tcp_md5_do_add(sk, (union tcp_md5_addr *)&sin6->sin6_addr.s6_addr32[3],
+				      AF_INET, cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
 
-	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
-	if (!newkey)
-		return -ENOMEM;
-	if (ipv6_addr_v4mapped(&sin6->sin6_addr)) {
-		return tcp_v4_md5_do_add(sk, sin6->sin6_addr.s6_addr32[3],
-					 newkey, cmd.tcpm_keylen);
-	}
-	return tcp_v6_md5_do_add(sk, &sin6->sin6_addr, newkey, cmd.tcpm_keylen);
+	return tcp_md5_do_add(sk, (union tcp_md5_addr *)&sin6->sin6_addr,
+			      AF_INET6, cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
 }
 
 static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
@@ -1503,10 +1361,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 * memory, then we end up not copying the key
 		 * across. Shucks.
 		 */
-		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
-		if (newkey != NULL)
-			tcp_v6_md5_do_add(newsk, &newnp->daddr,
-					  newkey, key->keylen);
+		tcp_md5_do_add(newsk, (union tcp_md5_addr *)&newnp->daddr,
+			       AF_INET6, key->key, key->keylen, GFP_ATOMIC);
 	}
 #endif
 
@@ -1995,11 +1851,6 @@ static int tcp_v6_init_sock(struct sock *sk)
 
 static void tcp_v6_destroy_sock(struct sock *sk)
 {
-#ifdef CONFIG_TCP_MD5SIG
-	/* Clean up the MD5 key list */
-	if (tcp_sk(sk)->md5sig_info)
-		tcp_v6_clear_md5_list(sk);
-#endif
 	tcp_v4_destroy_sock(sk);
 	inet6_destroy_sock(sk);
 }
