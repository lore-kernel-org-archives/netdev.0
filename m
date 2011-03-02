From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH 02/27] HFI: Add HFI adapter control structure
Date: Wed,  2 Mar 2011 16:09:48 -0500
Message-ID: <1299100213-8770-2-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:39183 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756193Ab1CBVKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 16:10:24 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p22Kk78p010629
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 15:46:07 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 08B3B6E8036
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 16:10:24 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p22LANTJ230250
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:10:23 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p22LANqW031936
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:10:23 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Alloc/free of hfidd_acs to track the state of each HFI

Signed-off-by:  Piyush Chaudhary <piyushc@linux.vnet.ibm.com>
Signed-off-by:  Jim Dykman <dykmanj@linux.vnet.ibm.com>
Signed-off-by:  Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
Signed-off-by:  William S. Cadden <wscadden@linux.vnet.ibm.com>
Signed-off-by:  Wen C. Chen <winstonc@linux.vnet.ibm.com>
Signed-off-by:  Scot Sakolish <sakolish@linux.vnet.ibm.com>
Signed-off-by:  Jian Xiao <jian@linux.vnet.ibm.com>
Signed-off-by:  Carol L. Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by:  Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
---
 drivers/net/hfi/core/Makefile      |    3 +-
 drivers/net/hfi/core/hfidd_adpt.c  |   60 ++++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_init.c  |   57 ++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_proto.h |   39 +++++++++++++++++++++++
 include/linux/hfi/hfidd_adpt.h     |   45 +++++++++++++++++++++++++++
 include/linux/hfi/hfidd_internal.h |   14 ++++++++
 6 files changed, 217 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/hfi/core/hfidd_adpt.c
 create mode 100644 drivers/net/hfi/core/hfidd_proto.h
 create mode 100644 include/linux/hfi/hfidd_adpt.h

diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
index 80790c6..6fe4e60 100644
--- a/drivers/net/hfi/core/Makefile
+++ b/drivers/net/hfi/core/Makefile
@@ -1,5 +1,6 @@
 #
 # Makefile for the HFI device driver for IBM eServer System p
 #
-hfi_core-objs:=	hfidd_init.o
+hfi_core-objs:=	hfidd_adpt.o \
+		hfidd_init.o
 obj-$(CONFIG_HFI) += hfi_core.o
diff --git a/drivers/net/hfi/core/hfidd_adpt.c b/drivers/net/hfi/core/hfidd_adpt.c
new file mode 100644
index 0000000..d64fa38
--- /dev/null
+++ b/drivers/net/hfi/core/hfidd_adpt.c
@@ -0,0 +1,60 @@
+/*
+ * hfidd_adpt.c
+ *
+ * HFI device driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include <linux/hfi/hfidd_internal.h>
+#include "hfidd_proto.h"
+
+int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t devno, void *uiop)
+{
+
+	struct hfidd_acs	*p_acs = NULL;
+
+	p_acs = kzalloc(sizeof(*p_acs), GFP_KERNEL);
+	if (p_acs == NULL)
+		return -ENOMEM;
+
+	p_acs->dev_num = devno;
+	p_acs->index  = MINOR(devno);
+	p_acs->state  = HFI_INVALID;
+	snprintf(p_acs->name, HFI_DEVICE_NAME_MAX - 1,
+			"%s%d", HFIDD_DEV_NAME, p_acs->index);
+
+	*adpt = p_acs;
+	return 0;
+}
+
+void hfidd_free_adapter(struct hfidd_acs *p_acs)
+{
+	kfree(p_acs);
+	p_acs = NULL;
+	return;
+}
diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
index e03620e..114b772 100644
--- a/drivers/net/hfi/core/hfidd_init.c
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -36,6 +36,7 @@
 #include <linux/device.h>
 
 #include <linux/hfi/hfidd_internal.h>
+#include "hfidd_proto.h"
 
 MODULE_VERSION("1.0");
 MODULE_DESCRIPTION("Device Driver for IBM eServer HFI for IBM System p");
@@ -118,10 +119,52 @@ hfidd_create_class_error1:
 	return rc;
 }
 
+/* Free adapter resources and the devicese */
+static void hfidd_destroy_devices(void)
+{
+	int i;
+
+	for (i = 0; i < MAX_HFIS; i++) {
+		hfidd_free_adapter(hfidd_global.p_acs[i]);
+		hfidd_global.p_acs[i] = NULL;
+		hfidd_global.acs_cnt--;
+	}
+}
+
+/*
+ * Create the adapter structure, allocate resources and create
+ * the hfi devices
+ */
+static int hfidd_create_devices(void)
+{
+	int i, j;
+	int rc = 0;
+
+	for (i = 0; i < MAX_HFIS; i++) {
+		rc = hfidd_alloc_adapter(&(hfidd_global.p_acs[i]),
+				MKDEV(MAJOR(hfidd_dev), i), NULL);
+		if (rc) {
+			printk(KERN_ERR "%s: hfidd_create_devices: "
+				"hfidd_alloc_adapter fail rc = %d\n",
+				HFIDD_DEV_NAME, rc);
+			for (j = 0; j < i; j++) {
+				hfidd_free_adapter(hfidd_global.p_acs[j]);
+				hfidd_global.p_acs[j] = NULL;
+				hfidd_global.acs_cnt--;
+			}
+			return rc;
+		}
+		hfidd_global.acs_cnt++;
+	}
+	return rc;
+}
+
 static int __init hfidd_mod_init(void)
 {
 	int			rc = 0;
 
+	hfidd_global.acs_cnt = 0;
+
 	rc = hfidd_create_class();
 	if (rc < 0) {
 		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_create_class failed"
@@ -129,12 +172,26 @@ static int __init hfidd_mod_init(void)
 		return -1;
 	}
 
+	rc = hfidd_create_devices();
+	if (rc < 0) {
+		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_create_devices"
+			" failed rc = %d\n", HFIDD_DEV_NAME, rc);
+		goto error1;
+	}
+
 	printk(KERN_INFO "IBM hfi device driver loaded sucessfully\n");
 	return 0;
+
+error1:
+	hfidd_destroy_class();
+
+	/* Returning -1 so insmod will fail */
+	return -1;
 }
 
 static void __exit hfidd_mod_exit(void)
 {
+	hfidd_destroy_devices();
 	hfidd_destroy_class();
 }
 
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
new file mode 100644
index 0000000..01a5ba2
--- /dev/null
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -0,0 +1,39 @@
+/*
+ * hfidd_proto.h
+ *
+ * HFI device driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com)
+ *
+ * Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef _HFIDD_PROTO_H_
+#define _HFIDD_PROTO_H_
+
+int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t, void *uiop);
+void hfidd_free_adapter(struct hfidd_acs *p_acs);
+
+#endif
diff --git a/include/linux/hfi/hfidd_adpt.h b/include/linux/hfi/hfidd_adpt.h
new file mode 100644
index 0000000..6b1432d
--- /dev/null
+++ b/include/linux/hfi/hfidd_adpt.h
@@ -0,0 +1,45 @@
+/*
+ * hfidd_adpt.h
+ *
+ * HFI device driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef _HFIDD_ADPT_H_
+#define _HFIDD_ADPT_H_
+
+#include <linux/hfi/hfidd_client.h>
+
+
+/* Adpt state */
+#define HFI_INVALID		0
+#define HFI_AVAIL		1
+#define HFI_GOING_UNAVAIL	2
+#define HFI_UNAVAIL		3
+
+#endif /* _HFIDD_ADPT_H_ */
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index f5de1bb..2c58b56 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -38,16 +38,30 @@
 #include <linux/cdev.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/slab.h>
 
 #include <linux/hfi/hfidd_client.h>
+#include <linux/hfi/hfidd_adpt.h>
 
 #define HFIDD_DEV_NAME		"hfi"
 #define HFIDD_CLASS_NAME	"hfi"
 
+#define HFI_DEVICE_NAME_MAX 64
+/* hfi global */
+struct hfidd_acs {
+	dev_t			dev_num;
+	char			name[HFI_DEVICE_NAME_MAX];
+	unsigned int		index;
+	unsigned int		acs_cnt;
+	unsigned int		state;
+};
+
 /* DD global */
 struct hfidd_global {
 	struct cdev		cdev;
 	struct class		*class;
+	int			acs_cnt;
+	struct hfidd_acs	*p_acs[MAX_HFIS];
 };
 
 #endif
-- 
1.7.3.1

