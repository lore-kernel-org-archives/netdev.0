From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH] [RESEND] [iproute2/tc] add generic size table for qdiscs
Date: Fri, 25 Jul 2008 16:19:09 +0300
Message-ID: <20080725131909.14497.2315.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:58067 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbYGYNTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 09:19:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch adds generic size table that is similiar to rate table, with
difference that size table stores link layer packet size.

Based on patch by Patrick McHardy
 http://marc.info/?l=linux-netdev&m=115201979221729&w=2

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |   20 ++++++
 include/linux/rtnetlink.h |    1 
 tc/Makefile               |    1 
 tc/tc_common.h            |    5 +
 tc/tc_core.c              |   79 ++++++++++++++++++----
 tc/tc_core.h              |    6 +-
 tc/tc_qdisc.c             |   36 ++++++++++
 tc/tc_stab.c              |  160 +++++++++++++++++++++++++++++++++++++++++++++
 tc/tc_util.c              |   26 +++++++
 tc/tc_util.h              |    2 +
 10 files changed, 318 insertions(+), 18 deletions(-)
 create mode 100644 tc/tc_stab.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..a779a00 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -85,6 +85,26 @@ struct tc_ratespec
 
 #define TC_RTAB_SIZE	1024
 
+struct tc_sizespec {
+	unsigned char	cell_log;
+	unsigned char	size_log;
+	short		cell_align;
+	int		overhead;
+	unsigned int	linklayer;
+	unsigned int	mpu;
+	unsigned int	mtu;
+	unsigned int	tsize;
+};
+
+enum {
+	TCA_STAB_UNSPEC,
+	TCA_STAB_BASE,
+	TCA_STAB_DATA,
+	__TCA_STAB_MAX
+};
+
+#define TCA_STAB_MAX (__TCA_STAB_MAX - 1)
+
 /* FIFO section */
 
 struct tc_fifo_qopt
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index c1f2d50..a125692 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -482,6 +482,7 @@ enum
 	TCA_RATE,
 	TCA_FCNT,
 	TCA_STATS2,
+	TCA_STAB,
 	__TCA_MAX
 };
 
diff --git a/tc/Makefile b/tc/Makefile
index bf2df00..a5ac841 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -45,6 +45,7 @@ TCLIB := tc_core.o
 TCLIB += tc_red.o
 TCLIB += tc_cbq.o
 TCLIB += tc_estimator.o
+TCLIB += tc_stab.o
 
 CFLAGS += -DCONFIG_GACT -DCONFIG_GACT_PROB
 
diff --git a/tc/tc_common.h b/tc/tc_common.h
index e01b037..4f88856 100644
--- a/tc/tc_common.h
+++ b/tc/tc_common.h
@@ -11,6 +11,11 @@ extern int print_action(const struct sockaddr_nl *who, struct nlmsghdr *n, void
 extern int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
 extern int print_qdisc(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
 extern int print_class(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
+extern void print_size_table(FILE *fp, const char *prefix, struct rtattr *rta);
 
 struct tc_estimator;
 extern int parse_estimator(int *p_argc, char ***p_argv, struct tc_estimator *est);
+
+struct tc_sizespec;
+extern int parse_size_table(int *p_argc, char ***p_argv, struct tc_sizespec *s);
+extern int check_size_table_opts(struct tc_sizespec *s);
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 855c115..9a0ff39 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -87,6 +87,21 @@ unsigned tc_align_to_atm(unsigned size)
 	return linksize;
 }
 
+unsigned tc_adjust_size(unsigned sz, unsigned mpu, enum link_layer linklayer)
+{
+	if (sz < mpu)
+		sz = mpu;
+
+	switch (linklayer) {
+	case LINKLAYER_ATM:
+		return tc_align_to_atm(sz);
+	case LINKLAYER_ETHERNET:
+	default:
+		// No size adjustments on Ethernet
+		return sz;
+	}
+}
+
 /*
    rtab[pkt_len>>cell_log] = pkt_xmit_time
  */
@@ -96,6 +111,7 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 		   enum link_layer linklayer)
 {
 	int i;
+	unsigned sz;
 	unsigned bps = r->rate;
 	unsigned mpu = r->mpu;
 
@@ -109,21 +125,7 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 	}
 
 	for (i=0; i<256; i++) {
-		unsigned sz = (i+1)<<cell_log;
-		if (sz < mpu)
-			sz = mpu;
-
-		switch (linklayer) {
-		case LINKLAYER_ATM:
-			sz = tc_align_to_atm(sz);
-			break;
-		case LINKLAYER_ETHERNET:
-			// No size adjustments on Ethernet
-			break;
-		default:
-			break;
-		}
-
+		sz = tc_adjust_size((i + 1) << cell_log, mpu, linklayer);
 		rtab[i] = tc_calc_xmittime(bps, sz);
 	}
 
@@ -132,6 +134,53 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 	return cell_log;
 }
 
+/*
+   stab[pkt_len>>cell_log] = pkt_xmit_size>>size_log
+ */
+
+int tc_calc_size_table(struct tc_sizespec *s, __u16 **stab)
+{
+	int i;
+	enum link_layer linklayer = s->linklayer;
+	unsigned int sz;
+
+	if (linklayer <= LINKLAYER_ETHERNET && s->mpu == 0) {
+		/* don't need data table in this case (only overhead set) */
+		s->mtu = 0;
+		s->tsize = 0;
+		s->cell_log = 0;
+		s->cell_align = 0;
+		*stab = NULL;
+		return 0;
+	}
+
+	if (s->mtu == 0)
+		s->mtu = 2047;
+	if (s->tsize == 0)
+		s->tsize = 512;
+
+	s->cell_log = 0;
+	while ((s->mtu >> s->cell_log) > s->tsize - 1)
+		s->cell_log++;
+
+	*stab = malloc(s->tsize * sizeof(__u16));
+	if (!*stab)
+		return -1;
+
+again:
+	for (i = s->tsize - 1; i >= 0; i--) {
+		sz = tc_adjust_size((i + 1) << s->cell_log, s->mpu, linklayer);
+		if ((sz >> s->size_log) > UINT16_MAX) {
+			s->size_log++;
+			goto again;
+		}
+		(*stab)[i] = sz >> s->size_log;
+	}
+
+	s->cell_align = -1; // Due to the sz calc
+	return 0;
+}
+
 int tc_core_init()
 {
 	FILE *fp;
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 9f835e8..5a693ba 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -7,8 +7,9 @@
 #define TIME_UNITS_PER_SEC	1000000
 
 enum link_layer {
-	LINKLAYER_ETHERNET=1,
-	LINKLAYER_ATM     =2,
+	LINKLAYER_UNSPEC,
+	LINKLAYER_ETHERNET,
+	LINKLAYER_ATM,
 };
 
 
@@ -21,6 +22,7 @@ unsigned tc_calc_xmittime(unsigned rate, unsigned size);
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
 int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 		   int cell_log, unsigned mtu, enum link_layer link_layer);
+int tc_calc_size_table(struct tc_sizespec *s, __u16 **stab);
 
 int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator *est);
 
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 1256f07..c7f2988 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -20,6 +20,7 @@
 #include <arpa/inet.h>
 #include <string.h>
 #include <math.h>
+#include <malloc.h>
 
 #include "utils.h"
 #include "tc_util.h"
@@ -32,12 +33,14 @@ static int usage(void)
 	fprintf(stderr, "Usage: tc qdisc [ add | del | replace | change | show ] dev STRING\n");
 	fprintf(stderr, "       [ handle QHANDLE ] [ root | ingress | parent CLASSID ]\n");
 	fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
+	fprintf(stderr, "       [ stab [ help | STAB_OPTIONS] ]\n");
 	fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ingress]\n");
 	fprintf(stderr, "Where:\n");
 	fprintf(stderr, "QDISC_KIND := { [p|b]fifo | tbf | prio | cbq | red | etc. }\n");
 	fprintf(stderr, "OPTIONS := ... try tc qdisc add <desired QDISC_KIND> help\n");
+	fprintf(stderr, "STAB_OPTIONS := ... try tc qdisc add stab help\n");
 	return -1;
 }
 
@@ -45,6 +48,10 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 {
 	struct qdisc_util *q = NULL;
 	struct tc_estimator est;
+	struct {
+		struct tc_sizespec	szopts;
+		__u16			*data;
+	} stab;
 	char  d[16];
 	char  k[16];
 	struct {
@@ -54,6 +61,7 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 	} req;
 
 	memset(&req, 0, sizeof(req));
+	memset(&stab, 0, sizeof(stab));
 	memset(&est, 0, sizeof(est));
 	memset(&d, 0, sizeof(d));
 	memset(&k, 0, sizeof(k));
@@ -108,6 +116,10 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 		} else if (matches(*argv, "estimator") == 0) {
 			if (parse_estimator(&argc, &argv, &est))
 				return -1;
+		} else if (matches(*argv, "stab") == 0) {
+			if (parse_size_table(&argc, &argv, &stab.szopts) < 0)
+				return -1;
+			continue;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -142,6 +154,26 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 		}
 	}
 
+	if (check_size_table_opts(&stab.szopts)) {
+		struct rtattr *tail;
+
+		if (tc_calc_size_table(&stab.szopts, &stab.data) < 0) {
+			fprintf(stderr, "failed to calculate size table.\n");
+			return -1;
+		}
+
+		tail = NLMSG_TAIL(&req.n);
+		addattr_l(&req.n, sizeof(req), TCA_STAB, NULL, 0);
+		addattr_l(&req.n, sizeof(req), TCA_STAB_BASE, &stab.szopts,
+			  sizeof(stab.szopts));
+		if (stab.data)
+			addattr_l(&req.n, sizeof(req), TCA_STAB_DATA, stab.data,
+				  stab.szopts.tsize * sizeof(__u16));
+		tail->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)tail;
+		if (stab.data)
+			free(stab.data);
+	}
+
 	if (d[0])  {
 		int idx;
 
@@ -223,6 +255,10 @@ int print_qdisc(const struct sockaddr_nl *who,
 			fprintf(fp, "[cannot parse qdisc parameters]");
 	}
 	fprintf(fp, "\n");
+	if (show_details && tb[TCA_STAB]) {
+		print_size_table(fp, " ", tb[TCA_STAB]);
+		fprintf(fp, "\n");
+	}
 	if (show_stats) {
 		struct rtattr *xstats = NULL;
 
diff --git a/tc/tc_stab.c b/tc/tc_stab.c
new file mode 100644
index 0000000..47b4e5e
--- /dev/null
+++ b/tc/tc_stab.c
@@ -0,0 +1,160 @@
+/*
+ * tc_stab.c		"tc qdisc ... stab *".
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Jussi Kivilinna, <jussi.kivilinna@mbnet.fi>
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
+#include <malloc.h>
+
+#include "utils.h"
+#include "tc_util.h"
+#include "tc_core.h"
+#include "tc_common.h"
+
+static void stab_help(void)
+{
+	fprintf(stderr,
+		"Usage: ... stab [ mtu BYTES ] [ tsize SLOTS ] [ mpu BYTES ] \n"
+		"                [ overhead BYTES ] [ linklayer TYPE ] ...\n"
+		"   mtu       : max packet size we create rate map for {2047}\n"
+		"   tsize     : how many slots should size table have {512}\n"
+		"   mpu       : minimum packet size used in rate computations\n"
+		"   overhead  : per-packet size overhead used in rate computations\n"
+		"   linklayer : adapting to a linklayer e.g. atm\n"
+		"Example: ... stab overhead 20 linklayer atm\n");
+
+	return;
+}
+
+int check_size_table_opts(struct tc_sizespec *s)
+{
+	return s->linklayer >= LINKLAYER_ETHERNET || s->mpu != 0 ||
+							s->overhead != 0;
+}
+
+int parse_size_table(int *argcp, char ***argvp, struct tc_sizespec *sp)
+{
+	char **argv = *argvp;
+	int argc = *argcp;
+	struct tc_sizespec s;
+
+	memset(&s, 0, sizeof(s));
+
+	NEXT_ARG();
+	if (matches(*argv, "help") == 0) {
+		stab_help();
+		return -1;
+	}
+	while (argc > 0) {
+		if (matches(*argv, "mtu") == 0) {
+			NEXT_ARG();
+			if (s.mtu)
+				duparg("mtu", *argv);
+			if (get_u32(&s.mtu, *argv, 10)) {
+				invarg("mtu", "invalid mtu");
+				return -1;
+			}
+		} else if (matches(*argv, "mpu") == 0) {
+			NEXT_ARG();
+			if (s.mpu)
+				duparg("mpu", *argv);
+			if (get_u32(&s.mpu, *argv, 10)) {
+				invarg("mpu", "invalid mpu");
+				return -1;
+			}
+		} else if (matches(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (s.overhead)
+				duparg("overhead", *argv);
+			if (get_integer(&s.overhead, *argv, 10)) {
+				invarg("overhead", "invalid overhead");
+				return -1;
+			}
+		} else if (matches(*argv, "tsize") == 0) {
+			NEXT_ARG();
+			if (s.tsize)
+				duparg("tsize", *argv);
+			if (get_u32(&s.tsize, *argv, 10)) {
+				invarg("tsize", "invalid table size");
+				return -1;
+			}
+		} else if (matches(*argv, "linklayer") == 0) {
+			NEXT_ARG();
+			if (s.linklayer != LINKLAYER_UNSPEC)
+				duparg("linklayer", *argv);
+			if (get_linklayer(&s.linklayer, *argv)) {
+				invarg("linklayer", "invalid linklayer");
+				return -1;
+			}
+		} else
+			break;
+		argc--; argv++;
+	}
+
+	if (!check_size_table_opts(&s))
+		return -1;
+
+	*sp = s;
+	*argvp = argv;
+	*argcp = argc;
+	return 0;
+}
+
+void print_size_table(FILE *fp, const char *prefix, struct rtattr *rta)
+{
+	struct rtattr *tb[TCA_STAB_MAX + 1];
+	SPRINT_BUF(b1);
+
+	parse_rtattr_nested(tb, TCA_STAB_MAX, rta);
+
+	if (tb[TCA_STAB_BASE]) {
+		struct tc_sizespec s = {0};
+		memcpy(&s, RTA_DATA(tb[TCA_STAB_BASE]),
+				MIN(RTA_PAYLOAD(tb[TCA_STAB_BASE]), sizeof(s)));
+
+		fprintf(fp, "%s", prefix);
+		if (s.linklayer)
+			fprintf(fp, "linklayer %s ",
+					sprint_linklayer(s.linklayer, b1));
+		if (s.overhead)
+			fprintf(fp, "overhead %d ", s.overhead);
+		if (s.mpu)
+			fprintf(fp, "mpu %u ", s.mpu);
+		if (s.mtu)
+			fprintf(fp, "mtu %u ", s.mtu);
+		if (s.tsize)
+			fprintf(fp, "tsize %u ", s.tsize);
+	}
+
+#if 0
+	if (tb[TCA_STAB_DATA]) {
+		unsigned i, j, dlen;
+		__u16 *data = RTA_DATA(tb[TCA_STAB_DATA]);
+		dlen = RTA_PAYLOAD(tb[TCA_STAB_DATA]) / sizeof(__u16);
+
+		fprintf(fp, "\n%sstab data:", prefix);
+		for (i = 0; i < dlen/12; i++) {
+			fprintf(fp, "\n%s %3u:", prefix, i * 12);
+			for (j = 0; i * 12 + j < dlen; j++)
+				fprintf(fp, " %05x", data[i * 12 + j]);
+		}
+	}
+#endif
+}
+
diff --git a/tc/tc_util.c b/tc/tc_util.c
index cd9dd59..8ec8ec2 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -435,7 +435,7 @@ int action_a2n(char *arg, int *result)
 	return 0;
 }
 
-int get_linklayer(unsigned int *val, const char *arg)
+int get_linklayer(unsigned *val, const char *arg)
 {
 	int res;
 
@@ -452,6 +452,30 @@ int get_linklayer(unsigned int *val, const char *arg)
 	return 0;
 }
 
+void print_linklayer(char *buf, int len, unsigned linklayer)
+{
+	switch (linklayer) {
+	case LINKLAYER_UNSPEC:
+		snprintf(buf, len, "%s", "unspec");
+		return;
+	case LINKLAYER_ETHERNET:
+		snprintf(buf, len, "%s", "ethernet");
+		return;
+	case LINKLAYER_ATM:
+		snprintf(buf, len, "%s", "atm");
+		return;
+	default:
+		snprintf(buf, len, "%s", "unknown");
+		return;
+	}
+}
+
+char *sprint_linklayer(unsigned linklayer, char *buf)
+{
+	print_linklayer(buf, SPRINT_BSIZE-1, linklayer);
+	return buf;
+}
+
 void print_tm(FILE * f, const struct tcf_t *tm)
 {
 	int hz = get_user_hz();
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
 
 extern void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtattr **xstats);
 extern void print_tcstats2_attr(FILE *fp, struct rtattr *rta, char *prefix, struct rtattr **xstats);

