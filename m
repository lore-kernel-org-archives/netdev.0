From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: unfold two loops in ip6_packet_match()
Date: Thu, 19 Feb 2009 09:14:14 +0100
Message-ID: <499D14D6.7020005@cosmosbay.com>
References: <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org> <498330B2.4060004@cosmosbay.com> <20090130172705.GB18453@one.firstfloor.org> <499032A4.9090301@trash.net> <499C24FF.90302@cosmosbay.com> <499C2766.5090904@trash.net> <499C3871.4030600@cosmosbay.com> <499C4739.3000800@cosmosbay.com> <499C4FEB.7040706@trash.net> <499D118B.1040309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50284 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbZBSIOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 03:14:24 -0500
In-Reply-To: <499D118B.1040309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_tables netfilter module can use an ifname_compare() helper
so that two loops are unfolded.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv6/netfilter/ip6_tables.c |   33 +++++++++++++++++++-----------
 1 files changed, 21 insertions(+), 12 deletions(-)
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

