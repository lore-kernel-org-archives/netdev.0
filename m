From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE 03/08]: Introduce tc_calc_xmitsize and use where appropriate
Date: Sun,  4 Mar 2007 20:14:57 +0100 (MET)
Message-ID: <20070304191406.22838.6859.sendpatchset@localhost.localdomain>
References: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61729 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbXCDTO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:14:59 -0500
In-Reply-To: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Introduce tc_calc_xmitsize and use where appropriate

Add tc_calc_xmitsize() as complement to tc_calc_xmittime(), which calculates
the size that can be transmitted at a given rate during a given time.

Replace all expressions of the form "size = rate*tc_core_tick2usec(time))/1000000"
by tc_calc_xmitsize() calls.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8b41013e2abb8eb6d3c960911d2ce137b40ccd50
tree 85068a3019ad77563ae82b9277bd13f3a6de19ba
parent a367af8046d31e986740aac45677c8fe8910c293
author Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100

 tc/m_police.c |    2 +-
 tc/q_htb.c    |    4 ++--
 tc/q_tbf.c    |    4 ++--
 tc/tc_core.c  |    5 +++++
 tc/tc_core.h  |    1 +
 5 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/tc/m_police.c b/tc/m_police.c
index 93f317c..36a7719 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -331,7 +331,7 @@ #endif
 
 	fprintf(f, " police 0x%x ", p->index);
 	fprintf(f, "rate %s ", sprint_rate(p->rate.rate, b1));
-	buffer = ((double)p->rate.rate*tc_core_tick2usec(p->burst))/1000000;
+	buffer = tc_calc_xmitsize(p->rate.rate, p->burst);
 	fprintf(f, "burst %s ", sprint_size(buffer, b1));
 	fprintf(f, "mtu %s ", sprint_size(p->mtu, b1));
 	if (show_raw)
diff --git a/tc/q_htb.c b/tc/q_htb.c
index d5f85c3..53e3f78 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -259,9 +259,9 @@ static int htb_print_opt(struct qdisc_ut
 				fprintf(f, "quantum %d ", (int)hopt->quantum);
 		}
 	    fprintf(f, "rate %s ", sprint_rate(hopt->rate.rate, b1));
-	    buffer = ((double)hopt->rate.rate*tc_core_tick2usec(hopt->buffer))/1000000;
+	    buffer = tc_calc_xmitsize(hopt->rate.rate, hopt->buffer);
 	    fprintf(f, "ceil %s ", sprint_rate(hopt->ceil.rate, b1));
-	    cbuffer = ((double)hopt->ceil.rate*tc_core_tick2usec(hopt->cbuffer))/1000000;
+	    cbuffer = tc_calc_xmitsize(hopt->ceil.rate, hopt->cbuffer);
 	    if (show_details) {
 		fprintf(f, "burst %s/%u mpu %s overhead %s ",
 			sprint_size(buffer, b1),
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index b50519f..cbfdcd8 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -218,7 +218,7 @@ static int tbf_print_opt(struct qdisc_ut
 	if (RTA_PAYLOAD(tb[TCA_TBF_PARMS])  < sizeof(*qopt))
 		return -1;
 	fprintf(f, "rate %s ", sprint_rate(qopt->rate.rate, b1));
-	buffer = ((double)qopt->rate.rate*tc_core_tick2usec(qopt->buffer))/1000000;
+	buffer = tc_calc_xmitsize(qopt->rate.rate, qopt->buffer);
 	if (show_details) {
 		fprintf(f, "burst %s/%u mpu %s ", sprint_size(buffer, b1),
 			1<<qopt->rate.cell_log, sprint_size(qopt->rate.mpu, b2));
@@ -230,7 +230,7 @@ static int tbf_print_opt(struct qdisc_ut
 	if (qopt->peakrate.rate) {
 		fprintf(f, "peakrate %s ", sprint_rate(qopt->peakrate.rate, b1));
 		if (qopt->mtu || qopt->peakrate.mpu) {
-			mtu = ((double)qopt->peakrate.rate*tc_core_tick2usec(qopt->mtu))/1000000;
+			mtu = tc_calc_xmitsize(qopt->peakrate.rate, qopt->mtu);
 			if (show_details) {
 				fprintf(f, "mtu %s/%u mpu %s ", sprint_size(mtu, b1),
 					1<<qopt->peakrate.cell_log, sprint_size(qopt->peakrate.mpu, b2));
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 90a097d..1ca4583 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -51,6 +51,11 @@ unsigned tc_calc_xmittime(unsigned rate,
 	return tc_core_usec2tick(1000000*((double)size/rate));
 }
 
+unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
+{
+	return ((double)rate*tc_core_tick2usec(ticks))/1000000;
+}
+
 /*
    rtab[pkt_len>>cell_log] = pkt_xmit_time
  */
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 65611b6..ff00f92 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -8,6 +8,7 @@ int  tc_core_usec2big(long usec);
 long tc_core_usec2tick(long usec);
 long tc_core_tick2usec(long tick);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
+unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
 int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu, unsigned mpu);
 
 int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator *est);
