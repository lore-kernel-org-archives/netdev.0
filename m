From: Tom Herbert <therbert@google.com>
Subject: (unknown)
Date: Mon, 23 Sep 2013 15:41:46 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1309231535460.23966@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:62452 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab3IWWls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 18:41:48 -0400
Received: by mail-qc0-f202.google.com with SMTP id r5so438497qcx.5
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 15:41:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From cf54b0651b7ea35fab4c398f1732e800550732ef Mon Sep 17 00:00:00 2001
From: Tom Herbert <therbert@google.com>
Date: Mon, 23 Sep 2013 12:27:17 -0700
Subject: [PATCH 2/2] net: Use Toeplitz for IPv4 and IPv6 connection hashing

Add a config option to specify which hash to use for IPv4 and IPv6
established connection hashing. The alternative option is original
jhash method (this patch sets Toeplitz to default).

Toeplitz is a little more heavy weight than jhash method.  For IPv4
the difference seems to be negligible, for IPv6 there is some
performance regression due mostly to the fact that Toeplitz hashes
over all the bits in the IPv6 address whereas Jhash doesn't (this
implies that Toeplitz might be more secure).

Some performance numbers using 200 netperf TCP_RR clients:

Toeplitz
  IPv4
    58.72% CPU utilization
    110/146/198 90/95/99% latencies
    1.72549e+06 tps
  IPv6
    72.38% CPU utilization
    117/168/255 90/95/99% latencies
    1.58545e+06 tps

Jhash
  IPv4
    57.67% CPU utilization
    111/146/196 90/95/99% latencies
    1.71574e+06 tps
  IPv6
    71.84% CPU utilization
    117/166/248 90/95/99% latencies
    1.59359e+06 tps

Standalone performance measurement:

Toeplitz
  IPv4
    40 nsecs/hash
  IPv6
    105 nsecs/hash
Jhash
  IPv4
    39 nsecs/hash
  IPv6
    77 nsecs/hash

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/inet6_hashtables.h | 16 ++++++++++++++++
 include/net/inet_sock.h        | 16 ++++++++++++++++
 net/ipv4/Kconfig               | 14 ++++++++++++++
 3 files changed, 46 insertions(+)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index f52fa88..492a45b 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -32,12 +32,28 @@ static inline unsigned int inet6_ehashfn(struct net *net,
 				const struct in6_addr *laddr, const u16 lport,
 				const struct in6_addr *faddr, const __be16 fport)
 {
+#if IS_ENABLED(CONFIG_IP_HASH_TOEPLITZ)
+	struct {
+		struct in6_addr saddr;
+		struct in6_addr daddr;
+		u16 sport;
+		u16 dport;
+	} input;
+
+        input.daddr = *laddr;
+        input.saddr = *faddr;
+        input.sport = htons(lport);
+        input.dport = fport;
+
+        return toeplitz_hash((u8 *)&input, toeplitz_net, sizeof(input));
+#else
 	u32 ports = (((u32)lport) << 16) | (__force u32)fport;
 
 	return jhash_3words((__force u32)laddr->s6_addr32[3],
 			    ipv6_addr_jhash(faddr),
 			    ports,
 			    inet_ehash_secret + net_hash_mix(net));
+#endif
 }
 
 static inline int inet6_sk_ehashfn(const struct sock *sk)
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 636d203..02e2ee2 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -209,10 +209,26 @@ static inline unsigned int inet_ehashfn(struct net *net,
 					const __be32 laddr, const __u16 lport,
 					const __be32 faddr, const __be16 fport)
 {
+#if IS_ENABLED(CONFIG_IP_HASH_TOEPLITZ)
+	struct {
+		u32 saddr;
+		u32 daddr;
+		u16 sport;
+		u16 dport;
+	} input;
+
+	input.saddr = faddr;
+	input.daddr = laddr;
+	input.sport = fport;
+	input.dport = htons(lport);
+
+	return toeplitz_hash((u8 *)&input, toeplitz_net, sizeof(input));
+#else
 	return jhash_3words((__force __u32) laddr,
 			    (__force __u32) faddr,
 			    ((__u32) lport) << 16 | (__force __u32)fport,
 			    inet_ehash_secret + net_hash_mix(net));
+#endif
 }
 
 static inline int inet_sk_ehashfn(const struct sock *sk)
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 05c57f0..c9a533f 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -104,6 +104,20 @@ config IP_ROUTE_VERBOSE
 config IP_ROUTE_CLASSID
 	bool
 
+choice
+	prompt "IP: connection hashing algorithm"
+	default IP_HASH_TOEPLITZ
+	help
+	  Select the default hashing algortihm for IP connections
+
+	config IP_HASH_JHASH
+		bool "Jhash"
+
+	config IP_HASH_TOEPLITZ
+		bool "Toeplitz"
+		select NET_TOEPLITZ
+endchoice
+
 config IP_PNP
 	bool "IP: kernel level autoconfiguration"
 	help
-- 
1.8.4
