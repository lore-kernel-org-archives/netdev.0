From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: qrtr: fix build problems
Date: Fri, 13 May 2016 15:09:58 +0200
Message-ID: <1463145025-4011396-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Bjorn Andersson <bjorn.andersson@sonymobile.com>,
	Courtney Cavin <courtney.cavin@sonymobile.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:56814 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932127AbcEMNKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 09:10:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having multiple loadable modules with the same name cannot work
with modprobe, and having both net/qrtr/smd.ko and drivers/soc/qcom/smd.ko
results in a (somewhat cryptic) build error:

ERROR: "qcom_smd_driver_unregister" [net/qrtr/smd.ko] undefined!
ERROR: "qcom_smd_driver_register" [net/qrtr/smd.ko] undefined!
ERROR: "qcom_smd_set_drvdata" [net/qrtr/smd.ko] undefined!
ERROR: "qcom_smd_send" [net/qrtr/smd.ko] undefined!
ERROR: "qcom_smd_get_drvdata" [net/qrtr/smd.ko] undefined!
ERROR: "qcom_smd_driver_unregister" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!
ERROR: "qcom_smd_driver_register" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!
ERROR: "qcom_smd_set_drvdata" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!
ERROR: "qcom_smd_send" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!
ERROR: "qcom_smd_get_drvdata" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!

Also, the qrtr driver uses the SMD interface and has a Kconfig dependency,
but also allows for compile-testing when SMD is disabled. However, if
with QCOM_SMD=m and COMPILE_TEST=y we can end up with QRTR_SMD=y and
that fails with a related link error.

The changes the dependency so we can still compile-test the driver but
not have it built-in if SMD is a module, to avoid running in the broken
configuration, and changes the Makefile to provide the driver under
a different module name.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: bdabad3e363d ("net: Add Qualcomm IPC router")
---
 net/qrtr/Kconfig  | 2 +-
 net/qrtr/Makefile | 4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/qrtr/Kconfig b/net/qrtr/Kconfig
index 673fd1f86ebe..b83c6807a5ae 100644
--- a/net/qrtr/Kconfig
+++ b/net/qrtr/Kconfig
@@ -16,7 +16,7 @@ if QRTR
 
 config QRTR_SMD
 	tristate "SMD IPC Router channels"
-	depends on QCOM_SMD || COMPILE_TEST
+	depends on QCOM_SMD || (COMPILE_TEST && QCOM_SMD=n)
 	---help---
 	  Say Y here to support SMD based ipcrouter channels.  SMD is the
 	  most common transport for IPC Router.
diff --git a/net/qrtr/Makefile b/net/qrtr/Makefile
index 6c00dc623b7e..ab09e40f7c74 100644
--- a/net/qrtr/Makefile
+++ b/net/qrtr/Makefile
@@ -1,2 +1,4 @@
 obj-$(CONFIG_QRTR) := qrtr.o
-obj-$(CONFIG_QRTR_SMD) += smd.o
+
+obj-$(CONFIG_QRTR_SMD) += qrtr-smd.o
+qrtr-smd-y	:= smd.o
-- 
2.7.0
