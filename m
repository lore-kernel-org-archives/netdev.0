From: Yury Polyanskiy <ypolyans@princeton.edu>
Subject: [PATCH] xfrm: SAD entries do not expire correctly after
 suspend-resume
Date: Sun, 8 Nov 2009 21:12:49 -0500
Message-ID: <20091108211249.2ecdfd38@penta.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/M2/legRKFtlEb50HQCJ8=Nq"; protocol="application/pgp-signature"
To: netdev@vger.kernel.org, davem@davemloft.net, peterz@infradead.org,
	yoshfuji@linux-ipv6.org, Thomas Gleixner <tglx@linutronix.de>,
	mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppa01.Princeton.EDU ([128.112.128.213]:47842 "EHLO
	ppa01.Princeton.EDU" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbZKICWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 21:22:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/M2/legRKFtlEb50HQCJ8=Nq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


  This fixes the following bug in the current implementation of
net/xfrm: SAD entries timeouts do not count the time spent by the machine=20
in the suspended state. This leads to the connectivity problems because=20
after resuming local machine thinks that the SAD entry is still valid, whil=
e=20
it has already been expired on the remote server.

  The cause of this is very simple: the timeouts in the net/xfrm are bound =
to=20
the old mod_timer() timers. This patch reassigns them to the
CLOCK_REALTIME hrtimer.

  I have been using this version of the patch for a few months on my
machines without any problems. Also run a few stress tests w/o any
issues.

  This version of the patch uses tasklet_hrtimer by Peter Zijlstra
(commit 9ba5f0).

  This patch is against 2.6.31.4. Please CC me.

Signed-off-by: Yury Polyanskiy <polyanskiy@gmail.com>
---
 include/net/xfrm.h    |    5 ++++-
 net/xfrm/xfrm_state.c |   34 +++++++++++++++++++---------------
 2 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9e3a3f4..ef28810 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -19,6 +19,9 @@
 #include <net/route.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
+
+#include <linux/interrupt.h>
+
 #ifdef CONFIG_XFRM_STATISTICS
 #include <net/snmp.h>
 #endif
@@ -199,7 +202,7 @@ struct xfrm_state
 	struct xfrm_stats	stats;
=20
 	struct xfrm_lifetime_cur curlft;
-	struct timer_list	timer;
+	struct tasklet_hrtimer	mtimer;
=20
 	/* Last used time */
 	unsigned long		lastused;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f2f7c63..45fff9c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -21,6 +21,9 @@
 #include <linux/cache.h>
 #include <linux/audit.h>
 #include <asm/uaccess.h>
+#include <linux/ktime.h>
+#include <linux/interrupt.h>
+#include <linux/kernel.h>
=20
 #include "xfrm_hash.h"
=20
@@ -352,7 +355,7 @@ static void xfrm_put_mode(struct xfrm_mode *mode)
=20
 static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
-	del_timer_sync(&x->timer);
+	tasklet_hrtimer_cancel(&x->mtimer);
 	del_timer_sync(&x->rtimer);
 	kfree(x->aalg);
 	kfree(x->ealg);
@@ -398,9 +401,10 @@ static inline unsigned long make_jiffies(long secs)
 		return secs*HZ;
 }
=20
-static void xfrm_timer_handler(unsigned long data)
-{
-	struct xfrm_state *x =3D (struct xfrm_state*)data;
+static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
+{=09
+	struct tasklet_hrtimer *thr =3D container_of(me, struct tasklet_hrtimer, =
timer);
+	struct xfrm_state *x =3D container_of(thr, struct xfrm_state, mtimer);
 	struct net *net =3D xs_net(x);
 	unsigned long now =3D get_seconds();
 	long next =3D LONG_MAX;
@@ -451,8 +455,9 @@ static void xfrm_timer_handler(unsigned long data)
 	if (warn)
 		km_state_expired(x, 0, 0);
 resched:
-	if (next !=3D LONG_MAX)
-		mod_timer(&x->timer, jiffies + make_jiffies(next));
+	if (next !=3D LONG_MAX){
+		tasklet_hrtimer_start(&x->mtimer, ktime_set(next, 0), HRTIMER_MODE_REL);
+	}
=20
 	goto out;
=20
@@ -474,6 +479,7 @@ expired:
=20
 out:
 	spin_unlock(&x->lock);
+	return HRTIMER_NORESTART;
 }
=20
 static void xfrm_replay_timer_handler(unsigned long data);
@@ -492,7 +498,7 @@ struct xfrm_state *xfrm_state_alloc(struct net *net)
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
-		setup_timer(&x->timer, xfrm_timer_handler, (unsigned long)x);
+		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_REALTIME, HRT=
IMER_MODE_ABS);
 		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
 				(unsigned long)x);
 		x->curlft.add_time =3D get_seconds();
@@ -843,8 +849,7 @@ found:
 				hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 			}
 			x->lft.hard_add_expires_seconds =3D net->xfrm.sysctl_acq_expires;
-			x->timer.expires =3D jiffies + net->xfrm.sysctl_acq_expires*HZ;
-			add_timer(&x->timer);
+			tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expire=
s, 0), HRTIMER_MODE_REL);
 			net->xfrm.state_num++;
 			xfrm_hash_grow_check(net, x->bydst.next !=3D NULL);
 		} else {
@@ -921,7 +926,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 		hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 	}
=20
-	mod_timer(&x->timer, jiffies + HZ);
+	tasklet_hrtimer_start(&x->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
 	if (x->replay_maxage)
 		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
=20
@@ -1019,8 +1024,7 @@ static struct xfrm_state *__find_acq_core(struct net =
*net, unsigned short family
 		x->props.reqid =3D reqid;
 		x->lft.hard_add_expires_seconds =3D net->xfrm.sysctl_acq_expires;
 		xfrm_state_hold(x);
-		x->timer.expires =3D jiffies + net->xfrm.sysctl_acq_expires*HZ;
-		add_timer(&x->timer);
+		tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires=
, 0), HRTIMER_MODE_REL);
 		list_add(&x->km.all, &net->xfrm.state_all);
 		hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
 		h =3D xfrm_src_hash(net, daddr, saddr, family);
@@ -1299,8 +1303,8 @@ out:
 			memcpy(&x1->sel, &x->sel, sizeof(x1->sel));
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying =3D 0;
-
-		mod_timer(&x1->timer, jiffies + HZ);
+	=09
+		tasklet_hrtimer_start(&x1->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
=20
@@ -1325,7 +1329,7 @@ int xfrm_state_check_expire(struct xfrm_state *x)
 	if (x->curlft.bytes >=3D x->lft.hard_byte_limit ||
 	    x->curlft.packets >=3D x->lft.hard_packet_limit) {
 		x->km.state =3D XFRM_STATE_EXPIRED;
-		mod_timer(&x->timer, jiffies);
+		tasklet_hrtimer_start(&x->mtimer, ktime_set(0,0), HRTIMER_MODE_REL);
 		return -EINVAL;
 	}
=20

--Sig_/M2/legRKFtlEb50HQCJ8=Nq
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkr3eqEACgkQemuRe3zuqOQWJACgnA5XIg1Zexip8Kz3t0YSJeqY
K9IAnA/Nhc7omUXlQ9oB0QsmbGLb/EuF
=vLZW
-----END PGP SIGNATURE-----

--Sig_/M2/legRKFtlEb50HQCJ8=Nq--
