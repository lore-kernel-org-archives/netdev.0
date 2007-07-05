From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 1/2] eHEA: Capability flag for DLPAR support
Date: Thu, 5 Jul 2007 09:26:25 +0200
Message-ID: <200707050926.26087.ossthema@de.ibm.com>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758319AbXGEHvg@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces a capability flag that is used by the DLPAR userspace
tool to check which DLPAR features are supported by the eHEA driver.

Missing goto has been included.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---
 drivers/net/ehea/ehea.h      |    8 +++++++-
 drivers/net/ehea/ehea_main.c |   23 ++++++++++++++++++++++-
 2 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index abaf3ac..f03f070 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,13 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0065"
+#define DRV_VERSION	"EHEA_0067"
+
+/* EHEA capability flags */
+#define DLPAR_PORT_ADD_REM 1
+#define DLPAR_MEM_ADD 2
+#define DLPAR_MEM_REM 4
+#define EHEA_CAPABILITIES (DLPAR_PORT_ADD_REM)
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index bdb5241..383144d 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2923,6 +2923,15 @@ static int check_module_parm(void)
 	return ret;
 }
 
+static ssize_t ehea_show_capabilities(struct device_driver *drv,
+				      char *buf)
+{
+	return sprintf(buf, "%d", EHEA_CAPABILITIES);
+}
+
+static DRIVER_ATTR(capabilities, S_IRUSR | S_IRGRP | S_IROTH,
+		   ehea_show_capabilities, NULL);
+
 int __init ehea_module_init(void)
 {
 	int ret;
@@ -2934,8 +2943,19 @@ int __init ehea_module_init(void)
 	if (ret)
 		goto out;
 	ret = ibmebus_register_driver(&ehea_driver);
-	if (ret)
+	if (ret) {
 		ehea_error("failed registering eHEA device driver on ebus");
+		goto out;
+	}
+
+	ret = driver_create_file(&ehea_driver.driver,
+				 &driver_attr_capabilities);
+	if (ret) {
+		ehea_error("failed to register capabilities attribute, ret=%d",
+			   ret);
+		ibmebus_unregister_driver(&ehea_driver);
+		goto out;
+	}
 
 out:
 	return ret;
@@ -2943,6 +2963,7 @@ out:
 
 static void __exit ehea_module_exit(void)
 {
+	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 }
 
-- 
1.5.2
