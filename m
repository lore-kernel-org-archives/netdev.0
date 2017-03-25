From: Florian Westphal <fw@strlen.de>
Subject: [PATCH stable 4.10] secure_seq: downgrade to per-host timestamp offsets
Date: Sat, 25 Mar 2017 10:58:24 +0100
Message-ID: <20170325095824.8292-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        "David S . Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43264 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751088AbdCYJ6T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 05:58:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 28ee1b746f493b7c62347d714f58fbf4f70df4f0 upstream.

Unfortunately too many devices (not under our control) use tcp_tw_recycle=1,
which depends on timestamps being identical of the same saddr.

Although tcp_tw_recycle got removed in net-next we can't make
such end hosts disappear so downgrade to per-host timestamp offsets.

4.10 note: original patch uses siphash (added in 4.11), since
ts_off is only used to obscure uptime (and doesn't use same secret
as isn generator) this uses jhash instead.

Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Reported-by: Yvan Vanrossomme <yvan@vanrossomme.net>
Fixes: 95a22caee396c ("tcp: randomize tcp timestamp offsets for each connection")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/secure_seq.c | 29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 88a8e429fc3e..2aee073b919e 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -16,9 +16,11 @@
 #define NET_SECRET_SIZE (MD5_MESSAGE_BYTES / 4)
 
 static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
+static u32 ts_secret[2];
 
 static __always_inline void net_secret_init(void)
 {
+	net_get_random_once(ts_secret, sizeof(ts_secret));
 	net_get_random_once(net_secret, sizeof(net_secret));
 }
 #endif
@@ -41,6 +43,21 @@ static u32 seq_scale(u32 seq)
 #endif
 
 #if IS_ENABLED(CONFIG_IPV6)
+static u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr)
+{
+	u32 hash[4 + 4 + 1];
+
+	if (sysctl_tcp_timestamps != 1)
+		return 0;
+
+	memcpy(hash, saddr, 16);
+	memcpy(hash + 4, daddr, 16);
+
+	hash[8] = ts_secret[0];
+
+	return jhash2(hash, ARRAY_SIZE(hash), ts_secret[1]);
+}
+
 u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 				 __be16 sport, __be16 dport, u32 *tsoff)
 {
@@ -59,7 +76,7 @@ u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 
 	md5_transform(hash, secret);
 
-	*tsoff = sysctl_tcp_timestamps == 1 ? hash[1] : 0;
+	*tsoff = secure_tcpv6_ts_off(saddr, daddr);
 	return seq_scale(hash[0]);
 }
 EXPORT_SYMBOL(secure_tcpv6_sequence_number);
@@ -87,6 +104,14 @@ EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
 
 #ifdef CONFIG_INET
+static u32 secure_tcp_ts_off(__be32 saddr, __be32 daddr)
+{
+	if (sysctl_tcp_timestamps != 1)
+		return 0;
+
+	return jhash_3words((__force u32)saddr, (__force u32)daddr,
+			    ts_secret[0], ts_secret[1]);
+}
 
 u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 			       __be16 sport, __be16 dport, u32 *tsoff)
@@ -101,7 +126,7 @@ u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 
 	md5_transform(hash, net_secret);
 
-	*tsoff = sysctl_tcp_timestamps == 1 ? hash[1] : 0;
+	*tsoff = secure_tcp_ts_off(saddr, daddr);
 	return seq_scale(hash[0]);
 }
 
-- 
2.10.2
