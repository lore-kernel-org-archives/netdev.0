From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 02/16] netback: add module unload function.
Date: Mon, 30 Jan 2012 14:45:20 +0000
Message-ID: <1327934734-8908-3-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63150 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab2A3Opg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:45:36 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enables users to unload netback module.

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h  |    1 +
 drivers/net/xen-netback/netback.c |   14 ++++++++++++++
 drivers/net/xen-netback/xenbus.c  |    5 +++++
 3 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 288b2f3..372c7f5 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -126,6 +126,7 @@ void xenvif_get(struct xenvif *vif);
 void xenvif_put(struct xenvif *vif);
 
 int xenvif_xenbus_init(void);
+void xenvif_xenbus_exit(void);
 
 int xenvif_schedulable(struct xenvif *vif);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index d11205f..3059684 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1670,5 +1670,19 @@ failed_init:
 
 module_init(netback_init);
 
+static void __exit netback_exit(void)
+{
+	int i;
+	xenvif_xenbus_exit();
+	for (i = 0; i < xen_netbk_group_nr; i++) {
+		struct xen_netbk *netbk = &xen_netbk[i];
+		del_timer_sync(&netbk->net_timer);
+		kthread_stop(netbk->task);
+	}
+	vfree(xen_netbk);
+	page_pool_destroy();
+}
+module_exit(netback_exit);
+
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_ALIAS("xen-backend:vif");
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 410018c..65d14f2 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -485,3 +485,8 @@ int xenvif_xenbus_init(void)
 {
 	return xenbus_register_backend(&netback_driver);
 }
+
+void xenvif_xenbus_exit(void)
+{
+	return xenbus_unregister_driver(&netback_driver);
+}
-- 
1.7.2.5
