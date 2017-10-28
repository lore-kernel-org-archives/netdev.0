From: Nishanth Devarajan <ndev2021@gmail.com>
Subject: [PATCH iproute2/net-next]tc: B.W limits can now be specified in %
Date: Sat, 28 Oct 2017 22:57:00 +0530
Message-ID: <20171028172657.GA5039@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, doucette@bu.edu, michel.machado@gmail.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:52620 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751399AbdJ1Rpm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 13:45:42 -0400
Received: by mail-yw0-f195.google.com with SMTP id w2so8276206ywa.9
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 10:45:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adapts the tc command line interface to allow bandwidth limits
to be specified as a percentage of the interface's capacity.

For this purpose, we move int read_prop() from ip/iptuntap.c to
lib/utils.c to make it accessible to tc.

Additionally, adding this functionality requires passing the specified
device string to each class/qdisc which changes the prototype for a
couple of functions: the .parse_qopt and .parse_copt interfaces. The
device string is a required parameter for tc-qdisc and tc-class, and when
not specified, the kernel return ENODEV. In this patch, if the user tries
to specify a bandwidth percentage without naming the device, we return an
error from userspace.

Signed-off-by: Nishanth Devarajan <ndev2021@gmail.com>
---
 include/utils.h |  1 +
 ip/iptuntap.c   | 32 --------------------------------
 lib/utils.c     | 32 ++++++++++++++++++++++++++++++++
 man/man8/tc.8   |  4 +++-
 tc/q_atm.c      |  2 +-
 tc/q_cbq.c      | 25 ++++++++++++++++++++-----
 tc/q_choke.c    |  9 +++++++--
 tc/q_clsact.c   |  2 +-
 tc/q_codel.c    |  2 +-
 tc/q_drr.c      |  4 ++--
 tc/q_dsmark.c   |  4 ++--
 tc/q_fifo.c     |  2 +-
 tc/q_fq.c       | 16 +++++++++++++---
 tc/q_fq_codel.c |  2 +-
 tc/q_gred.c     |  9 +++++++--
 tc/q_hfsc.c     | 45 ++++++++++++++++++++++++++++++---------------
 tc/q_hhf.c      |  2 +-
 tc/q_htb.c      | 18 ++++++++++++++----
 tc/q_ingress.c  |  2 +-
 tc/q_mqprio.c   |  2 +-
 tc/q_multiq.c   |  2 +-
 tc/q_netem.c    |  9 +++++++--
 tc/q_pie.c      |  2 +-
 tc/q_prio.c     |  2 +-
 tc/q_qfq.c      |  4 ++--
 tc/q_red.c      |  9 +++++++--
 tc/q_rr.c       |  2 +-
 tc/q_sfb.c      |  2 +-
 tc/q_sfq.c      |  2 +-
 tc/q_tbf.c      | 16 +++++++++++++---
 tc/tc.c         |  2 +-
 tc/tc_class.c   |  2 +-
 tc/tc_qdisc.c   |  2 +-
 tc/tc_util.c    | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tc/tc_util.h    |  8 ++++++--
 35 files changed, 237 insertions(+), 96 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 3d91c50..63fea7c 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -87,6 +87,7 @@ int get_prefix(inet_prefix *dst, char *arg, int family);
 int mask2bits(__u32 netmask);
 int get_addr_ila(__u64 *val, const char *arg);
 
+int read_prop(char *dev, char *prop, long *value);
 int get_hex(char c);
 int get_integer(int *val, const char *arg, int base);
 int get_unsigned(unsigned *val, const char *arg, int base);
diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index b46e452..09f2be2 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -223,38 +223,6 @@ static int do_del(int argc, char **argv)
 	return tap_del_ioctl(&ifr);
 }
 
-static int read_prop(char *dev, char *prop, long *value)
-{
-	char fname[IFNAMSIZ+25], buf[80], *endp;
-	ssize_t len;
-	int fd;
-	long result;
-
-	sprintf(fname, "/sys/class/net/%s/%s", dev, prop);
-	fd = open(fname, O_RDONLY);
-	if (fd < 0) {
-		if (strcmp(prop, "tun_flags"))
-			fprintf(stderr, "open %s: %s\n", fname,
-				strerror(errno));
-		return -1;
-	}
-	len = read(fd, buf, sizeof(buf)-1);
-	close(fd);
-	if (len < 0) {
-		fprintf(stderr, "read %s: %s", fname, strerror(errno));
-		return -1;
-	}
-
-	buf[len] = 0;
-	result = strtol(buf, &endp, 0);
-	if (*endp != '\n') {
-		fprintf(stderr, "Failed to parse %s\n", fname);
-		return -1;
-	}
-	*value = result;
-	return 0;
-}
-
 static void print_flags(long flags)
 {
 	if (flags & IFF_TUN)
diff --git a/lib/utils.c b/lib/utils.c
index ac155bf..444c978 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -39,6 +39,38 @@
 
 int timestamp_short;
 
+int read_prop(char *dev, char *prop, long *value)
+{
+	char fname[41], buf[80], *endp;
+	ssize_t len;
+	int fd;
+	long result;
+
+	sprintf(fname, "/sys/class/net/%s/%s", dev, prop);
+	fd = open(fname, O_RDONLY);
+	if (fd < 0) {
+		if (strcmp(prop, "tun_flags"))
+			fprintf(stderr, "open %s: %s\n", fname,
+				strerror(errno));
+		return -1;
+	}
+	len = read(fd, buf, sizeof(buf)-1);
+	close(fd);
+	if (len < 0) {
+		fprintf(stderr, "read %s: %s", fname, strerror(errno));
+		return -1;
+	}
+
+	buf[len] = 0;
+	result = strtol(buf, &endp, 0);
+	if (*endp != '\n') {
+		fprintf(stderr, "Failed to parse %s\n", fname);
+		return -1;
+	}
+	*value = result;
+	return 0;
+}
+
 int get_hex(char c)
 {
 	if (c >= 'A' && c <= 'F')
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index f96911a..22f699b 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -443,7 +443,9 @@ see the man pages for individual qdiscs.
 RATES
 Bandwidths or rates.
 These parameters accept a floating point number, possibly followed by
-a unit (both SI and IEC units supported).
+either a unit (both SI and IEC units supported), or a float followed '%'
+character to specify the rate as a percentage of the device's speed
+(e.g. 5%, 99.5%).
 .RS
 .TP
 bit or a bare number
diff --git a/tc/q_atm.c b/tc/q_atm.c
index 56e7ad8..5aa73db 100644
--- a/tc/q_atm.c
+++ b/tc/q_atm.c
@@ -45,7 +45,7 @@ static void explain(void)
 
 
 static int atm_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
-   struct nlmsghdr *n)
+	struct nlmsghdr *n, char *dev)
 {
 	struct sockaddr_atmsvc addr = {};
 	struct atm_qos qos;
diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index f148175..48adb15 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -47,7 +47,7 @@ static void explain1(char *arg)
 }
 
 
-static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	struct tc_ratespec r = {};
 	struct tc_cbq_lssopt lss = {};
@@ -63,7 +63,12 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		if (matches(*argv, "bandwidth") == 0 ||
 		    matches(*argv, "rate") == 0) {
 			NEXT_ARG();
-			if (get_rate(&r.rate, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate(&r.rate, *argv, dev)) {
+					explain1("bandwidth");
+					return -1;
+				}
+			} else if (get_rate(&r.rate, *argv)) {
 				explain1("bandwidth");
 				return -1;
 			}
@@ -177,7 +182,7 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	return 0;
 }
 
-static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	int wrr_ok = 0, fopt_ok = 0;
 	struct tc_ratespec r = {};
@@ -197,13 +202,23 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	while (argc > 0) {
 		if (matches(*argv, "rate") == 0) {
 			NEXT_ARG();
-			if (get_rate(&r.rate, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate(&r.rate, *argv, dev)) {
+					explain1("rate");
+					return -1;
+				}
+			} else if (get_rate(&r.rate, *argv)) {
 				explain1("rate");
 				return -1;
 			}
 		} else if (matches(*argv, "bandwidth") == 0) {
 			NEXT_ARG();
-			if (get_rate(&bndw, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate(&bndw, *argv, dev)) {
+					explain1("bandwidth");
+					return -1;
+				}
+			} else if (get_rate(&bndw, *argv)) {
 				explain1("bandwidth");
 				return -1;
 			}
diff --git a/tc/q_choke.c b/tc/q_choke.c
index a234d2e..b3bba68 100644
--- a/tc/q_choke.c
+++ b/tc/q_choke.c
@@ -32,7 +32,7 @@ static void explain(void)
 }
 
 static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			   struct nlmsghdr *n)
+			   struct nlmsghdr *n, char *dev)
 {
 	struct tc_red_qopt opt = {};
 	unsigned int burst = 0;
@@ -54,7 +54,12 @@ static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			}
 		} else if (strcmp(*argv, "bandwidth") == 0) {
 			NEXT_ARG();
-			if (get_rate(&rate, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate(&rate, *argv, dev)) {
+					fprintf(stderr, "Illegal \"bandwidth\"\n");
+					return -1;
+				}
+			} else if (get_rate(&rate, *argv)) {
 				fprintf(stderr, "Illegal \"bandwidth\"\n");
 				return -1;
 			}
diff --git a/tc/q_clsact.c b/tc/q_clsact.c
index e2a1a71..89028e6 100644
--- a/tc/q_clsact.c
+++ b/tc/q_clsact.c
@@ -10,7 +10,7 @@ static void explain(void)
 }
 
 static int clsact_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			    struct nlmsghdr *n)
+			    struct nlmsghdr *n, char *dev)
 {
 	if (argc > 0) {
 		fprintf(stderr, "What is \"%s\"?\n", *argv);
diff --git a/tc/q_codel.c b/tc/q_codel.c
index 09222a1..9395322 100644
--- a/tc/q_codel.c
+++ b/tc/q_codel.c
@@ -59,7 +59,7 @@ static void explain(void)
 }
 
 static int codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			   struct nlmsghdr *n)
+			   struct nlmsghdr *n, char *dev)
 {
 	unsigned int limit = 0;
 	unsigned int target = 0;
diff --git a/tc/q_drr.c b/tc/q_drr.c
index 79c81a2..9da18fb 100644
--- a/tc/q_drr.c
+++ b/tc/q_drr.c
@@ -34,7 +34,7 @@ static void explain2(void)
 }
 
 
-static int drr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int drr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	while (argc) {
 		if (strcmp(*argv, "help") == 0) {
@@ -50,7 +50,7 @@ static int drr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 }
 
 static int drr_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
-			       struct nlmsghdr *n)
+			       struct nlmsghdr *n, char *dev)
 {
 	struct rtattr *tail;
 	__u32 tmp;
diff --git a/tc/q_dsmark.c b/tc/q_dsmark.c
index 79dfd9a..3dea769 100644
--- a/tc/q_dsmark.c
+++ b/tc/q_dsmark.c
@@ -26,7 +26,7 @@ static void explain(void)
 
 
 static int dsmark_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-    struct nlmsghdr *n)
+	struct nlmsghdr *n, char *dev)
 {
 	struct rtattr *tail;
 	__u16 ind;
@@ -85,7 +85,7 @@ static void explain_class(void)
 
 
 static int dsmark_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
-   struct nlmsghdr *n)
+	struct nlmsghdr *n, char *dev)
 {
 	struct rtattr *tail;
 	__u8 tmp;
diff --git a/tc/q_fifo.c b/tc/q_fifo.c
index 3ee8ce9..eba1d38 100644
--- a/tc/q_fifo.c
+++ b/tc/q_fifo.c
@@ -28,7 +28,7 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... <[p|b]fifo | pfifo_head_drop> [ limit NUMBER ]\n");
 }
 
-static int fifo_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int fifo_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	int ok = 0;
 	struct tc_fifo_qopt opt = {};
diff --git a/tc/q_fq.c b/tc/q_fq.c
index 45b2ffd..b2ffbad 100644
--- a/tc/q_fq.c
+++ b/tc/q_fq.c
@@ -72,7 +72,7 @@ static unsigned int ilog2(unsigned int val)
 }
 
 static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			struct nlmsghdr *n)
+			struct nlmsghdr *n, char *dev)
 {
 	unsigned int plimit;
 	unsigned int flow_plimit;
@@ -119,7 +119,12 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			}
 		} else if (strcmp(*argv, "maxrate") == 0) {
 			NEXT_ARG();
-			if (get_rate(&maxrate, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate(&maxrate, *argv, dev)) {
+					fprintf(stderr, "Illegal \"maxrate\"\n");
+					return -1;
+				}
+			} else if (get_rate(&maxrate, *argv)) {
 				fprintf(stderr, "Illegal \"maxrate\"\n");
 				return -1;
 			}
@@ -133,7 +138,12 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			set_low_rate_threshold = true;
 		} else if (strcmp(*argv, "defrate") == 0) {
 			NEXT_ARG();
-			if (get_rate(&defrate, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate(&defrate, *argv, dev)) {
+					fprintf(stderr, "Illegal \"defrate\"\n");
+					return -1;
+				}
+			} else if (get_rate(&defrate, *argv)) {
 				fprintf(stderr, "Illegal \"defrate\"\n");
 				return -1;
 			}
diff --git a/tc/q_fq_codel.c b/tc/q_fq_codel.c
index 500e620..a105121 100644
--- a/tc/q_fq_codel.c
+++ b/tc/q_fq_codel.c
@@ -57,7 +57,7 @@ static void explain(void)
 }
 
 static int fq_codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			      struct nlmsghdr *n)
+			      struct nlmsghdr *n, char *dev)
 {
 	unsigned int limit = 0;
 	unsigned int flows = 0;
diff --git a/tc/q_gred.c b/tc/q_gred.c
index 0a98949..1cbaad8 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -117,7 +117,7 @@ static int init_gred(struct qdisc_util *qu, int argc, char **argv,
 /*
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 */
-static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	int ok = 0;
 	struct tc_gred_qopt opt = { 0 };
@@ -200,7 +200,12 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 			ok++;
 		} else if (strcmp(*argv, "bandwidth") == 0) {
 			NEXT_ARG();
-			if (get_rate(&rate, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate(&rate, *argv, dev)) {
+					fprintf(stderr, "Illegal \"bandwidth\"\n");
+					return -1;
+				}
+			} else if (get_rate(&rate, *argv)) {
 				fprintf(stderr, "Illegal \"bandwidth\"\n");
 				return -1;
 			}
diff --git a/tc/q_hfsc.c b/tc/q_hfsc.c
index cf784f1..c4b3151 100644
--- a/tc/q_hfsc.c
+++ b/tc/q_hfsc.c
@@ -24,7 +24,7 @@
 #include "utils.h"
 #include "tc_util.h"
 
-static int hfsc_get_sc(int *, char ***, struct tc_service_curve *);
+static int hfsc_get_sc(int *, char ***, struct tc_service_curve *, char *);
 
 
 static void
@@ -71,7 +71,7 @@ explain1(char *arg)
 }
 
 static int
-hfsc_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+hfsc_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	struct tc_hfsc_qopt qopt = {};
 
@@ -142,7 +142,7 @@ hfsc_print_xstats(struct qdisc_util *qu, FILE *f, struct rtattr *xstats)
 
 static int
 hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
-		     struct nlmsghdr *n)
+		     struct nlmsghdr *n, char *dev)
 {
 	struct tc_service_curve rsc = {}, fsc = {}, usc = {};
 	int rsc_ok = 0, fsc_ok = 0, usc_ok = 0;
@@ -151,21 +151,21 @@ hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 	while (argc > 0) {
 		if (matches(*argv, "rt") == 0) {
 			NEXT_ARG();
-			if (hfsc_get_sc(&argc, &argv, &rsc) < 0) {
+			if (hfsc_get_sc(&argc, &argv, &rsc, dev) < 0) {
 				explain1("rt");
 				return -1;
 			}
 			rsc_ok = 1;
 		} else if (matches(*argv, "ls") == 0) {
 			NEXT_ARG();
-			if (hfsc_get_sc(&argc, &argv, &fsc) < 0) {
+			if (hfsc_get_sc(&argc, &argv, &fsc, dev) < 0) {
 				explain1("ls");
 				return -1;
 			}
 			fsc_ok = 1;
 		} else if (matches(*argv, "sc") == 0) {
 			NEXT_ARG();
-			if (hfsc_get_sc(&argc, &argv, &rsc) < 0) {
+			if (hfsc_get_sc(&argc, &argv, &rsc, dev) < 0) {
 				explain1("sc");
 				return -1;
 			}
@@ -174,7 +174,7 @@ hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 			fsc_ok = 1;
 		} else if (matches(*argv, "ul") == 0) {
 			NEXT_ARG();
-			if (hfsc_get_sc(&argc, &argv, &usc) < 0) {
+			if (hfsc_get_sc(&argc, &argv, &usc, dev) < 0) {
 				explain1("ul");
 				return -1;
 			}
@@ -282,7 +282,7 @@ struct qdisc_util hfsc_qdisc_util = {
 };
 
 static int
-hfsc_get_sc1(int *argcp, char ***argvp, struct tc_service_curve *sc)
+hfsc_get_sc1(int *argcp, char ***argvp, struct tc_service_curve *sc, char *dev)
 {
 	char **argv = *argvp;
 	int argc = *argcp;
@@ -290,7 +290,12 @@ hfsc_get_sc1(int *argcp, char ***argvp, struct tc_service_curve *sc)
 
 	if (matches(*argv, "m1") == 0) {
 		NEXT_ARG();
-		if (get_rate(&m1, *argv) < 0) {
+		if (strchr(*argv, '%')) {
+			if (get_percent_rate(&m1, *argv, dev)) {
+				explain1("m1");
+				return -1;
+			}
+		} else if (get_rate(&m1, *argv) < 0) {
 			explain1("m1");
 			return -1;
 		}
@@ -308,7 +313,12 @@ hfsc_get_sc1(int *argcp, char ***argvp, struct tc_service_curve *sc)
 
 	if (matches(*argv, "m2") == 0) {
 		NEXT_ARG();
-		if (get_rate(&m2, *argv) < 0) {
+		if (strchr(*argv, '%')) {
+			if (get_percent_rate(&m2, *argv, dev)) {
+				explain1("m2");
+				return -1;
+			}
+		} else if (get_rate(&m2, *argv) < 0) {
 			explain1("m2");
 			return -1;
 		}
@@ -325,7 +335,7 @@ hfsc_get_sc1(int *argcp, char ***argvp, struct tc_service_curve *sc)
 }
 
 static int
-hfsc_get_sc2(int *argcp, char ***argvp, struct tc_service_curve *sc)
+hfsc_get_sc2(int *argcp, char ***argvp, struct tc_service_curve *sc, char *dev)
 {
 	char **argv = *argvp;
 	int argc = *argcp;
@@ -351,7 +361,12 @@ hfsc_get_sc2(int *argcp, char ***argvp, struct tc_service_curve *sc)
 
 	if (matches(*argv, "rate") == 0) {
 		NEXT_ARG();
-		if (get_rate(&rate, *argv) < 0) {
+		if (strchr(*argv, '%')) {
+			if (get_percent_rate(&rate, *argv, dev)) {
+				explain1("rate");
+				return -1;
+			}
+		} else if (get_rate(&rate, *argv) < 0) {
 			explain1("rate");
 			return -1;
 		}
@@ -387,10 +402,10 @@ hfsc_get_sc2(int *argcp, char ***argvp, struct tc_service_curve *sc)
 }
 
 static int
-hfsc_get_sc(int *argcp, char ***argvp, struct tc_service_curve *sc)
+hfsc_get_sc(int *argcp, char ***argvp, struct tc_service_curve *sc, char *dev)
 {
-	if (hfsc_get_sc1(argcp, argvp, sc) < 0 &&
-	    hfsc_get_sc2(argcp, argvp, sc) < 0)
+	if (hfsc_get_sc1(argcp, argvp, sc, dev) < 0 &&
+	    hfsc_get_sc2(argcp, argvp, sc, dev) < 0)
 		return -1;
 
 	if (sc->m1 == 0 && sc->m2 == 0) {
diff --git a/tc/q_hhf.c b/tc/q_hhf.c
index 738b563..b2b9bc1 100644
--- a/tc/q_hhf.c
+++ b/tc/q_hhf.c
@@ -26,7 +26,7 @@ static void explain(void)
 }
 
 static int hhf_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			 struct nlmsghdr *n)
+			 struct nlmsghdr *n, char *dev)
 {
 	unsigned int limit = 0;
 	unsigned int quantum = 0;
diff --git a/tc/q_htb.c b/tc/q_htb.c
index a811c28..8a3ff09 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -60,7 +60,7 @@ static void explain1(char *arg)
 }
 
 
-static int htb_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int htb_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	unsigned int direct_qlen = ~0U;
 	struct tc_htb_glob opt = {
@@ -109,7 +109,7 @@ static int htb_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	return 0;
 }
 
-static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	int ok = 0;
 	struct tc_htb_opt opt = {};
@@ -179,7 +179,12 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 				fprintf(stderr, "Double \"ceil\" spec\n");
 				return -1;
 			}
-			if (get_rate64(&ceil64, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate64(&ceil64, *argv, dev)) {
+					explain1("ceil");
+					return -1;
+				}
+			} else if (get_rate64(&ceil64, *argv)) {
 				explain1("ceil");
 				return -1;
 			}
@@ -190,7 +195,12 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 				fprintf(stderr, "Double \"rate\" spec\n");
 				return -1;
 			}
-			if (get_rate64(&rate64, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate64(&rate64, *argv, dev)) {
+					explain1("rate");
+					return -1;
+				}
+			} else if (get_rate64(&rate64, *argv)) {
 				explain1("rate");
 				return -1;
 			}
diff --git a/tc/q_ingress.c b/tc/q_ingress.c
index 31699a8..0ffd82c 100644
--- a/tc/q_ingress.c
+++ b/tc/q_ingress.c
@@ -21,7 +21,7 @@ static void explain(void)
 }
 
 static int ingress_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			     struct nlmsghdr *n)
+			     struct nlmsghdr *n, char *dev)
 {
 	while (argc > 0) {
 		if (strcmp(*argv, "handle") == 0) {
diff --git a/tc/q_mqprio.c b/tc/q_mqprio.c
index d6718fb..ceb533d 100644
--- a/tc/q_mqprio.c
+++ b/tc/q_mqprio.c
@@ -30,7 +30,7 @@ static void explain(void)
 }
 
 static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
-			    char **argv, struct nlmsghdr *n)
+			    char **argv, struct nlmsghdr *n, char *dev)
 {
 	int idx;
 	struct tc_mqprio_qopt opt = {
diff --git a/tc/q_multiq.c b/tc/q_multiq.c
index 9c09c9a..9bb8890 100644
--- a/tc/q_multiq.c
+++ b/tc/q_multiq.c
@@ -41,7 +41,7 @@ static void explain(void)
 }
 
 static int multiq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			    struct nlmsghdr *n)
+			    struct nlmsghdr *n, char *dev)
 {
 	struct tc_multiq_qopt opt = {};
 
diff --git a/tc/q_netem.c b/tc/q_netem.c
index cdaddce..e05b3a5 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -170,7 +170,7 @@ static int get_ticks(__u32 *ticks, const char *str)
 }
 
 static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			   struct nlmsghdr *n)
+			   struct nlmsghdr *n, char *dev)
 {
 	int dist_size = 0;
 	struct rtattr *tail;
@@ -399,7 +399,12 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		} else if (matches(*argv, "rate") == 0) {
 			++present[TCA_NETEM_RATE];
 			NEXT_ARG();
-			if (get_rate64(&rate64, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate64(&rate64, *argv, dev)) {
+					explain1("rate");
+					return -1;
+				}
+			} else if (get_rate64(&rate64, *argv)) {
 				explain1("rate");
 				return -1;
 			}
diff --git a/tc/q_pie.c b/tc/q_pie.c
index a697db7..08a8a62 100644
--- a/tc/q_pie.c
+++ b/tc/q_pie.c
@@ -40,7 +40,7 @@ static void explain(void)
 #define BETA_MAX 32
 
 static int pie_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			 struct nlmsghdr *n)
+			 struct nlmsghdr *n, char *dev)
 {
 	unsigned int limit   = 0;
 	unsigned int target  = 0;
diff --git a/tc/q_prio.c b/tc/q_prio.c
index a28928a..ad5f33e 100644
--- a/tc/q_prio.c
+++ b/tc/q_prio.c
@@ -28,7 +28,7 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... prio bands NUMBER priomap P1 P2...[multiqueue]\n");
 }
 
-static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	int pmap_mode = 0;
 	int idx = 0;
diff --git a/tc/q_qfq.c b/tc/q_qfq.c
index 0e02674..673f584 100644
--- a/tc/q_qfq.c
+++ b/tc/q_qfq.c
@@ -36,7 +36,7 @@ static void explain_class(void)
 }
 
 static int qfq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			 struct nlmsghdr *n)
+			 struct nlmsghdr *n, char *dev)
 {
 	if (argc > 0) {
 		if (matches(*argv, "help") != 0)
@@ -49,7 +49,7 @@ static int qfq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 }
 
 static int qfq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
-			       struct nlmsghdr *n)
+			       struct nlmsghdr *n, char *dev)
 {
 	struct rtattr *tail;
 	__u32 tmp;
diff --git a/tc/q_red.c b/tc/q_red.c
index ec706aa..2eb7f7b 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -33,7 +33,7 @@ static void explain(void)
 	fprintf(stderr, "               [ecn] [harddrop]\n");
 }
 
-static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	struct tc_red_qopt opt = {};
 	unsigned int burst = 0;
@@ -84,7 +84,12 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 			}
 		} else if (strcmp(*argv, "bandwidth") == 0) {
 			NEXT_ARG();
-			if (get_rate(&rate, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate(&rate, *argv, dev)) {
+					fprintf(stderr, "Illegal \"bandwidth\"\n");
+					return -1;
+				}
+			} else if (get_rate(&rate, *argv)) {
 				fprintf(stderr, "Illegal \"bandwidth\"\n");
 				return -1;
 			}
diff --git a/tc/q_rr.c b/tc/q_rr.c
index f330311..e473635 100644
--- a/tc/q_rr.c
+++ b/tc/q_rr.c
@@ -29,7 +29,7 @@ static void explain(void)
 }
 
 
-static int rr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int rr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	int pmap_mode = 0;
 	int idx = 0;
diff --git a/tc/q_sfb.c b/tc/q_sfb.c
index 05c5f13..136b8e9 100644
--- a/tc/q_sfb.c
+++ b/tc/q_sfb.c
@@ -49,7 +49,7 @@ static int get_prob(__u32 *val, const char *arg)
 }
 
 static int sfb_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-			 struct nlmsghdr *n)
+			 struct nlmsghdr *n, char *dev)
 {
 	struct tc_sfb_qopt opt = {
 		.rehash_interval = 600*1000,
diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index b5a9895..7c48e85 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -35,7 +35,7 @@ static void explain(void)
 	fprintf(stderr, "               [ ecn ] [ harddrop ]\n");
 }
 
-static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	int ok = 0, red = 0;
 	struct tc_sfq_qopt_v1 opt = {};
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index 18b2193..3b5af8f 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -36,7 +36,7 @@ static void explain1(const char *arg, const char *val)
 }
 
 
-static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	int ok = 0;
 	struct tc_tbf_qopt opt = {};
@@ -126,7 +126,12 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				fprintf(stderr, "tbf: duplicate \"rate\" specification\n");
 				return -1;
 			}
-			if (get_rate64(&rate64, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate64(&rate64, *argv, dev)) {
+					explain1("rate", *argv);
+					return -1;
+				}
+			} else if (get_rate64(&rate64, *argv)) {
 				explain1("rate", *argv);
 				return -1;
 			}
@@ -137,7 +142,12 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				fprintf(stderr, "tbf: duplicate \"peakrate\" specification\n");
 				return -1;
 			}
-			if (get_rate64(&prate64, *argv)) {
+			if (strchr(*argv, '%')) {
+				if (get_percent_rate64(&prate64, *argv, dev)) {
+					explain1("peakrate", *argv);
+					return -1;
+				}
+			} else if (get_rate64(&prate64, *argv)) {
 				explain1("peakrate", *argv);
 				return -1;
 			}
diff --git a/tc/tc.c b/tc/tc.c
index 8e64a82..83c775a 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -61,7 +61,7 @@ static int print_noqopt(struct qdisc_util *qu, FILE *f,
 	return 0;
 }
 
-static int parse_noqopt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int parse_noqopt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n, char *dev)
 {
 	if (argc) {
 		fprintf(stderr, "Unknown qdisc \"%s\", hence option \"%s\" is unparsable\n", qu->id, *argv);
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 0214775..6fbd217 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -129,7 +129,7 @@ static int tc_class_modify(int cmd, unsigned int flags, int argc, char **argv)
 			fprintf(stderr, "Error: Qdisc \"%s\" is classless.\n", k);
 			return 1;
 		}
-		if (q->parse_copt(q, argc, argv, &req.n))
+		if (q->parse_copt(q, argc, argv, &req.n, d))
 			return 1;
 	} else {
 		if (argc) {
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index c52114a..8f856b7 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -141,7 +141,7 @@ static int tc_qdisc_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 	if (q) {
 		if (q->parse_qopt) {
-			if (q->parse_qopt(q, argc, argv, &req.n))
+			if (q->parse_qopt(q, argc, argv, &req.n, d))
 				return 1;
 		} else if (argc) {
 			fprintf(stderr, "qdisc '%s' does not support option parsing\n", k);
diff --git a/tc/tc_util.c b/tc/tc_util.c
index b39e550..1cd22f4 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -191,6 +191,60 @@ static const struct rate_suffix {
 	{ NULL }
 };
 
+int parse_percent_rate(char *rate, const char *str, char *dev)
+{
+	long max_rate_bits;
+	int ret;
+	double perc, rate_bits;
+
+	if (!dev[0]) {
+		fprintf(stderr, "No device specified; specify device to rate limit by percentage\n");
+		return -1;
+	}
+
+	if (read_prop(dev, "speed", &max_rate_bits))
+		return -1;
+
+	ret = sscanf(str, "%lf%%", &perc);
+	if (ret != 1) {
+		fprintf(stderr, "Specified rate value could not be read or is malformed\n");
+		return -1;
+	}
+
+	if (perc > 100.0 || perc < 0.0) {
+		fprintf(stderr, "Invalid rate specified; should be between [0,100]%% but is %s\n", str);
+		return -1;
+	}
+
+	rate_bits = (perc * max_rate_bits) / 100.0;
+
+	ret = snprintf(rate, 20, "%lf", rate_bits);
+	if (ret <= 0 || ret >= 20) {
+		fprintf(stderr, "Unable to parse calculated rate\n");
+		return -1;
+	}
+
+	return 0;
+}
+int get_percent_rate(unsigned int *rate, const char *str, char *dev)
+{
+	char r_str[20];
+
+	if (parse_percent_rate(r_str, str, dev))
+		return -1;
+
+	return get_rate(rate, r_str);
+}
+
+int get_percent_rate64(__u64 *rate, const char *str, char *dev)
+{
+	char r_str[20];
+
+	if (parse_percent_rate(r_str, str, dev))
+		return -1;
+
+	return get_rate64(rate, r_str);
+}
 
 int get_rate(unsigned int *rate, const char *str)
 {
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 583a21a..e79b44e 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -24,14 +24,14 @@ struct qdisc_util {
 	struct  qdisc_util *next;
 	const char *id;
 	int (*parse_qopt)(struct qdisc_util *qu, int argc,
-			  char **argv, struct nlmsghdr *n);
+			  char **argv, struct nlmsghdr *n, char *dev);
 	int (*print_qopt)(struct qdisc_util *qu,
 			  FILE *f, struct rtattr *opt);
 	int (*print_xstats)(struct qdisc_util *qu,
 			    FILE *f, struct rtattr *xstats);
 
 	int (*parse_copt)(struct qdisc_util *qu, int argc,
-			  char **argv, struct nlmsghdr *n);
+			  char **argv, struct nlmsghdr *n, char *dev);
 	int (*print_copt)(struct qdisc_util *qu, FILE *f, struct rtattr *opt);
 };
 
@@ -66,9 +66,13 @@ const char *get_tc_lib(void);
 struct qdisc_util *get_qdisc_kind(const char *str);
 struct filter_util *get_filter_kind(const char *str);
 
+int read_prop(char *dev, char *prop, long *value);
+int parse_percent_rate(char *rate, const char *str, char *dev);
 int get_qdisc_handle(__u32 *h, const char *str);
 int get_rate(unsigned int *rate, const char *str);
+int get_percent_rate(unsigned int *rate, const char *str, char *dev);
 int get_rate64(__u64 *rate, const char *str);
+int get_percent_rate64(__u64 *rate, const char *str, char *dev);
 int get_size(unsigned int *size, const char *str);
 int get_size_and_cell(unsigned int *size, int *cell_log, char *str);
 int get_time(unsigned int *time, const char *str);
-- 
1.9.1
