From: Thomas Klein <tklein@de.ibm.com>
Subject: [PATCH 2/2][RESEND] ehea: fix possible DLPAR/mem deadlock
Date: Wed, 21 Apr 2010 11:11:31 +0200
Message-ID: <201004211111.31298.tklein@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, themann@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:60692 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686Ab0DUJLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 05:11:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Force serialization of userspace-triggered DLPAR/mem operations

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---

Patch created against net-2.6

diff -Nurp net-2.6.orig/drivers/net/ehea/ehea.h net-2.6/drivers/net/ehea/ehea.h
--- net-2.6.orig/drivers/net/ehea/ehea.h	2010-04-21 10:23:21.000000000 +0200
+++ net-2.6/drivers/net/ehea/ehea.h	2010-04-21 10:42:14.000000000 +0200
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0102"
+#define DRV_VERSION	"EHEA_0103"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp net-2.6.orig/drivers/net/ehea/ehea_main.c net-2.6/drivers/net/ehea/ehea_main.c
--- net-2.6.orig/drivers/net/ehea/ehea_main.c	2010-04-21 10:43:14.000000000 +0200
+++ net-2.6/drivers/net/ehea/ehea_main.c	2010-04-21 10:42:14.000000000 +0200
@@ -2889,7 +2889,6 @@ static void ehea_rereg_mrs(struct work_s
 	int ret, i;
 	struct ehea_adapter *adapter;
 
-	mutex_lock(&dlpar_mem_lock);
 	ehea_info("LPAR memory changed - re-initializing driver");
 
 	list_for_each_entry(adapter, &adapter_list, list)
@@ -2959,7 +2958,6 @@ static void ehea_rereg_mrs(struct work_s
 		}
 	ehea_info("re-initializing driver complete");
 out:
-	mutex_unlock(&dlpar_mem_lock);
 	return;
 }
 
@@ -3542,7 +3540,14 @@ void ehea_crash_handler(void)
 static int ehea_mem_notifier(struct notifier_block *nb,
                              unsigned long action, void *data)
 {
+	int ret = NOTIFY_BAD;
 	struct memory_notify *arg = data;
+
+	if (!mutex_trylock(&dlpar_mem_lock)) {
+		ehea_info("ehea_mem_notifier must not be called parallelized");
+		goto out;
+	}
+
 	switch (action) {
 	case MEM_CANCEL_OFFLINE:
 		ehea_info("memory offlining canceled");
@@ -3551,14 +3556,14 @@ static int ehea_mem_notifier(struct noti
 		ehea_info("memory is going online");
 		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
 		if (ehea_add_sect_bmap(arg->start_pfn, arg->nr_pages))
-			return NOTIFY_BAD;
+			goto out_unlock;
 		ehea_rereg_mrs(NULL);
 		break;
 	case MEM_GOING_OFFLINE:
 		ehea_info("memory is going offline");
 		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
 		if (ehea_rem_sect_bmap(arg->start_pfn, arg->nr_pages))
-			return NOTIFY_BAD;
+			goto out_unlock;
 		ehea_rereg_mrs(NULL);
 		break;
 	default:
@@ -3566,8 +3571,12 @@ static int ehea_mem_notifier(struct noti
 	}
 
 	ehea_update_firmware_handles();
+	ret = NOTIFY_OK;
 
-	return NOTIFY_OK;
+out_unlock:
+	mutex_unlock(&dlpar_mem_lock);
+out:
+	return ret;
 }
 
 static struct notifier_block ehea_mem_nb = {
