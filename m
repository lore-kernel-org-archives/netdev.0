From: "Sergey V. Lobanov" <sergey@lobanov.in>
Subject: [PATCH iproute2] Fixed 'tc qdisc show' for tbf when latency<0
Date: Sun, 11 May 2014 03:01:14 +0400
Message-ID: <1399762874-17902-1-git-send-email-sergey@lobanov.in>
Cc: "Sergey V. Lobanov" <sergey@lobanov.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward12.mail.yandex.net ([95.108.130.94]:54429 "EHLO
	forward12.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbaEJXC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 19:02:26 -0400
Received: from smtp12.mail.yandex.net (smtp12.mail.yandex.net [95.108.131.191])
	by forward12.mail.yandex.net (Yandex) with ESMTP id B4DB5C213CB
	for <netdev@vger.kernel.org>; Sun, 11 May 2014 03:02:23 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When limit<burst latency becomes <0, for example:
 # tc qdisc add dev eth0 root handle 1: tbf limit 100K burst 256K rate 256kbit
 # tc qdisc show
 qdisc tbf 1: dev eth0 root refcnt 2 rate 256Kbit burst 256Kb lat 4290.0s

If latency<0 there is no reason to show it. Limit will be printed instead of
latency when latency<0:
 # tc qdisc show
 qdisc tbf 1: dev eth0 root refcnt 2 rate 256Kbit burst 256Kb limit 100Kb

Signed-off-by: Sergey V. Lobanov <sergey@lobanov.in>
---
 tc/q_tbf.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index f3022b6..2d56331 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -302,16 +302,16 @@ static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		}
 	}
 
-	if (show_raw)
-		fprintf(f, "limit %s ", sprint_size(qopt->limit, b1));
-
 	latency = TIME_UNITS_PER_SEC*(qopt->limit/(double)rate64) - tc_core_tick2time(qopt->buffer);
 	if (prate64) {
 		double lat2 = TIME_UNITS_PER_SEC*(qopt->limit/(double)prate64) - tc_core_tick2time(qopt->mtu);
 		if (lat2 > latency)
 			latency = lat2;
 	}
-	fprintf(f, "lat %s ", sprint_time(latency, b1));
+	if (latency >= 0.0)
+		fprintf(f, "lat %s ", sprint_time(latency, b1));
+	if (show_raw || latency < 0.0)
+		fprintf(f, "limit %s ", sprint_size(qopt->limit, b1));
 
 	if (qopt->rate.overhead) {
 		fprintf(f, "overhead %d", qopt->rate.overhead);
-- 
1.9.1
