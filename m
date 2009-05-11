From: Yury Polyanskiy <ypolyans@Princeton.EDU>
Subject: [PATCH] xfrm: SAD entries do not expire after suspend-resume
Date: Mon, 11 May 2009 14:21:01 -0400
Message-ID: <20090511142101.639cb5d6@penta.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ItyCSKV2V=N4q9zczbFl116"; protocol="application/pgp-signature"
To: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, peterz@infradead.org, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from postoffice03.Princeton.EDU ([128.112.131.174]:47790 "EHLO
	Princeton.EDU" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755119AbZEKSak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 14:30:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/ItyCSKV2V=N4q9zczbFl116
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

  This fixes the following bug in the current implementation of
net/xfrm: if SAD entry expires in 8 hr and the kernel is put into
suspend for 10hr then upon wakeup SAD will not expire until 8 more
hours pass. This, of course, leads to connectivity problems because
the corresponding entry has already expired on the remote end.

  The patch is against 2.6.26.8 (applies to 2.6.26 cleanly) for two
reasons:=20

(1) that is what I am testing it on;=20

(2) it can not be ported to anything post 2.6.28-rc7 because hrtimer's
callbacks are run in hardirq context ever since. This would require a
major rewrite of xfrm_state's locking (i.e. replacing spin_lock_bh()
with spin_lock_irqsave() at least) which is (a) outside of my competence
and (b) will introduce excessive irq-disabled codepaths.

  Due to (2) I am copying the authors of the hrtimer's patch. Unless
there is an alternative (to hrtimer_start) way of requesting a
CLOCK_REALTIME softirq callback the only solution I could think of is
to hook into PM_POST_HIBERNATION+PM_POST_SUSPEND and force all of the
timers on xfrm_state_all list to go off after resume.

  I hope this is still useful for some.

Best,
Yury Polyanskiy.

--
 include/net/xfrm.h    |    2 +-
 net/xfrm/xfrm_state.c |   43
  ++++++++++++++++++++++++++++++------------- 2 files changed, 31
  insertions(+), 14 deletions(-)

diff -urpd linux-2.6.26.8/include/net/xfrm.h linux-2.6.26.8up1/include/net/=
xfrm.h
--- linux-2.6.26.8/include/net/xfrm.h	2008-08-20 14:11:37.000000000 -0400
+++ linux-2.6.26.8up1/include/net/xfrm.h	2009-05-10 21:24:12.000000000 -0400
@@ -196,7 +196,7 @@ struct xfrm_state
 	struct xfrm_stats	stats;
=20
 	struct xfrm_lifetime_cur curlft;
-	struct timer_list	timer;
+	struct hrtimer	mtimer;
=20
 	/* Last used time */
 	unsigned long		lastused;
diff -urpd linux-2.6.26.8/net/xfrm/xfrm_state.c linux-2.6.26.8up1/net/xfrm/=
xfrm_state.c
--- linux-2.6.26.8/net/xfrm/xfrm_state.c	2009-05-10 22:40:51.000000000 -0400
+++ linux-2.6.26.8up1/net/xfrm/xfrm_state.c	2009-05-11 01:28:56.000000000 -=
0400
@@ -21,6 +21,9 @@
 #include <linux/cache.h>
 #include <linux/audit.h>
 #include <asm/uaccess.h>
+#include <linux/ktime.h>
+#include <linux/hrtimer.h>
+#include <linux/kernel.h>
=20
 #include "xfrm_hash.h"
=20
@@ -380,7 +383,7 @@ static void xfrm_put_mode(struct xfrm_mo
=20
 static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
-	del_timer_sync(&x->timer);
+	hrtimer_cancel(&x->mtimer);
 	del_timer_sync(&x->rtimer);
 	kfree(x->aalg);
 	kfree(x->ealg);
@@ -426,9 +429,9 @@ static inline unsigned long make_jiffies
 		return secs*HZ;
 }
=20
-static void xfrm_timer_handler(unsigned long data)
+static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 {
-	struct xfrm_state *x =3D (struct xfrm_state*)data;
+	struct xfrm_state *x =3D container_of(me, struct xfrm_state, mtimer);
 	unsigned long now =3D get_seconds();
 	long next =3D LONG_MAX;
 	int warn =3D 0;
@@ -478,8 +481,16 @@ static void xfrm_timer_handler(unsigned=20
 	if (warn)
 		km_state_expired(x, 0, 0);
 resched:
-	if (next !=3D LONG_MAX)
-		mod_timer(&x->timer, jiffies + make_jiffies(next));
+	if (next !=3D LONG_MAX){
+		/* Note: here we could use a less expensive:
+		 *
+		 * hrtimer_start(&x->mtimer, ktime_set(now + next, 0), HRTIMER_MODE_ABS);
+		 *
+		 * but this would depend on ktime_get_real() and get_seconds() using=20
+		 * the same clock source and might break (?) in the future.
+		 */
+		hrtimer_start(&x->mtimer, ktime_set(next, 0), HRTIMER_MODE_REL);
+	}
=20
 	goto out;
=20
@@ -501,6 +512,7 @@ expired:
=20
 out:
 	spin_unlock(&x->lock);
+	return HRTIMER_NORESTART;
 }
=20
 static void xfrm_replay_timer_handler(unsigned long data);
@@ -518,7 +530,9 @@ struct xfrm_state *xfrm_state_alloc(void
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
-		setup_timer(&x->timer, xfrm_timer_handler, (unsigned long)x);
+		hrtimer_init(&x->mtimer, CLOCK_REALTIME, HRTIMER_MODE_ABS);
+		x->mtimer.function =3D xfrm_timer_handler;
+		x->mtimer.cb_mode =3D HRTIMER_CB_SOFTIRQ;
 		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
 				(unsigned long)x);
 		x->curlft.add_time =3D get_seconds();
@@ -866,8 +880,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 				hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 			}
 			x->lft.hard_add_expires_seconds =3D sysctl_xfrm_acq_expires;
-			x->timer.expires =3D jiffies + sysctl_xfrm_acq_expires*HZ;
-			add_timer(&x->timer);
+			hrtimer_start(&x->mtimer, ktime_set(sysctl_xfrm_acq_expires, 0), HRTIME=
R_MODE_REL);
 			xfrm_state_num++;
 			xfrm_hash_grow_check(x->bydst.next !=3D NULL);
 		} else {
@@ -942,7 +955,7 @@ static void __xfrm_state_insert(struct x
 		hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 	}
=20
-	mod_timer(&x->timer, jiffies + HZ);
+	hrtimer_start(&x->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
 	if (x->replay_maxage)
 		mod_timer(&x->rtimer, jiffies + x->replay_maxage);
=20
@@ -1053,8 +1066,7 @@ static struct xfrm_state *__find_acq_cor
 		x->props.reqid =3D reqid;
 		x->lft.hard_add_expires_seconds =3D sysctl_xfrm_acq_expires;
 		xfrm_state_hold(x);
-		x->timer.expires =3D jiffies + sysctl_xfrm_acq_expires*HZ;
-		add_timer(&x->timer);
+		hrtimer_start(&x->mtimer, ktime_set(sysctl_xfrm_acq_expires, 0), HRTIMER=
_MODE_REL);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h =3D xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -1330,8 +1342,8 @@ out:
 			memcpy(&x1->sel, &x->sel, sizeof(x1->sel));
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying =3D 0;
-
-		mod_timer(&x1->timer, jiffies + HZ);
+	=09
+		hrtimer_start(&x1->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
=20
@@ -1356,7 +1368,10 @@ int xfrm_state_check_expire(struct xfrm_
 	if (x->curlft.bytes >=3D x->lft.hard_byte_limit ||
 	    x->curlft.packets >=3D x->lft.hard_packet_limit) {
 		x->km.state =3D XFRM_STATE_EXPIRED;
-		mod_timer(&x->timer, jiffies);
+		/* TODO: analyze if dropping x->lock is possible,
+		 * 	in which case we might do hrtimer_cancel(); x->mtimer.function();
+		 */
+		hrtimer_start(&x->mtimer, ktime_set(0,0), HRTIMER_MODE_REL);
 		return -EINVAL;
 	}
=20

--Sig_/ItyCSKV2V=N4q9zczbFl116
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoIbI0ACgkQemuRe3zuqOR1RACeJFoPKr0JstFlMg5WlI5zLwd7
h34AoKPM9Gw48vuiBeBGOMKKS5jzuTkU
=xciR
-----END PGP SIGNATURE-----

--Sig_/ItyCSKV2V=N4q9zczbFl116--
