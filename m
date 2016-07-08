From: Varun Prakash <varun@chelsio.com>
Subject: [net-next 1/6] libcxgb: add library module for Chelsio drivers
Date: Fri,  8 Jul 2016 23:03:54 +0530
Message-ID: <594492b4038d92cf80ce1bd54f55c4adb5bc1da5.1467998292.git.varun@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com,
	varun@chelsio.com
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <cover.1467998292.git.varun@chelsio.com>
In-Reply-To: <cover.1467998292.git.varun@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add common library module(libcxgb.ko) for
Chelsio drivers to remove duplicate code.

Code for iSCSI DDP Page Pod Manager is moved
from cxgb4.ko to libcxgb.ko. Earlier only cxgbit.ko
was using this code, now cxgb3i and cxgb4i will
also use common Page Pod manager code.

In future this module will have common connection
management and hardware specific code that can be
shared by multiple Chelsio drivers.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/Kconfig               | 18 ++++++----------
 drivers/net/ethernet/chelsio/Makefile              |  1 +
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |  1 -
 drivers/net/ethernet/chelsio/libcxgb/Makefile      |  3 +++
 .../{cxgb4/cxgb4_ppm.c => libcxgb/libcxgb_ppm.c}   | 25 ++++++++++++++++++++--
 .../{cxgb4/cxgb4_ppm.h => libcxgb/libcxgb_ppm.h}   |  8 +++----
 drivers/target/iscsi/cxgbit/Kconfig                |  2 +-
 drivers/target/iscsi/cxgbit/Makefile               |  1 +
 drivers/target/iscsi/cxgbit/cxgbit.h               |  2 +-
 9 files changed, 41 insertions(+), 20 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/libcxgb/Makefile
 rename drivers/net/ethernet/chelsio/{cxgb4/cxgb4_ppm.c => libcxgb/libcxgb_ppm.c} (95%)
 rename drivers/net/ethernet/chelsio/{cxgb4/cxgb4_ppm.h => libcxgb/libcxgb_ppm.h} (98%)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index 4686a85..1a5ce1e 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -96,17 +96,6 @@ config CHELSIO_T4_DCB
 
 	  If unsure, say N.
 
-config CHELSIO_T4_UWIRE
-	bool "Unified Wire Support for Chelsio T5 cards"
-	default n
-	depends on CHELSIO_T4
-	---help---
-	  Enable unified-wire offload features.
-	  Say Y here if you want to enable unified-wire over Ethernet
-	  in the driver.
-
-	  If unsure, say N.
-
 config CHELSIO_T4_FCOE
 	bool "Fibre Channel over Ethernet (FCoE) Support for Chelsio T5 cards"
 	default n
@@ -137,4 +126,11 @@ config CHELSIO_T4VF
 	  To compile this driver as a module choose M here; the module
 	  will be called cxgb4vf.
 
+config CHELSIO_LIB
+	tristate "Chelsio common library"
+	default n
+	---help---
+	  This is common library module for Chelsio T3/T4/T5/T6
+	  drivers.
+
 endif # NET_VENDOR_CHELSIO
diff --git a/drivers/net/ethernet/chelsio/Makefile b/drivers/net/ethernet/chelsio/Makefile
index 390510b..b6a5eec 100644
--- a/drivers/net/ethernet/chelsio/Makefile
+++ b/drivers/net/ethernet/chelsio/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_CHELSIO_T1) += cxgb/
 obj-$(CONFIG_CHELSIO_T3) += cxgb3/
 obj-$(CONFIG_CHELSIO_T4) += cxgb4/
 obj-$(CONFIG_CHELSIO_T4VF) += cxgb4vf/
+obj-$(CONFIG_CHELSIO_LIB) += libcxgb/
diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index 85c9282..ace0ab9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -7,5 +7,4 @@ obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o
 cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
 cxgb4-$(CONFIG_CHELSIO_T4_FCOE) +=  cxgb4_fcoe.o
-cxgb4-$(CONFIG_CHELSIO_T4_UWIRE) +=  cxgb4_ppm.o
 cxgb4-$(CONFIG_DEBUG_FS) += cxgb4_debugfs.o
diff --git a/drivers/net/ethernet/chelsio/libcxgb/Makefile b/drivers/net/ethernet/chelsio/libcxgb/Makefile
new file mode 100644
index 0000000..2362230
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/libcxgb/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_CHELSIO_LIB) += libcxgb.o
+
+libcxgb-y := libcxgb_ppm.o
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
similarity index 95%
rename from drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
rename to drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
index d88a7a7..aa9a9bb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
@@ -1,5 +1,5 @@
 /*
- * cxgb4_ppm.c: Chelsio common library for T4/T5 iSCSI PagePod Manager
+ * libcxgb_ppm.c: Chelsio common library for T3/T4/T5 iSCSI PagePod Manager
  *
  * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
  *
@@ -10,6 +10,10 @@
  * Written by: Karen Xie (kxie@chelsio.com)
  */
 
+#define DRV_NAME "libcxgb"
+#define DRV_VERSION "1.0.0-ko"
+#define pr_fmt(fmt) DRV_NAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/version.h>
 #include <linux/module.h>
@@ -22,7 +26,7 @@
 #include <linux/pci.h>
 #include <linux/scatterlist.h>
 
-#include "cxgb4_ppm.h"
+#include "libcxgb_ppm.h"
 
 /* Direct Data Placement -
  * Directly place the iSCSI Data-In or Data-Out PDU's payload into
@@ -462,3 +466,20 @@ unsigned int cxgbi_tagmask_set(unsigned int ppmax)
 
 	return 1 << (bits + PPOD_IDX_SHIFT);
 }
+
+static int __init libcxgb_init(void)
+{
+	return 0;
+}
+
+static void __exit libcxgb_exit(void)
+{
+}
+
+module_init(libcxgb_init);
+module_exit(libcxgb_exit);
+
+MODULE_AUTHOR("Chelsio Communications");
+MODULE_DESCRIPTION("Chelsio common library");
+MODULE_VERSION(DRV_VERSION);
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.h
similarity index 98%
rename from drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h
rename to drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.h
index d487326..42ec2ac 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.h
@@ -1,5 +1,5 @@
 /*
- * cxgb4_ppm.h: Chelsio common library for T4/T5 iSCSI ddp operation
+ * libcxgb_ppm.h: Chelsio common library for T3/T4/T5 iSCSI ddp operation
  *
  * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
  *
@@ -10,8 +10,8 @@
  * Written by: Karen Xie (kxie@chelsio.com)
  */
 
-#ifndef	__CXGB4PPM_H__
-#define	__CXGB4PPM_H__
+#ifndef	__LIBCXGB_PPM_H__
+#define	__LIBCXGB_PPM_H__
 
 #include <linux/kernel.h>
 #include <linux/errno.h>
@@ -307,4 +307,4 @@ int cxgbi_ppm_release(struct cxgbi_ppm *ppm);
 void cxgbi_tagmask_check(unsigned int tagmask, struct cxgbi_tag_format *);
 unsigned int cxgbi_tagmask_set(unsigned int ppmax);
 
-#endif	/*__CXGB4PPM_H__*/
+#endif	/*__LIBCXGB_PPM_H__*/
diff --git a/drivers/target/iscsi/cxgbit/Kconfig b/drivers/target/iscsi/cxgbit/Kconfig
index c9b6a3c..bc6c1d5 100644
--- a/drivers/target/iscsi/cxgbit/Kconfig
+++ b/drivers/target/iscsi/cxgbit/Kconfig
@@ -1,7 +1,7 @@
 config ISCSI_TARGET_CXGB4
 	tristate "Chelsio iSCSI target offload driver"
 	depends on ISCSI_TARGET && CHELSIO_T4 && INET
-	select CHELSIO_T4_UWIRE
+	select CHELSIO_LIB
 	---help---
 	To compile this driver as module, choose M here: the module
 	will be called cxgbit.
diff --git a/drivers/target/iscsi/cxgbit/Makefile b/drivers/target/iscsi/cxgbit/Makefile
index bd56c07..4893ec2 100644
--- a/drivers/target/iscsi/cxgbit/Makefile
+++ b/drivers/target/iscsi/cxgbit/Makefile
@@ -1,4 +1,5 @@
 ccflags-y := -Idrivers/net/ethernet/chelsio/cxgb4
+ccflags-y += -Idrivers/net/ethernet/chelsio/libcxgb
 ccflags-y += -Idrivers/target/iscsi
 
 obj-$(CONFIG_ISCSI_TARGET_CXGB4)  += cxgbit.o
diff --git a/drivers/target/iscsi/cxgbit/cxgbit.h b/drivers/target/iscsi/cxgbit/cxgbit.h
index 625c7f6..9038869 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit.h
+++ b/drivers/target/iscsi/cxgbit/cxgbit.h
@@ -37,7 +37,7 @@
 #include "cxgb4.h"
 #include "cxgb4_uld.h"
 #include "l2t.h"
-#include "cxgb4_ppm.h"
+#include "libcxgb_ppm.h"
 #include "cxgbit_lro.h"
 
 extern struct mutex cdev_list_lock;
-- 
2.0.2

