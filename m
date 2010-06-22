From: frank.blaschka@de.ibm.com
Subject: [patch 01/11] [PATCH] smsgiucv: guarantee single iucv connect in thaw
Date: Tue, 22 Jun 2010 10:57:02 +0200
Message-ID: <20100622085806.920924000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:48351 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758959Ab0FVI6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:09 -0400
Content-Disposition: inline; filename=601-smsgiucv-thaw-path-connect.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

If another smsgiucv_app device exists, suspend / resume fails with
iucv path list corruption, because the same iucv_path_connect is
called twice.
The patch introduces a flag to save connect status of the smsgiucv
path to make sure iucv_path_connect in smsg_pm_restore_thaw is
called only once.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/smsgiucv.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/smsgiucv.c linux-2.6-patched/drivers/s390/net/smsgiucv.c
--- linux-2.6/drivers/s390/net/smsgiucv.c	2010-05-16 23:17:36.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/smsgiucv.c	2010-06-22 08:54:57.000000000 +0200
@@ -47,6 +47,7 @@ static struct device *smsg_dev;
 
 static DEFINE_SPINLOCK(smsg_list_lock);
 static LIST_HEAD(smsg_list);
+static int iucv_path_connected;
 
 static int smsg_path_pending(struct iucv_path *, u8 ipvmid[8], u8 ipuser[16]);
 static void smsg_message_pending(struct iucv_path *, struct iucv_message *);
@@ -142,8 +143,10 @@ static int smsg_pm_freeze(struct device 
 #ifdef CONFIG_PM_DEBUG
 	printk(KERN_WARNING "smsg_pm_freeze\n");
 #endif
-	if (smsg_path)
+	if (smsg_path && iucv_path_connected) {
 		iucv_path_sever(smsg_path, NULL);
+		iucv_path_connected = 0;
+	}
 	return 0;
 }
 
@@ -154,7 +157,7 @@ static int smsg_pm_restore_thaw(struct d
 #ifdef CONFIG_PM_DEBUG
 	printk(KERN_WARNING "smsg_pm_restore_thaw\n");
 #endif
-	if (smsg_path) {
+	if (smsg_path && iucv_path_connected) {
 		memset(smsg_path, 0, sizeof(*smsg_path));
 		smsg_path->msglim = 255;
 		smsg_path->flags = 0;
@@ -165,6 +168,8 @@ static int smsg_pm_restore_thaw(struct d
 			printk(KERN_ERR
 			       "iucv_path_connect returned with rc %i\n", rc);
 #endif
+		if (!rc)
+			iucv_path_connected = 1;
 		cpcmd("SET SMSG IUCV", NULL, 0, NULL);
 	}
 	return 0;
@@ -214,6 +219,8 @@ static int __init smsg_init(void)
 			       NULL, NULL, NULL);
 	if (rc)
 		goto out_free_path;
+	else
+		iucv_path_connected = 1;
 	smsg_dev = kzalloc(sizeof(struct device), GFP_KERNEL);
 	if (!smsg_dev) {
 		rc = -ENOMEM;

