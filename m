From: Varun Prakash <varun@chelsio.com>
Subject: [net-next v2 1/6] libcxgb: add library module for Chelsio drivers
Date: Sat, 16 Jul 2016 22:49:15 +0530
Message-ID: <c7109ba4c9c00f0580b8e603a3c9ac53e5750ad4.1468689125.git.varun@chelsio.com>
References: <cover.1468689125.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com,
	hariprasad@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <cover.1468689125.git.varun@chelsio.com>
In-Reply-To: <cover.1468689125.git.varun@chelsio.com>
References: <cover.1468689125.git.varun@chelsio.com>
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
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/net/ethernet/chelsio/Kconfig               | 16 ++-----
 drivers/net/ethernet/chelsio/Makefile              |  1 +
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |  1 -
 drivers/net/ethernet/chelsio/libcxgb/Makefile      |  3 ++
 .../{cxgb4/cxgb4_ppm.c => libcxgb/libcxgb_ppm.c}   | 55 ++++++++++++++++++++--
 .../{cxgb4/cxgb4_ppm.h => libcxgb/libcxgb_ppm.h}   | 38 ++++++++++++---
 drivers/target/iscsi/cxgbit/Kconfig                |  2 +-
 drivers/target/iscsi/cxgbit/Makefile               |  1 +
 drivers/target/iscsi/cxgbit/cxgbit.h               |  2 +-
 9 files changed, 93 insertions(+), 26 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/libcxgb/Makefile
 rename drivers/net/ethernet/chelsio/{cxgb4/cxgb4_ppm.c => libcxgb/libcxgb_ppm.c} (85%)
 rename drivers/net/ethernet/chelsio/{cxgb4/cxgb4_ppm.h => libcxgb/libcxgb_ppm.h} (84%)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index 4686a85..c1724aa 100644
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
@@ -137,4 +126,9 @@ config CHELSIO_T4VF
 	  To compile this driver as a module choose M here; the module
 	  will be called cxgb4vf.
 
+config CHELSIO_LIB
+	tristate
+	---help---
+	Chelsio common library.
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
similarity index 85%
rename from drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
rename to drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
index d88a7a7..4cd1072 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.c
@@ -1,15 +1,43 @@
 /*
- * cxgb4_ppm.c: Chelsio common library for T4/T5 iSCSI PagePod Manager
+ * libcxgb_ppm.c: Chelsio common library for T3/T4/T5 iSCSI PagePod Manager
  *
  * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
  *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
  *
  * Written by: Karen Xie (kxie@chelsio.com)
  */
 
+#define DRV_NAME "libcxgb"
+#define DRV_VERSION "1.0.0-ko"
+#define pr_fmt(fmt) DRV_NAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/version.h>
 #include <linux/module.h>
@@ -22,7 +50,7 @@
 #include <linux/pci.h>
 #include <linux/scatterlist.h>
 
-#include "cxgb4_ppm.h"
+#include "libcxgb_ppm.h"
 
 /* Direct Data Placement -
  * Directly place the iSCSI Data-In or Data-Out PDU's payload into
@@ -462,3 +490,20 @@ unsigned int cxgbi_tagmask_set(unsigned int ppmax)
 
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
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.h
similarity index 84%
rename from drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h
rename to drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.h
index d487326..e995a1a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_ppm.h
@@ -1,17 +1,41 @@
 /*
- * cxgb4_ppm.h: Chelsio common library for T4/T5 iSCSI ddp operation
+ * libcxgb_ppm.h: Chelsio common library for T3/T4/T5 iSCSI ddp operation
  *
  * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
  *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
  *
  * Written by: Karen Xie (kxie@chelsio.com)
  */
 
-#ifndef	__CXGB4PPM_H__
-#define	__CXGB4PPM_H__
+#ifndef	__LIBCXGB_PPM_H__
+#define	__LIBCXGB_PPM_H__
 
 #include <linux/kernel.h>
 #include <linux/errno.h>
@@ -307,4 +331,4 @@ int cxgbi_ppm_release(struct cxgbi_ppm *ppm);
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

