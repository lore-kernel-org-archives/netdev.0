From: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>
Subject: [PATCH 2.4] Use double-linked list for dev->qdisc_list
Date: Wed, 4 Aug 2004 14:59:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804125926.GA15324@krezus.e-wro.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ftEhullJWpWg/VHq"
Cc: kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ftEhullJWpWg/VHq
Content-Type: multipart/mixed; boundary="KsGdsel6WgEHnImy"
Content-Disposition: inline


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


This patch changes dev->qdisc_list to a double-linked list. This solves
the performance problems when destroying qdiscs with large number of inner
qdiscs.

This is backported version of Patrick McHardy patch (03-qdisc_list-list_h.d=
iff)
for 2.6 kernels.

--=20
Tomasz Paszkowski

--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="03-qdisc_list-list_h_2.4.27-rc5.diff"
Content-Transfer-Encoding: quoted-printable

diff -Nru linux-2.4.27-rc5_van/include/linux/netdevice.h linux-2.4.27-rc5/i=
nclude/linux/netdevice.h
--- linux-2.4.27-rc5_van/include/linux/netdevice.h	2004-08-04 16:37:39.0000=
00000 +0200
+++ linux-2.4.27-rc5/include/linux/netdevice.h	2004-08-04 16:22:08.00000000=
0 +0200
@@ -352,8 +352,8 @@
=20
 	struct Qdisc		*qdisc;
 	struct Qdisc		*qdisc_sleeping;
-	struct Qdisc		*qdisc_list;
 	struct Qdisc		*qdisc_ingress;
+	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
=20
 	/* hard_start_xmit synchronizer */
diff -Nru linux-2.4.27-rc5_van/include/net/pkt_sched.h linux-2.4.27-rc5/inc=
lude/net/pkt_sched.h
--- linux-2.4.27-rc5_van/include/net/pkt_sched.h	2004-02-18 14:36:32.000000=
000 +0100
+++ linux-2.4.27-rc5/include/net/pkt_sched.h	2004-08-04 16:22:08.000000000 =
+0200
@@ -80,11 +80,11 @@
 #define TCQ_F_THROTTLED	2
 #define TCQ_F_INGRES	4
 	struct Qdisc_ops	*ops;
-	struct Qdisc		*next;
 	u32			handle;
 	atomic_t		refcnt;
 	struct sk_buff_head	q;
 	struct net_device	*dev;
+	struct list_head	list;
=20
 	struct tc_stats		stats;
 	int			(*reshape_fail)(struct sk_buff *skb, struct Qdisc *q);
diff -Nru linux-2.4.27-rc5_van/net/sched/sch_api.c linux-2.4.27-rc5/net/sch=
ed/sch_api.c
--- linux-2.4.27-rc5_van/net/sched/sch_api.c	2002-11-29 00:53:16.000000000 =
+0100
+++ linux-2.4.27-rc5/net/sched/sch_api.c	2004-08-04 16:26:55.000000000 +0200
@@ -32,6 +32,7 @@
 #include <linux/init.h>
 #include <linux/proc_fs.h>
 #include <linux/kmod.h>
+#include <linux/list.h>
=20
 #include <net/sock.h>
 #include <net/pkt_sched.h>
@@ -193,7 +194,7 @@
 {
 	struct Qdisc *q;
=20
-	for (q =3D dev->qdisc_list; q; q =3D q->next) {
+	list_for_each_entry(q, &dev->qdisc_list, list) {
 		if (q->handle =3D=3D handle)
 			return q;
 	}
@@ -424,6 +425,7 @@
=20
 	memset(sch, 0, size);
=20
+	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
=20
 	if (handle =3D=3D TC_H_INGRESS)
@@ -449,8 +451,7 @@
=20
 	if (!ops->init || (err =3D ops->init(sch, tca[TCA_OPTIONS-1])) =3D=3D 0) {
 		write_lock(&qdisc_tree_lock);
-		sch->next =3D dev->qdisc_list;
-		dev->qdisc_list =3D sch;
+		list_add_tail(&sch->list, &dev->qdisc_list);
 		write_unlock(&qdisc_tree_lock);
 #ifdef CONFIG_NET_ESTIMATOR
 		if (tca[TCA_RATE-1])
@@ -805,9 +806,9 @@
 		if (idx > s_idx)
 			s_q_idx =3D 0;
 		read_lock(&qdisc_tree_lock);
-		for (q =3D dev->qdisc_list, q_idx =3D 0; q;
-		     q =3D q->next, q_idx++) {
-			if (q_idx < s_q_idx)
+		q_idx =3D 0;
+		list_for_each_entry(q, &dev->qdisc_list, list) {
+			if (q_idx++ < s_q_idx)
 				continue;
 			if (tc_fill_qdisc(skb, q, 0, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <=3D 0) {
@@ -822,7 +823,7 @@
 	read_unlock(&dev_base_lock);
=20
 	cb->args[0] =3D idx;
-	cb->args[1] =3D q_idx;
+	cb->args[1] =3D q_idx - 1;
=20
 	return skb->len;
 }
@@ -1024,13 +1025,16 @@
 		return 0;
=20
 	s_t =3D cb->args[0];
+	t =3D 0;
=20
 	read_lock(&qdisc_tree_lock);
-	for (q=3Ddev->qdisc_list, t=3D0; q; q =3D q->next, t++) {
-		if (t < s_t) continue;
-		if (!q->ops->cl_ops) continue;
-		if (tcm->tcm_parent && TC_H_MAJ(tcm->tcm_parent) !=3D q->handle)
+	list_for_each_entry(q, &dev->qdisc_list, list) {
+		if (t < s_t || !q->ops->cl_ops ||
+		    (tcm->tcm_parent &&
+		     TC_H_MAJ(tcm->tcm_parent) !=3D q->handle)) {
+			t++;
 			continue;
+		}
 		if (t > s_t)
 			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
 		arg.w.fn =3D qdisc_class_dump;
@@ -1043,6 +1047,7 @@
 		cb->args[1] =3D arg.w.count;
 		if (arg.w.stop)
 			break;
+		t++;
 	}
 	read_unlock(&qdisc_tree_lock);
=20
diff -Nru linux-2.4.27-rc5_van/net/sched/sch_generic.c linux-2.4.27-rc5/net=
/sched/sch_generic.c
--- linux-2.4.27-rc5_van/net/sched/sch_generic.c	2004-02-18 14:36:32.000000=
000 +0100
+++ linux-2.4.27-rc5/net/sched/sch_generic.c	2004-08-04 16:30:16.000000000 =
+0200
@@ -29,6 +29,7 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
+#include <linux/list.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
=20
@@ -391,6 +392,7 @@
 		return NULL;
 	memset(sch, 0, size);
=20
+	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 	sch->ops =3D ops;
 	sch->enqueue =3D ops->enqueue;
@@ -420,22 +422,10 @@
 void qdisc_destroy(struct Qdisc *qdisc)
 {
 	struct Qdisc_ops *ops =3D qdisc->ops;
-	struct net_device *dev;
=20
 	if (!atomic_dec_and_test(&qdisc->refcnt))
 		return;
-
-	dev =3D qdisc->dev;
-
-	if (dev) {
-		struct Qdisc *q, **qp;
-		for (qp =3D &qdisc->dev->qdisc_list; (q=3D*qp) !=3D NULL; qp =3D &q->nex=
t) {
-			if (q =3D=3D qdisc) {
-				*qp =3D q->next;
-				break;
-			}
-		}
-	}
+	list_del(&qdisc->list);
 #ifdef CONFIG_NET_ESTIMATOR
 	qdisc_kill_estimator(&qdisc->stats);
 #endif
@@ -464,10 +454,8 @@
 				printk(KERN_INFO "%s: activation failed\n", dev->name);
 				return;
 			}
-
 			write_lock(&qdisc_tree_lock);
-			qdisc->next =3D dev->qdisc_list;
-			dev->qdisc_list =3D qdisc;
+			list_add_tail(&qdisc->list, &dev->qdisc_list);
 			write_unlock(&qdisc_tree_lock);
=20
 		} else {
@@ -513,7 +501,7 @@
 	dev->qdisc =3D &noop_qdisc;
 	spin_unlock_bh(&dev->queue_lock);
 	dev->qdisc_sleeping =3D &noop_qdisc;
-	dev->qdisc_list =3D NULL;
+	INIT_LIST_HEAD(&dev->qdisc_list);
 	write_unlock(&qdisc_tree_lock);
=20
 	dev_watchdog_init(dev);
@@ -535,9 +523,7 @@
 		qdisc_destroy(qdisc);
         }
 #endif
-	BUG_TRAP(dev->qdisc_list =3D=3D NULL);
 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
-	dev->qdisc_list =3D NULL;
 	spin_unlock_bh(&dev->queue_lock);
 	write_unlock(&qdisc_tree_lock);
 }

--KsGdsel6WgEHnImy--

--ftEhullJWpWg/VHq
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBEN2tcNXOL98XeysRAh8RAJwNnKyt6wC/GhimrDWBDlPSnJzBvACfQ4Uk
c2lzDxLg6/T9Ecx61r4SSWo=
=JCaa
-----END PGP SIGNATURE-----

--ftEhullJWpWg/VHq--
