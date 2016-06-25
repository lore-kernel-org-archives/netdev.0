From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: do not use stack storage in crypto
 operations
Date: Sat, 25 Jun 2016 18:09:35 +0200
Message-ID: <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
	 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35896 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbcFYQJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:09:40 -0400
Received: by mail-pf0-f196.google.com with SMTP id i123so11898495pfg.3
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2016 09:09:40 -0700 (PDT)
In-Reply-To: <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some arches have virtually mapped kernel stacks, or will soon have.

tcp_md5_hash_header() uses an automatic variable to copy tcp header
before mangling th->check and calling crypto function, which might
be problematic on such arches.

So use percpu storage as we already do for the pseudo header,
and reduce number of crypto functions calls, as these headers
are ridiculously small.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andy Lutomirski <luto@amacapital.net>
---
I am not sure the md5 crypto functions have a problem with data backed
in virtually mapped stacks, but this patch seems to remove the doubt.

 include/net/tcp.h   |    2 +-
 net/ipv4/tcp.c      |   17 -----------------
 net/ipv4/tcp_ipv4.c |   29 +++++++++++++----------------
 net/ipv6/tcp_ipv6.c |   27 +++++++++++++++------------
 4 files changed, 29 insertions(+), 46 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a79894b667265cdf9e3fe793b4757e2f932b378a..2dd919e0289839130d2c5435b7925592082d62b5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1385,6 +1385,7 @@ union tcp_md5sum_block {
 struct tcp_md5sig_pool {
 	struct ahash_request	*md5_req;
 	union tcp_md5sum_block	md5_blk;
+	struct tcphdr		tcp_hdr;
 };
 
 /* - functions */
@@ -1420,7 +1421,6 @@ static inline void tcp_put_md5sig_pool(void)
 	local_bh_enable();
 }
 
-int tcp_md5_hash_header(struct tcp_md5sig_pool *, const struct tcphdr *);
 int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, const struct sk_buff *,
 			  unsigned int header_len);
 int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5c7ed147449c1b7ba029b12e033ad779a631460a..5fc9336934a11387e725300d6bca4aabd3991f19 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3025,23 +3025,6 @@ struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
 }
 EXPORT_SYMBOL(tcp_get_md5sig_pool);
 
-int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
-			const struct tcphdr *th)
-{
-	struct scatterlist sg;
-	struct tcphdr hdr;
-
-	/* We are not allowed to change tcphdr, make a local copy */
-	memcpy(&hdr, th, sizeof(hdr));
-	hdr.check = 0;
-
-	/* options aren't included in the hash */
-	sg_init_one(&sg, &hdr, sizeof(hdr));
-	ahash_request_set_crypt(hp->md5_req, &sg, NULL, sizeof(hdr));
-	return crypto_ahash_update(hp->md5_req);
-}
-EXPORT_SYMBOL(tcp_md5_hash_header);
-
 int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 			  const struct sk_buff *skb, unsigned int header_len)
 {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3708de2a66833cf1d4a221a2b6ce3923bde978c4..8eb360c9b4a8dc6393e1dfa04957273ec7ac1e97 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1018,27 +1018,28 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 			      GFP_KERNEL);
 }
 
-static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
-					__be32 daddr, __be32 saddr, int nbytes)
+static int tcp_v4_md5_hash_headers(struct tcp_md5sig_pool *hp,
+				   __be32 daddr, __be32 saddr,
+				   const struct tcphdr *th, int nbytes)
 {
 	struct tcp4_pseudohdr *bp;
 	struct scatterlist sg;
+	struct tcphdr *_th;
 
 	bp = &hp->md5_blk.ip4;
-
-	/*
-	 * 1. the TCP pseudo-header (in the order: source IP address,
-	 * destination IP address, zero-padded protocol number, and
-	 * segment length)
-	 */
 	bp->saddr = saddr;
 	bp->daddr = daddr;
 	bp->pad = 0;
 	bp->protocol = IPPROTO_TCP;
 	bp->len = cpu_to_be16(nbytes);
 
-	sg_init_one(&sg, bp, sizeof(*bp));
-	ahash_request_set_crypt(hp->md5_req, &sg, NULL, sizeof(*bp));
+	_th = (struct tcphdr *)(bp + 1);
+	memcpy(_th, th, sizeof(*th));
+	_th->check = 0;
+
+	sg_init_one(&sg, bp, sizeof(*bp) + sizeof(*th));
+	ahash_request_set_crypt(hp->md5_req, &sg, NULL,
+				sizeof(*bp) + sizeof(*th));
 	return crypto_ahash_update(hp->md5_req);
 }
 
@@ -1055,9 +1056,7 @@ static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 
 	if (crypto_ahash_init(req))
 		goto clear_hash;
-	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
-		goto clear_hash;
-	if (tcp_md5_hash_header(hp, th))
+	if (tcp_v4_md5_hash_headers(hp, daddr, saddr, th, th->doff << 2))
 		goto clear_hash;
 	if (tcp_md5_hash_key(hp, key))
 		goto clear_hash;
@@ -1101,9 +1100,7 @@ int tcp_v4_md5_hash_skb(char *md5_hash, const struct tcp_md5sig_key *key,
 	if (crypto_ahash_init(req))
 		goto clear_hash;
 
-	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, skb->len))
-		goto clear_hash;
-	if (tcp_md5_hash_header(hp, th))
+	if (tcp_v4_md5_hash_headers(hp, daddr, saddr, th, skb->len))
 		goto clear_hash;
 	if (tcp_md5_hash_skb_data(hp, skb, th->doff << 2))
 		goto clear_hash;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f36c2d076fce0df30d202d7683a67e3614d77fe9..614d685a3c407d3c9cb62f24505f70aadc7c4873 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -526,12 +526,14 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 			      AF_INET6, cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
 }
 
-static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
-					const struct in6_addr *daddr,
-					const struct in6_addr *saddr, int nbytes)
+static int tcp_v6_md5_hash_headers(struct tcp_md5sig_pool *hp,
+				   const struct in6_addr *daddr,
+				   const struct in6_addr *saddr,
+				   const struct tcphdr *th, int nbytes)
 {
 	struct tcp6_pseudohdr *bp;
 	struct scatterlist sg;
+	struct tcphdr *_th;
 
 	bp = &hp->md5_blk.ip6;
 	/* 1. TCP pseudo-header (RFC2460) */
@@ -540,12 +542,17 @@ static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 	bp->protocol = cpu_to_be32(IPPROTO_TCP);
 	bp->len = cpu_to_be32(nbytes);
 
-	sg_init_one(&sg, bp, sizeof(*bp));
-	ahash_request_set_crypt(hp->md5_req, &sg, NULL, sizeof(*bp));
+	_th = (struct tcphdr *)(bp + 1);
+	memcpy(_th, th, sizeof(*th));
+	_th->check = 0;
+
+	sg_init_one(&sg, bp, sizeof(*bp) + sizeof(*th));
+	ahash_request_set_crypt(hp->md5_req, &sg, NULL,
+				sizeof(*bp) + sizeof(*th));
 	return crypto_ahash_update(hp->md5_req);
 }
 
-static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
+static int tcp_v6_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 			       const struct in6_addr *daddr, struct in6_addr *saddr,
 			       const struct tcphdr *th)
 {
@@ -559,9 +566,7 @@ static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
 
 	if (crypto_ahash_init(req))
 		goto clear_hash;
-	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
-		goto clear_hash;
-	if (tcp_md5_hash_header(hp, th))
+	if (tcp_v6_md5_hash_headers(hp, daddr, saddr, th, th->doff << 2))
 		goto clear_hash;
 	if (tcp_md5_hash_key(hp, key))
 		goto clear_hash;
@@ -606,9 +611,7 @@ static int tcp_v6_md5_hash_skb(char *md5_hash,
 	if (crypto_ahash_init(req))
 		goto clear_hash;
 
-	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, skb->len))
-		goto clear_hash;
-	if (tcp_md5_hash_header(hp, th))
+	if (tcp_v6_md5_hash_headers(hp, daddr, saddr, th, skb->len))
 		goto clear_hash;
 	if (tcp_md5_hash_skb_data(hp, skb, th->doff << 2))
 		goto clear_hash;
