From: Crestez Dan Leonard <cdleonard@gmail.com>
Subject: [RFC] tcp md5 use of alloc_percpu
Date: Wed, 22 Oct 2014 21:55:46 +0300
Message-ID: <5447FDB2.2010906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:47002 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbaJVSzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 14:55:50 -0400
Received: by mail-wg0-f48.google.com with SMTP id k14so4408689wgh.7
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 11:55:49 -0700 (PDT)
Received: from [10.205.20.121] ([109.100.41.154])
        by mx.google.com with ESMTPSA id t16sm16923735wjr.44.2014.10.22.11.55.47
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 11:55:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

It seems that the TCP MD5 feature allocates a percpu struct tcp_md5sig_pool and uses part of that memory for a scratch buffer to do crypto on. Here is the relevant code:

static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
                                        __be32 daddr, __be32 saddr, int nbytes)
{
        struct tcp4_pseudohdr *bp;
        struct scatterlist sg;

        bp = &hp->md5_blk.ip4;

        /*
         * 1. the TCP pseudo-header (in the order: source IP address,
         * destination IP address, zero-padded protocol number, and
         * segment length)
         */
        bp->saddr = saddr;
        bp->daddr = daddr;
        bp->pad = 0;
        bp->protocol = IPPROTO_TCP;
        bp->len = cpu_to_be16(nbytes);

        sg_init_one(&sg, bp, sizeof(*bp));
        return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
}

sg_init_one does virt_addr on the pointer which assumes it is directly accessible. But the tcp_md5sig_pool pointer comes from alloc_percpu which can return memory from the vmalloc area after the pcpu_first_chunk is exhausted. This looks wrong to me. I'm am getting crashes on mips and I believe this to be the cause.

Allocating a scratch buffer this way is very peculiar. The tcp4_pseudohdr struct is only 12 bytes in length. Similar code in tcp_v6_md5_hash_pseudoheader uses a 40 byte tcp6_pseudohdr. I think it is perfectly reasonable to allocate this kind of stuff on the stack, right? These pseudohdr structs are not used at all outside these two static functions and it would simplify the code.

The whole notion of struct tcp_md5sig_pool seems dubious. This is a very tiny struct already and after removing the pseudohdr it shrinks to a percpu hash_desc for md5 (8 or 16 bytes). Wouldn't DEFINE_PERCPU be more appropriate? Before commit 71cea17ed39fdf1c0634f530ddc6a2c2fc601c2b the struct tcp_md5sig_pool structs were freed when all users were gone, but that functionality seems to have been dropped.

I'm not familiar with the linux crypto API. Isn't there an easier way to get a temporary md5 hasher?

Here's what I mean by allocating tcp{4,6}_pseudohdr on the stack:

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4062b4f..beabd7b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1266,33 +1266,9 @@ struct tcp_md5sig_info {
 	struct rcu_head		rcu;
 };
 
-/* - pseudo header */
-struct tcp4_pseudohdr {
-	__be32		saddr;
-	__be32		daddr;
-	__u8		pad;
-	__u8		protocol;
-	__be16		len;
-};
-
-struct tcp6_pseudohdr {
-	struct in6_addr	saddr;
-	struct in6_addr daddr;
-	__be32		len;
-	__be32		protocol;	/* including padding */
-};
-
-union tcp_md5sum_block {
-	struct tcp4_pseudohdr ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-	struct tcp6_pseudohdr ip6;
-#endif
-};
-
 /* - pool: digest algorithm, hash description and scratch buffer */
 struct tcp_md5sig_pool {
 	struct hash_desc	md5_desc;
-	union tcp_md5sum_block	md5_blk;
 };
 
 /* - functions */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 94d1a77..e716a67 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1041,27 +1041,33 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 			      GFP_KERNEL);
 }
 
+struct tcp4_pseudohdr {
+	__be32		saddr;
+	__be32		daddr;
+	__u8		pad;
+	__u8		protocol;
+	__be16		len;
+};
+
 static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 					__be32 daddr, __be32 saddr, int nbytes)
 {
-	struct tcp4_pseudohdr *bp;
+	struct tcp4_pseudohdr bp;
 	struct scatterlist sg;
 
-	bp = &hp->md5_blk.ip4;
-
 	/*
 	 * 1. the TCP pseudo-header (in the order: source IP address,
 	 * destination IP address, zero-padded protocol number, and
 	 * segment length)
 	 */
-	bp->saddr = saddr;
-	bp->daddr = daddr;
-	bp->pad = 0;
-	bp->protocol = IPPROTO_TCP;
-	bp->len = cpu_to_be16(nbytes);
-
-	sg_init_one(&sg, bp, sizeof(*bp));
-	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
+	bp.saddr = saddr;
+	bp.daddr = daddr;
+	bp.pad = 0;
+	bp.protocol = IPPROTO_TCP;
+	bp.len = cpu_to_be16(nbytes);
+
+	sg_init_one(&sg, &bp, sizeof(bp));
+	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(bp));
 }
 
 static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8314955..87a9126 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -568,22 +568,28 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 			      AF_INET6, cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
 }
 
+struct tcp6_pseudohdr {
+	struct in6_addr	saddr;
+	struct in6_addr daddr;
+	__be32		len;
+	__be32		protocol;	/* including padding */
+};
+
 static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 					const struct in6_addr *daddr,
 					const struct in6_addr *saddr, int nbytes)
 {
-	struct tcp6_pseudohdr *bp;
+	struct tcp6_pseudohdr bp;
 	struct scatterlist sg;
 
-	bp = &hp->md5_blk.ip6;
 	/* 1. TCP pseudo-header (RFC2460) */
-	bp->saddr = *saddr;
-	bp->daddr = *daddr;
-	bp->protocol = cpu_to_be32(IPPROTO_TCP);
-	bp->len = cpu_to_be32(nbytes);
+	bp.saddr = *saddr;
+	bp.daddr = *daddr;
+	bp.protocol = cpu_to_be32(IPPROTO_TCP);
+	bp.len = cpu_to_be32(nbytes);
 
-	sg_init_one(&sg, bp, sizeof(*bp));
-	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
+	sg_init_one(&sg, &bp, sizeof(bp));
+	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(bp));
 }
 
 static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
