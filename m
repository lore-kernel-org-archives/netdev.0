From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: unfold two critical loops in ip_packet_match()
Date: Fri, 30 Jan 2009 17:54:10 +0100
Message-ID: <498330B2.4060004@cosmosbay.com>
References: <497E361B.30909@hp.com> <497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com> <497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net> <497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com>	<497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com>	<498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net>	<498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com>	<4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87ocxox0bu.fsf@basil.nowhere.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>=20
>> While doing oprofile tests I noticed two loops are not properly unro=
lled by gcc
>=20
> That's because nobody passed -funroll-loops. Did you try that for
> that file? Likely will need -O2 too

I dont want to unroll all loops, only those two :)
I wish gcc (4.3.2 here) was litle bit smarter :(

Without using -funroll-loops

size ipv4/netfilter/ip_tables.o
   text    data     bss     dec     hex filename
   6424     368      16    6808    1a98 net/ipv4/netfilter/ip_tables.o

With -funroll-loops :

size ipv4/netfilter/ip_tables.o
   text    data     bss     dec     hex filename
   7144     368      16    7528    1d68 net/ipv4/netfilter/ip_tables.o

With my patch and no -funroll-loops
   text    data     bss     dec     hex filename
   6488     368      16    6872    1ad8 net/ipv4/netfilter/ip_tables.o


>=20
>> +static unsigned long ifname_compare(const void *_a, const void *_b,=
 const void *_mask)
>> +{
>> +	const unsigned long *a =3D (const unsigned long *)_a;
>> +	const unsigned long *b =3D (const unsigned long *)_b;
>> +	const unsigned long *mask =3D (const unsigned long *)_mask;
>> +	unsigned long ret;
>> +
>> +	ret =3D (a[0] ^ b[0]) & mask[0];
>> +	ret |=3D (a[1] ^ b[1]) & mask[1];
>> +	if (IFNAMSIZ > 2 * sizeof(unsigned long))
>> +		ret |=3D (a[2] ^ b[2]) & mask[2];
>> +	if (IFNAMSIZ > 3 * sizeof(unsigned long))
>> +		ret |=3D (a[3] ^ b[3]) & mask[3];
>=20
> That will silently break for IFNAMSIZ >=3D 4*sizeof(unsigned long)
> You should add a dummy loop for that or at least a BUILD_BUG_ON

It will also break the day we port linux to a 128 bits machine :)

Thanks Andi

(By the way, I still use the patch on arch/x86/oprofile/op_model_ppro.c
to have a working oprofile on my dev machine...)


[PATCH] netfilter: unfold two critical loops in ip_packet_match()

While doing oprofile tests I noticed two loops are not properly unrolle=
d by gcc

Using hand coded unrolled loop provides nice speedup : ipt_do_table
credited of 2.52 % of cpu instead of 3.29 % in tbench, for a small
text size increase (62 bytes for both loops)


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv4/netfilter/ip_tables.c |   34 ++++++++++++++++++-------------
 1 files changed, 20 insertions(+), 14 deletions(-)


diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index ef8b6ca..9298d0a 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -65,6 +65,24 @@ do {								\
 #define inline
 #endif
=20
+static unsigned long ifname_compare(const void *_a, const void *_b, co=
nst void *_mask)
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
 /*
    We keep a set of rules for each CPU, so we can avoid write-locking
    them in the softirq when updating the counters and therefore
@@ -83,7 +101,6 @@ ip_packet_match(const struct iphdr *ip,
 		const struct ipt_ip *ipinfo,
 		int isfrag)
 {
-	size_t i;
 	unsigned long ret;
=20
 #define FWINV(bool, invflg) ((bool) ^ !!(ipinfo->invflags & (invflg)))
@@ -103,13 +120,7 @@ ip_packet_match(const struct iphdr *ip,
 		return false;
 	}
=20
-	/* Look for ifname matches; this should unroll nicely. */
-	for (i =3D 0, ret =3D 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |=3D (((const unsigned long *)indev)[i]
-			^ ((const unsigned long *)ipinfo->iniface)[i])
-			& ((const unsigned long *)ipinfo->iniface_mask)[i];
-	}
-
+	ret =3D ifname_compare(indev, ipinfo->iniface, ipinfo->iniface_mask);
 	if (FWINV(ret !=3D 0, IPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
 			indev, ipinfo->iniface,
@@ -117,12 +128,7 @@ ip_packet_match(const struct iphdr *ip,
 		return false;
 	}
=20
-	for (i =3D 0, ret =3D 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |=3D (((const unsigned long *)outdev)[i]
-			^ ((const unsigned long *)ipinfo->outiface)[i])
-			& ((const unsigned long *)ipinfo->outiface_mask)[i];
-	}
-
+	ret =3D ifname_compare(outdev, ipinfo->outiface, ipinfo->outiface_mas=
k);
 	if (FWINV(ret !=3D 0, IPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
 			outdev, ipinfo->outiface,


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
