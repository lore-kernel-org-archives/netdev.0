From: Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH] Fix RCU warning in rt_cache_seq_show
Date: Tue,  9 Aug 2011 18:02:40 +0100
Message-ID: <1312909360-2675-1-git-send-email-mark.rutland@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: Mark Rutland <mark.rutland@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Gergely Kalman <synapse@hippy.csoma.elte.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from service87.mimecast.com ([94.185.240.25]:51173 "HELO
	service87.mimecast.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754011Ab1HIRDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 13:03:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f2c31e32 ("net: fix NULL dereferences in check_peer_redir()")
added rcu protection to dst neighbour, and updated callsites for
dst_{get,set}_neighbour. Unfortunately, it missed rt_cache_seq_show.

This produces a warning on v3.1-rc1 (on a preemptible kernel, on an
ARM Vexpress A9x4):

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
include/net/dst.h:91 invoked rcu_dereference_check() without protection!

other info that might help us debug this:

rcu_scheduler_active =3D 1, debug_locks =3D 0
2 locks held by proc01/32159:

stack backtrace:
[<80014880>] (unwind_backtrace+0x0/0xf8) from [<802e5c78>] (rt_cache_seq_sh=
ow+0x18c/0x1c4)
[<802e5c78>] (rt_cache_seq_show+0x18c/0x1c4) from [<800e0c5c>] (seq_read+0x=
324/0x4a4)
[<800e0c5c>] (seq_read+0x324/0x4a4) from [<8010786c>] (proc_reg_read+0x70/0=
x94)
[<8010786c>] (proc_reg_read+0x70/0x94) from [<800c0ba8>] (vfs_read+0xb0/0x1=
44)
[<800c0ba8>] (vfs_read+0xb0/0x144) from [<800c0ea8>] (sys_read+0x40/0x70)
[<800c0ea8>] (sys_read+0x40/0x70) from [<8000e0c0>] (ret_fast_syscall+0x0/0=
x3c)

This patch adds calls to rcu_read_{lock,unlock} in rt_cache_seq_show,
protecting the dereferenced variable, and clearing the warning.

Signed-off-by: Mark Rutland <mark.rutland@arm.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Gergely Kalman <synapse@hippy.csoma.elte.hu>
---
 net/ipv4/route.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e3dec1c..6699ef7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -419,6 +419,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void=
 *v)
 =09=09struct neighbour *n;
 =09=09int len;
=20
+=09=09rcu_read_lock();
 =09=09n =3D dst_get_neighbour(&r->dst);
 =09=09seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
 =09=09=09      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
@@ -435,6 +436,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void=
 *v)
 =09=09=09-1,
 =09=09=09(n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0,
 =09=09=09r->rt_spec_dst, &len);
+=09=09rcu_read_unlock();
=20
 =09=09seq_printf(seq, "%*s\n", 127 - len, "");
 =09}
--=20
1.7.0.4


