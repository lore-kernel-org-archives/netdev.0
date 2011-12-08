From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] red: harddrop support and cleanups
Date: Fri, 09 Dec 2011 00:11:40 +0100
Message-ID: <1323385900.2529.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38926 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab1LHXLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 18:11:47 -0500
Received: by eaak14 with SMTP id k14so1450859eaa.19
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2011 15:11:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add harddrop support (kernel support added a long time ago), and various
cleanups.

min BYTES, max BYTES are now optional and follow Sally Floyd's
recommendations.

By the way, our default 2% probability is a bit low, Sally recommends
10%.
Not a big deal if upcoming adaptative algo is deployed.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 tc/q_red.c |   41 ++++++++++++++++++++---------------------
 1 file changed, 20 insertions(+), 21 deletions(-)

diff --git a/tc/q_red.c b/tc/q_red.c
index 6e58d7a..90c8573 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -27,8 +27,8 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... red limit BYTES min BYTES max BYTES avpkt BYTES burst PACKETS\n");
-	fprintf(stderr, "               probability PROBABILITY bandwidth KBPS [ ecn ]\n");
+	fprintf(stderr, "Usage: ... red limit BYTES [min BYTES] [max BYTES] avpkt BYTES [burst PACKETS]\n");
+	fprintf(stderr, "               [probability PROBABILITY] bandwidth KBPS [ecn] [harddrop]\n");
 }
 
 static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
@@ -38,7 +38,6 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	unsigned avpkt = 0;
 	double probability = 0.02;
 	unsigned rate = 0;
-	int ecn_ok = 0;
 	int wlog;
 	__u8 sbuf[256];
 	struct rtattr *tail;
@@ -89,7 +88,9 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				return -1;
 			}
 		} else if (strcmp(*argv, "ecn") == 0) {
-			ecn_ok = 1;
+			opt.flags |= TC_RED_ECN;
+		} else if (strcmp(*argv, "harddrop") == 0) {
+			opt.flags |= TC_RED_HARDDROP;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -104,14 +105,20 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	if (rate == 0)
 		get_rate(&rate, "10Mbit");
 
-	if (!opt.qth_min || !opt.qth_max || !opt.limit || !avpkt) {
-		fprintf(stderr, "RED: Required parameter (min, max, limit, avpkt) is missing\n");
+	if (!opt.limit || !avpkt) {
+		fprintf(stderr, "RED: Required parameter (limit, avpkt) is missing\n");
 		return -1;
 	}
-	if (!burst) {
+	/* Compute default min/max thresholds based on 
+	 * Sally Floyd's recommendations:
+	 * http://www.icir.org/floyd/REDparameters.txt
+	 */
+	if (!opt.qth_max) 
+		opt.qth_max = opt.qth_min ? opt.qth_min * 3 : opt.limit / 4;
+	if (!opt.qth_min)
+		opt.qth_min = opt.qth_max / 3;
+	if (!burst)
 		burst = (2 * opt.qth_min + opt.qth_max) / (3 * avpkt);
-		fprintf(stderr, "RED: set burst to %u\n", burst);
-	}
 	if ((wlog = tc_red_eval_ewma(opt.qth_min, burst, avpkt)) < 0) {
 		fprintf(stderr, "RED: failed to calculate EWMA constant.\n");
 		return -1;
@@ -129,14 +136,6 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		return -1;
 	}
 	opt.Scell_log = wlog;
-	if (ecn_ok) {
-#ifdef TC_RED_ECN
-		opt.flags |= TC_RED_ECN;
-#else
-		fprintf(stderr, "RED: ECN support is missing in this binary.\n");
-		return -1;
-#endif
-	}
 
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
@@ -148,7 +147,7 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 
 static int red_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
-	struct rtattr *tb[TCA_RED_STAB+1];
+	struct rtattr *tb[TCA_RED_MAX + 1];
 	struct tc_red_qopt *qopt;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
@@ -157,7 +156,7 @@ static int red_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (opt == NULL)
 		return 0;
 
-	parse_rtattr_nested(tb, TCA_RED_STAB, opt);
+	parse_rtattr_nested(tb, TCA_RED_MAX, opt);
 
 	if (tb[TCA_RED_PARMS] == NULL)
 		return -1;
@@ -168,10 +167,10 @@ static int red_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		sprint_size(qopt->limit, b1),
 		sprint_size(qopt->qth_min, b2),
 		sprint_size(qopt->qth_max, b3));
-#ifdef TC_RED_ECN
 	if (qopt->flags & TC_RED_ECN)
 		fprintf(f, "ecn ");
-#endif
+	if (qopt->flags & TC_RED_HARDDROP)
+		fprintf(f, "harddrop ");
 	if (show_details) {
 		fprintf(f, "ewma %u Plog %u Scell_log %u",
 			qopt->Wlog, qopt->Plog, qopt->Scell_log);
