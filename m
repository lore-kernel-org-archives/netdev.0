From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: unfold two critical loops in ip_packet_match()
Date: Fri, 20 Feb 2009 11:02:17 +0100
Message-ID: <499E7FA9.6070707@cosmosbay.com>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4981CBE2.5020306@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While doing oprofile tests I noticed two loops are not properly unrolled by gcc

Using a hand coded unrolled loop provides nice speedup : ipt_do_table
credited of 2.52 % of cpu instead of 3.29 % in tbench.


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
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

