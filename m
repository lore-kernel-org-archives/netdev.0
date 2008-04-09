From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [PATCH 7/7] Add linklayer parameter to TBF.
Date: Wed, 9 Apr 2008 23:07:18 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804092306250.21022@ask.diku.dk>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:57463 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754484AbYDIVHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 17:07:20 -0400
In-Reply-To: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
  tc/q_tbf.c |   12 +++++++++---
  1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index 3bdce5a..dbf9586 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -27,7 +27,7 @@ static void explain(void)
  {
  	fprintf(stderr, "Usage: ... tbf limit BYTES burst BYTES[/BYTES] rate KBPS [ mtu BYTES[/BYTES] ]\n");
  	fprintf(stderr, "               [ peakrate KBPS ] [ latency TIME ] ");
-	fprintf(stderr, "[ overhead BYTES ]\n");
+	fprintf(stderr, "[ overhead BYTES ] [ linklayer TYPE ]\n");
  }

  static void explain1(char *arg)
@@ -47,6 +47,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
  	unsigned buffer=0, mtu=0, mpu=0, latency=0;
  	int Rcell_log=-1, Pcell_log = -1;
  	unsigned short overhead=0;
+	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
  	struct rtattr *tail;

  	memset(&opt, 0, sizeof(opt));
@@ -141,6 +142,11 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
  			if (get_u16(&overhead, *argv, 10)) {
  				explain1("overhead"); return -1;
  			}
+		} else if (matches(*argv, "linklayer") == 0) {
+			NEXT_ARG();
+			if (get_linklayer(&linklayer, *argv)) {
+				explain1("linklayer"); return -1;
+			}
  		} else if (strcmp(*argv, "help") == 0) {
  			explain();
  			return -1;
@@ -183,7 +189,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl

  	opt.rate.mpu      = mpu;
  	opt.rate.overhead = overhead;
-	if (tc_calc_rtable(&opt.rate, rtab, Rcell_log, mtu) < 0) {
+	if (tc_calc_rtable(&opt.rate, rtab, Rcell_log, mtu, linklayer) < 0) {
  		fprintf(stderr, "TBF: failed to calculate rate table.\n");
  		return -1;
  	}
@@ -192,7 +198,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
  	if (opt.peakrate.rate) {
  		opt.peakrate.mpu      = mpu;
  		opt.peakrate.overhead = overhead;
-		if (tc_calc_rtable(&opt.peakrate, ptab, Pcell_log, mtu) < 0) {
+		if (tc_calc_rtable(&opt.peakrate, ptab, Pcell_log, mtu, linklayer) < 0) {
  			fprintf(stderr, "TBF: failed to calculate peak rate table.\n");
  			return -1;
  		}
-- 
1.5.3

