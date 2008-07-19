From: "Adam Langley" <agl@imperialviolet.org>
Subject: [RFC 2/2] TCP: Add TCP-AO support
Date: Fri, 18 Jul 2008 17:22:10 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069032@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:7596 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437AbYGSAVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 20:21:10 -0400
Received: by wf-out-1314.google.com with SMTP id 27so450723wfd.4
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 17:21:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the draft isn't finalised yet, this is just an experimental patch set
against net-2.6 for people who wish to comment.

Stuff that is clearly a result of the experimental nature of this patch:
  * The TCP option number hasn't been assigned yet, so I just took a guess
  * The MAC functions haven't been decided yet, so I took a guess at
    HMAC-MD5-96 and HMAC-SHA1-96

Limitations which might well persist into a final patch unless someone has a
good argument against:
  * Only two keys supported (against a spec max of 256)
  * Asymmetric protection not supported

Stuff I included that I hope will end up in the new draft of the spec:
  * The keyid is placed at the beginning of the MAC for better alignment
  * Excluding the pseudoheader and port numbers for NAT traversal is supported

Stuff that might be a good idea, I'm not sure yet:
  * Latch mode: unsigned packets are accepted until the first signed packet is
    received. This is for applications which setup TCP auth after an unsigned
    SYN handshake.

The userspace interface is similar to the md5sig one (and md5sig is still
supported with a wrapper around the TCP auth code) and is probably adequately
described by the header:

#define TCP_AUTH_KEYED_MD5_128		0
#define TCP_AUTH_HMAC_MD5_96		1
#define TCP_AUTH_HMAC_SHA1_96		2

#define TCP_AUTH_MAX_MAC		2
#define TCP_AUTH_MAX_MAC_SIZE		20	/* SHA1 sets the limit */

/* tcpa_flags */
#define TCP_AUTH_ALLOW_KEY0		(1 << 0)
#define TCP_AUTH_ALLOW_KEY1		(1 << 1)
#define TCP_AUTH_TX_KEY1		(1 << 2)
#define TCP_AUTH_RFC2385		(1 << 3)
#define TCP_AUTH_OPTIONS_EXCLUDE	(1 << 4)
#define TCP_AUTH_PSEUDOHEADER_EXCLUDE	(1 << 5)
#define TCP_AUTH_PORT_NUMS_EXCLUDE	(1 << 6)
#define TCP_AUTH_LATCH			(1 << 7)

struct tcp_auth {
	struct __kernel_sockaddr_storage tcpa_addr;	/* address associated */
	__u8	tcpa_key0[TCP_AUTH_MAXKEYLEN];		/* key0 (binary) */
	__u8	tcpa_key1[TCP_AUTH_MAXKEYLEN];		/* key1 (binary) */
	__u8	tcpa_key0len;				/* key0 length */
	__u8	tcpa_key1len;				/* key1 length */
	__u8	tcpa_macfunc;				/* MAC function */
	__u8	tcpa_flags;
};
---

 include/linux/tcp.h      |   42 +++++-
 include/net/tcp.h        |  116 +++++++++++++----
 net/ipv4/Kconfig         |    2 
 net/ipv4/tcp.c           |  317 ++++++++++++++++++++++++++++++++++++++++++----
 net/ipv4/tcp_input.c     |   13 +-
 net/ipv4/tcp_ipv4.c      |  293 +++++++++++++++++++++++--------------------
 net/ipv4/tcp_minisocks.c |   18 ++-
 net/ipv4/tcp_output.c    |   58 ++++----
 net/ipv6/tcp_ipv6.c      |  276 +++++++++++++++++++++++-----------------
 9 files changed, 792 insertions(+), 343 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 65542c6..fd36a19 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -96,6 +96,7 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
+#define TCP_AUTH		15	/* TCP Auth option */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -162,12 +163,41 @@ struct tcp_info
 /* for TCP_MD5SIG socket option */
 #define TCP_MD5SIG_MAXKEYLEN	80
 
-struct tcp_auth {
+struct tcp_md5sig {
 	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
-	__u16	__tcpm_pad1;				/* zero */
-	__u16	tcpm_keylen;				/* key length */
-	__u32	__tcpm_pad2;				/* zero */
-	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
+	__u16   __tcpm_pad1;				/* zero */
+	__u16   tcpm_keylen;				/* key length */
+	__u32   __tcpm_pad2;				/* zero */
+	__u8    tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
+};
+
+#define TCP_AUTH_MAXKEYLEN TCP_MD5SIG_MAXKEYLEN
+
+/* MAC functions */
+#define TCP_AUTH_KEYED_MD5_128		0
+#define TCP_AUTH_HMAC_MD5_96		1
+#define TCP_AUTH_HMAC_SHA1_96		2
+
+#define TCP_AUTH_MAX_MAC		2
+
+/* tcpa_flags */
+#define TCP_AUTH_ALLOW_KEY0		(1 << 0)
+#define TCP_AUTH_ALLOW_KEY1		(1 << 1)
+#define TCP_AUTH_TX_KEY1		(1 << 2)
+#define TCP_AUTH_RFC2385		(1 << 3)
+#define TCP_AUTH_OPTIONS_EXCLUDE	(1 << 4)
+#define TCP_AUTH_PSEUDOHEADER_EXCLUDE	(1 << 5)
+#define TCP_AUTH_PORT_NUMS_EXCLUDE	(1 << 6)
+#define TCP_AUTH_LATCH			(1 << 7)
+
+struct tcp_auth {
+	struct __kernel_sockaddr_storage tcpa_addr;	/* address associated */
+	__u8	tcpa_key0[TCP_AUTH_MAXKEYLEN];		/* key0 (binary) */
+	__u8	tcpa_key1[TCP_AUTH_MAXKEYLEN];		/* key1 (binary) */
+	__u8	tcpa_key0len;				/* key0 length */
+	__u8	tcpa_key1len;				/* key1 length */
+	__u8	tcpa_macfunc;				/* MAC function */
+	__u8	tcpa_flags;
 };
 
 #ifdef __KERNEL__
@@ -428,6 +458,8 @@ struct tcp_timewait_sock {
 #ifdef CONFIG_TCP_MD5SIG
 	u16			  tw_auth_keylen;
 	u8			  tw_auth_key[TCP_MD5SIG_MAXKEYLEN];
+	u8			  tw_auth_mac;
+	u8			  tw_auth_flags;
 #endif
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9903916..bee0093 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -166,6 +166,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
+#define TCPOPT_AUTH		28	/* TCP Authentication Option */
 
 /*
  *     TCP option lengths
@@ -176,6 +177,8 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERM      2
 #define TCPOLEN_TIMESTAMP      10
 #define TCPOLEN_MD5SIG         18
+#define TCPOLEN_AUTH           19	/* This is a maximum size */
+#define TCPOLEN_AUTH_MIN       15	/* This is a minimum size */
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -186,6 +189,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
 #define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_AUTH_ALIGNED		20	/* This is a maximum */
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
@@ -1048,13 +1052,17 @@ static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
 	tcp_clear_retrans_hints_partial(tp);
 }
 
-/* MD5 Signature */
-struct crypto_hash;
+#define TCP_AUTH_MAX_MAC_SIZE	16	/* Keyed MD5 sets the limit */
+#define TCP_AUTH_MAX_HASH_SIZE	20	/* SHA1 sets the limit */
 
-/* - key database */
+/* TCP Auth key database. First the common information for a key */
 struct tcp_auth_key {
-	u8			*key;
-	u8			keylen;
+	u8			*key0;
+	u8			key0len;
+	u8			*key1;
+	u8			key1len;
+	u8			mac;	/* See TCP_AUTH_* in linux/tcp.h */
+	u16			flags;	/* See TCP_AUTH_* in linux/tcp.h */
 };
 
 struct tcp4_auth_key {
@@ -1070,19 +1078,19 @@ struct tcp6_auth_key {
 	struct in6_addr		addr;
 };
 
-/* - sock block */
+/* The per socket information */
 struct tcp_auth_info {
 	struct tcp4_auth_key	*keys4;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct tcp6_auth_key	*keys6;
-	u32			entries6;
-	u32			alloced6;
+	u16			entries6;
+	u16			alloced6;
 #endif
-	u32			entries4;
-	u32			alloced4;
+	u16			entries4;
+	u16			alloced4;
 };
 
-/* - pseudo header */
+/* TCPv4 - pseudo header */
 struct tcp4_pseudohdr {
 	__be32		saddr;
 	__be32		daddr;
@@ -1107,26 +1115,35 @@ union tcp_auth_block {
 
 /* - pool: digest algorithm, hash description and scratch buffer */
 struct tcp_auth_pool {
+	struct hash_desc	*desc;
 	struct hash_desc	md5_desc;
-	union tcp_auth_block	md5_blk;
+	struct hash_desc	hmac_md5_desc;
+	struct hash_desc	hmac_sha1_desc;
+	union tcp_auth_block	auth_blk;
 };
 
-#define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
+/* This is the number of distinct addresses (IPv4 + v6) that can be configured
+ * on a single socket. Having two keys for a given address doesn't mean that it
+ * counts twice towards this limit. Also note that the allocation of the array
+ * of keys is GPF_ATOMIC, so memory pressure may limit the number of keys
+ * before this limit is hit. Since we are doing a linear search per packet,
+ * getting anywhere near this limit is a bad idea. */
+#define TCP_AUTH_MAX_KEYS	256
 
 /* - functions */
-extern int			tcp_v4_auth_hash_skb(char *md5_hash,
-						     struct tcp_md5sig_key *key,
+extern int			tcp_v4_auth_hash_skb(char *hash,
+						     struct tcp_auth_key *key,
 						     struct sock *sk,
 						     struct request_sock *req,
-						     struct sk_buff *skb);
+						     struct sk_buff *skb,
+						     int keyid);
 
-extern struct tcp_md5sig_key	*tcp_v4_auth_lookup(struct sock *sk,
+extern struct tcp_auth_key	*tcp_v4_auth_lookup(struct sock *sk,
 						    struct sock *addr_sk);
 
 extern int			tcp_v4_auth_do_add(struct sock *sk,
 						   __be32 addr,
-						   u8 *newkey,
-						   u8 newkeylen);
+						   const struct tcp_auth_key *);
 
 extern int			tcp_v4_auth_do_del(struct sock *sk,
 						   __be32 addr);
@@ -1134,8 +1151,12 @@ extern int			tcp_v4_auth_do_del(struct sock *sk,
 #ifdef CONFIG_TCP_MD5SIG
 #define tcp_twsk_auth_key(twsk)	((twsk)->tw_auth_keylen ? 		 \
 				 &(struct tcp_auth_key) {		 \
-					.key = (twsk)->tw_auth_key,	 \
-					.keylen = (twsk)->tw_auth_keylen, \
+					.key0 = (twsk)->tw_auth_key,	 \
+					.key0len = (twsk)->tw_auth_keylen, \
+					.key1 = NULL, \
+					.key1len = 0, \
+					.mac = (twsk)->tw_auth_mac, \
+					.flags = (twsk)->tw_auth_flags \
 				} : NULL)
 #else
 #define tcp_twsk_auth_key(twsk)	NULL
@@ -1146,9 +1167,47 @@ extern void			tcp_auth_free_pool(void);
 
 extern struct tcp_auth_pool	*__tcp_auth_get_pool(int cpu);
 extern void			__tcp_auth_put_pool(void);
-extern int tcp_auth_hash_header(struct tcp_auth_pool *, struct tcphdr *);
+extern int tcp_auth_hash_header(struct tcp_auth_pool *,
+				const struct tcp_auth_key *, struct tcphdr *,
+				u8 *hash);
 extern int tcp_auth_hash_skb_data(struct tcp_auth_pool *, struct sk_buff *,
-				  unsigned header_len);
+				  unsigned int header_len);
+
+extern u8 *tcp_auth_get_key(const struct tcp_auth_key *, int, int *);
+extern int tcp_auth_key_dup(struct tcp_auth_key *, const struct tcp_auth_key *);
+extern unsigned int tcp_auth_option_len(const struct tcp_auth_key *);
+extern unsigned int tcp_auth_header_word(const struct tcp_auth_key *);
+extern unsigned int tcp_auth_hash_len(const struct tcp_auth_key *);
+extern int tcp_auth_hash_init(struct tcp_auth_pool *hp,
+			      const struct tcp_auth_key *key, int keyid);
+extern int tcp_auth_hash_final(u8 *output, struct tcp_auth_pool *hp,
+			       const struct tcp_auth_key *key, int keyid);
+extern const char *tcp_auth_inbound_hash
+	(struct sk_buff *skb, struct tcp_auth_key *key,
+	 int (*hashf) (char *hash, struct tcp_auth_key *key, struct sock *sk,
+		       struct request_sock *req, struct sk_buff *skb,
+		       int keyid));
+
+static inline unsigned int tcp_auth_option_len_aligned
+	(const struct tcp_auth_key *key)
+{
+	return 4 * ((tcp_auth_option_len(key) + 3) / 4);
+}
+
+static inline int tcp_auth_option_type(const struct tcp_auth_key *key)
+{
+	return key->flags & TCP_AUTH_RFC2385 ? TCPOPT_MD5SIG : TCPOPT_AUTH;
+}
+
+static inline void tcp_auth_move_key(struct tcp_auth_key *dest,
+				     const struct tcp_auth_key *src) {
+	dest->key0 = src->key0;
+	dest->key0len = src->key0len;
+	dest->key1 = src->key1;
+	dest->key1len = src->key1len;
+	dest->mac = src->mac;
+	dest->flags = src->flags;
+}
 
 static inline
 struct tcp_auth_pool		*tcp_auth_get_pool(void)
@@ -1376,17 +1435,20 @@ struct tcp_sock_af_ops {
 	struct tcp_auth_key	*(*auth_lookup) (struct sock *sk,
 						 struct sock *addr_sk);
 	int			(*auth_calc_hash) (char *location,
-						   struct tcp_auth_key *auth,
+						   struct tcp_auth_key *key,
 						   struct sock *sk,
 						   struct request_sock *req,
-						   struct sk_buff *skb);
+						   struct sk_buff *skb,
+						   int keyid);
 	int			(*auth_add) (struct sock *sk,
 					     struct sock *addr_sk,
-					     u8 *newkey,
-					     u8 len);
+					     const struct tcp_auth_key *tmpl);
 	int			(*auth_parse) (struct sock *sk,
 					       char __user *optval,
 					       int optlen);
+	int			(*md5_parse) (struct sock *sk,
+					      char __user *optval,
+					      int optlen);
 #endif
 };
 
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 4670683..3f506a9 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -625,6 +625,8 @@ config TCP_MD5SIG
 	depends on EXPERIMENTAL
 	select CRYPTO
 	select CRYPTO_MD5
+	select CRYPTO_SHA1
+	select CRYPTO_HMAC
 	---help---
 	  RFC2385 specifies a method of giving MD5 protection to TCP sessions.
 	  Its main (only?) use is to protect BGP sessions between core routers
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 021bb72..0df118f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2157,6 +2157,10 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 #ifdef CONFIG_TCP_MD5SIG
 	case TCP_MD5SIG:
 		/* Read the IP->Key mappings from userspace */
+		err = tp->af_specific->md5_parse(sk, optval, optlen);
+		break;
+	case TCP_AUTH:
+		/* Read the IP->Key mappings from userspace */
 		err = tp->af_specific->auth_parse(sk, optval, optlen);
 		break;
 #endif
@@ -2473,6 +2477,10 @@ static void __tcp_auth_free_pool(struct tcp_auth_pool **pool)
 		if (p) {
 			if (p->md5_desc.tfm)
 				crypto_free_hash(p->md5_desc.tfm);
+			if (p->hmac_md5_desc.tfm)
+				crypto_free_hash(p->hmac_md5_desc.tfm);
+			if (p->hmac_sha1_desc.tfm)
+				crypto_free_hash(p->hmac_sha1_desc.tfm);
 			kfree(p);
 			p = NULL;
 		}
@@ -2493,7 +2501,6 @@ void tcp_auth_free_pool(void)
 	if (pool)
 		__tcp_auth_free_pool(pool);
 }
-
 EXPORT_SYMBOL(tcp_auth_free_pool);
 
 static struct tcp_auth_pool **__tcp_auth_alloc_pool(void)
@@ -2507,18 +2514,23 @@ static struct tcp_auth_pool **__tcp_auth_alloc_pool(void)
 
 	for_each_possible_cpu(cpu) {
 		struct tcp_auth_pool *p;
-		struct crypto_hash *hash;
 
 		p = kzalloc(sizeof(*p), GFP_KERNEL);
 		if (!p)
 			goto out_free;
 		*per_cpu_ptr(pool, cpu) = p;
 
-		hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
-		if (!hash || IS_ERR(hash))
+		p->md5_desc.tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+		if (!p->md5_desc.tfm || IS_ERR(p->md5_desc.tfm))
+			goto out_free;
+		p->hmac_md5_desc.tfm =
+			crypto_alloc_hash("hmac(md5)", 0, CRYPTO_ALG_ASYNC);
+		if (!p->hmac_md5_desc.tfm || IS_ERR(p->hmac_md5_desc.tfm))
+			goto out_free;
+		p->hmac_sha1_desc.tfm =
+			crypto_alloc_hash("hmac(sha1)", 0, CRYPTO_ALG_ASYNC);
+		if (!p->hmac_sha1_desc.tfm || IS_ERR(p->hmac_sha1_desc.tfm))
 			goto out_free;
-
-		p->md5_desc.tfm = hash;
 	}
 	return pool;
 out_free:
@@ -2566,7 +2578,6 @@ retry:
 	}
 	return pool;
 }
-
 EXPORT_SYMBOL(tcp_auth_alloc_pool);
 
 struct tcp_auth_pool *__tcp_auth_get_pool(int cpu)
@@ -2579,39 +2590,237 @@ struct tcp_auth_pool *__tcp_auth_get_pool(int cpu)
 	spin_unlock_bh(&tcp_auth_pool_lock);
 	return (p ? *per_cpu_ptr(p, cpu) : NULL);
 }
-
 EXPORT_SYMBOL(__tcp_auth_get_pool);
 
 void __tcp_auth_put_pool(void)
 {
 	tcp_auth_free_pool();
 }
-
 EXPORT_SYMBOL(__tcp_auth_put_pool);
 
+unsigned tcp_auth_option_len(const struct tcp_auth_key *key)
+{
+	switch (key->mac) {
+	case TCP_AUTH_KEYED_MD5_128:
+		return 18;
+	case TCP_AUTH_HMAC_MD5_96:
+	case TCP_AUTH_HMAC_SHA1_96:
+		return 15;
+	default:
+		BUG();
+		return 0;
+	}
+}
+EXPORT_SYMBOL(tcp_auth_option_len);
+
+unsigned tcp_auth_hash_len(const struct tcp_auth_key *key)
+{
+	switch (key->mac) {
+	case TCP_AUTH_KEYED_MD5_128:
+		return 16;
+	case TCP_AUTH_HMAC_MD5_96:
+	case TCP_AUTH_HMAC_SHA1_96:
+		return 12;
+	default:
+		BUG();
+		return 0;
+	}
+}
+
+/**
+ * tcp_auth_get_key - return a bytestring key
+ * @keyid: if -1, select the current transmission key. Otherwise this is either
+ * 	   0 or 1
+ * @keylen: (output) the length of the key, in bytes
+ */
+u8 *tcp_auth_get_key(const struct tcp_auth_key *key, int keyid,
+		     int *keylen)
+{
+	switch (keyid) {
+	case -1:
+		if (key->flags & TCP_AUTH_TX_KEY1) {
+			*keylen = key->key1len;
+			return key->key1;
+		} else {
+			*keylen = key->key0len;
+			return key->key0;
+		}
+	case 0:
+		*keylen = key->key0len;
+		return key->key0;
+	case 1:
+		*keylen = key->key1len;
+		return key->key1;
+	default:
+		BUG();
+		return 0;
+	}
+}
+EXPORT_SYMBOL(tcp_auth_get_key);
+
+int tcp_auth_key_dup(struct tcp_auth_key *out, const struct tcp_auth_key *in)
+{
+	u8 *key0, *key1;
+	key0 = in->key0 ?
+	       kmemdup(in->key0, in->key0len, GFP_ATOMIC) : NULL;
+	if (key0 == NULL && in->key0len)
+		return 1;
+	key1 = in->key1 ?
+	       kmemdup(in->key1, in->key1len, GFP_ATOMIC) : NULL;
+	if (key1 == NULL && in->key1len) {
+		kfree(key1);
+		return 1;
+	}
+
+	out->key0 = key0;
+	out->key0len = in->key0len;
+	out->key1 = key1;
+	out->key1len = in->key1len;
+	out->mac = in->mac;
+	out->flags = in->flags;
+
+	return 0;
+}
+EXPORT_SYMBOL(tcp_auth_key_dup);
+
+int tcp_auth_hash_init(struct tcp_auth_pool *hp, const struct tcp_auth_key *key,
+		       int keyid)
+{
+	char setkey = 0;
+	int err = 0;
+
+	switch (key->mac) {
+	case TCP_AUTH_KEYED_MD5_128:
+		hp->desc = &hp->md5_desc;
+		break;
+	case TCP_AUTH_HMAC_MD5_96:
+		hp->desc = &hp->hmac_md5_desc;
+		setkey = 1;
+		break;
+	case TCP_AUTH_HMAC_SHA1_96:
+		hp->desc = &hp->hmac_sha1_desc;
+		setkey = 1;
+		break;
+	default:
+		BUG();
+	}
+
+	err = crypto_hash_init(hp->desc);
+	if (err)
+		return err;
+	if (setkey) {
+		int keylen;
+		u8 *keybytes = tcp_auth_get_key(key, keyid, &keylen);
+		err = crypto_hash_setkey(hp->desc->tfm, keybytes, keylen);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(tcp_auth_hash_init);
+
+int tcp_auth_hash_final(u8 *output, struct tcp_auth_pool *hp,
+			const struct tcp_auth_key *key, int keyid)
+{
+	u8 temp[TCP_AUTH_MAX_HASH_SIZE];
+	struct scatterlist sg;
+	int err = 0, keylen;
+	u8 *keybytes;
+
+	switch (key->mac) {
+	case TCP_AUTH_KEYED_MD5_128:
+		keybytes = tcp_auth_get_key(key, keyid, &keylen);
+		sg_init_one(&sg, keybytes, keylen);
+		err = crypto_hash_update(hp->desc, &sg, keylen);
+		if (err)
+			return err;
+		err = crypto_hash_final(hp->desc, output);
+		break;
+	case TCP_AUTH_HMAC_MD5_96:
+		err = crypto_hash_final(hp->desc, temp);
+		memcpy(output, temp, 12);
+		break;
+	case TCP_AUTH_HMAC_SHA1_96:
+		err = crypto_hash_final(hp->desc, temp);
+		memcpy(output, temp, 12);
+		break;
+	default:
+		BUG();
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(tcp_auth_hash_final);
+
+__be32 tcp_auth_header_word(const struct tcp_auth_key *key)
+{
+	if (key->flags & TCP_AUTH_RFC2385) {
+		return htonl((TCPOPT_NOP << 24) |
+			     (TCPOPT_NOP << 16) |
+			     (TCPOPT_MD5SIG << 8) |
+			     TCPOLEN_MD5SIG);
+	}
+
+	return htonl((TCPOPT_NOP << 24) |
+		     (TCPOPT_AUTH << 16) |
+		     (tcp_auth_option_len(key) << 8) |
+		     (key->flags & TCP_AUTH_TX_KEY1 ? 1 : 0));
+}
+EXPORT_SYMBOL(tcp_auth_header_word);
+
+/**
+ * tcp_auth_hash_header - update a hash to include a TCP header
+ *
+ * @hp: this CPU's pool entry, with ->desc set correctly
+ * @th: the beginning of the TCP header with options following
+ * @hash: a pointer into the TCP header where the hash will live. In some cases
+ *        this needs to be zeroed out
+ */
 int tcp_auth_hash_header(struct tcp_auth_pool *hp,
-			 struct tcphdr *th)
+			 const struct tcp_auth_key *key,
+			 struct tcphdr *th, u8 *hash)
 {
 	struct scatterlist sg;
 	int err;
+	__sum16 old_checksum;
+	__be16 old_sport = 0, old_dport = 0;
+	int len;
+
+	if (key->flags & TCP_AUTH_OPTIONS_EXCLUDE) {
+		len = sizeof(struct tcphdr);
+	} else {
+		len = th->doff << 2;
+		memset(hash, 0, tcp_auth_hash_len(key));
+	}
 
-	__sum16 old_checksum = th->check;
+	old_checksum = th->check;
 	th->check = 0;
-	/* options aren't included in the hash */
-	sg_init_one(&sg, th, sizeof(struct tcphdr));
-	err = crypto_hash_update(&hp->md5_desc, &sg, sizeof(struct tcphdr));
+	if (key->flags & TCP_AUTH_PORT_NUMS_EXCLUDE) {
+		old_sport = th->source;
+		old_dport = th->dest;
+		th->source = th->dest = __constant_cpu_to_be16(0);
+	}
+	sg_init_one(&sg, th, len);
+	err = crypto_hash_update(hp->desc, &sg, len);
 	th->check = old_checksum;
+	if (key->flags & TCP_AUTH_PORT_NUMS_EXCLUDE) {
+		th->source = old_sport;
+		th->dest = old_dport;
+	}
 	return err;
 }
-
 EXPORT_SYMBOL(tcp_auth_hash_header);
 
+/**
+ * tcp_auth_hash_skb_data - update a hash with the payload contents of a packet
+ *
+ * @hp: the current CPU's pool entry with ->desc set
+ * @header_len: number of bytes after which lies payload data
+ */
 int tcp_auth_hash_skb_data(struct tcp_auth_pool *hp,
 			   struct sk_buff *skb, unsigned header_len)
 {
 	struct scatterlist sg;
 	const struct tcphdr *tp = tcp_hdr(skb);
-	struct hash_desc *desc = &hp->md5_desc;
 	unsigned i;
 	const unsigned head_data_len = skb_headlen(skb) > header_len ?
 				       skb_headlen(skb) - header_len : 0;
@@ -2620,30 +2829,88 @@ int tcp_auth_hash_skb_data(struct tcp_auth_pool *hp,
 	sg_init_table(&sg, 1);
 
 	sg_set_buf(&sg, ((u8 *) tp) + header_len, head_data_len);
-	if (crypto_hash_update(desc, &sg, head_data_len))
+	if (crypto_hash_update(hp->desc, &sg, head_data_len))
 		return 1;
 
 	for (i = 0; i < shi->nr_frags; ++i) {
 		const struct skb_frag_struct *f = &shi->frags[i];
 		sg_set_page(&sg, f->page, f->size, f->page_offset);
-		if (crypto_hash_update(desc, &sg, f->size))
+		if (crypto_hash_update(hp->desc, &sg, f->size))
 			return 1;
 	}
 
 	return 0;
 }
-
 EXPORT_SYMBOL(tcp_auth_hash_skb_data);
 
-int tcp_auth_hash_key(struct tcp_auth_pool *hp, struct tcp_auth_key *key)
+/**
+ * tcp_auth_inbound_hash - check hash on inbound packet
+ *
+ * @skb: packet with a TCP header
+ * @key: (maybe NULL) the auth key associated with this connection
+ * @hashf: the IPv4/6 specific packet hashing function
+ *
+ * returns either NULL (accept packet) or a pointer to a debug string which is
+ * expected to be ratelimt printk'ed.
+ */
+const char *tcp_auth_inbound_hash
+	(struct sk_buff *skb, struct tcp_auth_key *key,
+	 int (*hashf) (char *hash, struct tcp_auth_key *key, struct sock *sk,
+		       struct request_sock *req, struct sk_buff *skb,
+		       int keyid))
 {
-	struct scatterlist sg;
+	struct tcphdr *th = tcp_hdr(skb);
+	int genhash, keyid;
+	u8 *option;
+	u8 hash[TCP_AUTH_MAX_MAC_SIZE], orighash[TCP_AUTH_MAX_MAC_SIZE];
 
-	sg_init_one(&sg, key->key, key->keylen);
-	return crypto_hash_update(&hp->md5_desc, &sg, key->keylen);
-}
+	option = tcp_auth_parse_option(th);
+
+	if (!key && !option)
+		return NULL;
 
-EXPORT_SYMBOL(tcp_md5_hash_key);
+	if (key && !option) {
+		if (key->flags & TCP_AUTH_LATCH)
+			return NULL;
+		return "Auth option expected but NOT found";
+	}
+
+	if (!key && option)
+		return "Auth option NOT expected but found";
+
+	if (*option != tcp_auth_option_type(key))
+		return "Auth option of wrong type";
+	option++;
+
+	if (*option != tcp_auth_option_len(key))
+		return "Auth option found with wrong size";
+	option++;
+
+	if (key->flags & TCP_AUTH_RFC2385)
+		keyid = 0;
+	else
+		keyid = *option++;
+
+	if (keyid > 1 ||
+	    (keyid == 0 && !(key->flags & TCP_AUTH_ALLOW_KEY0)) ||
+	    (keyid == 1 && !(key->flags & TCP_AUTH_ALLOW_KEY1)))
+		return "Auth option using unconfigured key";
+
+	/* check the signature */
+	memcpy(orighash, option, tcp_auth_hash_len(key));
+	memset(option, 0, tcp_auth_hash_len(key));
+	genhash = hashf(hash, key, NULL, NULL, skb, keyid);
+	memcpy(option, orighash, tcp_auth_hash_len(key));
+
+	if (genhash)
+		return "TCP Auth: dropping packet because of internal failure";
+	if (memcmp(option, hash, tcp_auth_hash_len(key)) != 0)
+		return "TCP Auth: verification failure";
+
+	key->flags &= ~((u16) TCP_AUTH_LATCH);
+	return NULL;
+}
+EXPORT_SYMBOL(tcp_auth_inbound_hash);
 
 #endif
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f89c4c5..e17162d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3465,8 +3465,10 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 }
 
 #ifdef CONFIG_TCP_MD5SIG
-/*
- * Parse MD5 Signature option
+/**
+ * tcp_auth_parse_option - extract an MD5 or Auth option from a header
+ *
+ * Returns a pointer to the beginning of the option (i.e. optname byte)
  */
 u8 *tcp_auth_parse_option(struct tcphdr *th)
 {
@@ -3474,7 +3476,7 @@ u8 *tcp_auth_parse_option(struct tcphdr *th)
 	u8 *ptr = (u8*)(th + 1);
 
 	/* If the TCP option is too short, we can short cut */
-	if (length < TCPOLEN_MD5SIG)
+	if (length < TCPOLEN_AUTH_MIN)
 		return NULL;
 
 	while (length > 0) {
@@ -3491,8 +3493,9 @@ u8 *tcp_auth_parse_option(struct tcphdr *th)
 			opsize = *ptr++;
 			if (opsize < 2 || opsize > length)
 				return NULL;
-			if (opcode == TCPOPT_MD5SIG)
-				return ptr;
+			if (opcode == TCPOPT_MD5SIG ||
+			    opcode == TCPOPT_AUTH)
+				return ptr - 2;
 		}
 		ptr += opsize - 2;
 		length -= opsize;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8282634..b37959f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -88,7 +88,7 @@ int sysctl_tcp_low_latency __read_mostly;
 static struct tcp_auth_key *tcp_v4_auth_do_lookup(struct sock *sk,
 						  __be32 addr);
 static int tcp_v4_auth_hash_hdr(char *hash, struct tcp_auth_key *key,
-			        __be32 daddr, __be32 saddr, struct tcphdr *th);
+				__be32 daddr, __be32 saddr, struct tcphdr *th);
 #else
 static inline
 struct tcp_auth_key *tcp_v4_auth_do_lookup(struct sock *sk, __be32 addr)
@@ -536,7 +536,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	struct {
 		struct tcphdr th;
 #ifdef CONFIG_TCP_MD5SIG
-		__be32 opt[(TCPOLEN_MD5SIG_ALIGNED >> 2)];
+		__be32 opt[(TCPOLEN_AUTH_ALIGNED >> 2)];
 #endif
 	} rep;
 	struct ip_reply_arg arg;
@@ -574,12 +574,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 #ifdef CONFIG_TCP_MD5SIG
 	key = sk ? tcp_v4_auth_do_lookup(sk, ip_hdr(skb)->daddr) : NULL;
 	if (key) {
-		rep.opt[0] = htonl((TCPOPT_NOP << 24) |
-				   (TCPOPT_NOP << 16) |
-				   (TCPOPT_MD5SIG << 8) |
-				   TCPOLEN_MD5SIG);
+		rep.opt[0] = tcp_auth_header_word(key);
 		/* Update length and the length the header thinks exists */
-		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
+		arg.iov[0].iov_len += tcp_auth_option_len_aligned(key);
 		rep.th.doff = arg.iov[0].iov_len / 4;
 
 		tcp_v4_auth_hash_hdr((__u8 *) &rep.opt[1],
@@ -613,7 +610,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 		struct tcphdr th;
 		__be32 opt[(TCPOLEN_TSTAMP_ALIGNED >> 2)
 #ifdef CONFIG_TCP_MD5SIG
-			   + (TCPOLEN_MD5SIG_ALIGNED >> 2)
+			   + (TCPOLEN_AUTH_ALIGNED >> 2)
 #endif
 			];
 	} rep;
@@ -647,11 +644,8 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 	if (key) {
 		int offset = (ts) ? 3 : 0;
 
-		rep.opt[offset++] = htonl((TCPOPT_NOP << 24) |
-					  (TCPOPT_NOP << 16) |
-					  (TCPOPT_MD5SIG << 8) |
-					  TCPOLEN_MD5SIG);
-		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
+		rep.opt[offset++] = tcp_auth_header_word(key);
+		arg.iov[0].iov_len += tcp_auth_option_len_aligned(key);
 		rep.th.doff = arg.iov[0].iov_len/4;
 
 		tcp_v4_auth_hash_hdr((__u8 *) &rep.opt[offset],
@@ -794,6 +788,7 @@ static struct ip_options *tcp_v4_save_options(struct sock *sk,
 static struct tcp_auth_key *tcp_v4_auth_do_lookup(struct sock *sk, __be32 addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_auth_key *wildcard_ret = NULL;
 	int i;
 
 	if (!tp->auth_info || !tp->auth_info->entries4)
@@ -801,8 +796,11 @@ static struct tcp_auth_key *tcp_v4_auth_do_lookup(struct sock *sk, __be32 addr)
 	for (i = 0; i < tp->auth_info->entries4; i++) {
 		if (tp->auth_info->keys4[i].addr == addr)
 			return &tp->auth_info->keys4[i].base;
+		else if (tp->auth_info->keys4[i].addr == 0)
+			wildcard_ret = &tp->auth_info->keys4[i].base;
 	}
-	return NULL;
+
+	return wildcard_ret;
 }
 
 struct tcp_auth_key *tcp_v4_auth_lookup(struct sock *sk,
@@ -810,7 +808,6 @@ struct tcp_auth_key *tcp_v4_auth_lookup(struct sock *sk,
 {
 	return tcp_v4_auth_do_lookup(sk, inet_sk(addr_sk)->daddr);
 }
-
 EXPORT_SYMBOL(tcp_v4_auth_lookup);
 
 static struct tcp_auth_key *tcp_v4_reqsk_auth_lookup(struct sock *sk,
@@ -821,19 +818,28 @@ static struct tcp_auth_key *tcp_v4_reqsk_auth_lookup(struct sock *sk,
 
 /* This can be called on a newly created socket, from other files */
 int tcp_v4_auth_do_add(struct sock *sk, __be32 addr,
-		       u8 *newkey, u8 newkeylen)
+		       const struct tcp_auth_key *tmpl)
 {
 	/* Add Key to the list */
-	struct tcp_auth_key *key;
+	struct tcp_auth_key *key = NULL;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp4_auth_key *keys;
+	int i, err = 0;
+
+	if (tp->auth_info && tp->auth_info->entries4) {
+		for (i = 0; i < tp->auth_info->entries4; i++) {
+			if (tp->auth_info->keys4[i].addr == addr) {
+				key = &tp->auth_info->keys4[i].base;
+				break;
+			}
+		}
+	}
 
-	key = tcp_v4_auth_do_lookup(sk, addr);
 	if (key) {
 		/* Pre-existing entry - just update that one. */
-		kfree(key->key);
-		key->key = newkey;
-		key->keylen = newkeylen;
+		kfree(key->key0);
+		kfree(key->key1);
+		tcp_auth_move_key(key, tmpl);
 	} else {
 		struct tcp_auth_info *auth;
 
@@ -841,24 +847,30 @@ int tcp_v4_auth_do_add(struct sock *sk, __be32 addr,
 			tp->auth_info = kzalloc(sizeof(*tp->auth_info),
 						GFP_ATOMIC);
 			if (!tp->auth_info) {
-				kfree(newkey);
-				return -ENOMEM;
+				err = -ENOMEM;
+				goto out;
 			}
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		}
+
+		auth = tp->auth_info;
+		if (auth->entries4 + 1 > TCP_AUTH_MAX_KEYS) {
+			err = -ENOSPC;
+			goto out;
+		}
+
 		if (tcp_auth_alloc_pool() == NULL) {
-			kfree(newkey);
-			return -ENOMEM;
+			err = -ENOMEM;
+			goto out;
 		}
-		auth = tp->auth_info;
 
 		if (auth->alloced4 == auth->entries4) {
 			keys = kmalloc((sizeof(*keys) *
 					(auth->entries4 + 1)), GFP_ATOMIC);
 			if (!keys) {
-				kfree(newkey);
 				tcp_auth_free_pool();
-				return -ENOMEM;
+				err = -ENOMEM;
+				goto out;
 			}
 
 			if (auth->entries4)
@@ -871,20 +883,22 @@ int tcp_v4_auth_do_add(struct sock *sk, __be32 addr,
 			auth->alloced4++;
 		}
 		auth->entries4++;
-		auth->keys4[auth->entries4 - 1].addr        = addr;
-		auth->keys4[auth->entries4 - 1].base.key    = newkey;
-		auth->keys4[auth->entries4 - 1].base.keylen = newkeylen;
+		auth->keys4[auth->entries4 - 1].addr         = addr;
+		tcp_auth_move_key(&auth->keys4[auth->entries4 - 1].base, tmpl);
 	}
 	return 0;
-}
 
+out:
+	kfree(tmpl->key0);
+	kfree(tmpl->key1);
+	return err;
+}
 EXPORT_SYMBOL(tcp_v4_auth_do_add);
 
 static int tcp_v4_auth_add_func(struct sock *sk, struct sock *addr_sk,
-			        u8 *newkey, u8 newkeylen)
+				const struct tcp_auth_key *tmpl)
 {
-	return tcp_v4_auth_do_add(sk, inet_sk(addr_sk)->daddr,
-				  newkey, newkeylen);
+	return tcp_v4_auth_do_add(sk, inet_sk(addr_sk)->daddr, tmpl);
 }
 
 int tcp_v4_auth_do_del(struct sock *sk, __be32 addr)
@@ -895,7 +909,8 @@ int tcp_v4_auth_do_del(struct sock *sk, __be32 addr)
 	for (i = 0; i < tp->auth_info->entries4; i++) {
 		if (tp->auth_info->keys4[i].addr == addr) {
 			/* Free the key */
-			kfree(tp->auth_info->keys4[i].base.key);
+			kfree(tp->auth_info->keys4[i].base.key0);
+			kfree(tp->auth_info->keys4[i].base.key1);
 			tp->auth_info->entries4--;
 
 			if (tp->auth_info->entries4 == 0) {
@@ -915,7 +930,6 @@ int tcp_v4_auth_do_del(struct sock *sk, __be32 addr)
 	}
 	return -ENOENT;
 }
-
 EXPORT_SYMBOL(tcp_v4_auth_do_del);
 
 static void tcp_v4_auth_clear_list(struct sock *sk)
@@ -928,8 +942,10 @@ static void tcp_v4_auth_clear_list(struct sock *sk)
 	 */
 	if (tp->auth_info->entries4) {
 		int i;
-		for (i = 0; i < tp->auth_info->entries4; i++)
-			kfree(tp->auth_info->keys4[i].base.key);
+		for (i = 0; i < tp->auth_info->entries4; i++) {
+			kfree(tp->auth_info->keys4[i].base.key0);
+			kfree(tp->auth_info->keys4[i].base.key1);
+		}
 		tp->auth_info->entries4 = 0;
 		tcp_auth_free_pool();
 	}
@@ -940,47 +956,102 @@ static void tcp_v4_auth_clear_list(struct sock *sk)
 	}
 }
 
-static int tcp_v4_auth_parse_keys(struct sock *sk, char __user *optval,
-				  int optlen)
+static int tcp_v4_auth_parse(struct sock *sk, struct tcp_auth *cmd)
 {
-	struct tcp_auth cmd;
-	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
-	u8 *newkey;
-
-	if (optlen < sizeof(cmd))
-		return -EINVAL;
-
-	if (copy_from_user(&cmd, optval, sizeof(cmd)))
-		return -EFAULT;
+	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd->tcpa_addr;
+	struct tcp_auth_key key;
 
 	if (sin->sin_family != AF_INET)
 		return -EINVAL;
 
-	if (!cmd.tcpm_key || !cmd.tcpm_keylen) {
+	if (!cmd->tcpa_key0len && !cmd->tcpa_key1len) {
 		if (!tcp_sk(sk)->auth_info)
 			return -ENOENT;
 		return tcp_v4_auth_do_del(sk, sin->sin_addr.s_addr);
 	}
 
-	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
+	if (cmd->tcpa_flags & TCP_AUTH_RFC2385) {
+		cmd->tcpa_flags = TCP_AUTH_RFC2385 | TCP_AUTH_ALLOW_KEY0 |
+				  TCP_AUTH_OPTIONS_EXCLUDE;
+		cmd->tcpa_key1len = 0;
+		cmd->tcpa_macfunc = TCP_AUTH_KEYED_MD5_128;
+	}
+
+	if (cmd->tcpa_macfunc > TCP_AUTH_MAX_MAC)
+		return -EPROTONOSUPPORT;
+
+	if (cmd->tcpa_key0len > TCP_AUTH_MAXKEYLEN ||
+	    cmd->tcpa_key1len > TCP_AUTH_MAXKEYLEN)
 		return -EINVAL;
 
 	if (!tcp_sk(sk)->auth_info) {
 		struct tcp_sock *tp = tcp_sk(sk);
+		/* FIXME: shouldn't this be GPF_ATOMIC if the lock is held? */
 		struct tcp_auth_info *p = kzalloc(sizeof(*p), GFP_KERNEL);
 
 		if (!p)
-			return -EINVAL;
+			return -ENOMEM;
 
 		tp->auth_info = p;
 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 
-	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
-	if (!newkey)
+	key.key0 = cmd->tcpa_key0len ?
+		   kmemdup(cmd->tcpa_key0, cmd->tcpa_key0len, GFP_KERNEL) :
+		   NULL;
+	if (!key.key0 && cmd->tcpa_key0len)
+		return -ENOMEM;
+	key.key1 = cmd->tcpa_key1len ?
+		   kmemdup(cmd->tcpa_key1, cmd->tcpa_key1len, GFP_KERNEL) :
+		   NULL;
+	if (!key.key1 && cmd->tcpa_key1len) {
+		kfree(key.key0);
 		return -ENOMEM;
-	return tcp_v4_auth_do_add(sk, sin->sin_addr.s_addr,
-				  newkey, cmd.tcpm_keylen);
+	}
+
+	key.key0len = cmd->tcpa_key0len;
+	key.key1len = cmd->tcpa_key1len;
+	key.mac = cmd->tcpa_macfunc;
+	key.flags = cmd->tcpa_flags;
+
+	return tcp_v4_auth_do_add(sk, sin->sin_addr.s_addr, &key);
+}
+
+static int tcp_v4_auth_parse_keys(struct sock *sk, char __user *optval,
+				  int optlen)
+{
+	struct tcp_auth cmd;
+
+	if (optlen < sizeof(cmd))
+		return -EINVAL;
+
+	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+		return -EFAULT;
+
+	return tcp_v4_auth_parse(sk, &cmd);
+}
+
+static int tcp_v4_md5_parse_keys(struct sock *sk, char __user *optval,
+				 int optlen)
+{
+	struct tcp_md5sig cmd;
+	struct tcp_auth tcpa;
+
+	if (optlen < sizeof(cmd))
+		return -EINVAL;
+
+	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+		return -EFAULT;
+
+	memcpy(tcpa.tcpa_key0, cmd.tcpm_key,
+	       min_t(unsigned, TCP_MD5SIG_MAXKEYLEN, TCP_AUTH_MAXKEYLEN));
+	memcpy(&tcpa.tcpa_addr, &cmd.tcpm_addr, sizeof(tcpa.tcpa_addr));
+	tcpa.tcpa_key0len = cmd.tcpm_keylen;
+	tcpa.tcpa_key1len = 0;
+	tcpa.tcpa_flags = TCP_AUTH_RFC2385;
+	tcpa.tcpa_macfunc = TCP_AUTH_KEYED_MD5_128;
+
+	return tcp_v4_auth_parse(sk, &tcpa);
 }
 
 static int tcp_v4_auth_hash_pseudoheader(struct tcp_auth_pool *hp,
@@ -1003,29 +1074,28 @@ static int tcp_v4_auth_hash_pseudoheader(struct tcp_auth_pool *hp,
 	bp->len = cpu_to_be16(nbytes);
 
 	sg_init_one(&sg, bp, sizeof(*bp));
-	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
+	return crypto_hash_update(hp->desc, &sg, sizeof(*bp));
 }
 
 static int tcp_v4_auth_hash_hdr(char *hash, struct tcp_auth_key *key,
 				__be32 daddr, __be32 saddr, struct tcphdr *th)
 {
 	struct tcp_auth_pool *hp;
-	struct hash_desc *desc;
 
 	hp = tcp_auth_get_pool();
 	if (!hp)
 		goto clear_hash_noput;
-	desc = &hp->md5_desc;
 
-	if (crypto_hash_init(desc))
-		goto clear_hash;
-	if (tcp_v4_auth_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
-		goto clear_hash;
-	if (tcp_auth_hash_header(hp, th))
+	if (tcp_auth_hash_init(hp, key, -1))
 		goto clear_hash;
-	if (tcp_auth_hash_key(hp, key))
+	if (!(key->flags & TCP_AUTH_PSEUDOHEADER_EXCLUDE)) {
+		if (tcp_v4_auth_hash_pseudoheader(hp, daddr, saddr,
+						  th->doff << 2))
+			goto clear_hash;
+	}
+	if (tcp_auth_hash_header(hp, key, th, hash))
 		goto clear_hash;
-	if (crypto_hash_final(desc, hash))
+	if (tcp_auth_hash_final(hash, hp, key, -1))
 		goto clear_hash;
 
 	tcp_auth_put_pool();
@@ -1034,16 +1104,15 @@ static int tcp_v4_auth_hash_hdr(char *hash, struct tcp_auth_key *key,
 clear_hash:
 	tcp_auth_put_pool();
 clear_hash_noput:
-	memset(hash, 0, 16);
+	memset(hash, 0, tcp_auth_hash_len(key));
 	return 1;
 }
 
 int tcp_v4_auth_hash_skb(char *hash, struct tcp_auth_key *key,
 			 struct sock *sk, struct request_sock *req,
-			 struct sk_buff *skb)
+			 struct sk_buff *skb, int keyid)
 {
 	struct tcp_auth_pool *hp;
-	struct hash_desc *desc;
 	struct tcphdr *th = tcp_hdr(skb);
 	__be32 saddr, daddr;
 
@@ -1062,20 +1131,19 @@ int tcp_v4_auth_hash_skb(char *hash, struct tcp_auth_key *key,
 	hp = tcp_auth_get_pool();
 	if (!hp)
 		goto clear_hash_noput;
-	desc = &hp->md5_desc;
 
-	if (crypto_hash_init(desc))
+	if (tcp_auth_hash_init(hp, key, keyid))
 		goto clear_hash;
 
-	if (tcp_v4_auth_hash_pseudoheader(hp, daddr, saddr, skb->len))
-		goto clear_hash;
-	if (tcp_auth_hash_header(hp, th))
+	if (!(key->flags & TCP_AUTH_PSEUDOHEADER_EXCLUDE)) {
+		if (tcp_v4_auth_hash_pseudoheader(hp, daddr, saddr, skb->len))
+			goto clear_hash;
+	}
+	if (tcp_auth_hash_header(hp, key, th, hash))
 		goto clear_hash;
 	if (tcp_auth_hash_skb_data(hp, skb, th->doff << 2))
 		goto clear_hash;
-	if (tcp_auth_hash_key(hp, key))
-		goto clear_hash;
-	if (crypto_hash_final(desc, hash))
+	if (tcp_auth_hash_final(hash, hp, key, keyid))
 		goto clear_hash;
 
 	tcp_auth_put_pool();
@@ -1084,69 +1152,28 @@ int tcp_v4_auth_hash_skb(char *hash, struct tcp_auth_key *key,
 clear_hash:
 	tcp_auth_put_pool();
 clear_hash_noput:
-	memset(hash, 0, 16);
+	memset(hash, 0, tcp_auth_hash_len(key));
 	return 1;
 }
-
 EXPORT_SYMBOL(tcp_v4_auth_hash_skb);
 
 static int tcp_v4_auth_inbound_hash(struct sock *sk, struct sk_buff *skb)
 {
-	/*
-	 * This gets called for each TCP segment that arrives
-	 * so we want to be efficient.
-	 * We have 3 drop cases:
-	 * o No MD5 hash and one expected.
-	 * o MD5 hash and we're not expecting one.
-	 * o MD5 hash and its wrong.
-	 */
-	__u8 *hash_location = NULL;
-	struct tcp_auth_key *hash_expected;
 	const struct iphdr *iph = ip_hdr(skb);
-	struct tcphdr *th = tcp_hdr(skb);
-	int genhash;
-	unsigned char newhash[16];
-
-	hash_expected = tcp_v4_auth_do_lookup(sk, iph->saddr);
-	hash_location = tcp_auth_parse_option(th);
-
-	/* We've parsed the options - do we have a hash? */
-	if (!hash_expected && !hash_location)
-		return 0;
-
-	if (hash_expected && !hash_location) {
-		LIMIT_NETDEBUG(KERN_INFO "MD5 Hash expected but NOT found "
-			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
-			       NIPQUAD(iph->saddr), ntohs(th->source),
-			       NIPQUAD(iph->daddr), ntohs(th->dest));
-		return 1;
-	}
+	const struct tcphdr *th = tcp_hdr(skb);
+	struct tcp_auth_key *key = tcp_v4_auth_do_lookup(sk, iph->saddr);
+	const char *errormsg =
+		tcp_auth_inbound_hash(skb, key, tcp_v4_auth_hash_skb);
 
-	if (!hash_expected && hash_location) {
-		LIMIT_NETDEBUG(KERN_INFO "MD5 Hash NOT expected but found "
+	if (errormsg) {
+		LIMIT_NETDEBUG(KERN_INFO "%s "
 			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
+			       errormsg,
 			       NIPQUAD(iph->saddr), ntohs(th->source),
 			       NIPQUAD(iph->daddr), ntohs(th->dest));
 		return 1;
 	}
 
-	/* Okay, so this is hash_expected and hash_location -
-	 * so we need to calculate the checksum.
-	 */
-	genhash = tcp_v4_auth_hash_skb(newhash,
-				      hash_expected,
-				      NULL, NULL, skb);
-
-	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash failed for "
-			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)%s\n",
-			       NIPQUAD(iph->saddr), ntohs(th->source),
-			       NIPQUAD(iph->daddr), ntohs(th->dest),
-			       genhash ? " tcp_v4_auth_hash_skb failed" : "");
-		}
-		return 1;
-	}
 	return 0;
 }
 
@@ -1380,11 +1407,12 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 * memory, then we end up not copying the key
 		 * across. Shucks.
 		 */
-		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
-		if (newkey != NULL)
-			tcp_v4_auth_do_add(newsk, inet_sk(sk)->daddr,
-					   newkey, key->keylen);
-		newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+		struct tcp_auth_key newkey;
+
+		if (tcp_auth_key_dup(&newkey, key) == 0) {
+			tcp_v4_auth_do_add(newsk, inet_sk(sk)->daddr, &newkey);
+			newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+		}
 	}
 #endif
 
@@ -1751,6 +1779,7 @@ static struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
 	.auth_calc_hash		= tcp_v4_auth_hash_skb,
 	.auth_add		= tcp_v4_auth_add_func,
 	.auth_parse		= tcp_v4_auth_parse_keys,
+	.md5_parse		= tcp_v4_md5_parse_keys,
 };
 #endif
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6f282d6..d820fbc 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -319,8 +319,13 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			tcptw->tw_auth_keylen = 0;
 			key = tp->af_specific->auth_lookup(sk, sk);
 			if (key != NULL) {
-				memcpy(&tcptw->tw_auth_key, key->key, key->keylen);
-				tcptw->tw_auth_keylen = key->keylen;
+				int keylen;
+				const u8 *keybytes =
+					tcp_auth_get_key(key, -1, &keylen);
+				memcpy(&tcptw->tw_auth_key, keybytes, keylen);
+				tcptw->tw_auth_keylen = keylen;
+				tcptw->tw_auth_mac = key->mac;
+				tcptw->tw_auth_flags = key->flags;
 				if (tcp_auth_alloc_pool() == NULL)
 					BUG();
 			}
@@ -669,14 +674,13 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 				 * newsk structure. If we fail to get memory then we
 				 * end up not copying the key across. Shucks.
 				 */
-				char *newkey = kmemdup(key->key, key->keylen,
-						       GFP_ATOMIC);
-				if (newkey) {
+				struct tcp_auth_key newkey;
+
+				if (tcp_auth_key_dup(&newkey, key) == 0) {
 					if (!tcp_auth_alloc_pool())
 						BUG();
 					tp->af_specific->auth_add(child, child,
-								  newkey,
-								  key->keylen);
+								  &newkey);
 				}
 			}
 		}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4fe610f..dcfc668 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -347,7 +347,7 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 
 #define OPTION_SACK_ADVERTISE	(1 << 0)
 #define OPTION_TS		(1 << 1)
-#define OPTION_MD5		(1 << 2)
+#define OPTION_AUTH		(1 << 2)
 
 struct tcp_out_options {
 	u8 options;		/* bit field of OPTION_* */
@@ -359,14 +359,12 @@ struct tcp_out_options {
 
 static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 			      const struct tcp_out_options *opts,
-			      __u8 **hash) {
-	if (unlikely(OPTION_MD5 & opts->options)) {
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_MD5SIG << 8) |
-			       TCPOLEN_MD5SIG);
-		*hash = (__u8 *)ptr;
-		ptr += 4;
+			      struct tcp_auth_key *key, __u8 **hash)
+{
+	if (unlikely(OPTION_AUTH & opts->options)) {
+		*ptr = tcp_auth_header_word(key);
+		*hash = (__u8 *)(ptr + 1);
+		ptr += tcp_auth_option_len_aligned(key) / 4;
 	} else {
 		*hash = NULL;
 	}
@@ -441,8 +439,8 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 #ifdef CONFIG_TCP_MD5SIG
 	*key = tp->af_specific->auth_lookup(sk, sk);
 	if (*key) {
-		opts->options |= OPTION_MD5;
-		size += TCPOLEN_MD5SIG_ALIGNED;
+		opts->options |= OPTION_AUTH;
+		size += tcp_auth_option_len_aligned(*key);
 	}
 #else
 	*key = NULL;
@@ -460,7 +458,8 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	opts->mss = tcp_advertise_mss(sk);
 	size += TCPOLEN_MSS_ALIGNED;
 
-	if (likely(sysctl_tcp_timestamps && *key == NULL)) {
+	if (likely(sysctl_tcp_timestamps &&
+		   (*key == NULL || tcp_auth_option_len_aligned(*key) <= 16))) {
 		opts->options |= OPTION_TS;
 		opts->tsval = TCP_SKB_CB(skb)->when;
 		opts->tsecr = tp->rx_opt.ts_recent;
@@ -491,8 +490,8 @@ static unsigned tcp_synack_options(struct sock *sk,
 #ifdef CONFIG_TCP_MD5SIG
 	*key = tcp_rsk(req)->af_specific->auth_lookup(sk, req);
 	if (*key) {
-		opts->options |= OPTION_MD5;
-		size += TCPOLEN_MD5SIG_ALIGNED;
+		opts->options |= OPTION_AUTH;
+		size += tcp_auth_option_len_aligned(*key);
 	}
 #else
 	*key = NULL;
@@ -501,8 +500,11 @@ static unsigned tcp_synack_options(struct sock *sk,
 	/* we can't fit any SACK blocks in a packet with MD5 + TS
 	   options. There was discussion about disabling SACK rather than TS in
 	   order to fit in better with old, buggy kernels, but that was deemed
-	   to be unnecessary. */
-	doing_ts = ireq->tstamp_ok && !(*key && ireq->sack_ok);
+	   to be unnecessary. With TCP Auth, if the MAC is small enough we can
+	   still do it, however */
+	doing_ts = ireq->tstamp_ok &&
+		   !(*key && tcp_auth_option_len_aligned(*key) > 16 &&
+		     ireq->sack_ok);
 
 	opts->mss = mss;
 	size += TCPOLEN_MSS_ALIGNED;
@@ -536,8 +538,8 @@ static unsigned tcp_established_options(struct sock *sk, struct sk_buff *skb,
 #ifdef CONFIG_TCP_MD5SIG
 	*key = tp->af_specific->auth_lookup(sk, sk);
 	if (unlikely(*key)) {
-		opts->options |= OPTION_MD5;
-		size += TCPOLEN_MD5SIG_ALIGNED;
+		opts->options |= OPTION_AUTH;
+		size += tcp_auth_option_len_aligned(*key);
 	}
 #else
 	*key = NULL;
@@ -650,16 +652,16 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		th->urg			= 1;
 	}
 
-	tcp_options_write((__be32 *)(th + 1), tp, &opts, &hash_location);
+	tcp_options_write((__be32 *)(th + 1), tp, &opts, key, &hash_location);
 	if (likely((tcb->flags & TCPCB_FLAG_SYN) == 0))
 		TCP_ECN_send(sk, skb, tcp_header_size);
 
 #ifdef CONFIG_TCP_MD5SIG
-	/* Calculate the MD5 hash, as we have all we need now */
+	/* Calculate the auth hash, as we have all we need now */
 	if (key) {
 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		tp->af_specific->auth_calc_hash(hash_location,
-						key, sk, NULL, skb);
+						key, sk, NULL, skb, -1);
 	}
 #endif
 
@@ -2295,15 +2297,15 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
 	else
 #endif
-	tcp_options_write((__be32 *)(th + 1), tp, &opts, &hash_location);
+	tcp_options_write((__be32 *)(th + 1), tp, &opts, key, &hash_location);
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
-	/* Okay, we have all we need - do the auth hash if needed */
+	/* Okay, we have all we need - do the hash if needed */
 	if (key) {
-		tp->af_specific->calc_auth_hash(hash_location,
-					        key, NULL, req, skb);
+		tp->af_specific->auth_calc_hash(hash_location,
+						key, NULL, req, skb, -1);
 	}
 #endif
 
@@ -2317,6 +2319,7 @@ static void tcp_connect_init(struct sock *sk)
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_auth_key *key;
 	__u8 rcv_wscale;
 
 	/* We'll fix this up when we get a response from the other end.
@@ -2326,8 +2329,9 @@ static void tcp_connect_init(struct sock *sk)
 		(sysctl_tcp_timestamps ? TCPOLEN_TSTAMP_ALIGNED : 0);
 
 #ifdef CONFIG_TCP_MD5SIG
-	if (tp->af_specific->auth_lookup(sk, sk) != NULL)
-		tp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
+	key = tp->af_specific->auth_lookup(sk, sk);
+	if (key)
+		tp->tcp_header_len += tcp_auth_option_len_aligned(key);
 #endif
 
 	/* If user gave his TCP_MAXSEG, record it to clamp */
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ffac593..63605f3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -80,7 +80,7 @@ static struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
 #else
 static struct tcp_auth_key *tcp_v6_auth_do_lookup(struct sock *sk,
-						  struct in6_addr *addr)
+						  const struct in6_addr *addr)
 {
 	return NULL;
 }
@@ -535,21 +535,24 @@ static void tcp_v6_reqsk_destructor(struct request_sock *req)
 
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_auth_key *tcp_v6_auth_do_lookup(struct sock *sk,
-						  struct in6_addr *addr)
+						  const struct in6_addr *addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_auth_key *wildcard_ret = NULL;
 	int i;
 
 	BUG_ON(tp == NULL);
 
 	if (!tp->auth_info || !tp->auth_info->entries6)
 		return NULL;
-
 	for (i = 0; i < tp->auth_info->entries6; i++) {
 		if (ipv6_addr_equal(&tp->auth_info->keys6[i].addr, addr))
 			return &tp->auth_info->keys6[i].base;
+		else if (tp->auth_info->keys4[i].addr == 0)
+			wildcard_ret = &tp->auth_info->keys4[i].base;
 	}
-	return NULL;
+
+	return wildcard_ret;
 }
 
 static struct tcp_auth_key *tcp_v6_auth_lookup(struct sock *sk,
@@ -565,32 +568,48 @@ static struct tcp_auth_key *tcp_v6_reqsk_auth_lookup(struct sock *sk,
 }
 
 static int tcp_v6_auth_do_add(struct sock *sk, struct in6_addr *peer,
-			      char *newkey, u8 newkeylen)
+			      const struct tcp_auth_key *tmpl)
 {
 	/* Add key to the list */
-	struct tcp_auth_key *key;
+	struct tcp_auth_key *key = NULL;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp6_auth_key *keys;
+	int i, err = 0;
+
+	if (tp->auth_info && tp->auth_info->entries6) {
+		for (i = 0; i < tp->auth_info->entries6; i++) {
+			if (ipv6_addr_equal(&tp->auth_info->keys6[i].addr,
+					    peer)) {
+				key = &tp->auth_info->keys6[i].base;
+				break;
+			}
+		}
+	}
 
-	key = tcp_v6_auth_do_lookup(sk, peer);
 	if (key) {
 		/* modify existing entry - just update that one */
-		kfree(key->key);
-		key->key = newkey;
-		key->keylen = newkeylen;
+		kfree(key->key0);
+		kfree(key->key1);
+		tcp_auth_move_key(key, tmpl);
 	} else {
 		/* reallocate new list if current one is full. */
 		if (!tp->auth_info) {
 			tp->auth_info = kzalloc(sizeof(*tp->auth_info), GFP_ATOMIC);
 			if (!tp->auth_info) {
-				kfree(newkey);
-				return -ENOMEM;
+				err = -ENOMEM;
+				goto out;
 			}
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		}
+
+		if (tp->auth_info->entries6 + 1 > TCP_AUTH_MAX_KEYS) {
+			err = -ENOSPC;
+			goto out;
+		}
+
 		if (tcp_auth_alloc_pool() == NULL) {
-			kfree(newkey);
-			return -ENOMEM;
+			err = -ENOMEM;
+			goto out;
 		}
 		if (tp->auth_info->alloced6 == tp->auth_info->entries6) {
 			keys = kmalloc((sizeof (tp->auth_info->keys6[0]) *
@@ -598,8 +617,8 @@ static int tcp_v6_auth_do_add(struct sock *sk, struct in6_addr *peer,
 
 			if (!keys) {
 				tcp_auth_free_pool();
-				kfree(newkey);
-				return -ENOMEM;
+				err = -ENOMEM;
+				goto out;
 			}
 
 			if (tp->auth_info->entries6)
@@ -612,21 +631,24 @@ static int tcp_v6_auth_do_add(struct sock *sk, struct in6_addr *peer,
 			tp->auth_info->alloced6++;
 		}
 
-		ipv6_addr_copy(&tp->auth_info->keys6[tp->auth_info->entries6].addr,
-			       peer);
-		tp->auth_info->keys6[tp->auth_info->entries6].base.key = newkey;
-		tp->auth_info->keys6[tp->auth_info->entries6].base.keylen = newkeylen;
+		keys = &tp->auth_info->keys6[tp->auth_info->entries6];
+		ipv6_addr_copy(&keys->addr, peer);
+		tcp_auth_move_key(&keys->base, tmpl);
 
 		tp->auth_info->entries6++;
 	}
 	return 0;
+
+out:
+	kfree(tmpl->key0);
+	kfree(tmpl->key1);
+	return err;
 }
 
 static int tcp_v6_auth_add_func(struct sock *sk, struct sock *addr_sk,
-			       u8 *newkey, __u8 newkeylen)
+				const struct tcp_auth_key *tmpl)
 {
-	return tcp_v6_auth_do_add(sk, &inet6_sk(addr_sk)->daddr,
-				  newkey, newkeylen);
+	return tcp_v6_auth_do_add(sk, &inet6_sk(addr_sk)->daddr, tmpl);
 }
 
 static int tcp_v6_auth_do_del(struct sock *sk, struct in6_addr *peer)
@@ -637,7 +659,8 @@ static int tcp_v6_auth_do_del(struct sock *sk, struct in6_addr *peer)
 	for (i = 0; i < tp->auth_info->entries6; i++) {
 		if (ipv6_addr_equal(&tp->auth_info->keys6[i].addr, peer)) {
 			/* Free the key */
-			kfree(tp->auth_info->keys6[i].base.key);
+			kfree(tp->auth_info->keys6[i].base.key0);
+			kfree(tp->auth_info->keys6[i].base.key1);
 			tp->auth_info->entries6--;
 
 			if (tp->auth_info->entries6 == 0) {
@@ -665,8 +688,10 @@ static void tcp_v6_auth_clear_list(struct sock *sk)
 	int i;
 
 	if (tp->auth_info->entries6) {
-		for (i = 0; i < tp->auth_info->entries6; i++)
-			kfree(tp->auth_info->keys6[i].base.key);
+		for (i = 0; i < tp->auth_info->entries6; i++) {
+			kfree(tp->auth_info->keys6[i].base.key0);
+			kfree(tp->auth_info->keys6[i].base.key1);
+		}
 		tp->auth_info->entries6 = 0;
 		tcp_auth_free_pool();
 	}
@@ -676,8 +701,10 @@ static void tcp_v6_auth_clear_list(struct sock *sk)
 	tp->auth_info->alloced6 = 0;
 
 	if (tp->auth_info->entries4) {
-		for (i = 0; i < tp->auth_info->entries4; i++)
-			kfree(tp->auth_info->keys4[i].base.key);
+		for (i = 0; i < tp->auth_info->entries4; i++) {
+			kfree(tp->auth_info->keys4[i].base.key0);
+			kfree(tp->auth_info->keys4[i].base.key1);
+		}
 		tp->auth_info->entries4 = 0;
 		tcp_auth_free_pool();
 	}
@@ -687,23 +714,15 @@ static void tcp_v6_auth_clear_list(struct sock *sk)
 	tp->auth_info->alloced4 = 0;
 }
 
-static int tcp_v6_auth_parse_keys(struct sock *sk, char __user *optval,
-				  int optlen)
+static int tcp_v6_auth_parse(struct sock *sk, struct tcp_auth *cmd)
 {
-	struct tcp_auth cmd;
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
-	u8 *newkey;
-
-	if (optlen < sizeof(cmd))
-		return -EINVAL;
-
-	if (copy_from_user(&cmd, optval, sizeof(cmd)))
-		return -EFAULT;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd->tcpa_addr;
+	struct tcp_auth_key key;
 
 	if (sin6->sin6_family != AF_INET6)
 		return -EINVAL;
 
-	if (!cmd.tcpm_keylen) {
+	if (!cmd->tcpa_key0len && !cmd->tcpa_key1len) {
 		if (!tcp_sk(sk)->auth_info)
 			return -ENOENT;
 		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
@@ -711,7 +730,18 @@ static int tcp_v6_auth_parse_keys(struct sock *sk, char __user *optval,
 		return tcp_v6_auth_do_del(sk, &sin6->sin6_addr);
 	}
 
-	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
+	if (cmd->tcpa_flags & TCP_AUTH_RFC2385) {
+		cmd->tcpa_flags = TCP_AUTH_RFC2385 | TCP_AUTH_ALLOW_KEY0 |
+				 TCP_AUTH_OPTIONS_EXCLUDE;
+		cmd->tcpa_key1len = 0;
+		cmd->tcpa_macfunc = TCP_AUTH_KEYED_MD5_128;
+	}
+
+	if (cmd->tcpa_macfunc > TCP_AUTH_MAX_MAC)
+		return -EPROTONOSUPPORT;
+
+	if (cmd->tcpa_key0len > TCP_AUTH_MAXKEYLEN ||
+	    cmd->tcpa_key1len > TCP_AUTH_MAXKEYLEN)
 		return -EINVAL;
 
 	if (!tcp_sk(sk)->auth_info) {
@@ -726,14 +756,64 @@ static int tcp_v6_auth_parse_keys(struct sock *sk, char __user *optval,
 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 
-	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
-	if (!newkey)
+	key.key0 = cmd->tcpa_key0len ?
+		   kmemdup(cmd->tcpa_key0, cmd->tcpa_key0len, GFP_KERNEL) : NULL;
+	if (!key.key0 && cmd->tcpa_key0len)
+		return -ENOMEM;
+	key.key1 = cmd->tcpa_key1len ?
+		   kmemdup(cmd->tcpa_key1, cmd->tcpa_key1len, GFP_KERNEL) : NULL;
+	if (!key.key1 && cmd->tcpa_key1len) {
+		kfree(key.key0);
 		return -ENOMEM;
+	}
+
+	key.key0len = cmd->tcpa_key0len;
+	key.key1len = cmd->tcpa_key1len;
+	key.mac = cmd->tcpa_macfunc;
+	key.flags = cmd->tcpa_flags;
+
 	if (ipv6_addr_v4mapped(&sin6->sin6_addr)) {
 		return tcp_v4_auth_do_add(sk, sin6->sin6_addr.s6_addr32[3],
-					 newkey, cmd.tcpm_keylen);
+					  &key);
 	}
-	return tcp_v6_auth_do_add(sk, &sin6->sin6_addr, newkey, cmd.tcpm_keylen);
+	return tcp_v6_auth_do_add(sk, &sin6->sin6_addr, &key);
+}
+
+static int tcp_v6_auth_parse_keys(struct sock *sk, char __user *optval,
+				  int optlen)
+{
+	struct tcp_auth cmd;
+
+	if (optlen < sizeof(cmd))
+		return -EINVAL;
+
+	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+		return -EFAULT;
+
+	return tcp_v6_auth_parse(sk, &cmd);
+}
+
+static int tcp_v6_md5_parse_keys(struct sock *sk, char __user *optval,
+				 int optlen)
+{
+	struct tcp_md5sig cmd;
+	struct tcp_auth tcpa;
+
+	if (optlen < sizeof(cmd))
+		return -EINVAL;
+
+	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+		return -EFAULT;
+
+	memcpy(tcpa.tcpa_key0, cmd.tcpm_key,
+	       min_t(unsigned, TCP_MD5SIG_MAXKEYLEN, TCP_AUTH_MAXKEYLEN));
+	memcpy(&tcpa.tcpa_addr, &cmd.tcpm_addr, sizeof(tcpa.tcpa_addr));
+	tcpa.tcpa_key0len = cmd.tcpm_keylen;
+	tcpa.tcpa_key1len = 0;
+	tcpa.tcpa_flags = TCP_AUTH_RFC2385;
+	tcpa.tcpa_macfunc = TCP_AUTH_KEYED_MD5_128;
+
+	return tcp_v6_auth_parse(sk, &tcpa);
 }
 
 static int tcp_v6_auth_hash_pseudoheader(struct tcp_auth_pool *hp,
@@ -759,22 +839,21 @@ static int tcp_v6_auth_hash_hdr(char *hash, struct tcp_auth_key *key,
 			        struct tcphdr *th)
 {
 	struct tcp_auth_pool *hp;
-	struct hash_desc *desc;
 
 	hp = tcp_auth_get_pool();
 	if (!hp)
 		goto clear_hash_noput;
-	desc = &hp->md5_desc;
 
-	if (crypto_hash_init(desc))
-		goto clear_hash;
-	if (tcp_v6_auth_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
+	if (tcp_auth_hash_init(hp, key, -1))
 		goto clear_hash;
-	if (tcp_auth_hash_header(hp, th))
-		goto clear_hash;
-	if (tcp_auth_hash_key(hp, key))
+	if (!(key->flags & TCP_AUTH_PSEUDOHEADER_EXCLUDE)) {
+		if (tcp_v6_auth_hash_pseudoheader(hp, daddr, saddr,
+						  th->doff << 2))
+			goto clear_hash;
+	}
+	if (tcp_auth_hash_header(hp, key, th, hash))
 		goto clear_hash;
-	if (crypto_hash_final(desc, hash))
+	if (tcp_auth_hash_final(hash, hp, key, -1))
 		goto clear_hash;
 
 	tcp_auth_put_pool();
@@ -783,17 +862,16 @@ static int tcp_v6_auth_hash_hdr(char *hash, struct tcp_auth_key *key,
 clear_hash:
 	tcp_auth_put_pool();
 clear_hash_noput:
-	memset(hash, 0, 16);
+	memset(hash, 0, tcp_auth_hash_len(key));
 	return 1;
 }
 
 static int tcp_v6_auth_hash_skb(char *hash, struct tcp_auth_key *key,
-			        struct sock *sk, struct request_sock *req,
-			        struct sk_buff *skb)
+				struct sock *sk, struct request_sock *req,
+				struct sk_buff *skb, int keyid)
 {
 	struct in6_addr *saddr, *daddr;
 	struct tcp_auth_pool *hp;
-	struct hash_desc *desc;
 	struct tcphdr *th = tcp_hdr(skb);
 
 	if (sk) {
@@ -811,20 +889,19 @@ static int tcp_v6_auth_hash_skb(char *hash, struct tcp_auth_key *key,
 	hp = tcp_auth_get_pool();
 	if (!hp)
 		goto clear_hash_noput;
-	desc = &hp->md5_desc;
 
-	if (crypto_hash_init(desc))
+	if (tcp_auth_hash_init(hp, key, keyid))
 		goto clear_hash;
 
-	if (tcp_v6_auth_hash_pseudoheader(hp, daddr, saddr, skb->len))
-		goto clear_hash;
-	if (tcp_auth_hash_header(hp, th))
+	if (!(key->flags & TCP_AUTH_PSEUDOHEADER_EXCLUDE)) {
+		if (tcp_v6_auth_hash_pseudoheader(hp, daddr, saddr, skb->len))
+			goto clear_hash;
+	}
+	if (tcp_auth_hash_header(hp, key, th, hash))
 		goto clear_hash;
 	if (tcp_auth_hash_skb_data(hp, skb, th->doff << 2))
 		goto clear_hash;
-	if (tcp_auth_hash_key(hp, key))
-		goto clear_hash;
-	if (crypto_hash_final(desc, hash))
+	if (tcp_auth_hash_final(hash, hp, key, -1))
 		goto clear_hash;
 
 	tcp_auth_put_pool();
@@ -839,59 +916,24 @@ clear_hash_noput:
 
 static int tcp_v6_auth_inbound_hash(struct sock *sk, struct sk_buff *skb)
 {
-	__u8 *hash_location = NULL;
-	struct tcp_auth_key *hash_expected;
-	struct ipv6hdr *ip6h = ipv6_hdr(skb);
-	struct tcphdr *th = tcp_hdr(skb);
-	int genhash;
-	u8 newhash[16];
-
-	hash_expected = tcp_v6_auth_do_lookup(sk, &ip6h->saddr);
-	hash_location = tcp_auth_parse_option(th);
-
-	/* do we have a hash as expected? */
-	if (!hash_expected) {
-		if (!hash_location)
-			return 0;
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash NOT expected but found "
-			       "(" NIP6_FMT ", %u)->"
-			       "(" NIP6_FMT ", %u)\n",
-			       NIP6(ip6h->saddr), ntohs(th->source),
-			       NIP6(ip6h->daddr), ntohs(th->dest));
-		}
-		return 1;
-	}
-
-	if (!hash_location) {
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash expected but NOT found "
-			       "(" NIP6_FMT ", %u)->"
-			       "(" NIP6_FMT ", %u)\n",
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
+	struct tcp_auth_key *key = tcp_v6_auth_do_lookup(sk, &ip6h->saddr);
+	const char *errormsg =
+		tcp_auth_inbound_hash(skb, key, tcp_v6_auth_hash_skb);
+
+	if (errormsg) {
+		LIMIT_NETDEBUG(KERN_INFO "%s "
+			       "(" NIP6_FMT ", %u)->(" NIP6_FMT ", %u)\n",
+			       errormsg,
 			       NIP6(ip6h->saddr), ntohs(th->source),
 			       NIP6(ip6h->daddr), ntohs(th->dest));
-		}
 		return 1;
 	}
 
-	/* check the signature */
-	genhash = tcp_v6_auth_hash_skb(newhash,
-				       hash_expected,
-				       NULL, NULL, skb);
-
-	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash %s for "
-			       "(" NIP6_FMT ", %u)->"
-			       "(" NIP6_FMT ", %u)\n",
-			       genhash ? "failed" : "mismatch",
-			       NIP6(ip6h->saddr), ntohs(th->source),
-			       NIP6(ip6h->daddr), ntohs(th->dest));
-		}
-		return 1;
-	}
 	return 0;
 }
+
 #endif
 
 struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
@@ -1475,10 +1517,13 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 * memory, then we end up not copying the key
 		 * across. Shucks.
 		 */
-		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
-		if (newkey != NULL)
+		struct tcp_auth_key newkey;
+
+		if (tcp_auth_key_dup(&newkey, key) == 0) {
 			tcp_v6_auth_do_add(newsk, &inet6_sk(sk)->daddr,
-					   newkey, key->keylen);
+					   &newkey);
+			newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+		}
 	}
 #endif
 
@@ -1825,6 +1870,7 @@ static struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
 	.auth_calc_hash	=	tcp_v6_auth_hash_skb,
 	.auth_add	=	tcp_v6_auth_add_func,
 	.auth_parse	=	tcp_v6_auth_parse_keys,
+	.md5_parse	=	tcp_v6_md5_parse_keys,
 };
 #endif
 
