From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 21/27] HFI: Add send and receive interrupts
Date: Thu, 21 Apr 2011 17:38:51 -0400
Message-ID: <1303421937-2325-22-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e1.ny.us.ibm.com ([32.97.182.141]:47276 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753755Ab1DUVjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:22 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLSfCJ026901
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:28:41 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdCOo622840
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:13 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLdCq9012772
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:12 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Each window has its own interrupt for send interrupts and another for receive
interrupts.

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
 drivers/net/hfi/core/Makefile       |    1 +
 drivers/net/hfi/core/hfidd_intr.c   |  127 +++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_proto.h  |    3 +
 drivers/net/hfi/core/hfidd_window.c |   16 ++++-
 include/linux/hfi/hfidd_client.h    |   17 +++++
 include/linux/hfi/hfidd_internal.h  |    2 +
 6 files changed, 165 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/hfi/core/hfidd_intr.c

diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
index 3adf07e..d2ed86f 100644
--- a/drivers/net/hfi/core/Makefile
+++ b/drivers/net/hfi/core/Makefile
@@ -6,5 +6,6 @@ hfi_core-objs:=	hfidd_adpt.o \
 		hfidd_init.o \
 		hfidd_xlat.o \
 		hfidd_map.o \
+		hfidd_intr.o \
 		hfidd_hcalls.o
 obj-$(CONFIG_HFI) += hfi_core.o
diff --git a/drivers/net/hfi/core/hfidd_intr.c b/drivers/net/hfi/core/hfidd_intr.c
new file mode 100644
index 0000000..253de27
--- /dev/null
+++ b/drivers/net/hfi/core/hfidd_intr.c
@@ -0,0 +1,127 @@
+/*
+ * hfidd_intr.c
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
+static irqreturn_t send_intr_handler(int irq, void *data)
+{
+	struct hfidd_window *win_p = data;
+	struct hfidd_acs *p_acs;
+
+	p_acs = hfidd_global.p_acs[win_p->ai];
+	if (p_acs == NULL)
+		return IRQ_HANDLED;
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t recv_intr_handler(int irq, void *data)
+{
+	struct hfidd_window *win_p = data;
+	struct hfidd_acs *p_acs;
+
+	p_acs = hfidd_global.p_acs[win_p->ai];
+	if (p_acs == NULL)
+		return IRQ_HANDLED;
+
+	return IRQ_HANDLED;
+}
+
+static inline void hfidd_clear_interrupt(unsigned int int_level,
+			struct hfidd_window *win_p)
+{
+	ibmebus_free_irq(int_level, win_p);
+}
+
+static int hfidd_init_interrupt(struct hfidd_acs *p_acs,
+		struct hfidd_window *win_p ,
+		irqreturn_t (*handler)(int, void *),
+		const char *name,
+		unsigned int int_level)
+{
+	int rc;
+
+	rc = ibmebus_request_irq(int_level, handler, IRQF_DISABLED, name,
+			win_p);
+	if (rc != 0) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_init_interrupt: request_irq failed for "
+			"int_level 0x%x rc %d\n", int_level, rc);
+		return rc;
+	}
+	return rc;
+}
+
+int hfidd_init_win_interrupt(struct hfidd_acs *p_acs,
+		struct hfidd_window *win_p)
+{
+	int rc;
+
+	/* init send interrupt handler */
+	snprintf(win_p->send_name, IRQ_NAME_SIZE - 1, "%s%d-send%d",
+		HFIDD_DEV_NAME, p_acs->index, win_p->index);
+	rc = hfidd_init_interrupt(p_acs, win_p, send_intr_handler,
+		win_p->send_name, win_p->send_intr);
+	if (rc != 0) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_init_win_interrupt: send int failed, "
+			"rc = 0x%x\n", rc);
+		return rc;
+	}
+
+	/* init recv interrupt handler */
+	snprintf(win_p->recv_name, IRQ_NAME_SIZE - 1, "%s%d-recv%d",
+		HFIDD_DEV_NAME, p_acs->index, win_p->index);
+	rc = hfidd_init_interrupt(p_acs, win_p, recv_intr_handler,
+		win_p->recv_name, win_p->recv_intr);
+	if (rc != 0) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_init_win_interrupt: recv int failed, "
+			"rc = 0x%x\n", rc);
+		hfidd_clear_interrupt(win_p->send_intr, win_p);
+		return rc;
+	}
+	return 0;
+}
+
+void hfidd_clear_win_interrupt(struct hfidd_window *win_p)
+{
+	if (win_p->send_intr != 0) {
+		hfidd_clear_interrupt(win_p->send_intr, win_p);
+		win_p->send_intr = 0;
+	}
+	if (win_p->recv_intr != 0) {
+		hfidd_clear_interrupt(win_p->recv_intr, win_p);
+		win_p->recv_intr = 0;
+	}
+}
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index f531dcd..af88f0b 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -73,6 +73,9 @@ int hfidd_query_interface(struct hfidd_acs *p_acs, unsigned int subtype,
 int hfidd_start_nmmu(struct hfidd_acs *p_acs);
 int hfidd_start_interface(struct hfidd_acs *p_acs);
 int hfidd_stop_interface(struct hfidd_acs *p_acs, unsigned int hfi_id);
+int hfidd_init_win_interrupt(struct hfidd_acs *p_acs,
+		struct hfidd_window *win_p);
+void hfidd_clear_win_interrupt(struct hfidd_window *win_p);
 long long hfi_start_nmmu(u64 chip_id, void *nmmu_info);
 long long hfi_stop_nmmu(u64 chip_id);
 long long hfi_open_window(u64 unit_id, u64 win_id, u64 flag,
diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index fd692eb..6864eae 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -1049,6 +1049,15 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 	local_p->local_isrid = p_acs->isr;
 	win_p->client_info.local_isrid = p_acs->isr;
 
+	/* Init the send and recv interrupt handlers */
+	rc = hfidd_init_win_interrupt(p_acs, win_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_open_window_func: hfidd_init_win_interrupt "
+			"failed, rc = 0x%x\n", rc);
+		goto hfidd_open_window_func_err6;
+	}
+
 	/* Copy out the client info back to user */
 	rc = hfi_copy_to_user((void *)out_p, (void *)local_p,
 			is_userspace, sizeof(struct hfi_client_info));
@@ -1056,7 +1065,7 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		dev_printk(KERN_ERR, p_acs->hfidd_dev,
 			"hfidd_open_window_func: hfi_copy_to_user "
 			"failed, rc = 0x%x\n", rc);
-		goto hfidd_open_window_func_err6;
+		goto hfidd_open_window_func_err7;
 	}
 
 	spin_lock(&(win_p->win_lock));
@@ -1068,6 +1077,8 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 	kfree(local_p);
 	return rc;
 
+hfidd_open_window_func_err7:
+	hfidd_clear_win_interrupt(win_p);
 hfidd_open_window_func_err6:
 	if (is_userspace)
 		hfidd_unmap(local_p->mmio_regs.use.kptr, PAGE_SIZE_64K);
@@ -1134,6 +1145,9 @@ int hfidd_close_window_internal(struct hfidd_acs *p_acs,
 	}
 	spin_unlock(&(win_p->win_lock));
 
+	/* Clear the send and recv interrupt handlers */
+	hfidd_clear_win_interrupt(win_p);
+
 	rc = hfi_unmap_mmio_regs(p_acs, win_p, is_userspace);
 	if (rc) {
 		dev_printk(KERN_ERR, p_acs->hfidd_dev,
diff --git a/include/linux/hfi/hfidd_client.h b/include/linux/hfi/hfidd_client.h
index 11c8973..3b2d032 100644
--- a/include/linux/hfi/hfidd_client.h
+++ b/include/linux/hfi/hfidd_client.h
@@ -121,6 +121,23 @@ struct hfi_window_info {
 	unsigned int		window;
 };
 
+/* Event Notification */
+enum hfi_event_type {
+	HFIDD_SEND		= 0,
+	HFIDD_RECV		= 1,
+	HFIDD_WIN_ERROR		= 2,
+	HFIDD_HFI_ERROR		= 3,
+	HFIDD_TERMINATE		= 4,
+	HFIDD_RELEASE_WINDOW	= 5,
+	HFIDD_CAU_ERROR		= 6,
+	HFIDD_ICS_ERROR		= 7,
+	HFIDD_HFI_READY_REG	= 8,
+	HFIDD_ROUTE_CHANGE	= 9,
+	HFIDD_IP_TRC_LVL	= 10,	/* IP Window only */
+	HFIDD_POOL_SIZE		= 11,	/* IP Window only */
+	HFIDD_NUM_EVENT_TYPES	= 12
+};
+
 #define MAX_TORRENTS            1
 #define MAX_HFI_PER_TORRENT     2
 #define MAX_HFIS                (MAX_TORRENTS * MAX_HFI_PER_TORRENT)
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index 820df48..f82a626 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -145,6 +145,8 @@ struct hfidd_global {
 	struct hfidd_acs	*p_acs[MAX_HFIS];
 };
 
+extern struct hfidd_global hfidd_global;
+
 static inline struct hfidd_window *hfi_window(struct hfidd_acs *p,
 		unsigned int idx)
 {
-- 
1.7.3.5

