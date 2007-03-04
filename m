From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE 02/08]: Use tc_calc_xmittime() where appropriate
Date: Sun,  4 Mar 2007 20:14:56 +0100 (MET)
Message-ID: <20070304191405.22838.87758.sendpatchset@localhost.localdomain>
References: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61726 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbXCDTO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:14:57 -0500
In-Reply-To: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Use tc_calc_xmittime() where appropriate

Replace expressions of the form "tc_core_usec2tick(1000000 * size/rate)"
by tc_calc_xmittime().

The CBQ case deserves an extra comment: when called with bnwd=rate,
tc_cbq_calc_maxidle() behaves identical to tc_calc_xmittime():

unsigned tc_cbq_calc_maxidle(...)
{
	double g = 1.0 - 1.0/(1<<ewma_log);
	double xmt = (double)avpkt/bndw;

	maxidle = xmt*(1-g);
	if (bndw != rate && maxburst) {
		...
	}
	return tc_core_usec2tick(maxidle*(1<<ewma_log)*1000000);
}

which comes down to:

maxidle	= xmt * (1 - g)
	= xmt * (1 - (1.0 - 1.0/(1 << ewma_log))
	= xmt * (1.0/(1 << ewma_log))

so:

maxidle * (1 << ewma_log) * 1000000
	= xmt * (1.0/(1 << ewma_log)) * (1 << ewma_log) * 1000000
	= xmt * 1000000
	= avpkt/bndw * 1000000

Which means tc_core_usec2tick(maxidle*(1<<ewma_log)*1000000) is identical
to tc_calc_xmittime(bndw, avpkt). Use it directly since its a lot easier
to understand its limits.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a367af8046d31e986740aac45677c8fe8910c293
tree 056436a16da372e602f43259609e54bb3e7dce16
parent b17ff630348093476b7679b421aba1797f3d6466
author Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:47 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:47 +0100

 tc/q_cbq.c   |    2 +-
 tc/tc_core.c |    2 +-
 tc/tc_red.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index bc7e8ba..0000a56 100644
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
 
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 10c375e..90a097d 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -76,7 +76,7 @@ int tc_calc_rtable(unsigned bps, __u32 *
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
