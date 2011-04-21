From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 10/27] HFI: HFIDD_REQ_OPEN_WINDOW request
Date: Thu, 21 Apr 2011 17:38:40 -0400
Message-ID: <1303421937-2325-11-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e1.ny.us.ibm.com ([32.97.182.141]:47282 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755177Ab1DUVjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:23 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLSfq7026910
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:28:41 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdCbF2076784
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:12 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLd90A012563
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:11 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Set up protocol access to an HFI window.

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
 drivers/net/hfi/core/hfidd_init.c   |   14 +++++++
 drivers/net/hfi/core/hfidd_proto.h  |    3 +
 drivers/net/hfi/core/hfidd_window.c |   70 +++++++++++++++++++++++++++++++++++
 include/linux/hfi/hfidd_client.h    |   22 +++++++++++
 include/linux/hfi/hfidd_internal.h  |   26 +++++++++++++
 include/linux/hfi/hfidd_requests.h  |    1 +
 7 files changed, 137 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/hfi/core/hfidd_window.c

diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
index 4e6cbd6..0224a57 100644
--- a/drivers/net/hfi/core/Makefile
+++ b/drivers/net/hfi/core/Makefile
@@ -2,6 +2,7 @@
 # Makefile for the HFI device driver for IBM eServer System p
 #
 hfi_core-objs:=	hfidd_adpt.o \
+		hfidd_window.o \
 		hfidd_init.o \
 		hfidd_hcalls.o
 obj-$(CONFIG_HFI) += hfi_core.o
diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
index df79ae9..49099ec 100644
--- a/drivers/net/hfi/core/hfidd_init.c
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -129,6 +129,20 @@ static ssize_t hfidd_cmd_write(struct file *filep, const char __user *buf,
 	}
 
 	switch (cmd.req) {
+	case HFIDD_REQ_OPEN_WINDOW:
+		if (cmd.req_len != sizeof(struct hfi_client_info)) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_cmd_write: hdr.reqlen 0x%x expected "
+				"0x%lx for cmd req 0x%x\n",
+				cmd.req_len,
+				sizeof(struct hfi_client_info), cmd.req);
+			return -EINVAL;
+		}
+		rc = hfidd_open_window_func(p_acs, is_userspace,
+			(struct hfi_client_info *) buf,
+			(struct hfi_client_info *) cmd.result.use.kptr);
+		break;
+
 	case HFIDD_REQ_QUERY_DD_INFO:
 		if (cmd.req_len != sizeof(struct hfi_query_dd_info)) {
 			dev_printk(KERN_ERR, p_acs->hfidd_dev,
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index c61387e..e7f2901 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -39,6 +39,9 @@ int hfidd_alloc_windows(struct hfidd_acs *p_acs);
 void hfidd_free_windows(struct hfidd_acs *p_acs);
 int hfidd_init_adapter(struct hfidd_acs *p_acs, void *uiop);
 int hfidd_age_hcall(u64 time_start);
+int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
+		struct hfi_client_info *user_p,
+		struct hfi_client_info *out_p);
 int hfidd_get_phyp_page(struct hfidd_acs *p_acs, caddr_t *page,
 	caddr_t *laddr, int size);
 void hfidd_release_phyp_page(caddr_t page, int size);
diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
new file mode 100644
index 0000000..f16caf7
--- /dev/null
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -0,0 +1,70 @@
+/*
+ * hfidd_window.c
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
+#include <linux/hfi/hfidd_hcalls.h>
+#include "hfidd_proto.h"
+#include <linux/hfi/hfidd_requests.h>
+
+/*
+ * Allows an user/kernel window to send/receive network traffic thru HFI
+ * adapter. This function will allocate the system resources needed to open
+ * a window. If any problem detected, then the request will fail. This function
+ * is called directly by kernel users and by a write system call by userspace.
+ */
+int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
+		struct hfi_client_info *user_p,
+		struct hfi_client_info *out_p)
+{
+	int			rc = 0;
+	struct hfi_client_info	*local_p = NULL;
+
+	/* Allocate local data structure */
+	local_p = kmalloc(sizeof(struct hfi_client_info), GFP_KERNEL);
+	if (local_p == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"open_window_func: kmalloc local_p failed\n");
+		return -ENOMEM;
+	}
+
+	/* Copy into local from user */
+	rc = hfi_copy_from_user((void *)local_p, (void *)user_p,
+			is_userspace, sizeof(struct hfi_client_info));
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"open_window_func: hfi_copy_from_user failed\n");
+	}
+
+	kfree(local_p);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(hfidd_open_window_func);
diff --git a/include/linux/hfi/hfidd_client.h b/include/linux/hfi/hfidd_client.h
index c3c8fef..7e4c1a7 100644
--- a/include/linux/hfi/hfidd_client.h
+++ b/include/linux/hfi/hfidd_client.h
@@ -69,6 +69,28 @@ struct fifo_info {
 	unsigned long long	size;		/* bytes */
 };
 
+/*
+ * HFIDD_REQ_OPEN_WINDOW: Window Open
+ * For reserved windows
+ *	The job scheduler provides the application with window number and
+ *	jobid, which need to be passed in/will be checked on the window open.
+ *	Immediate send slots were also reserved by the job scheduler, and the
+ *	DD returns the count. The application has the option of setting
+ *	protection keys by task or by jobid. Protection key is passed in.
+ * For Dynamic windows
+ *	The DD will select a free dynamic window and return its window number.
+ *	The jobid will be assigned by the DD (upper bits set to select a
+ *	reserved range of jobids, lower bits come from userid).  The
+ *	protection key flag is always by task. The protection key is passed in.
+ * For Kernel/IP windows
+ *	The DD will select a free dynamic window and return its window number.
+ *	The jobid is passed in. The jobid is used for the protection key.
+ *
+ * Finished vectors:
+ *	sfifo_finishvec and imm_finishvec must reside in an extra page (last
+ *	page) in the sfifo memory range, provided by the user.
+ */
+
 #define HFIDD_IP_WIN		1	/* IP windows get broadcasts forwarded
 						to them... */
 #define HFIDD_KERNEL_WIN	2	/* ... other kernel windows do not */
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index 420d55a..951314a 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -142,4 +142,30 @@ struct hfidd_global {
 	struct hfidd_acs	*p_acs[MAX_HFIS];
 };
 
+static inline int hfi_copy_to_user(void *user_p, void *local_p,
+		unsigned int is_userspace, unsigned int size)
+{
+	int	rc = 0;
+
+	if (is_userspace)
+		rc = copy_to_user(user_p, local_p, size);
+	else
+		memcpy(user_p, local_p, size);
+
+	return rc;
+}
+
+static inline int hfi_copy_from_user(void *local_p, void *user_p,
+		unsigned int is_userspace, unsigned int size)
+{
+	int	rc = 0;
+
+	if (is_userspace)
+		rc = copy_from_user(local_p, user_p, size);
+	else
+		memcpy(local_p, user_p, size);
+
+	return rc;
+}
+
 #endif
diff --git a/include/linux/hfi/hfidd_requests.h b/include/linux/hfi/hfidd_requests.h
index b6e255f..4f1c74d 100644
--- a/include/linux/hfi/hfidd_requests.h
+++ b/include/linux/hfi/hfidd_requests.h
@@ -33,6 +33,7 @@
 #ifndef _HFIDD_REQUESTS_H_
 #define _HFIDD_REQUESTS_H_
 
+#define HFIDD_REQ_OPEN_WINDOW			0x00000a01
 #define HFIDD_REQ_QUERY_DD_INFO			0x00001004
 
 #endif /* _HFIDD_REQUESTS_H_ */
-- 
1.7.3.5

