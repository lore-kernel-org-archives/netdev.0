From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux Route Cache performance tests
Date: Mon, 07 Nov 2011 00:08:35 +0100
Message-ID: <1320620915.6506.44.camel@edumazet-laptop>
References: <4EB6AE62.5050803@itcare.pl>
	    <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>
	   <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>
	  <1320608290.6506.33.camel@edumazet-laptop> <4EB6ED2E.1070106@itcare.pl>
	 <1320614788.6506.38.camel@edumazet-laptop> <4EB702D3.1090703@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61179 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126Ab1KFXIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2011 18:08:41 -0500
Received: by wyh15 with SMTP id 15so3965420wyh.19
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2011 15:08:39 -0800 (PST)
In-Reply-To: <4EB702D3.1090703@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 06 novembre 2011 =C3=A0 22:57 +0100, Pawe=C5=82 Staszewski =
a =C3=A9crit :
> W dniu 2011-11-06 22:26, Eric Dumazet pisze:
> > Le dimanche 06 novembre 2011 =C3=A0 21:25 +0100, Pawe=C5=82 Staszew=
ski a =C3=A9crit :
> >> Yes with this is a little problem i think with kernel 3.1 because
> >> dmesg | egrep  '(rhash)|(route)'
> >> [    0.000000] Command line: root=3D/dev/md2 rhash_entries=3D20971=
52
> >> [    0.000000] Kernel command line: root=3D/dev/md2 rhash_entries=3D=
2097152
> >> [    4.697294] IP route cache hash table entries: 524288 (order: 1=
0,
> >> 4194304 bytes)
> >>
> >>
> > Dont tell me you _still_ use a 32bit kernel ?
> no it is 64bit :)
> Linux localhost 3.1.0 #16 SMP Sun Nov 6 18:09:48 CET 2011 x86_64 Inte=
l(R)
> :)
>=20
> > If so, you need to tweak alloc_large_system_hash() to use vmalloc,
> > because you hit MAX_ORDER (10) page allocations.
> funny then :)
> Maybee i turned off too many kernel features
> > But considering LOWMEM is about 700 Mbytes, you wont be able to cre=
ate a
> > lot of route cache entries.
> >
> > Come on, do us a favor, and enter new era of computing.

OK, then your kernel is not CONFIG_NUMA enabled

It seems strange given you probably have a NUMA machine (24 cpus)

If so, your choices are :

1) enable CONFIG_NUMA. Really this is a must given the workload of your
machine.

2) Or : you need to add "hashdist=3D1" on boot params
   and patch your kernel with following patch :

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..07f86e0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5362,7 +5362,6 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_t=
able *table, int write,
=20
 int hashdist =3D HASHDIST_DEFAULT;
=20
-#ifdef CONFIG_NUMA
 static int __init set_hashdist(char *str)
 {
 	if (!str)
@@ -5371,7 +5370,6 @@ static int __init set_hashdist(char *str)
 	return 1;
 }
 __setup("hashdist=3D", set_hashdist);
-#endif
=20
 /*
  * allocate a large system hash table from bootmem
