From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v7 2/6] secure_seq: use SipHash in place of MD5
Date: Thu, 22 Dec 2016 00:02:12 +0100
Message-ID: <20161221230216.25341-3-Jason@zx2c4.com>
References: <20161216030328.11602-1-Jason@zx2c4.com>
 <20161221230216.25341-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org,
	David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	edumazet@google.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	ak@linux.intel.com,
	davem@davemloft.net,
	luto@amacapital.net,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <kernel-hardening-return-5749-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161221230216.25341-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

This gives a clear speed and security improvement. Siphash is both
faster and is more solid crypto than the aging MD5.

Rather than manually filling MD5 buffers, for IPv6, we simply create
a layout by a simple anonymous struct, for which gcc generates
rather efficient code. For IPv4, we pass the values directly to the
short input convenience functions.

64-bit x86_64:
[    1.683628] secure_tcpv6_sequence_number_md5# cycles: 99563527
[    1.717350] secure_tcp_sequence_number_md5# cycles: 92890502
[    1.741968] secure_tcpv6_sequence_number_siphash# cycles: 67825362
[    1.762048] secure_tcp_sequence_number_siphash# cycles: 67485526

32-bit x86:
[    1.600012] secure_tcpv6_sequence_number_md5# cycles: 103227892
[    1.634219] secure_tcp_sequence_number_md5# cycles: 94732544
[    1.669102] secure_tcpv6_sequence_number_siphash# cycles: 96299384
[    1.700165] secure_tcp_sequence_number_siphash# cycles: 86015473

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: David Miller <davem@davemloft.net>
Cc: David Laight <David.Laight@aculab.com>
Cc: Tom Herbert <tom@herbertland.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/secure_seq.c | 135 ++++++++++++++++++++------------------------------
 1 file changed, 54 insertions(+), 81 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 88a8e429fc3e..3dc2689bcc64 100644
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
@@ -44,80 +46,65 @@ static u32 seq_scale(u32 seq)
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
+	hash = siphash(&combined, offsetofend(typeof(combined), dport), net_secret);
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
+	return siphash(&combined, offsetofend(typeof(combined), dport), net_secret);
 }
 EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
 
 #ifdef CONFIG_INET
 
+/* secure_tcp_sequence_number(a, b, 0, d) == secure_ipv4_port_ephemeral(a, b, d),
+ * but fortunately, `sport' cannot be 0 in any circumstances. If this changes,
+ * it would be easy enough to have the former function use siphash_4u32, passing
+ * the arguments as separate u32.
+ */
+
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
+	hash = siphash_3u32(saddr, daddr, (u32)sport << 16 | dport, net_secret);
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
+	return siphash_3u32(saddr, daddr, dport, net_secret);
 }
 EXPORT_SYMBOL_GPL(secure_ipv4_port_ephemeral);
 #endif
@@ -126,21 +113,11 @@ EXPORT_SYMBOL_GPL(secure_ipv4_port_ephemeral);
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
+	seq = siphash_3u32(saddr, daddr, (u32)sport << 16 | dport, net_secret);
 	seq += ktime_get_real_ns();
 	seq &= (1ull << 48) - 1;
-
 	return seq;
 }
 EXPORT_SYMBOL(secure_dccp_sequence_number);
@@ -149,26 +126,22 @@ EXPORT_SYMBOL(secure_dccp_sequence_number);
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
+	seq = siphash(&combined, offsetofend(typeof(combined), dport), net_secret);
 	seq += ktime_get_real_ns();
 	seq &= (1ull << 48) - 1;
-
 	return seq;
 }
 EXPORT_SYMBOL(secure_dccpv6_sequence_number);
-- 
2.11.0
