From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: [PATCH 1/2] Runtime configuration of HTB's HYSTERESIS option
	(kernel)
Date: Thu, 15 Jun 2006 19:01:28 +1000
Message-ID: <1150362088.5578.15.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-C3mnM58ghUdzK26iDV75"
Cc: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:40908 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1751336AbWFOJCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 05:02:20 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@osdl.org>,
	Martin Devera <devik@cdi.cz>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-C3mnM58ghUdzK26iDV75
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

The HTB qdisc has a compile time option, HTB_HYSTERESIS,=20
that trades accuracy of traffic classification for CPU=20
time.  These patches change hysteresis to be a runtime=20
option under the control of "tc".

The effects of HYSTERESIS on HTB's accuracy are significant=20
(see chapter 7, section 7.3.1, pp 69-70 in Jesper Brouer's
thesis: http://www.adsl-optimizer.dk/thesis/ ), whereas=20
HTB's CPU usage on modern machines using broadband links=20
is minimal.  Currently HYSTERESIS is on by default, and=20
requires a kernel re-compile to change.  Altering it to=20
be a runtime option will make life easier for the bulk of=20
its users.

Further documentation on the patch and its usage can be
found here:
  http://www.stuart.id.au/russell/files/tc/tc-atm

Signed-off-by: Russell Stuart <russell-tcatm@stuart.id.au>
Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

diff -Nurp kernel-source-2.6.11.orig/include/linux/pkt_sched.h kernel-sourc=
e-2.6.11/include/linux/pkt_sched.h
--- kernel-source-2.6.11.orig/include/linux/pkt_sched.h	2005-03-02 17:38:13=
.000000000 +1000
+++ kernel-source-2.6.11/include/linux/pkt_sched.h	2006-06-13 11:34:25.0000=
00000 +1000
@@ -231,6 +231,10 @@ struct tc_gred_sopt
 #define TC_HTB_MAXDEPTH		8
 #define TC_HTB_PROTOVER		3 /* the same as HTB and TC's major */
=20
+struct tc_htb_hopt
+{
+	__u32	nohyst;
+};
 struct tc_htb_opt
 {
 	struct tc_ratespec 	rate;
@@ -258,6 +262,7 @@ enum
 	TCA_HTB_INIT,
 	TCA_HTB_CTAB,
 	TCA_HTB_RTAB,
+	TCA_HTB_NOHYST,
 	__TCA_HTB_MAX,
 };
=20
diff -Nurp kernel-source-2.6.11.orig/net/sched/sch_htb.c kernel-source-2.6.=
11/net/sched/sch_htb.c
--- kernel-source-2.6.11.orig/net/sched/sch_htb.c	2005-03-02 17:38:12.00000=
0000 +1000
+++ kernel-source-2.6.11/net/sched/sch_htb.c	2006-06-13 11:34:25.000000000 =
+1000
@@ -73,7 +73,6 @@
 #define HTB_EWMAC 2	/* rate average over HTB_EWMAC*HTB_HSIZE sec */
 #undef HTB_DEBUG	/* compile debugging support (activated by tc tool) */
 #define HTB_RATECM 1    /* whether to use rate computer */
-#define HTB_HYSTERESIS 1/* whether to use mode hysteresis for speedup */
 #define HTB_QLOCK(S) spin_lock_bh(&(S)->dev->queue_lock)
 #define HTB_QUNLOCK(S) spin_unlock_bh(&(S)->dev->queue_lock)
 #define HTB_VER 0x30011	/* major must be matched with number suplied by TC=
 as version */
@@ -190,6 +189,7 @@ struct htb_class
     /* class attached filters */
     struct tcf_proto *filter_list;
     int filter_cnt;
+    int nohyst;		/* Don't use hysteresis htb_class_mode */
=20
     int warned;		/* only one warning about non work conserving .. */
=20
@@ -622,20 +622,14 @@ static __inline__ enum htb_cmode=20
 htb_class_mode(struct htb_class *cl,long *diff)
 {
     long toks;
+    long hysteresis =3D
+	    (cl->nohyst || cl->cmode =3D=3D HTB_CANT_SEND) ? 0 : -cl->cbuffer;
=20
-    if ((toks =3D (cl->ctokens + *diff)) < (
-#if HTB_HYSTERESIS
-	    cl->cmode !=3D HTB_CANT_SEND ? -cl->cbuffer :
-#endif
-       	    0)) {
+    if ((toks =3D (cl->ctokens + *diff)) < hysteresis) {
 	    *diff =3D -toks;
 	    return HTB_CANT_SEND;
     }
-    if ((toks =3D (cl->tokens + *diff)) >=3D (
-#if HTB_HYSTERESIS
-	    cl->cmode =3D=3D HTB_CAN_SEND ? -cl->buffer :
-#endif
-	    0))
+    if ((toks =3D (cl->tokens + *diff)) >=3D hysteresis)
 	    return HTB_CAN_SEND;
=20
     *diff =3D -toks;
@@ -1323,6 +1317,7 @@ static int htb_dump_class(struct Qdisc *
 	unsigned char	 *b =3D skb->tail;
 	struct rtattr *rta;
 	struct tc_htb_opt opt;
+	struct tc_htb_hopt hopt;
=20
 	HTB_DBG(0,1,"htb_dump_class handle=3D%X clid=3D%X\n",sch->handle,cl->clas=
sid);
=20
@@ -1342,6 +1337,8 @@ static int htb_dump_class(struct Qdisc *
 	opt.quantum =3D cl->un.leaf.quantum; opt.prio =3D cl->un.leaf.prio;
 	opt.level =3D cl->level;=20
 	RTA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
+	hopt.nohyst =3D cl->nohyst;
+	RTA_PUT(skb, TCA_HTB_NOHYST, sizeof(hopt), &hopt);
 	rta->rta_len =3D skb->tail - b;
 	HTB_QUNLOCK(sch);
 	return skb->len;
@@ -1527,11 +1524,12 @@ static int htb_change_class(struct Qdisc
 	struct htb_class *cl =3D (struct htb_class*)*arg,*parent;
 	struct rtattr *opt =3D tca[TCA_OPTIONS-1];
 	struct qdisc_rate_table *rtab =3D NULL, *ctab =3D NULL;
-	struct rtattr *tb[TCA_HTB_RTAB];
+	struct rtattr *tb[TCA_HTB_MAX];
 	struct tc_htb_opt *hopt;
+	struct tc_htb_hopt *uhopt;
=20
 	/* extract all subattrs from opt attr */
-	if (!opt || rtattr_parse_nested(tb, TCA_HTB_RTAB, opt) ||
+	if (!opt || rtattr_parse_nested(tb, TCA_HTB_MAX, opt) ||
 			tb[TCA_HTB_PARMS-1] =3D=3D NULL ||
 			RTA_PAYLOAD(tb[TCA_HTB_PARMS-1]) < sizeof(*hopt))
 		goto failure;
@@ -1544,6 +1542,10 @@ static int htb_change_class(struct Qdisc
 	ctab =3D qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB-1]);
 	if (!rtab || !ctab) goto failure;
=20
+	uhopt =3D RTA_DATA(tb[TCA_HTB_NOHYST-1]);
+	if (uhopt !=3D NULL && RTA_PAYLOAD(tb[TCA_HTB_NOHYST-1]) < sizeof(*uhopt)=
)
+		goto failure;
+
 	if (!cl) { /* new class */
 		struct Qdisc *new_q;
 		/* check for valid classid */
@@ -1636,6 +1638,7 @@ static int htb_change_class(struct Qdisc
 	cl->cbuffer =3D hopt->cbuffer;
 	if (cl->rate) qdisc_put_rtab(cl->rate); cl->rate =3D rtab;
 	if (cl->ceil) qdisc_put_rtab(cl->ceil); cl->ceil =3D ctab;
+	if (uhopt) cl->nohyst =3D uhopt->nohyst;
 	sch_tree_unlock(sch);
=20
 	*arg =3D (unsigned long)cl;




--=-C3mnM58ghUdzK26iDV75
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEkSHojF9eJB0AJIYRAj8jAJwLaYTAhvTetmZaQZOX6v9M7dWINQCcCZmF
Y5nYcJDE7YPAsQSg+iF1afw=
=yGbB
-----END PGP SIGNATURE-----

--=-C3mnM58ghUdzK26iDV75--

