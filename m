From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.2.0-rc3+ (Linus git -
 883381d9f1c5a6329bbb796e23ae52c939940310) - INFO: suspicious RCU usage
Date: Wed, 30 Nov 2011 07:05:55 +0100
Message-ID: <1322633155.23721.5.camel@edumazet-laptop>
References: <CAHFgRy-hAMF344eChZ9tLnFB7qUS_v3m0LvtBKWjbFmBeeASsA@mail.gmail.com>
	 <1322632602.23721.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: Miles Lane <miles.lane@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45009 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab1K3GGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 01:06:03 -0500
In-Reply-To: <1322632602.23721.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 06:56 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mercredi 30 novembre 2011 =C3=A0 00:09 -0500, Miles Lane a =C3=A9c=
rit :
> > I got the following message while running "find /proc | xargs head"=
 to
> > see whether accessing any proc files would cause trouble.
> >=20
> > [  442.112632] [ INFO: suspicious RCU usage. ]
> > [  442.112634] -------------------------------
> > [  442.112637] include/net/dst.h:91 suspicious rcu_dereference_chec=
k() usage!
> > [  442.112640]
> > [  442.112641] other info that might help us debug this:
> > [  442.112643]
> > [  442.112645]
> > [  442.112646] rcu_scheduler_active =3D 1, debug_locks =3D 1
> > [  442.112650] 2 locks held by head/4903:
> > [  442.112652]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff810e160a>]
> > seq_read+0x38/0x35d
> > [  442.112665]  #1:  (rcu_read_lock_bh){.+....}, at:
> > [<ffffffff812f831e>] rcu_read_lock_bh+0x0/0x35
> > [  442.112676]
> > [  442.112677] stack backtrace:
> > [  442.112681] Pid: 4903, comm: head Not tainted 3.2.0-rc3+ #42
> > [  442.112684] Call Trace:
> > [  442.112691]  [<ffffffff8105cdd2>] lockdep_rcu_suspicious+0xaf/0x=
b8
> > [  442.112697]  [<ffffffff812f8e02>] dst_get_neighbour.isra.31+0x44=
/0x4c
> > [  442.112702]  [<ffffffff812f8e86>] rt_cache_seq_show+0x46/0x194
> > [  442.112708]  [<ffffffff812f8351>] ? rcu_read_lock_bh+0x33/0x35
> > [  442.112714]  [<ffffffff8104b57a>] ? rcu_read_lock_bh_held+0x9/0x=
37
> > [  442.112719]  [<ffffffff812f85c2>] ? rt_cache_get_first+0x72/0x11=
6
> > [  442.112725]  [<ffffffff810e184d>] seq_read+0x27b/0x35d
> > [  442.112730]  [<ffffffff810e15d2>] ? seq_lseek+0xda/0xda
> > [  442.112736]  [<ffffffff8110e3e1>] proc_reg_read+0x8e/0xad
> > [  442.112741]  [<ffffffff810c6e23>] vfs_read+0xa0/0xc7
> > [  442.112746]  [<ffffffff810c80bf>] ? fget_light+0x35/0x98
> > [  442.112750]  [<ffffffff810c6e8f>] sys_read+0x45/0x69
> > [  442.112756]  [<ffffffff8136a27b>] system_call_fastpath+0x16/0x1b
>=20
>=20
> Thanks for the report Miles, I'll provide a patch in a couple of minu=
tes
> after testing it
>=20
>=20

[PATCH] ipv4: fix lockdep splat in rt_cache_seq_show

After commit f2c31e32b378 (fix NULL dereferences in check_peer_redir())=
,
dst_get_neighbour() should be guarded by rcu_read_lock() /
rcu_read_unlock() section.

Reported-by: Miles Lane <miles.lane@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5c28472..57e01bc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -417,9 +417,13 @@ static int rt_cache_seq_show(struct seq_file *seq,=
 void *v)
 	else {
 		struct rtable *r =3D v;
 		struct neighbour *n;
-		int len;
+		int len, HHUptod;
=20
+		rcu_read_lock();
 		n =3D dst_get_neighbour(&r->dst);
+		HHUptod =3D (n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0;
+		rcu_read_unlock();
+
 		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
 			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
 			r->dst.dev ? r->dst.dev->name : "*",
@@ -433,7 +437,7 @@ static int rt_cache_seq_show(struct seq_file *seq, =
void *v)
 			      dst_metric(&r->dst, RTAX_RTTVAR)),
 			r->rt_key_tos,
 			-1,
-			(n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0,
+			HHUptod,
 			r->rt_spec_dst, &len);
=20
 		seq_printf(seq, "%*s\n", 127 - len, "");
