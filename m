From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH RFC] net_sched: add generic qdisc size table
Date: Thu, 17 Jul 2008 03:32:31 +0300
Message-ID: <20080717033231.17025djszmn2khds@hayate.ip6>
References: <20080710193434.19525.83454.stgit@fate.lan>
	<20080710193440.19525.93085.stgit@fate.lan> <487B61A9.5090204@trash.net>
	<20080715135244.17106mgc64fxlpj4@hayate.ip6> <487C821D.1010806@trash.net>
	<20080717024055.18323q4r4ll8sf0g@hayate.ip6>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=_4kdbyiudgkxs"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:60671 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759916AbYGQAcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 20:32:33 -0400
In-Reply-To: <20080717024055.18323q4r4ll8sf0g@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message is in MIME format.

--=_4kdbyiudgkxs
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Quoting "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>:

>
> Here's first version of generic size table feature. Didn't get chance
> to test too much yet but hfsc&sfq seems to be ok.
>
>  - Jussi
>

Resending iproute2/tc patch, as it was missing one file.

  - Jussi



--=_4kdbyiudgkxs
Content-Type: text/x-patch;
	charset=UTF-8;
	name="01-iproute-add-size-table.diff"
Content-Disposition: attachment;
	filename="01-iproute-add-size-table.diff"
Content-Transfer-Encoding: quoted-printable

[iproute2/tc] tc_core: add size table

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Patch adds generic size table that is similiar to rate table, with=20
difference that size table stores link layer packet size.=20

Based on patch by Patrick McHardy
 http://marc.info/?l=3Dlinux-netdev&m=3D115201979221729&w=3D2

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |   21 ++++++
 include/linux/rtnetlink.h |    1=20
 tc/Makefile               |    1=20
 tc/tc_class.c             |    1=20
 tc/tc_common.h            |    5 ++
 tc/tc_core.c              |   64 +++++++++++++++----
 tc/tc_core.h              |    6 +-
 tc/tc_qdisc.c             |   32 ++++++++++
 tc/tc_stab.c              |  149 ++++++++++++++++++++++++++++++++++++++++++=
+++
 tc/tc_util.c              |   26 ++++++++
 tc/tc_util.h              |    2 +
 11 files changed, 290 insertions(+), 18 deletions(-)
 create mode 100644 tc/tc_stab.c


diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..eae53bf 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -85,6 +85,27 @@ struct tc_ratespec
=20
 #define TC_RTAB_SIZE=091024
=20
+struct tc_sizespec {
+=09unsigned char=09cell_log;
+=09unsigned char=09size_log;
+=09short=09=09cell_align;
+=09int=09=09overhead;
+=09unsigned=09linklayer;
+=09unsigned=09mpu;
+=09unsigned=09mtu;
+};
+
+#define TC_STAB_DATA_SIZE 1024
+
+enum {
+=09TCA_STAB_UNSPEC,
+=09TCA_STAB_BASE,
+=09TCA_STAB_DATA,
+=09__TCA_STAB_MAX
+};
+
+#define TCA_STAB_MAX (__TCA_STAB_MAX - 1)
+
 /* FIFO section */
=20
 struct tc_fifo_qopt
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index c1f2d50..a125692 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -482,6 +482,7 @@ enum
 =09TCA_RATE,
 =09TCA_FCNT,
 =09TCA_STATS2,
+=09TCA_STAB,
 =09__TCA_MAX
 };
=20
diff --git a/tc/Makefile b/tc/Makefile
index bf2df00..a5ac841 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -45,6 +45,7 @@ TCLIB :=3D tc_core.o
 TCLIB +=3D tc_red.o
 TCLIB +=3D tc_cbq.o
 TCLIB +=3D tc_estimator.o
+TCLIB +=3D tc_stab.o
=20
 CFLAGS +=3D -DCONFIG_GACT -DCONFIG_GACT_PROB
=20
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 774497a..6cf19d4 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -31,6 +31,7 @@ static void usage(void)
 {
 =09fprintf(stderr, "Usage: tc class [ add | del | change | replace | show ]=
 dev STRING\n");
 =09fprintf(stderr, "       [ classid CLASSID ] [ root | parent CLASSID ]\n"=
);
+=09fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
 =09fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
 =09fprintf(stderr, "\n");
 =09fprintf(stderr, "       tc class show [ dev STRING ] [ root | parent CLA=
SSID ]\n");
diff --git a/tc/tc_common.h b/tc/tc_common.h
index e01b037..4f88856 100644
--- a/tc/tc_common.h
+++ b/tc/tc_common.h
@@ -11,6 +11,11 @@ extern int print_action(const struct sockaddr_nl *who, st=
ruct nlmsghdr *n, void
 extern int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, =
void *arg);
 extern int print_qdisc(const struct sockaddr_nl *who, struct nlmsghdr *n, v=
oid *arg);
 extern int print_class(const struct sockaddr_nl *who, struct nlmsghdr *n, v=
oid *arg);
+extern void print_size_table(FILE *fp, const char *prefix, struct rtattr *r=
ta);
=20
 struct tc_estimator;
 extern int parse_estimator(int *p_argc, char ***p_argv, struct tc_estimator=
 *est);
+
+struct tc_sizespec;
+extern int parse_size_table(int *p_argc, char ***p_argv, struct tc_sizespec=
 *s);
+extern int check_size_table_opts(struct tc_sizespec *s);
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 855c115..dd7885c 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -87,6 +87,21 @@ unsigned tc_align_to_atm(unsigned size)
 =09return linksize;
 }
=20
+unsigned tc_adjust_size(unsigned sz, unsigned mpu, enum link_layer linklaye=
r)
+{
+=09if (sz < mpu)
+=09=09sz =3D mpu;
+
+=09switch (linklayer) {
+=09case LINKLAYER_ATM:
+=09=09return tc_align_to_atm(sz);
+=09case LINKLAYER_ETHERNET:
+=09default:
+=09=09// No size adjustments on Ethernet
+=09=09return sz;
+=09}
+}
+
 /*
    rtab[pkt_len>>cell_log] =3D pkt_xmit_time
  */
@@ -96,6 +111,7 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 =09=09   enum link_layer linklayer)
 {
 =09int i;
+=09unsigned sz;
 =09unsigned bps =3D r->rate;
 =09unsigned mpu =3D r->mpu;
=20
@@ -109,21 +125,7 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 =09}
=20
 =09for (i=3D0; i<256; i++) {
-=09=09unsigned sz =3D (i+1)<<cell_log;
-=09=09if (sz < mpu)
-=09=09=09sz =3D mpu;
-
-=09=09switch (linklayer) {
-=09=09case LINKLAYER_ATM:
-=09=09=09sz =3D tc_align_to_atm(sz);
-=09=09=09break;
-=09=09case LINKLAYER_ETHERNET:
-=09=09=09// No size adjustments on Ethernet
-=09=09=09break;
-=09=09default:
-=09=09=09break;
-=09=09}
-
+=09=09sz =3D tc_adjust_size((i + 1) << cell_log, mpu, linklayer);
 =09=09rtab[i] =3D tc_calc_xmittime(bps, sz);
 =09}
=20
@@ -132,6 +134,38 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 =09return cell_log;
 }
=20
+/*
+   stab[pkt_len>>cell_log] =3D pkt_xmit_size>>size_log
+ */
+
+int tc_calc_size_table(struct tc_sizespec *s, __u16 *stab)
+{
+=09int i;
+=09enum link_layer linklayer =3D s->linklayer;
+=09unsigned mtu =3D s->mtu;
+=09unsigned sz;
+
+=09if (mtu =3D=3D 0)
+=09=09mtu =3D 2047;
+
+=09s->cell_log =3D 0;
+=09while ((mtu >> s->cell_log) > 512 - 1)
+=09=09s->cell_log++;
+
+again:
+=09for (i =3D 512 - 1; i >=3D 0; i--) {
+=09=09sz =3D tc_adjust_size((i + 1) << s->cell_log, s->mpu, linklayer);
+=09=09if ((sz >> s->size_log) > UINT16_MAX) {
+=09=09=09s->size_log++;
+=09=09=09goto again;
+=09=09}
+=09=09stab[i] =3D sz >> s->size_log;
+=09}
+
+=09s->cell_align =3D -1; // Due to the sz calc
+=09return s->cell_log;
+}
+
 int tc_core_init()
 {
 =09FILE *fp;
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 9f835e8..b82d2b8 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -7,8 +7,9 @@
 #define TIME_UNITS_PER_SEC=091000000
=20
 enum link_layer {
-=09LINKLAYER_ETHERNET=3D1,
-=09LINKLAYER_ATM     =3D2,
+=09LINKLAYER_UNSPEC,
+=09LINKLAYER_ETHERNET,
+=09LINKLAYER_ATM,
 };
=20
=20
@@ -21,6 +22,7 @@ unsigned tc_calc_xmittime(unsigned rate, unsigned size);
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
 int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 =09=09   int cell_log, unsigned mtu, enum link_layer link_layer);
+int tc_calc_size_table(struct tc_sizespec *s, __u16 *stab);
=20
 int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator=
 *est);
=20
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 1256f07..60388a4 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -32,12 +32,14 @@ static int usage(void)
 =09fprintf(stderr, "Usage: tc qdisc [ add | del | replace | change | show ]=
 dev STRING\n");
 =09fprintf(stderr, "       [ handle QHANDLE ] [ root | ingress | parent CLA=
SSID ]\n");
 =09fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
+=09fprintf(stderr, "       [ stab [ help | STAB_OPTIONS] ]\n");
 =09fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
 =09fprintf(stderr, "\n");
 =09fprintf(stderr, "       tc qdisc show [ dev STRING ] [ingress]\n");
 =09fprintf(stderr, "Where:\n");
 =09fprintf(stderr, "QDISC_KIND :=3D { [p|b]fifo | tbf | prio | cbq | red | =
etc. }\n");
 =09fprintf(stderr, "OPTIONS :=3D ... try tc qdisc add <desired QDISC_KIND> =
help\n");
+=09fprintf(stderr, "STAB_OPTIONS :=3D ... try tc qdisc add stab help\n");
 =09return -1;
 }
=20
@@ -45,6 +47,10 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, ch=
ar **argv)
 {
 =09struct qdisc_util *q =3D NULL;
 =09struct tc_estimator est;
+=09struct {
+=09=09struct tc_sizespec=09szopts;
+=09=09__u16=09=09=09data[512];
+=09} stab;
 =09char  d[16];
 =09char  k[16];
 =09struct {
@@ -54,6 +60,7 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, cha=
r **argv)
 =09} req;
=20
 =09memset(&req, 0, sizeof(req));
+=09memset(&stab, 0, sizeof(stab));
 =09memset(&est, 0, sizeof(est));
 =09memset(&d, 0, sizeof(d));
 =09memset(&k, 0, sizeof(k));
@@ -108,6 +115,10 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, =
char **argv)
 =09=09} else if (matches(*argv, "estimator") =3D=3D 0) {
 =09=09=09if (parse_estimator(&argc, &argv, &est))
 =09=09=09=09return -1;
+=09=09} else if (matches(*argv, "stab") =3D=3D 0) {
+=09=09=09if (parse_size_table(&argc, &argv, &stab.szopts) < 0)
+=09=09=09=09return -1;
+=09=09=09continue;
 =09=09} else if (matches(*argv, "help") =3D=3D 0) {
 =09=09=09usage();
 =09=09} else {
@@ -142,6 +153,23 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, =
char **argv)
 =09=09}
 =09}
=20
+=09if (check_size_table_opts(&stab.szopts)) {
+=09=09struct rtattr *tail;
+
+=09=09if (tc_calc_size_table(&stab.szopts, stab.data) < 0) {
+=09=09=09fprintf(stderr, "failed to calculate size table.\n");
+=09=09=09return -1;
+=09=09}
+
+=09=09tail =3D NLMSG_TAIL(&req.n);
+=09=09addattr_l(&req.n, sizeof(req), TCA_STAB, NULL, 0);
+=09=09addattr_l(&req.n, sizeof(req), TCA_STAB_BASE, &stab.szopts,
+=09=09=09  sizeof(stab.szopts));
+=09=09addattr_l(&req.n, sizeof(req), TCA_STAB_DATA, stab.data,
+=09=09=09  TC_STAB_DATA_SIZE);
+=09=09tail->rta_len =3D (void *)NLMSG_TAIL(&req.n) - (void *)tail;
+=09}
+
 =09if (d[0])  {
 =09=09int idx;
=20
@@ -223,6 +251,10 @@ int print_qdisc(const struct sockaddr_nl *who,
 =09=09=09fprintf(fp, "[cannot parse qdisc parameters]");
 =09}
 =09fprintf(fp, "\n");
+=09if (tb[TCA_STAB]) {
+=09=09print_size_table(fp, " ", tb[TCA_STAB]);
+=09=09fprintf(fp, "\n");
+=09}
 =09if (show_stats) {
 =09=09struct rtattr *xstats =3D NULL;
=20
diff --git a/tc/tc_stab.c b/tc/tc_stab.c
new file mode 100644
index 0000000..9ca9f5e
--- /dev/null
+++ b/tc/tc_stab.c
@@ -0,0 +1,149 @@
+/*
+ * tc_stab.c=09=09"tc qdisc ... stab *".
+ *
+ *=09=09This program is free software; you can redistribute it and/or
+ *=09=09modify it under the terms of the GNU General Public License
+ *=09=09as published by the Free Software Foundation; either version
+ *=09=092 of the License, or (at your option) any later version.
+ *
+ * Authors:=09Jussi Kivilinna, <jussi.kivilinna@mbnet.fi>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <math.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+
+#include "utils.h"
+#include "tc_util.h"
+#include "tc_core.h"
+#include "tc_common.h"
+
+static void stab_help(void)
+{
+=09fprintf(stderr,
+=09=09"Usage: ... stab [ default CLASSID ] [ mtu BYTES] [ mpu BYTES ]\n"
+=09=09"                [ overhead BYTES ] [ linklayer TYPE ] ...\n"
+=09=09"   mtu       : max packet size we create rate map for {2047}\n"
+=09=09"   mpu       : minimum packet size used in rate computations\n"
+=09=09"   overhead  : per-packet size overhead used in rate computations\n"
+=09=09"   linklayer : adapting to a linklayer e.g. atm\n"
+=09=09"Example: ... stab overhead 20b linklayer atm\n");
+
+=09return;
+}
+
+int check_size_table_opts(struct tc_sizespec *s)
+{
+=09return s->linklayer >=3D LINKLAYER_ETHERNET || s->mpu !=3D 0 ||
+=09=09=09=09=09=09=09s->overhead !=3D 0;
+}
+
+int parse_size_table(int *argcp, char ***argvp, struct tc_sizespec *sp)
+{
+=09char **argv =3D *argvp;
+=09int argc =3D *argcp;
+=09unsigned linklayer =3D LINKLAYER_UNSPEC;
+=09struct tc_sizespec s;
+
+=09memset(&s, 0, sizeof(s));
+
+=09NEXT_ARG();
+=09if (matches(*argv, "help") =3D=3D 0) {
+=09=09stab_help();
+=09=09return -1;
+=09}
+=09while (argc > 0) {
+=09=09if (matches(*argv, "mtu") =3D=3D 0) {
+=09=09=09NEXT_ARG();
+=09=09=09if (s.mtu)
+=09=09=09=09duparg("mtu", *argv);
+=09=09=09if (get_u32(&s.mtu, *argv, 10)) {
+=09=09=09=09invarg("mtu", "invalid mtu");
+=09=09=09=09return -1;
+=09=09=09}
+=09=09} else if (matches(*argv, "mpu") =3D=3D 0) {
+=09=09=09NEXT_ARG();
+=09=09=09if (s.mpu)
+=09=09=09=09duparg("mpu", *argv);
+=09=09=09if (get_u32(&s.mpu, *argv, 10)) {
+=09=09=09=09invarg("mpu", "invalid mpu");
+=09=09=09=09return -1;
+=09=09=09}
+=09=09} else if (matches(*argv, "overhead") =3D=3D 0) {
+=09=09=09NEXT_ARG();
+=09=09=09if (s.overhead)
+=09=09=09=09duparg("overhead", *argv);
+=09=09=09if (get_integer(&s.overhead, *argv, 10)) {
+=09=09=09=09invarg("overhead", "invalid overhead");
+=09=09=09=09return -1;
+=09=09=09}
+=09=09} else if (matches(*argv, "linklayer") =3D=3D 0) {
+=09=09=09NEXT_ARG();
+=09=09=09if (linklayer !=3D LINKLAYER_UNSPEC)
+=09=09=09=09duparg("linklayer", *argv);
+=09=09=09if (get_linklayer(&linklayer, *argv)) {
+=09=09=09=09invarg("linklayer", "invalid linklayer");
+=09=09=09=09return -1;
+=09=09=09}
+=09=09} else
+=09=09=09break;
+=09=09argc--; argv++;
+=09}
+
+=09if (!check_size_table_opts(&s))
+=09=09return -1;
+
+=09s.linklayer =3D linklayer;
+=09*sp =3D s;
+=09*argvp =3D argv;
+=09*argcp =3D argc;
+=09return 0;
+}
+
+void print_size_table(FILE *fp, const char *prefix, struct rtattr *rta)
+{
+=09struct rtattr *tb[TCA_STAB_MAX + 1];
+
+=09SPRINT_BUF(b1);
+
+=09parse_rtattr_nested(tb, TCA_STAB_MAX, rta);
+
+=09if (tb[TCA_STAB_BASE]) {
+=09=09struct tc_sizespec s =3D {0};
+=09=09memcpy(&s, RTA_DATA(tb[TCA_STAB_BASE]), MIN(RTA_PAYLOAD(tb[TCA_STAB_B=
ASE]), sizeof(s)));
+
+=09=09fprintf(fp, "%s", prefix);
+=09=09if (s.mtu)
+=09=09=09fprintf(fp, "mtu %u ", s.mtu);
+=09=09if (s.mpu)
+=09=09=09fprintf(fp, "mpu %u ", s.mpu);
+=09=09if (s.overhead)
+=09=09=09fprintf(fp, "overhead %d ", s.overhead);
+=09=09if (s.linklayer)
+=09=09=09fprintf(fp, "linklayer %s ", sprint_linklayer(s.linklayer, b1));
+=09}
+
+#if 0
+=09if (show_details && tb[TCA_STAB_DATA]) {
+=09=09unsigned i, j, dlen;
+=09=09__u16 *data =3D RTA_DATA(tb[TCA_STAB_DATA]);
+=09=09dlen =3D RTA_PAYLOAD(tb[TCA_STAB_DATA]) / sizeof(__u16);
+
+=09=09fprintf(fp, "\n%sstab data:", prefix);
+=09=09for (i =3D 0; i < dlen/12; i++) {
+=09=09=09fprintf(fp, "\n%s %3u:", prefix, i * 12);
+=09=09=09for (j =3D 0; i * 12 + j < dlen; j++)
+=09=09=09=09fprintf(fp, " %05x", data[i * 12 + j]);
+=09=09}
+=09}
+#endif
+}
+
diff --git a/tc/tc_util.c b/tc/tc_util.c
index cd9dd59..8ec8ec2 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -435,7 +435,7 @@ int action_a2n(char *arg, int *result)
 =09return 0;
 }
=20
-int get_linklayer(unsigned int *val, const char *arg)
+int get_linklayer(unsigned *val, const char *arg)
 {
 =09int res;
=20
@@ -452,6 +452,30 @@ int get_linklayer(unsigned int *val, const char *arg)
 =09return 0;
 }
=20
+void print_linklayer(char *buf, int len, unsigned linklayer)
+{
+=09switch (linklayer) {
+=09case LINKLAYER_UNSPEC:
+=09=09snprintf(buf, len, "%s", "unspec");
+=09=09return;
+=09case LINKLAYER_ETHERNET:
+=09=09snprintf(buf, len, "%s", "ethernet");
+=09=09return;
+=09case LINKLAYER_ATM:
+=09=09snprintf(buf, len, "%s", "atm");
+=09=09return;
+=09default:
+=09=09snprintf(buf, len, "%s", "unknown");
+=09=09return;
+=09}
+}
+
+char *sprint_linklayer(unsigned linklayer, char *buf)
+{
+=09print_linklayer(buf, SPRINT_BSIZE-1, linklayer);
+=09return buf;
+}
+
 void print_tm(FILE * f, const struct tcf_t *tm)
 {
 =09int hz =3D get_user_hz();
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 796da54..c4a386c 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -57,6 +57,7 @@ extern void print_size(char *buf, int len, __u32 size);
 extern void print_percent(char *buf, int len, __u32 percent);
 extern void print_qdisc_handle(char *buf, int len, __u32 h);
 extern void print_time(char *buf, int len, __u32 time);
+extern void print_linklayer(char *buf, int len, unsigned linklayer);
 extern char * sprint_rate(__u32 rate, char *buf);
 extern char * sprint_size(__u32 size, char *buf);
 extern char * sprint_qdisc_handle(__u32 h, char *buf);
@@ -64,6 +65,7 @@ extern char * sprint_tc_classid(__u32 h, char *buf);
 extern char * sprint_time(__u32 time, char *buf);
 extern char * sprint_ticks(__u32 ticks, char *buf);
 extern char * sprint_percent(__u32 percent, char *buf);
+extern char * sprint_linklayer(unsigned linklayer, char *buf);
=20
 extern void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix,=
 struct rtattr **xstats);
 extern void print_tcstats2_attr(FILE *fp, struct rtattr *rta, char *prefix,=
 struct rtattr **xstats);
--=_4kdbyiudgkxs--

