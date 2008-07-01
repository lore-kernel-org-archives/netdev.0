From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: MD5 SG fix
Date: Tue, 1 Jul 2008 14:49:46 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe0683152@europa>
References: <396556a20807011448m534c4c8dvf0b827f4cead4714@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:18179 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758972AbYGAVww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 17:52:52 -0400
Received: by yw-out-2324.google.com with SMTP id 9so28945ywe.1
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2008 14:52:41 -0700 (PDT)
In-Reply-To: <396556a20807011448m534c4c8dvf0b827f4cead4714@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Second cut: copy from hunks from [1] where route caps were set to disable GSO.

Cheers,


AGL


[1] http://marc.info/?l=linux-netdev&m=121459157816964&w=2

---

 include/net/tcp.h     |   11 +++--
 net/ipv4/tcp_ipv4.c   |  114 +++++++++++++++++++++++++++++++++++++------------
 net/ipv4/tcp_output.c |   18 +++++---
 3 files changed, 105 insertions(+), 38 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 633147c..4213379 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1110,6 +1110,7 @@ union tcp_md5sum_block {
 struct tcp_md5sig_pool {
 	struct hash_desc	md5_desc;
 	union tcp_md5sum_block	md5_blk;
+	struct scatterlist sg[MAX_SKB_FRAGS + 3];
 };
 
 #define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
@@ -1120,9 +1121,10 @@ extern int			tcp_v4_calc_md5_hash(char *md5_hash,
 						     struct sock *sk,
 						     struct dst_entry *dst,
 						     struct request_sock *req,
-						     struct tcphdr *th,
 						     int protocol,
-						     unsigned int tcplen);
+						     struct tcphdr *th,
+						     int data_off, int tcplen,
+						     struct skb_shared_info *);
 extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
 						   struct sock *addr_sk);
 
@@ -1370,9 +1372,10 @@ struct tcp_sock_af_ops {
 						  struct sock *sk,
 						  struct dst_entry *dst,
 						  struct request_sock *req,
-						  struct tcphdr *th,
 						  int protocol,
-						  unsigned int len);
+						  struct tcphdr *th,
+						  int data_off, int tcplen,
+						  struct skb_shared_info*frags);
 	int			(*md5_add) (struct sock *sk,
 					    struct sock *addr_sk,
 					    u8 *newkey,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cd601a8..1ac4b1f 100644
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
+	struct scatterlist *sg;
+	const __u16 head_data_len = tcplen - data_off;
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
@@ -1029,6 +1068,7 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 		goto clear_hash_noput;
 
 	bp = &hp->md5_blk.ip4;
+	sg = hp->sg;
 	desc = &hp->md5_desc;
 
 	/*
@@ -1040,9 +1080,14 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
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
@@ -1056,11 +1101,21 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
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
+			sg_set_buf(&sg[block++],
+				   ((unsigned char *) page_address(f->page)) +
+				     f->page_offset,
+				   f->size);
+			nbytes += f->size;
+		}
 	}
 
 	/* 4. an independently-specified key or password, known to both
@@ -1069,7 +1124,7 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	sg_set_buf(&sg[block++], key->key, key->keylen);
 	nbytes += key->keylen;
 
-	sg_mark_end(&sg[block - 1]);
+	/*md5_dump(sg, block, nbytes, data_off, tcplen, frags != NULL);*/
 
 	/* Now store the Hash into the packet */
 	err = crypto_hash_init(desc);
@@ -1099,8 +1154,9 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 			 struct sock *sk,
 			 struct dst_entry *dst,
 			 struct request_sock *req,
-			 struct tcphdr *th, int protocol,
-			 unsigned int tcplen)
+			 int protocol,
+			 struct tcphdr *th, int data_off, int tcplen,
+			 struct skb_shared_info *frags)
 {
 	__be32 saddr, daddr;
 
@@ -1113,9 +1169,8 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 		saddr = rt->rt_src;
 		daddr = rt->rt_dst;
 	}
-	return tcp_v4_do_calc_md5_hash(md5_hash, key,
-				       saddr, daddr,
-				       th, protocol, tcplen);
+	return tcp_v4_do_calc_md5_hash(md5_hash, key, saddr, daddr, protocol,
+				       th, data_off, tcplen, frags);
 }
 
 EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
@@ -1206,8 +1261,10 @@ done_opts:
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
@@ -1456,6 +1513,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		if (newkey != NULL)
 			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
 					  newkey, key->keylen);
+		newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
 #endif
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e399bde..c5f044b 100644
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
@@ -606,9 +608,11 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		tp->af_specific->calc_md5_hash(md5_hash_location,
 					       md5,
 					       sk, NULL, NULL,
-					       tcp_hdr(skb),
 					       sk->sk_protocol,
-					       skb->len);
+					       th, th->doff << 2,
+					       skb_headlen(skb),
+					       skb_is_nonlinear(skb) ?
+						 skb_shinfo(skb) : NULL);
 	}
 #endif
 
@@ -2263,9 +2267,11 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	if (md5) {
 		tp->af_specific->calc_md5_hash(md5_hash_location,
 					       md5,
-					       NULL, dst, req,
-					       tcp_hdr(skb), sk->sk_protocol,
-					       skb->len);
+					       NULL, dst, req, sk->sk_protocol,
+					       th, th->doff << 2,
+					       skb_headlen(skb),
+					       skb_is_nonlinear(skb) ?
+						 skb_shinfo(skb) : NULL);
 	}
 #endif
 
