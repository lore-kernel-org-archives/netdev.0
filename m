From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v4 05/27] HFI: The first few HFI-specific hypervisor calls
Date: Mon, 25 Apr 2011 17:23:45 -0400
Message-ID: <1303766647-30156-6-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e32.co.us.ibm.com ([32.97.110.150]:36599 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590Ab1DYVYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 17:24:20 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PLDAR7003314
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:13:10 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3PLOHX8099834
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:17 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PLOG08032227
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:17 -0600
In-Reply-To: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

H_HFI_START_INTERFACE Notifies the hypervisor that a new instance of the DD is
starting, and any leftover state should be considered stale.
H_HFI_STOP_INTERFACE tells the hypervisor that the DD is unloading, and to
clean up any activity related to this DD instance.
H_HFI_QUERY_INTERFACE lets us get info about the HFIs that is not in the
device tree.

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
 drivers/net/hfi/core/Makefile       |    3 +-
 drivers/net/hfi/core/hfidd_adpt.c   |  139 +++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_hcalls.c |   90 ++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_proto.h  |   12 +++
 include/linux/hfi/hfidd_client.h    |    8 ++
 include/linux/hfi/hfidd_hcalls.h    |   58 +++++++++++++++
 include/linux/hfi/hfidd_internal.h  |    7 ++-
 7 files changed, 315 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/hfi/core/hfidd_hcalls.c
 create mode 100644 include/linux/hfi/hfidd_hcalls.h

diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
index 6fe4e60..4e6cbd6 100644
--- a/drivers/net/hfi/core/Makefile
+++ b/drivers/net/hfi/core/Makefile
@@ -2,5 +2,6 @@
 # Makefile for the HFI device driver for IBM eServer System p
 #
 hfi_core-objs:=	hfidd_adpt.o \
-		hfidd_init.o
+		hfidd_init.o \
+		hfidd_hcalls.o
 obj-$(CONFIG_HFI) += hfi_core.o
diff --git a/drivers/net/hfi/core/hfidd_adpt.c b/drivers/net/hfi/core/hfidd_adpt.c
index f309a02..fd4a0cb 100644
--- a/drivers/net/hfi/core/hfidd_adpt.c
+++ b/drivers/net/hfi/core/hfidd_adpt.c
@@ -33,6 +33,18 @@
 #include <linux/hfi/hfidd_internal.h>
 #include "hfidd_proto.h"
 
+#define HFIDD_TIME_AGE  (10 * HZ)
+
+int hfidd_age_hcall(u64 time_start)
+{
+	u64	timestamp = get_jiffies_64();
+
+	if ((timestamp - time_start) > HFIDD_TIME_AGE)
+		return 1;
+	else
+		return 0;
+}
+
 int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t devno, void *uiop)
 {
 
@@ -66,3 +78,130 @@ void hfidd_free_adapter(struct hfidd_acs *p_acs)
 {
 	kfree(p_acs);
 }
+
+/* Allocate the page for the HCALL */
+int hfidd_get_phyp_page(struct hfidd_acs *p_acs, caddr_t *page, caddr_t *laddr,
+	int size)
+{
+	*page = (caddr_t)__get_free_pages(GFP_KERNEL, get_order(size));
+	if (*page == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_get_phyp_page: __get_free_pages failed\n");
+		return -ENOMEM;
+	}
+
+	/* translate virtual to logical address */
+	*laddr = (caddr_t)__pa((caddr_t) *page);
+	memset(*page, 0, size);
+	return 0;
+}
+
+/* Release the page allocated for the HCALL */
+inline void hfidd_release_phyp_page(caddr_t page, int size)
+{
+	free_pages((unsigned long)page, get_order(size));
+}
+
+int hfidd_query_interface(struct hfidd_acs *p_acs, unsigned int subtype,
+		unsigned int hfi_id, unsigned long long *state)
+{
+	long long		hvrc;
+	int			rc = 0;
+	struct hfi_query_interface *query_p;
+	caddr_t			laddr = NULL;
+
+	if (subtype != COMP_QUERY && subtype != EEH_QUERY) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_query_interface: subtype not supported, %d\n",
+			subtype);
+		return -EINVAL;
+	}
+
+	if (subtype == COMP_QUERY) {
+		/* Allocate the page for the HCALL */
+		rc = hfidd_get_phyp_page(p_acs, (caddr_t *)&query_p, &laddr,
+				PAGE_SIZE_4K);
+		if (rc) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_query_interface: hfidd_get_phyp_page "
+				"failed\n");
+			return -ENOMEM;
+		}
+	}
+
+	hvrc = hfi_hquery_interface(hfi_id, subtype,
+		(unsigned long long)laddr, state);
+	if (hvrc != H_SUCCESS) {
+		rc = -EPERM;
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_query_interface: failed, state 0x%llx "
+			"hvrc 0x%llx\n", *state, hvrc);
+		goto query1;
+	}
+
+	if (subtype == COMP_QUERY) {
+		if (*state == ACTIVE) {
+			if (p_acs->state != HFI_AVAIL) {
+				p_acs->isr = query_p->local_node_id;
+				p_acs->state = HFI_AVAIL;
+			}
+		} else {
+			p_acs->state = HFI_UNAVAIL;
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_query_interface: Bad state %lld, "
+				"return ENODEV\n", *state);
+			rc = -EIO;
+		}
+	}
+
+query1:
+	if (subtype == COMP_QUERY)
+		hfidd_release_phyp_page((caddr_t)query_p, PAGE_SIZE_4K);
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_query_interface: return rc %d\n", rc);
+	return rc;
+}
+
+int hfidd_start_interface(struct hfidd_acs *p_acs)
+{
+	long long hvrc = 0;
+	int	rc = 0;
+	u64	start_time = get_jiffies_64();
+
+	while (1) {
+		hvrc = hfi_start_interface(p_acs->dds.hfi_id);
+		if (hvrc != H_BUSY)
+			break;
+		if (hfidd_age_hcall(start_time))
+			break;
+	}
+	if (hvrc != H_SUCCESS) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_start_interface: HFI_START_INTERFACE failed "
+			"hvrc 0x%llx\n", hvrc);
+		rc = -EPERM;
+	}
+	return rc;
+}
+
+int hfidd_stop_interface(struct hfidd_acs *p_acs, unsigned int hfi_id)
+{
+	long long hvrc = 0;
+	int	rc = 0;
+	u64	start_time = get_jiffies_64();
+
+	while (1) {
+		hvrc = hfi_stop_interface(hfi_id);
+		if (hvrc != H_BUSY)
+			break;
+		if (hfidd_age_hcall(start_time))
+			break;
+	}
+	if (hvrc != H_SUCCESS) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_stop_interface: HFI_STOP_INTERFACE failed "
+			"hvrc 0x%llx\n", hvrc);
+		rc = -EPERM;
+	}
+	return rc;
+}
diff --git a/drivers/net/hfi/core/hfidd_hcalls.c b/drivers/net/hfi/core/hfidd_hcalls.c
new file mode 100644
index 0000000..84467b3
--- /dev/null
+++ b/drivers/net/hfi/core/hfidd_hcalls.c
@@ -0,0 +1,90 @@
+/*
+ * hfidd_hcalls.c
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
+static inline long long h_hfi_start_interface(int token,
+		u64 HFI_chip_ID)
+{
+	return plpar_hcall_norets(token, HFI_chip_ID);
+}
+
+static inline long long h_hfi_stop_interface(int token,
+		u64 HFI_chip_ID)
+{
+	return plpar_hcall_norets(token, HFI_chip_ID);
+}
+
+static inline long long h_hfi_query_interface(int token,
+		u64 HFI_chip_ID,
+		u64 type,
+		u64 output_page_ptr,
+		u64 *state)
+{
+	long long rc;
+	u64 hyp_outputs[PLPAR_HCALL_BUFSIZE];
+
+	rc = plpar_hcall(token, (unsigned long *)hyp_outputs, HFI_chip_ID, type,
+			output_page_ptr);
+	*state = hyp_outputs[0];	/* 1st ret value */
+
+	return rc;
+}
+
+long long hfi_hquery_interface(u64 unit_id, u64 subtype,
+			       u64 query_p, u64 *state)
+{
+	long long	hvrc;
+
+	hvrc = h_hfi_query_interface(H_HFI_QUERY_INTERFACE,
+			unit_id,
+			subtype,
+			query_p,
+			state);
+	return hvrc;
+}
+
+long long hfi_start_interface(u64 unit_id)
+{
+	return h_hfi_start_interface(H_HFI_START_INTERFACE,
+			unit_id);
+}
+
+long long hfi_stop_interface(u64 unit_id)
+{
+	long long	hvrc;
+
+	hvrc = h_hfi_stop_interface(H_HFI_STOP_INTERFACE,
+			unit_id);
+	return hvrc;
+}
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index e2ed4c9..6ec9245 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -36,5 +36,17 @@
 int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t, void *uiop);
 void hfidd_free_adapter(struct hfidd_acs *p_acs);
 int hfidd_init_adapter(struct hfidd_acs *p_acs, void *uiop);
+int hfidd_age_hcall(u64 time_start);
+int hfidd_get_phyp_page(struct hfidd_acs *p_acs, caddr_t *page,
+	caddr_t *laddr, int size);
+void hfidd_release_phyp_page(caddr_t page, int size);
+int hfidd_query_interface(struct hfidd_acs *p_acs, unsigned int subtype,
+	unsigned int hfi_id, unsigned long long *state);
+int hfidd_start_interface(struct hfidd_acs *p_acs);
+int hfidd_stop_interface(struct hfidd_acs *p_acs, unsigned int hfi_id);
+long long hfi_hquery_interface(u64 unit_id, u64 subtype, u64 query_p,
+		u64 *state);
+long long hfi_start_interface(u64 unit_id);
+long long hfi_stop_interface(u64 unit_id);
 
 #endif
diff --git a/include/linux/hfi/hfidd_client.h b/include/linux/hfi/hfidd_client.h
index 28f1693..2714a27 100644
--- a/include/linux/hfi/hfidd_client.h
+++ b/include/linux/hfi/hfidd_client.h
@@ -40,4 +40,12 @@
 
 #define HFI_DYN_WINS_DEFAULT	32
 
+#define PAGE_SIZE_4K		0x1000
+#define PAGE_SIZE_64K		0x10000
+#define PAGE_SIZE_1M		0x100000
+#define PAGE_SIZE_16M		0x1000000
+#define PAGE_SIZE_256M		0x10000000
+#define PAGE_SIZE_4G		0x100000000
+#define PAGE_SIZE_16G		0x400000000
+
 #endif /* _HFIDD_CLIENT_H_ */
diff --git a/include/linux/hfi/hfidd_hcalls.h b/include/linux/hfi/hfidd_hcalls.h
new file mode 100644
index 0000000..5349e9e
--- /dev/null
+++ b/include/linux/hfi/hfidd_hcalls.h
@@ -0,0 +1,58 @@
+/*
+ * hfidd_hcalls.h
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
+#ifndef _HFIDD_HCALLS_H_
+#define _HFIDD_HCALLS_H_
+
+#include <asm/hvcall.h>
+
+/* Token IDs */
+#define H_HFI_START_INTERFACE		0xF000
+#define H_HFI_QUERY_INTERFACE		0xF004
+#define H_HFI_STOP_INTERFACE		0xF008
+
+#define EEH_QUERY	1
+#define COMP_QUERY	2
+
+/* States of Query interface */
+#define NOT_READY	0
+#define NOT_STARTED	1
+#define ACTIVE		2
+#define CLOSING	3
+#define ERROR		101
+
+struct hfi_query_interface {
+	unsigned long long	hypervisor_capabilities;
+	unsigned int		local_node_id;
+};
+
+#endif /* _HFIDD_HCALLS_H_ */
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index 78a5763..c7c67ca 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -39,10 +39,12 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
+#include <linux/jiffies.h>
+#include <linux/device.h>
 
 #include <linux/hfi/hfidd_client.h>
 #include <linux/hfi/hfidd_adpt.h>
-
+#include <linux/hfi/hfidd_hcalls.h>
 #define HFIDD_DEV_NAME		"hfi"
 #define HFIDD_CLASS_NAME	"hfi"
 
@@ -65,6 +67,9 @@ struct hfidd_acs {
 	unsigned int		index;
 	unsigned int		acs_cnt;
 	unsigned int		state;
+
+	unsigned int		isr;
+
 	struct device		*hfidd_dev;
 	struct hfidd_dds	dds;
 };
-- 
1.7.3.5

