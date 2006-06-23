From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 01/05]: Use tc_calc_xmittime where appropriate
Date: Fri, 23 Jun 2006 20:06:44 +0200 (MEST)
Message-ID: <20060623180644.13183.98204.sendpatchset@localhost.localdomain>
References: <20060623180642.13183.74864.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43189 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751839AbWFWSGq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 14:06:46 -0400
To: hemminger@osdl.org
In-Reply-To: <20060623180642.13183.74864.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Use tc_calc_xmittime where appropriate

Replace expressions of the form "1000000 * size/rate" by tc_calc_xmittime().
The CBQ case deserves an extra comment: when called with bnwd=rate
tc_cbq_calc_maxidle behaves identical to tc_calc_xmittime, so use it
for clarity.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c25b0a7730d72f266e46fee3cfd53ce9f2a15c2f
tree 39c6fbd3395e8a41170739d6cff8d3a00d31a915
parent 8f8a36487119a3cd1afe86a9649704aca088567b
author Patrick McHardy <kaber@trash.net> Fri, 23 Jun 2006 19:02:46 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 23 Jun 2006 19:02:46 +0200

 tc/q_cbq.c   |    2 +-
 tc/q_tbf.c   |    4 ++--
 tc/tc_core.c |    2 +-
 tc/tc_red.c  |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index a456eda..045c377 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -147,7 +147,7 @@ static int cbq_parse_opt(struct qdisc_ut
 	if (ewma_log < 0)
 		ewma_log = TC_CBQ_DEF_EWMA;
 	lss.ewma_log = ewma_log;
-	lss.maxidle = tc_cbq_calc_maxidle(r.rate, r.rate, avpkt, lss.ewma_log, 0);
+	lss.maxidle = tc_calc_xmittime(r.rate, avpkt);
 	lss.change = TCF_CBQ_LSS_MAXIDLE|TCF_CBQ_LSS_EWMA|TCF_CBQ_LSS_AVPKT;
 	lss.avpkt = avpkt;
 
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index 6ed5e0b..87b1b29 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -245,9 +245,9 @@ static int tbf_print_opt(struct qdisc_ut
 	if (show_raw)
 		fprintf(f, "limit %s ", sprint_size(qopt->limit, b1));
 
-	latency = 1000000*(qopt->limit/(double)qopt->rate.rate) - tc_core_tick2usec(qopt->buffer);
+	latency = tc_calc_xmittime(qopt->rate.rate, qopt->limit) - tc_core_tick2usec(qopt->buffer);
 	if (qopt->peakrate.rate) {
-		double lat2 = 1000000*(qopt->limit/(double)qopt->peakrate.rate) - tc_core_tick2usec(qopt->mtu);
+		double lat2 = tc_calc_xmittime(qopt->peakrate.rate, qopt->limit) - tc_core_tick2usec(qopt->mtu);
 		if (lat2 > latency)
 			latency = lat2;
 	}
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 07cf2fa..8688b63 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -67,7 +67,7 @@ int tc_calc_rtable(unsigned bps, __u32 *
 			sz += overhead;
 		if (sz < mpu)
 			sz = mpu;
-		rtab[i] = tc_core_usec2tick(1000000*((double)sz/bps));
+		rtab[i] = tc_calc_xmittime(bps, sz);
 	}
 	return cell_log;
 }
diff --git a/tc/tc_red.c b/tc/tc_red.c
index 385e7af..8f9bde0 100644
--- a/tc/tc_red.c
+++ b/tc/tc_red.c
@@ -71,7 +71,7 @@ int tc_red_eval_ewma(unsigned qmin, unsi
 
 int tc_red_eval_idle_damping(int Wlog, unsigned avpkt, unsigned bps, __u8 *sbuf)
 {
-	double xmit_time = tc_core_usec2tick(1000000*(double)avpkt/bps);
+	double xmit_time = tc_calc_xmittime(bps, avpkt);
 	double lW = -log(1.0 - 1.0/(1<<Wlog))/xmit_time;
 	double maxtime = 31/lW;
 	int clog;
