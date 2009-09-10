From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 17/31: xtables: use memcmp in unconditional check
Date: Thu, 10 Sep 2009 18:12:08 +0200 (MEST)
Message-ID: <20090910161204.31179.59243.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 47901dc2c4a3f1f9af453486a005d31fe9b393f0
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Jul 9 23:00:19 2009 +0200

    netfilter: xtables: use memcmp in unconditional check
    
    Instead of inspecting each u32/char open-coded, clean up and make use
    of memcmp. On some arches, memcmp is implemented as assembly or GCC's
    __builtin_memcmp which can possibly take advantages of known
    alignment.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 7505dff..b9f7243 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -341,15 +341,11 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 }
 
 /* All zeroes == unconditional rule. */
-static inline int unconditional(const struct arpt_arp *arp)
+static inline bool unconditional(const struct arpt_arp *arp)
 {
-	unsigned int i;
-
-	for (i = 0; i < sizeof(*arp)/sizeof(__u32); i++)
-		if (((__u32 *)arp)[i])
-			return 0;
+	static const struct arpt_arp uncond;
 
-	return 1;
+	return memcmp(arp, &uncond, sizeof(uncond)) == 0;
 }
 
 /* Figures out from what hook each rule can be called: returns 0 if
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3856aa3..3431a77 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -190,16 +190,11 @@ get_entry(void *base, unsigned int offset)
 
 /* All zeroes == unconditional rule. */
 /* Mildly perf critical (only if packet tracing is on) */
-static inline int
-unconditional(const struct ipt_ip *ip)
+static inline bool unconditional(const struct ipt_ip *ip)
 {
-	unsigned int i;
+	static const struct ipt_ip uncond;
 
-	for (i = 0; i < sizeof(*ip)/sizeof(__u32); i++)
-		if (((__u32 *)ip)[i])
-			return 0;
-
-	return 1;
+	return memcmp(ip, &uncond, sizeof(uncond)) == 0;
 #undef FWINV
 }
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index ced1f2c..1389ad9 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -222,16 +222,11 @@ get_entry(void *base, unsigned int offset)
 
 /* All zeroes == unconditional rule. */
 /* Mildly perf critical (only if packet tracing is on) */
-static inline int
-unconditional(const struct ip6t_ip6 *ipv6)
+static inline bool unconditional(const struct ip6t_ip6 *ipv6)
 {
-	unsigned int i;
-
-	for (i = 0; i < sizeof(*ipv6); i++)
-		if (((char *)ipv6)[i])
-			break;
+	static const struct ip6t_ip6 uncond;
 
-	return (i == sizeof(*ipv6));
+	return memcmp(ipv6, &uncond, sizeof(uncond)) == 0;
 }
 
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
