From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] htb: add support for direct_qlen attribute
Date: Fri, 13 Sep 2013 08:30:35 -0700
Message-ID: <1379086235.24408.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:41167 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767Ab3IMPaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 11:30:39 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf1so2658178pab.38
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 08:30:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCA_HTB_DIRECT_QLEN attribute is supported since linux-3.10

HTB classes use an internal pfifo queue, which limit was not reported
by tc, and value inherited from device tx_queue_len at setup time.
    
With this patch, tc displays the value and can change it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 tc/q_htb.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/tc/q_htb.c b/tc/q_htb.c
index 7b6f908..0e878d4 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -37,6 +37,7 @@ static void explain(void)
 		"... class add ... htb rate R1 [burst B1] [mpu B] [overhead O]\n"
 		"                      [prio P] [slot S] [pslot PS]\n"
 		"                      [ceil R2] [cburst B2] [mtu MTU] [quantum Q]\n"
+		"                      [direct_qlen L]\n"
 		" rate     rate allocated to this class (class can still borrow)\n"
 		" burst    max bytes burst which can be accumulated during idle period {computed}\n"
 		" mpu      minimum packet size used in rate computations\n"
@@ -47,6 +48,7 @@ static void explain(void)
 		" mtu      max packet size we create rate map for {1600}\n"
 		" prio     priority of leaf; lower are served first {0}\n"
 		" quantum  how much bytes to serve from leaf at once {use r2q}\n"
+		" direct_qlen  Limit of the direct queue {in packets}\n"
 		"\nTC HTB version %d.%d\n",HTB_TC_VER>>16,HTB_TC_VER&0xffff
 		);
 }
@@ -108,6 +110,7 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	unsigned mtu;
 	unsigned short mpu = 0;
 	unsigned short overhead = 0;
+	unsigned int direct_qlen = ~0U;
 	unsigned int linklayer  = LINKLAYER_ETHERNET; /* Assume ethernet */
 	struct rtattr *tail;
 
@@ -125,6 +128,11 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 			if (get_u32(&mtu, *argv, 10)) {
 				explain1("mtu"); return -1;
 			}
+		} else if (matches(*argv, "direct_qlen") == 0) {
+			NEXT_ARG();
+			if (get_u32(&direct_qlen, *argv, 10)) {
+				explain1("direct_qlen"); return -1;
+			}
 		} else if (matches(*argv, "mpu") == 0) {
 			NEXT_ARG();
 			if (get_u16(&mpu, *argv, 10)) {
@@ -230,6 +238,9 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	opt.cbuffer = tc_calc_xmittime(opt.ceil.rate, cbuffer);
 
 	tail = NLMSG_TAIL(n);
+	if (direct_qlen != ~0U)
+		addattr_l(n, 1024, TCA_HTB_DIRECT_QLEN,
+			  &direct_qlen, sizeof(direct_qlen));
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	addattr_l(n, 2024, TCA_HTB_PARMS, &opt, sizeof(opt));
 	addattr_l(n, 3024, TCA_HTB_RTAB, rtab, 1024);
@@ -240,7 +251,7 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 
 static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
-	struct rtattr *tb[TCA_HTB_RTAB+1];
+	struct rtattr *tb[TCA_HTB_MAX + 1];
 	struct tc_htb_opt *hopt;
 	struct tc_htb_glob *gopt;
 	double buffer,cbuffer;
@@ -253,7 +264,7 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (opt == NULL)
 		return 0;
 
-	parse_rtattr_nested(tb, TCA_HTB_RTAB, opt);
+	parse_rtattr_nested(tb, TCA_HTB_MAX, opt);
 
 	if (tb[TCA_HTB_PARMS]) {
 		hopt = RTA_DATA(tb[TCA_HTB_PARMS]);
@@ -302,6 +313,12 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		if (show_details)
 			fprintf(f," ver %d.%d",gopt->version >> 16,gopt->version & 0xffff);
 	}
+	if (tb[TCA_HTB_DIRECT_QLEN] &&
+	    RTA_PAYLOAD(tb[TCA_HTB_DIRECT_QLEN]) >= sizeof(__u32)) {
+		__u32 direct_qlen = rta_getattr_u32(tb[TCA_HTB_DIRECT_QLEN]);
+
+		fprintf(f, " direct_qlen %u", direct_qlen);
+	}
 	return 0;
 }
 
