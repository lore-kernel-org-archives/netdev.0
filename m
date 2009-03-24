From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 18/41: ip_tables: unfold two critical loops in ip_packet_match()
Date: Tue, 24 Mar 2009 15:03:31 +0100 (MET)
Message-ID: <20090324140327.31401.72576.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34741 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813AbZCXODd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:33 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 08361aa807ae5e5007cd226ca9e34287512de737
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Fri Feb 20 11:03:33 2009 +0100

    netfilter: ip_tables: unfold two critical loops in ip_packet_match()
    
    While doing oprofile tests I noticed two loops are not properly unrolled by gcc
    
    Using a hand coded unrolled loop provides nice speedup : ipt_do_table
    credited of 2.52 % of cpu instead of 3.29 % in tbench.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 08cde5b..e5294ae 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -74,6 +74,25 @@ do {								\
 
    Hence the start of any table is given by get_table() below.  */
 
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
@@ -83,7 +102,6 @@ ip_packet_match(const struct iphdr *ip,
 		const struct ipt_ip *ipinfo,
 		int isfrag)
 {
-	size_t i;
 	unsigned long ret;
 
 #define FWINV(bool, invflg) ((bool) ^ !!(ipinfo->invflags & (invflg)))
@@ -103,12 +121,7 @@ ip_packet_match(const struct iphdr *ip,
 		return false;
 	}
 
-	/* Look for ifname matches; this should unroll nicely. */
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)indev)[i]
-			^ ((const unsigned long *)ipinfo->iniface)[i])
-			& ((const unsigned long *)ipinfo->iniface_mask)[i];
-	}
+	ret = ifname_compare(indev, ipinfo->iniface, ipinfo->iniface_mask);
 
 	if (FWINV(ret != 0, IPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -117,11 +130,7 @@ ip_packet_match(const struct iphdr *ip,
 		return false;
 	}
 
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)outdev)[i]
-			^ ((const unsigned long *)ipinfo->outiface)[i])
-			& ((const unsigned long *)ipinfo->outiface_mask)[i];
-	}
+	ret = ifname_compare(outdev, ipinfo->outiface, ipinfo->outiface_mask);
 
 	if (FWINV(ret != 0, IPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
