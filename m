From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] secure_seq: initialize secret at boot instead of at runtime
Date: Sun, 15 Jan 2017 15:01:36 +0100
Message-ID: <20170115140136.23135-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:57693 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751053AbdAOOBq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Jan 2017 09:01:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the static key stuff is fast, it's not as fast as simply not
having any code to run. So, this patch generates the secret at
boot, rather than at runtime.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
I can imagine this patch not being desirable because:

  a) It was done this way in the first place for a reason. (Which?)
  b) __initcall is too early for get_random_bytes to return good
     randomness. (Is this even true?)
  c) late_initcall is too late since packets have already started
     to flow. (Is this even true?)

So if one of these holds, feel free to ignore this patch. Otherwise,
it seems like it could be worthwhile.

 net/core/secure_seq.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 758f140b6bed..fd123f3b76c1 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -16,15 +16,18 @@
 #include <net/secure_seq.h>
 
 #if IS_ENABLED(CONFIG_IPV6) || IS_ENABLED(CONFIG_INET)
+#include <linux/init.h>
 #include <linux/in6.h>
 #include <net/tcp.h>
 
 static siphash_key_t net_secret __read_mostly;
 
-static __always_inline void net_secret_init(void)
+static int net_secret_init(void)
 {
-	net_get_random_once(&net_secret, sizeof(net_secret));
+	get_random_bytes(&net_secret, sizeof(net_secret));
+	return 0;
 }
+__initcall(net_secret_init);
 #endif
 
 #ifdef CONFIG_INET
@@ -60,7 +63,6 @@ u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 		.dport = dport
 	};
 	u64 hash;
-	net_secret_init();
 	hash = siphash(&combined, offsetofend(typeof(combined), dport),
 		       &net_secret);
 	*tsoff = sysctl_tcp_timestamps == 1 ? (hash >> 32) : 0;
@@ -80,7 +82,6 @@ u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 		.daddr = *(struct in6_addr *)daddr,
 		.dport = dport
 	};
-	net_secret_init();
 	return siphash(&combined, offsetofend(typeof(combined), dport),
 		       &net_secret);
 }
@@ -99,7 +100,6 @@ u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 			       __be16 sport, __be16 dport, u32 *tsoff)
 {
 	u64 hash;
-	net_secret_init();
 	hash = siphash_3u32((__force u32)saddr, (__force u32)daddr,
 			    (__force u32)sport << 16 | (__force u32)dport,
 			    &net_secret);
@@ -109,7 +109,6 @@ u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport)
 {
-	net_secret_init();
 	return siphash_3u32((__force u32)saddr, (__force u32)daddr,
 			    (__force u16)dport, &net_secret);
 }
@@ -121,7 +120,6 @@ u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				__be16 sport, __be16 dport)
 {
 	u64 seq;
-	net_secret_init();
 	seq = siphash_3u32((__force u32)saddr, (__force u32)daddr,
 			   (__force u32)sport << 16 | (__force u32)dport,
 			   &net_secret);
@@ -147,7 +145,6 @@ u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
 		.dport = dport
 	};
 	u64 seq;
-	net_secret_init();
 	seq = siphash(&combined, offsetofend(typeof(combined), dport),
 		      &net_secret);
 	seq += ktime_get_real_ns();
-- 
2.11.0
