From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] 2.6.37-rc5 Memory leak in net/ipv4/udp.c
Date: Fri, 17 Dec 2010 11:35:16 +0100
Message-ID: <1292582116.2906.5.camel@edumazet-laptop>
References: <19723.14557.349975.821418@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lothar =?ISO-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62993 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab0LQKfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 05:35:21 -0500
Received: by wyb28 with SMTP id 28so468757wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 02:35:19 -0800 (PST)
In-Reply-To: <19723.14557.349975.821418@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 d=C3=A9cembre 2010 =C3=A0 11:18 +0100, Lothar Wa=C3=9Fma=
nn a =C3=A9crit :
> Hi,
>=20
> the kernel memory leak detector spews the message:
> |kmemleak: 2 new suspected memory leaks (see /sys/kernel/debug/kmemle=
ak)
> cat /sys/kernel/debug/kmemleak
> |unreferenced object 0xc7a1c000 (size 5120):
> |  comm "swapper", pid 1, jiffies 4294937513 (age 2320.120s)
> |  hex dump (first 32 bytes):
> |    aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa  ...............=
=2E
> |    aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa  ...............=
=2E
> |  backtrace:
> |    [<c00112b8>] alloc_large_system_hash+0x188/0x224
> |    [<c001be14>] udp_table_init+0x44/0x180
> |    [<c001bf64>] udp_init+0x14/0x78
> |    [<c001c620>] inet_init+0x138/0x240
> |    [<c0030368>] do_one_initcall+0x58/0x1a8
> |    [<c00083c8>] kernel_init+0x98/0x14c
> |    [<c0037714>] kernel_thread_exit+0x0/0x8
> |    [<ffffffff>] 0xffffffff
> |unreferenced object 0xc7a26000 (size 5120):
> |  comm "swapper", pid 1, jiffies 4294937513 (age 2320.130s)
> |  hex dump (first 32 bytes):
> |    aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa  ...............=
=2E
> |    aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa  ...............=
=2E
> |  backtrace:
> |    [<c00112b8>] alloc_large_system_hash+0x188/0x224
> |    [<c001be14>] udp_table_init+0x44/0x180
> |    [<c001bff0>] udplite4_register+0x10/0x94
> |    [<c001c624>] inet_init+0x13c/0x240
> |    [<c0030368>] do_one_initcall+0x58/0x1a8
> |    [<c00083c8>] kernel_init+0x98/0x14c
> |    [<c0037714>] kernel_thread_exit+0x0/0x8
> |    [<ffffffff>] 0xffffffff
>=20
> The offending code in net/ipv4/udp.c is:
> |void __init udp_table_init(struct udp_table *table, const char *name=
)
> |{
> |	unsigned int i;
> |
> |	if (!CONFIG_BASE_SMALL)
> |		table->hash =3D alloc_large_system_hash(name,
> |			2 * sizeof(struct udp_hslot),
> |			uhash_entries,
> |			21, /* one slot per 2 MB */
> |			0,
> |			&table->log,
> |			&table->mask,
> |			64 * 1024);
> |	/*
> |	 * Make sure hash table has the minimum size
> |	 */
> |	if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
> |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> In case of !CONFIG_BASE_SMALL and 'table->mask < UDP_HTABLE_SIZE_MIN =
- 1)'
> the memory allocated in the previous if clause becomes inacessible!
>=20
> Shouldn't this be:
> |	if (!CONFIG_BASE_SMALL && table->mask >=3D UDP_HTABLE_SIZE_MIN - 1)=
 {
> |		table->hash =3D alloc_large_system_hash(name,
> |			2 * sizeof(struct udp_hslot),
> |			uhash_entries,
> |			21, /* one slot per 2 MB */
> |			0,
> |			&table->log,
> |			&table->mask,
> |			64 * 1024);
> |	} else {
> |		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
> |				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
> [...]
>=20
>=20
>=20
> Lothar Wa=C3=9Fmann

Nothing we can do about it, there is no API to reverse the
alloc_large_system_hash() effect. We could call kmemleak api to at leas=
t
avoid this false alarm.

We really want a minimum size for the UDP hash table, because our algos
depend on this.

Why on your config alloc_large_system_hash() is allocating 5120 bytes, =
I
dont know :(


