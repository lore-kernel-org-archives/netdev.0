From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Query on a lockdep issue in neigh_lookup
Date: Wed, 14 Sep 2011 11:36:57 +0200
Message-ID: <1315993017.2361.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAByGWUHkt=6AjW_GFsGd1EnbMC=pjhtxRu8ez0sw6rZNvA_nxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Murali raja Muniraju <murali.rajam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f52.google.com ([209.85.215.52]:43996 "EHLO
	mail-ew0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785Ab1INJgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 05:36:51 -0400
Received: by ewy28 with SMTP id 28so877585ewy.11
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2011 02:36:49 -0700 (PDT)
In-Reply-To: <CAByGWUHkt=6AjW_GFsGd1EnbMC=pjhtxRu8ez0sw6rZNvA_nxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 septembre 2011 =C3=A0 16:11 -0700, Murali raja Muniraju a =C3=
=A9crit :
> Hi,
>    I see a potential deadlock situation on the kernel 2.6.34. Has thi=
s
> been fixed in the later version of the kernel.

Hmm, is it a pristine 2.6.34, or something you modified ?

Please dont ask us to debug your changes, without even making this clea=
r
at the very beginning.

netdev is not at your disposal.

>=20
> I see that one after holding the neigh_lookup, one can acquire the
> lock for rt_hash_locks
>=20
> But there is a situation while freed skb's in dst_release while
> holding the rt_hash_locks, neigh_lookup can be called which tries to
> acquire its lock.
>=20

how so ? Following 2.6.34 code is 100% safe.

void dst_release(struct dst_entry *dst)
{
        if (dst) {
               int newrefcnt;

               smp_mb__before_atomic_dec();
               newrefcnt =3D atomic_dec_return(&dst->__refcnt);
               WARN_ON(newrefcnt < 0);
        }
}


> This seems to be a deadlock candidate.
>=20

Only because of some alien patch.

> Thanks,
> Murali
>=20
> Below if the scenario found by lockdep on a debug kernel during the
> kernel bootup.
>=20
>     [   92.245713] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>  [   92.246640] [ INFO: possible circular locking dependency detected=
 ]
>  [   92.246640] 2.6.34-dbg-2011082906 #1
>  [   92.246640] -----------------------------------------------------=
--
>  [   92.246640] swapper/0 is trying to acquire lock:
>  [   92.246640]  (&tbl->lock){++--..}, at: [<ffffffff81553a22>]
> neigh_lookup+0x42/0xd0
>  [   92.246640]
>  [   92.246640] but task is already holding lock:
>  [   92.246640]  (&(&rt_hash_locks[i])->rlock){+.-...}, at:
> [<ffffffff815798e0>] rt_intern_hash+0xd0/0x880
>  [   92.246640]
>  [   92.246640] which lock already depends on the new lock.
>  [   92.246640]
>  [   92.246640]
>  [   92.246640] the existing dependency chain (in reverse order) is:
>  [   92.246640]
>  [   92.246640] -> #2 (&(&rt_hash_locks[i])->rlock){+.-...}:
>  [   92.246640]        [<ffffffff810e7700>] __lock_acquire+0xe30/0x11=
90
>  [   92.246640]        [<ffffffff810e7af3>] lock_acquire+0x93/0x120
>  [   92.246640]        [<ffffffff815ed266>] _raw_spin_lock_bh+0x36/0x=
50
>  [   92.246640]        [<ffffffff81576a26>] rt_dst_release+0x66/0xc0

I cant see rt_dst_release() in 2.6.34




>  [   92.246640]        [<ffffffff8155194c>] dst_release+0x5c/0x90
>  [   92.246640]        [<ffffffff8153aef5>] skb_release_head_state+0x=
95/0xd0
>  [   92.246640]        [<ffffffff8153ad06>] __kfree_skb+0x16/0xa0
>  [   92.246640]        [<ffffffff8153ae12>] kfree_skb+0x42/0x90
>  [   92.246640]        [<ffffffff81552fae>] __neigh_event_send+0x11e/=
0x1d0
>  [   92.246640]        [<ffffffff81553193>] neigh_resolve_output+0x13=
3/0x2f0
>  [   92.246640]        [<ffffffff81584742>] ip_output+0x2c2/0x3a0
>  [   92.246640]        [<ffffffff8158291d>] ip_local_out+0xad/0xc0
>  [   92.246640]        [<ffffffff81582cc0>] ip_send_reply+0x290/0x340
>  [   92.246640]        [<ffffffff815a3ba1>] tcp_v4_send_reset+0x1a1/0=
x310
>  [   92.246640]        [<ffffffff815a7b04>] tcp_v4_rcv+0x314/0x9b0
>  [   92.246640]        [<ffffffff8157e344>] ip_local_deliver_finish+0=
xf4/0x200
>  [   92.246640]        [<ffffffff8157e4e0>] ip_local_deliver+0x90/0xa=
0
>  [   92.246640]        [<ffffffff8157dbf1>] ip_rcv_finish+0x111/0x460
>  [   92.246640]        [<ffffffff8157e17d>] ip_rcv+0x23d/0x310
>  [   92.246640]        [<ffffffff81549144>] __netif_receive_skb+0x2d4=
/0x570
>  [   92.246640]        [<ffffffff81549620>] netif_receive_skb+0xb0/0x=
c0
>  [   92.246640]        [<ffffffff81549d28>] napi_gro_receive+0x148/0x=
180
>  [   92.246640]        [<ffffffffa0066aba>]
