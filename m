From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE 07/08]: Handle different kernel clock resolutions
Date: Sun,  4 Mar 2007 20:15:03 +0100 (MET)
Message-ID: <20070304191412.22838.24161.sendpatchset@localhost.localdomain>
References: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61742 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444AbXCDTPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:15:04 -0500
In-Reply-To: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Handle different kernel clock resolutions

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0e0db5d408bdac33eadd9d947c0e6904df26ab8f
tree 950a6f47287bec01e5996bec3f1141b60f3f6f6a
parent 5950296ff76ba81593928a2ee89757d69b2acba9
author Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100

 tc/tc_core.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index e27254e..58155fb 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -23,9 +23,8 @@ #include <string.h>
 
 #include "tc_core.h"
 
-static __u32 t2us=1;
-static __u32 us2t=1;
 static double tick_in_usec = 1;
+static double clock_factor = 1;
 
 int tc_core_time2big(long time)
 {
@@ -48,12 +47,12 @@ long tc_core_tick2time(long tick)
 
 long tc_core_time2ktime(long time)
 {
-	return time;
+	return time * clock_factor;
 }
 
 long tc_core_ktime2time(long ktime)
 {
-	return ktime;
+	return ktime / clock_factor;
 }
 
 unsigned tc_calc_xmittime(unsigned rate, unsigned size)
@@ -98,16 +97,29 @@ int tc_calc_rtable(unsigned bps, __u32 *
 
 int tc_core_init()
 {
-	FILE *fp = fopen("/proc/net/psched", "r");
+	FILE *fp;
+	__u32 clock_res;
+	__u32 t2us;
+	__u32 us2t;
 
+	fp = fopen("/proc/net/psched", "r");
 	if (fp == NULL)
 		return -1;
 
-	if (fscanf(fp, "%08x%08x", &t2us, &us2t) != 2) {
+	if (fscanf(fp, "%08x%08x%08x", &t2us, &us2t, &clock_res) != 3) {
 		fclose(fp);
 		return -1;
 	}
 	fclose(fp);
-	tick_in_usec = (double)t2us/us2t;
+
+	/* compatibility hack: for old iproute binaries (ignoring
+	 * the kernel clock resolution) the kernel advertises a
+	 * tick multiplier of 1000 in case of nano-second resolution,
+	 * which really is 1. */
+	if (clock_res == 1000000000)
+		t2us = us2t;
+
+	clock_factor  = (double)clock_res / TIME_UNITS_PER_SEC;
+	tick_in_usec = (double)t2us / us2t * clock_factor;
 	return 0;
 }
