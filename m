From: "Adam Langley" <agl@imperialviolet.org>
Subject: [Resend v2 PATCH 1/3] TCP: Fix MD5 signatures for non-linear skbs
Date: Thu, 17 Jul 2008 16:08:10 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069021@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:13826 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761054AbYGQXJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 19:09:46 -0400
Received: by rv-out-0506.google.com with SMTP id k40so107335rvb.1
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 16:09:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the MD5 code assumes that the SKBs are linear and, in the case
that they aren't, happily goes off and hashes off the end of the SKB and
into random memory.

Reported by Stephen Hemminger in [1]. Advice thanks to Stephen and Evgeniy
Polyakov. Also includes a couple of missed route_caps from Stephen's patch
in [2].

[1] http://marc.info/?l=linux-netdev&m=121445989106145&w=2
[2] http://marc.info/?l=linux-netdev&m=121459157816964&w=2

Signed-off-by: Adam Langley <agl@imperialviolet.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---

 include/net/tcp.h     |   29 ++++------
 net/ipv4/tcp.c        |  127 ++++++++++++++++++++------------------------
 net/ipv4/tcp_ipv4.c   |  140 ++++++++++++++++++++++++++++++-------------------
 net/ipv4/tcp_output.c |   14 ++---
 net/ipv6/tcp_ipv6.c   |  127 +++++++++++++++++++++++++++++---------------
 5 files changed, 242 insertions(+), 195 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6b827cc..0484cf4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1115,20 +1115,12 @@ struct tcp_md5sig_pool {
 #define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
 
 /* - functions */
-extern int			tcp_calc_md5_hash(char *md5_hash,
-						  struct tcp_md5sig_key *key,
-						  int bplen,
-						  struct tcphdr *th,
-						  unsigned int tcplen,
-						  struct tcp_md5sig_pool *hp);
-
-extern int			tcp_v4_calc_md5_hash(char *md5_hash,
-						     struct tcp_md5sig_key *key,
-						     struct sock *sk,
-						     struct dst_entry *dst,
-						     struct request_sock *req,
-						     struct tcphdr *th,
-						     unsigned int tcplen);
+extern int			tcp_v4_md5_hash_skb(char *md5_hash,
+						    struct tcp_md5sig_key *key,
+						    struct sock *sk,
+						    struct request_sock *req,
+						    struct sk_buff *skb);
+
 extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
 						   struct sock *addr_sk);
 
@@ -1155,6 +1147,11 @@ extern void			tcp_free_md5sig_pool(void);
 
 extern struct tcp_md5sig_pool	*__tcp_get_md5sig_pool(int cpu);
 extern void			__tcp_put_md5sig_pool(void);
+extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, struct tcphdr *);
+extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, struct sk_buff *,
+				 unsigned header_len);
+extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
+			    struct tcp_md5sig_key *key);
 
 static inline
 struct tcp_md5sig_pool		*tcp_get_md5sig_pool(void)
@@ -1384,10 +1381,8 @@ struct tcp_sock_af_ops {
 	int			(*calc_md5_hash) (char *location,
 						  struct tcp_md5sig_key *md5,
 						  struct sock *sk,
-						  struct dst_entry *dst,
 						  struct request_sock *req,
-						  struct tcphdr *th,
-						  unsigned int len);
+						  struct sk_buff *skb);
 	int			(*md5_add) (struct sock *sk,
 					    struct sock *addr_sk,
 					    u8 *newkey,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 56a133c..e9a99c2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2465,76 +2465,6 @@ static unsigned long tcp_md5sig_users;
 static struct tcp_md5sig_pool **tcp_md5sig_pool;
 static DEFINE_SPINLOCK(tcp_md5sig_pool_lock);
 
-int tcp_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-		      int bplen,
-		      struct tcphdr *th, unsigned int tcplen,
-		      struct tcp_md5sig_pool *hp)
-{
-	struct scatterlist sg[4];
-	__u16 data_len;
-	int block = 0;
-	__sum16 cksum;
-	struct hash_desc *desc = &hp->md5_desc;
-	int err;
-	unsigned int nbytes = 0;
-
-	sg_init_table(sg, 4);
-
-	/* 1. The TCP pseudo-header */
-	sg_set_buf(&sg[block++], &hp->md5_blk, bplen);
-	nbytes += bplen;
-
-	/* 2. The TCP header, excluding options, and assuming a
-	 * checksum of zero
-	 */
-	cksum = th->check;
-	th->check = 0;
-	sg_set_buf(&sg[block++], th, sizeof(*th));
-	nbytes += sizeof(*th);
-
-	/* 3. The TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
-	if (data_len > 0) {
-		u8 *data = (u8 *)th + (th->doff << 2);
-		sg_set_buf(&sg[block++], data, data_len);
-		nbytes += data_len;
-	}
-
-	/* 4. an independently-specified key or password, known to both
-	 * TCPs and presumably connection-specific
-	 */
-	sg_set_buf(&sg[block++], key->key, key->keylen);
-	nbytes += key->keylen;
-
-	sg_mark_end(&sg[block - 1]);
-
-	/* Now store the hash into the packet */
-	err = crypto_hash_init(desc);
-	if (err) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "%s(): hash_init failed\n", __func__);
-		return -1;
-	}
-	err = crypto_hash_update(desc, sg, nbytes);
-	if (err) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "%s(): hash_update failed\n", __func__);
-		return -1;
-	}
-	err = crypto_hash_final(desc, md5_hash);
-	if (err) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "%s(): hash_final failed\n", __func__);
-		return -1;
-	}
-
-	/* Reset header */
-	th->check = cksum;
-
-	return 0;
-}
-EXPORT_SYMBOL(tcp_calc_md5_hash);
-
 static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool **pool)
 {
 	int cpu;
@@ -2658,6 +2588,63 @@ void __tcp_put_md5sig_pool(void)
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
+EXPORT_SYMBOL(tcp_md5_hash_header);
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
+EXPORT_SYMBOL(tcp_md5_hash_skb_data);
+
+int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, struct tcp_md5sig_key *key)
+{
+	struct scatterlist sg;
+
+	sg_init_one(&sg, key->key, key->keylen);
+	return crypto_hash_update(&hp->md5_desc, &sg, key->keylen);
+}
+
+EXPORT_SYMBOL(tcp_md5_hash_key);
+
 #endif
 
 void tcp_done(struct sock *sk)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0fefd44..78e2a0c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -87,9 +87,8 @@ int sysctl_tcp_low_latency __read_mostly;
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 						   __be32 addr);
-static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, unsigned int tcplen);
+static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
+			       __be32 daddr, __be32 saddr, struct tcphdr *th);
 #else
 static inline
 struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
@@ -582,11 +581,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
 		rep.th.doff = arg.iov[0].iov_len / 4;
 
-		tcp_v4_do_calc_md5_hash((__u8 *)&rep.opt[1],
-					key,
-					ip_hdr(skb)->daddr,
-					ip_hdr(skb)->saddr,
-					&rep.th, arg.iov[0].iov_len);
+		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[1],
+				     key, ip_hdr(skb)->daddr,
+				     ip_hdr(skb)->saddr, &rep.th);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -654,11 +651,9 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 		arg.iov[0].iov_len += TCPOLEN_MD5SIG_ALIGNED;
 		rep.th.doff = arg.iov[0].iov_len/4;
 
-		tcp_v4_do_calc_md5_hash((__u8 *)&rep.opt[offset],
-					key,
-					ip_hdr(skb)->daddr,
-					ip_hdr(skb)->saddr,
-					&rep.th, arg.iov[0].iov_len);
+		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[offset],
+				    key, ip_hdr(skb)->daddr,
+				    ip_hdr(skb)->saddr, &rep.th);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -986,28 +981,16 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 				 newkey, cmd.tcpm_keylen);
 }
 
-static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th,
-				   unsigned int tcplen)
+static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
+					__be32 daddr, __be32 saddr, int nbytes)
 {
-	struct tcp_md5sig_pool *hp;
 	struct tcp4_pseudohdr *bp;
-	int err;
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
 
 	/*
-	 * The TCP pseudo-header (in the order: source IP address,
+	 * 1. the TCP pseudo-header (in the order: source IP address,
 	 * destination IP address, zero-padded protocol number, and
 	 * segment length)
 	 */
@@ -1015,48 +998,95 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	bp->daddr = daddr;
 	bp->pad = 0;
 	bp->protocol = IPPROTO_TCP;
-	bp->len = htons(tcplen);
+	bp->len = cpu_to_be16(nbytes);
 
-	err = tcp_calc_md5_hash(md5_hash, key, sizeof(*bp),
-				th, tcplen, hp);
-	if (err)
+	sg_init_one(&sg, bp, sizeof(*bp));
+	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
+}
+
+static int tcp_v4_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
+			       __be32 daddr, __be32 saddr, struct tcphdr *th)
+{
+	struct tcp_md5sig_pool *hp;
+	struct hash_desc *desc;
+
+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;
+	desc = &hp->md5_desc;
+
+	if (crypto_hash_init(desc))
+		goto clear_hash;
+	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
+		goto clear_hash;
+	if (tcp_md5_hash_header(hp, th))
+		goto clear_hash;
+	if (tcp_md5_hash_key(hp, key))
+		goto clear_hash;
+	if (crypto_hash_final(desc, md5_hash))
 		goto clear_hash;
 
-	/* Free up the crypto pool */
 	tcp_put_md5sig_pool();
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
-			 struct tcphdr *th,
-			 unsigned int tcplen)
+int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
+			struct sock *sk, struct request_sock *req,
+			struct sk_buff *skb)
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
-				       th, tcplen);
+
+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;
+	desc = &hp->md5_desc;
+
+	if (crypto_hash_init(desc))
+		goto clear_hash;
+
+	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, skb->len))
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
 
-EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
+EXPORT_SYMBOL(tcp_v4_md5_hash_skb);
 
 static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 {
@@ -1101,10 +1131,9 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 	/* Okay, so this is hash_expected and hash_location -
 	 * so we need to calculate the checksum.
 	 */
-	genhash = tcp_v4_do_calc_md5_hash(newhash,
-					  hash_expected,
-					  iph->saddr, iph->daddr,
-					  th, skb->len);
+	genhash = tcp_v4_md5_hash_skb(newhash,
+				      hash_expected,
+				      NULL, NULL, skb);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
@@ -1353,6 +1382,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		if (newkey != NULL)
 			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
 					  newkey, key->keylen);
+		newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 #endif
 
@@ -1715,7 +1745,7 @@ struct inet_connection_sock_af_ops ipv4_specific = {
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
 	.md5_lookup		= tcp_v4_md5_lookup,
-	.calc_md5_hash		= tcp_v4_calc_md5_hash,
+	.calc_md5_hash		= tcp_v4_md5_hash_skb,
 	.md5_add		= tcp_v4_md5_add_func,
 	.md5_parse		= tcp_v4_parse_md5_keys,
 };
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index edef2af..ac3d89d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -540,8 +540,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
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
@@ -602,10 +604,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	/* Calculate the MD5 hash, as we have all we need now */
 	if (md5) {
 		tp->af_specific->calc_md5_hash(md5_hash_location,
-					       md5,
-					       sk, NULL, NULL,
-					       tcp_hdr(skb),
-					       skb->len);
+					       md5, sk, NULL, skb);
 	}
 #endif
 
@@ -2264,10 +2263,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	/* Okay, we have all we need - do the md5 hash if needed */
 	if (md5) {
 		tp->af_specific->calc_md5_hash(md5_hash_location,
-					       md5,
-					       NULL, dst, req,
-					       tcp_hdr(skb),
-					       skb->len);
+					       md5, NULL, req, skb);
 	}
 #endif
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 30dbab7..ec4041a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -735,64 +735,105 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 	return tcp_v6_md5_do_add(sk, &sin6->sin6_addr, newkey, cmd.tcpm_keylen);
 }
 
-static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-				   struct in6_addr *saddr,
-				   struct in6_addr *daddr,
-				   struct tcphdr *th, unsigned int tcplen)
+static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
+					struct in6_addr *daddr,
+					struct in6_addr *saddr, int nbytes)
 {
-	struct tcp_md5sig_pool *hp;
 	struct tcp6_pseudohdr *bp;
-	int err;
-
-	hp = tcp_get_md5sig_pool();
-	if (!hp) {
-		printk(KERN_WARNING "%s(): hash pool not found...\n", __func__);
-		goto clear_hash_noput;
-	}
+	struct scatterlist sg;
 
 	bp = &hp->md5_blk.ip6;
-
 	/* 1. TCP pseudo-header (RFC2460) */
 	ipv6_addr_copy(&bp->saddr, saddr);
 	ipv6_addr_copy(&bp->daddr, daddr);
-	bp->len = htonl(tcplen);
-	bp->protocol = htonl(IPPROTO_TCP);
+	bp->protocol = cpu_to_be32(IPPROTO_TCP);
+	bp->len = cpu_to_be16(nbytes);
 
-	err = tcp_calc_md5_hash(md5_hash, key, sizeof(*bp),
-				th, tcplen, hp);
+	sg_init_one(&sg, bp, sizeof(*bp));
+	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
+}
 
-	if (err)
+static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
+			       struct in6_addr *daddr, struct in6_addr *saddr,
+			       struct tcphdr *th)
+{
+	struct tcp_md5sig_pool *hp;
+	struct hash_desc *desc;
+
+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;
+	desc = &hp->md5_desc;
+
+	if (crypto_hash_init(desc))
+		goto clear_hash;
+	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
+		goto clear_hash;
+	if (tcp_md5_hash_header(hp, th))
+		goto clear_hash;
+	if (tcp_md5_hash_key(hp, key))
+		goto clear_hash;
+	if (crypto_hash_final(desc, md5_hash))
 		goto clear_hash;
 
-	/* Free up the crypto pool */
 	tcp_put_md5sig_pool();
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
-				struct tcphdr *th, unsigned int tcplen)
+static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
+			       struct sock *sk, struct request_sock *req,
+			       struct sk_buff *skb)
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
-				       th, tcplen);
+
+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;
+	desc = &hp->md5_desc;
+
+	if (crypto_hash_init(desc))
+		goto clear_hash;
+
+	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, skb->len))
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
@@ -833,10 +874,10 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* check the signature */
-	genhash = tcp_v6_do_calc_md5_hash(newhash,
-					  hash_expected,
-					  &ip6h->saddr, &ip6h->daddr,
-					  th, skb->len);
+	genhash = tcp_v6_md5_hash_skb(newhash,
+				      hash_expected,
+				      NULL, NULL, skb);
+
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
 			printk(KERN_INFO "MD5 Hash %s for "
@@ -973,10 +1014,9 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 			       (TCPOPT_NOP << 16) |
 			       (TCPOPT_MD5SIG << 8) |
 			       TCPOLEN_MD5SIG);
-		tcp_v6_do_calc_md5_hash((__u8 *)&opt[1], key,
-					&ipv6_hdr(skb)->daddr,
-					&ipv6_hdr(skb)->saddr,
-					t1, tot_len);
+		tcp_v6_md5_hash_hdr((__u8 *)&opt[1], key,
+				    &ipv6_hdr(skb)->daddr,
+				    &ipv6_hdr(skb)->saddr, t1);
 	}
 #endif
 
@@ -1063,10 +1103,9 @@ static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32
 	if (key) {
 		*topt++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				(TCPOPT_MD5SIG << 8) | TCPOLEN_MD5SIG);
-		tcp_v6_do_calc_md5_hash((__u8 *)topt, key,
-					&ipv6_hdr(skb)->daddr,
-					&ipv6_hdr(skb)->saddr,
-					t1, tot_len);
+		tcp_v6_md5_hash_hdr((__u8 *)topt, key,
+				    &ipv6_hdr(skb)->daddr,
+				    &ipv6_hdr(skb)->saddr, t1);
 	}
 #endif
 
@@ -1781,7 +1820,7 @@ static struct inet_connection_sock_af_ops ipv6_specific = {
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
 	.md5_lookup	=	tcp_v6_md5_lookup,
-	.calc_md5_hash	=	tcp_v6_calc_md5_hash,
+	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
 	.md5_add	=	tcp_v6_md5_add_func,
 	.md5_parse	=	tcp_v6_parse_md5_keys,
 };
@@ -1813,7 +1852,7 @@ static struct inet_connection_sock_af_ops ipv6_mapped = {
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific = {
 	.md5_lookup	=	tcp_v4_md5_lookup,
-	.calc_md5_hash	=	tcp_v4_calc_md5_hash,
+	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
 	.md5_add	=	tcp_v6_md5_add_func,
 	.md5_parse	=	tcp_v6_parse_md5_keys,
 };
