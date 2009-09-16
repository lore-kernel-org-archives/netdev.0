From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 2/7] [PATCH] iucv: fix iucv_buffer_cpumask check when calling IUCV functions
Date: Wed, 16 Sep 2009 16:37:23 +0200
Message-ID: <20090916144304.269646000@linux.vnet.ibm.com>
References: <20090916143721.863799000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:57641 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbZIPOnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 10:43:02 -0400
Content-Disposition: inline; filename=601-iucv-cpumask.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

Prior to calling IUCV functions, the DECLARE BUFFER function must have been
called for at least one CPU to receive IUCV interrupts.

With commit "iucv: establish reboot notifier" (6c005961), a check has been
introduced to avoid calling IUCV functions if the current CPU does not have
an interrupt buffer declared.
Because one interrupt buffer is sufficient, change the condition to ensure
that one interrupt buffer is available.

In addition, checking the buffer on the current CPU creates a race with
CPU up/down notifications: before checking the buffer, the IUCV function
might be interrupted by an smp_call_function() that retrieves the interrupt
buffer for the current CPU.
When the IUCV function continues, the check fails and -EIO is returned. If a
buffer is available on any other CPU, the IUCV function call must be invoked
(instead of failing with -EIO).

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/iucv.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff -urpN linux-2.6/net/iucv/iucv.c linux-2.6-patched/net/iucv/iucv.c
--- linux-2.6/net/iucv/iucv.c	2009-09-15 12:25:32.000000000 +0200
+++ linux-2.6-patched/net/iucv/iucv.c	2009-09-15 12:25:32.000000000 +0200
@@ -864,7 +864,7 @@ int iucv_path_accept(struct iucv_path *p
 	int rc;
 
 	local_bh_disable();
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -913,7 +913,7 @@ int iucv_path_connect(struct iucv_path *
 
 	spin_lock_bh(&iucv_table_lock);
 	iucv_cleanup_queue();
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -973,7 +973,7 @@ int iucv_path_quiesce(struct iucv_path *
 	int rc;
 
 	local_bh_disable();
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1005,7 +1005,7 @@ int iucv_path_resume(struct iucv_path *p
 	int rc;
 
 	local_bh_disable();
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1034,7 +1034,7 @@ int iucv_path_sever(struct iucv_path *pa
 	int rc;
 
 	preempt_disable();
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1068,7 +1068,7 @@ int iucv_message_purge(struct iucv_path 
 	int rc;
 
 	local_bh_disable();
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1160,7 +1160,7 @@ int __iucv_message_receive(struct iucv_p
 	if (msg->flags & IUCV_IPRMDATA)
 		return iucv_message_receive_iprmdata(path, msg, flags,
 						     buffer, size, residual);
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1233,7 +1233,7 @@ int iucv_message_reject(struct iucv_path
 	int rc;
 
 	local_bh_disable();
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1272,7 +1272,7 @@ int iucv_message_reply(struct iucv_path 
 	int rc;
 
 	local_bh_disable();
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1322,7 +1322,7 @@ int __iucv_message_send(struct iucv_path
 	union iucv_param *parm;
 	int rc;
 
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}
@@ -1409,7 +1409,7 @@ int iucv_message_send2way(struct iucv_pa
 	int rc;
 
 	local_bh_disable();
-	if (!cpu_isset(smp_processor_id(), iucv_buffer_cpumask)) {
+	if (cpus_empty(iucv_buffer_cpumask)) {
 		rc = -EIO;
 		goto out;
 	}

