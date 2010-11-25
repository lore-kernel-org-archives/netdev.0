From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: [PATCH 1/2] Prepare the tree for un-inlined jhash.
Date: Thu, 25 Nov 2010 14:15:07 +0100
Message-ID: <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu>
References: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jhash is widely used in the kernel and because the functions
are inlined, the cost in size is significant. Also, the new jhash
functions are slightly larger than the previous ones so better un-inline.
As a preparation step, the calls to the internal macros are replaced
with the plain jhash function calls.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/ipv6/inet6_connection_sock.c |   18 ++++++++----------
 net/ipv6/reassembly.c            |   36 ++++++++++++++++--------------------
 2 files changed, 24 insertions(+), 30 deletions(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 8a16280..861d252 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -60,18 +60,16 @@ EXPORT_SYMBOL_GPL(inet6_csk_bind_conflict);
 static u32 inet6_synq_hash(const struct in6_addr *raddr, const __be16 rport,
 			   const u32 rnd, const u16 synq_hsize)
 {
-	u32 a = (__force u32)raddr->s6_addr32[0];
-	u32 b = (__force u32)raddr->s6_addr32[1];
-	u32 c = (__force u32)raddr->s6_addr32[2];
-
-	a += JHASH_GOLDEN_RATIO;
-	b += JHASH_GOLDEN_RATIO;
-	c += rnd;
-	__jhash_mix(a, b, c);
-
-	a += (__force u32)raddr->s6_addr32[3];
-	b += (__force u32)rport;
-	__jhash_mix(a, b, c);
+	u32 c;
+
+	c = jhash_3words((__force u32)raddr->s6_addr32[0],
+			 (__force u32)raddr->s6_addr32[1],
+			 (__force u32)raddr->s6_addr32[2],
+			 rnd);
+
+	c = jhash_2words((__force u32)raddr->s6_addr32[3],
+			 (__force u32)rport,
+			 c);
 
 	return c & (synq_hsize - 1);
 }
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index c7ba314..5e57490 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -104,26 +104,22 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
 			     const struct in6_addr *daddr, u32 rnd)
 {
-	u32 a, b, c;
-
-	a = (__force u32)saddr->s6_addr32[0];
-	b = (__force u32)saddr->s6_addr32[1];
-	c = (__force u32)saddr->s6_addr32[2];
-
-	a += JHASH_GOLDEN_RATIO;
-	b += JHASH_GOLDEN_RATIO;
-	c += rnd;
-	__jhash_mix(a, b, c);
-
-	a += (__force u32)saddr->s6_addr32[3];
-	b += (__force u32)daddr->s6_addr32[0];
-	c += (__force u32)daddr->s6_addr32[1];
-	__jhash_mix(a, b, c);
-
-	a += (__force u32)daddr->s6_addr32[2];
-	b += (__force u32)daddr->s6_addr32[3];
-	c += (__force u32)id;
-	__jhash_mix(a, b, c);
+	u32 c;
+
+	c = jhash_3words((__force u32)saddr->s6_addr32[0],
+			 (__force u32)saddr->s6_addr32[1],
+			 (__force u32)saddr->s6_addr32[2],
+			 rnd);
+
+	c = jhash_3words((__force u32)saddr->s6_addr32[3],
+			 (__force u32)daddr->s6_addr32[0],
+			 (__force u32)daddr->s6_addr32[1],
+			 c);
+
+	c =  jhash_3words((__force u32)daddr->s6_addr32[2],
+			  (__force u32)daddr->s6_addr32[3],
+			  (__force u32)id,
+			  c);
 
 	return c & (INETFRAGS_HASHSZ - 1);
 }
-- 
1.7.0.4

