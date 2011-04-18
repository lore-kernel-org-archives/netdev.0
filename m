From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v2 03/27] HFI:  Add device_create/device_destroy calls for HFI devices.
Date: Sun, 17 Apr 2011 23:21:35 -0400
Message-ID: <1303096919-7367-4-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41184 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380Ab1DRDWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:22:34 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I2v71F010295
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 22:57:07 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3I3MWbZ2625614
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:32 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3MUme001187
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:31 -0400
In-Reply-To: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

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
 drivers/net/hfi/core/hfidd_init.c  |   52 ++++++++++++++++++++++++++++++++++++
 include/linux/hfi/hfidd_internal.h |    1 +
 2 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
index 114b772..1e4898b 100644
--- a/drivers/net/hfi/core/hfidd_init.c
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -47,6 +47,7 @@ MODULE_LICENSE("GPL v2");
 struct hfidd_global hfidd_global;
 EXPORT_SYMBOL_GPL(hfidd_global);
 
+struct device  *hfidd_class_dev[MAX_HFIS + 1];
 static dev_t   hfidd_dev;
 
 #define MAX_HFI_DEVS (MAX_HFIS + 1)
@@ -71,6 +72,38 @@ static const struct file_operations hfidd_fops = {
 	.write		= hfidd_cmd_write,
 };
 
+/* Create the hfi device */
+static int hfidd_mkdev(int ai, struct hfidd_acs *p_acs)
+{
+	char			dname[128];
+	int			rc = 0;
+
+	sprintf(dname, "%s%d", HFIDD_DEV_NAME, ai);
+
+	hfidd_class_dev[ai] = device_create(hfidd_global.class,
+			NULL, MKDEV(MAJOR(hfidd_dev), ai),
+			(void *)p_acs, (char *)dname);
+
+	if (IS_ERR(hfidd_class_dev[ai])) {
+		rc = PTR_ERR(hfidd_class_dev[ai]);
+		printk(KERN_ERR "%s: hfidd_mkdev: device_create for ai=%d fail"
+				" rc = %d\n", dname, ai, rc);
+		return rc;
+	}
+
+	if (ai == MAX_HFIS)
+		return 0;
+
+	p_acs->hfidd_dev = hfidd_class_dev[ai];
+	return rc;
+}
+
+/* delete the hfi device, /dev/hfi* files and sysclass files */
+static void hfidd_rmdev(int ai)
+{
+	device_destroy(hfidd_global.class, MKDEV(MAJOR(hfidd_dev), ai));
+}
+
 /* Destroy the HFI class */
 static inline void hfidd_destroy_class(void)
 {
@@ -129,6 +162,8 @@ static void hfidd_destroy_devices(void)
 		hfidd_global.p_acs[i] = NULL;
 		hfidd_global.acs_cnt--;
 	}
+	for (i = 0; i <= MAX_HFIS; i++)
+		hfidd_rmdev(i);
 }
 
 /*
@@ -156,6 +191,23 @@ static int hfidd_create_devices(void)
 		}
 		hfidd_global.acs_cnt++;
 	}
+
+	for (i = 0; i <= MAX_HFIS; i++) {
+		rc = hfidd_mkdev(i, hfidd_global.p_acs[i]);
+		if (rc) {
+			for (j = 0; j < i; j++)
+				hfidd_rmdev(j);
+			goto hfidd_create_devices_error0;
+		}
+	}
+	return 0;
+
+hfidd_create_devices_error0:
+	for (i = 0; i < MAX_HFIS; i++) {
+		hfidd_free_adapter(hfidd_global.p_acs[i]);
+		hfidd_global.p_acs[i] = NULL;
+		hfidd_global.acs_cnt--;
+	}
 	return rc;
 }
 
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index 2c58b56..695d7f4 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -54,6 +54,7 @@ struct hfidd_acs {
 	unsigned int		index;
 	unsigned int		acs_cnt;
 	unsigned int		state;
+	struct device		*hfidd_dev;
 };
 
 /* DD global */
-- 
1.7.3.5

