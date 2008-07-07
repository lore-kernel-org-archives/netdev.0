From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] ipv[46]: Fix MD5 signatures for non-linear skbs
Date: Mon, 7 Jul 2008 10:22:43 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069001@europa>
References: <396556a20807071021n2039fc8eo6ab343355e36b468@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:41363 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734AbYGGRX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 13:23:57 -0400
Received: by yx-out-2324.google.com with SMTP id 8so458295yxm.1
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2008 10:23:56 -0700 (PDT)
In-Reply-To: <396556a20807071021n2039fc8eo6ab343355e36b468@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv[46]: Fix MD5 signatures for non-linear skbs

Currently, the MD5 code assumes that the SKBs are linear and, in the case
that they aren't, happily goes off and hashes off the end of the SKB and
into random memory.

Reported by Stephen Hemminger in [1]. Advice thanks to Stephen and Evgeniy
Polyakov. Also includes a couple of missed route_caps from Stephen's patch
in [2].

[1] http://marc.info/?l=linux-netdev&m=121445989106145&w=2
[2] http://marc.info/?l=linux-netdev&m=121459157816964&w=2

Signed-off-by: Adam Langley <agl@imperialviolet.org>
---

 include/net/tcp.h     |   20 ++---
 net/ipv4/tcp.c        |   51 ++++++++++++++
 net/ipv4/tcp_ipv4.c   |  179 ++++++++++++++++++++++---------------------------
 net/ipv4/tcp_output.c |   17 ++---
 net/ipv6/tcp_ipv6.c   |  167 ++++++++++++++++++++++------------------------
 5 files changed, 229 insertions(+), 205 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cf54034..baca49e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1113,14 +1113,9 @@ struct tcp_md5sig_pool {
 #define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
 
 /* - functions */
-extern int			tcp_v4_calc_md5_hash(char *md5_hash,
-						     struct tcp_md5sig_key *key,
-						     struct sock *sk,
-						     struct dst_entry *dst,
-						     struct request_sock *req,
-						     struct tcphdr *th,
-						     int protocol,
-						     unsigned int tcplen);
+int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
+			struct sock *sk, struct request_sock *req,
+			int protocol, struct sk_buff *skb);
 extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
 						   struct sock *addr_sk);
 
@@ -1137,6 +1132,11 @@ extern void			tcp_free_md5sig_pool(void);
 
 extern struct tcp_md5sig_pool	*__tcp_get_md5sig_pool(int cpu);
 extern void			__tcp_put_md5sig_pool(void);
+extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, struct tcphdr *);
+extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, struct sk_buff *,
+				 unsigned header_len);
+extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
+			    struct tcp_md5sig_key *key);
 
 static inline
 struct tcp_md5sig_pool		*tcp_get_md5sig_pool(void)
@@ -1366,11 +1366,9 @@ struct tcp_sock_af_ops {
 	int			(*calc_md5_hash) (char *location,
 						  struct tcp_md5sig_key *md5,
 						  struct sock *sk,
-						  struct dst_entry *dst,
 						  struct request_sock *req,
-						  struct tcphdr *th,
 						  int protocol,
-						  unsigned int len);
+						  struct sk_buff *skb);
 	int			(*md5_add) (struct sock *sk,
 					    struct sock *addr_sk,
 					    u8 *newkey,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1d723de..497e4f3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2590,6 +2590,57 @@ void __tcp_put_md5sig_pool(void)
 }
 
 EXPORT_SYMBOL(__tcp_put_md5sig_pool);
+
+int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
+			struct tcphdr *th)
+{
+	struct scatterlist sg;
+	int err;
+
+	__sum16 old_checksum = th->check;
+	th->check = 0;
+	/* options aren't included in the hash */
+	sg_init_one(&sg, th, sizeof(struct tcphdr));
+	err = crypto_hash_update(&hp->md5_desc, &sg, sizeof(struct tcphdr));
+	th->check = old_checksum;
+	return err;
+}
+
+int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
+			  struct sk_buff *skb, unsigned header_len)
+{
+	struct scatterlist sg;
+	const struct tcphdr *tp = tcp_hdr(skb);
+	struct hash_desc *desc = &hp->md5_desc;
+	unsigned i;
+	const unsigned head_data_len = skb_headlen(skb) > header_len ?
+				       skb_headlen(skb) - header_len : 0;
+	const struct skb_shared_info *shi = skb_shinfo(skb);
+
+	sg_init_table(&sg, 1);
+
+	sg_set_buf(&sg, ((u8 *) tp) + header_len, head_data_len);
+	if (crypto_hash_update(desc, &sg, head_data_len))
+		return 1;
+
+	for (i = 0; i < shi->nr_frags; ++i) {
+		const struct skb_frag_struct *f = &shi->frags[i];
+		sg_set_page(&sg, f->page, f->size, f->page_offset);
+		if (crypto_hash_update(desc, &sg, f->size))
+			return 1;
+	}
+
+	return 0;
+}
+
+int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, struct tcp_md5sig_key *key)
+{
+	struct scatterlist sg;
+
+	sg_init_one(&sg, key->key, key->keylen);
+	return crypto_hash_update(&hp->md5_desc, &sg, key->keylen);
+}
+
 #endif
 
 void tcp_done(struct sock *sk)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ffe869a..99861dd 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -87,12 +87,10 @@ int sysctl_tcp_low_latency __read_mostly;
 
 
 #ifdef CONFIG_TCP_MD5SIG
+static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
+			       __be32 daddr, __be32 saddr, struct tcphdr *th);
 static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 						   __be32 addr);
-static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen);
 #endif
 
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
@@ -578,12 +576,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
 		rep.th.doff = arg.iov[0].iov_len / 4;
 
-		tcp_v4_do_calc_md5_hash((__u8 *)&rep.opt[1],
-					key,
-					ip_hdr(skb)->daddr,
-					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[1],
+				     key, ip_hdr(skb)->daddr,
+				     ip_hdr(skb)->saddr, &rep.th);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -672,12 +667,9 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
 		rep.th.doff = arg.iov[0].iov_len/4;
 
-		tcp_v4_do_calc_md5_hash((__u8 *)&rep.opt[offset],
-					key,
-					ip_hdr(skb)->daddr,
-					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[offset],
+				    key, ip_hdr(skb)->daddr,
+				    ip_hdr(skb)->saddr, &rep.th);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -1000,32 +992,14 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 				 newkey, cmd.tcpm_keylen);
 }
 
-static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen)
+static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
+					__be32 daddr, __be32 saddr,
+					int protocol, int nbytes)
 {
-	struct scatterlist sg[4];
-	__u16 data_len;
-	int block = 0;
-	__sum16 old_checksum;
-	struct tcp_md5sig_pool *hp;
 	struct tcp4_pseudohdr *bp;
-	struct hash_desc *desc;
-	int err;
-	unsigned int nbytes = 0;
-
-	/*
-	 * Okay, so RFC2385 is turned on for this connection,
-	 * so we need to generate the MD5 hash for the packet now.
-	 */
-
-	hp = tcp_get_md5sig_pool();
-	if (!hp)
-		goto clear_hash_noput;
+	struct scatterlist sg;
 
 	bp = &hp->md5_blk.ip4;
-	desc = &hp->md5_desc;
 
 	/*
 	 * 1. the TCP pseudo-header (in the order: source IP address,
@@ -1036,85 +1010,94 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	bp->daddr = daddr;
 	bp->pad = 0;
 	bp->protocol = protocol;
-	bp->len = htons(tcplen);
-
-	sg_init_table(sg, 4);
-
-	sg_set_buf(&sg[block++], bp, sizeof(*bp));
-	nbytes += sizeof(*bp);
-
-	/* 2. the TCP header, excluding options, and assuming a
-	 * checksum of zero/
-	 */
-	old_checksum = th->check;
-	th->check = 0;
-	sg_set_buf(&sg[block++], th, sizeof(struct tcphdr));
-	nbytes += sizeof(struct tcphdr);
+	bp->len = cpu_to_be16(nbytes);
 
-	/* 3. the TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
-	if (data_len > 0) {
-		unsigned char *data = (unsigned char *)th + (th->doff << 2);
-		sg_set_buf(&sg[block++], data, data_len);
-		nbytes += data_len;
-	}
+	sg_init_one(&sg, bp, sizeof(*bp));
+	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
+}
 
-	/* 4. an independently-specified key or password, known to both
-	 * TCPs and presumably connection-specific
-	 */
-	sg_set_buf(&sg[block++], key->key, key->keylen);
-	nbytes += key->keylen;
+static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
+			       __be32 daddr, __be32 saddr, struct tcphdr *th)
+{
+	struct tcp_md5sig_pool *hp;
+	struct hash_desc *desc;
 
-	sg_mark_end(&sg[block - 1]);
+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;
+	desc = &hp->md5_desc;
 
-	/* Now store the Hash into the packet */
-	err = crypto_hash_init(desc);
-	if (err)
+	if (crypto_hash_init(desc))
 		goto clear_hash;
-	err = crypto_hash_update(desc, sg, nbytes);
-	if (err)
+	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, IPPROTO_TCP,
+					 th->doff << 2))
 		goto clear_hash;
-	err = crypto_hash_final(desc, md5_hash);
-	if (err)
+	if (tcp_md5_hash_header(hp, th))
+		goto clear_hash;
+	if (tcp_md5_hash_key(hp, key))
+		goto clear_hash;
+	if (crypto_hash_final(desc, md5_hash))
 		goto clear_hash;
 
-	/* Reset header, and free up the crypto */
 	tcp_put_md5sig_pool();
-	th->check = old_checksum;
-
-out:
 	return 0;
+
 clear_hash:
 	tcp_put_md5sig_pool();
 clear_hash_noput:
 	memset(md5_hash, 0, 16);
-	goto out;
+	return 1;
 }
 
-int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-			 struct sock *sk,
-			 struct dst_entry *dst,
-			 struct request_sock *req,
-			 struct tcphdr *th, int protocol,
-			 unsigned int tcplen)
+int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
+			struct sock *sk, struct request_sock *req,
+			int protocol, struct sk_buff *skb)
 {
+	struct tcp_md5sig_pool *hp;
+	struct hash_desc *desc;
+	struct tcphdr *th = tcp_hdr(skb);
 	__be32 saddr, daddr;
 
 	if (sk) {
 		saddr = inet_sk(sk)->saddr;
 		daddr = inet_sk(sk)->daddr;
+	} else if (req) {
+		saddr = inet_rsk(req)->loc_addr;
+		daddr = inet_rsk(req)->rmt_addr;
 	} else {
-		struct rtable *rt = (struct rtable *)dst;
-		BUG_ON(!rt);
-		saddr = rt->rt_src;
-		daddr = rt->rt_dst;
+		const struct iphdr *iph = ip_hdr(skb);
+		saddr = iph->saddr;
+		daddr = iph->daddr;
 	}
-	return tcp_v4_do_calc_md5_hash(md5_hash, key,
-				       saddr, daddr,
-				       th, protocol, tcplen);
-}
 
-EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;
+	desc = &hp->md5_desc;
+
+	if (crypto_hash_init(desc))
+		goto clear_hash;
+
+	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, protocol, skb->len))
+		goto clear_hash;
+	if (tcp_md5_hash_header(hp, th))
+		goto clear_hash;
+	if (tcp_md5_hash_skb_data(hp, skb, th->doff << 2))
+		goto clear_hash;
+	if (tcp_md5_hash_key(hp, key))
+		goto clear_hash;
+	if (crypto_hash_final(desc, md5_hash))
+		goto clear_hash;
+
+	tcp_put_md5sig_pool();
+	return 0;
+
+clear_hash:
+	tcp_put_md5sig_pool();
+clear_hash_noput:
+	memset(md5_hash, 0, 16);
+	return 1;
+}
 
 static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 {
@@ -1199,11 +1182,10 @@ done_opts:
 	/* Okay, so this is hash_expected and hash_location -
 	 * so we need to calculate the checksum.
 	 */
-	genhash = tcp_v4_do_calc_md5_hash(newhash,
-					  hash_expected,
-					  iph->saddr, iph->daddr,
-					  th, sk->sk_protocol,
-					  skb->len);
+	genhash = tcp_v4_md5_hash_skb(newhash,
+				      hash_expected,
+				      NULL, NULL,
+				      sk->sk_protocol, skb);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
@@ -1452,6 +1434,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		if (newkey != NULL)
 			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
 					  newkey, key->keylen);
+		newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 #endif
 
@@ -1814,7 +1797,7 @@ struct inet_connection_sock_af_ops ipv4_specific = {
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
 	.md5_lookup		= tcp_v4_md5_lookup,
-	.calc_md5_hash		= tcp_v4_calc_md5_hash,
+	.calc_md5_hash		= tcp_v4_md5_hash_skb,
 	.md5_add		= tcp_v4_md5_add_func,
 	.md5_parse		= tcp_v4_parse_md5_keys,
 };
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ad993ec..14dfc09 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -542,8 +542,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	 * room for it.
 	 */
 	md5 = tp->af_specific->md5_lookup(sk, sk);
-	if (md5)
+	if (md5) {
 		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
+		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+	}
 #endif
 
 	skb_push(skb, tcp_header_size);
@@ -604,11 +606,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	/* Calculate the MD5 hash, as we have all we need now */
 	if (md5) {
 		tp->af_specific->calc_md5_hash(md5_hash_location,
-					       md5,
-					       sk, NULL, NULL,
-					       tcp_hdr(skb),
-					       sk->sk_protocol,
-					       skb->len);
+					       md5, sk, NULL,
+					       sk->sk_protocol, skb);
 	}
 #endif
 
@@ -2264,10 +2263,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	/* Okay, we have all we need - do the md5 hash if needed */
 	if (md5) {
 		tp->af_specific->calc_md5_hash(md5_hash_location,
-					       md5,
-					       NULL, dst, req,
-					       tcp_hdr(skb), sk->sk_protocol,
-					       skb->len);
+					       md5, NULL, req,
+					       sk->sk_protocol, skb);
 	}
 #endif
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 40ea9c3..074feda 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -733,109 +733,107 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 	return tcp_v6_md5_do_add(sk, &sin6->sin6_addr, newkey, cmd.tcpm_keylen);
 }
 
-static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-				   struct in6_addr *saddr,
-				   struct in6_addr *daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen)
+static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
+					struct in6_addr *daddr,
+					struct in6_addr *saddr,
+					int protocol, int nbytes)
 {
-	struct scatterlist sg[4];
-	__u16 data_len;
-	int block = 0;
-	__sum16 cksum;
-	struct tcp_md5sig_pool *hp;
 	struct tcp6_pseudohdr *bp;
-	struct hash_desc *desc;
-	int err;
-	unsigned int nbytes = 0;
+	struct scatterlist sg;
 
-	hp = tcp_get_md5sig_pool();
-	if (!hp) {
-		printk(KERN_WARNING "%s(): hash pool not found...\n", __func__);
-		goto clear_hash_noput;
-	}
 	bp = &hp->md5_blk.ip6;
-	desc = &hp->md5_desc;
-
 	/* 1. TCP pseudo-header (RFC2460) */
 	ipv6_addr_copy(&bp->saddr, saddr);
 	ipv6_addr_copy(&bp->daddr, daddr);
-	bp->len = htonl(tcplen);
-	bp->protocol = htonl(protocol);
-
-	sg_init_table(sg, 4);
+	bp->protocol = cpu_to_be32(protocol);
+	bp->len = cpu_to_be16(nbytes);
 
-	sg_set_buf(&sg[block++], bp, sizeof(*bp));
-	nbytes += sizeof(*bp);
-
-	/* 2. TCP header, excluding options */
-	cksum = th->check;
-	th->check = 0;
-	sg_set_buf(&sg[block++], th, sizeof(*th));
-	nbytes += sizeof(*th);
-
-	/* 3. TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
-	if (data_len > 0) {
-		u8 *data = (u8 *)th + (th->doff << 2);
-		sg_set_buf(&sg[block++], data, data_len);
-		nbytes += data_len;
-	}
+	sg_init_one(&sg, bp, sizeof(*bp));
+	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
+}
 
-	/* 4. shared key */
-	sg_set_buf(&sg[block++], key->key, key->keylen);
-	nbytes += key->keylen;
+static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
+			       struct in6_addr *daddr, struct in6_addr *saddr,
+			       struct tcphdr *th)
+{
+	struct tcp_md5sig_pool *hp;
+	struct hash_desc *desc;
 
-	sg_mark_end(&sg[block - 1]);
+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;
+	desc = &hp->md5_desc;
 
-	/* Now store the hash into the packet */
-	err = crypto_hash_init(desc);
-	if (err) {
-		printk(KERN_WARNING "%s(): hash_init failed\n", __func__);
+	if (crypto_hash_init(desc))
 		goto clear_hash;
-	}
-	err = crypto_hash_update(desc, sg, nbytes);
-	if (err) {
-		printk(KERN_WARNING "%s(): hash_update failed\n", __func__);
+	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, IPPROTO_TCP,
+					 th->doff << 2))
 		goto clear_hash;
-	}
-	err = crypto_hash_final(desc, md5_hash);
-	if (err) {
-		printk(KERN_WARNING "%s(): hash_final failed\n", __func__);
+	if (tcp_md5_hash_header(hp, th))
+		goto clear_hash;
+	if (tcp_md5_hash_key(hp, key))
+		goto clear_hash;
+	if (crypto_hash_final(desc, md5_hash))
 		goto clear_hash;
-	}
 
-	/* Reset header, and free up the crypto */
 	tcp_put_md5sig_pool();
-	th->check = cksum;
-out:
 	return 0;
+
 clear_hash:
 	tcp_put_md5sig_pool();
 clear_hash_noput:
 	memset(md5_hash, 0, 16);
-	goto out;
+	return 1;
 }
 
-static int tcp_v6_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-				struct sock *sk,
-				struct dst_entry *dst,
-				struct request_sock *req,
-				struct tcphdr *th, int protocol,
-				unsigned int tcplen)
+static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
+			       struct sock *sk, struct request_sock *req,
+			       int protocol, struct sk_buff *skb)
 {
 	struct in6_addr *saddr, *daddr;
+	struct tcp_md5sig_pool *hp;
+	struct hash_desc *desc;
+	struct tcphdr *th = tcp_hdr(skb);
 
 	if (sk) {
 		saddr = &inet6_sk(sk)->saddr;
 		daddr = &inet6_sk(sk)->daddr;
-	} else {
+	} else if (req) {
 		saddr = &inet6_rsk(req)->loc_addr;
 		daddr = &inet6_rsk(req)->rmt_addr;
+	} else {
+		struct ipv6hdr *ip6h = ipv6_hdr(skb);
+		saddr = &ip6h->saddr;
+		daddr = &ip6h->daddr;
 	}
-	return tcp_v6_do_calc_md5_hash(md5_hash, key,
-				       saddr, daddr,
-				       th, protocol, tcplen);
+
+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;
+	desc = &hp->md5_desc;
+
+	if (crypto_hash_init(desc))
+		goto clear_hash;
+
+	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, protocol, skb->len))
+		goto clear_hash;
+	if (tcp_md5_hash_header(hp, th))
+		goto clear_hash;
+	if (tcp_md5_hash_skb_data(hp, skb, th->doff << 2))
+		goto clear_hash;
+	if (tcp_md5_hash_key(hp, key))
+		goto clear_hash;
+	if (crypto_hash_final(desc, md5_hash))
+		goto clear_hash;
+
+	tcp_put_md5sig_pool();
+	return 0;
+
+clear_hash:
+	tcp_put_md5sig_pool();
+clear_hash_noput:
+	memset(md5_hash, 0, 16);
+	return 1;
 }
 
 static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
@@ -907,11 +905,10 @@ done_opts:
 	}
 
 	/* check the signature */
-	genhash = tcp_v6_do_calc_md5_hash(newhash,
-					  hash_expected,
-					  &ip6h->saddr, &ip6h->daddr,
-					  th, sk->sk_protocol,
-					  skb->len);
+	genhash = tcp_v6_md5_hash_skb(newhash,
+				      hash_expected,
+				      NULL, NULL, sk->sk_protocol, skb);
+
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
 			printk(KERN_INFO "MD5 Hash %s for "
@@ -1048,10 +1045,9 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 			       (TCPOPT_NOP << 16) |
 			       (TCPOPT_MD5SIG << 8) |
 			       TCPOLEN_MD5SIG);
-		tcp_v6_do_calc_md5_hash((__u8 *)&opt[1], key,
-					&ipv6_hdr(skb)->daddr,
-					&ipv6_hdr(skb)->saddr,
-					t1, IPPROTO_TCP, tot_len);
+		tcp_v6_md5_hash_hdr((__u8 *)&opt[1], key,
+				    &ipv6_hdr(skb)->daddr,
+				    &ipv6_hdr(skb)->saddr, t1);
 	}
 #endif
 
@@ -1154,10 +1150,9 @@ static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
 	if (key) {
 		*topt++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				(TCPOPT_MD5SIG << 8) | TCPOLEN_MD5SIG);
-		tcp_v6_do_calc_md5_hash((__u8 *)topt, key,
-					&ipv6_hdr(skb)->daddr,
-					&ipv6_hdr(skb)->saddr,
-					t1, IPPROTO_TCP, tot_len);
+		tcp_v6_md5_hash_hdr((__u8 *)topt, key,
+				    &ipv6_hdr(skb)->daddr,
+				    &ipv6_hdr(skb)->saddr, t1);
 	}
 #endif
 
@@ -1871,7 +1866,7 @@ static struct inet_connection_sock_af_ops ipv6_specific = {
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
 	.md5_lookup	=	tcp_v6_md5_lookup,
-	.calc_md5_hash	=	tcp_v6_calc_md5_hash,
+	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
 	.md5_add	=	tcp_v6_md5_add_func,
 	.md5_parse	=	tcp_v6_parse_md5_keys,
 };
@@ -1903,7 +1898,7 @@ static struct inet_connection_sock_af_ops ipv6_mapped = {
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific = {
 	.md5_lookup	=	tcp_v4_md5_lookup,
-	.calc_md5_hash	=	tcp_v4_calc_md5_hash,
+	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
 	.md5_add	=	tcp_v6_md5_add_func,
 	.md5_parse	=	tcp_v6_parse_md5_keys,
 };
