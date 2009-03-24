From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 13/41: ip6_tables: unfold two loops in ip6_packet_match()
Date: Tue, 24 Mar 2009 15:03:24 +0100 (MET)
Message-ID: <20090324140320.31401.37849.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 323dbf96382f057d035afce0237f08e18571ac1d
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Thu Feb 19 11:18:23 2009 +0100

    netfilter: ip6_tables: unfold two loops in ip6_packet_match()
    
    ip6_tables netfilter module can use an ifname_compare() helper
    so that two loops are unfolded.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index a33485d..d64594b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -89,6 +89,25 @@ ip6t_ext_hdr(u8 nexthdr)
 		 (nexthdr == IPPROTO_DSTOPTS) );
 }
 
+static unsigned long ifname_compare(const char *_a, const char *_b,
+				    const unsigned char *_mask)
+{
+	const unsigned long *a = (const unsigned long *)_a;
+	const unsigned long *b = (const unsigned long *)_b;
+	const unsigned long *mask = (const unsigned long *)_mask;
+	unsigned long ret;
+
+	ret = (a[0] ^ b[0]) & mask[0];
+	if (IFNAMSIZ > sizeof(unsigned long))
+		ret |= (a[1] ^ b[1]) & mask[1];
+	if (IFNAMSIZ > 2 * sizeof(unsigned long))
+		ret |= (a[2] ^ b[2]) & mask[2];
+	if (IFNAMSIZ > 3 * sizeof(unsigned long))
+		ret |= (a[3] ^ b[3]) & mask[3];
+	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
+	return ret;
+}
+
 /* Returns whether matches rule or not. */
 /* Performance critical - called for every packet */
 static inline bool
@@ -99,7 +118,6 @@ ip6_packet_match(const struct sk_buff *skb,
 		 unsigned int *protoff,
 		 int *fragoff, bool *hotdrop)
 {
-	size_t i;
 	unsigned long ret;
 	const struct ipv6hdr *ipv6 = ipv6_hdr(skb);
 
@@ -120,12 +138,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		return false;
 	}
 
-	/* Look for ifname matches; this should unroll nicely. */
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)indev)[i]
-			^ ((const unsigned long *)ip6info->iniface)[i])
-			& ((const unsigned long *)ip6info->iniface_mask)[i];
-	}
+	ret = ifname_compare(indev, ip6info->iniface, ip6info->iniface_mask);
 
 	if (FWINV(ret != 0, IP6T_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -134,11 +147,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		return false;
 	}
 
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)outdev)[i]
-			^ ((const unsigned long *)ip6info->outiface)[i])
-			& ((const unsigned long *)ip6info->outiface_mask)[i];
-	}
+	ret = ifname_compare(outdev, ip6info->outiface, ip6info->outiface_mask);
 
 	if (FWINV(ret != 0, IP6T_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
