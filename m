From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] ehea: add kexec support
Date: Fri, 26 Oct 2007 14:37:28 +0200
Message-ID: <200710261437.29117.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:18721 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbXJZMhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 08:37:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eHEA resources that are allocated via H_CALLs have a unique identifier each.
These identifiers are necessary to free the resources. A reboot notifier
is used to free all eHEA resources before the indentifiers get lost, i.e
before kexec starts a new kernel.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 4b4b74e..f78e5bf 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0079"
+#define DRV_VERSION	"EHEA_0080"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 0a7e789..f0319f1 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -33,6 +33,9 @@
 #include <linux/if.h>
 #include <linux/list.h>
 #include <linux/if_ether.h>
+#include <linux/notifier.h>
+#include <linux/reboot.h>
+
 #include <net/ip.h>
 
 #include "ehea.h"
@@ -3295,6 +3298,20 @@ static int __devexit ehea_remove(struct of_device *dev)
 	return 0;
 }
 
+static int ehea_reboot_notifier(struct notifier_block *nb,
+				unsigned long action, void *unused)
+{
+	if (action == SYS_RESTART) {
+		ehea_info("Reboot: freeing all eHEA resources");
+		ibmebus_unregister_driver(&ehea_driver);
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ehea_reboot_nb = {
+        .notifier_call = ehea_reboot_notifier,
+};
+
 static int check_module_parm(void)
 {
 	int ret = 0;
@@ -3351,6 +3368,8 @@ int __init ehea_module_init(void)
 	if (ret)
 		goto out;
 
+	register_reboot_notifier(&ehea_reboot_nb);
+
 	ret = ibmebus_register_driver(&ehea_driver);
 	if (ret) {
 		ehea_error("failed registering eHEA device driver on ebus");
@@ -3362,6 +3381,7 @@ int __init ehea_module_init(void)
 	if (ret) {
 		ehea_error("failed to register capabilities attribute, ret=%d",
 			   ret);
+		unregister_reboot_notifier(&ehea_reboot_nb);
 		ibmebus_unregister_driver(&ehea_driver);
 		goto out;
 	}
@@ -3375,6 +3395,7 @@ static void __exit ehea_module_exit(void)
 	flush_scheduled_work();
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
+	unregister_reboot_notifier(&ehea_reboot_nb);
 	ehea_destroy_busmap();
 }
 
-- 
1.5.2

