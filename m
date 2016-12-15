From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v5 3/4] secure_seq: use SipHash in place of MD5
Date: Thu, 15 Dec 2016 21:30:02 +0100
Message-ID: <20161215203003.31989-4-Jason@zx2c4.com>
References: <20161215203003.31989-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org,
	David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	George Spelvin <linux@sciencehorizons.net>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	ak@linux.intel.com,
	davem@davemloft.net,
	luto@amacapital.net
Return-path: <kernel-hardening-return-5594-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161215203003.31989-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

This gives a clear speed and security improvement. Siphash is both
faster and is more solid crypto than the aging MD5.

Rather than manually filling MD5 buffers, for IPv6, we simply create
a layout by a simple anonymous struct, for which gcc generates
rather efficient code. For IPv4, we pass the values directly to the
short input convenience functions.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: David Miller <davem@davemloft.net>
Cc: David Laight <David.Laight@aculab.com>
Cc: Tom Herbert <tom@herbertland.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/secure_seq.c | 133 ++++++++++++++++++++------------------------------
 1 file changed, 52 insertions(+), 81 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 88a8e429fc3e..c80583bf3213 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -1,3 +1,5 @@
+/* Copyright (C) 2016 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved. */
+
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/cryptohash.h>
@@ -8,14 +10,14 @@
 #include <linux/ktime.h>
 #include <linux/string.h>
 #include <linux/net.h>
-
+#include <linux/siphash.h>
 #include <net/secure_seq.h>
 
 #if IS_ENABLED(CONFIG_IPV6) || IS_ENABLED(CONFIG_INET)
+#include <linux/in6.h>
 #include <net/tcp.h>
-#define NET_SECRET_SIZE (MD5_MESSAGE_BYTES / 4)
 
-static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
+static siphash_key_t net_secret;
 
 static __always_inline void net_secret_init(void)
 {
@@ -44,44 +46,42 @@ static u32 seq_scale(u32 seq)
 u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 				 __be16 sport, __be16 dport, u32 *tsoff)
 {
-	u32 secret[MD5_MESSAGE_BYTES / 4];
-	u32 hash[MD5_DIGEST_WORDS];
-	u32 i;
-
+	const struct {
+		struct in6_addr saddr;
+		struct in6_addr daddr;
+		__be16 sport;
+		__be16 dport;
+		u32 padding;
+	} __aligned(SIPHASH_ALIGNMENT) combined = {
+		.saddr = *(struct in6_addr *)saddr,
+		.daddr = *(struct in6_addr *)daddr,
+		.sport = sport,
+		.dport = dport
+	};
+	u64 hash;
 	net_secret_init();
-	memcpy(hash, saddr, 16);
-	for (i = 0; i < 4; i++)
-		secret[i] = net_secret[i] + (__force u32)daddr[i];
-	secret[4] = net_secret[4] +
-		(((__force u16)sport << 16) + (__force u16)dport);
-	for (i = 5; i < MD5_MESSAGE_BYTES / 4; i++)
-		secret[i] = net_secret[i];
-
-	md5_transform(hash, secret);
-
-	*tsoff = sysctl_tcp_timestamps == 1 ? hash[1] : 0;
-	return seq_scale(hash[0]);
+	hash = siphash(&combined, sizeof(combined), net_secret);
+	*tsoff = sysctl_tcp_timestamps == 1 ? (hash >> 32) : 0;
+	return seq_scale(hash);
 }
 EXPORT_SYMBOL(secure_tcpv6_sequence_number);
 
 u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 			       __be16 dport)
 {
-	u32 secret[MD5_MESSAGE_BYTES / 4];
-	u32 hash[MD5_DIGEST_WORDS];
-	u32 i;
-
+	const struct {
+		struct in6_addr saddr;
+		struct in6_addr daddr;
+		__be16 dport;
+		u16 padding1;
+		u32 padding2;
+	} __aligned(SIPHASH_ALIGNMENT) combined = {
+		.saddr = *(struct in6_addr *)saddr,
+		.daddr = *(struct in6_addr *)daddr,
+		.dport = dport
+	};
 	net_secret_init();
-	memcpy(hash, saddr, 16);
-	for (i = 0; i < 4; i++)
-		secret[i] = net_secret[i] + (__force u32) daddr[i];
-	secret[4] = net_secret[4] + (__force u32)dport;
-	for (i = 5; i < MD5_MESSAGE_BYTES / 4; i++)
-		secret[i] = net_secret[i];
-
-	md5_transform(hash, secret);
-
-	return hash[0];
+	return siphash(&combined, sizeof(combined), net_secret);
 }
 EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
@@ -91,33 +91,17 @@ EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 			       __be16 sport, __be16 dport, u32 *tsoff)
 {
-	u32 hash[MD5_DIGEST_WORDS];
-
+	u64 hash;
 	net_secret_init();
-	hash[0] = (__force u32)saddr;
-	hash[1] = (__force u32)daddr;
-	hash[2] = ((__force u16)sport << 16) + (__force u16)dport;
-	hash[3] = net_secret[15];
-
-	md5_transform(hash, net_secret);
-
-	*tsoff = sysctl_tcp_timestamps == 1 ? hash[1] : 0;
-	return seq_scale(hash[0]);
+	hash = siphash_4u32(saddr, daddr, sport, dport, net_secret);
+	*tsoff = sysctl_tcp_timestamps == 1 ? (hash >> 32) : 0;
+	return seq_scale(hash);
 }
 
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport)
 {
-	u32 hash[MD5_DIGEST_WORDS];
-
 	net_secret_init();
-	hash[0] = (__force u32)saddr;
-	hash[1] = (__force u32)daddr;
-	hash[2] = (__force u32)dport ^ net_secret[14];
-	hash[3] = net_secret[15];
-
-	md5_transform(hash, net_secret);
-
-	return hash[0];
+	return siphash_4u32(saddr, daddr, dport, 0, net_secret);
 }
 EXPORT_SYMBOL_GPL(secure_ipv4_port_ephemeral);
 #endif
@@ -126,21 +110,11 @@ EXPORT_SYMBOL_GPL(secure_ipv4_port_ephemeral);
 u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				__be16 sport, __be16 dport)
 {
-	u32 hash[MD5_DIGEST_WORDS];
 	u64 seq;
-
 	net_secret_init();
-	hash[0] = (__force u32)saddr;
-	hash[1] = (__force u32)daddr;
-	hash[2] = ((__force u16)sport << 16) + (__force u16)dport;
-	hash[3] = net_secret[15];
-
-	md5_transform(hash, net_secret);
-
-	seq = hash[0] | (((u64)hash[1]) << 32);
+	seq = siphash_4u32(saddr, daddr, sport, dport, net_secret);
 	seq += ktime_get_real_ns();
 	seq &= (1ull << 48) - 1;
-
 	return seq;
 }
 EXPORT_SYMBOL(secure_dccp_sequence_number);
@@ -149,26 +123,23 @@ EXPORT_SYMBOL(secure_dccp_sequence_number);
 u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
 				  __be16 sport, __be16 dport)
 {
-	u32 secret[MD5_MESSAGE_BYTES / 4];
-	u32 hash[MD5_DIGEST_WORDS];
+	const struct {
+		struct in6_addr saddr;
+		struct in6_addr daddr;
+		__be16 sport;
+		__be16 dport;
+		u32 padding;
+	} __aligned(SIPHASH_ALIGNMENT) combined = {
+		.saddr = *(struct in6_addr *)saddr,
+		.daddr = *(struct in6_addr *)daddr,
+		.sport = sport,
+		.dport = dport
+	};
 	u64 seq;
-	u32 i;
-
 	net_secret_init();
-	memcpy(hash, saddr, 16);
-	for (i = 0; i < 4; i++)
-		secret[i] = net_secret[i] + (__force u32)daddr[i];
-	secret[4] = net_secret[4] +
-		(((__force u16)sport << 16) + (__force u16)dport);
-	for (i = 5; i < MD5_MESSAGE_BYTES / 4; i++)
-		secret[i] = net_secret[i];
-
-	md5_transform(hash, secret);
-
-	seq = hash[0] | (((u64)hash[1]) << 32);
+	seq = siphash(&combined, sizeof(combined), net_secret);
 	seq += ktime_get_real_ns();
 	seq &= (1ull << 48) - 1;
-
 	return seq;
 }
 EXPORT_SYMBOL(secure_dccpv6_sequence_number);
-- 
2.11.0
