From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix RCU warning in rt_cache_seq_show
Date: Tue, 09 Aug 2011 19:18:56 +0200
Message-ID: <1312910336.2371.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1312909360-2675-1-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Gergely Kalman <synapse@hippy.csoma.elte.hu>
To: Mark Rutland <mark.rutland@arm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38395 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011Ab1HIRS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 13:18:58 -0400
Received: by wyg24 with SMTP id 24so145770wyg.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 10:18:57 -0700 (PDT)
In-Reply-To: <1312909360-2675-1-git-send-email-mark.rutland@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 ao=C3=BBt 2011 =C3=A0 18:02 +0100, Mark Rutland a =C3=A9cri=
t :
> Commit f2c31e32 ("net: fix NULL dereferences in check_peer_redir()")
> added rcu protection to dst neighbour, and updated callsites for
> dst_{get,set}_neighbour. Unfortunately, it missed rt_cache_seq_show.
>=20
> This produces a warning on v3.1-rc1 (on a preemptible kernel, on an
> ARM Vexpress A9x4):
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> include/net/dst.h:91 invoked rcu_dereference_check() without protecti=
on!
>=20
> other info that might help us debug this:
>=20
> rcu_scheduler_active =3D 1, debug_locks =3D 0
> 2 locks held by proc01/32159:
>=20
> stack backtrace:
> [<80014880>] (unwind_backtrace+0x0/0xf8) from [<802e5c78>] (rt_cache_=
seq_show+0x18c/0x1c4)
> [<802e5c78>] (rt_cache_seq_show+0x18c/0x1c4) from [<800e0c5c>] (seq_r=
ead+0x324/0x4a4)
> [<800e0c5c>] (seq_read+0x324/0x4a4) from [<8010786c>] (proc_reg_read+=
0x70/0x94)
> [<8010786c>] (proc_reg_read+0x70/0x94) from [<800c0ba8>] (vfs_read+0x=
b0/0x144)
> [<800c0ba8>] (vfs_read+0xb0/0x144) from [<800c0ea8>] (sys_read+0x40/0=
x70)
> [<800c0ea8>] (sys_read+0x40/0x70) from [<8000e0c0>] (ret_fast_syscall=
+0x0/0x3c)
>=20
> This patch adds calls to rcu_read_{lock,unlock} in rt_cache_seq_show,
> protecting the dereferenced variable, and clearing the warning.
>=20
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Gergely Kalman <synapse@hippy.csoma.elte.hu>
> ---
>  net/ipv4/route.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index e3dec1c..6699ef7 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -419,6 +419,7 @@ static int rt_cache_seq_show(struct seq_file *seq=
, void *v)
>  		struct neighbour *n;
>  		int len;
> =20
> +		rcu_read_lock();
>  		n =3D dst_get_neighbour(&r->dst);
>  		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
>  			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
> @@ -435,6 +436,7 @@ static int rt_cache_seq_show(struct seq_file *seq=
, void *v)
>  			-1,
>  			(n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0,
>  			r->rt_spec_dst, &len);
> +		rcu_read_unlock();
> =20
>  		seq_printf(seq, "%*s\n", 127 - len, "");
>  	}


Hmm, I though rcu_read_lock_bh() (done by caller of this function) was
protecting us here.


Paul, is it really needed, or is it a lockdep artifact ?





