From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: MD5 SG fix
Date: Tue, 1 Jul 2008 15:38:14 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe0683153@europa>
References: <396556a20805301217k293e5718h6bbf02bfe0683152@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:45175 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761661AbYGAWkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 18:40:09 -0400
Received: by yw-out-2324.google.com with SMTP id 9so38696ywe.1
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2008 15:40:00 -0700 (PDT)
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683152@europa>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cut three,
  * I should use sg_set_page, not sg_set_buf with page_address
  * Make the version that tcp_output etc use take an SKB
  * Replicate fix to IPv6

Cheers,


AGL

 include/net/tcp.h     |    6 +--
 net/ipv4/tcp_ipv4.c   |  112 +++++++++++++++++++++++++++++++++++++------------
 net/ipv4/tcp_output.c |   11 ++---
 net/ipv6/tcp_ipv6.c   |   65 ++++++++++++++++++----------
 4 files changed, 133 insertions(+), 61 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 633147c..a9130a1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1120,9 +1120,8 @@ extern int			tcp_v4_calc_md5_hash(char *md5_hash,
 						     struct sock *sk,
 						     struct dst_entry *dst,
 						     struct request_sock *req,
-						     struct tcphdr *th,
 						     int protocol,
-						     unsigned int tcplen);
+						     struct sk_buff *skb);
 extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
 						   struct sock *addr_sk);
 
@@ -1370,9 +1369,8 @@ struct tcp_sock_af_ops {
 						  struct sock *sk,
 						  struct dst_entry *dst,
 						  struct request_sock *req,
-						  struct tcphdr *th,
 						  int protocol,
-						  unsigned int len);
+						  struct sk_buff *skb);
 	int			(*md5_add) (struct sock *sk,
 					    struct sock *addr_sk,
 					    u8 *newkey,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cd601a8..90a5f41 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -95,8 +95,9 @@ static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 						   __be32 addr);
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen);
+				   int protocol,
+				   struct tcphdr *th, int data_off, int tcplen,
+				   struct skb_shared_info *frags);
 #endif
 
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
@@ -586,8 +587,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 					key,
 					ip_hdr(skb)->daddr,
 					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+					IPPROTO_TCP, &rep.th,
+					arg.iov[0].iov_len, arg.iov[0].iov_len,
+					NULL);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -680,8 +682,9 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 					key,
 					ip_hdr(skb)->daddr,
 					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+					IPPROTO_TCP, &rep.th,
+					arg.iov[0].iov_len, arg.iov[0].iov_len,
+					NULL);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -1004,20 +1007,56 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 				 newkey, cmd.tcpm_keylen);
 }
 
+/*
+static void
+md5_dump(struct scatterlist *sglist, int nsg, unsigned nbytes, int data_off, int tcplen, char frags) {
+	struct scatterlist *sg;
+	unsigned e;
+
+	printk(KERN_INFO "MD5: %d %d %d %d %d\n", nsg, nbytes, data_off, tcplen, frags);
+	for_each_sg(sglist, sg, nsg, e) {
+		u8 *buf = sg_virt(sg);
+		unsigned i;
+
+		for (i = 0; i < sg->length; ++i)
+			printk(" %02x", buf[i]);
+
+		printk("\n");
+	}
+
+	printk("\n");
+}*/
+
+/**
+ * tcp_v4_do_calc_md5_hash - calculate an MD5 hash (RFC 2385)
+ * @md5_hash: (output) a 16 byte space into which the MD5 sig is written
+ * @key: the key that is appened to the hash input
+ * @saddr: source IP address for the packet
+ * @daddr: destination IP address for the packet
+ * @protocol: the protocol number in the IP header (see the RFC)
+ * @th: the TCP header, followed by options and (optional) data
+ * @data_off: the offset of the optional data (in bytes) from @th
+ * @tcplen: the length of the buffer (in bytes) pointed to by @th. If
+ *   @tcplen == @data_off then there is no data following the header
+ * @frags: (maybe NULL) a list of additional fragments of data
+ *
+ * We don't always have the SKB when this function is called, thus the pointer
+ * to the TCP header and all the length arguments.
+ */
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen)
+				   __be32 saddr, __be32 daddr, int protocol,
+				   struct tcphdr *th, int data_off, int tcplen,
+				   struct skb_shared_info *frags)
 {
-	struct scatterlist sg[4];
-	__u16 data_len;
+	struct scatterlist sg[MAX_SKB_FRAGS + 3];
+	const int head_data_len = tcplen - data_off;
 	int block = 0;
 	__sum16 old_checksum;
 	struct tcp_md5sig_pool *hp;
 	struct tcp4_pseudohdr *bp;
 	struct hash_desc *desc;
-	int err;
-	unsigned int nbytes = 0;
+	int err, i;
+	unsigned int nbytes = tcplen;
 
 	/*
 	 * Okay, so RFC2385 is turned on for this connection,
@@ -1040,9 +1079,14 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	bp->daddr = daddr;
 	bp->pad = 0;
 	bp->protocol = protocol;
-	bp->len = htons(tcplen);
+	if (frags)
+		for (i = 0; i < frags->nr_frags; ++i)
+			nbytes += frags->frags[i].size;
+	bp->len = htons(nbytes);
+	nbytes = 0;
 
-	sg_init_table(sg, 4);
+	sg_init_table(sg, 3 + (head_data_len > 0) +
+		      (frags ? frags->nr_frags : 0));
 
 	sg_set_buf(&sg[block++], bp, sizeof(*bp));
 	nbytes += sizeof(*bp);
@@ -1056,11 +1100,19 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	nbytes += sizeof(struct tcphdr);
 
 	/* 3. the TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
-	if (data_len > 0) {
-		unsigned char *data = (unsigned char *)th + (th->doff << 2);
-		sg_set_buf(&sg[block++], data, data_len);
-		nbytes += data_len;
+	if (head_data_len > 0) {
+		unsigned char *data = (unsigned char *)th + data_off;
+		sg_set_buf(&sg[block++], data, head_data_len);
+		nbytes += head_data_len;
+	}
+
+	if (frags) {
+		for (i = 0; i < frags->nr_frags; ++i) {
+			const struct skb_frag_struct *f = &frags->frags[i];
+			sg_set_page(&sg[block++], f->page, f->size,
+				    f->page_offset);
+			nbytes += f->size;
+		}
 	}
 
 	/* 4. an independently-specified key or password, known to both
@@ -1069,7 +1121,7 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	sg_set_buf(&sg[block++], key->key, key->keylen);
 	nbytes += key->keylen;
 
-	sg_mark_end(&sg[block - 1]);
+	/*md5_dump(sg, block, nbytes, data_off, tcplen, frags != NULL);*/
 
 	/* Now store the Hash into the packet */
 	err = crypto_hash_init(desc);
@@ -1099,10 +1151,10 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 			 struct sock *sk,
 			 struct dst_entry *dst,
 			 struct request_sock *req,
-			 struct tcphdr *th, int protocol,
-			 unsigned int tcplen)
+			 int protocol, struct sk_buff *skb)
 {
 	__be32 saddr, daddr;
+	struct tcphdr *th = tcp_hdr(skb);
 
 	if (sk) {
 		saddr = inet_sk(sk)->saddr;
@@ -1113,9 +1165,10 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 		saddr = rt->rt_src;
 		daddr = rt->rt_dst;
 	}
-	return tcp_v4_do_calc_md5_hash(md5_hash, key,
-				       saddr, daddr,
-				       th, protocol, tcplen);
+	return tcp_v4_do_calc_md5_hash(md5_hash, key, saddr, daddr, protocol,
+				       th, th->doff << 2, skb_headlen(skb),
+				       skb_is_nonlinear(skb) ?
+					 skb_shinfo(skb) : NULL);
 }
 
 EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
@@ -1206,8 +1259,10 @@ done_opts:
 	genhash = tcp_v4_do_calc_md5_hash(newhash,
 					  hash_expected,
 					  iph->saddr, iph->daddr,
-					  th, sk->sk_protocol,
-					  skb->len);
+					  sk->sk_protocol, th, th->doff << 2,
+					  skb_headlen(skb),
+					  skb_is_nonlinear(skb) ?
+						skb_shinfo(skb) : NULL);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
@@ -1456,6 +1511,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		if (newkey != NULL)
 			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
 					  newkey, key->keylen);
+		newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 #endif
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e399bde..07269e9 100644
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
@@ -606,9 +608,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		tp->af_specific->calc_md5_hash(md5_hash_location,
 					       md5,
 					       sk, NULL, NULL,
-					       tcp_hdr(skb),
-					       sk->sk_protocol,
-					       skb->len);
+					       sk->sk_protocol, skb);
 	}
 #endif
 
@@ -2264,8 +2264,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		tp->af_specific->calc_md5_hash(md5_hash_location,
 					       md5,
 					       NULL, dst, req,
-					       tcp_hdr(skb), sk->sk_protocol,
-					       skb->len);
+					       sk->sk_protocol, skb);
 	}
 #endif
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 715965f..b547a08 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -736,18 +736,19 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   struct in6_addr *saddr,
 				   struct in6_addr *daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen)
+				   int protocol,
+				   struct tcphdr *th, int data_off, int tcplen,
+				   struct skb_shared_info *frags)
 {
-	struct scatterlist sg[4];
-	__u16 data_len;
+	struct scatterlist sg[MAX_SKB_FRAGS + 3];
+	const int head_data_len = tcplen - data_off;
 	int block = 0;
 	__sum16 cksum;
 	struct tcp_md5sig_pool *hp;
 	struct tcp6_pseudohdr *bp;
 	struct hash_desc *desc;
-	int err;
-	unsigned int nbytes = 0;
+	int err, i;
+	unsigned int nbytes = tcplen;
 
 	hp = tcp_get_md5sig_pool();
 	if (!hp) {
@@ -760,10 +761,15 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	/* 1. TCP pseudo-header (RFC2460) */
 	ipv6_addr_copy(&bp->saddr, saddr);
 	ipv6_addr_copy(&bp->daddr, daddr);
-	bp->len = htonl(tcplen);
 	bp->protocol = htonl(protocol);
+	if (frags)
+		for (i = 0; i < frags->nr_frags; ++i)
+			nbytes += frags->frags[i].size;
+	bp->len = htonl(nbytes);
+	nbytes = 0;
 
-	sg_init_table(sg, 4);
+	sg_init_table(sg, 3 + (head_data_len > 0) +
+		      (frags ? frags->nr_frags : 0));
 
 	sg_set_buf(&sg[block++], bp, sizeof(*bp));
 	nbytes += sizeof(*bp);
@@ -775,19 +781,25 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	nbytes += sizeof(*th);
 
 	/* 3. TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
-	if (data_len > 0) {
-		u8 *data = (u8 *)th + (th->doff << 2);
-		sg_set_buf(&sg[block++], data, data_len);
-		nbytes += data_len;
+	if (head_data_len > 0) {
+		u8 *data = (u8 *)th + data_off;
+		sg_set_buf(&sg[block++], data, head_data_len);
+		nbytes += head_data_len;
+	}
+
+	if (frags) {
+		for (i = 0; i < frags->nr_frags; ++i) {
+			const struct skb_frag_struct *f = &frags->frags[i];
+			sg_set_page(&sg[block++], f->page, f->size,
+				    f->page_offset);
+			nbytes += f->size;
+		}
 	}
 
 	/* 4. shared key */
 	sg_set_buf(&sg[block++], key->key, key->keylen);
 	nbytes += key->keylen;
 
-	sg_mark_end(&sg[block - 1]);
-
 	/* Now store the hash into the packet */
 	err = crypto_hash_init(desc);
 	if (err) {
@@ -821,10 +833,11 @@ static int tcp_v6_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				struct sock *sk,
 				struct dst_entry *dst,
 				struct request_sock *req,
-				struct tcphdr *th, int protocol,
-				unsigned int tcplen)
+				int protocol,
+				struct sk_buff *skb)
 {
 	struct in6_addr *saddr, *daddr;
+	struct tcphdr *th = tcp_hdr(skb);
 
 	if (sk) {
 		saddr = &inet6_sk(sk)->saddr;
@@ -834,8 +847,10 @@ static int tcp_v6_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 		daddr = &inet6_rsk(req)->rmt_addr;
 	}
 	return tcp_v6_do_calc_md5_hash(md5_hash, key,
-				       saddr, daddr,
-				       th, protocol, tcplen);
+				       saddr, daddr, protocol,
+				       th, th->doff << 2, skb_headlen(skb),
+				       skb_is_nonlinear(skb) ?
+					 skb_shinfo(skb) : NULL);
 }
 
 static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
@@ -910,8 +925,10 @@ done_opts:
 	genhash = tcp_v6_do_calc_md5_hash(newhash,
 					  hash_expected,
 					  &ip6h->saddr, &ip6h->daddr,
-					  th, sk->sk_protocol,
-					  skb->len);
+					  sk->sk_protocol, th,
+					  th->doff << 2, skb_headlen(skb),
+					  skb_is_nonlinear(skb) ?
+					    skb_shinfo(skb) : NULL);
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
 			printk(KERN_INFO "MD5 Hash %s for "
@@ -1051,7 +1068,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		tcp_v6_do_calc_md5_hash((__u8 *)&opt[1], key,
 					&ipv6_hdr(skb)->daddr,
 					&ipv6_hdr(skb)->saddr,
-					t1, IPPROTO_TCP, tot_len);
+					IPPROTO_TCP, t1, tot_len,
+					tot_len, NULL);
 	}
 #endif
 
@@ -1157,7 +1175,8 @@ static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
 		tcp_v6_do_calc_md5_hash((__u8 *)topt, key,
 					&ipv6_hdr(skb)->daddr,
 					&ipv6_hdr(skb)->saddr,
-					t1, IPPROTO_TCP, tot_len);
+					IPPROTO_TCP, t1, tot_len,
+					tot_len, NULL);
 	}
 #endif
 
