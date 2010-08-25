From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Fix sysctl_tcp_max_orphans when PAGE_SIZE != 4k
Date: Wed, 25 Aug 2010 19:50:34 +0200
Message-ID: <1282758634.2487.576.camel@edumazet-laptop>
References: <20100825071626.GA13681@kryten>  <20100825071701.GA14962@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, miltonm@bga.com
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52701 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab0HYRuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 13:50:39 -0400
Received: by eyg5 with SMTP id 5so499799eyg.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 10:50:38 -0700 (PDT)
In-Reply-To: <20100825071701.GA14962@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 ao=C3=BBt 2010 =C3=A0 17:17 +1000, Anton Blanchard a =C3=
=A9crit :
> We were hard coding 4096 when sizing sysctl_tcp_max_orphans which
> causes problems when PAGE_SIZE is not 4k. We calculate an order based=
 on
> PAGE_SHIFT so the count should be based on PAGE_SIZE
>=20
> Signed-off-By: Milton Miller <miltonm@bga.com>
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
>=20
> Index: powerpc.git/net/ipv4/tcp.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- powerpc.git.orig/net/ipv4/tcp.c	2010-08-25 17:04:51.190305401 +10=
00
> +++ powerpc.git/net/ipv4/tcp.c	2010-08-25 17:05:15.463884764 +1000
> @@ -3270,7 +3270,7 @@ void __init tcp_init(void)
>  		;
>  	if (order >=3D 4) {
>  		tcp_death_row.sysctl_max_tw_buckets =3D 180000;
> -		sysctl_tcp_max_orphans =3D 4096 << (order - 4);
> +		sysctl_tcp_max_orphans =3D PAGE_SIZE << (order - 4);
>  		sysctl_max_syn_backlog =3D 1024;
>  	} else if (order < 3) {
>  		tcp_death_row.sysctl_max_tw_buckets >>=3D (3 - order);
> --

In fact, existing code makes litle sense....

(tcp_hashinfo.bhash_size * sizeof(struct inet_bind_hashbucket))

is much bigger if spinlock debugging is on. Its strange to select bigge=
r
limits in this case (where kernel structures are also bigger)

bhash_size max is 65536, and we get this value even for small machines.=
=20

Sizing would probably be better if using ehash_size instead of
bhash_size

Maybe remove the 'order' loop and use ehash_size, already a result of
the available memory or thash_entries tunable.

unsigned int ehash_size =3D tcp_hashinfo.ehash_mask + 1;

tcp_death_row.sysctl_max_tw_buckets =3D cnt / 2;
sysctl_tcp_max_orphans =3D cnt / 2;
sysctl_max_syn_backlog =3D min(128, cnt / 256);



