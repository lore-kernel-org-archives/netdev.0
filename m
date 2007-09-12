From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 5/6] [IPROUTE2]: Cleanup: tc_calc_rtable()
Date: Wed, 12 Sep 2007 12:14:49 +0200
Message-ID: <1189592089.26927.26.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:36427 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964929AbXILKPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:15:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit e3bad6e344303fec9916d1420aade98a2e6c79cc
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Wed Sep 5 10:47:47 2007 +0200

    [IPROUTE2]: Cleanup: tc_calc_rtable().
    
    Change tc_calc_rtable() to take a tc_ratespec struct as an
    argument. (cell_log still needs to be passed on as a parameter,
    because -1 indicate that the cell_log needs to be computed by the
    function.).
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/tc/m_police.c b/tc/m_police.c
index 5d2528b..acdfd22 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -263,22 +263,20 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 	}
 
 	if (p.rate.rate) {
-		if ((Rcell_log = tc_calc_rtable(p.rate.rate, rtab, Rcell_log, mtu, mpu)) < 0) {
+		p.rate.mpu = mpu;
+		if (tc_calc_rtable(&p.rate, rtab, Rcell_log, mtu) < 0) {
 			fprintf(stderr, "TBF: failed to calculate rate table.\n");
 			return -1;
 		}
 		p.burst = tc_calc_xmittime(p.rate.rate, buffer);
-		p.rate.cell_log = Rcell_log;
-		p.rate.mpu = mpu;
 	}
 	p.mtu = mtu;
 	if (p.peakrate.rate) {
-		if ((Pcell_log = tc_calc_rtable(p.peakrate.rate, ptab, Pcell_log, mtu, mpu)) < 0) {
+		p.peakrate.mpu = mpu;
+		if (tc_calc_rtable(&p.peakrate, ptab, Pcell_log, mtu) < 0) {
 			fprintf(stderr, "POLICE: failed to calculate peak rate table.\n");
 			return -1;
 		}
-		p.peakrate.cell_log = Pcell_log;
-		p.peakrate.mpu = mpu;
 	}
 
 	tail = NLMSG_TAIL(n);
diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index f2b4ce8..df98312 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -137,12 +137,11 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	if (allot < (avpkt*3)/2)
 		allot = (avpkt*3)/2;
 
-	if ((cell_log = tc_calc_rtable(r.rate, rtab, cell_log, allot, mpu)) < 0) {
+	r.mpu = mpu;
+	if (tc_calc_rtable(&r, rtab, cell_log, allot) < 0) {
 		fprintf(stderr, "CBQ: failed to calculate rate table.\n");
 		return -1;
 	}
-	r.cell_log = cell_log;
-	r.mpu = mpu;
 
 	if (ewma_log < 0)
 		ewma_log = TC_CBQ_DEF_EWMA;
@@ -336,12 +335,11 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 		unsigned pktsize = wrr.allot;
 		if (wrr.allot < (lss.avpkt*3)/2)
 			wrr.allot = (lss.avpkt*3)/2;
-		if ((cell_log = tc_calc_rtable(r.rate, rtab, cell_log, pktsize, mpu)) < 0) {
+		r.mpu = mpu;
+		if (tc_calc_rtable(&r, rtab, cell_log, pktsize) < 0) {
 			fprintf(stderr, "CBQ: failed to calculate rate table.\n");
 			return -1;
 		}
-		r.cell_log = cell_log;
-		r.mpu = mpu;
 	}
 	if (ewma_log < 0)
 		ewma_log = TC_CBQ_DEF_EWMA;
diff --git a/tc/q_htb.c b/tc/q_htb.c
index 310d36d..e24ad6d 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -213,19 +213,17 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	opt.ceil.mpu = mpu;
 	opt.rate.mpu = mpu;
 
-	if ((cell_log = tc_calc_rtable(opt.rate.rate, rtab, cell_log, mtu, mpu)) < 0) {
+	if (tc_calc_rtable(&opt.rate, rtab, cell_log, mtu) < 0) {
 		fprintf(stderr, "htb: failed to calculate rate table.\n");
 		return -1;
 	}
 	opt.buffer = tc_calc_xmittime(opt.rate.rate, buffer);
-	opt.rate.cell_log = cell_log;
 
-	if ((ccell_log = tc_calc_rtable(opt.ceil.rate, ctab, cell_log, mtu, mpu)) < 0) {
+	if (tc_calc_rtable(&opt.ceil, ctab, ccell_log, mtu) < 0) {
 		fprintf(stderr, "htb: failed to calculate ceil rate table.\n");
 		return -1;
 	}
 	opt.cbuffer = tc_calc_xmittime(opt.ceil.rate, cbuffer);
-	opt.ceil.cell_log = ccell_log;
 
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index 1fc05f4..c7b4f0f 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -170,21 +170,20 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		opt.limit = lim;
 	}
 
-	if ((Rcell_log = tc_calc_rtable(opt.rate.rate, rtab, Rcell_log, mtu, mpu)) < 0) {
+	opt.rate.mpu = mpu;
+	if (tc_calc_rtable(&opt.rate, rtab, Rcell_log, mtu) < 0) {
 		fprintf(stderr, "TBF: failed to calculate rate table.\n");
 		return -1;
 	}
 	opt.buffer = tc_calc_xmittime(opt.rate.rate, buffer);
-	opt.rate.cell_log = Rcell_log;
-	opt.rate.mpu = mpu;
+
 	if (opt.peakrate.rate) {
-		if ((Pcell_log = tc_calc_rtable(opt.peakrate.rate, ptab, Pcell_log, mtu, mpu)) < 0) {
+		opt.peakrate.mpu = mpu;
+		if (tc_calc_rtable(&opt.peakrate, ptab, Pcell_log, mtu) < 0) {
 			fprintf(stderr, "TBF: failed to calculate peak rate table.\n");
 			return -1;
 		}
 		opt.mtu = tc_calc_xmittime(opt.peakrate.rate, mtu);
-		opt.peakrate.cell_log = Pcell_log;
-		opt.peakrate.mpu = mpu;
 	}
 
 	tail = NLMSG_TAIL(n);
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 1ab0ba0..c713a18 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -69,10 +69,11 @@ unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
    rtab[pkt_len>>cell_log] = pkt_xmit_time
  */
 
-int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu,
-		   unsigned mpu)
+int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab, int cell_log, unsigned mtu)
 {
 	int i;
+	unsigned bps = r->rate;
+	unsigned mpu = r->mpu;
 
 	if (mtu == 0)
 		mtu = 2047;
@@ -88,6 +89,7 @@ int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu,
 			sz = mpu;
 		rtab[i] = tc_calc_xmittime(bps, sz);
 	}
+	r->cell_log=cell_log;
 	return cell_log;
 }
 
diff --git a/tc/tc_core.h b/tc/tc_core.h
index a139da6..e98a7b4 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -13,7 +13,7 @@ long tc_core_time2ktime(long time);
 long tc_core_ktime2time(long ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
-int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu, unsigned mpu);
+int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab, int cell_log, unsigned mtu);
 
 int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator *est);
 

