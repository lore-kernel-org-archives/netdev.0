From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH 2/6] netback: add module unload function.
Date: Fri, 13 Jan 2012 16:59:05 +0000
Message-ID: <1326473949-22389-3-git-send-email-wei.liu2@citrix.com>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:8241 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344Ab2AMQ7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 11:59:33 -0500
In-Reply-To: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enables users to unload netback module.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h  |    1 +
 drivers/net/xen-netback/netback.c |   14 ++++++++++++++
 drivers/net/xen-netback/xenbus.c  |    5 +++++
 3 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 94b79c3..263df73 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -120,6 +120,7 @@ void xenvif_get(struct xenvif *vif);
 void xenvif_put(struct xenvif *vif);
 
 int xenvif_xenbus_init(void);
+void xenvif_xenbus_exit(void);
 
 int xenvif_schedulable(struct xenvif *vif);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 26af7b7..dd10c0d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1653,5 +1653,19 @@ failed_init:
 
 module_init(netback_init);
 
+static void __exit netback_exit(void)
+{
+	int i;
+	for (i = 0; i < xen_netbk_group_nr; i++) {
+		struct xen_netbk *netbk = &xen_netbk[i];
+		del_timer(&netbk->net_timer);
+		kthread_stop(netbk->task);
+	}
+	vfree(xen_netbk);
+	page_pool_destroy();
+	xenvif_xenbus_exit();
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
