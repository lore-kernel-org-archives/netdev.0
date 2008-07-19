From: "Adam Langley" <agl@imperialviolet.org>
Subject: [RFC 1/2] TCP: Renaming md5sig to auth
Date: Fri, 18 Jul 2008 17:22:10 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069031@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:7596 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbYGSAVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 20:21:07 -0400
Received: by wf-out-1314.google.com with SMTP id 27so450723wfd.4
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 17:21:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---

 include/linux/tcp.h      |    8 +
 include/net/tcp.h        |  116 +++++++++---------
 net/ipv4/tcp.c           |  112 +++++++++---------
 net/ipv4/tcp_input.c     |    4 -
 net/ipv4/tcp_ipv4.c      |  283 ++++++++++++++++++++++----------------------
 net/ipv4/tcp_minisocks.c |   36 +++---
 net/ipv4/tcp_output.c    |   72 ++++++-----
 net/ipv6/tcp_ipv6.c      |  294 +++++++++++++++++++++++-----------------------
 8 files changed, 461 insertions(+), 464 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 2e25573..65542c6 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -162,7 +162,7 @@ struct tcp_info
 /* for TCP_MD5SIG socket option */
 #define TCP_MD5SIG_MAXKEYLEN	80
 
-struct tcp_md5sig {
+struct tcp_auth {
 	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
 	__u16	__tcpm_pad1;				/* zero */
 	__u16	tcpm_keylen;				/* key length */
@@ -407,7 +407,7 @@ struct tcp_sock {
 	struct tcp_sock_af_ops	*af_specific;
 
 /* TCP MD5 Signagure Option information */
-	struct tcp_md5sig_info	*md5sig_info;
+	struct tcp_auth_info	*auth_info;
 #endif
 
 	int			linger2;
@@ -426,8 +426,8 @@ struct tcp_timewait_sock {
 	u32			  tw_ts_recent;
 	long			  tw_ts_recent_stamp;
 #ifdef CONFIG_TCP_MD5SIG
-	u16			  tw_md5_keylen;
-	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
+	u16			  tw_auth_keylen;
+	u8			  tw_auth_key[TCP_MD5SIG_MAXKEYLEN];
 #endif
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8983386..9903916 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -397,7 +397,7 @@ extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
 						  int estab);
 
-extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
+extern u8			*tcp_auth_parse_option(struct tcphdr *th);
 
 /*
  *	TCP v4 functions exported for the inet6 API
@@ -1052,18 +1052,18 @@ static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
 struct crypto_hash;
 
 /* - key database */
-struct tcp_md5sig_key {
+struct tcp_auth_key {
 	u8			*key;
 	u8			keylen;
 };
 
-struct tcp4_md5sig_key {
-	struct tcp_md5sig_key	base;
+struct tcp4_auth_key {
+	struct tcp_auth_key	base;
 	__be32			addr;
 };
 
-struct tcp6_md5sig_key {
-	struct tcp_md5sig_key	base;
+struct tcp6_auth_key {
+	struct tcp_auth_key	base;
 #if 0
 	u32			scope_id;	/* XXX */
 #endif
@@ -1071,10 +1071,10 @@ struct tcp6_md5sig_key {
 };
 
 /* - sock block */
-struct tcp_md5sig_info {
-	struct tcp4_md5sig_key	*keys4;
+struct tcp_auth_info {
+	struct tcp4_auth_key	*keys4;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct tcp6_md5sig_key	*keys6;
+	struct tcp6_auth_key	*keys6;
 	u32			entries6;
 	u32			alloced6;
 #endif
@@ -1098,7 +1098,7 @@ struct tcp6_pseudohdr {
 	__be32		protocol;	/* including padding */
 };
 
-union tcp_md5sum_block {
+union tcp_auth_block {
 	struct tcp4_pseudohdr ip4;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct tcp6_pseudohdr ip6;
@@ -1106,65 +1106,63 @@ union tcp_md5sum_block {
 };
 
 /* - pool: digest algorithm, hash description and scratch buffer */
-struct tcp_md5sig_pool {
+struct tcp_auth_pool {
 	struct hash_desc	md5_desc;
-	union tcp_md5sum_block	md5_blk;
+	union tcp_auth_block	md5_blk;
 };
 
 #define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
 
 /* - functions */
-extern int			tcp_v4_md5_hash_skb(char *md5_hash,
-						    struct tcp_md5sig_key *key,
-						    struct sock *sk,
-						    struct request_sock *req,
-						    struct sk_buff *skb);
+extern int			tcp_v4_auth_hash_skb(char *md5_hash,
+						     struct tcp_md5sig_key *key,
+						     struct sock *sk,
+						     struct request_sock *req,
+						     struct sk_buff *skb);
 
-extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
-						   struct sock *addr_sk);
+extern struct tcp_md5sig_key	*tcp_v4_auth_lookup(struct sock *sk,
+						    struct sock *addr_sk);
 
-extern int			tcp_v4_md5_do_add(struct sock *sk,
-						  __be32 addr,
-						  u8 *newkey,
-						  u8 newkeylen);
+extern int			tcp_v4_auth_do_add(struct sock *sk,
+						   __be32 addr,
+						   u8 *newkey,
+						   u8 newkeylen);
 
-extern int			tcp_v4_md5_do_del(struct sock *sk,
-						  __be32 addr);
+extern int			tcp_v4_auth_do_del(struct sock *sk,
+						   __be32 addr);
 
 #ifdef CONFIG_TCP_MD5SIG
-#define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_keylen ? 		 \
-				 &(struct tcp_md5sig_key) {		 \
-					.key = (twsk)->tw_md5_key,	 \
-					.keylen = (twsk)->tw_md5_keylen, \
+#define tcp_twsk_auth_key(twsk)	((twsk)->tw_auth_keylen ? 		 \
+				 &(struct tcp_auth_key) {		 \
+					.key = (twsk)->tw_auth_key,	 \
+					.keylen = (twsk)->tw_auth_keylen, \
 				} : NULL)
 #else
-#define tcp_twsk_md5_key(twsk)	NULL
+#define tcp_twsk_auth_key(twsk)	NULL
 #endif
 
-extern struct tcp_md5sig_pool	**tcp_alloc_md5sig_pool(void);
-extern void			tcp_free_md5sig_pool(void);
+extern struct tcp_auth_pool	**tcp_auth_alloc_pool(void);
+extern void			tcp_auth_free_pool(void);
 
-extern struct tcp_md5sig_pool	*__tcp_get_md5sig_pool(int cpu);
-extern void			__tcp_put_md5sig_pool(void);
-extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, struct tcphdr *);
-extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, struct sk_buff *,
-				 unsigned header_len);
-extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
-			    struct tcp_md5sig_key *key);
+extern struct tcp_auth_pool	*__tcp_auth_get_pool(int cpu);
+extern void			__tcp_auth_put_pool(void);
+extern int tcp_auth_hash_header(struct tcp_auth_pool *, struct tcphdr *);
+extern int tcp_auth_hash_skb_data(struct tcp_auth_pool *, struct sk_buff *,
+				  unsigned header_len);
 
 static inline
-struct tcp_md5sig_pool		*tcp_get_md5sig_pool(void)
+struct tcp_auth_pool		*tcp_auth_get_pool(void)
 {
 	int cpu = get_cpu();
-	struct tcp_md5sig_pool *ret = __tcp_get_md5sig_pool(cpu);
+	struct tcp_auth_pool *ret = __tcp_auth_get_pool(cpu);
 	if (!ret)
 		put_cpu();
 	return ret;
 }
 
-static inline void		tcp_put_md5sig_pool(void)
+static inline void		tcp_auth_put_pool(void)
 {
-	__tcp_put_md5sig_pool();
+	__tcp_auth_put_pool();
 	put_cpu();
 }
 
@@ -1375,27 +1373,27 @@ extern void tcp4_proc_exit(void);
 /* TCP af-specific functions */
 struct tcp_sock_af_ops {
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
-						struct sock *addr_sk);
-	int			(*calc_md5_hash) (char *location,
-						  struct tcp_md5sig_key *md5,
-						  struct sock *sk,
-						  struct request_sock *req,
-						  struct sk_buff *skb);
-	int			(*md5_add) (struct sock *sk,
-					    struct sock *addr_sk,
-					    u8 *newkey,
-					    u8 len);
-	int			(*md5_parse) (struct sock *sk,
-					      char __user *optval,
-					      int optlen);
+	struct tcp_auth_key	*(*auth_lookup) (struct sock *sk,
+						 struct sock *addr_sk);
+	int			(*auth_calc_hash) (char *location,
+						   struct tcp_auth_key *auth,
+						   struct sock *sk,
+						   struct request_sock *req,
+						   struct sk_buff *skb);
+	int			(*auth_add) (struct sock *sk,
+					     struct sock *addr_sk,
+					     u8 *newkey,
+					     u8 len);
+	int			(*auth_parse) (struct sock *sk,
+					       char __user *optval,
+					       int optlen);
 #endif
 };
 
 struct tcp_request_sock_ops {
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
-						struct request_sock *req);
+	struct tcp_auth_key	*(*auth_lookup) (struct sock *sk,
+						 struct request_sock *req);
 #endif
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0b491bf..021bb72 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2157,7 +2157,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 #ifdef CONFIG_TCP_MD5SIG
 	case TCP_MD5SIG:
 		/* Read the IP->Key mappings from userspace */
-		err = tp->af_specific->md5_parse(sk, optval, optlen);
+		err = tp->af_specific->auth_parse(sk, optval, optlen);
 		break;
 #endif
 
@@ -2461,15 +2461,15 @@ out:
 EXPORT_SYMBOL(tcp_tso_segment);
 
 #ifdef CONFIG_TCP_MD5SIG
-static unsigned long tcp_md5sig_users;
-static struct tcp_md5sig_pool **tcp_md5sig_pool;
-static DEFINE_SPINLOCK(tcp_md5sig_pool_lock);
+static unsigned long tcp_auth_users;
+static struct tcp_auth_pool **tcp_auth_pool;
+static DEFINE_SPINLOCK(tcp_auth_pool_lock);
 
-static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool **pool)
+static void __tcp_auth_free_pool(struct tcp_auth_pool **pool)
 {
 	int cpu;
 	for_each_possible_cpu(cpu) {
-		struct tcp_md5sig_pool *p = *per_cpu_ptr(pool, cpu);
+		struct tcp_auth_pool *p = *per_cpu_ptr(pool, cpu);
 		if (p) {
 			if (p->md5_desc.tfm)
 				crypto_free_hash(p->md5_desc.tfm);
@@ -2480,33 +2480,33 @@ static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool **pool)
 	free_percpu(pool);
 }
 
-void tcp_free_md5sig_pool(void)
+void tcp_auth_free_pool(void)
 {
-	struct tcp_md5sig_pool **pool = NULL;
+	struct tcp_auth_pool **pool = NULL;
 
-	spin_lock_bh(&tcp_md5sig_pool_lock);
-	if (--tcp_md5sig_users == 0) {
-		pool = tcp_md5sig_pool;
-		tcp_md5sig_pool = NULL;
+	spin_lock_bh(&tcp_auth_pool_lock);
+	if (--tcp_auth_users == 0) {
+		pool = tcp_auth_pool;
+		tcp_auth_pool = NULL;
 	}
-	spin_unlock_bh(&tcp_md5sig_pool_lock);
+	spin_unlock_bh(&tcp_auth_pool_lock);
 	if (pool)
-		__tcp_free_md5sig_pool(pool);
+		__tcp_auth_free_pool(pool);
 }
 
-EXPORT_SYMBOL(tcp_free_md5sig_pool);
+EXPORT_SYMBOL(tcp_auth_free_pool);
 
-static struct tcp_md5sig_pool **__tcp_alloc_md5sig_pool(void)
+static struct tcp_auth_pool **__tcp_auth_alloc_pool(void)
 {
 	int cpu;
-	struct tcp_md5sig_pool **pool;
+	struct tcp_auth_pool **pool;
 
-	pool = alloc_percpu(struct tcp_md5sig_pool *);
+	pool = alloc_percpu(struct tcp_auth_pool *);
 	if (!pool)
 		return NULL;
 
 	for_each_possible_cpu(cpu) {
-		struct tcp_md5sig_pool *p;
+		struct tcp_auth_pool *p;
 		struct crypto_hash *hash;
 
 		p = kzalloc(sizeof(*p), GFP_KERNEL);
@@ -2522,75 +2522,75 @@ static struct tcp_md5sig_pool **__tcp_alloc_md5sig_pool(void)
 	}
 	return pool;
 out_free:
-	__tcp_free_md5sig_pool(pool);
+	__tcp_auth_free_pool(pool);
 	return NULL;
 }
 
-struct tcp_md5sig_pool **tcp_alloc_md5sig_pool(void)
+struct tcp_auth_pool **tcp_auth_alloc_pool(void)
 {
-	struct tcp_md5sig_pool **pool;
+	struct tcp_auth_pool **pool;
 	int alloc = 0;
 
 retry:
-	spin_lock_bh(&tcp_md5sig_pool_lock);
-	pool = tcp_md5sig_pool;
-	if (tcp_md5sig_users++ == 0) {
+	spin_lock_bh(&tcp_auth_pool_lock);
+	pool = tcp_auth_pool;
+	if (tcp_auth_users++ == 0) {
 		alloc = 1;
-		spin_unlock_bh(&tcp_md5sig_pool_lock);
+		spin_unlock_bh(&tcp_auth_pool_lock);
 	} else if (!pool) {
-		tcp_md5sig_users--;
-		spin_unlock_bh(&tcp_md5sig_pool_lock);
+		tcp_auth_users--;
+		spin_unlock_bh(&tcp_auth_pool_lock);
 		cpu_relax();
 		goto retry;
 	} else
-		spin_unlock_bh(&tcp_md5sig_pool_lock);
+		spin_unlock_bh(&tcp_auth_pool_lock);
 
 	if (alloc) {
 		/* we cannot hold spinlock here because this may sleep. */
-		struct tcp_md5sig_pool **p = __tcp_alloc_md5sig_pool();
-		spin_lock_bh(&tcp_md5sig_pool_lock);
+		struct tcp_auth_pool **p = __tcp_auth_alloc_pool();
+		spin_lock_bh(&tcp_auth_pool_lock);
 		if (!p) {
-			tcp_md5sig_users--;
-			spin_unlock_bh(&tcp_md5sig_pool_lock);
+			tcp_auth_users--;
+			spin_unlock_bh(&tcp_auth_pool_lock);
 			return NULL;
 		}
-		pool = tcp_md5sig_pool;
+		pool = tcp_auth_pool;
 		if (pool) {
 			/* oops, it has already been assigned. */
-			spin_unlock_bh(&tcp_md5sig_pool_lock);
-			__tcp_free_md5sig_pool(p);
+			spin_unlock_bh(&tcp_auth_pool_lock);
+			__tcp_auth_free_pool(p);
 		} else {
-			tcp_md5sig_pool = pool = p;
-			spin_unlock_bh(&tcp_md5sig_pool_lock);
+			tcp_auth_pool = pool = p;
+			spin_unlock_bh(&tcp_auth_pool_lock);
 		}
 	}
 	return pool;
 }
 
-EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
+EXPORT_SYMBOL(tcp_auth_alloc_pool);
 
-struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
+struct tcp_auth_pool *__tcp_auth_get_pool(int cpu)
 {
-	struct tcp_md5sig_pool **p;
-	spin_lock_bh(&tcp_md5sig_pool_lock);
-	p = tcp_md5sig_pool;
+	struct tcp_auth_pool **p;
+	spin_lock_bh(&tcp_auth_pool_lock);
+	p = tcp_auth_pool;
 	if (p)
-		tcp_md5sig_users++;
-	spin_unlock_bh(&tcp_md5sig_pool_lock);
+		tcp_auth_users++;
+	spin_unlock_bh(&tcp_auth_pool_lock);
 	return (p ? *per_cpu_ptr(p, cpu) : NULL);
 }
 
-EXPORT_SYMBOL(__tcp_get_md5sig_pool);
+EXPORT_SYMBOL(__tcp_auth_get_pool);
 
-void __tcp_put_md5sig_pool(void)
+void __tcp_auth_put_pool(void)
 {
-	tcp_free_md5sig_pool();
+	tcp_auth_free_pool();
 }
 
-EXPORT_SYMBOL(__tcp_put_md5sig_pool);
+EXPORT_SYMBOL(__tcp_auth_put_pool);
 
-int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
-			struct tcphdr *th)
+int tcp_auth_hash_header(struct tcp_auth_pool *hp,
+			 struct tcphdr *th)
 {
 	struct scatterlist sg;
 	int err;
@@ -2604,10 +2604,10 @@ int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
 	return err;
 }
 
-EXPORT_SYMBOL(tcp_md5_hash_header);
+EXPORT_SYMBOL(tcp_auth_hash_header);
 
-int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
-			  struct sk_buff *skb, unsigned header_len)
+int tcp_auth_hash_skb_data(struct tcp_auth_pool *hp,
+			   struct sk_buff *skb, unsigned header_len)
 {
 	struct scatterlist sg;
 	const struct tcphdr *tp = tcp_hdr(skb);
@@ -2633,9 +2633,9 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 	return 0;
 }
 
-EXPORT_SYMBOL(tcp_md5_hash_skb_data);
+EXPORT_SYMBOL(tcp_auth_hash_skb_data);
 
-int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, struct tcp_md5sig_key *key)
+int tcp_auth_hash_key(struct tcp_auth_pool *hp, struct tcp_auth_key *key)
 {
 	struct scatterlist sg;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fa91c13..f89c4c5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3468,7 +3468,7 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 /*
  * Parse MD5 Signature option
  */
-u8 *tcp_parse_md5sig_option(struct tcphdr *th)
+u8 *tcp_auth_parse_option(struct tcphdr *th)
 {
 	int length = (th->doff << 2) - sizeof (*th);
 	u8 *ptr = (u8*)(th + 1);
@@ -5477,7 +5477,7 @@ EXPORT_SYMBOL(sysctl_tcp_reordering);
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 EXPORT_SYMBOL(tcp_parse_options);
 #ifdef CONFIG_TCP_MD5SIG
-EXPORT_SYMBOL(tcp_parse_md5sig_option);
+EXPORT_SYMBOL(tcp_auth_parse_option);
 #endif
 EXPORT_SYMBOL(tcp_rcv_established);
 EXPORT_SYMBOL(tcp_rcv_state_process);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5400d75..8282634 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -85,13 +85,13 @@ int sysctl_tcp_low_latency __read_mostly;
 
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
-						   __be32 addr);
-static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
-			       __be32 daddr, __be32 saddr, struct tcphdr *th);
+static struct tcp_auth_key *tcp_v4_auth_do_lookup(struct sock *sk,
+						  __be32 addr);
+static int tcp_v4_auth_hash_hdr(char *hash, struct tcp_auth_key *key,
+			        __be32 daddr, __be32 saddr, struct tcphdr *th);
 #else
 static inline
-struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+struct tcp_auth_key *tcp_v4_auth_do_lookup(struct sock *sk, __be32 addr)
 {
 	return NULL;
 }
@@ -541,7 +541,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	} rep;
 	struct ip_reply_arg arg;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
+	struct tcp_auth_key *key;
 #endif
 	struct net *net;
 
@@ -572,7 +572,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	arg.iov[0].iov_len  = sizeof(rep.th);
 
 #ifdef CONFIG_TCP_MD5SIG
-	key = sk ? tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr) : NULL;
+	key = sk ? tcp_v4_auth_do_lookup(sk, ip_hdr(skb)->daddr) : NULL;
 	if (key) {
 		rep.opt[0] = htonl((TCPOPT_NOP << 24) |
 				   (TCPOPT_NOP << 16) |
@@ -582,7 +582,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
 		rep.th.doff = arg.iov[0].iov_len / 4;
 
-		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[1],
+		tcp_v4_auth_hash_hdr((__u8 *) &rep.opt[1],
 				     key, ip_hdr(skb)->daddr,
 				     ip_hdr(skb)->saddr, &rep.th);
 	}
@@ -606,7 +606,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 
 static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			    u32 win, u32 ts, int oif,
-			    struct tcp_md5sig_key *key)
+			    struct tcp_auth_key *key)
 {
 	struct tcphdr *th = tcp_hdr(skb);
 	struct {
@@ -654,9 +654,9 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
 		rep.th.doff = arg.iov[0].iov_len/4;
 
-		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[offset],
-				    key, ip_hdr(skb)->daddr,
-				    ip_hdr(skb)->saddr, &rep.th);
+		tcp_v4_auth_hash_hdr((__u8 *) &rep.opt[offset],
+				     key, ip_hdr(skb)->daddr,
+				     ip_hdr(skb)->saddr, &rep.th);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -681,7 +681,7 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcptw->tw_ts_recent,
 			tw->tw_bound_dev_if,
-			tcp_twsk_md5_key(tcptw)
+			tcp_twsk_auth_key(tcptw)
 			);
 
 	inet_twsk_put(tw);
@@ -694,7 +694,7 @@ static void tcp_v4_reqsk_send_ack(struct sk_buff *skb,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
 			req->ts_recent,
 			0,
-			tcp_v4_md5_do_lookup(skb->sk, ip_hdr(skb)->daddr));
+			tcp_v4_auth_do_lookup(skb->sk, ip_hdr(skb)->daddr));
 }
 
 /*
@@ -791,135 +791,134 @@ static struct ip_options *tcp_v4_save_options(struct sock *sk,
  */
 
 /* Find the Key structure for an address.  */
-static struct tcp_md5sig_key *
-			tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+static struct tcp_auth_key *tcp_v4_auth_do_lookup(struct sock *sk, __be32 addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int i;
 
-	if (!tp->md5sig_info || !tp->md5sig_info->entries4)
+	if (!tp->auth_info || !tp->auth_info->entries4)
 		return NULL;
-	for (i = 0; i < tp->md5sig_info->entries4; i++) {
-		if (tp->md5sig_info->keys4[i].addr == addr)
-			return &tp->md5sig_info->keys4[i].base;
+	for (i = 0; i < tp->auth_info->entries4; i++) {
+		if (tp->auth_info->keys4[i].addr == addr)
+			return &tp->auth_info->keys4[i].base;
 	}
 	return NULL;
 }
 
-struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
-					 struct sock *addr_sk)
+struct tcp_auth_key *tcp_v4_auth_lookup(struct sock *sk,
+					struct sock *addr_sk)
 {
-	return tcp_v4_md5_do_lookup(sk, inet_sk(addr_sk)->daddr);
+	return tcp_v4_auth_do_lookup(sk, inet_sk(addr_sk)->daddr);
 }
 
-EXPORT_SYMBOL(tcp_v4_md5_lookup);
+EXPORT_SYMBOL(tcp_v4_auth_lookup);
 
-static struct tcp_md5sig_key *tcp_v4_reqsk_md5_lookup(struct sock *sk,
-						      struct request_sock *req)
+static struct tcp_auth_key *tcp_v4_reqsk_auth_lookup(struct sock *sk,
+						     struct request_sock *req)
 {
-	return tcp_v4_md5_do_lookup(sk, inet_rsk(req)->rmt_addr);
+	return tcp_v4_auth_do_lookup(sk, inet_rsk(req)->rmt_addr);
 }
 
 /* This can be called on a newly created socket, from other files */
-int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
-		      u8 *newkey, u8 newkeylen)
+int tcp_v4_auth_do_add(struct sock *sk, __be32 addr,
+		       u8 *newkey, u8 newkeylen)
 {
 	/* Add Key to the list */
-	struct tcp_md5sig_key *key;
+	struct tcp_auth_key *key;
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp4_md5sig_key *keys;
+	struct tcp4_auth_key *keys;
 
-	key = tcp_v4_md5_do_lookup(sk, addr);
+	key = tcp_v4_auth_do_lookup(sk, addr);
 	if (key) {
 		/* Pre-existing entry - just update that one. */
 		kfree(key->key);
 		key->key = newkey;
 		key->keylen = newkeylen;
 	} else {
-		struct tcp_md5sig_info *md5sig;
+		struct tcp_auth_info *auth;
 
-		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info),
-						  GFP_ATOMIC);
-			if (!tp->md5sig_info) {
+		if (!tp->auth_info) {
+			tp->auth_info = kzalloc(sizeof(*tp->auth_info),
+						GFP_ATOMIC);
+			if (!tp->auth_info) {
 				kfree(newkey);
 				return -ENOMEM;
 			}
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		}
-		if (tcp_alloc_md5sig_pool() == NULL) {
+		if (tcp_auth_alloc_pool() == NULL) {
 			kfree(newkey);
 			return -ENOMEM;
 		}
-		md5sig = tp->md5sig_info;
+		auth = tp->auth_info;
 
-		if (md5sig->alloced4 == md5sig->entries4) {
+		if (auth->alloced4 == auth->entries4) {
 			keys = kmalloc((sizeof(*keys) *
-					(md5sig->entries4 + 1)), GFP_ATOMIC);
+					(auth->entries4 + 1)), GFP_ATOMIC);
 			if (!keys) {
 				kfree(newkey);
-				tcp_free_md5sig_pool();
+				tcp_auth_free_pool();
 				return -ENOMEM;
 			}
 
-			if (md5sig->entries4)
-				memcpy(keys, md5sig->keys4,
-				       sizeof(*keys) * md5sig->entries4);
+			if (auth->entries4)
+				memcpy(keys, auth->keys4,
+				       sizeof(*keys) * auth->entries4);
 
 			/* Free old key list, and reference new one */
-			kfree(md5sig->keys4);
-			md5sig->keys4 = keys;
-			md5sig->alloced4++;
+			kfree(auth->keys4);
+			auth->keys4 = keys;
+			auth->alloced4++;
 		}
-		md5sig->entries4++;
-		md5sig->keys4[md5sig->entries4 - 1].addr        = addr;
-		md5sig->keys4[md5sig->entries4 - 1].base.key    = newkey;
-		md5sig->keys4[md5sig->entries4 - 1].base.keylen = newkeylen;
+		auth->entries4++;
+		auth->keys4[auth->entries4 - 1].addr        = addr;
+		auth->keys4[auth->entries4 - 1].base.key    = newkey;
+		auth->keys4[auth->entries4 - 1].base.keylen = newkeylen;
 	}
 	return 0;
 }
 
-EXPORT_SYMBOL(tcp_v4_md5_do_add);
+EXPORT_SYMBOL(tcp_v4_auth_do_add);
 
-static int tcp_v4_md5_add_func(struct sock *sk, struct sock *addr_sk,
-			       u8 *newkey, u8 newkeylen)
+static int tcp_v4_auth_add_func(struct sock *sk, struct sock *addr_sk,
+			        u8 *newkey, u8 newkeylen)
 {
-	return tcp_v4_md5_do_add(sk, inet_sk(addr_sk)->daddr,
-				 newkey, newkeylen);
+	return tcp_v4_auth_do_add(sk, inet_sk(addr_sk)->daddr,
+				  newkey, newkeylen);
 }
 
-int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
+int tcp_v4_auth_do_del(struct sock *sk, __be32 addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int i;
 
-	for (i = 0; i < tp->md5sig_info->entries4; i++) {
-		if (tp->md5sig_info->keys4[i].addr == addr) {
+	for (i = 0; i < tp->auth_info->entries4; i++) {
+		if (tp->auth_info->keys4[i].addr == addr) {
 			/* Free the key */
-			kfree(tp->md5sig_info->keys4[i].base.key);
-			tp->md5sig_info->entries4--;
-
-			if (tp->md5sig_info->entries4 == 0) {
-				kfree(tp->md5sig_info->keys4);
-				tp->md5sig_info->keys4 = NULL;
-				tp->md5sig_info->alloced4 = 0;
-			} else if (tp->md5sig_info->entries4 != i) {
+			kfree(tp->auth_info->keys4[i].base.key);
+			tp->auth_info->entries4--;
+
+			if (tp->auth_info->entries4 == 0) {
+				kfree(tp->auth_info->keys4);
+				tp->auth_info->keys4 = NULL;
+				tp->auth_info->alloced4 = 0;
+			} else if (tp->auth_info->entries4 != i) {
 				/* Need to do some manipulation */
-				memmove(&tp->md5sig_info->keys4[i],
-					&tp->md5sig_info->keys4[i+1],
-					(tp->md5sig_info->entries4 - i) *
-					 sizeof(struct tcp4_md5sig_key));
+				memmove(&tp->auth_info->keys4[i],
+					&tp->auth_info->keys4[i+1],
+					(tp->auth_info->entries4 - i) *
+					 sizeof(struct tcp4_auth_key));
 			}
-			tcp_free_md5sig_pool();
+			tcp_auth_free_pool();
 			return 0;
 		}
 	}
 	return -ENOENT;
 }
 
-EXPORT_SYMBOL(tcp_v4_md5_do_del);
+EXPORT_SYMBOL(tcp_v4_auth_do_del);
 
-static void tcp_v4_clear_md5_list(struct sock *sk)
+static void tcp_v4_auth_clear_list(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -927,24 +926,24 @@ static void tcp_v4_clear_md5_list(struct sock *sk)
 	 * the crypto element, and then decrement our
 	 * hold on the last resort crypto.
 	 */
-	if (tp->md5sig_info->entries4) {
+	if (tp->auth_info->entries4) {
 		int i;
-		for (i = 0; i < tp->md5sig_info->entries4; i++)
-			kfree(tp->md5sig_info->keys4[i].base.key);
-		tp->md5sig_info->entries4 = 0;
-		tcp_free_md5sig_pool();
+		for (i = 0; i < tp->auth_info->entries4; i++)
+			kfree(tp->auth_info->keys4[i].base.key);
+		tp->auth_info->entries4 = 0;
+		tcp_auth_free_pool();
 	}
-	if (tp->md5sig_info->keys4) {
-		kfree(tp->md5sig_info->keys4);
-		tp->md5sig_info->keys4 = NULL;
-		tp->md5sig_info->alloced4  = 0;
+	if (tp->auth_info->keys4) {
+		kfree(tp->auth_info->keys4);
+		tp->auth_info->keys4 = NULL;
+		tp->auth_info->alloced4  = 0;
 	}
 }
 
-static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
-				 int optlen)
+static int tcp_v4_auth_parse_keys(struct sock *sk, char __user *optval,
+				  int optlen)
 {
-	struct tcp_md5sig cmd;
+	struct tcp_auth cmd;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
 	u8 *newkey;
 
@@ -958,39 +957,39 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 		return -EINVAL;
 
 	if (!cmd.tcpm_key || !cmd.tcpm_keylen) {
-		if (!tcp_sk(sk)->md5sig_info)
+		if (!tcp_sk(sk)->auth_info)
 			return -ENOENT;
-		return tcp_v4_md5_do_del(sk, sin->sin_addr.s_addr);
+		return tcp_v4_auth_do_del(sk, sin->sin_addr.s_addr);
 	}
 
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
 		return -EINVAL;
 
-	if (!tcp_sk(sk)->md5sig_info) {
+	if (!tcp_sk(sk)->auth_info) {
 		struct tcp_sock *tp = tcp_sk(sk);
-		struct tcp_md5sig_info *p = kzalloc(sizeof(*p), GFP_KERNEL);
+		struct tcp_auth_info *p = kzalloc(sizeof(*p), GFP_KERNEL);
 
 		if (!p)
 			return -EINVAL;
 
-		tp->md5sig_info = p;
+		tp->auth_info = p;
 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 
 	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
 	if (!newkey)
 		return -ENOMEM;
-	return tcp_v4_md5_do_add(sk, sin->sin_addr.s_addr,
-				 newkey, cmd.tcpm_keylen);
+	return tcp_v4_auth_do_add(sk, sin->sin_addr.s_addr,
+				  newkey, cmd.tcpm_keylen);
 }
 
-static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
-					__be32 daddr, __be32 saddr, int nbytes)
+static int tcp_v4_auth_hash_pseudoheader(struct tcp_auth_pool *hp,
+					 __be32 daddr, __be32 saddr, int nbytes)
 {
 	struct tcp4_pseudohdr *bp;
 	struct scatterlist sg;
 
-	bp = &hp->md5_blk.ip4;
+	bp = &hp->auth_blk.ip4;
 
 	/*
 	 * 1. the TCP pseudo-header (in the order: source IP address,
@@ -1007,43 +1006,43 @@ static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
 }
 
-static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
-			       __be32 daddr, __be32 saddr, struct tcphdr *th)
+static int tcp_v4_auth_hash_hdr(char *hash, struct tcp_auth_key *key,
+				__be32 daddr, __be32 saddr, struct tcphdr *th)
 {
-	struct tcp_md5sig_pool *hp;
+	struct tcp_auth_pool *hp;
 	struct hash_desc *desc;
 
-	hp = tcp_get_md5sig_pool();
+	hp = tcp_auth_get_pool();
 	if (!hp)
 		goto clear_hash_noput;
 	desc = &hp->md5_desc;
 
 	if (crypto_hash_init(desc))
 		goto clear_hash;
-	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
+	if (tcp_v4_auth_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
 		goto clear_hash;
-	if (tcp_md5_hash_header(hp, th))
+	if (tcp_auth_hash_header(hp, th))
 		goto clear_hash;
-	if (tcp_md5_hash_key(hp, key))
+	if (tcp_auth_hash_key(hp, key))
 		goto clear_hash;
-	if (crypto_hash_final(desc, md5_hash))
+	if (crypto_hash_final(desc, hash))
 		goto clear_hash;
 
-	tcp_put_md5sig_pool();
+	tcp_auth_put_pool();
 	return 0;
 
 clear_hash:
-	tcp_put_md5sig_pool();
+	tcp_auth_put_pool();
 clear_hash_noput:
-	memset(md5_hash, 0, 16);
+	memset(hash, 0, 16);
 	return 1;
 }
 
-int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
-			struct sock *sk, struct request_sock *req,
-			struct sk_buff *skb)
+int tcp_v4_auth_hash_skb(char *hash, struct tcp_auth_key *key,
+			 struct sock *sk, struct request_sock *req,
+			 struct sk_buff *skb)
 {
-	struct tcp_md5sig_pool *hp;
+	struct tcp_auth_pool *hp;
 	struct hash_desc *desc;
 	struct tcphdr *th = tcp_hdr(skb);
 	__be32 saddr, daddr;
@@ -1060,7 +1059,7 @@ int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 		daddr = iph->daddr;
 	}
 
-	hp = tcp_get_md5sig_pool();
+	hp = tcp_auth_get_pool();
 	if (!hp)
 		goto clear_hash_noput;
 	desc = &hp->md5_desc;
@@ -1068,30 +1067,30 @@ int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 	if (crypto_hash_init(desc))
 		goto clear_hash;
 
-	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, skb->len))
+	if (tcp_v4_auth_hash_pseudoheader(hp, daddr, saddr, skb->len))
 		goto clear_hash;
-	if (tcp_md5_hash_header(hp, th))
+	if (tcp_auth_hash_header(hp, th))
 		goto clear_hash;
-	if (tcp_md5_hash_skb_data(hp, skb, th->doff << 2))
+	if (tcp_auth_hash_skb_data(hp, skb, th->doff << 2))
 		goto clear_hash;
-	if (tcp_md5_hash_key(hp, key))
+	if (tcp_auth_hash_key(hp, key))
 		goto clear_hash;
-	if (crypto_hash_final(desc, md5_hash))
+	if (crypto_hash_final(desc, hash))
 		goto clear_hash;
 
-	tcp_put_md5sig_pool();
+	tcp_auth_put_pool();
 	return 0;
 
 clear_hash:
-	tcp_put_md5sig_pool();
+	tcp_auth_put_pool();
 clear_hash_noput:
-	memset(md5_hash, 0, 16);
+	memset(hash, 0, 16);
 	return 1;
 }
 
-EXPORT_SYMBOL(tcp_v4_md5_hash_skb);
+EXPORT_SYMBOL(tcp_v4_auth_hash_skb);
 
-static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
+static int tcp_v4_auth_inbound_hash(struct sock *sk, struct sk_buff *skb)
 {
 	/*
 	 * This gets called for each TCP segment that arrives
@@ -1102,14 +1101,14 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 	 * o MD5 hash and its wrong.
 	 */
 	__u8 *hash_location = NULL;
-	struct tcp_md5sig_key *hash_expected;
+	struct tcp_auth_key *hash_expected;
 	const struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
 	int genhash;
 	unsigned char newhash[16];
 
-	hash_expected = tcp_v4_md5_do_lookup(sk, iph->saddr);
-	hash_location = tcp_parse_md5sig_option(th);
+	hash_expected = tcp_v4_auth_do_lookup(sk, iph->saddr);
+	hash_location = tcp_auth_parse_option(th);
 
 	/* We've parsed the options - do we have a hash? */
 	if (!hash_expected && !hash_location)
@@ -1134,7 +1133,7 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 	/* Okay, so this is hash_expected and hash_location -
 	 * so we need to calculate the checksum.
 	 */
-	genhash = tcp_v4_md5_hash_skb(newhash,
+	genhash = tcp_v4_auth_hash_skb(newhash,
 				      hash_expected,
 				      NULL, NULL, skb);
 
@@ -1144,7 +1143,7 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)%s\n",
 			       NIPQUAD(iph->saddr), ntohs(th->source),
 			       NIPQUAD(iph->daddr), ntohs(th->dest),
-			       genhash ? " tcp_v4_calc_md5_hash failed" : "");
+			       genhash ? " tcp_v4_auth_hash_skb failed" : "");
 		}
 		return 1;
 	}
@@ -1164,7 +1163,7 @@ struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
-	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
+	.auth_lookup	=	tcp_v4_reqsk_auth_lookup,
 };
 #endif
 
@@ -1336,7 +1335,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	struct tcp_sock *newtp;
 	struct sock *newsk;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
+	struct tcp_auth_key *key;
 #endif
 
 	if (sk_acceptq_is_full(sk))
@@ -1374,7 +1373,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
-	if ((key = tcp_v4_md5_do_lookup(sk, newinet->daddr)) != NULL) {
+	if ((key = tcp_v4_auth_do_lookup(sk, newinet->daddr)) != NULL) {
 		/*
 		 * We're using one, so create a matching key
 		 * on the newsk structure. If we fail to get
@@ -1383,8 +1382,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 */
 		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
 		if (newkey != NULL)
-			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
-					  newkey, key->keylen);
+			tcp_v4_auth_do_add(newsk, inet_sk(sk)->daddr,
+					   newkey, key->keylen);
 		newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 #endif
@@ -1473,7 +1472,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
 	 *  o There is an MD5 option and we're not expecting one
 	 */
-	if (tcp_v4_inbound_md5_hash(sk, skb))
+	if (tcp_v4_auth_inbound_hash(sk, skb))
 		goto discard;
 #endif
 
@@ -1748,10 +1747,10 @@ struct inet_connection_sock_af_ops ipv4_specific = {
 
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
-	.md5_lookup		= tcp_v4_md5_lookup,
-	.calc_md5_hash		= tcp_v4_md5_hash_skb,
-	.md5_add		= tcp_v4_md5_add_func,
-	.md5_parse		= tcp_v4_parse_md5_keys,
+	.auth_lookup		= tcp_v4_auth_lookup,
+	.auth_calc_hash		= tcp_v4_auth_hash_skb,
+	.auth_add		= tcp_v4_auth_add_func,
+	.auth_parse		= tcp_v4_auth_parse_keys,
 };
 #endif
 
@@ -1822,10 +1821,10 @@ void tcp_v4_destroy_sock(struct sock *sk)
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Clean up the MD5 key list, if any */
-	if (tp->md5sig_info) {
-		tcp_v4_clear_md5_list(sk);
-		kfree(tp->md5sig_info);
-		tp->md5sig_info = NULL;
+	if (tp->auth_info) {
+		tcp_v4_auth_clear_list(sk);
+		kfree(tp->auth_info);
+		tp->auth_info = NULL;
 	}
 #endif
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 204c421..6f282d6 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -310,18 +310,18 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		/*
 		 * The timewait bucket does not have the key DB from the
 		 * sock structure. We just make a quick copy of the
-		 * md5 key being used (if indeed we are using one)
+		 * auth key being used (if indeed we are using one)
 		 * so the timewait ack generating code has the key.
 		 */
 		do {
-			struct tcp_md5sig_key *key;
-			memset(tcptw->tw_md5_key, 0, sizeof(tcptw->tw_md5_key));
-			tcptw->tw_md5_keylen = 0;
-			key = tp->af_specific->md5_lookup(sk, sk);
+			struct tcp_auth_key *key;
+			memset(tcptw->tw_auth_key, 0, sizeof(tcptw->tw_auth_key));
+			tcptw->tw_auth_keylen = 0;
+			key = tp->af_specific->auth_lookup(sk, sk);
 			if (key != NULL) {
-				memcpy(&tcptw->tw_md5_key, key->key, key->keylen);
-				tcptw->tw_md5_keylen = key->keylen;
-				if (tcp_alloc_md5sig_pool() == NULL)
+				memcpy(&tcptw->tw_auth_key, key->key, key->keylen);
+				tcptw->tw_auth_keylen = key->keylen;
+				if (tcp_auth_alloc_pool() == NULL)
 					BUG();
 			}
 		} while (0);
@@ -361,8 +361,8 @@ void tcp_twsk_destructor(struct sock *sk)
 {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
-	if (twsk->tw_md5_keylen)
-		tcp_put_md5sig_pool();
+	if (twsk->tw_auth_keylen)
+		tcp_auth_put_pool();
 #endif
 }
 
@@ -471,8 +471,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 			newtp->tcp_header_len = sizeof(struct tcphdr);
 		}
 #ifdef CONFIG_TCP_MD5SIG
-		newtp->md5sig_info = NULL;	/*XXX*/
-		if (newtp->af_specific->md5_lookup(sk, newsk))
+		newtp->auth_info = NULL;	/*XXX*/
+		if (newtp->af_specific->auth_lookup(sk, newsk))
 			newtp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
 #endif
 		if (skb->len >= TCP_MIN_RCVMSS+newtp->tcp_header_len)
@@ -660,9 +660,9 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 #ifdef CONFIG_TCP_MD5SIG
 		else {
 			/* Copy over the MD5 key from the original socket */
-			struct tcp_md5sig_key *key;
+			struct tcp_auth_key *key;
 			struct tcp_sock *tp = tcp_sk(sk);
-			key = tp->af_specific->md5_lookup(sk, child);
+			key = tp->af_specific->auth_lookup(sk, child);
 			if (key != NULL) {
 				/*
 				 * We're using one, so create a matching key on the
@@ -672,11 +672,11 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 				char *newkey = kmemdup(key->key, key->keylen,
 						       GFP_ATOMIC);
 				if (newkey) {
-					if (!tcp_alloc_md5sig_pool())
+					if (!tcp_auth_alloc_pool())
 						BUG();
-					tp->af_specific->md5_add(child, child,
-								 newkey,
-								 key->keylen);
+					tp->af_specific->auth_add(child, child,
+								  newkey,
+								  key->keylen);
 				}
 			}
 		}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1fa683c..4fe610f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -359,16 +359,16 @@ struct tcp_out_options {
 
 static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 			      const struct tcp_out_options *opts,
-			      __u8 **md5_hash) {
+			      __u8 **hash) {
 	if (unlikely(OPTION_MD5 & opts->options)) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_NOP << 16) |
 			       (TCPOPT_MD5SIG << 8) |
 			       TCPOLEN_MD5SIG);
-		*md5_hash = (__u8 *)ptr;
+		*hash = (__u8 *)ptr;
 		ptr += 4;
 	} else {
-		*md5_hash = NULL;
+		*hash = NULL;
 	}
 
 	if (likely(OPTION_TS & opts->options)) {
@@ -434,18 +434,18 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 
 static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_out_options *opts,
-				struct tcp_md5sig_key **md5) {
+				struct tcp_auth_key **key) {
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned size = 0;
 
 #ifdef CONFIG_TCP_MD5SIG
-	*md5 = tp->af_specific->md5_lookup(sk, sk);
-	if (*md5) {
+	*key = tp->af_specific->auth_lookup(sk, sk);
+	if (*key) {
 		opts->options |= OPTION_MD5;
 		size += TCPOLEN_MD5SIG_ALIGNED;
 	}
 #else
-	*md5 = NULL;
+	*key = NULL;
 #endif
 
 	/* We always get an MSS option.  The option bytes which will be seen in
@@ -460,7 +460,7 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	opts->mss = tcp_advertise_mss(sk);
 	size += TCPOLEN_MSS_ALIGNED;
 
-	if (likely(sysctl_tcp_timestamps && *md5 == NULL)) {
+	if (likely(sysctl_tcp_timestamps && *key == NULL)) {
 		opts->options |= OPTION_TS;
 		opts->tsval = TCP_SKB_CB(skb)->when;
 		opts->tsecr = tp->rx_opt.ts_recent;
@@ -483,26 +483,26 @@ static unsigned tcp_synack_options(struct sock *sk,
 				   struct request_sock *req,
 				   unsigned mss, struct sk_buff *skb,
 				   struct tcp_out_options *opts,
-				   struct tcp_md5sig_key **md5) {
+				   struct tcp_auth_key **key) {
 	unsigned size = 0;
 	struct inet_request_sock *ireq = inet_rsk(req);
 	char doing_ts;
 
 #ifdef CONFIG_TCP_MD5SIG
-	*md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
-	if (*md5) {
+	*key = tcp_rsk(req)->af_specific->auth_lookup(sk, req);
+	if (*key) {
 		opts->options |= OPTION_MD5;
 		size += TCPOLEN_MD5SIG_ALIGNED;
 	}
 #else
-	*md5 = NULL;
+	*key = NULL;
 #endif
 
 	/* we can't fit any SACK blocks in a packet with MD5 + TS
 	   options. There was discussion about disabling SACK rather than TS in
 	   order to fit in better with old, buggy kernels, but that was deemed
 	   to be unnecessary. */
-	doing_ts = ireq->tstamp_ok && !(*md5 && ireq->sack_ok);
+	doing_ts = ireq->tstamp_ok && !(*key && ireq->sack_ok);
 
 	opts->mss = mss;
 	size += TCPOLEN_MSS_ALIGNED;
@@ -528,19 +528,19 @@ static unsigned tcp_synack_options(struct sock *sk,
 
 static unsigned tcp_established_options(struct sock *sk, struct sk_buff *skb,
 					struct tcp_out_options *opts,
-					struct tcp_md5sig_key **md5) {
+					struct tcp_auth_key **key) {
 	struct tcp_skb_cb *tcb = skb ? TCP_SKB_CB(skb) : NULL;
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned size = 0;
 
 #ifdef CONFIG_TCP_MD5SIG
-	*md5 = tp->af_specific->md5_lookup(sk, sk);
-	if (unlikely(*md5)) {
+	*key = tp->af_specific->auth_lookup(sk, sk);
+	if (unlikely(*key)) {
 		opts->options |= OPTION_MD5;
 		size += TCPOLEN_MD5SIG_ALIGNED;
 	}
 #else
-	*md5 = NULL;
+	*key = NULL;
 #endif
 
 	if (likely(tp->rx_opt.tstamp_ok)) {
@@ -583,8 +583,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	struct tcp_skb_cb *tcb;
 	struct tcp_out_options opts;
 	unsigned tcp_options_size, tcp_header_size;
-	struct tcp_md5sig_key *md5;
-	__u8 *md5_hash_location;
+	struct tcp_auth_key *key;
+	__u8 *hash_location;
 	struct tcphdr *th;
 	int err;
 
@@ -611,10 +611,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	memset(&opts, 0, sizeof(opts));
 
 	if (unlikely(tcb->flags & TCPCB_FLAG_SYN))
-		tcp_options_size = tcp_syn_options(sk, skb, &opts, &md5);
+		tcp_options_size = tcp_syn_options(sk, skb, &opts, &key);
 	else
 		tcp_options_size = tcp_established_options(sk, skb, &opts,
-							   &md5);
+							   &key);
 	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
 
 	if (tcp_packets_in_flight(tp) == 0)
@@ -650,16 +650,16 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		th->urg			= 1;
 	}
 
-	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
+	tcp_options_write((__be32 *)(th + 1), tp, &opts, &hash_location);
 	if (likely((tcb->flags & TCPCB_FLAG_SYN) == 0))
 		TCP_ECN_send(sk, skb, tcp_header_size);
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Calculate the MD5 hash, as we have all we need now */
-	if (md5) {
+	if (key) {
 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
-		tp->af_specific->calc_md5_hash(md5_hash_location,
-					       md5, sk, NULL, skb);
+		tp->af_specific->auth_calc_hash(hash_location,
+						key, sk, NULL, skb);
 	}
 #endif
 
@@ -1023,7 +1023,7 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 	int doing_tso = 0;
 	unsigned header_len;
 	struct tcp_out_options opts;
-	struct tcp_md5sig_key *md5;
+	struct tcp_auth_key *key;
 
 	mss_now = tp->mss_cache;
 
@@ -1036,7 +1036,7 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 
-	header_len = tcp_established_options(sk, NULL, &opts, &md5) +
+	header_len = tcp_established_options(sk, NULL, &opts, &key) +
 		     sizeof(struct tcphdr);
 	/* The mss_cache is sized based on tp->tcp_header_len, which assumes
 	 * some common options. If this is an odd packet (because we have SACK
@@ -2237,8 +2237,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	int tcp_header_size;
 	struct tcp_out_options opts;
 	struct sk_buff *skb;
-	struct tcp_md5sig_key *md5;
-	__u8 *md5_hash_location;
+	struct tcp_auth_key *key;
+	__u8 *hash_location;
 
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
 	if (skb == NULL)
@@ -2267,7 +2267,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	tcp_header_size = tcp_synack_options(sk, req,
 					     dst_metric(dst, RTAX_ADVMSS),
-					     skb, &opts, &md5) +
+					     skb, &opts, &key) +
 			  sizeof(struct tcphdr);
 
 	skb_push(skb, tcp_header_size);
@@ -2295,15 +2295,15 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
 	else
 #endif
-	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
+	tcp_options_write((__be32 *)(th + 1), tp, &opts, &hash_location);
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
-	/* Okay, we have all we need - do the md5 hash if needed */
-	if (md5) {
-		tp->af_specific->calc_md5_hash(md5_hash_location,
-					       md5, NULL, req, skb);
+	/* Okay, we have all we need - do the auth hash if needed */
+	if (key) {
+		tp->af_specific->calc_auth_hash(hash_location,
+					        key, NULL, req, skb);
 	}
 #endif
 
@@ -2326,7 +2326,7 @@ static void tcp_connect_init(struct sock *sk)
 		(sysctl_tcp_timestamps ? TCPOLEN_TSTAMP_ALIGNED : 0);
 
 #ifdef CONFIG_TCP_MD5SIG
-	if (tp->af_specific->md5_lookup(sk, sk) != NULL)
+	if (tp->af_specific->auth_lookup(sk, sk) != NULL)
 		tp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
 #endif
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ae45f98..ffac593 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -79,8 +79,8 @@ static struct inet_connection_sock_af_ops ipv6_specific;
 static struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
 #else
-static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
-						   struct in6_addr *addr)
+static struct tcp_auth_key *tcp_v6_auth_do_lookup(struct sock *sk,
+						  struct in6_addr *addr)
 {
 	return NULL;
 }
@@ -534,45 +534,45 @@ static void tcp_v6_reqsk_destructor(struct request_sock *req)
 }
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
-						   struct in6_addr *addr)
+static struct tcp_auth_key *tcp_v6_auth_do_lookup(struct sock *sk,
+						  struct in6_addr *addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int i;
 
 	BUG_ON(tp == NULL);
 
-	if (!tp->md5sig_info || !tp->md5sig_info->entries6)
+	if (!tp->auth_info || !tp->auth_info->entries6)
 		return NULL;
 
-	for (i = 0; i < tp->md5sig_info->entries6; i++) {
-		if (ipv6_addr_equal(&tp->md5sig_info->keys6[i].addr, addr))
-			return &tp->md5sig_info->keys6[i].base;
+	for (i = 0; i < tp->auth_info->entries6; i++) {
+		if (ipv6_addr_equal(&tp->auth_info->keys6[i].addr, addr))
+			return &tp->auth_info->keys6[i].base;
 	}
 	return NULL;
 }
 
-static struct tcp_md5sig_key *tcp_v6_md5_lookup(struct sock *sk,
-						struct sock *addr_sk)
+static struct tcp_auth_key *tcp_v6_auth_lookup(struct sock *sk,
+					       struct sock *addr_sk)
 {
-	return tcp_v6_md5_do_lookup(sk, &inet6_sk(addr_sk)->daddr);
+	return tcp_v6_auth_do_lookup(sk, &inet6_sk(addr_sk)->daddr);
 }
 
-static struct tcp_md5sig_key *tcp_v6_reqsk_md5_lookup(struct sock *sk,
-						      struct request_sock *req)
+static struct tcp_auth_key *tcp_v6_reqsk_auth_lookup(struct sock *sk,
+						     struct request_sock *req)
 {
-	return tcp_v6_md5_do_lookup(sk, &inet6_rsk(req)->rmt_addr);
+	return tcp_v6_auth_do_lookup(sk, &inet6_rsk(req)->rmt_addr);
 }
 
-static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *peer,
-			     char *newkey, u8 newkeylen)
+static int tcp_v6_auth_do_add(struct sock *sk, struct in6_addr *peer,
+			      char *newkey, u8 newkeylen)
 {
 	/* Add key to the list */
-	struct tcp_md5sig_key *key;
+	struct tcp_auth_key *key;
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp6_md5sig_key *keys;
+	struct tcp6_auth_key *keys;
 
-	key = tcp_v6_md5_do_lookup(sk, peer);
+	key = tcp_v6_auth_do_lookup(sk, peer);
 	if (key) {
 		/* modify existing entry - just update that one */
 		kfree(key->key);
@@ -580,117 +580,117 @@ static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *peer,
 		key->keylen = newkeylen;
 	} else {
 		/* reallocate new list if current one is full. */
-		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
-			if (!tp->md5sig_info) {
+		if (!tp->auth_info) {
+			tp->auth_info = kzalloc(sizeof(*tp->auth_info), GFP_ATOMIC);
+			if (!tp->auth_info) {
 				kfree(newkey);
 				return -ENOMEM;
 			}
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		}
-		if (tcp_alloc_md5sig_pool() == NULL) {
+		if (tcp_auth_alloc_pool() == NULL) {
 			kfree(newkey);
 			return -ENOMEM;
 		}
-		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
-			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
-				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
+		if (tp->auth_info->alloced6 == tp->auth_info->entries6) {
+			keys = kmalloc((sizeof (tp->auth_info->keys6[0]) *
+				       (tp->auth_info->entries6 + 1)), GFP_ATOMIC);
 
 			if (!keys) {
-				tcp_free_md5sig_pool();
+				tcp_auth_free_pool();
 				kfree(newkey);
 				return -ENOMEM;
 			}
 
-			if (tp->md5sig_info->entries6)
-				memmove(keys, tp->md5sig_info->keys6,
-					(sizeof (tp->md5sig_info->keys6[0]) *
-					 tp->md5sig_info->entries6));
+			if (tp->auth_info->entries6)
+				memmove(keys, tp->auth_info->keys6,
+					(sizeof (tp->auth_info->keys6[0]) *
+					 tp->auth_info->entries6));
 
-			kfree(tp->md5sig_info->keys6);
-			tp->md5sig_info->keys6 = keys;
-			tp->md5sig_info->alloced6++;
+			kfree(tp->auth_info->keys6);
+			tp->auth_info->keys6 = keys;
+			tp->auth_info->alloced6++;
 		}
 
-		ipv6_addr_copy(&tp->md5sig_info->keys6[tp->md5sig_info->entries6].addr,
+		ipv6_addr_copy(&tp->auth_info->keys6[tp->auth_info->entries6].addr,
 			       peer);
-		tp->md5sig_info->keys6[tp->md5sig_info->entries6].base.key = newkey;
-		tp->md5sig_info->keys6[tp->md5sig_info->entries6].base.keylen = newkeylen;
+		tp->auth_info->keys6[tp->auth_info->entries6].base.key = newkey;
+		tp->auth_info->keys6[tp->auth_info->entries6].base.keylen = newkeylen;
 
-		tp->md5sig_info->entries6++;
+		tp->auth_info->entries6++;
 	}
 	return 0;
 }
 
-static int tcp_v6_md5_add_func(struct sock *sk, struct sock *addr_sk,
+static int tcp_v6_auth_add_func(struct sock *sk, struct sock *addr_sk,
 			       u8 *newkey, __u8 newkeylen)
 {
-	return tcp_v6_md5_do_add(sk, &inet6_sk(addr_sk)->daddr,
-				 newkey, newkeylen);
+	return tcp_v6_auth_do_add(sk, &inet6_sk(addr_sk)->daddr,
+				  newkey, newkeylen);
 }
 
-static int tcp_v6_md5_do_del(struct sock *sk, struct in6_addr *peer)
+static int tcp_v6_auth_do_del(struct sock *sk, struct in6_addr *peer)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int i;
 
-	for (i = 0; i < tp->md5sig_info->entries6; i++) {
-		if (ipv6_addr_equal(&tp->md5sig_info->keys6[i].addr, peer)) {
+	for (i = 0; i < tp->auth_info->entries6; i++) {
+		if (ipv6_addr_equal(&tp->auth_info->keys6[i].addr, peer)) {
 			/* Free the key */
-			kfree(tp->md5sig_info->keys6[i].base.key);
-			tp->md5sig_info->entries6--;
+			kfree(tp->auth_info->keys6[i].base.key);
+			tp->auth_info->entries6--;
 
-			if (tp->md5sig_info->entries6 == 0) {
-				kfree(tp->md5sig_info->keys6);
-				tp->md5sig_info->keys6 = NULL;
-				tp->md5sig_info->alloced6 = 0;
+			if (tp->auth_info->entries6 == 0) {
+				kfree(tp->auth_info->keys6);
+				tp->auth_info->keys6 = NULL;
+				tp->auth_info->alloced6 = 0;
 			} else {
 				/* shrink the database */
-				if (tp->md5sig_info->entries6 != i)
-					memmove(&tp->md5sig_info->keys6[i],
-						&tp->md5sig_info->keys6[i+1],
-						(tp->md5sig_info->entries6 - i)
-						* sizeof (tp->md5sig_info->keys6[0]));
+				if (tp->auth_info->entries6 != i)
+					memmove(&tp->auth_info->keys6[i],
+						&tp->auth_info->keys6[i+1],
+						(tp->auth_info->entries6 - i)
+						* sizeof (tp->auth_info->keys6[0]));
 			}
-			tcp_free_md5sig_pool();
+			tcp_auth_free_pool();
 			return 0;
 		}
 	}
 	return -ENOENT;
 }
 
-static void tcp_v6_clear_md5_list (struct sock *sk)
+static void tcp_v6_auth_clear_list(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int i;
 
-	if (tp->md5sig_info->entries6) {
-		for (i = 0; i < tp->md5sig_info->entries6; i++)
-			kfree(tp->md5sig_info->keys6[i].base.key);
-		tp->md5sig_info->entries6 = 0;
-		tcp_free_md5sig_pool();
+	if (tp->auth_info->entries6) {
+		for (i = 0; i < tp->auth_info->entries6; i++)
+			kfree(tp->auth_info->keys6[i].base.key);
+		tp->auth_info->entries6 = 0;
+		tcp_auth_free_pool();
 	}
 
-	kfree(tp->md5sig_info->keys6);
-	tp->md5sig_info->keys6 = NULL;
-	tp->md5sig_info->alloced6 = 0;
+	kfree(tp->auth_info->keys6);
+	tp->auth_info->keys6 = NULL;
+	tp->auth_info->alloced6 = 0;
 
-	if (tp->md5sig_info->entries4) {
-		for (i = 0; i < tp->md5sig_info->entries4; i++)
-			kfree(tp->md5sig_info->keys4[i].base.key);
-		tp->md5sig_info->entries4 = 0;
-		tcp_free_md5sig_pool();
+	if (tp->auth_info->entries4) {
+		for (i = 0; i < tp->auth_info->entries4; i++)
+			kfree(tp->auth_info->keys4[i].base.key);
+		tp->auth_info->entries4 = 0;
+		tcp_auth_free_pool();
 	}
 
-	kfree(tp->md5sig_info->keys4);
-	tp->md5sig_info->keys4 = NULL;
-	tp->md5sig_info->alloced4 = 0;
+	kfree(tp->auth_info->keys4);
+	tp->auth_info->keys4 = NULL;
+	tp->auth_info->alloced4 = 0;
 }
 
-static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
+static int tcp_v6_auth_parse_keys(struct sock *sk, char __user *optval,
 				  int optlen)
 {
-	struct tcp_md5sig cmd;
+	struct tcp_auth cmd;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
 	u8 *newkey;
 
@@ -704,25 +704,25 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 		return -EINVAL;
 
 	if (!cmd.tcpm_keylen) {
-		if (!tcp_sk(sk)->md5sig_info)
+		if (!tcp_sk(sk)->auth_info)
 			return -ENOENT;
 		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
-			return tcp_v4_md5_do_del(sk, sin6->sin6_addr.s6_addr32[3]);
-		return tcp_v6_md5_do_del(sk, &sin6->sin6_addr);
+			return tcp_v4_auth_do_del(sk, sin6->sin6_addr.s6_addr32[3]);
+		return tcp_v6_auth_do_del(sk, &sin6->sin6_addr);
 	}
 
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
 		return -EINVAL;
 
-	if (!tcp_sk(sk)->md5sig_info) {
+	if (!tcp_sk(sk)->auth_info) {
 		struct tcp_sock *tp = tcp_sk(sk);
-		struct tcp_md5sig_info *p;
+		struct tcp_auth_info *p;
 
-		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
+		p = kzalloc(sizeof(struct tcp_auth_info), GFP_KERNEL);
 		if (!p)
 			return -ENOMEM;
 
-		tp->md5sig_info = p;
+		tp->auth_info = p;
 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 
@@ -730,20 +730,20 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 	if (!newkey)
 		return -ENOMEM;
 	if (ipv6_addr_v4mapped(&sin6->sin6_addr)) {
-		return tcp_v4_md5_do_add(sk, sin6->sin6_addr.s6_addr32[3],
+		return tcp_v4_auth_do_add(sk, sin6->sin6_addr.s6_addr32[3],
 					 newkey, cmd.tcpm_keylen);
 	}
-	return tcp_v6_md5_do_add(sk, &sin6->sin6_addr, newkey, cmd.tcpm_keylen);
+	return tcp_v6_auth_do_add(sk, &sin6->sin6_addr, newkey, cmd.tcpm_keylen);
 }
 
-static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
-					struct in6_addr *daddr,
-					struct in6_addr *saddr, int nbytes)
+static int tcp_v6_auth_hash_pseudoheader(struct tcp_auth_pool *hp,
+					 struct in6_addr *daddr,
+					 struct in6_addr *saddr, int nbytes)
 {
 	struct tcp6_pseudohdr *bp;
 	struct scatterlist sg;
 
-	bp = &hp->md5_blk.ip6;
+	bp = &hp->auth_blk.ip6;
 	/* 1. TCP pseudo-header (RFC2460) */
 	ipv6_addr_copy(&bp->saddr, saddr);
 	ipv6_addr_copy(&bp->daddr, daddr);
@@ -754,45 +754,45 @@ static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
 }
 
-static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
-			       struct in6_addr *daddr, struct in6_addr *saddr,
-			       struct tcphdr *th)
+static int tcp_v6_auth_hash_hdr(char *hash, struct tcp_auth_key *key,
+			        struct in6_addr *daddr, struct in6_addr *saddr,
+			        struct tcphdr *th)
 {
-	struct tcp_md5sig_pool *hp;
+	struct tcp_auth_pool *hp;
 	struct hash_desc *desc;
 
-	hp = tcp_get_md5sig_pool();
+	hp = tcp_auth_get_pool();
 	if (!hp)
 		goto clear_hash_noput;
 	desc = &hp->md5_desc;
 
 	if (crypto_hash_init(desc))
 		goto clear_hash;
-	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
+	if (tcp_v6_auth_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
 		goto clear_hash;
-	if (tcp_md5_hash_header(hp, th))
+	if (tcp_auth_hash_header(hp, th))
 		goto clear_hash;
-	if (tcp_md5_hash_key(hp, key))
+	if (tcp_auth_hash_key(hp, key))
 		goto clear_hash;
-	if (crypto_hash_final(desc, md5_hash))
+	if (crypto_hash_final(desc, hash))
 		goto clear_hash;
 
-	tcp_put_md5sig_pool();
+	tcp_auth_put_pool();
 	return 0;
 
 clear_hash:
-	tcp_put_md5sig_pool();
+	tcp_auth_put_pool();
 clear_hash_noput:
-	memset(md5_hash, 0, 16);
+	memset(hash, 0, 16);
 	return 1;
 }
 
-static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
-			       struct sock *sk, struct request_sock *req,
-			       struct sk_buff *skb)
+static int tcp_v6_auth_hash_skb(char *hash, struct tcp_auth_key *key,
+			        struct sock *sk, struct request_sock *req,
+			        struct sk_buff *skb)
 {
 	struct in6_addr *saddr, *daddr;
-	struct tcp_md5sig_pool *hp;
+	struct tcp_auth_pool *hp;
 	struct hash_desc *desc;
 	struct tcphdr *th = tcp_hdr(skb);
 
@@ -808,7 +808,7 @@ static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 		daddr = &ip6h->daddr;
 	}
 
-	hp = tcp_get_md5sig_pool();
+	hp = tcp_auth_get_pool();
 	if (!hp)
 		goto clear_hash_noput;
 	desc = &hp->md5_desc;
@@ -816,38 +816,38 @@ static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 	if (crypto_hash_init(desc))
 		goto clear_hash;
 
-	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, skb->len))
+	if (tcp_v6_auth_hash_pseudoheader(hp, daddr, saddr, skb->len))
 		goto clear_hash;
-	if (tcp_md5_hash_header(hp, th))
+	if (tcp_auth_hash_header(hp, th))
 		goto clear_hash;
-	if (tcp_md5_hash_skb_data(hp, skb, th->doff << 2))
+	if (tcp_auth_hash_skb_data(hp, skb, th->doff << 2))
 		goto clear_hash;
-	if (tcp_md5_hash_key(hp, key))
+	if (tcp_auth_hash_key(hp, key))
 		goto clear_hash;
-	if (crypto_hash_final(desc, md5_hash))
+	if (crypto_hash_final(desc, hash))
 		goto clear_hash;
 
-	tcp_put_md5sig_pool();
+	tcp_auth_put_pool();
 	return 0;
 
 clear_hash:
-	tcp_put_md5sig_pool();
+	tcp_auth_put_pool();
 clear_hash_noput:
-	memset(md5_hash, 0, 16);
+	memset(hash, 0, 16);
 	return 1;
 }
 
-static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
+static int tcp_v6_auth_inbound_hash(struct sock *sk, struct sk_buff *skb)
 {
 	__u8 *hash_location = NULL;
-	struct tcp_md5sig_key *hash_expected;
+	struct tcp_auth_key *hash_expected;
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
 	int genhash;
 	u8 newhash[16];
 
-	hash_expected = tcp_v6_md5_do_lookup(sk, &ip6h->saddr);
-	hash_location = tcp_parse_md5sig_option(th);
+	hash_expected = tcp_v6_auth_do_lookup(sk, &ip6h->saddr);
+	hash_location = tcp_auth_parse_option(th);
 
 	/* do we have a hash as expected? */
 	if (!hash_expected) {
@@ -875,9 +875,9 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* check the signature */
-	genhash = tcp_v6_md5_hash_skb(newhash,
-				      hash_expected,
-				      NULL, NULL, skb);
+	genhash = tcp_v6_auth_hash_skb(newhash,
+				       hash_expected,
+				       NULL, NULL, skb);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
@@ -905,7 +905,7 @@ struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
-	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
+	.auth_lookup	=	tcp_v6_reqsk_auth_lookup,
 };
 #endif
 
@@ -960,7 +960,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(*th);
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
+	struct tcp_auth_key *key;
 #endif
 
 	if (th->rst)
@@ -971,7 +971,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 
 #ifdef CONFIG_TCP_MD5SIG
 	if (sk)
-		key = tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr);
+		key = tcp_v6_auth_do_lookup(sk, &ipv6_hdr(skb)->daddr);
 	else
 		key = NULL;
 
@@ -1015,9 +1015,9 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 			       (TCPOPT_NOP << 16) |
 			       (TCPOPT_MD5SIG << 8) |
 			       TCPOLEN_MD5SIG);
-		tcp_v6_md5_hash_hdr((__u8 *)&opt[1], key,
-				    &ipv6_hdr(skb)->daddr,
-				    &ipv6_hdr(skb)->saddr, t1);
+		tcp_v6_auth_hash_hdr((__u8 *)&opt[1], key,
+				     &ipv6_hdr(skb)->daddr,
+				     &ipv6_hdr(skb)->saddr, t1);
 	}
 #endif
 
@@ -1055,7 +1055,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 }
 
 static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts,
-			    struct tcp_md5sig_key *key)
+			    struct tcp_auth_key *key)
 {
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
@@ -1104,9 +1104,9 @@ static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32
 	if (key) {
 		*topt++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				(TCPOPT_MD5SIG << 8) | TCPOLEN_MD5SIG);
-		tcp_v6_md5_hash_hdr((__u8 *)topt, key,
-				    &ipv6_hdr(skb)->daddr,
-				    &ipv6_hdr(skb)->saddr, t1);
+		tcp_v6_auth_hash_hdr((__u8 *)topt, key,
+				     &ipv6_hdr(skb)->daddr,
+				     &ipv6_hdr(skb)->saddr, t1);
 	}
 #endif
 
@@ -1144,7 +1144,7 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 
 	tcp_v6_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
-			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw));
+			tcptw->tw_ts_recent, tcp_twsk_auth_key(tcptw));
 
 	inet_twsk_put(tw);
 }
@@ -1152,7 +1152,7 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 static void tcp_v6_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req)
 {
 	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent,
-			tcp_v6_md5_do_lookup(skb->sk, &ipv6_hdr(skb)->daddr));
+			tcp_v6_auth_do_lookup(skb->sk, &ipv6_hdr(skb)->daddr));
 }
 
 
@@ -1303,7 +1303,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	struct sock *newsk;
 	struct ipv6_txoptions *opt;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
+	struct tcp_auth_key *key;
 #endif
 
 	if (skb->protocol == htons(ETH_P_IP)) {
@@ -1469,7 +1469,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
-	if ((key = tcp_v6_md5_do_lookup(sk, &newnp->daddr)) != NULL) {
+	if ((key = tcp_v6_auth_do_lookup(sk, &newnp->daddr)) != NULL) {
 		/* We're using one, so create a matching key
 		 * on the newsk structure. If we fail to get
 		 * memory, then we end up not copying the key
@@ -1477,8 +1477,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 */
 		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
 		if (newkey != NULL)
-			tcp_v6_md5_do_add(newsk, &inet6_sk(sk)->daddr,
-					  newkey, key->keylen);
+			tcp_v6_auth_do_add(newsk, &inet6_sk(sk)->daddr,
+					   newkey, key->keylen);
 	}
 #endif
 
@@ -1543,7 +1543,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		return tcp_v4_do_rcv(sk, skb);
 
 #ifdef CONFIG_TCP_MD5SIG
-	if (tcp_v6_inbound_md5_hash (sk, skb))
+	if (tcp_v6_auth_inbound_hash(sk, skb))
 		goto discard;
 #endif
 
@@ -1821,10 +1821,10 @@ static struct inet_connection_sock_af_ops ipv6_specific = {
 
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
-	.md5_lookup	=	tcp_v6_md5_lookup,
-	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
-	.md5_add	=	tcp_v6_md5_add_func,
-	.md5_parse	=	tcp_v6_parse_md5_keys,
+	.auth_lookup	=	tcp_v6_auth_lookup,
+	.auth_calc_hash	=	tcp_v6_auth_hash_skb,
+	.auth_add	=	tcp_v6_auth_add_func,
+	.auth_parse	=	tcp_v6_auth_parse_keys,
 };
 #endif
 
@@ -1853,10 +1853,10 @@ static struct inet_connection_sock_af_ops ipv6_mapped = {
 
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific = {
-	.md5_lookup	=	tcp_v4_md5_lookup,
-	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
-	.md5_add	=	tcp_v6_md5_add_func,
-	.md5_parse	=	tcp_v6_parse_md5_keys,
+	.auth_lookup	=	tcp_v4_auth_lookup,
+	.auth_calc_hash	=	tcp_v4_auth_hash_skb,
+	.auth_add	=	tcp_v6_auth_add_func,
+	.auth_parse	=	tcp_v6_auth_parse_keys,
 };
 #endif
 
@@ -1915,8 +1915,8 @@ static void tcp_v6_destroy_sock(struct sock *sk)
 {
 #ifdef CONFIG_TCP_MD5SIG
 	/* Clean up the MD5 key list */
-	if (tcp_sk(sk)->md5sig_info)
-		tcp_v6_clear_md5_list(sk);
+	if (tcp_sk(sk)->auth_info)
+		tcp_v6_auth_clear_list(sk);
 #endif
 	tcp_v4_destroy_sock(sk);
 	inet6_destroy_sock(sk);
