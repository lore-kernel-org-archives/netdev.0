From: amit.salecha@qlogic.com
Subject: [PATCHv3 NEXT 3/5] qlcnic: fix netdev notifier in error path
Date: Tue, 13 Jul 2010 23:33:33 -0700
Message-ID: <1279089215-23231-4-git-send-email-amit.salecha@qlogic.com>
References: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:49679 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752364Ab0GNGdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 02:33:36 -0400
In-Reply-To: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

netdev notifier are not unregistered if pci_register_driver fails.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 0fef8c3..0995f90 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -3451,6 +3451,7 @@ static struct pci_driver qlcnic_driver = {
 
 static int __init qlcnic_init_module(void)
 {
+	int ret;
 
 	printk(KERN_INFO "%s\n", qlcnic_driver_string);
 
@@ -3459,8 +3460,15 @@ static int __init qlcnic_init_module(void)
 	register_inetaddr_notifier(&qlcnic_inetaddr_cb);
 #endif
 
+	ret = pci_register_driver(&qlcnic_driver);
+	if (ret) {
+#ifdef CONFIG_INET
+		unregister_inetaddr_notifier(&qlcnic_inetaddr_cb);
+		unregister_netdevice_notifier(&qlcnic_netdev_cb);
+#endif
+	}
 
-	return pci_register_driver(&qlcnic_driver);
+	return ret;
 }
 
 module_init(qlcnic_init_module);
-- 
1.6.0.2

