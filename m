From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: net_secret should not depend on TCP
Date: Tue, 24 Sep 2013 06:19:57 -0700
Message-ID: <1380028797.3165.65.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
	 <1380001118.3165.41.camel@edumazet-glaptop>
	 <20130924054532.GA24446@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:37124 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab3IXN1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 09:27:41 -0400
Received: by mail-yh0-f41.google.com with SMTP id f73so1962616yha.0
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 06:27:41 -0700 (PDT)
In-Reply-To: <20130924054532.GA24446@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A host might need net_secret[] and never open a single socket. 

Problem added in commit aebda156a570782
("net: defer net_secret[] initialization")

Based on prior patch from Hannes Frederic Sowa.

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/secure_seq.h |    1 -
 net/core/secure_seq.c    |   27 ++++++++++++++++++++++++---
 net/ipv4/af_inet.c       |    4 +---
 3 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index 6ca975b..c2e542b 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -3,7 +3,6 @@
 
 #include <linux/types.h>
 
-extern void net_secret_init(void);
 extern __u32 secure_ip_id(__be32 daddr);
 extern __u32 secure_ipv6_id(const __be32 daddr[4]);
 extern u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport);
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 6a2f13c..3f1ec15 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -10,11 +10,24 @@
 
 #include <net/secure_seq.h>
 
-static u32 net_secret[MD5_MESSAGE_BYTES / 4] ____cacheline_aligned;
+#define NET_SECRET_SIZE (MD5_MESSAGE_BYTES / 4)
 
-void net_secret_init(void)
+static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
+
+static void net_secret_init(void)
 {
-	get_random_bytes(net_secret, sizeof(net_secret));
+	u32 tmp;
+	int i;
+
+	if (likely(net_secret[0]))
+		return;
+
+	for (i = NET_SECRET_SIZE; i > 0;) {
+		do {
+			get_random_bytes(&tmp, sizeof(tmp));
+		} while (!tmp);
+		cmpxchg(&net_secret[--i], 0, tmp);
+	}
 }
 
 #ifdef CONFIG_INET
@@ -42,6 +55,7 @@ __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 	u32 hash[MD5_DIGEST_WORDS];
 	u32 i;
 
+	net_secret_init();
 	memcpy(hash, saddr, 16);
 	for (i = 0; i < 4; i++)
 		secret[i] = net_secret[i] + (__force u32)daddr[i];
@@ -63,6 +77,7 @@ u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 	u32 hash[MD5_DIGEST_WORDS];
 	u32 i;
 
+	net_secret_init();
 	memcpy(hash, saddr, 16);
 	for (i = 0; i < 4; i++)
 		secret[i] = net_secret[i] + (__force u32) daddr[i];
@@ -82,6 +97,7 @@ __u32 secure_ip_id(__be32 daddr)
 {
 	u32 hash[MD5_DIGEST_WORDS];
 
+	net_secret_init();
 	hash[0] = (__force __u32) daddr;
 	hash[1] = net_secret[13];
 	hash[2] = net_secret[14];
@@ -96,6 +112,7 @@ __u32 secure_ipv6_id(const __be32 daddr[4])
 {
 	__u32 hash[4];
 
+	net_secret_init();
 	memcpy(hash, daddr, 16);
 	md5_transform(hash, net_secret);
 
@@ -107,6 +124,7 @@ __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 {
 	u32 hash[MD5_DIGEST_WORDS];
 
+	net_secret_init();
 	hash[0] = (__force u32)saddr;
 	hash[1] = (__force u32)daddr;
 	hash[2] = ((__force u16)sport << 16) + (__force u16)dport;
@@ -121,6 +139,7 @@ u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport)
 {
 	u32 hash[MD5_DIGEST_WORDS];
 
+	net_secret_init();
 	hash[0] = (__force u32)saddr;
 	hash[1] = (__force u32)daddr;
 	hash[2] = (__force u32)dport ^ net_secret[14];
@@ -140,6 +159,7 @@ u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 	u32 hash[MD5_DIGEST_WORDS];
 	u64 seq;
 
+	net_secret_init();
 	hash[0] = (__force u32)saddr;
 	hash[1] = (__force u32)daddr;
 	hash[2] = ((__force u16)sport << 16) + (__force u16)dport;
@@ -164,6 +184,7 @@ u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
 	u64 seq;
 	u32 i;
 
+	net_secret_init();
 	memcpy(hash, saddr, 16);
 	for (i = 0; i < 4; i++)
 		secret[i] = net_secret[i] + daddr[i];
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7a1874b..cfeb85c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -263,10 +263,8 @@ void build_ehash_secret(void)
 		get_random_bytes(&rnd, sizeof(rnd));
 	} while (rnd == 0);
 
-	if (cmpxchg(&inet_ehash_secret, 0, rnd) == 0) {
+	if (cmpxchg(&inet_ehash_secret, 0, rnd) == 0)
 		get_random_bytes(&ipv6_hash_secret, sizeof(ipv6_hash_secret));
-		net_secret_init();
-	}
 }
 EXPORT_SYMBOL(build_ehash_secret);
 
