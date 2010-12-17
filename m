From: =?iso-8859-15?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: [BUG] 2.6.37-rc5 Memory leak in net/ipv4/udp.c
Date: Fri, 17 Dec 2010 11:18:05 +0100
Message-ID: <19723.14557.349975.821418@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([213.146.116.110]:43304 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532Ab0LQKZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 05:25:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the kernel memory leak detector spews the message:
|kmemleak: 2 new suspected memory leaks (see /sys/kernel/debug/kmemleak=
)
cat /sys/kernel/debug/kmemleak
|unreferenced object 0xc7a1c000 (size 5120):
|  comm "swapper", pid 1, jiffies 4294937513 (age 2320.120s)
|  hex dump (first 32 bytes):
|    aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa  ................
|    aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa  ................
|  backtrace:
|    [<c00112b8>] alloc_large_system_hash+0x188/0x224
|    [<c001be14>] udp_table_init+0x44/0x180
|    [<c001bf64>] udp_init+0x14/0x78
|    [<c001c620>] inet_init+0x138/0x240
|    [<c0030368>] do_one_initcall+0x58/0x1a8
|    [<c00083c8>] kernel_init+0x98/0x14c
|    [<c0037714>] kernel_thread_exit+0x0/0x8
|    [<ffffffff>] 0xffffffff
|unreferenced object 0xc7a26000 (size 5120):
|  comm "swapper", pid 1, jiffies 4294937513 (age 2320.130s)
|  hex dump (first 32 bytes):
|    aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa  ................
|    aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa aa  ................
|  backtrace:
|    [<c00112b8>] alloc_large_system_hash+0x188/0x224
|    [<c001be14>] udp_table_init+0x44/0x180
|    [<c001bff0>] udplite4_register+0x10/0x94
|    [<c001c624>] inet_init+0x13c/0x240
|    [<c0030368>] do_one_initcall+0x58/0x1a8
|    [<c00083c8>] kernel_init+0x98/0x14c
|    [<c0037714>] kernel_thread_exit+0x0/0x8
|    [<ffffffff>] 0xffffffff

The offending code in net/ipv4/udp.c is:
|void __init udp_table_init(struct udp_table *table, const char *name)
|{
|	unsigned int i;
|
|	if (!CONFIG_BASE_SMALL)
|		table->hash =3D alloc_large_system_hash(name,
|			2 * sizeof(struct udp_hslot),
|			uhash_entries,
|			21, /* one slot per 2 MB */
|			0,
|			&table->log,
|			&table->mask,
|			64 * 1024);
|	/*
|	 * Make sure hash table has the minimum size
|	 */
|	if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
|		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
|				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
In case of !CONFIG_BASE_SMALL and 'table->mask < UDP_HTABLE_SIZE_MIN - =
1)'
the memory allocated in the previous if clause becomes inacessible!

Shouldn't this be:
|	if (!CONFIG_BASE_SMALL && table->mask >=3D UDP_HTABLE_SIZE_MIN - 1) {
|		table->hash =3D alloc_large_system_hash(name,
|			2 * sizeof(struct udp_hslot),
|			uhash_entries,
|			21, /* one slot per 2 MB */
|			0,
|			&table->log,
|			&table->mask,
|			64 * 1024);
|	} else {
|		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
|				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
[...]



Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
