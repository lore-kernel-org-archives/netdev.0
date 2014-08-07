From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [setsockopt] WARNING: CPU: 0 PID: 1444 at
 kernel/sched/core.c:7088 __might_sleep+0x51/0x16f()
Date: Thu, 7 Aug 2014 17:17:41 +0200
Message-ID: <20140807151741.GP19379@twins.programming.kicks-ass.net>
References: <20140805214624.GA9973@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9cV+svY7NXaw/O8a"
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	lkp@01.org, Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140805214624.GA9973@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--9cV+svY7NXaw/O8a
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 06, 2014 at 05:46:24AM +0800, Fengguang Wu wrote:
> Greetings,
>=20
> Here is a microcode/load_module error triggered by debug check commit
> 64c2181bc433b17f04da8fe8592aa83cceac9606 ("sched: Debug nested sleeps"):
>=20
> [main] Setsockopt(1 8 80d1000 4) on fd 21 [1:2:1]
> [main] Setsockopt(1 2f 80d1000 4) on fd 22 [4:2:60]
> [   14.027148] ------------[ cut here ]------------
> [   14.027864] WARNING: CPU: 0 PID: 210 at kernel/sched/core.c:7088 __mig=
ht_sleep+0x40/0x68()
> [   14.029295] do not call blocking ops when !TASK_RUNNING; state=3D2 set=
 at [<c144e379>] prepare_to_wait+0x35/0x56
> [   14.030590] Modules linked in:
> [   14.031136] CPU: 0 PID: 210 Comm: trinity-main Not tainted 3.16.0-0216=
7-g254135e #972
> [   14.032263]  00000000 c0f4de4c c0f4de24 c196630c c0f4de3c c142f01a c14=
47632 c0f1dbb0
> [   14.033480]  00000002 b0066140 c0f4de54 c142f057 00000009 c0f4de4c c1b=
3bac8 c0f4de68
> [   14.034640]  c0f4de88 c1447632 c1b3bb12 00001bb0 c1b3bac8 00000002 c14=
4e379 c144e379
> [   14.035983] Call Trace:
> [   14.036355]  [<c196630c>] dump_stack+0x16/0x18
> [   14.037005]  [<c142f01a>] warn_slowpath_common+0x55/0x6c
> [   14.037715]  [<c1447632>] ? __might_sleep+0x40/0x68
> [   14.038372]  [<c142f057>] warn_slowpath_fmt+0x26/0x2a
> [   14.039097]  [<c1447632>] __might_sleep+0x40/0x68
> [   14.039787]  [<c144e379>] ? prepare_to_wait+0x35/0x56
> [   14.040595]  [<c144e379>] ? prepare_to_wait+0x35/0x56
> [   14.041272]  [<c14a837e>] kmem_cache_alloc+0x39/0xb0
> [   14.041934]  [<c18fa2de>] ? __alloc_skb+0x3c/0x154
> [   14.042572]  [<c18fa2de>] __alloc_skb+0x3c/0x154
> [   14.043339]  [<c145117a>] ? mark_held_locks+0x44/0x60
> [   14.044141]  [<c1946093>] sigd_enq2+0x2a/0xff
> [   14.044836]  [<c1946188>] sigd_enq+0x20/0x2a
> [   14.045405]  [<c19467fb>] svc_listen+0x8b/0x11f
> [   14.046009]  [<c144e5a6>] ? __wake_up_sync+0xd/0xd
> [   14.046653]  [<c18f4132>] SyS_listen+0x37/0x51
> [   14.047423]  [<c18f4ce5>] SyS_socketcall+0x90/0x1c0
> [   14.048328]  [<c145136e>] ? trace_hardirqs_on+0xb/0xd
> [   14.049061]  [<c19729f6>] ? restore_all+0xf/0xf
> [   14.049665]  [<c19729bd>] syscall_call+0x7/0x7
> [   14.050253]  [<c1970000>] ? __ww_mutex_lock_interruptible+0x165/0x573
> [   14.051147] ---[ end trace 6f1365c63eafedde ]---
> [main] Setsockopt(1 2d 80d1000 f0) on fd 25 [1:1:1]

---
Subject: atm: Fix blocking in wait loop

One should not call blocking primitives inside a wait loop, since both
require task_struct::state to sleep, so the inner will destroy the outer
state.

In this instance sigd_enq() will possible sleep for alloc_skb(), now if
I understand the code right, we do not actually need to call sigd_enq()
after the initial prepare_to_wait(), because we test the termination
condition before schedule() anyhow.

So we can simply move it up a bit and avoid the entire confusion.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 net/atm/svc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/atm/svc.c b/net/atm/svc.c
index d8e5d0c2ebbc..445ac238b69b 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -297,8 +297,8 @@ static int svc_listen(struct socket *sock, int backlog)
 		goto out;
 	}
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc, as_listen, NULL, NULL, &vcc->local);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);

--9cV+svY7NXaw/O8a
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT45iVAAoJEHZH4aRLwOS6WooP/1d//0LIEQ9nnZsjrlivF2y6
kt9PJ2HHEmd99DSyNAvgDP4YKZLvg/RGxIuS9jX8uLlrFE/FCrHj/8C2c/9f+2kF
q8EscW//k5LALvH15B6Kck+KxAIku8Sj5od6CBM+Kuv2NEpK02MFrNczcVQ5Icw7
YQAnH+orWKR0DvCFPEszbQecw565BgW77OJDjKeOu38JHlhnihkgzxmDhN26HjGx
GC6Hqf/AAzqlTNG/cg4W8u8+IqJZG7djK3cOMZc3vtwfCbprB7dgbysl/iprvbZc
M1EX/h/1YbHr5D0+25VCwpeqB+90AnDnBG9TApU+mUFHjKF74cFix/FujnYBVvIM
SHBBdkclR5iWnVit1VgRT7qcJAmxf5NMTkaJLS789zm/uHBVFh+ruyNSph00DVPQ
tIrjMMYGvxAsZwvye9XpyBiSaBff18vyUSZmxoo2pjgITMMYldNKeWilrEi+xATq
moO4ZpcGclHSCALOc9E4aJBI4AUsH47xUxca2sV01gLXNyuFxEGNUEoA53um9bBY
gUb+5uD3irWhoSdOCsDZkwYd5c9w5AvAXnoT1IpuSxq3m2jXN+ZSdW3m8/J4wkpr
cA8rmDeX94Q1Nu/RNRf/3M4PTnovIWGAoKWaftJdRS7VhZC7G4zA3br+KmMhNAdJ
Pj0+vBTq78GZIiSXytl9
=EZHv
-----END PGP SIGNATURE-----

--9cV+svY7NXaw/O8a--
