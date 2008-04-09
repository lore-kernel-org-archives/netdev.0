From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [PATCH 6/7] Add linklayer parameter to HTB.
Date: Wed, 9 Apr 2008 23:06:14 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804092305010.21022@ask.diku.dk>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:57428 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754433AbYDIVGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 17:06:16 -0400
In-Reply-To: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
  tc/q_htb.c |   11 +++++++++--
  1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/tc/q_htb.c b/tc/q_htb.c
index e24ad6d..7e85bf7 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -41,6 +41,7 @@ static void explain(void)
  		" burst    max bytes burst which can be accumulated during idle period {computed}\n"
  		" mpu      minimum packet size used in rate computations\n"
  		" overhead per-packet size overhead used in rate computations\n"
+		" linklay  adapting to a linklayer e.g. atm\n"

  		" ceil     definite upper class rate (no borrows) {rate}\n"
  		" cburst   burst but for ceil {computed}\n"
@@ -110,6 +111,7 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
  	unsigned mtu;
  	unsigned short mpu = 0;
  	unsigned short overhead = 0;
+	unsigned int linklayer  = LINKLAYER_ETHERNET; /* Assume ethernet */
  	struct rtattr *tail;

  	memset(&opt, 0, sizeof(opt)); mtu = 1600; /* eth packet len */
@@ -136,6 +138,11 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
  			if (get_u16(&overhead, *argv, 10)) {
  				explain1("overhead"); return -1;
  			}
+		} else if (matches(*argv, "linklayer") == 0) {
+			NEXT_ARG();
+			if (get_linklayer(&linklayer, *argv)) {
+				explain1("linklayer"); return -1;
+			}
  		} else if (matches(*argv, "quantum") == 0) {
  			NEXT_ARG();
  			if (get_u32(&opt.quantum, *argv, 10)) {
@@ -213,13 +220,13 @@ static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
  	opt.ceil.mpu = mpu;
  	opt.rate.mpu = mpu;

-	if (tc_calc_rtable(&opt.rate, rtab, cell_log, mtu) < 0) {
+	if (tc_calc_rtable(&opt.rate, rtab, cell_log, mtu, linklayer) < 0) {
  		fprintf(stderr, "htb: failed to calculate rate table.\n");
  		return -1;
  	}
  	opt.buffer = tc_calc_xmittime(opt.rate.rate, buffer);

-	if (tc_calc_rtable(&opt.ceil, ctab, ccell_log, mtu) < 0) {
+	if (tc_calc_rtable(&opt.ceil, ctab, ccell_log, mtu, linklayer) < 0) {
  		fprintf(stderr, "htb: failed to calculate ceil rate table.\n");
  		return -1;
  	}
-- 
1.5.3

