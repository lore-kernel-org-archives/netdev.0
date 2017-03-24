From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] secure_seq: downgrade to per-host timestamp offsets
Date: Fri, 24 Mar 2017 19:42:37 +0100
Message-ID: <20170324184237.16044-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41008 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965619AbdCXSm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 14:42:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunately too many devices (not under our control) use tcp_tw_recycle=1,
which depends on timestamps being identical of the same saddr.

Although tcp_tw_recycle got removed in net-next we can't make
such end hosts disappear so downgrade to per-host timestamp offsets.

Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Reported-by: Yvan Vanrossomme <yvan@vanrossomme.net>
Fixes: 95a22caee396c ("tcp: randomize tcp timestamp offsets for each connection")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
Got offlist report about this, the device in question was an IP camera.

David, I can cook a stable patch using jhash if needed, just let me know
(siphash was added after 4.10).

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 758f140b6bed..d28da7d363f1 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -20,9 +20,11 @@
 #include <net/tcp.h>
 
 static siphash_key_t net_secret __read_mostly;
+static siphash_key_t ts_secret __read_mostly;
 
 static __always_inline void net_secret_init(void)
 {
+	net_get_random_once(&ts_secret, sizeof(ts_secret));
 	net_get_random_once(&net_secret, sizeof(net_secret));
 }
 #endif
@@ -45,6 +47,23 @@ static u32 seq_scale(u32 seq)
 #endif
 
 #if IS_ENABLED(CONFIG_IPV6)
+static u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr)
+{
+	const struct {
+		struct in6_addr saddr;
+		struct in6_addr daddr;
+	} __aligned(SIPHASH_ALIGNMENT) combined = {
+		.saddr = *(struct in6_addr *)saddr,
+		.daddr = *(struct in6_addr *)daddr,
+	};
+
+	if (sysctl_tcp_timestamps != 1)
+		return 0;
+
+	return siphash(&combined, offsetofend(typeof(combined), daddr),
+		       &ts_secret);
+}
+
 u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 				 __be16 sport, __be16 dport, u32 *tsoff)
 {
@@ -63,7 +82,7 @@ u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 	net_secret_init();
 	hash = siphash(&combined, offsetofend(typeof(combined), dport),
 		       &net_secret);
-	*tsoff = sysctl_tcp_timestamps == 1 ? (hash >> 32) : 0;
+	*tsoff = secure_tcpv6_ts_off(saddr, daddr);
 	return seq_scale(hash);
 }
 EXPORT_SYMBOL(secure_tcpv6_sequence_number);
@@ -88,6 +107,14 @@ EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
 
 #ifdef CONFIG_INET
+static u32 secure_tcp_ts_off(__be32 saddr, __be32 daddr)
+{
+	if (sysctl_tcp_timestamps != 1)
+		return 0;
+
+	return siphash_2u32((__force u32)saddr, (__force u32)daddr,
+			    &ts_secret);
+}
 
 /* secure_tcp_sequence_number(a, b, 0, d) == secure_ipv4_port_ephemeral(a, b, d),
  * but fortunately, `sport' cannot be 0 in any circumstances. If this changes,
@@ -103,7 +130,7 @@ u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 	hash = siphash_3u32((__force u32)saddr, (__force u32)daddr,
 			    (__force u32)sport << 16 | (__force u32)dport,
 			    &net_secret);
-	*tsoff = sysctl_tcp_timestamps == 1 ? (hash >> 32) : 0;
+	*tsoff = secure_tcp_ts_off(saddr, daddr);
 	return seq_scale(hash);
 }
 
-- 
2.10.2
