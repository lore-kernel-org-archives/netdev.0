From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] red: make burst optional
Date: Thu, 01 Dec 2011 15:25:59 +0100
Message-ID: <1322749559.2335.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1322688891.2602.15.camel@edumazet-laptop>
	 <1322689213.2602.18.camel@edumazet-laptop>
	 <1322691053.2602.24.camel@edumazet-laptop>
	 <CAA93jw7TZj3Gd-KiVwr3Qwta4RpDKKV9QxGc+fyGc_+-9r1tLw@mail.gmail.com>
	 <1322693086.2602.28.camel@edumazet-laptop>
	 <1322737471.2335.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55986 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361Ab1LAO0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 09:26:03 -0500
Received: by faaq16 with SMTP id q16so1300192faa.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 06:26:02 -0800 (PST)
In-Reply-To: <1322737471.2335.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation advises to set burst to (min+min+max)/(3*avpkt)

Let tc do this automatically if user doesnt provide burst himself.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 tc/q_choke.c |    2 +-
 tc/q_gred.c  |   10 +++++++---
 tc/q_red.c   |   11 +++++++----
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/tc/q_choke.c b/tc/q_choke.c
index 04a864f..7816f62 100644
--- a/tc/q_choke.c
+++ b/tc/q_choke.c
@@ -133,7 +133,7 @@ static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		return -1;
 	}
 	if (wlog >= 10)
-		fprintf(stderr, "CHOKE: WARNING. Burst %d seems to be to large.\n", burst);
+		fprintf(stderr, "CHOKE: WARNING. Burst %d seems to be too large.\n", burst);
 	opt.Wlog = wlog;
 
 	wlog = tc_red_eval_P(opt.qth_min*avpkt, opt.qth_max*avpkt, probability);
diff --git a/tc/q_gred.c b/tc/q_gred.c
index 59651d3..5fa0cc7 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -215,19 +215,23 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	if (rate == 0)
 		get_rate(&rate, "10Mbit");
 
-	if (!opt.qth_min || !opt.qth_max || !burst || !opt.limit || !avpkt ||
+	if (!opt.qth_min || !opt.qth_max || !opt.limit || !avpkt ||
 	    (opt.DP<0)) {
-		fprintf(stderr, "Required parameter (min, max, burst, limit, "
+		fprintf(stderr, "Required parameter (min, max, limit, "
 		    "avpkt, DP) is missing\n");
 		return -1;
 	}
+	if (!burst) {
+		burst = (2 * opt.qth_min + opt.qth_max) / (3 * avpkt);
+		fprintf(stderr, "GRED: set burst to %u\n", burst);
+	}
 
 	if ((wlog = tc_red_eval_ewma(opt.qth_min, burst, avpkt)) < 0) {
 		fprintf(stderr, "GRED: failed to calculate EWMA constant.\n");
 		return -1;
 	}
 	if (wlog >= 10)
-		fprintf(stderr, "GRED: WARNING. Burst %d seems to be to "
+		fprintf(stderr, "GRED: WARNING. Burst %d seems to be too "
 		    "large.\n", burst);
 	opt.Wlog = wlog;
 	if ((wlog = tc_red_eval_P(opt.qth_min, opt.qth_max, probability)) < 0) {
diff --git a/tc/q_red.c b/tc/q_red.c
index 4b1b889..6e58d7a 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -104,17 +104,20 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	if (rate == 0)
 		get_rate(&rate, "10Mbit");
 
-	if (!opt.qth_min || !opt.qth_max || !burst || !opt.limit || !avpkt) {
-		fprintf(stderr, "Required parameter (min, max, burst, limit, avpkt) is missing\n");
+	if (!opt.qth_min || !opt.qth_max || !opt.limit || !avpkt) {
+		fprintf(stderr, "RED: Required parameter (min, max, limit, avpkt) is missing\n");
 		return -1;
 	}
-
+	if (!burst) {
+		burst = (2 * opt.qth_min + opt.qth_max) / (3 * avpkt);
+		fprintf(stderr, "RED: set burst to %u\n", burst);
+	}
 	if ((wlog = tc_red_eval_ewma(opt.qth_min, burst, avpkt)) < 0) {
 		fprintf(stderr, "RED: failed to calculate EWMA constant.\n");
 		return -1;
 	}
 	if (wlog >= 10)
-		fprintf(stderr, "RED: WARNING. Burst %d seems to be to large.\n", burst);
+		fprintf(stderr, "RED: WARNING. Burst %d seems to be too large.\n", burst);
 	opt.Wlog = wlog;
 	if ((wlog = tc_red_eval_P(opt.qth_min, opt.qth_max, probability)) < 0) {
 		fprintf(stderr, "RED: failed to calculate probability.\n");
