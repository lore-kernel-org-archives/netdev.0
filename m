From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [PATCH 4/7] Add linklayer parameter to filter action police.
Date: Wed, 9 Apr 2008 23:03:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804092302260.21022@ask.diku.dk>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:57337 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755522AbYDIVDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 17:03:51 -0400
In-Reply-To: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
  tc/m_police.c |   12 +++++++++---
  1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/tc/m_police.c b/tc/m_police.c
index e55a8c9..6e4c7fa 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -36,7 +36,7 @@ static void usage(void)
  {
  	fprintf(stderr, "Usage: ... police rate BPS burst BYTES[/BYTES] [ mtu BYTES[/BYTES] ]\n");
  	fprintf(stderr, "                [ peakrate BPS ] [ avrate BPS ] [ overhead BYTES ]\n");
-	fprintf(stderr, "                [ ACTIONTERM ]\n");
+	fprintf(stderr, "                [ linklayer TYPE ] [ ACTIONTERM ]\n");
  	fprintf(stderr, "Old Syntax ACTIONTERM := action <EXCEEDACT>[/NOTEXCEEDACT] \n");
  	fprintf(stderr, "New Syntax ACTIONTERM := conform-exceed <EXCEEDACT>[/NOTEXCEEDACT] \n");
  	fprintf(stderr, "Where: *EXCEEDACT := pipe | ok | reclassify | drop | continue \n");
@@ -134,6 +134,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
  	int presult = 0;
  	unsigned buffer=0, mtu=0, mpu=0;
  	unsigned short overhead=0;
+	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
  	int Rcell_log=-1, Pcell_log = -1;
  	struct rtattr *tail;

@@ -240,6 +241,11 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
  			if (get_u16(&overhead, *argv, 10)) {
  				explain1("overhead"); return -1;
  			}
+		} else if (matches(*argv, "linklayer") == 0) {
+			NEXT_ARG();
+			if (get_linklayer(&linklayer, *argv)) {
+				explain1("linklayer"); return -1;
+			}
  		} else if (strcmp(*argv, "help") == 0) {
  			usage();
  		} else {
@@ -270,7 +276,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
  	if (p.rate.rate) {
  		p.rate.mpu = mpu;
  		p.rate.overhead = overhead;
-		if (tc_calc_rtable(&p.rate, rtab, Rcell_log, mtu) < 0) {
+		if (tc_calc_rtable(&p.rate, rtab, Rcell_log, mtu, linklayer) < 0) {
  			fprintf(stderr, "TBF: failed to calculate rate table.\n");
  			return -1;
  		}
@@ -280,7 +286,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
  	if (p.peakrate.rate) {
  		p.peakrate.mpu = mpu;
  		p.peakrate.overhead = overhead;
-		if (tc_calc_rtable(&p.peakrate, ptab, Pcell_log, mtu) < 0) {
+		if (tc_calc_rtable(&p.peakrate, ptab, Pcell_log, mtu, linklayer) < 0) {
  			fprintf(stderr, "POLICE: failed to calculate peak rate table.\n");
  			return -1;
  		}
-- 
1.5.3

