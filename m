From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/12: factorize ifname_compare()
Date: Thu, 26 Mar 2009 20:02:34 +0100 (MET)
Message-ID: <20090326190229.23365.21477.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit b8dfe498775de912116f275680ddb57c8799d9ef
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Wed Mar 25 17:31:52 2009 +0100

    netfilter: factorize ifname_compare()
    
    We use same not trivial helper function in four places. We can factorize it.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index e8e08d0..72918b7 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -435,6 +435,29 @@ extern void xt_free_table_info(struct xt_table_info *info);
 extern void xt_table_entry_swap_rcu(struct xt_table_info *old,
 				    struct xt_table_info *new);
 
+/*
+ * This helper is performance critical and must be inlined
+ */
+static inline unsigned long ifname_compare_aligned(const char *_a,
+						   const char *_b,
+						   const char *_mask)
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
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 64a7c6c..4b35dba 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -80,19 +80,7 @@ static inline int arp_devaddr_compare(const struct arpt_devaddr_info *ap,
 static unsigned long ifname_compare(const char *_a, const char *_b, const char *_mask)
 {
 #ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-	const unsigned long *a = (const unsigned long *)_a;
-	const unsigned long *b = (const unsigned long *)_b;
-	const unsigned long *mask = (const unsigned long *)_mask;
-	unsigned long ret;
-
-	ret = (a[0] ^ b[0]) & mask[0];
-	if (IFNAMSIZ > sizeof(unsigned long))
-		ret |= (a[1] ^ b[1]) & mask[1];
-	if (IFNAMSIZ > 2 * sizeof(unsigned long))
-		ret |= (a[2] ^ b[2]) & mask[2];
-	if (IFNAMSIZ > 3 * sizeof(unsigned long))
-		ret |= (a[3] ^ b[3]) & mask[3];
-	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
+	unsigned long ret = ifname_compare_aligned(_a, _b, _mask);
 #else
 	unsigned long ret = 0;
 	int i;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index e5294ae..41c59e3 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -74,25 +74,6 @@ do {								\
 
    Hence the start of any table is given by get_table() below.  */
 
-static unsigned long ifname_compare(const char *_a, const char *_b,
-				    const unsigned char *_mask)
-{
-	const unsigned long *a = (const unsigned long *)_a;
-	const unsigned long *b = (const unsigned long *)_b;
-	const unsigned long *mask = (const unsigned long *)_mask;
-	unsigned long ret;
-
-	ret = (a[0] ^ b[0]) & mask[0];
-	if (IFNAMSIZ > sizeof(unsigned long))
-		ret |= (a[1] ^ b[1]) & mask[1];
-	if (IFNAMSIZ > 2 * sizeof(unsigned long))
-		ret |= (a[2] ^ b[2]) & mask[2];
-	if (IFNAMSIZ > 3 * sizeof(unsigned long))
-		ret |= (a[3] ^ b[3]) & mask[3];
-	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
-	return ret;
-}
-
 /* Returns whether matches rule or not. */
 /* Performance critical - called for every packet */
 static inline bool
@@ -121,7 +102,7 @@ ip_packet_match(const struct iphdr *ip,
 		return false;
 	}
 
-	ret = ifname_compare(indev, ipinfo->iniface, ipinfo->iniface_mask);
+	ret = ifname_compare_aligned(indev, ipinfo->iniface, ipinfo->iniface_mask);
 
 	if (FWINV(ret != 0, IPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -130,7 +111,7 @@ ip_packet_match(const struct iphdr *ip,
 		return false;
 	}
 
-	ret = ifname_compare(outdev, ipinfo->outiface, ipinfo->outiface_mask);
+	ret = ifname_compare_aligned(outdev, ipinfo->outiface, ipinfo->outiface_mask);
 
 	if (FWINV(ret != 0, IPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 34af7bb..e59662b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -89,25 +89,6 @@ ip6t_ext_hdr(u8 nexthdr)
 		 (nexthdr == IPPROTO_DSTOPTS) );
 }
 
-static unsigned long ifname_compare(const char *_a, const char *_b,
-				    const unsigned char *_mask)
-{
-	const unsigned long *a = (const unsigned long *)_a;
-	const unsigned long *b = (const unsigned long *)_b;
-	const unsigned long *mask = (const unsigned long *)_mask;
-	unsigned long ret;
-
-	ret = (a[0] ^ b[0]) & mask[0];
-	if (IFNAMSIZ > sizeof(unsigned long))
-		ret |= (a[1] ^ b[1]) & mask[1];
-	if (IFNAMSIZ > 2 * sizeof(unsigned long))
-		ret |= (a[2] ^ b[2]) & mask[2];
-	if (IFNAMSIZ > 3 * sizeof(unsigned long))
-		ret |= (a[3] ^ b[3]) & mask[3];
-	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
-	return ret;
-}
-
 /* Returns whether matches rule or not. */
 /* Performance critical - called for every packet */
 static inline bool
@@ -138,7 +119,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		return false;
 	}
 
-	ret = ifname_compare(indev, ip6info->iniface, ip6info->iniface_mask);
+	ret = ifname_compare_aligned(indev, ip6info->iniface, ip6info->iniface_mask);
 
 	if (FWINV(ret != 0, IP6T_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -147,7 +128,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		return false;
 	}
 
-	ret = ifname_compare(outdev, ip6info->outiface, ip6info->outiface_mask);
+	ret = ifname_compare_aligned(outdev, ip6info->outiface, ip6info->outiface_mask);
 
 	if (FWINV(ret != 0, IP6T_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 44a234e..8d28ca5 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -20,23 +20,6 @@ MODULE_DESCRIPTION("Xtables: Bridge physical device match");
 MODULE_ALIAS("ipt_physdev");
 MODULE_ALIAS("ip6t_physdev");
 
-static unsigned long ifname_compare(const char *_a, const char *_b, const char *_mask)
-{
-	const unsigned long *a = (const unsigned long *)_a;
-	const unsigned long *b = (const unsigned long *)_b;
-	const unsigned long *mask = (const unsigned long *)_mask;
-	unsigned long ret;
-
-	ret = (a[0] ^ b[0]) & mask[0];
-	if (IFNAMSIZ > sizeof(unsigned long))
-		ret |= (a[1] ^ b[1]) & mask[1];
-	if (IFNAMSIZ > 2 * sizeof(unsigned long))
-		ret |= (a[2] ^ b[2]) & mask[2];
-	if (IFNAMSIZ > 3 * sizeof(unsigned long))
-		ret |= (a[3] ^ b[3]) & mask[3];
-	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
-	return ret;
-}
 
 static bool
 physdev_mt(const struct sk_buff *skb, const struct xt_match_param *par)
@@ -85,7 +68,7 @@ physdev_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (!(info->bitmask & XT_PHYSDEV_OP_IN))
 		goto match_outdev;
 	indev = nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	ret = ifname_compare(indev, info->physindev, info->in_mask);
+	ret = ifname_compare_aligned(indev, info->physindev, info->in_mask);
 
 	if (!ret ^ !(info->invert & XT_PHYSDEV_OP_IN))
 		return false;
@@ -95,7 +78,7 @@ match_outdev:
 		return true;
 	outdev = nf_bridge->physoutdev ?
 		 nf_bridge->physoutdev->name : nulldevname;
-	ret = ifname_compare(outdev, info->physoutdev, info->out_mask);
+	ret = ifname_compare_aligned(outdev, info->physoutdev, info->out_mask);
 
 	return (!!ret ^ !(info->invert & XT_PHYSDEV_OP_OUT));
 }
