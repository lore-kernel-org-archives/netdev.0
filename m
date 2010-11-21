From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] pktgen: allow faster module unload
Date: Sun, 21 Nov 2010 19:11:31 +0100
Message-ID: <1290363091.2756.136.camel@edumazet-laptop>
References: <1290359251.2756.134.camel@edumazet-laptop>
	 <20101121.095636.71126038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57703 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755030Ab0KUSLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 13:11:37 -0500
Received: by wyb28 with SMTP id 28so6238568wyb.19
        for <netdev@vger.kernel.org>; Sun, 21 Nov 2010 10:11:36 -0800 (PST)
In-Reply-To: <20101121.095636.71126038.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 21 novembre 2010 =C3=A0 09:56 -0800, David Miller a =C3=A9c=
rit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 21 Nov 2010 18:07:31 +0100
>=20
> > @@ -395,6 +395,8 @@ struct pktgen_hdr {
> >  	__be32 tv_usec;
> >  };
> > =20
> > +bool pktgen_exiting __read_mostly;
> > +
> >  struct pktgen_thread {
> >  	spinlock_t if_lock;		/* for list of devices */
> >  	struct list_head if_list;	/* All device here */
>=20
> Maybe this should be static?

Indeed, thanks !

[PATCH net-next-2.6 v2] pktgen: allow faster module unload

Unloading pktgen module needs ~6 seconds on a 64 cpus machine, to stop
64 kthreads.

Add a pktgen_exiting variable to let kernel threads die faster, so that
kthread_stop() doesnt have to wait too long for them. This variable is
not tested in fast path.

Note : Before exiting from pktgen_thread_worker(), we must make sure
kthread_stop() is waiting for this thread to be stopped, like its done
in kernel/softirq.c

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 52fc1e0..f6f3d5d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -395,6 +395,8 @@ struct pktgen_hdr {
 	__be32 tv_usec;
 };
=20
+static bool pktgen_exiting __read_mostly;
+
 struct pktgen_thread {
 	spinlock_t if_lock;		/* for list of devices */
 	struct list_head if_list;	/* All device here */
@@ -3451,11 +3453,6 @@ static void pktgen_rem_thread(struct pktgen_thre=
ad *t)
=20
 	remove_proc_entry(t->tsk->comm, pg_proc_dir);
=20
-	mutex_lock(&pktgen_thread_lock);
-
-	list_del(&t->th_list);
-
-	mutex_unlock(&pktgen_thread_lock);
 }
=20
 static void pktgen_resched(struct pktgen_dev *pkt_dev)
@@ -3602,6 +3599,8 @@ static int pktgen_thread_worker(void *arg)
 		pkt_dev =3D next_to_run(t);
=20
 		if (unlikely(!pkt_dev && t->control =3D=3D 0)) {
+			if (pktgen_exiting)
+				break;
 			wait_event_interruptible_timeout(t->queue,
 							 t->control !=3D 0,
 							 HZ/10);
@@ -3654,6 +3653,13 @@ static int pktgen_thread_worker(void *arg)
 	pr_debug("%s removing thread\n", t->tsk->comm);
 	pktgen_rem_thread(t);
=20
+	/* Wait for kthread_stop */
+	while (!kthread_should_stop()) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule();
+	}
+	__set_current_state(TASK_RUNNING);
+
 	return 0;
 }
=20
@@ -3928,6 +3934,7 @@ static void __exit pg_cleanup(void)
 	struct list_head *q, *n;
=20
 	/* Stop all interfaces & threads */
+	pktgen_exiting =3D true;
=20
 	list_for_each_safe(q, n, &pktgen_threads) {
 		t =3D list_entry(q, struct pktgen_thread, th_list);


