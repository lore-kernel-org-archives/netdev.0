From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 02/05]: Introduce tc_calc_xmitsize and use where appropriate
Date: Fri, 23 Jun 2006 20:06:46 +0200 (MEST)
Message-ID: <20060623180646.13183.69961.sendpatchset@localhost.localdomain>
References: <20060623180642.13183.74864.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44981 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751842AbWFWSGs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 14:06:48 -0400
To: hemminger@osdl.org
In-Reply-To: <20060623180642.13183.74864.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Introduce tc_calc_xmitsize and use where appropriate

Add tc_calc_xmitsize() as complement to tc_calc_xmittime(), which calculates
the size than can be transmitted at a given rate during a given time.
Replace all expressions of the form "size = rate*tc_core_tick2usec(time))/1000000"
by tc_calc_xmitsize() calls.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 06a5350c47d028448850788031625ac1961d722b
tree 23eb5f6dbbb4a864e524c048f006842733924c9e
parent c25b0a7730d72f266e46fee3cfd53ce9f2a15c2f
author Patrick McHardy <kaber@trash.net> Fri, 23 Jun 2006 19:13:09 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 23 Jun 2006 19:13:09 +0200

 tc/m_police.c |    2 +-
 tc/q_htb.c    |    4 ++--
 tc/q_tbf.c    |    4 ++--
 tc/tc_core.c  |    5 +++++
 tc/tc_core.h  |    1 +
 5 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/tc/m_police.c b/tc/m_police.c
index 71adb59..c3d2eeb 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -334,7 +334,7 @@ #endif
 
 	fprintf(f, " police 0x%x ", p->index);
 	fprintf(f, "rate %s ", sprint_rate(p->rate.rate, b1));
-	buffer = ((double)p->rate.rate*tc_core_tick2usec(p->burst))/1000000;
+	buffer = tc_calc_xmitsize(p->rate.rate, p->burst);
 	fprintf(f, "burst %s ", sprint_size(buffer, b1));
 	fprintf(f, "mtu %s ", sprint_size(p->mtu, b1));
 	if (show_raw)
diff --git a/tc/q_htb.c b/tc/q_htb.c
index 828d4b1..9a7755f 100644
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
index 87b1b29..bb13d77 100644
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
index 8688b63..7d6dd7d 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -42,6 +42,11 @@ unsigned tc_calc_xmittime(unsigned rate,
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
index 1537f95..d97c011 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -7,6 +7,7 @@ #include <linux/pkt_sched.h>
 long tc_core_usec2tick(long usec);
 long tc_core_tick2usec(long tick);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
+unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
 int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu, unsigned mpu);
 
 int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator *est);
