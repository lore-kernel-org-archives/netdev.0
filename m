From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH] tcp: md5 signature check scaling
Date: Wed, 27 Oct 2010 16:52:30 +0400
Message-ID: <AANLkTi=U1smX6XXDMyBTicyqbUU5V-t56jmH7qtX2XW5__34176.6111240306$1288183967$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38200 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756397Ab0J0Mwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 08:52:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Popov <dp@highloadlab.com>

TCP MD5 signature checking without socket lock.

Each tcp_sock has 2 RCU-protected arrays (tcp[46]_md5sig_info) of
tcp[46]_md5sig_key address-key pairs.
Each key (tcp_md5sig_key) has kref struct so that there is no need to
lock the whole array to work with one key.

MD5 functions were rewritten according to above statement and hash
check (tcp_v4_inbound_md5_hash) was moved before socket lock.

Signed-off-by: Dmitry Popov <dp@highloadlab.com>
---
 include/linux/tcp.h      |   14 ++-
 include/net/tcp.h        |   82 +++++++----
 net/ipv4/tcp_ipv4.c      |  370 ++++++++++++++++++++++++++++------------------
 net/ipv4/tcp_minisocks.c |   26 +--
 net/ipv4/tcp_output.c    |   12 +-
 net/ipv6/tcp_ipv6.c      |  358 +++++++++++++++++++++++++++-----------------
 6 files changed, 531 insertions(+), 331 deletions(-)
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..806266a 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -450,8 +450,14 @@ struct tcp_sock {
 /* TCP AF-Specific parts; only used by MD5 Signature support so far */
 	const struct tcp_sock_af_ops	*af_specific;

-/* TCP MD5 Signature Option information */
-	struct tcp_md5sig_info	*md5sig_info;
+/* IPV4 TCP MD5 Signature Option information */
+	struct tcp4_md5sig_info	*md5sig_info4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+
+/* IPV6 TCP MD5 Signature Option information */
+	struct tcp6_md5sig_info	*md5sig_info6;
+#endif
+
 #endif

 	/* When the cookie options are generated and exchanged, then this
@@ -474,8 +480,8 @@ struct tcp_timewait_sock {
 	u32			  tw_ts_recent;
 	long			  tw_ts_recent_stamp;
 #ifdef CONFIG_TCP_MD5SIG
-	u16			  tw_md5_keylen;
-	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
+	/* MD5 key from parent socket */
+	struct tcp_md5sig_key	  *tw_md5sig_key;
 #endif
 	/* Few sockets in timewait have cookies; in that case, then this
 	 * object holds a reference to them (tw_cookie_values->kref).
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3e4b33e..3f0dbec 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1092,33 +1092,46 @@ struct crypto_hash;

 /* - key database */
 struct tcp_md5sig_key {
-	u8			*key;
-	u8			keylen;
+	struct kref kref;
+	/* Actually we need only 1 byte for keylen,
+	 * but we want key to be aligned
+	 */
+	u32			keylen;
+	u8			key[0];
 };

 struct tcp4_md5sig_key {
-	struct tcp_md5sig_key	base;
+	struct tcp_md5sig_key	*base;
 	__be32			addr;
+#ifdef CONFIG_64BIT
+	u32 unused;
+#endif
 };

 struct tcp6_md5sig_key {
-	struct tcp_md5sig_key	base;
+	struct tcp_md5sig_key	*base;
 #if 0
 	u32			scope_id;	/* XXX */
 #endif
 	struct in6_addr		addr;
 };

-/* - sock block */
-struct tcp_md5sig_info {
-	struct tcp4_md5sig_key	*keys4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct tcp6_md5sig_key	*keys6;
-	u32			entries6;
-	u32			alloced6;
+struct tcp4_md5sig_info {
+	u32 entries;
+#ifdef CONFIG_64BIT
+	u32 unused;
+#endif
+	struct rcu_head rcu_head;
+	struct tcp4_md5sig_key keys[0];
+};
+
+struct tcp6_md5sig_info {
+	u32 entries;
+#ifdef CONFIG_64BIT
+	u32 unused;
 #endif
-	u32			entries4;
-	u32			alloced4;
+	struct rcu_head rcu_head;
+	struct tcp6_md5sig_key keys[0];
 };

 /* - pseudo header */
@@ -1153,21 +1166,29 @@ struct tcp_md5sig_pool {
 #define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */

 /* - functions */
-extern int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
-			       struct sock *sk, struct request_sock *req,
-			       struct sk_buff *skb);
-extern struct tcp_md5sig_key * tcp_v4_md5_lookup(struct sock *sk,
-						 struct sock *addr_sk);
-extern int tcp_v4_md5_do_add(struct sock *sk, __be32 addr, u8 *newkey,
-			     u8 newkeylen);
-extern int tcp_v4_md5_do_del(struct sock *sk, __be32 addr);
+extern int			tcp_v4_md5_hash_skb(char *md5_hash,
+						    struct tcp_md5sig_key *key,
+						    struct sock *sk,
+						    struct request_sock *req,
+						    struct sk_buff *skb);
+
+extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
+						   struct sock *addr_sk);
+
+extern struct tcp_md5sig_key *tcp_v4_md5_get(struct sock *sk,
+					     struct sock *addr_sk);
+
+extern void tcp_md5_put(struct tcp_md5sig_key *key);
+
+extern int			tcp_v4_md5_do_add(struct sock *sk,
+						  __be32 addr,
+						  struct tcp_md5sig_key *key);
+
+extern int			tcp_v4_md5_do_del(struct sock *sk,
+						  __be32 addr);

 #ifdef CONFIG_TCP_MD5SIG
-#define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_keylen ? 		 \
-				 &(struct tcp_md5sig_key) {		 \
-					.key = (twsk)->tw_md5_key,	 \
-					.keylen = (twsk)->tw_md5_keylen, \
-				} : NULL)
+#define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5sig_key)
 #else
 #define tcp_twsk_md5_key(twsk)	NULL
 #endif
@@ -1413,6 +1434,9 @@ struct tcp_sock_af_ops {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
 						struct sock *addr_sk);
+	struct tcp_md5sig_key	*(*md5_get) (struct sock *sk,
+					     struct sock *addr_sk);
+	void			(*md5_put) (struct tcp_md5sig_key *key);
 	int			(*calc_md5_hash) (char *location,
 						  struct tcp_md5sig_key *md5,
 						  struct sock *sk,
@@ -1420,8 +1444,7 @@ struct tcp_sock_af_ops {
 						  struct sk_buff *skb);
 	int			(*md5_add) (struct sock *sk,
 					    struct sock *addr_sk,
-					    u8 *newkey,
-					    u8 len);
+					    struct tcp_md5sig_key *key);
 	int			(*md5_parse) (struct sock *sk,
 					      char __user *optval,
 					      int optlen);
@@ -1432,6 +1455,9 @@ struct tcp_request_sock_ops {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
 						struct request_sock *req);
+	struct tcp_md5sig_key	*(*md5_get) (struct sock *sk,
+					     struct request_sock *req);
+	void			(*md5_put) (struct tcp_md5sig_key *key);
 	int			(*calc_md5_hash) (char *location,
 						  struct tcp_md5sig_key *md5,
 						  struct sock *sk,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0207662..6068b17 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -88,13 +88,13 @@ EXPORT_SYMBOL(sysctl_tcp_low_latency);


 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
-						   __be32 addr);
+static struct tcp_md5sig_key *tcp_v4_md5_do_get(struct sock *sk,
+						__be32 addr);
 static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
 			       __be32 daddr, __be32 saddr, struct tcphdr *th);
 #else
 static inline
-struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+struct tcp_md5sig_key *tcp_v4_md5_do_get(struct sock *sk, __be32 addr)
 {
 	return NULL;
 }
@@ -621,7 +621,7 @@ static void tcp_v4_send_reset(struct sock *sk,
struct sk_buff *skb)
 	arg.iov[0].iov_len  = sizeof(rep.th);

 #ifdef CONFIG_TCP_MD5SIG
-	key = sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr) : NULL;
+	key = sk ? tcp_v4_md5_do_get(sk, ip_hdr(skb)->daddr) : NULL;
 	if (key) {
 		rep.opt[0] = htonl((TCPOPT_NOP << 24) |
 				   (TCPOPT_NOP << 16) |
@@ -634,6 +634,7 @@ static void tcp_v4_send_reset(struct sock *sk,
struct sk_buff *skb)
 		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[1],
 				     key, ip_hdr(skb)->saddr,
 				     ip_hdr(skb)->daddr, &rep.th);
+		tcp_md5_put(key);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -743,12 +744,17 @@ static void tcp_v4_timewait_ack(struct sock *sk,
struct sk_buff *skb)
 static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
+	struct tcp_md5sig_key *key = tcp_v4_md5_do_get(sk, ip_hdr(skb)->daddr);
+
 	tcp_v4_send_ack(skb, tcp_rsk(req)->snt_isn + 1,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
 			req->ts_recent,
 			0,
-			tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr),
+			key,
 			inet_rsk(req)->no_srccheck ? IP_REPLY_ARG_NOSRCCHECK : 0);
+
+	if (key)
+		tcp_md5_put(key);
 }

 /*
@@ -844,20 +850,38 @@ static struct ip_options
*tcp_v4_save_options(struct sock *sk,

 /* Find the Key structure for an address.  */
 static struct tcp_md5sig_key *
-			tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+			__tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp4_md5sig_info	*md5_info = rcu_dereference(tp->md5sig_info4);
 	int i;

-	if (!tp->md5sig_info || !tp->md5sig_info->entries4)
+	if (!md5_info)
 		return NULL;
-	for (i = 0; i < tp->md5sig_info->entries4; i++) {
-		if (tp->md5sig_info->keys4[i].addr == addr)
-			return &tp->md5sig_info->keys4[i].base;
+
+	for (i = 0; i < md5_info->entries; i++) {
+		if (md5_info->keys[i].addr == addr)
+			return md5_info->keys[i].base;
 	}
 	return NULL;
 }

+static struct tcp_md5sig_key *
+			tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+{
+	struct tcp_md5sig_key *res;
+
+	/* Short path */
+	if (!tcp_sk(sk)->md5sig_info4)
+		return NULL;
+
+	rcu_read_lock();
+	res = __tcp_v4_md5_do_lookup(sk, addr);
+	rcu_read_unlock();
+
+	return res;
+}
+
 struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
 					 struct sock *addr_sk)
 {
@@ -871,96 +895,171 @@ static struct tcp_md5sig_key
*tcp_v4_reqsk_md5_lookup(struct sock *sk,
 	return tcp_v4_md5_do_lookup(sk, inet_rsk(req)->rmt_addr);
 }

+/* Find and lock the Key structure for an address. */
+static struct tcp_md5sig_key *
+			tcp_v4_md5_do_get(struct sock *sk, __be32 addr)
+{
+	struct tcp_md5sig_key *res;
+
+	/* Short path */
+	if (!tcp_sk(sk)->md5sig_info4)
+		return NULL;
+
+	rcu_read_lock();
+	res = __tcp_v4_md5_do_lookup(sk, addr);
+	if (res)
+		kref_get(&res->kref);
+	rcu_read_unlock();
+
+	return res;
+}
+
+struct tcp_md5sig_key *tcp_v4_md5_get(struct sock *sk,
+				      struct sock *addr_sk)
+{
+	return tcp_v4_md5_do_get(sk, inet_sk(addr_sk)->inet_daddr);
+}
+EXPORT_SYMBOL(tcp_v4_md5_get);
+
+static struct tcp_md5sig_key *tcp_v4_reqsk_md5_get(struct sock *sk,
+						   struct request_sock *req)
+{
+	return tcp_v4_md5_do_get(sk, inet_rsk(req)->rmt_addr);
+}
+
+static void md5sig_key_release(struct kref *kref)
+{
+	kfree(container_of(kref, struct tcp_md5sig_key, kref));
+	tcp_free_md5sig_pool();
+}
+
+/* Put md5sig key */
+void tcp_md5_put(struct tcp_md5sig_key *key)
+{
+	kref_put(&key->kref, md5sig_key_release);
+}
+EXPORT_SYMBOL(tcp_md5_put);
+
 /* This can be called on a newly created socket, from other files */
 int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
-		      u8 *newkey, u8 newkeylen)
+		      struct tcp_md5sig_key *key)
 {
 	/* Add Key to the list */
-	struct tcp_md5sig_key *key;
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp4_md5sig_key *keys;
+	struct tcp4_md5sig_info *old_info = NULL;
+	struct tcp4_md5sig_info *new_info;
+	int place = 0;
+	u32 entries;
+
+	if (tp->md5sig_info4) {
+		old_info = tp->md5sig_info4;
+		/* Check if we have to replace old key */
+		for (; place < old_info->entries; place++) {
+			if (old_info->keys[place].addr == addr)
+				break;
+		}
+	} else {
+		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
+	}

-	key = tcp_v4_md5_do_lookup(sk, addr);
-	if (key) {
-		/* Pre-existing entry - just update that one. */
-		kfree(key->key);
-		key->key = newkey;
-		key->keylen = newkeylen;
+	/* Number of entries in new_info */
+	if (old_info) {
+		entries = old_info->entries;
+		if (place == old_info->entries)
+			++entries;
 	} else {
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
-		if (tcp_alloc_md5sig_pool(sk) == NULL) {
-			kfree(newkey);
-			return -ENOMEM;
-		}
-		md5sig = tp->md5sig_info;
-
-		if (md5sig->alloced4 == md5sig->entries4) {
-			keys = kmalloc((sizeof(*keys) *
-					(md5sig->entries4 + 1)), GFP_ATOMIC);
-			if (!keys) {
-				kfree(newkey);
-				tcp_free_md5sig_pool();
-				return -ENOMEM;
-			}
+		entries = 1;
+	}

-			if (md5sig->entries4)
-				memcpy(keys, md5sig->keys4,
-				       sizeof(*keys) * md5sig->entries4);
+	new_info = kmalloc(sizeof(*new_info) +
+				sizeof(new_info->keys[0]) * entries,
+			   GFP_ATOMIC);

-			/* Free old key list, and reference new one */
-			kfree(md5sig->keys4);
-			md5sig->keys4 = keys;
-			md5sig->alloced4++;
-		}
-		md5sig->entries4++;
-		md5sig->keys4[md5sig->entries4 - 1].addr        = addr;
-		md5sig->keys4[md5sig->entries4 - 1].base.key    = newkey;
-		md5sig->keys4[md5sig->entries4 - 1].base.keylen = newkeylen;
+	if (!new_info) {
+		tcp_md5_put(key);
+		return -ENOMEM;
+	}
+
+	new_info->entries = entries;
+
+	if (old_info)
+		memcpy(new_info->keys, old_info->keys,
+			old_info->entries * sizeof(old_info->keys[0]));
+
+	new_info->keys[place].addr = addr;
+	new_info->keys[place].base = key;
+	rcu_assign_pointer(tp->md5sig_info4, new_info);
+
+	/* This function may be called from setsockopt (synchronize_rcu is ok)
+	 * or on a newly created socket (old_info == NULL)
+	 */
+	if (old_info) {
+		synchronize_rcu();
+		if (place != old_info->entries) /* Put old key */
+			tcp_md5_put(old_info->keys[place].base);
+		kfree(old_info);
 	}
+
 	return 0;
 }
 EXPORT_SYMBOL(tcp_v4_md5_do_add);

 static int tcp_v4_md5_add_func(struct sock *sk, struct sock *addr_sk,
-			       u8 *newkey, u8 newkeylen)
+			       struct tcp_md5sig_key *key)
+{
+	return tcp_v4_md5_do_add(sk, inet_sk(addr_sk)->inet_daddr, key);
+}
+
+static int
+	tcp_v4_md5_do_del_ith(struct tcp4_md5sig_info **new_info,
+			      struct tcp4_md5sig_info *old_info,
+			      int i)
 {
-	return tcp_v4_md5_do_add(sk, inet_sk(addr_sk)->inet_daddr,
-				 newkey, newkeylen);
+	struct tcp4_md5sig_info *res_info = NULL;
+
+	if (old_info->entries > 1) {
+		res_info = kmalloc(sizeof(*res_info) +
+					sizeof(res_info->keys[0]) *
+					(old_info->entries - 1),
+					GFP_ATOMIC);
+		if (!res_info)
+			return -ENOMEM;
+		res_info->entries = old_info->entries - 1;
+
+		memcpy(res_info->keys,
+			old_info->keys,
+			i * sizeof(res_info->keys[0]));
+		memcpy(&res_info->keys[i],
+			&old_info->keys[i + 1],
+			(res_info->entries - i) * sizeof(res_info->keys[0]));
+	}
+
+	*new_info = res_info;
+	return 0;
 }

 int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp4_md5sig_info *old_info = tp->md5sig_info4;
 	int i;

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
-			} else if (tp->md5sig_info->entries4 != i) {
-				/* Need to do some manipulation */
-				memmove(&tp->md5sig_info->keys4[i],
-					&tp->md5sig_info->keys4[i+1],
-					(tp->md5sig_info->entries4 - i) *
-					 sizeof(struct tcp4_md5sig_key));
-			}
-			tcp_free_md5sig_pool();
+	if (!old_info)
+		return -ENOENT;
+
+	for (i = 0; i < old_info->entries; i++) {
+		if (old_info->keys[i].addr == addr) {
+			struct tcp4_md5sig_info *new_info;
+			int res;
+
+			res = tcp_v4_md5_do_del_ith(&new_info, old_info, i);
+			if (res)
+				return res;
+
+			rcu_assign_pointer(tp->md5sig_info4, new_info);
+			synchronize_rcu();
+			tcp_md5_put(old_info->keys[i].base);
+			kfree(old_info);
 			return 0;
 		}
 	}
@@ -968,25 +1067,27 @@ int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
 }
 EXPORT_SYMBOL(tcp_v4_md5_do_del);

+static void tcp_v4_md5_clear_info(struct rcu_head *head)
+{
+	struct tcp4_md5sig_info *md5_info =
+		container_of(head, struct tcp4_md5sig_info, rcu_head);
+	int i;
+
+	/* Free each key, then the set of key keys
+	 */
+	for (i = 0; i < md5_info->entries; i++)
+		tcp_md5_put(md5_info->keys[i].base);
+	kfree(md5_info);
+}
+
 static void tcp_v4_clear_md5_list(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp4_md5sig_info *md5_info = tp->md5sig_info4;

-	/* Free each key, then the set of key keys,
-	 * the crypto element, and then decrement our
-	 * hold on the last resort crypto.
-	 */
-	if (tp->md5sig_info->entries4) {
-		int i;
-		for (i = 0; i < tp->md5sig_info->entries4; i++)
-			kfree(tp->md5sig_info->keys4[i].base.key);
-		tp->md5sig_info->entries4 = 0;
-		tcp_free_md5sig_pool();
-	}
-	if (tp->md5sig_info->keys4) {
-		kfree(tp->md5sig_info->keys4);
-		tp->md5sig_info->keys4 = NULL;
-		tp->md5sig_info->alloced4  = 0;
+	if (md5_info) {
+		rcu_assign_pointer(tp->md5sig_info4, NULL);
+		call_rcu(&md5_info->rcu_head, tcp_v4_md5_clear_info);
 	}
 }

@@ -995,7 +1096,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk,
char __user *optval,
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
-	u8 *newkey;
+	struct tcp_md5sig_key *newkey;

 	if (optlen < sizeof(cmd))
 		return -EINVAL;
@@ -1006,32 +1107,26 @@ static int tcp_v4_parse_md5_keys(struct sock
*sk, char __user *optval,
 	if (sin->sin_family != AF_INET)
 		return -EINVAL;

-	if (!cmd.tcpm_key || !cmd.tcpm_keylen) {
-		if (!tcp_sk(sk)->md5sig_info)
-			return -ENOENT;
+	if (!cmd.tcpm_keylen)
 		return tcp_v4_md5_do_del(sk, sin->sin_addr.s_addr);
-	}

 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
 		return -EINVAL;

-	if (!tcp_sk(sk)->md5sig_info) {
-		struct tcp_sock *tp = tcp_sk(sk);
-		struct tcp_md5sig_info *p;
-
-		p = kzalloc(sizeof(*p), sk->sk_allocation);
-		if (!p)
-			return -EINVAL;
+	newkey = kmalloc(sizeof(*newkey) + cmd.tcpm_keylen, sk->sk_allocation);
+	if (!newkey)
+		return -ENOMEM;

-		tp->md5sig_info = p;
-		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
+	if (tcp_alloc_md5sig_pool(sk) == NULL) {
+		kfree(newkey);
+		return -ENOMEM;
 	}

-	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, sk->sk_allocation);
-	if (!newkey)
-		return -ENOMEM;
-	return tcp_v4_md5_do_add(sk, sin->sin_addr.s_addr,
-				 newkey, cmd.tcpm_keylen);
+	kref_init(&newkey->kref);
+	newkey->keylen = cmd.tcpm_keylen;
+	memcpy(newkey->key, cmd.tcpm_key, cmd.tcpm_keylen);
+
+	return tcp_v4_md5_do_add(sk, sin->sin_addr.s_addr, newkey);
 }

 static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
@@ -1157,7 +1252,7 @@ static int tcp_v4_inbound_md5_hash(struct sock
*sk, struct sk_buff *skb)
 	int genhash;
 	unsigned char newhash[16];

-	hash_expected = tcp_v4_md5_do_lookup(sk, iph->saddr);
+	hash_expected = tcp_v4_md5_do_get(sk, iph->saddr);
 	hash_location = tcp_parse_md5sig_option(th);

 	/* We've parsed the options - do we have a hash? */
@@ -1165,6 +1260,7 @@ static int tcp_v4_inbound_md5_hash(struct sock
*sk, struct sk_buff *skb)
 		return 0;

 	if (hash_expected && !hash_location) {
+		tcp_md5_put(hash_expected);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPMD5NOTFOUND);
 		return 1;
 	}
@@ -1181,6 +1277,8 @@ static int tcp_v4_inbound_md5_hash(struct sock
*sk, struct sk_buff *skb)
 				      hash_expected,
 				      NULL, NULL, skb);

+	tcp_md5_put(hash_expected);
+
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
 			printk(KERN_INFO "MD5 Hash failed for (%pI4, %d)->(%pI4, %d)%s\n",
@@ -1207,6 +1305,8 @@ struct request_sock_ops tcp_request_sock_ops
__read_mostly = {

 #ifdef CONFIG_TCP_MD5SIG
 static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
+	.md5_get	=	tcp_v4_reqsk_md5_get,
+	.md5_put	=	tcp_md5_put,
 	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
 	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
 };
@@ -1453,20 +1553,9 @@ struct sock *tcp_v4_syn_recv_sock(struct sock
*sk, struct sk_buff *skb,

 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
-	key = tcp_v4_md5_do_lookup(sk, newinet->inet_daddr);
-	if (key != NULL) {
-		/*
-		 * We're using one, so create a matching key
-		 * on the newsk structure. If we fail to get
-		 * memory, then we end up not copying the key
-		 * across. Shucks.
-		 */
-		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
-		if (newkey != NULL)
-			tcp_v4_md5_do_add(newsk, newinet->inet_daddr,
-					  newkey, key->keylen);
-		sk_nocaps_add(newsk, NETIF_F_GSO_MASK);
-	}
+	key = tcp_v4_md5_do_get(sk, newinet->inet_daddr);
+	if (key != NULL)
+		tcp_v4_md5_do_add(newsk, newinet->inet_daddr, key);
 #endif

 	__inet_hash_nolisten(newsk, NULL);
@@ -1547,16 +1636,6 @@ static __sum16 tcp_v4_checksum_init(struct sk_buff *skb)
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct sock *rsk;
-#ifdef CONFIG_TCP_MD5SIG
-	/*
-	 * We really want to reject the packet as early as possible
-	 * if:
-	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
-	 *  o There is an MD5 option and we're not expecting one
-	 */
-	if (tcp_v4_inbound_md5_hash(sk, skb))
-		goto discard;
-#endif

 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		sock_rps_save_rxhash(sk, skb->rxhash);
@@ -1680,6 +1759,17 @@ process:

 	skb->dev = NULL;

+#ifdef CONFIG_TCP_MD5SIG
+	/*
+	 * We really want to reject the packet as early as possible
+	 * if:
+	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
+	 *  o There is an MD5 option and we're not expecting one
+	 */
+	if (tcp_v4_inbound_md5_hash(sk, skb))
+		goto discard_and_relse;
+#endif
+
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {
@@ -1842,6 +1932,8 @@ EXPORT_SYMBOL(ipv4_specific);

 #ifdef CONFIG_TCP_MD5SIG
 static const struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
+	.md5_get		= tcp_v4_md5_get,
+	.md5_put		= tcp_md5_put,
 	.md5_lookup		= tcp_v4_md5_lookup,
 	.calc_md5_hash		= tcp_v4_md5_hash_skb,
 	.md5_add		= tcp_v4_md5_add_func,
@@ -1931,11 +2023,7 @@ void tcp_v4_destroy_sock(struct sock *sk)

 #ifdef CONFIG_TCP_MD5SIG
 	/* Clean up the MD5 key list, if any */
-	if (tp->md5sig_info) {
-		tcp_v4_clear_md5_list(sk);
-		kfree(tp->md5sig_info);
-		tp->md5sig_info = NULL;
-	}
+	tcp_v4_clear_md5_list(sk);
 #endif

 #ifdef CONFIG_NET_DMA
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f25b56c..599752c 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -306,22 +306,11 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 #ifdef CONFIG_TCP_MD5SIG
 		/*
 		 * The timewait bucket does not have the key DB from the
-		 * sock structure. We just make a quick copy of the
-		 * md5 key being used (if indeed we are using one)
+		 * sock structure. We just get the md5 key being used
+		 * (if indeed we are using one)
 		 * so the timewait ack generating code has the key.
 		 */
-		do {
-			struct tcp_md5sig_key *key;
-			memset(tcptw->tw_md5_key, 0, sizeof(tcptw->tw_md5_key));
-			tcptw->tw_md5_keylen = 0;
-			key = tp->af_specific->md5_lookup(sk, sk);
-			if (key != NULL) {
-				memcpy(&tcptw->tw_md5_key, key->key, key->keylen);
-				tcptw->tw_md5_keylen = key->keylen;
-				if (tcp_alloc_md5sig_pool(sk) == NULL)
-					BUG();
-			}
-		} while (0);
+		tcptw->tw_md5sig_key = tp->af_specific->md5_get(sk, sk);
 #endif

 		/* Linkage updates. */
@@ -358,8 +347,8 @@ void tcp_twsk_destructor(struct sock *sk)
 {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
-	if (twsk->tw_md5_keylen)
-		tcp_free_md5sig_pool();
+	if (twsk->tw_md5sig_key)
+		tcp_md5_put(twsk->tw_md5sig_key);
 #endif
 }
 EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
@@ -496,7 +485,10 @@ struct sock *tcp_create_openreq_child(struct sock
*sk, struct request_sock *req,
 			newtp->tcp_header_len = sizeof(struct tcphdr);
 		}
 #ifdef CONFIG_TCP_MD5SIG
-		newtp->md5sig_info = NULL;	/*XXX*/
+		newtp->md5sig_info4 = NULL;	/*XXX*/
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		newtp->md5sig_info6 = NULL;	/*XXX*/
+#endif
 		if (newtp->af_specific->md5_lookup(sk, newsk))
 			newtp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
 #endif
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index de3bd84..8954453 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -569,7 +569,7 @@ static unsigned tcp_syn_options(struct sock *sk,
struct sk_buff *skb,
 			 0;

 #ifdef CONFIG_TCP_MD5SIG
-	*md5 = tp->af_specific->md5_lookup(sk, sk);
+	*md5 = tp->af_specific->md5_get(sk, sk);
 	if (*md5) {
 		opts->options |= OPTION_MD5;
 		remaining -= TCPOLEN_MD5SIG_ALIGNED;
@@ -671,7 +671,7 @@ static unsigned tcp_synack_options(struct sock *sk,
 			 0;

 #ifdef CONFIG_TCP_MD5SIG
-	*md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
+	*md5 = tcp_rsk(req)->af_specific->md5_get(sk, req);
 	if (*md5) {
 		opts->options |= OPTION_MD5;
 		remaining -= TCPOLEN_MD5SIG_ALIGNED;
@@ -745,7 +745,7 @@ static unsigned tcp_established_options(struct
sock *sk, struct sk_buff *skb,
 	unsigned int eff_sacks;

 #ifdef CONFIG_TCP_MD5SIG
-	*md5 = tp->af_specific->md5_lookup(sk, sk);
+	*md5 = tp->af_specific->md5_get(sk, sk);
 	if (unlikely(*md5)) {
 		opts->options |= OPTION_MD5;
 		size += TCPOLEN_MD5SIG_ALIGNED;
@@ -876,6 +876,7 @@ static int tcp_transmit_skb(struct sock *sk,
struct sk_buff *skb, int clone_it,
 		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		tp->af_specific->calc_md5_hash(opts.hash_location,
 					       md5, sk, NULL, skb);
+		tp->af_specific->md5_put(md5);
 	}
 #endif

@@ -1258,6 +1259,10 @@ unsigned int tcp_current_mss(struct sock *sk)

 	header_len = tcp_established_options(sk, NULL, &opts, &md5) +
 		     sizeof(struct tcphdr);
+#ifdef CONFIG_TCP_MD5SIG
+	if (unlikely(md5))
+		tp->af_specific->md5_put(md5);
+#endif
 	/* The mss_cache is sized based on tp->tcp_header_len, which assumes
 	 * some common options. If this is an odd packet (because we have SACK
 	 * blocks etc) then our calculated header_len will be different, and
@@ -2515,6 +2520,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk,
struct dst_entry *dst,
 	if (md5) {
 		tcp_rsk(req)->af_specific->calc_md5_hash(opts.hash_location,
 					       md5, NULL, req, skb);
+		tcp_rsk(req)->af_specific->md5_put(md5);
 	}
 #endif

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index fe6d404..80d2d20 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -85,8 +85,8 @@ static const struct inet_connection_sock_af_ops ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
 #else
-static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
-						   struct in6_addr *addr)
+static struct tcp_md5sig_key *tcp_v6_md5_do_get(struct sock *sk,
+						struct in6_addr *addr)
 {
 	return NULL;
 }
@@ -542,24 +542,41 @@ static void tcp_v6_reqsk_destructor(struct
request_sock *req)
 }

 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+static struct tcp_md5sig_key *__tcp_v6_md5_do_lookup(struct sock *sk,
 						   struct in6_addr *addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp6_md5sig_info	*md5_info = rcu_dereference(tp->md5sig_info6);
 	int i;

 	BUG_ON(tp == NULL);

-	if (!tp->md5sig_info || !tp->md5sig_info->entries6)
+	if (!md5_info)
 		return NULL;

-	for (i = 0; i < tp->md5sig_info->entries6; i++) {
-		if (ipv6_addr_equal(&tp->md5sig_info->keys6[i].addr, addr))
-			return &tp->md5sig_info->keys6[i].base;
+	for (i = 0; i < md5_info->entries; i++) {
+		if (ipv6_addr_equal(&md5_info->keys[i].addr, addr))
+			return md5_info->keys[i].base;
 	}
 	return NULL;
 }

+static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+						   struct in6_addr *addr)
+{
+	struct tcp_md5sig_key *res;
+
+	/* Short path */
+	if (!tcp_sk(sk)->md5sig_info6)
+		return NULL;
+
+	rcu_read_lock();
+	res = __tcp_v6_md5_do_lookup(sk, addr);
+	rcu_read_unlock();
+
+	return res;
+}
+
 static struct tcp_md5sig_key *tcp_v6_md5_lookup(struct sock *sk,
 						struct sock *addr_sk)
 {
@@ -572,135 +589,194 @@ static struct tcp_md5sig_key
*tcp_v6_reqsk_md5_lookup(struct sock *sk,
 	return tcp_v6_md5_do_lookup(sk, &inet6_rsk(req)->rmt_addr);
 }

-static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *peer,
-			     char *newkey, u8 newkeylen)
+/* Find and lock the Key structure for an address. */
+static struct tcp_md5sig_key *
+		tcp_v6_md5_do_get(struct sock *sk, struct in6_addr *addr)
 {
-	/* Add key to the list */
-	struct tcp_md5sig_key *key;
+	struct tcp_md5sig_key *res;
+
+	/* Short path */
+	if (!tcp_sk(sk)->md5sig_info6)
+		return NULL;
+
+	rcu_read_lock();
+	res = __tcp_v6_md5_do_lookup(sk, addr);
+	if (res)
+		kref_get(&res->kref);
+	rcu_read_unlock();
+
+	return res;
+}
+
+struct tcp_md5sig_key *tcp_v6_md5_get(struct sock *sk,
+				      struct sock *addr_sk)
+{
+	return tcp_v6_md5_do_get(sk, &inet6_sk(addr_sk)->daddr);
+}
+
+static struct tcp_md5sig_key *tcp_v6_reqsk_md5_get(struct sock *sk,
+						   struct request_sock *req)
+{
+	return tcp_v6_md5_do_get(sk, &inet6_rsk(req)->rmt_addr);
+}
+
+static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *addr,
+			     struct tcp_md5sig_key *key)
+{
+	/* Add Key to the list */
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp6_md5sig_key *keys;
+	struct tcp6_md5sig_info *old_info = NULL;
+	struct tcp6_md5sig_info *new_info;
+	int place = 0;
+	u32 entries;
+
+	if (tp->md5sig_info6) {
+		old_info = tp->md5sig_info6;
+		/* Check if we have to replace old key */
+		for (; place < old_info->entries; place++) {
+			if (ipv6_addr_equal(&old_info->keys[place].addr,
+									addr))
+				break;
+		}
+	} else {
+		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
+	}

-	key = tcp_v6_md5_do_lookup(sk, peer);
-	if (key) {
-		/* modify existing entry - just update that one */
-		kfree(key->key);
-		key->key = newkey;
-		key->keylen = newkeylen;
+	/* Number of entries in new_info */
+	if (old_info) {
+		entries = old_info->entries;
+		if (place == old_info->entries)
+			++entries;
 	} else {
-		/* reallocate new list if current one is full. */
-		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
-			if (!tp->md5sig_info) {
-				kfree(newkey);
-				return -ENOMEM;
-			}
-			sk_nocaps_add(sk, NETIF_F_GSO_MASK);
-		}
-		if (tcp_alloc_md5sig_pool(sk) == NULL) {
-			kfree(newkey);
-			return -ENOMEM;
-		}
-		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
-			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
-				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
-
-			if (!keys) {
-				tcp_free_md5sig_pool();
-				kfree(newkey);
-				return -ENOMEM;
-			}
+		entries = 1;
+	}

-			if (tp->md5sig_info->entries6)
-				memmove(keys, tp->md5sig_info->keys6,
-					(sizeof (tp->md5sig_info->keys6[0]) *
-					 tp->md5sig_info->entries6));
+	new_info = kmalloc(sizeof(*new_info) +
+				sizeof(new_info->keys[0]) * entries,
+			   GFP_ATOMIC);

-			kfree(tp->md5sig_info->keys6);
-			tp->md5sig_info->keys6 = keys;
-			tp->md5sig_info->alloced6++;
-		}
+	if (!new_info) {
+		tcp_md5_put(key);
+		return -ENOMEM;
+	}
+
+	new_info->entries = entries;

-		ipv6_addr_copy(&tp->md5sig_info->keys6[tp->md5sig_info->entries6].addr,
-			       peer);
-		tp->md5sig_info->keys6[tp->md5sig_info->entries6].base.key = newkey;
-		tp->md5sig_info->keys6[tp->md5sig_info->entries6].base.keylen = newkeylen;
+	if (old_info)
+		memcpy(new_info->keys, old_info->keys,
+			old_info->entries * sizeof(old_info->keys[0]));

-		tp->md5sig_info->entries6++;
+	if (!old_info || place == old_info->entries)
+		ipv6_addr_copy(&new_info->keys[place].addr, addr);
+
+	new_info->keys[place].base = key;
+	rcu_assign_pointer(tp->md5sig_info6, new_info);
+
+	/* This function may be called from setsockopt (synchronize_rcu is ok)
+	 * or on a newly created socket (old_info == NULL)
+	 */
+	if (old_info) {
+		synchronize_rcu();
+		if (place != old_info->entries) /* Put old key */
+			tcp_md5_put(old_info->keys[place].base);
+		kfree(old_info);
 	}
+
 	return 0;
 }

 static int tcp_v6_md5_add_func(struct sock *sk, struct sock *addr_sk,
-			       u8 *newkey, __u8 newkeylen)
+			     struct tcp_md5sig_key *key)
 {
-	return tcp_v6_md5_do_add(sk, &inet6_sk(addr_sk)->daddr,
-				 newkey, newkeylen);
+	return tcp_v6_md5_do_add(sk, &inet6_sk(addr_sk)->daddr, key);
+}
+
+static int
+	tcp_v6_md5_do_del_ith(struct tcp6_md5sig_info **new_info,
+			      struct tcp6_md5sig_info *old_info,
+			      int i)
+{
+	struct tcp6_md5sig_info *res_info = NULL;
+
+	if (old_info->entries > 1) {
+		res_info = kmalloc(sizeof(*res_info) +
+					sizeof(res_info->keys[0]) *
+					(old_info->entries - 1),
+					GFP_ATOMIC);
+		if (!res_info)
+			return -ENOMEM;
+		res_info->entries = old_info->entries - 1;
+
+		memcpy(res_info->keys,
+			old_info->keys,
+			i * sizeof(res_info->keys[0]));
+		memcpy(&res_info->keys[i],
+			&old_info->keys[i + 1],
+			(res_info->entries - i) * sizeof(res_info->keys[0]));
+	}
+
+	*new_info = res_info;
+	return 0;
 }

 static int tcp_v6_md5_do_del(struct sock *sk, struct in6_addr *peer)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp6_md5sig_info *old_info = tp->md5sig_info6;
 	int i;

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
-			} else {
-				/* shrink the database */
-				if (tp->md5sig_info->entries6 != i)
-					memmove(&tp->md5sig_info->keys6[i],
-						&tp->md5sig_info->keys6[i+1],
-						(tp->md5sig_info->entries6 - i)
-						* sizeof (tp->md5sig_info->keys6[0]));
-			}
-			tcp_free_md5sig_pool();
+	if (!old_info)
+		return -ENOENT;
+
+	for (i = 0; i < old_info->entries; i++) {
+		if (ipv6_addr_equal(&old_info->keys[i].addr, peer)) {
+			struct tcp6_md5sig_info *new_info;
+			int res;
+
+			res = tcp_v6_md5_do_del_ith(&new_info, old_info, i);
+			if (res)
+				return res;
+
+			rcu_assign_pointer(tp->md5sig_info6, new_info);
+			synchronize_rcu();
+			tcp_md5_put(old_info->keys[i].base);
+			kfree(old_info);
 			return 0;
 		}
 	}
 	return -ENOENT;
 }

-static void tcp_v6_clear_md5_list (struct sock *sk)
+static void tcp_v6_md5_clear_info(struct rcu_head *head)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp6_md5sig_info *md5_info =
+		container_of(head, struct tcp6_md5sig_info, rcu_head);
 	int i;

-	if (tp->md5sig_info->entries6) {
-		for (i = 0; i < tp->md5sig_info->entries6; i++)
-			kfree(tp->md5sig_info->keys6[i].base.key);
-		tp->md5sig_info->entries6 = 0;
-		tcp_free_md5sig_pool();
-	}
+	/* Free each key, then the set of keys
+	 */
+	for (i = 0; i < md5_info->entries; i++)
+		tcp_md5_put(md5_info->keys[i].base);
+	kfree(md5_info);
+}

-	kfree(tp->md5sig_info->keys6);
-	tp->md5sig_info->keys6 = NULL;
-	tp->md5sig_info->alloced6 = 0;
+static void tcp_v6_clear_md5_list(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp6_md5sig_info *md5_info = tp->md5sig_info6;

-	if (tp->md5sig_info->entries4) {
-		for (i = 0; i < tp->md5sig_info->entries4; i++)
-			kfree(tp->md5sig_info->keys4[i].base.key);
-		tp->md5sig_info->entries4 = 0;
-		tcp_free_md5sig_pool();
+	if (md5_info) {
+		rcu_assign_pointer(tp->md5sig_info6, NULL);
+		call_rcu(&md5_info->rcu_head, tcp_v6_md5_clear_info);
 	}
-
-	kfree(tp->md5sig_info->keys4);
-	tp->md5sig_info->keys4 = NULL;
-	tp->md5sig_info->alloced4 = 0;
 }

-static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
-				  int optlen)
+static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
+				 int optlen)
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
-	u8 *newkey;
+	struct tcp_md5sig_key *newkey;

 	if (optlen < sizeof(cmd))
 		return -EINVAL;
@@ -712,8 +788,6 @@ static int tcp_v6_parse_md5_keys (struct sock *sk,
char __user *optval,
 		return -EINVAL;

 	if (!cmd.tcpm_keylen) {
-		if (!tcp_sk(sk)->md5sig_info)
-			return -ENOENT;
 		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
 			return tcp_v4_md5_do_del(sk, sin6->sin6_addr.s6_addr32[3]);
 		return tcp_v6_md5_do_del(sk, &sin6->sin6_addr);
@@ -722,26 +796,24 @@ static int tcp_v6_parse_md5_keys (struct sock
*sk, char __user *optval,
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
 		return -EINVAL;

-	if (!tcp_sk(sk)->md5sig_info) {
-		struct tcp_sock *tp = tcp_sk(sk);
-		struct tcp_md5sig_info *p;
-
-		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
-		if (!p)
-			return -ENOMEM;
+	newkey = kmalloc(sizeof(*newkey) + cmd.tcpm_keylen, GFP_KERNEL);
+	if (!newkey)
+		return -ENOMEM;

-		tp->md5sig_info = p;
-		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
+	if (tcp_alloc_md5sig_pool(sk) == NULL) {
+		kfree(newkey);
+		return -ENOMEM;
 	}

-	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
-	if (!newkey)
-		return -ENOMEM;
-	if (ipv6_addr_v4mapped(&sin6->sin6_addr)) {
+	kref_init(&newkey->kref);
+	newkey->keylen = cmd.tcpm_keylen;
+	memcpy(newkey->key, cmd.tcpm_key, cmd.tcpm_keylen);
+
+	if (ipv6_addr_v4mapped(&sin6->sin6_addr))
 		return tcp_v4_md5_do_add(sk, sin6->sin6_addr.s6_addr32[3],
-					 newkey, cmd.tcpm_keylen);
-	}
-	return tcp_v6_md5_do_add(sk, &sin6->sin6_addr, newkey, cmd.tcpm_keylen);
+						newkey);
+
+	return tcp_v6_md5_do_add(sk, &sin6->sin6_addr, newkey);
 }

 static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
@@ -854,7 +926,7 @@ static int tcp_v6_inbound_md5_hash (struct sock
*sk, struct sk_buff *skb)
 	int genhash;
 	u8 newhash[16];

-	hash_expected = tcp_v6_md5_do_lookup(sk, &ip6h->saddr);
+	hash_expected = tcp_v6_md5_do_get(sk, &ip6h->saddr);
 	hash_location = tcp_parse_md5sig_option(th);

 	/* We've parsed the options - do we have a hash? */
@@ -862,6 +934,7 @@ static int tcp_v6_inbound_md5_hash (struct sock
*sk, struct sk_buff *skb)
 		return 0;

 	if (hash_expected && !hash_location) {
+		tcp_md5_put(hash_expected);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPMD5NOTFOUND);
 		return 1;
 	}
@@ -876,6 +949,8 @@ static int tcp_v6_inbound_md5_hash (struct sock
*sk, struct sk_buff *skb)
 				      hash_expected,
 				      NULL, NULL, skb);

+	tcp_md5_put(hash_expected);
+
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
 			printk(KERN_INFO "MD5 Hash %s for [%pI6c]:%u->[%pI6c]:%u\n",
@@ -901,6 +976,8 @@ struct request_sock_ops tcp6_request_sock_ops
__read_mostly = {

 #ifdef CONFIG_TCP_MD5SIG
 static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
+	.md5_get	=	tcp_v6_reqsk_md5_get,
+	.md5_put	=	tcp_md5_put,
 	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
 	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
 };
@@ -1092,7 +1169,7 @@ static void tcp_v6_send_reset(struct sock *sk,
struct sk_buff *skb)

 #ifdef CONFIG_TCP_MD5SIG
 	if (sk)
-		key = tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr);
+		key = tcp_v6_md5_do_get(sk, &ipv6_hdr(skb)->daddr);
 #endif

 	if (th->ack)
@@ -1102,6 +1179,9 @@ static void tcp_v6_send_reset(struct sock *sk,
struct sk_buff *skb)
 			  (th->doff << 2);

 	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, key, 1);
+
+	if (key)
+		tcp_md5_put(key);
 }

 static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
u32 win, u32 ts,
@@ -1125,8 +1205,15 @@ static void tcp_v6_timewait_ack(struct sock
*sk, struct sk_buff *skb)
 static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
-	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1,
tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent,
-			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr));
+	struct tcp_md5sig_key *key = tcp_v6_md5_do_get(sk,
+							&ipv6_hdr(skb)->daddr);
+
+	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1,
+			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
+			req->ts_recent, key);
+
+	if (key)
+		tcp_md5_put(key);
 }


@@ -1484,17 +1571,9 @@ static struct sock *
tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,

 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
-	if ((key = tcp_v6_md5_do_lookup(sk, &newnp->daddr)) != NULL) {
-		/* We're using one, so create a matching key
-		 * on the newsk structure. If we fail to get
-		 * memory, then we end up not copying the key
-		 * across. Shucks.
-		 */
-		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
-		if (newkey != NULL)
-			tcp_v6_md5_do_add(newsk, &newnp->daddr,
-					  newkey, key->keylen);
-	}
+	key = tcp_v6_md5_do_get(sk, &newnp->daddr);
+	if (key != NULL)
+		tcp_v6_md5_do_add(newsk, &newnp->daddr, key);
 #endif

 	__inet6_hash(newsk, NULL);
@@ -1557,11 +1636,6 @@ static int tcp_v6_do_rcv(struct sock *sk,
struct sk_buff *skb)
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);

-#ifdef CONFIG_TCP_MD5SIG
-	if (tcp_v6_inbound_md5_hash (sk, skb))
-		goto discard;
-#endif
-
 	if (sk_filter(sk, skb))
 		goto discard;

@@ -1726,6 +1800,11 @@ process:

 	skb->dev = NULL;

+#ifdef CONFIG_TCP_MD5SIG
+	if (tcp_v6_inbound_md5_hash(sk, skb))
+		goto discard_and_relse;
+#endif
+
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {
@@ -1841,6 +1920,8 @@ static const struct inet_connection_sock_af_ops
ipv6_specific = {

 #ifdef CONFIG_TCP_MD5SIG
 static const struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
+	.md5_get	=	tcp_v6_md5_get,
+	.md5_put	=	tcp_md5_put,
 	.md5_lookup	=	tcp_v6_md5_lookup,
 	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
 	.md5_add	=	tcp_v6_md5_add_func,
@@ -1873,6 +1954,8 @@ static const struct inet_connection_sock_af_ops
ipv6_mapped = {

 #ifdef CONFIG_TCP_MD5SIG
 static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific = {
+	.md5_get	=	tcp_v4_md5_get,
+	.md5_put	=	tcp_md5_put,
 	.md5_lookup	=	tcp_v4_md5_lookup,
 	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
 	.md5_add	=	tcp_v6_md5_add_func,
@@ -1950,8 +2033,7 @@ static void tcp_v6_destroy_sock(struct sock *sk)
 {
 #ifdef CONFIG_TCP_MD5SIG
 	/* Clean up the MD5 key list */
-	if (tcp_sk(sk)->md5sig_info)
-		tcp_v6_clear_md5_list(sk);
+	tcp_v6_clear_md5_list(sk);
 #endif
 	tcp_v4_destroy_sock(sk);
 	inet6_destroy_sock(sk);
