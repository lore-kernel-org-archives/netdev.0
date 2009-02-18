From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: unfold two critical loops in ip_packet_match()
Date: Wed, 18 Feb 2009 17:33:53 +0100
Message-ID: <499C3871.4030600@cosmosbay.com>
References: <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org> <498330B2.4060004@cosmosbay.com> <20090130172705.GB18453@one.firstfloor.org> <499032A4.9090301@trash.net> <499C24FF.90302@cosmosbay.com> <499C2766.5090904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	"David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38834 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbZBRQeF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 11:34:05 -0500
In-Reply-To: <499C2766.5090904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Patrick McHardy a =E9crit :
>>> The interface name matching has shown up in profiles forever
>>> though and we've actually already tried to optimize it IIRC.
>>>
>>> Eric, I'm trying to keep all the *tables files synchronized,
>>> could you send me a patch updating the other ones as well
>>> please?
>>
>> While doing this, I found arp_tables is still using loop using
>> byte operations.
>>
>> Also, I could not find how iniface_mask[], outiface_mask[], iniface[=
]
>> and outiface[] were forced to long word alignment ...
>> (in struct ipt_ip, struct ip6t_ip6, struct arpt_arp)
>=20
> In case of IPv4 and IPv6 they are already suitable aligned, it
> simply performing the comparison in unsigned long quantities.
> struct arpt_arp unfortunately doesn't properly align the interface
> names, so we need to continue to do byte-wise comparisons.
>=20
>=20

I see, but #ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS can help here =
;)

ifname_compare() should be static in three files (ipv4_ip_tables, ipv6_=
ip_tables and arp_tables),
since only arp_tables variant has the alignement problem.

[PATCH] netfilter: unfold two critical loops in arp_packet_match()

x86 and powerpc can perform long word accesses in an efficient maner.
We can use this to unroll two loops in arp_packet_match(), to
perform arithmetic on long words instead of bytes. This is a win
on x86_64 for example.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv4/netfilter/arp_tables.c |   44 +++++++++++++++++++++++-------
 1 files changed, 34 insertions(+), 10 deletions(-)
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_t=
ables.c
index 7ea88b6..b5db463 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -73,6 +73,36 @@ static inline int arp_devaddr_compare(const struct a=
rpt_devaddr_info *ap,
 	return (ret !=3D 0);
 }
=20
+/*
+ * Unfortunatly, _b and _mask are not aligned to an int (or long int)
+ * Some arches dont care, unrolling the loop is a win on them.
+ */
+static unsigned long ifname_compare(const char *_a, const char *_b, co=
nst char *_mask)
+{
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
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
+#else
+	unsigned long ret =3D 0;
+	int i;
+
+	for (i =3D 0; i < IFNAMSIZ; i++)
+		ret |=3D (_a[i] ^ _b[i]) & _mask[i];
+#endif
+	return ret;
+}
+
 /* Returns whether packet matches rule or not. */
 static inline int arp_packet_match(const struct arphdr *arphdr,
 				   struct net_device *dev,
@@ -83,7 +113,7 @@ static inline int arp_packet_match(const struct arph=
dr *arphdr,
 	const char *arpptr =3D (char *)(arphdr + 1);
 	const char *src_devaddr, *tgt_devaddr;
 	__be32 src_ipaddr, tgt_ipaddr;
-	int i, ret;
+	long ret;
=20
 #define FWINV(bool, invflg) ((bool) ^ !!(arpinfo->invflags & (invflg))=
)
=20
@@ -156,10 +186,7 @@ static inline int arp_packet_match(const struct ar=
phdr *arphdr,
 	}
=20
 	/* Look for ifname matches.  */
-	for (i =3D 0, ret =3D 0; i < IFNAMSIZ; i++) {
-		ret |=3D (indev[i] ^ arpinfo->iniface[i])
-			& arpinfo->iniface_mask[i];
-	}
+	ret =3D ifname_compare(indev, arpinfo->iniface, arpinfo->iniface_mask=
);
=20
 	if (FWINV(ret !=3D 0, ARPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
@@ -168,10 +195,7 @@ static inline int arp_packet_match(const struct ar=
phdr *arphdr,
 		return 0;
 	}
=20
-	for (i =3D 0, ret =3D 0; i < IFNAMSIZ; i++) {
-		ret |=3D (outdev[i] ^ arpinfo->outiface[i])
-			& arpinfo->outiface_mask[i];
-	}
+	ret =3D ifname_compare(outdev, arpinfo->outiface, arpinfo->outiface_m=
ask);
=20
 	if (FWINV(ret !=3D 0, ARPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
@@ -221,7 +245,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			   const struct net_device *out,
 			   struct xt_table *table)
 {
-	static const char nulldevname[IFNAMSIZ];
+	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof=
(long))));
 	unsigned int verdict =3D NF_DROP;
 	const struct arphdr *arp;
 	bool hotdrop =3D false;


