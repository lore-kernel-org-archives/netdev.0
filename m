From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/3] iucv: wrong irq-disabling locking at module load time
Date: Thu, 07 Feb 2008 15:28:43 +0100
Message-ID: <20080207143533.294538000@linux.vnet.ibm.com>
References: <20080207142842.852003000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:61607 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755292AbYBGOfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 09:35:36 -0500
Content-Disposition: inline; filename=707-iucv-irq.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

Linux may hang when running af_iucv socket programs concurrently
with a load of module netiucv. iucv_register() tries to take the
iucv_table_lock with spin_lock_irq. This conflicts with
iucv_connect() which has a need for an smp_call_function while
holding the iucv_table_lock.
Solution: use bh-disabling locking in iucv_register()

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 net/iucv/iucv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/net/iucv/iucv.c linux-2.6-patched/net/iucv/iucv.c
--- linux-2.6/net/iucv/iucv.c	2008-02-07 13:24:12.000000000 +0100
+++ linux-2.6-patched/net/iucv/iucv.c	2008-02-07 13:24:34.000000000 +0100
@@ -693,9 +693,9 @@ int iucv_register(struct iucv_handler *h
 		iucv_setmask_up();
 	INIT_LIST_HEAD(&handler->paths);
 
-	spin_lock_irq(&iucv_table_lock);
+	spin_lock_bh(&iucv_table_lock);
 	list_add_tail(&handler->list, &iucv_handler_list);
-	spin_unlock_irq(&iucv_table_lock);
+	spin_unlock_bh(&iucv_table_lock);
 	rc = 0;
 out_mutex:
 	mutex_unlock(&iucv_register_mutex);

-- 
