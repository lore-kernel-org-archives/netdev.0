From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] 2.6.37-rc5 Memory leak in net/ipv4/udp.c
Date: Fri, 17 Dec 2010 12:32:14 +0100
Message-ID: <1292585534.2906.12.camel@edumazet-laptop>
References: <19723.14557.349975.821418@ipc1.ka-ro>
	 <1292582116.2906.5.camel@edumazet-laptop>
	 <19723.17775.241784.993744@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lothar =?ISO-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58078 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab0LQLcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 06:32:19 -0500
Received: by wyb28 with SMTP id 28so512308wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 03:32:17 -0800 (PST)
In-Reply-To: <19723.17775.241784.993744@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 d=C3=A9cembre 2010 =C3=A0 12:11 +0100, Lothar Wa=C3=9Fma=
nn a =C3=A9crit :
> Hi,
>=20
> Eric Dumazet writes:
> > Le vendredi 17 d=C3=A9cembre 2010 =C3=A0 11:18 +0100, Lothar Wa=C3=9F=
mann a =C3=A9crit :
> > > The offending code in net/ipv4/udp.c is:
> > > |void __init udp_table_init(struct udp_table *table, const char *=
name)
> > > |{
> > > |	unsigned int i;
> > > |
> > > |	if (!CONFIG_BASE_SMALL)
> > > |		table->hash =3D alloc_large_system_hash(name,
> > > |			2 * sizeof(struct udp_hslot),
> > > |			uhash_entries,
> > > |			21, /* one slot per 2 MB */
> > > |			0,
> > > |			&table->log,
> > > |			&table->mask,
> > > |			64 * 1024);
> > > |	/*
> > > |	 * Make sure hash table has the minimum size
> > > |	 */
> > > |	if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1)=
 {
> > > |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> > > |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> > > In case of !CONFIG_BASE_SMALL and 'table->mask < UDP_HTABLE_SIZE_=
MIN - 1)'
> > > the memory allocated in the previous if clause becomes inacessibl=
e!
> > >=20
> > > Shouldn't this be:
> > > |	if (!CONFIG_BASE_SMALL && table->mask >=3D UDP_HTABLE_SIZE_MIN =
- 1) {
> > > |		table->hash =3D alloc_large_system_hash(name,
> > > |			2 * sizeof(struct udp_hslot),
> > > |			uhash_entries,
> > > |			21, /* one slot per 2 MB */
> > > |			0,
> > > |			&table->log,
> > > |			&table->mask,
> > > |			64 * 1024);
> > > |	} else {
> > > |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> > > |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> > > [...]
> > >=20
> >=20
> > Nothing we can do about it, there is no API to reverse the
> > alloc_large_system_hash() effect. We could call kmemleak api to at =
least
> > avoid this false alarm.
> >=20
> Do you have to call it at all in case of table->mask < UDP_HTABLE_SIZ=
E_MIN - 1?
>=20

We call alloc_large_system_hash() asking it to size the table _itself_.
We give some hints :=20

- How many slots per MB of avail memory.
- An upper limit (64*1024 slots because we only handle 65536 udp ports)
- but not a lower limit (not available in the API)

Problem is in your case, alloc_large_system_hash() allocates a very
small area. Then we catch the problem, seeing table->mask is too small
for our needs. We prefer to 'lost' this too small memory than crashing
kernel later.


> > We really want a minimum size for the UDP hash table, because our a=
lgos
> > depend on this.
> >=20
> I can't see why this could not be achieved by doing _either_
> alloc_large_system_hash() _OR_ kmalloc() as stated above, but not
> both.

We definitly want alloc_large_system_hash() for the general case
(nice NUMA spread, while kmalloc() would allocate the hash table on a
single memory node. Not so nice)

One way to handle this problem would be to add a new parameter to
alloc_large_system_hash() to specify a lower limit.
alloc_large_system_hash() would not even try to allocate a too small
array.

Is your system so small ?



