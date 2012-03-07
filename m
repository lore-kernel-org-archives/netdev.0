From: frank.blaschka@de.ibm.com
Subject: [patch 4/7] [PATCH] ctcm: make ctcmpc debugging compilable
Date: Wed, 07 Mar 2012 13:06:26 +0100
Message-ID: <20120307120707.933695671@de.ibm.com>
References: <20120307120622.922387262@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:43421 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757468Ab2CGMH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 07:07:27 -0500
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 7 Mar 2012 12:07:26 -0000
Content-Disposition: inline; filename=611-ctcm-debug.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

ctcmpc debugging can be activated defining constant DEBUGCCW.
The debugging part contains wrong checks for 64 bit addresses.
Thus the debugging version does not compile. 
This patch corrects the 64-bit address checks to make it
compilable.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reviewed-by: Belinda Thompson <belindat@us.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/ctcm_main.c |    3 +++
 drivers/s390/net/ctcm_mpc.c  |   12 ++++++------
 2 files changed, 9 insertions(+), 6 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/ctcm_main.c linux-2.6-patched/drivers/s390/net/ctcm_main.c
--- linux-2.6/drivers/s390/net/ctcm_main.c	2012-01-05 00:55:44.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.c	2012-03-06 13:36:00.000000000 +0100
@@ -562,6 +562,9 @@ static int ctcm_transmit_skb(struct chan
 		skb_queue_tail(&ch->io_queue, skb);
 		ccw_idx = 3;
 	}
+	if (do_debug_ccw)
+		ctcmpc_dumpit((char *)&ch->ccw[ccw_idx],
+					sizeof(struct ccw1) * 3);
 	ch->retry = 0;
 	fsm_newstate(ch->fsm, CTC_STATE_TX);
 	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
diff -urpN linux-2.6/drivers/s390/net/ctcm_mpc.c linux-2.6-patched/drivers/s390/net/ctcm_mpc.c
--- linux-2.6/drivers/s390/net/ctcm_mpc.c	2012-01-05 00:55:44.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/ctcm_mpc.c	2012-03-06 13:36:00.000000000 +0100
@@ -53,8 +53,8 @@
 #include <linux/moduleparam.h>
 #include <asm/idals.h>
 
-#include "ctcm_mpc.h"
 #include "ctcm_main.h"
+#include "ctcm_mpc.h"
 #include "ctcm_fsms.h"
 
 static const struct xid2 init_xid = {
@@ -132,7 +132,7 @@ void ctcmpc_dumpit(char *buf, int len)
 	__u32	ct, sw, rm, dup;
 	char	*ptr, *rptr;
 	char	tbuf[82], tdup[82];
-	#if (UTS_MACHINE == s390x)
+	#ifdef CONFIG_64BIT
 	char	addr[22];
 	#else
 	char	addr[12];
@@ -149,8 +149,8 @@ void ctcmpc_dumpit(char *buf, int len)
 
 	for (ct = 0; ct < len; ct++, ptr++, rptr++) {
 		if (sw == 0) {
-			#if (UTS_MACHINE == s390x)
-			sprintf(addr, "%16.16lx", (__u64)rptr);
+			#ifdef CONFIG_64BIT
+			sprintf(addr, "%16.16llx", (__u64)rptr);
 			#else
 			sprintf(addr, "%8.8X", (__u32)rptr);
 			#endif
@@ -164,8 +164,8 @@ void ctcmpc_dumpit(char *buf, int len)
 		if (sw == 8)
 			strcat(bhex, "	");
 
-		#if (UTS_MACHINE == s390x)
-		sprintf(tbuf, "%2.2lX", (__u64)*ptr);
+		#if CONFIG_64BIT
+		sprintf(tbuf, "%2.2llX", (__u64)*ptr);
 		#else
 		sprintf(tbuf, "%2.2X", (__u32)*ptr);
 		#endif
