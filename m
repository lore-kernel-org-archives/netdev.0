From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 2/8] netback: add module unload function
Date: Fri, 15 Feb 2013 16:00:03 +0000
Message-ID: <1360944010-15336-3-git-send-email-wei.liu2@citrix.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27169 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933002Ab3BOQAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 11:00:54 -0500
In-Reply-To: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable users to unload netback module. Users should make sure there is not vif
runnig.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h  |    1 +
 drivers/net/xen-netback/netback.c |   18 ++++++++++++++++++
 drivers/net/xen-netback/xenbus.c  |    5 +++++
 3 files changed, 24 insertions(+)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 9d7f172..35d8772 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -120,6 +120,7 @@ void xenvif_get(struct xenvif *vif);
 void xenvif_put(struct xenvif *vif);
 
 int xenvif_xenbus_init(void);
+void xenvif_xenbus_exit(void);
 
 int xenvif_schedulable(struct xenvif *vif);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index db8d45a..de59098 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1761,5 +1761,23 @@ failed_init:
 
 module_init(netback_init);
 
+static void __exit netback_exit(void)
+{
+	int group, i;
+	xenvif_xenbus_exit();
+	for (group = 0; group < xen_netbk_group_nr; group++) {
+		struct xen_netbk *netbk = &xen_netbk[group];
+		for (i = 0; i < MAX_PENDING_REQS; i++) {
+			if (netbk->mmap_pages[i])
+				__free_page(netbk->mmap_pages[i]);
+		}
+		del_timer_sync(&netbk->net_timer);
+		kthread_stop(netbk->task);
+	}
+	vfree(xen_netbk);
+}
+
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
1.7.10.4
