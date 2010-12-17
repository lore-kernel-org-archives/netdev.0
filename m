From: =?iso-8859-15?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: Re: [BUG] 2.6.37-rc5 Memory leak in net/ipv4/udp.c
Date: Fri, 17 Dec 2010 12:47:22 +0100
Message-ID: <19723.19914.961119.861405@ipc1.ka-ro>
References: <19723.14557.349975.821418@ipc1.ka-ro>
	<1292582116.2906.5.camel@edumazet-laptop>
	<19723.17775.241784.993744@ipc1.ka-ro>
	<1292585534.2906.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([213.146.116.110]:48416 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab0LQLrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 06:47:36 -0500
In-Reply-To: <1292585534.2906.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet writes:
> Le vendredi 17 d=E9cembre 2010 =E0 12:11 +0100, Lothar Wa=DFmann a =E9=
crit :
> > Hi,
> >=20
> > Eric Dumazet writes:
> > > Le vendredi 17 d=E9cembre 2010 =E0 11:18 +0100, Lothar Wa=DFmann =
a =E9crit :
> > > > The offending code in net/ipv4/udp.c is:
> > > > |void __init udp_table_init(struct udp_table *table, const char=
 *name)
> > > > |{
> > > > |	unsigned int i;
> > > > |
> > > > |	if (!CONFIG_BASE_SMALL)
> > > > |		table->hash =3D alloc_large_system_hash(name,
> > > > |			2 * sizeof(struct udp_hslot),
> > > > |			uhash_entries,
> > > > |			21, /* one slot per 2 MB */
> > > > |			0,
> > > > |			&table->log,
> > > > |			&table->mask,
> > > > |			64 * 1024);
> > > > |	/*
> > > > |	 * Make sure hash table has the minimum size
> > > > |	 */
> > > > |	if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - =
1) {
> > > > |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> > > > |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> > > > In case of !CONFIG_BASE_SMALL and 'table->mask < UDP_HTABLE_SIZ=
E_MIN - 1)'
> > > > the memory allocated in the previous if clause becomes inacessi=
ble!
> > > >=20
> > > > Shouldn't this be:
> > > > |	if (!CONFIG_BASE_SMALL && table->mask >=3D UDP_HTABLE_SIZE_MI=
N - 1) {
> > > > |		table->hash =3D alloc_large_system_hash(name,
> > > > |			2 * sizeof(struct udp_hslot),
> > > > |			uhash_entries,
> > > > |			21, /* one slot per 2 MB */
> > > > |			0,
> > > > |			&table->log,
> > > > |			&table->mask,
> > > > |			64 * 1024);
> > > > |	} else {
> > > > |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> > > > |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> > > > [...]
> > > >=20
> > >=20
> > > Nothing we can do about it, there is no API to reverse the
> > > alloc_large_system_hash() effect. We could call kmemleak api to a=
t least
> > > avoid this false alarm.
> > >=20
> > Do you have to call it at all in case of table->mask < UDP_HTABLE_S=
IZE_MIN - 1?
> >=20
>=20
> We call alloc_large_system_hash() asking it to size the table _itself=
_.
> We give some hints :=20
>=20
> - How many slots per MB of avail memory.
> - An upper limit (64*1024 slots because we only handle 65536 udp port=
s)
> - but not a lower limit (not available in the API)
>=20
> Problem is in your case, alloc_large_system_hash() allocates a very
> small area. Then we catch the problem, seeing table->mask is too smal=
l
> for our needs. We prefer to 'lost' this too small memory than crashin=
g
> kernel later.
>=20
table->mask is not altered by alloc_large_system_hash(), so you could
detect the situation beforhand and avoid calling that function in this
case. As far as I can tell there is no need for
alloc_large_system_hash() if you later decide to use kmalloc'ed memory
instead.

The current situation is
if (!CONFIG_BASE_SMALL)
	call alloc_large_system_hash()
if (CONFIG_BASE_SMALL || table->mask < MIN)
	call kmalloc() dropping evnetually allocated memory from the
	previous if clause

My proposal was:
if (!CONFIG_BASE_SMALL && table->mask >=3D MIN)
	call alloc_large_system_hash()
else
	call kmalloc()

which is functionally equivalent except for the missing call to
alloc_large_system_hash() if the memory allocated by that function is
not used.

> > > We really want a minimum size for the UDP hash table, because our=
 algos
> > > depend on this.
> > >=20
> > I can't see why this could not be achieved by doing _either_
> > alloc_large_system_hash() _OR_ kmalloc() as stated above, but not
> > both.
>=20
> We definitly want alloc_large_system_hash() for the general case
> (nice NUMA spread, while kmalloc() would allocate the hash table on a
> single memory node. Not so nice)
>=20
That would still be the case with my proposed solution.


Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
