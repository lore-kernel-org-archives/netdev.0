From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: netfilter 07/41: arp_tables: unfold two critical loops in arp_packet_match()
Date: Tue, 24 Mar 2009 22:06:50 +0100
Message-ID: <49C94B6A.5020304@cosmosbay.com>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>	<20090324140312.31401.89168.sendpatchset@x2.localnet> <20090324.132954.148903398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324.132954.148903398.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 24 Mar 2009 15:03:16 +0100 (MET)
>=20
>> +/*
>> + * Unfortunatly, _b and _mask are not aligned to an int (or long in=
t)
>> + * Some arches dont care, unrolling the loop is a win on them.
>> + */
>> +static unsigned long ifname_compare(const char *_a, const char *_b,=
 const char *_mask)
>> +{
>> +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
>> +	const unsigned long *a =3D (const unsigned long *)_a;
>> +	const unsigned long *b =3D (const unsigned long *)_b;
>=20
> I think we can at least give some help for the platforms which
> require alignment.
>=20
> We can, for example, assume 16-bit alignment and thus loop
> over u16's

Right. How about this incremental patch ?

Thanks

[PATCH] arp_tables: ifname_compare() can assume 16bit alignment

Arches without efficient unaligned access can still perform a loop
assuming 16bit alignment in ifname_compare()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_t=
ables.c
index 64a7c6c..84b9c17 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -76,6 +76,7 @@ static inline int arp_devaddr_compare(const struct ar=
pt_devaddr_info *ap,
 /*
  * Unfortunatly, _b and _mask are not aligned to an int (or long int)
  * Some arches dont care, unrolling the loop is a win on them.
+ * For other arches, we only have a 16bit alignement.
  */
 static unsigned long ifname_compare(const char *_a, const char *_b, co=
nst char *_mask)
 {
@@ -95,10 +96,13 @@ static unsigned long ifname_compare(const char *_a,=
 const char *_b, const char *
 	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
 #else
 	unsigned long ret =3D 0;
+	const u16 *a =3D (const u16 *)_a;
+	const u16 *b =3D (const u16 *)_b;
+	const u16 *mask =3D (const u16 *)_mask;
 	int i;
=20
-	for (i =3D 0; i < IFNAMSIZ; i++)
-		ret |=3D (_a[i] ^ _b[i]) & _mask[i];
+	for (i =3D 0; i < IFNAMSIZ/sizeof(u16); i++)
+		ret |=3D (a[i] ^ b[i]) & mask[i];
 #endif
 	return ret;
 }

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
