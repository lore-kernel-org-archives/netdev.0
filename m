From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: factorize ifname_compare()
Date: Wed, 25 Mar 2009 12:27:07 +0100
Message-ID: <49CA150B.2080203@cosmosbay.com>
References: <20090324.132954.148903398.davem@davemloft.net> <49C94B6A.5020304@cosmosbay.com> <alpine.LSU.2.00.0903242215590.26397@fbirervta.pbzchgretzou.qr> <20090324.141848.119353425.davem@davemloft.net> <alpine.LSU.2.00.0903242220280.26397@fbirervta.pbzchgretzou.qr> <49C952FE.7070202@cosmosbay.com> <alpine.LSU.2.00.0903242243040.3974@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55456 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086AbZCYL1S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 07:27:18 -0400
In-Reply-To: <alpine.LSU.2.00.0903242243040.3974@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt a =E9crit :
> On Tuesday 2009-03-24 22:39, Eric Dumazet wrote:
>> memcmp() is fine, but how is it solving the masking problem we have =
?
>=20
> You are right; we would have to calculate the prefix length of the
> mask first. (And I think we can assume that there will not be any 1s
> in the mask after the first 0.) It would consume CPU indeed.
>=20
>> Also in the case of arp_tables, _a is long word aligned, while _b an=
d _mask
>> are not.
>>
>> If you look various ifname_compare(), we have two different implemen=
tations.
>>
>> So yes, a factorization is possible for three ip_tables.c, ip6_table=
s.c and
>> xt_physdev.c.
>=20
> Very well.

Here is a patch to factorize these functions, as suggested by Jan

Thank you

[PATCH] netfilter: factorize ifname_compare()

We use same not trivial helper function in four places. We can factoriz=
e it.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/netfilter/x_tables.h |   23 +++++++++++++++++++++++
 net/ipv4/netfilter/arp_tables.c    |   14 +-------------
 net/ipv4/netfilter/ip_tables.c     |   23 ++---------------------
 net/ipv6/netfilter/ip6_tables.c    |   23 ++---------------------
 net/netfilter/xt_physdev.c         |   21 ++-------------------
 5 files changed, 30 insertions(+), 74 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilt=
er/x_tables.h
index e8e08d0..72918b7 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -435,6 +435,29 @@ extern void xt_free_table_info(struct xt_table_inf=
o *info);
 extern void xt_table_entry_swap_rcu(struct xt_table_info *old,
 				    struct xt_table_info *new);
=20
+/*
+ * This helper is performance critical and must be inlined
+ */
+static inline unsigned long ifname_compare_aligned(const char *_a,
+						   const char *_b,
+						   const char *_mask)
+{
+	const unsigned long *a =3D (const unsigned long *)_a;
+	const unsigned long *b =3D (const unsigned long *)_b;
+	const unsigned long *mask =3D (const unsigned long *)_mask;
+	unsigned long ret;
+
+	ret =3D (a[0] ^ b[0]) & mask[0];
+	if (IFNAMSIZ > sizeof(unsigned long))
+		ret |=3D (a[1] ^ b[1]) & mask[1];
+	if (IFNAMSIZ > 2 * sizeof(unsigned long))
+		ret |=3D (a[2] ^ b[2]) & mask[2];
+	if (IFNAMSIZ > 3 * sizeof(unsigned long))
+		ret |=3D (a[3] ^ b[3]) & mask[3];
+	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
+	return ret;
+}
+
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
=20
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_t=
ables.c
index 84b9c17..ee1133c 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -81,19 +81,7 @@ static inline int arp_devaddr_compare(const struct a=
rpt_devaddr_info *ap,
 static unsigned long ifname_compare(const char *_a, const char *_b, co=
nst char *_mask)
 {
 #ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-	const unsigned long *a =3D (const unsigned long *)_a;
-	const unsigned long *b =3D (const unsigned long *)_b;
-	const unsigned long *mask =3D (const unsigned long *)_mask;
-	unsigned long ret;
-
-	ret =3D (a[0] ^ b[0]) & mask[0];
-	if (IFNAMSIZ > sizeof(unsigned long))
-		ret |=3D (a[1] ^ b[1]) & mask[1];
-	if (IFNAMSIZ > 2 * sizeof(unsigned long))
-		ret |=3D (a[2] ^ b[2]) & mask[2];
-	if (IFNAMSIZ > 3 * sizeof(unsigned long))
-		ret |=3D (a[3] ^ b[3]) & mask[3];
-	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
+	unsigned long ret =3D ifname_compare_aligned(_a, _b, _mask);
 #else
 	unsigned long ret =3D 0;
 	const u16 *a =3D (const u16 *)_a;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index e5294ae..41c59e3 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -74,25 +74,6 @@ do {								\
=20
    Hence the start of any table is given by get_table() below.  */
=20
-static unsigned long ifname_compare(const char *_a, const char *_b,
-				    const unsigned char *_mask)
-{
-	const unsigned long *a =3D (const unsigned long *)_a;
-	const unsigned long *b =3D (const unsigned long *)_b;
-	const unsigned long *mask =3D (const unsigned long *)_mask;
-	unsigned long ret;
-
-	ret =3D (a[0] ^ b[0]) & mask[0];
-	if (IFNAMSIZ > sizeof(unsigned long))
-		ret |=3D (a[1] ^ b[1]) & mask[1];
-	if (IFNAMSIZ > 2 * sizeof(unsigned long))
-		ret |=3D (a[2] ^ b[2]) & mask[2];
-	if (IFNAMSIZ > 3 * sizeof(unsigned long))
-		ret |=3D (a[3] ^ b[3]) & mask[3];
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
=20
-	ret =3D ifname_compare(indev, ipinfo->iniface, ipinfo->iniface_mask);
+	ret =3D ifname_compare_aligned(indev, ipinfo->iniface, ipinfo->inifac=
e_mask);
=20
 	if (FWINV(ret !=3D 0, IPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -130,7 +111,7 @@ ip_packet_match(const struct iphdr *ip,
 		return false;
 	}
=20
-	ret =3D ifname_compare(outdev, ipinfo->outiface, ipinfo->outiface_mas=
k);
+	ret =3D ifname_compare_aligned(outdev, ipinfo->outiface, ipinfo->outi=
face_mask);
=20
 	if (FWINV(ret !=3D 0, IPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_t=
ables.c
index 34af7bb..e59662b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -89,25 +89,6 @@ ip6t_ext_hdr(u8 nexthdr)
 		 (nexthdr =3D=3D IPPROTO_DSTOPTS) );
 }
=20
-static unsigned long ifname_compare(const char *_a, const char *_b,
-				    const unsigned char *_mask)
-{
-	const unsigned long *a =3D (const unsigned long *)_a;
-	const unsigned long *b =3D (const unsigned long *)_b;
-	const unsigned long *mask =3D (const unsigned long *)_mask;
-	unsigned long ret;
-
-	ret =3D (a[0] ^ b[0]) & mask[0];
-	if (IFNAMSIZ > sizeof(unsigned long))
-		ret |=3D (a[1] ^ b[1]) & mask[1];
-	if (IFNAMSIZ > 2 * sizeof(unsigned long))
-		ret |=3D (a[2] ^ b[2]) & mask[2];
-	if (IFNAMSIZ > 3 * sizeof(unsigned long))
-		ret |=3D (a[3] ^ b[3]) & mask[3];
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
=20
-	ret =3D ifname_compare(indev, ip6info->iniface, ip6info->iniface_mask=
);
+	ret =3D ifname_compare_aligned(indev, ip6info->iniface, ip6info->inif=
ace_mask);
=20
 	if (FWINV(ret !=3D 0, IP6T_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -147,7 +128,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		return false;
 	}
=20
-	ret =3D ifname_compare(outdev, ip6info->outiface, ip6info->outiface_m=
ask);
+	ret =3D ifname_compare_aligned(outdev, ip6info->outiface, ip6info->ou=
tiface_mask);
=20
 	if (FWINV(ret !=3D 0, IP6T_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 44a234e..8d28ca5 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -20,23 +20,6 @@ MODULE_DESCRIPTION("Xtables: Bridge physical device =
match");
 MODULE_ALIAS("ipt_physdev");
 MODULE_ALIAS("ip6t_physdev");
=20
-static unsigned long ifname_compare(const char *_a, const char *_b, co=
nst char *_mask)
-{
-	const unsigned long *a =3D (const unsigned long *)_a;
-	const unsigned long *b =3D (const unsigned long *)_b;
-	const unsigned long *mask =3D (const unsigned long *)_mask;
-	unsigned long ret;
-
-	ret =3D (a[0] ^ b[0]) & mask[0];
-	if (IFNAMSIZ > sizeof(unsigned long))
-		ret |=3D (a[1] ^ b[1]) & mask[1];
-	if (IFNAMSIZ > 2 * sizeof(unsigned long))
-		ret |=3D (a[2] ^ b[2]) & mask[2];
-	if (IFNAMSIZ > 3 * sizeof(unsigned long))
-		ret |=3D (a[3] ^ b[3]) & mask[3];
-	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
-	return ret;
-}
=20
 static bool
 physdev_mt(const struct sk_buff *skb, const struct xt_match_param *par=
)
@@ -85,7 +68,7 @@ physdev_mt(const struct sk_buff *skb, const struct xt=
_match_param *par)
 	if (!(info->bitmask & XT_PHYSDEV_OP_IN))
 		goto match_outdev;
 	indev =3D nf_bridge->physindev ? nf_bridge->physindev->name : nulldev=
name;
-	ret =3D ifname_compare(indev, info->physindev, info->in_mask);
+	ret =3D ifname_compare_aligned(indev, info->physindev, info->in_mask)=
;
=20
 	if (!ret ^ !(info->invert & XT_PHYSDEV_OP_IN))
 		return false;
@@ -95,7 +78,7 @@ match_outdev:
 		return true;
 	outdev =3D nf_bridge->physoutdev ?
 		 nf_bridge->physoutdev->name : nulldevname;
-	ret =3D ifname_compare(outdev, info->physoutdev, info->out_mask);
+	ret =3D ifname_compare_aligned(outdev, info->physoutdev, info->out_ma=
sk);
=20
 	return (!!ret ^ !(info->invert & XT_PHYSDEV_OP_OUT));
 }

