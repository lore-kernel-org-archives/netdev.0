From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 07/41: arp_tables: unfold two critical loops in arp_packet_match()
Date: Tue, 24 Mar 2009 15:03:16 +0100 (MET)
Message-ID: <20090324140312.31401.89168.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34743 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755732AbZCXODS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:18 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ddc214c43a923e89741e04da2f10e3037a64e222
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Wed Feb 18 17:47:50 2009 +0100

    netfilter: arp_tables: unfold two critical loops in arp_packet_match()
    
    x86 and powerpc can perform long word accesses in an efficient maner.
    We can use this to unroll two loops in arp_packet_match(), to
    perform arithmetic on long words instead of bytes. This is a win
    on x86_64 for example.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 7ea88b6..b5db463 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -73,6 +73,36 @@ static inline int arp_devaddr_compare(const struct arpt_devaddr_info *ap,
 	return (ret != 0);
 }
 
+/*
+ * Unfortunatly, _b and _mask are not aligned to an int (or long int)
+ * Some arches dont care, unrolling the loop is a win on them.
+ */
+static unsigned long ifname_compare(const char *_a, const char *_b, const char *_mask)
+{
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
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
+#else
+	unsigned long ret = 0;
+	int i;
+
+	for (i = 0; i < IFNAMSIZ; i++)
+		ret |= (_a[i] ^ _b[i]) & _mask[i];
+#endif
+	return ret;
+}
+
 /* Returns whether packet matches rule or not. */
 static inline int arp_packet_match(const struct arphdr *arphdr,
 				   struct net_device *dev,
@@ -83,7 +113,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	const char *arpptr = (char *)(arphdr + 1);
 	const char *src_devaddr, *tgt_devaddr;
 	__be32 src_ipaddr, tgt_ipaddr;
-	int i, ret;
+	long ret;
 
 #define FWINV(bool, invflg) ((bool) ^ !!(arpinfo->invflags & (invflg)))
 
@@ -156,10 +186,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	}
 
 	/* Look for ifname matches.  */
-	for (i = 0, ret = 0; i < IFNAMSIZ; i++) {
-		ret |= (indev[i] ^ arpinfo->iniface[i])
-			& arpinfo->iniface_mask[i];
-	}
+	ret = ifname_compare(indev, arpinfo->iniface, arpinfo->iniface_mask);
 
 	if (FWINV(ret != 0, ARPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -168,10 +195,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 		return 0;
 	}
 
-	for (i = 0, ret = 0; i < IFNAMSIZ; i++) {
-		ret |= (outdev[i] ^ arpinfo->outiface[i])
-			& arpinfo->outiface_mask[i];
-	}
+	ret = ifname_compare(outdev, arpinfo->outiface, arpinfo->outiface_mask);
 
 	if (FWINV(ret != 0, ARPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
@@ -221,7 +245,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			   const struct net_device *out,
 			   struct xt_table *table)
 {
-	static const char nulldevname[IFNAMSIZ];
+	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	unsigned int verdict = NF_DROP;
 	const struct arphdr *arp;
 	bool hotdrop = false;
