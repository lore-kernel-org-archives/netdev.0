From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/3] s390: iucv - avoid deadlock between iucv_path_connect and tasklet
Date: Fri, 13 Jul 2007 10:50:55 +0200
Message-ID: <20070713085245.495093000@linux.vnet.ibm.com>
References: <20070713085053.530802000@linux.vnet.ibm.com>
Cc: Frank Pavlic <fpavlic@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:24669 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934881AbXGMIxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 04:53:09 -0400
Content-Disposition: inline; filename=201-iucv-trylock.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

An iucv deadlock may occur, where one CPU is spinning on the
iucv_table_lock for iucv_tasklet_fn(), while another CPU is holding
the iucv_table_lock for an iucv_path_connect() and is waiting for
the first CPU in an smp_call_function.
Solution: replace spin_lock in iucv_tasklet_fn by spin_trylock and
reschedule tasklet in case of non-granted lock.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Acked-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 net/iucv/iucv.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

Index: net-2.6-uschi/net/iucv/iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/iucv.c
+++ net-2.6-uschi/net/iucv/iucv.c
@@ -1494,7 +1494,10 @@ static void iucv_tasklet_fn(unsigned lon
 	struct iucv_irq_list *p, *n;
 
 	/* Serialize tasklet, iucv_path_sever and iucv_path_connect. */
-	spin_lock(&iucv_table_lock);
+	if (!spin_trylock(&iucv_table_lock)) {
+		tasklet_schedule(&iucv_tasklet);
+		return;
+	}
 	iucv_active_cpu = smp_processor_id();
 
 	spin_lock_irq(&iucv_queue_lock);

-- 
