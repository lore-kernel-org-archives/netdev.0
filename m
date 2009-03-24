From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/9] [PATCH] Use kthread instead of kernel_thread
Date: Tue, 24 Mar 2009 14:27:43 +0100
Message-ID: <20090324133048.845506000@linux.vnet.ibm.com>
References: <20090324132742.300929000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:50458 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760681AbZCXNaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 09:30:52 -0400
Content-Disposition: inline; filename=604-lcs-threads.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

Lcs uses low-level kernel_thread implementation.
All drivers should use <linux/kthread.h> API instead.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/lcs.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c	2009-03-04 15:58:03.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/lcs.c	2009-03-04 15:58:28.000000000 +0100
@@ -39,6 +39,7 @@
 #include <linux/in.h>
 #include <linux/igmp.h>
 #include <linux/delay.h>
+#include <linux/kthread.h>
 #include <net/arp.h>
 #include <net/ip.h>
 
@@ -1259,7 +1260,6 @@ lcs_register_mc_addresses(void *data)
 	struct in_device *in4_dev;
 
 	card = (struct lcs_card *) data;
-	daemonize("regipm");
 
 	if (!lcs_do_run_thread(card, LCS_SET_MC_THREAD))
 		return 0;
@@ -1753,11 +1753,10 @@ lcs_start_kernel_thread(struct work_stru
 	struct lcs_card *card = container_of(work, struct lcs_card, kernel_thread_starter);
 	LCS_DBF_TEXT(5, trace, "krnthrd");
 	if (lcs_do_start_thread(card, LCS_RECOVERY_THREAD))
-		kernel_thread(lcs_recovery, (void *) card, SIGCHLD);
+		kthread_run(lcs_recovery, card, "lcs_recover");
 #ifdef CONFIG_IP_MULTICAST
 	if (lcs_do_start_thread(card, LCS_SET_MC_THREAD))
-		kernel_thread(lcs_register_mc_addresses,
-				(void *) card, SIGCHLD);
+		kthread_run(lcs_register_mc_addresses, card, "regipm");
 #endif
 }
 
@@ -2258,7 +2257,6 @@ lcs_recovery(void *ptr)
         int rc;
 
 	card = (struct lcs_card *) ptr;
-	daemonize("lcs_recover");
 
 	LCS_DBF_TEXT(4, trace, "recover1");
 	if (!lcs_do_run_thread(card, LCS_RECOVERY_THREAD))

