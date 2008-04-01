From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 3/3] iucv: Delay bus registration until core is ready.
Date: Tue, 01 Apr 2008 15:45:24 +0200
Message-ID: <20080401135709.863647000@linux.vnet.ibm.com>
References: <20080401134521.169525000@linux.vnet.ibm.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:13339 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755114AbYDAN5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 09:57:12 -0400
Content-Disposition: inline; filename=724-iucv-delay.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cornelia Huck <cornelia.huck@de.ibm.com>

If we register the iucv bus after the infrastructure is ready,
userspace can start relying on it when it receives the uevent
for the bus.

Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 net/iucv/iucv.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Index: net-2.6.26-uschi/net/iucv/iucv.c
===================================================================
--- net-2.6.26-uschi.orig/net/iucv/iucv.c
+++ net-2.6.26-uschi/net/iucv/iucv.c
@@ -1608,13 +1608,10 @@ static int __init iucv_init(void)
 	rc = register_external_interrupt(0x4000, iucv_external_interrupt);
 	if (rc)
 		goto out;
-	rc = bus_register(&iucv_bus);
-	if (rc)
-		goto out_int;
 	iucv_root = s390_root_dev_register("iucv");
 	if (IS_ERR(iucv_root)) {
 		rc = PTR_ERR(iucv_root);
-		goto out_bus;
+		goto out_int;
 	}
 
 	for_each_online_cpu(cpu) {
@@ -1634,13 +1631,20 @@ static int __init iucv_init(void)
 			goto out_free;
 		}
 	}
-	register_hotcpu_notifier(&iucv_cpu_notifier);
+	rc = register_hotcpu_notifier(&iucv_cpu_notifier);
+	if (rc)
+		goto out_free;
 	ASCEBC(iucv_error_no_listener, 16);
 	ASCEBC(iucv_error_no_memory, 16);
 	ASCEBC(iucv_error_pathid, 16);
 	iucv_available = 1;
+	rc = bus_register(&iucv_bus);
+	if (rc)
+		goto out_cpu;
 	return 0;
 
+out_cpu:
+	unregister_hotcpu_notifier(&iucv_cpu_notifier);
 out_free:
 	for_each_possible_cpu(cpu) {
 		kfree(iucv_param[cpu]);
@@ -1649,8 +1653,6 @@ out_free:
 		iucv_irq_data[cpu] = NULL;
 	}
 	s390_root_dev_unregister(iucv_root);
-out_bus:
-	bus_unregister(&iucv_bus);
 out_int:
 	unregister_external_interrupt(0x4000, iucv_external_interrupt);
 out:

-- 
