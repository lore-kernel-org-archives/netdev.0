From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH 3/3] secure_seq: use fast&secure siphash instead of slow&insecure md5
Date: Wed, 14 Dec 2016 01:16:56 +0100
Message-ID: <20161214001656.19388-3-Jason@zx2c4.com>
References: <20161214001656.19388-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	LKML <linux-kernel@vger.kernel.org>,
	George Spelvin <linux@horizon.com>,
	Scott Bauer <sbauer@eng.utah.edu>,
	Andi Kleen <ak@linux.intel.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Greg KH <gregkh@linuxfoundation.org>,
	Eric Biggers <ebiggers3@gmail.com>
Return-path: <kernel-hardening-return-5502-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161214001656.19388-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

This gives a clear speed and security improvement. Rather than manually
filling MD5 buffers, we simply create a layout by a simple anonymous
struct, for which gcc generates rather efficient code.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 net/core/secure_seq.c | 153 ++++++++++++++++++++++++--------------------------
 1 file changed, 73 insertions(+), 80 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index fd3ce461fbe6..dcee974f2fb1 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -1,3 +1,5 @@
+/* Copyright (C) 2016 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved. */
+
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/cryptohash.h>
@@ -8,13 +10,12 @@
 #include <linux/ktime.h>
 #include <linux/string.h>
 #include <linux/net.h>
-
+#include <linux/siphash.h>
+#include <linux/in6.h>
 #include <net/secure_seq.h>
 
 #if IS_ENABLED(CONFIG_IPV6) || IS_ENABLED(CONFIG_INET)
-#define NET_SECRET_SIZE (MD5_MESSAGE_BYTES / 4)
-
-static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
+static u8 net_secret[SIPHASH24_KEY_LEN];
 
 static __always_inline void net_secret_init(void)
 {
@@ -43,43 +44,36 @@ static u32 seq_scale(u32 seq)
 __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 				   __be16 sport, __be16 dport)
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
+	} __packed combined = {
+		.saddr = *(struct in6_addr *)saddr,
+		.daddr = *(struct in6_addr *)daddr,
+		.sport = sport,
+		.dport = dport
+	};
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
-	return seq_scale(hash[0]);
+	return seq_scale(siphash24((const u8 *)&combined, sizeof(combined), net_secret));
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
+	} __packed combined = {
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
+	return siphash24((const u8 *)&combined, sizeof(combined), net_secret);
 }
 EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
@@ -89,32 +83,34 @@ EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 				 __be16 sport, __be16 dport)
 {
-	u32 hash[MD5_DIGEST_WORDS];
-
+	const struct {
+		__be32 saddr;
+		__be32 daddr;
+		__be16 sport;
+		__be16 dport;
+	} __packed combined = {
+		.saddr = saddr,
+		.daddr = daddr,
+		.sport = sport,
+		.dport = dport
+	};
 	net_secret_init();
-	hash[0] = (__force u32)saddr;
-	hash[1] = (__force u32)daddr;
-	hash[2] = ((__force u16)sport << 16) + (__force u16)dport;
-	hash[3] = net_secret[15];
-
-	md5_transform(hash, net_secret);
-
-	return seq_scale(hash[0]);
+	return seq_scale(siphash24((const u8 *)&combined, sizeof(combined), net_secret));
 }
 
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport)
 {
-	u32 hash[MD5_DIGEST_WORDS];
-
+	const struct {
+		__be32 saddr;
+		__be32 daddr;
+		__be16 dport;
+	} __packed combined = {
+		.saddr = saddr,
+		.daddr = daddr,
+		.dport = dport
+	};
 	net_secret_init();
-	hash[0] = (__force u32)saddr;
-	hash[1] = (__force u32)daddr;
-	hash[2] = (__force u32)dport ^ net_secret[14];
-	hash[3] = net_secret[15];
-
-	md5_transform(hash, net_secret);
-
-	return hash[0];
+	return seq_scale(siphash24((const u8 *)&combined, sizeof(combined), net_secret));
 }
 EXPORT_SYMBOL_GPL(secure_ipv4_port_ephemeral);
 #endif
@@ -123,21 +119,22 @@ EXPORT_SYMBOL_GPL(secure_ipv4_port_ephemeral);
 u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				__be16 sport, __be16 dport)
 {
-	u32 hash[MD5_DIGEST_WORDS];
+	const struct {
+		__be32 saddr;
+		__be32 daddr;
+		__be16 sport;
+		__be16 dport;
+	} __packed combined = {
+		.saddr = saddr,
+		.daddr = daddr,
+		.sport = sport,
+		.dport = dport
+	};
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
+	seq = siphash24((const u8 *)&combined, sizeof(combined), net_secret);
 	seq += ktime_get_real_ns();
 	seq &= (1ull << 48) - 1;
-
 	return seq;
 }
 EXPORT_SYMBOL(secure_dccp_sequence_number);
@@ -146,26 +143,22 @@ EXPORT_SYMBOL(secure_dccp_sequence_number);
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
+	} __packed combined = {
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
+	seq = siphash24((const u8 *)&combined, sizeof(combined), net_secret);
 	seq += ktime_get_real_ns();
 	seq &= (1ull << 48) - 1;
-
 	return seq;
 }
 EXPORT_SYMBOL(secure_dccpv6_sequence_number);
-- 
2.11.0
