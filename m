From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: iproute2 proposal
Date: Wed, 6 Aug 2008 01:25:38 +0300
Message-ID: <200808060125.38260.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_iNNmIsEvLAOcFev"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:56066 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbYHEWre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 18:47:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_iNNmIsEvLAOcFev
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

While using iproute2 in batch mode i notice that adding 11362 rules, on system 
with 500+ interfaces takes up to 1minute on Xeon 3.0 Ghz.
After "oprofiling" i got result:

CPU: P4 / Xeon with 2 hyper-threads, speed 2992.84 MHz (estimated)
Counted GLOBAL_POWER_EVENTS events (time during which processor is not 
stopped) with a unit mask of 0x01 (mandatory) count 100000
samples  %        image name               symbol name
86166    57.3473  tc                       ll_remember_index
48103    32.0147  tc                       parse_rtattr
8497      5.6551  tc                       rtnl_dump_filter
1751      1.1654  [vdso] (tgid:22801 range:0xb7f66000-0xb7f67000) (no symbols)
1085      0.7221  tc                       tc_calc_xmittime
672       0.4472  tc                       .plt

I did small patch, and voila! batch finished in 2 seconds successfully!

Proof of concept patch is attached. Not sure if it is not breaking any other 
things. Waiting for any comments.

--Boundary-00=_iNNmIsEvLAOcFev
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iproute2-proposal.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="iproute2-proposal.patch"

diff -Naur iproute2-original/lib/ll_map.c iproute2-patched/lib/ll_map.c
--- iproute2-original/lib/ll_map.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/lib/ll_map.c	2008-08-05 22:22:36.000000000 +0000
@@ -23,6 +23,7 @@
 #include "ll_map.h"
 
 extern unsigned int if_nametoindex (const char *);
+static int ifacecache=0;
 
 struct idxmap
 {
@@ -160,6 +161,10 @@
 
 int ll_init_map(struct rtnl_handle *rth)
 {
+	if (ifacecache == 1)
+	    return 0;
+	ifacecache = 1;
+
 	if (rtnl_wilddump_request(rth, AF_UNSPEC, RTM_GETLINK) < 0) {
 		perror("Cannot send dump request");
 		exit(1);

--Boundary-00=_iNNmIsEvLAOcFev--
