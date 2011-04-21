From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 04/27] HFI: Find HFI devices in the device tree
Date: Thu, 21 Apr 2011 17:38:34 -0400
Message-ID: <1303421937-2325-5-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e8.ny.us.ibm.com ([32.97.182.138]:47287 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755177Ab1DUVjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:19 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLDjK7032688
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:13:45 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdAwq1851528
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:10 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLd8MW012487
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:09 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
 drivers/net/hfi/core/hfidd_adpt.c  |   10 +++
 drivers/net/hfi/core/hfidd_init.c  |  108 ++++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_proto.h |    1 +
 include/linux/hfi/hfidd_adpt.h     |    5 ++
 include/linux/hfi/hfidd_client.h   |    3 +
 include/linux/hfi/hfidd_internal.h |   12 ++++
 6 files changed, 139 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_adpt.c b/drivers/net/hfi/core/hfidd_adpt.c
index ec6a053..f309a02 100644
--- a/drivers/net/hfi/core/hfidd_adpt.c
+++ b/drivers/net/hfi/core/hfidd_adpt.c
@@ -36,6 +36,7 @@
 int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t devno, void *uiop)
 {
 
+	int			ret = 0;
 	struct hfidd_acs	*p_acs = NULL;
 
 	p_acs = kzalloc(sizeof(*p_acs), GFP_KERNEL);
@@ -48,8 +49,17 @@ int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t devno, void *uiop)
 	snprintf(p_acs->name, HFI_DEVICE_NAME_MAX,
 			"%s%d", HFIDD_DEV_NAME, p_acs->index);
 
+	ret = hfidd_init_adapter(p_acs, uiop);
+	if (ret)
+		goto err_exit0;
+
 	*adpt = p_acs;
 	return 0;
+
+err_exit0:
+	kfree(p_acs);
+	p_acs = NULL;
+	return ret;
 }
 
 void hfidd_free_adapter(struct hfidd_acs *p_acs)
diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
index 40d5aaf..d181d97 100644
--- a/drivers/net/hfi/core/hfidd_init.c
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/device.h>
+#include <linux/of.h>
 
 #include <linux/hfi/hfidd_internal.h>
 #include "hfidd_proto.h"
@@ -103,6 +104,113 @@ static void hfidd_rmdev(int ai)
 	device_destroy(hfidd_global.class, MKDEV(MAJOR(hfidd_dev), ai));
 }
 
+/*
+ * Read the hfi device tree attributes and
+ * fill the hfidd_dds structure to be used by the driver
+ */
+static int hfidd_dds_init(struct hfidd_acs *p_acs, struct hfidd_dds *pdds)
+{
+	struct device_node	*node;
+	struct device_node	*child_node = NULL;
+	unsigned long long	*lp;
+	int			*p;
+	unsigned char		octant;
+	unsigned char		id;
+	int			found = 0;
+
+	node = of_find_node_by_name(NULL, "hfi-iohub");
+	if (!node) {
+		printk(KERN_ERR "%s: hfidd_dds_init: of_find_node_by_name"
+			" 'hfi-iohub' failed\n", p_acs->name);
+		return -EINVAL;
+	}
+
+	lp = (unsigned long long *)of_get_property(node, "reg", NULL);
+	if (!lp) {
+		printk(KERN_ERR "%s: hfidd_dds_init: of_get_property"
+			" 'hfi-iohub/reg' failed\n", p_acs->name);
+		return -EINVAL;
+	}
+	pdds->torr_id = *lp;
+
+	lp = (unsigned long long *)of_get_property(node,
+				"ibm,fw-ec-level", NULL);
+	if (!lp) {
+		printk(KERN_ERR "%s: hfidd_dds_init: of_get_property"
+			" 'ibm,fw-ec-level' failed\n", p_acs->name);
+		return -EINVAL;
+	}
+	pdds->fw_ec_level = *lp;
+
+	octant = (node->full_name[strlen(node->full_name) - 1] - '0');
+	if (octant > HFI_MAX_OCTANT) {
+		printk(KERN_ERR "%s: hfidd_dds_init: invalid hfi-iohub octant"
+			" '%s'\n", node->full_name, p_acs->name);
+		return -EINVAL;
+	}
+
+	id = ((octant << HFI_SHIFT_OCTANT) | p_acs->index);
+
+	while ((child_node = of_get_next_child(node, child_node))) {
+		p = (int *)of_get_property(child_node, "reg", NULL);
+		if (!p) {
+			printk(KERN_ERR "%s: hfidd_dds_init: of_get_property "
+				"'reg' failed\n", p_acs->name);
+			return -EINVAL;
+		}
+
+		if (id == *p) {
+			pdds->hfi_id = *p;
+			found = 1;
+			break;
+		}
+	}
+
+	if (found == 0) {
+		printk(KERN_ERR "%s: hfidd_dds_init: can not find child\n",
+			p_acs->name);
+		return -EINVAL;
+	}
+
+	lp = (unsigned long long *)of_get_property(child_node,
+					"ibm,hfi-windows", NULL);
+	if (!lp) {
+		printk(KERN_ERR "%s: hfidd_dds_init: of_get_property"
+			" 'ibm,hfi-windows' failed\n", p_acs->name);
+		return -EINVAL;
+	}
+
+	pdds->window_num   = (int) (*lp >> HFI_WNUM_SHIFT);
+	pdds->window_start = (int) *lp;
+
+	if (pdds->window_num > MAX_WIN_PER_HFI) {
+		printk(KERN_ERR "%s: hfidd_dds_init: Max windows exceeded,"
+			" windows=%d\n", p_acs->name, pdds->window_num);
+		return -EINVAL;
+	}
+
+	lp = (unsigned long long *)of_get_property(child_node,
+				"ibm,hfi-misc-user-base-addr", NULL);
+	if (!lp) {
+		printk(KERN_ERR "%s: hfidd_dds_init: of_get_property"
+			" 'ibm,hfi-misc-user-base-addr' failed\n", p_acs->name);
+		return -EINVAL;
+	}
+	pdds->misc_base_address = *lp;
+
+	return 0;
+}
+
+/* Initialize adapter structure */
+int hfidd_init_adapter(struct hfidd_acs *p_acs, void *uiop)
+{
+	int rc = 0;
+
+	rc = hfidd_dds_init(p_acs, &(p_acs->dds));
+	p_acs->dds.num_d_windows = HFI_DYN_WINS_DEFAULT;
+	return rc;
+}
+
 /* Destroy the HFI class */
 static inline void hfidd_destroy_class(void)
 {
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index 01a5ba2..e2ed4c9 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -35,5 +35,6 @@
 
 int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t, void *uiop);
 void hfidd_free_adapter(struct hfidd_acs *p_acs);
+int hfidd_init_adapter(struct hfidd_acs *p_acs, void *uiop);
 
 #endif
diff --git a/include/linux/hfi/hfidd_adpt.h b/include/linux/hfi/hfidd_adpt.h
index 6b1432d..e3271e9 100644
--- a/include/linux/hfi/hfidd_adpt.h
+++ b/include/linux/hfi/hfidd_adpt.h
@@ -36,6 +36,11 @@
 #include <linux/hfi/hfidd_client.h>
 
 
+#define HFI_WNUM_SHIFT		32
+#define HFI_CAUNUM_SHIFT	32
+#define HFI_SHIFT_OCTANT	3
+#define HFI_MAX_OCTANT		7
+
 /* Adpt state */
 #define HFI_INVALID		0
 #define HFI_AVAIL		1
diff --git a/include/linux/hfi/hfidd_client.h b/include/linux/hfi/hfidd_client.h
index b738f4b..28f1693 100644
--- a/include/linux/hfi/hfidd_client.h
+++ b/include/linux/hfi/hfidd_client.h
@@ -36,5 +36,8 @@
 #define MAX_TORRENTS            1
 #define MAX_HFI_PER_TORRENT     2
 #define MAX_HFIS                (MAX_TORRENTS * MAX_HFI_PER_TORRENT)
+#define MAX_WIN_PER_HFI		256
+
+#define HFI_DYN_WINS_DEFAULT	32
 
 #endif /* _HFIDD_CLIENT_H_ */
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index 956e6b2..78a5763 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -46,6 +46,17 @@
 #define HFIDD_DEV_NAME		"hfi"
 #define HFIDD_CLASS_NAME	"hfi"
 
+struct hfidd_dds {
+	unsigned int		version;	/* HFI adapter type */
+	unsigned long long	misc_base_address; /* Misc user base address */
+	int			window_start;	/* window start for this HFI */
+	int			window_num;	/* window count for this HFI */
+	unsigned int		num_d_windows;	/* number of dynamic windows */
+	unsigned long long	torr_id;	/* torrent chip id */
+	unsigned int		hfi_id;		/* HFI Unit Id */
+	unsigned long long	fw_ec_level;	/* Firmware Level */
+};
+
 #define HFI_DEVICE_NAME_MAX 8
 /* hfi global */
 struct hfidd_acs {
@@ -55,6 +66,7 @@ struct hfidd_acs {
 	unsigned int		acs_cnt;
 	unsigned int		state;
 	struct device		*hfidd_dev;
+	struct hfidd_dds	dds;
 };
 
 /* DD global */
-- 
1.7.3.5

