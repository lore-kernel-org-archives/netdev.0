From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 5/5] [IPROUTE2] For police, implement overhead parameter
	parsing.
Date: Sun, 23 Mar 2008 23:53:57 +0100
Message-ID: <1206312837.15884.39.camel@localhost.localdomain>
References: <1206312248.15884.26.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-server.lanfw.cxnet.dk ([87.72.215.201]:48134 "EHLO
	comxexch02.comx.local" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756313AbYCWXAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 19:00:37 -0400
In-Reply-To: <1206312248.15884.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For police, implement overhead parameter parsing.

The change is ABI (Application Binary Interface) backward compatible
with older kernels, but will first have effect from kernel 2.6.24.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 tc/m_police.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/tc/m_police.c b/tc/m_police.c
index 46c785b..8fa63ad 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -35,7 +35,7 @@ struct action_util police_action_util = {
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ... police rate BPS burst BYTES[/BYTES] [ mtu BYTES[/BYTES] ]\n");
-	fprintf(stderr, "                [ peakrate BPS ] [ avrate BPS ]\n");
+	fprintf(stderr, "                [ peakrate BPS ] [ avrate BPS ] [ overhead BYTES ]\n");
 	fprintf(stderr, "                [ ACTIONTERM ]\n");
 	fprintf(stderr, "Old Syntax ACTIONTERM := action <EXCEEDACT>[/NOTEXCEEDACT] \n");
 	fprintf(stderr, "New Syntax ACTIONTERM := conform-exceed <EXCEEDACT>[/NOTEXCEEDACT] \n");
@@ -133,6 +133,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 	__u32 avrate = 0;
 	int presult = 0;
 	unsigned buffer=0, mtu=0, mpu=0;
+	unsigned short overhead;
 	int Rcell_log=-1, Pcell_log = -1;
 	struct rtattr *tail;
 
@@ -234,6 +235,11 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 				fprintf(stderr, "Illegal \"action\"\n");
 				return -1;
 			}
+		} else if (matches(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (get_u16(&overhead, *argv, 10)) {
+				explain1("overhead"); return -1;
+			}
 		} else if (strcmp(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -263,6 +269,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 
 	if (p.rate.rate) {
 		p.rate.mpu = mpu;
+		p.rate.overhead = overhead;
 		if (tc_calc_rtable(&p.rate, rtab, Rcell_log, mtu) < 0) {
 			fprintf(stderr, "TBF: failed to calculate rate table.\n");
 			return -1;
@@ -272,6 +279,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 	p.mtu = mtu;
 	if (p.peakrate.rate) {
 		p.peakrate.mpu = mpu;
+		p.peakrate.overhead = overhead;
 		if (tc_calc_rtable(&p.peakrate, ptab, Pcell_log, mtu) < 0) {
 			fprintf(stderr, "POLICE: failed to calculate peak rate table.\n");
 			return -1;
@@ -344,6 +352,7 @@ print_police(struct action_util *a, FILE *f, struct rtattr *arg)
 		fprintf(f, "/%s ", police_action_n2a(*(int*)RTA_DATA(tb[TCA_POLICE_RESULT]), b1, sizeof(b1)));
 	} else
 		fprintf(f, " ");
+	fprintf(f, "overhead %ub ", p->rate.overhead);
 	fprintf(f, "\nref %d bind %d\n",p->refcnt, p->bindcnt);
 
 	return 0;
-- 
1.5.3


