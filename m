From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 3/5] s390: use kthread_run in qeth and lcs
Date: Mon, 30 Apr 2007 17:42:57 +0200
Message-ID: <20070430154256.GC23666@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:42914 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423401AbXD3Pmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 11:42:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Biederman <ebiederm@xmission.com>

This patch modifies the qeth_recover thread to be started
with kthread_run not a combination of kernel_thread and
daemonize.  Resulting in slightly simpler and more maintainable
code.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 lcs.c       |    8 +++-----
 qeth_main.c |    4 ++--
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 08a994f..0300d87 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -36,6 +36,7 @@
 #include <linux/in.h>
 #include <linux/igmp.h>
 #include <linux/delay.h>
+#include <linux/kthread.h>
 #include <net/arp.h>
 #include <net/ip.h>
 
@@ -1248,7 +1249,6 @@ lcs_register_mc_addresses(void *data)
 	struct in_device *in4_dev;
 
 	card = (struct lcs_card *) data;
-	daemonize("regipm");
 
 	if (!lcs_do_run_thread(card, LCS_SET_MC_THREAD))
 		return 0;
@@ -1728,11 +1728,10 @@ lcs_start_kernel_thread(struct work_struct *work)
 	struct lcs_card *card = container_of(work, struct lcs_card, kernel_thread_starter);
 	LCS_DBF_TEXT(5, trace, "krnthrd");
 	if (lcs_do_start_thread(card, LCS_RECOVERY_THREAD))
-		kernel_thread(lcs_recovery, (void *) card, SIGCHLD);
+		kthread_run(lcs_recovery, card, "lcs_recover");
 #ifdef CONFIG_IP_MULTICAST
 	if (lcs_do_start_thread(card, LCS_SET_MC_THREAD))
-		kernel_thread(lcs_register_mc_addresses,
-				(void *) card, SIGCHLD);
+		kernel_run(lcs_register_mc_addresses, card, "regipm");
 #endif
 }
 
@@ -2232,7 +2231,6 @@ lcs_recovery(void *ptr)
         int rc;
 
 	card = (struct lcs_card *) ptr;
-	daemonize("lcs_recover");
 
 	LCS_DBF_TEXT(4, trace, "recover1");
 	if (!lcs_do_run_thread(card, LCS_RECOVERY_THREAD))
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index e0eb113..0d10ee0 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -50,6 +50,7 @@
 #include <linux/mii.h>
 #include <linux/rcupdate.h>
 #include <linux/ethtool.h>
+#include <linux/kthread.h>
 
 #include <net/arp.h>
 #include <net/ip.h>
@@ -957,7 +958,6 @@ qeth_recover(void *ptr)
 	int rc = 0;
 
 	card = (struct qeth_card *) ptr;
-	daemonize("qeth_recover");
 	QETH_DBF_TEXT(trace,2,"recover1");
 	QETH_DBF_HEX(trace, 2, &card, sizeof(void *));
 	if (!qeth_do_run_thread(card, QETH_RECOVER_THREAD))
@@ -1014,7 +1014,7 @@ qeth_start_kernel_thread(struct work_struct *work)
 	    card->write.state != CH_STATE_UP)
 		return;
 	if (qeth_do_start_thread(card, QETH_RECOVER_THREAD))
-		kernel_thread(qeth_recover, (void *) card, SIGCHLD);
+		kthread_run(qeth_recover, card, "qeth_recover");
 }
 
 
-- 
1.5.1.2

