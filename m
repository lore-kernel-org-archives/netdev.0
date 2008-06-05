From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/3] iucv: prevent cpu hotplug when walking cpu_online_map.
Date: Thu, 05 Jun 2008 11:08:39 +0200
Message-ID: <20080605091437.542540000@linux.vnet.ibm.com>
References: <20080605090837.212105000@linux.vnet.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:53621 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073AbYFEJPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 05:15:21 -0400
Content-Disposition: inline; filename=604-iucv-hotplug.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

The code used preempt_disable() to prevent cpu hotplug, however that
doesn't protect for cpus being added. So use get_online_cpus() instead.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 net/iucv/iucv.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

Index: net-2.6-uschi/net/iucv/iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/iucv.c
+++ net-2.6-uschi/net/iucv/iucv.c
@@ -474,14 +474,14 @@ static void iucv_setmask_mp(void)
 {
 	int cpu;
 
-	preempt_disable();
+	get_online_cpus();
 	for_each_online_cpu(cpu)
 		/* Enable all cpus with a declared buffer. */
 		if (cpu_isset(cpu, iucv_buffer_cpumask) &&
 		    !cpu_isset(cpu, iucv_irq_cpumask))
 			smp_call_function_single(cpu, iucv_allow_cpu,
 						 NULL, 0, 1);
-	preempt_enable();
+	put_online_cpus();
 }
 
 /**
@@ -521,16 +521,17 @@ static int iucv_enable(void)
 		goto out;
 	/* Declare per cpu buffers. */
 	rc = -EIO;
-	preempt_disable();
+	get_online_cpus();
 	for_each_online_cpu(cpu)
 		smp_call_function_single(cpu, iucv_declare_cpu, NULL, 0, 1);
-	preempt_enable();
 	if (cpus_empty(iucv_buffer_cpumask))
 		/* No cpu could declare an iucv buffer. */
 		goto out_path;
+	put_online_cpus();
 	return 0;
 
 out_path:
+	put_online_cpus();
 	kfree(iucv_path_table);
 out:
 	return rc;
@@ -545,7 +546,9 @@ out:
  */
 static void iucv_disable(void)
 {
+	get_online_cpus();
 	on_each_cpu(iucv_retrieve_cpu, NULL, 0, 1);
+	put_online_cpus();
 	kfree(iucv_path_table);
 }
 

-- 
