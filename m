From: =?iso-8859-15?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: Re: [BUG] 2.6.37-rc5 Memory leak in net/ipv4/udp.c
Date: Fri, 17 Dec 2010 12:11:43 +0100
Message-ID: <19723.17775.241784.993744@ipc1.ka-ro>
References: <19723.14557.349975.821418@ipc1.ka-ro>
	<1292582116.2906.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([213.146.116.110]:40872 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab0LQLLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 06:11:47 -0500
In-Reply-To: <1292582116.2906.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Eric Dumazet writes:
> Le vendredi 17 d=E9cembre 2010 =E0 11:18 +0100, Lothar Wa=DFmann a =E9=
crit :
> > The offending code in net/ipv4/udp.c is:
> > |void __init udp_table_init(struct udp_table *table, const char *na=
me)
> > |{
> > |	unsigned int i;
> > |
> > |	if (!CONFIG_BASE_SMALL)
> > |		table->hash =3D alloc_large_system_hash(name,
> > |			2 * sizeof(struct udp_hslot),
> > |			uhash_entries,
> > |			21, /* one slot per 2 MB */
> > |			0,
> > |			&table->log,
> > |			&table->mask,
> > |			64 * 1024);
> > |	/*
> > |	 * Make sure hash table has the minimum size
> > |	 */
> > |	if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
> > |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> > |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> > In case of !CONFIG_BASE_SMALL and 'table->mask < UDP_HTABLE_SIZE_MI=
N - 1)'
> > the memory allocated in the previous if clause becomes inacessible!
> >=20
> > Shouldn't this be:
> > |	if (!CONFIG_BASE_SMALL && table->mask >=3D UDP_HTABLE_SIZE_MIN - =
1) {
> > |		table->hash =3D alloc_large_system_hash(name,
> > |			2 * sizeof(struct udp_hslot),
> > |			uhash_entries,
> > |			21, /* one slot per 2 MB */
> > |			0,
> > |			&table->log,
> > |			&table->mask,
> > |			64 * 1024);
> > |	} else {
> > |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> > |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> > [...]
> >=20
>=20
> Nothing we can do about it, there is no API to reverse the
> alloc_large_system_hash() effect. We could call kmemleak api to at le=
ast
> avoid this false alarm.
>=20
Do you have to call it at all in case of table->mask < UDP_HTABLE_SIZE_=
MIN - 1?

> We really want a minimum size for the UDP hash table, because our alg=
os
> depend on this.
>=20
I can't see why this could not be achieved by doing _either_
alloc_large_system_hash() _OR_ kmalloc() as stated above, but not
both.


Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
