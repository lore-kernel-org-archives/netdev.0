From: =?iso-8859-15?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: Re: [BUG] 2.6.37-rc5 Memory leak in net/ipv4/udp.c
Date: Fri, 17 Dec 2010 12:56:17 +0100
Message-ID: <19723.20449.974043.309608@ipc1.ka-ro>
References: <19723.14557.349975.821418@ipc1.ka-ro>
	<1292582116.2906.5.camel@edumazet-laptop>
	<19723.17775.241784.993744@ipc1.ka-ro>
	<1292585534.2906.12.camel@edumazet-laptop>
	<19723.19914.961119.861405@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([213.146.116.110]:48751 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab0LQL4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 06:56:22 -0500
In-Reply-To: <19723.19914.961119.861405@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

Lothar Wa=DFmann writes:
> Eric Dumazet writes:
> > Le vendredi 17 d=E9cembre 2010 =E0 12:11 +0100, Lothar Wa=DFmann a =
=E9crit :
> > > Hi,
> > >=20
> > > Eric Dumazet writes:
> > > > Le vendredi 17 d=E9cembre 2010 =E0 11:18 +0100, Lothar Wa=DFman=
n a =E9crit :
> > > > > The offending code in net/ipv4/udp.c is:
> > > > > |void __init udp_table_init(struct udp_table *table, const ch=
ar *name)
> > > > > |{
> > > > > |	unsigned int i;
> > > > > |
> > > > > |	if (!CONFIG_BASE_SMALL)
> > > > > |		table->hash =3D alloc_large_system_hash(name,
> > > > > |			2 * sizeof(struct udp_hslot),
> > > > > |			uhash_entries,
> > > > > |			21, /* one slot per 2 MB */
> > > > > |			0,
> > > > > |			&table->log,
> > > > > |			&table->mask,
> > > > > |			64 * 1024);
> > > > > |	/*
> > > > > |	 * Make sure hash table has the minimum size
> > > > > |	 */
> > > > > |	if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN =
- 1) {
> > > > > |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> > > > > |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> > > > > In case of !CONFIG_BASE_SMALL and 'table->mask < UDP_HTABLE_S=
IZE_MIN - 1)'
> > > > > the memory allocated in the previous if clause becomes inaces=
sible!
> > > > >=20
> > > > > Shouldn't this be:
> > > > > |	if (!CONFIG_BASE_SMALL && table->mask >=3D UDP_HTABLE_SIZE_=
MIN - 1) {
> > > > > |		table->hash =3D alloc_large_system_hash(name,
> > > > > |			2 * sizeof(struct udp_hslot),
> > > > > |			uhash_entries,
> > > > > |			21, /* one slot per 2 MB */
> > > > > |			0,
> > > > > |			&table->log,
> > > > > |			&table->mask,
> > > > > |			64 * 1024);
> > > > > |	} else {
> > > > > |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> > > > > |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> > > > > [...]
> > > > >=20
> > > >=20
> > > > Nothing we can do about it, there is no API to reverse the
> > > > alloc_large_system_hash() effect. We could call kmemleak api to=
 at least
> > > > avoid this false alarm.
> > > >=20
> > > Do you have to call it at all in case of table->mask < UDP_HTABLE=
_SIZE_MIN - 1?
> > >=20
> >=20
> > We call alloc_large_system_hash() asking it to size the table _itse=
lf_.
> > We give some hints :=20
> >=20
> > - How many slots per MB of avail memory.
> > - An upper limit (64*1024 slots because we only handle 65536 udp po=
rts)
> > - but not a lower limit (not available in the API)
> >=20
> > Problem is in your case, alloc_large_system_hash() allocates a very
> > small area. Then we catch the problem, seeing table->mask is too sm=
all
> > for our needs. We prefer to 'lost' this too small memory than crash=
ing
> > kernel later.
> >=20
> table->mask is not altered by alloc_large_system_hash(), so you could
> detect the situation beforhand and avoid calling that function in thi=
s
> case. As far as I can tell there is no need for
> alloc_large_system_hash() if you later decide to use kmalloc'ed memor=
y
> instead.
>=20
=46orget about this. I was a little confused when reading the
alloc_large_system_hash() function. No I understand.

Sorry for the noise.


Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
