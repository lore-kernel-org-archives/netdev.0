From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: [PATCH 2/2] Runtime configuration of HTB's HYSTERESIS option
	(userspace)
Date: Thu, 15 Jun 2006 19:01:49 +1000
Message-ID: <1150362109.5578.16.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vtNHNXzfF3o/hXW62bV8"
Cc: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:42700 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1751341AbWFOJCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 05:02:41 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@osdl.org>,
	Martin Devera <devik@cdi.cz>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vtNHNXzfF3o/hXW62bV8
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

diff -Nurp iproute2.orig/include/linux/pkt_sched.h iproute2/include/linux/p=
kt_sched.h
--- iproute2.orig/include/linux/pkt_sched.h	2006-06-13 11:53:27.000000000 +=
1000
+++ iproute2/include/linux/pkt_sched.h	2006-06-13 11:54:50.000000000 +1000
@@ -232,6 +232,10 @@ struct tc_gred_sopt
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
@@ -259,6 +263,7 @@ enum
 	TCA_HTB_INIT,
 	TCA_HTB_CTAB,
 	TCA_HTB_RTAB,
+	TCA_HTB_NOHYST,
 	__TCA_HTB_MAX,
 };
=20
diff -Nurp iproute2.orig/tc/q_htb.c iproute2/tc/q_htb.c
--- iproute2.orig/tc/q_htb.c	2006-06-13 11:53:27.000000000 +1000
+++ iproute2/tc/q_htb.c	2006-06-13 11:54:50.000000000 +1000
@@ -35,7 +35,7 @@ static void explain(void)
 		" r2q      DRR quantums are computed as rate in Bps/r2q {10}\n"
 		" debug    string of 16 numbers each 0-3 {0}\n\n"
 		"... class add ... htb rate R1 [burst B1] [mpu B] [overhead O] [atm]\n"
-		"                      [prio P] [slot S] [pslot PS]\n"
+		"                      [prio P] [slot S] [pslot PS] [nohyst]\n"
 		"                      [ceil R2] [cburst B2] [mtu MTU] [quantum Q]\n"
 		" rate     rate allocated to this class (class can still borrow)\n"
 		" burst    max bytes burst which can be accumulated during idle period {=
computed}\n"
@@ -46,6 +46,7 @@ static void explain(void)
 		" cburst   burst but for ceil {computed}\n"
 		" mtu      max packet size we create rate map for {1600}\n"
 		" prio     priority of leaf; lower are served first {0}\n"
+		" nohyst   disable hysteresis (heavier on CPU but more accurate)\n"
 		" quantum  how much bytes to serve from leaf at once {use r2q}\n"
 		"\nTC HTB version %d.%d\n",HTB_TC_VER>>16,HTB_TC_VER&0xffff
 		);
@@ -104,6 +105,7 @@ static int htb_parse_class_opt(struct qd
 {
 	int ok=3D0;
 	struct tc_htb_opt opt;
+	struct tc_htb_hopt hopt;
 	__u32 rtab[256],ctab[256];
 	unsigned buffer=3D0,cbuffer=3D0;
 	int cell_log=3D-1,ccell_log =3D -1;
@@ -114,6 +116,7 @@ static int htb_parse_class_opt(struct qd
 	struct rtattr *tail;
=20
 	memset(&opt, 0, sizeof(opt)); mtu =3D 1600; /* eth packet len */
+	memset(&hopt, 0, sizeof(hopt));
=20
 	while (argc > 0) {
 		if (matches(*argv, "prio") =3D=3D 0) {
@@ -132,6 +135,8 @@ static int htb_parse_class_opt(struct qd
 			if (get_u8(&mpu8, *argv, 10)) {
 				explain1("mpu"); return -1;
 			}
+		} else if (matches(*argv, "nohyst") =3D=3D 0) {
+		  	hopt.nohyst =3D 1;
 		} else if (matches(*argv, "overhead") =3D=3D 0) {
 			NEXT_ARG();
 			if (get_s8(&overhead, *argv, 10)) {
@@ -221,14 +226,16 @@ static int htb_parse_class_opt(struct qd
 	addattr_l(n, 2024, TCA_HTB_PARMS, &opt, sizeof(opt));
 	addattr_l(n, 3024, TCA_HTB_RTAB, rtab, 1024);
 	addattr_l(n, 4024, TCA_HTB_CTAB, ctab, 1024);
+	addattr_l(n, 5024, TCA_HTB_NOHYST, &hopt, sizeof(hopt));
 	tail->rta_len =3D (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
=20
 static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *op=
t)
 {
-	struct rtattr *tb[TCA_HTB_RTAB+1];
+	struct rtattr *tb[TCA_HTB_MAX+1];
 	struct tc_htb_opt *hopt;
+	struct tc_htb_hopt *uhopt;
 	struct tc_htb_glob *gopt;
 	double buffer,cbuffer;
 	SPRINT_BUF(b1);
@@ -238,7 +245,7 @@ static int htb_print_opt(struct qdisc_ut
 	if (opt =3D=3D NULL)
 		return 0;
=20
-	parse_rtattr_nested(tb, TCA_HTB_RTAB, opt);
+	parse_rtattr_nested(tb, TCA_HTB_MAX, opt);
=20
 	if (tb[TCA_HTB_PARMS]) {
=20
@@ -278,6 +285,13 @@ static int htb_print_opt(struct qdisc_ut
 		fprintf(f, "buffer [%08x] cbuffer [%08x] ",=20
 			hopt->buffer,hopt->cbuffer);
 	}
+	if (tb[TCA_HTB_NOHYST]) {
+	    uhopt =3D RTA_DATA(tb[TCA_HTB_NOHYST]);
+	    if (RTA_PAYLOAD(tb[TCA_HTB_NOHYST]) < sizeof(*uhopt)) return -1;
+
+	    if (uhopt->nohyst)
+	        fprintf(f, "nohyst ");
+	}
 	if (tb[TCA_HTB_INIT]) {
 	    gopt =3D RTA_DATA(tb[TCA_HTB_INIT]);
 	    if (RTA_PAYLOAD(tb[TCA_HTB_INIT])  < sizeof(*gopt)) return -1;

--=-vtNHNXzfF3o/hXW62bV8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEkSH9jF9eJB0AJIYRAhLaAJ0UXdq+0T6ERMrKAXjddrGJE9CziACeKSbA
ojAYMEaV+ZpkVTjwqGVaKpk=
=/EGW
-----END PGP SIGNATURE-----

--=-vtNHNXzfF3o/hXW62bV8--

