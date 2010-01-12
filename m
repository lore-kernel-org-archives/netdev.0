From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 3/5] tc: red, gred, tbf: more helpful error messages
Date: Tue, 12 Jan 2010 21:44:29 +0100
Message-ID: <1263329071-19657-1-git-send-email-fw@strlen.de>
References: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Cc: shemminger@vyatta.com, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:54389 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752312Ab0ALUpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:45:12 -0500
In-Reply-To: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

$ tc qdisc add dev eth1 root tbf
RTNETLINK answers: Invalid argument

$ tc qdisc add dev eth1 root red
RTNETLINK answers: Invalid argument

with patch:
$ tc qdisc add dev eth1 root red
Required parameter (min, max, burst, limit, avpkt) is missing

$ tc qdisc add dev eth1 root tbf
Usage: ... tbf limit BYTES burst BYTES[/BYTES] rate KBPS ...

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 tc/q_gred.c |    5 +----
 tc/q_red.c  |   14 +-------------
 tc/q_tbf.c  |    6 ++++--
 3 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index ecef42e..ab26801 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -215,16 +215,13 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 		argc--; argv++;
 	}
 
-	if (!ok)
-		return 0;
-
 	if (rate == 0)
 		get_rate(&rate, "10Mbit");
 
 	if (!opt.qth_min || !opt.qth_max || !burst || !opt.limit || !avpkt ||
 	    (opt.DP<0)) {
 		fprintf(stderr, "Required parameter (min, max, burst, limit, "
-		    "avpket, DP) is missing\n");
+		    "avpkt, DP) is missing\n");
 		return -1;
 	}
 
diff --git a/tc/q_red.c b/tc/q_red.c
index 6f93b26..3ba6bc7 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -35,7 +35,6 @@ static void explain(void)
 
 static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
-	int ok=0;
 	struct tc_red_qopt opt;
 	unsigned burst = 0;
 	unsigned avpkt = 0;
@@ -55,52 +54,44 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				fprintf(stderr, "Illegal \"limit\"\n");
 				return -1;
 			}
-			ok++;
 		} else if (strcmp(*argv, "min") == 0) {
 			NEXT_ARG();
 			if (get_size(&opt.qth_min, *argv)) {
 				fprintf(stderr, "Illegal \"min\"\n");
 				return -1;
 			}
-			ok++;
 		} else if (strcmp(*argv, "max") == 0) {
 			NEXT_ARG();
 			if (get_size(&opt.qth_max, *argv)) {
 				fprintf(stderr, "Illegal \"max\"\n");
 				return -1;
 			}
-			ok++;
 		} else if (strcmp(*argv, "burst") == 0) {
 			NEXT_ARG();
 			if (get_unsigned(&burst, *argv, 0)) {
 				fprintf(stderr, "Illegal \"burst\"\n");
 				return -1;
 			}
-			ok++;
 		} else if (strcmp(*argv, "avpkt") == 0) {
 			NEXT_ARG();
 			if (get_size(&avpkt, *argv)) {
 				fprintf(stderr, "Illegal \"avpkt\"\n");
 				return -1;
 			}
-			ok++;
 		} else if (strcmp(*argv, "probability") == 0) {
 			NEXT_ARG();
 			if (sscanf(*argv, "%lg", &probability) != 1) {
 				fprintf(stderr, "Illegal \"probability\"\n");
 				return -1;
 			}
-			ok++;
 		} else if (strcmp(*argv, "bandwidth") == 0) {
 			NEXT_ARG();
 			if (get_rate(&rate, *argv)) {
 				fprintf(stderr, "Illegal \"bandwidth\"\n");
 				return -1;
 			}
-			ok++;
 		} else if (strcmp(*argv, "ecn") == 0) {
 			ecn_ok = 1;
-			ok++;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -112,14 +103,11 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		argc--; argv++;
 	}
 
-	if (!ok)
-		return 0;
-
 	if (rate == 0)
 		get_rate(&rate, "10Mbit");
 
 	if (!opt.qth_min || !opt.qth_max || !burst || !opt.limit || !avpkt) {
-		fprintf(stderr, "Required parameter (min, max, burst, limit, avpket) is missing\n");
+		fprintf(stderr, "Required parameter (min, max, burst, limit, avpkt) is missing\n");
 		return -1;
 	}
 
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index dbf9586..06ccda3 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -158,8 +158,10 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		argc--; argv++;
 	}
 
-	if (!ok)
-		return 0;
+	if (!ok) {
+		explain();
+		return -1;
+	}
 
 	if (opt.rate.rate == 0 || !buffer) {
 		fprintf(stderr, "Both \"rate\" and \"burst\" are required.\n");
-- 
1.6.4.4

