From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] htb: support 64bit rates
Date: Tue, 12 Nov 2013 14:34:07 -0800
Message-ID: <1384295647.28458.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:63323 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864Ab3KLWeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 17:34:09 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so1339555pbb.28
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 14:34:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Starting from linux-3.13, we can break the 32bit limitation of
rates on HTB qdisc/classes.

Prior limit was 34.359.738.360 bits per second.

lpq83:~# tc -s qdisc show dev lo ; tc -s class show dev lo
qdisc htb 1: root refcnt 2 r2q 2000 default 1 direct_packets_stat 0 direct_qlen 6000
 Sent 6591936144493 bytes 149549182 pkt (dropped 0, overlimits 213757419 requeues 0) 
 rate 39464Mbit 114938pps backlog 0b 15p requeues 0 
class htb 1:1 root prio 0 rate 50000Mbit ceil 50000Mbit burst 200000b cburst 0b 
 Sent 6591942184547 bytes 149549310 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 39464Mbit 114938pps backlog 0b 15p requeues 0 
 lended: 149549310 borrowed: 0 giants: 0
 tokens: 336 ctokens: -164

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/q_htb.c   |   56 ++++++++++++++++++++++++++++++++++++-------------
 tc/tc_core.c |    6 ++---
 tc/tc_core.h |    4 +--
 tc/tc_util.c |   27 ++++++++++++++++++++++-
 tc/tc_util.h |    1 
 5 files changed, 74 insertions(+), 20 deletions(-)

diff --git a/tc/q_htb.c b/tc/q_htb.c
index e108857..1d8c56f 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -113,6 +113,7 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	unsigned int direct_qlen = ~0U;
 	unsigned int linklayer  = LINKLAYER_ETHERNET; /* Assume ethernet */
 	struct rtattr *tail;
+	__u64 ceil64 = 0, rate64 = 0;
 
 	memset(&opt, 0, sizeof(opt)); mtu = 1600; /* eth packet len */
 
@@ -173,22 +174,22 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 			ok++;
 		} else if (strcmp(*argv, "ceil") == 0) {
 			NEXT_ARG();
-			if (opt.ceil.rate) {
+			if (ceil64) {
 				fprintf(stderr, "Double \"ceil\" spec\n");
 				return -1;
 			}
-			if (get_rate(&opt.ceil.rate, *argv)) {
+			if (get_rate64(&ceil64, *argv)) {
 				explain1("ceil");
 				return -1;
 			}
 			ok++;
 		} else if (strcmp(*argv, "rate") == 0) {
 			NEXT_ARG();
-			if (opt.rate.rate) {
+			if (rate64) {
 				fprintf(stderr, "Double \"rate\" spec\n");
 				return -1;
 			}
-			if (get_rate(&opt.rate.rate, *argv)) {
+			if (get_rate64(&rate64, *argv)) {
 				explain1("rate");
 				return -1;
 			}
@@ -207,17 +208,23 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	/*	if (!ok)
 		return 0;*/
 
-	if (opt.rate.rate == 0) {
+	if (!rate64) {
 		fprintf(stderr, "\"rate\" is required.\n");
 		return -1;
 	}
 	/* if ceil params are missing, use the same as rate */
-	if (!opt.ceil.rate) opt.ceil = opt.rate;
+	if (!ceil64)
+		ceil64 = rate64;
+
+	opt.rate.rate = (rate64 >= (1ULL << 32)) ? ~0U : rate64;
+	opt.ceil.rate = (ceil64 >= (1ULL << 32)) ? ~0U : ceil64;
 
 	/* compute minimal allowed burst from rate; mtu is added here to make
 	   sute that buffer is larger than mtu and to have some safeguard space */
-	if (!buffer) buffer = opt.rate.rate / get_hz() + mtu;
-	if (!cbuffer) cbuffer = opt.ceil.rate / get_hz() + mtu;
+	if (!buffer)
+		buffer = rate64 / get_hz() + mtu;
+	if (!cbuffer)
+		cbuffer = ceil64 / get_hz() + mtu;
 
 	opt.ceil.overhead = overhead;
 	opt.rate.overhead = overhead;
@@ -229,19 +236,26 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 		fprintf(stderr, "htb: failed to calculate rate table.\n");
 		return -1;
 	}
-	opt.buffer = tc_calc_xmittime(opt.rate.rate, buffer);
+	opt.buffer = tc_calc_xmittime(rate64, buffer);
 
 	if (tc_calc_rtable(&opt.ceil, ctab, ccell_log, mtu, linklayer) < 0) {
 		fprintf(stderr, "htb: failed to calculate ceil rate table.\n");
 		return -1;
 	}
-	opt.cbuffer = tc_calc_xmittime(opt.ceil.rate, cbuffer);
+	opt.cbuffer = tc_calc_xmittime(ceil64, cbuffer);
 
 	tail = NLMSG_TAIL(n);
 	if (direct_qlen != ~0U)
 		addattr_l(n, 1024, TCA_HTB_DIRECT_QLEN,
 			  &direct_qlen, sizeof(direct_qlen));
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
+
+	if (rate64 >= (1ULL << 32))
+		addattr_l(n, 1124, TCA_HTB_RATE64, &rate64, sizeof(rate64));
+
+	if (ceil64 >= (1ULL << 32))
+		addattr_l(n, 1224, TCA_HTB_CEIL64, &ceil64, sizeof(ceil64));
+
 	addattr_l(n, 2024, TCA_HTB_PARMS, &opt, sizeof(opt));
 	addattr_l(n, 3024, TCA_HTB_RTAB, rtab, 1024);
 	addattr_l(n, 4024, TCA_HTB_CTAB, ctab, 1024);
@@ -256,6 +270,7 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	struct tc_htb_glob *gopt;
 	double buffer,cbuffer;
 	unsigned int linklayer;
+	__u64 rate64, ceil64;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
 	SPRINT_BUF(b3);
@@ -275,12 +290,25 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 			if (show_details)
 				fprintf(f, "quantum %d ", (int)hopt->quantum);
 		}
-		fprintf(f, "rate %s ", sprint_rate(hopt->rate.rate, b1));
+
+		rate64 = hopt->rate.rate;
+		if (tb[TCA_HTB_RATE64] &&
+		    RTA_PAYLOAD(tb[TCA_HTB_RATE64]) >= sizeof(rate64)) {
+			rate64 = rta_getattr_u64(tb[TCA_HTB_RATE64]);
+		}
+
+		ceil64 = hopt->ceil.rate;
+		if (tb[TCA_HTB_CEIL64] &&
+		    RTA_PAYLOAD(tb[TCA_HTB_CEIL64]) >= sizeof(ceil64))
+			ceil64 = rta_getattr_u64(tb[TCA_HTB_CEIL64]);
+
+		fprintf(f, "rate %s ", sprint_rate(rate64, b1));
 		if (hopt->rate.overhead)
 			fprintf(f, "overhead %u ", hopt->rate.overhead);
-		buffer = tc_calc_xmitsize(hopt->rate.rate, hopt->buffer);
-		fprintf(f, "ceil %s ", sprint_rate(hopt->ceil.rate, b1));
-		cbuffer = tc_calc_xmitsize(hopt->ceil.rate, hopt->cbuffer);
+		buffer = tc_calc_xmitsize(rate64, hopt->buffer);
+
+		fprintf(f, "ceil %s ", sprint_rate(ceil64, b1));
+		cbuffer = tc_calc_xmitsize(ceil64, hopt->cbuffer);
 		linklayer = (hopt->rate.linklayer & TC_LINKLAYER_MASK);
 		if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
 			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b4));
diff --git a/tc/tc_core.c b/tc/tc_core.c
index a524337..46eaefb 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -56,12 +56,12 @@ unsigned tc_core_ktime2time(unsigned ktime)
 	return ktime / clock_factor;
 }
 
-unsigned tc_calc_xmittime(unsigned rate, unsigned size)
+unsigned tc_calc_xmittime(__u64 rate, unsigned size)
 {
-	return tc_core_time2tick(TIME_UNITS_PER_SEC*((double)size/rate));
+	return tc_core_time2tick(TIME_UNITS_PER_SEC*((double)size/(double)rate));
 }
 
-unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
+unsigned tc_calc_xmitsize(__u64 rate, unsigned ticks)
 {
 	return ((double)rate*tc_core_tick2time(ticks))/TIME_UNITS_PER_SEC;
 }
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 5a693ba..8a63b79 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -18,8 +18,8 @@ unsigned tc_core_time2tick(unsigned time);
 unsigned tc_core_tick2time(unsigned tick);
 unsigned tc_core_time2ktime(unsigned time);
 unsigned tc_core_ktime2time(unsigned ktime);
-unsigned tc_calc_xmittime(unsigned rate, unsigned size);
-unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
+unsigned tc_calc_xmittime(__u64 rate, unsigned size);
+unsigned tc_calc_xmitsize(__u64 rate, unsigned ticks);
 int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 		   int cell_log, unsigned mtu, enum link_layer link_layer);
 int tc_calc_size_table(struct tc_sizespec *s, __u16 **stab);
diff --git a/tc/tc_util.c b/tc/tc_util.c
index be3ed07..808c768 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -171,6 +171,31 @@ int get_rate(unsigned *rate, const char *str)
 	return 0;
 }
 
+int get_rate64(__u64 *rate, const char *str)
+{
+	char *p;
+	double bps = strtod(str, &p);
+	const struct rate_suffix *s;
+
+	if (p == str)
+		return -1;
+
+	for (s = suffixes; s->name; ++s) {
+		if (strcasecmp(s->name, p) == 0) {
+			bps *= s->scale;
+			p += strlen(p);
+			break;
+		}
+	}
+
+	if (*p)
+		return -1; /* unknown suffix */
+
+	bps /= 8; /* -> bytes per second */
+	*rate = bps;
+	return 0;
+}
+
 void print_rate(char *buf, int len, __u64 rate)
 {
 	double tmp = (double)rate*8;
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 7c3709f..d418367 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -58,6 +58,7 @@ extern struct filter_util *get_filter_kind(const char *str);
 
 extern int get_qdisc_handle(__u32 *h, const char *str);
 extern int get_rate(unsigned *rate, const char *str);
+extern int get_rate64(__u64 *rate, const char *str);
 extern int get_size(unsigned *size, const char *str);
 extern int get_size_and_cell(unsigned *size, int *cell_log, char *str);
 extern int get_time(unsigned *time, const char *str);
