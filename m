From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 01/05]: Use tc_calc_xmittime where appropriate
Date: Wed, 10 Jan 2007 11:01:45 +0100 (MET)
Message-ID: <20070110100144.29356.52367.sendpatchset@localhost.localdomain>
References: <20070110100143.29356.98344.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63778 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964817AbXAJKBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 05:01:46 -0500
To: shemminger@osdl.org
In-Reply-To: <20070110100143.29356.98344.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Use tc_calc_xmittime where appropriate

Replace expressions of the form "1000000 * size/rate" by tc_calc_xmittime().
The CBQ case deserves an extra comment: when called with bnwd=rate
tc_cbq_calc_maxidle behaves identical to tc_calc_xmittime, so use it
for clarity.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d786eedd7b3e9ceb381ee602efcbe002afc7be73
tree 4db59786df1da875f9c3956000496dd8455d5af6
parent 40076f622e0aacb2b792d3ac1b5d12aa97c4da9c
author Patrick McHardy <kaber@trash.net> Wed, 10 Jan 2007 10:40:05 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 10 Jan 2007 10:40:05 +0100

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
