From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 08/27] HFI: DD request framework and first HFI DD request
Date: Thu, 21 Apr 2011 17:38:38 -0400
Message-ID: <1303421937-2325-9-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e3.ny.us.ibm.com ([32.97.182.143]:33325 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755351Ab1DUVjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:25 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLI9UJ022958
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:18:09 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdBat1417420
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:13 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLd9C7012541
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:11 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

We use an ioctl-ish mechanism similar to the one found in the HEA driver.
Some of our requests have very large parameter lists, this method allows
us to get the parms into the DD quickly.

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
 drivers/net/hfi/core/hfidd_init.c  |   94 +++++++++++++++++++++++++++++++++++-
 include/linux/hfi/Kbuild           |    1 +
 include/linux/hfi/hfidd_client.h   |   40 +++++++++++++++
 include/linux/hfi/hfidd_internal.h |   23 ++++++++-
 include/linux/hfi/hfidd_requests.h |   38 ++++++++++++++
 5 files changed, 192 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/hfi/hfidd_requests.h

diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
index 3dcaa8f..df79ae9 100644
--- a/drivers/net/hfi/core/hfidd_init.c
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -36,6 +36,7 @@
 #include <linux/of.h>
 
 #include <linux/hfi/hfidd_internal.h>
+#include <linux/hfi/hfidd_requests.h>
 #include "hfidd_proto.h"
 
 MODULE_VERSION("1.0");
@@ -59,11 +60,102 @@ static ssize_t hfidd_read(struct file *filep, char *buf, size_t count,
 	return 0;
 }
 
+/* Query firmare level and use abi version to users */
+static int hfidd_query_dd_info(struct hfidd_acs *p_acs,
+			struct hfi_query_dd_info *user_p)
+{
+	struct hfi_query_dd_info req;
+	int rc;
+
+	req.fw_ec_level = p_acs->dds.fw_ec_level;
+	req.abi_version = HFIDD_USER_ABI_VERSION;
+
+	rc = copy_to_user(user_p, &req, sizeof(struct hfi_query_dd_info));
+	if (rc)
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_query_dd_info: copy_to_user failed\n");
+
+	return rc;
+}
+
 /* Entry point for user space to do driver requests. */
 static ssize_t hfidd_cmd_write(struct file *filep, const char __user *buf,
 		size_t count, loff_t *pos)
 {
-	return 0;
+	struct hfidd_acs	*p_acs;
+	int			ai;
+	int			cnt = 0;
+	int			rc = 0;
+	struct hfi_req_hdr	cmd;
+	int			is_userspace;
+
+	ai = iminor(filep->f_path.dentry->d_inode);
+	if (ai >= MAX_HFIS) {
+		printk(KERN_ERR "%s: hfidd_cmd_write: wrong ai = %d\n",
+				HFIDD_DEV_NAME, ai);
+		return -ENODEV;
+	}
+
+	p_acs = hfidd_global.p_acs[ai];
+	if (p_acs == NULL) {
+		printk(KERN_ERR "%s: hfidd_cmd_write: p_acs is NULL\n",
+				HFIDD_DEV_NAME);
+		return -EINVAL;
+	}
+
+	if (count < sizeof(cmd)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_cmd_write: Invalid count: 0x%lx expected "
+			"count: 0x%lx\n", count, sizeof(cmd));
+		return -EINVAL;
+	}
+
+	is_userspace = 1;
+	if (segment_eq(get_fs(), KERNEL_DS))
+		is_userspace = 0;
+
+	if (copy_from_user(&cmd, buf, sizeof(cmd))) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_cmd_write: copy_from_user failed\n");
+		return -EINVAL;
+	}
+
+	if (cmd.abi_version != HFIDD_USER_ABI_VERSION) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_cmd_write: wrong abi_version %d, "
+			"should be %d for cmd 0x%x\n",
+			cmd.abi_version, HFIDD_USER_ABI_VERSION, cmd.req);
+		return -EINVAL;
+	}
+
+	switch (cmd.req) {
+	case HFIDD_REQ_QUERY_DD_INFO:
+		if (cmd.req_len != sizeof(struct hfi_query_dd_info)) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_cmd_write: hdr.reqlen 0x%x expected "
+				"0x%x for cmd req 0x%x\n",
+				cmd.req_len, (unsigned int)
+				sizeof(struct hfi_query_dd_info), cmd.req);
+			return -EINVAL;
+		}
+		rc = hfidd_query_dd_info(p_acs, (struct hfi_query_dd_info *)
+			cmd.result.use.kptr);
+		break;
+
+	default:
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_cmd_write: invalid cmd = 0x%x\n", cmd.req);
+		return -EINVAL;
+	}
+
+	if (rc == 0)
+		cnt = count;
+	else
+		cnt = rc;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"hfidd_cmd_write: Exit cmd = 0x%x rc = 0x%x\n", cmd.req, rc);
+	return cnt;
 }
 
 static const struct file_operations hfidd_fops = {
diff --git a/include/linux/hfi/Kbuild b/include/linux/hfi/Kbuild
index 3a742ce..6637c65 100644
--- a/include/linux/hfi/Kbuild
+++ b/include/linux/hfi/Kbuild
@@ -1 +1,2 @@
 header-y += hfidd_client.h
+header-y += hfidd_requests.h
diff --git a/include/linux/hfi/hfidd_client.h b/include/linux/hfi/hfidd_client.h
index 2714a27..b2ebd01 100644
--- a/include/linux/hfi/hfidd_client.h
+++ b/include/linux/hfi/hfidd_client.h
@@ -33,11 +33,51 @@
 #ifndef _HFIDD_CLIENT_H_
 #define _HFIDD_CLIENT_H_
 
+
+#define HFIDD_USER_ABI_VERSION  1
+
+
+/*
+ * New ioctls are not allowed.  We will use write() calls to pass
+ * in an ioctl-looking request, with struct hfi_req_hdr giving the
+ * information we used to get from the ioctl() parameter list.  The
+ * write() call will copy out the request structure to the buffer pointed
+ * to by result, which is probably the original request.
+ */
+
+struct hfi_64b {
+	union {
+		unsigned long long	allu;	/* APPLICATION Long long
+						   Unsigned 64 bit address
+						   container */
+		void			*kptr;	/* KERNEL Pointer 64 bit
+						   container */
+	} use;
+};
+
+/* Request header: first structure in each of the HFI DD requests */
+struct hfi_req_hdr {
+	unsigned int	req;			/* HFIDD_REQ_* */
+	unsigned int	req_len;		/* length of req, in bytes */
+	unsigned int	abi_version;		/* ABI version */
+	struct hfi_64b	result;			/* user eaddr for output */
+};
+#define HFIDD_REQ_HDR_SIZE			sizeof(struct hfi_req_hdr)
+
 #define MAX_TORRENTS            1
 #define MAX_HFI_PER_TORRENT     2
 #define MAX_HFIS                (MAX_TORRENTS * MAX_HFI_PER_TORRENT)
 #define MAX_WIN_PER_HFI		256
 
+/*
+ * HFIDD_REQ_QUERY_DD_INFO
+ */
+struct hfi_query_dd_info {
+	struct hfi_req_hdr	hdr;
+	unsigned long long	fw_ec_level;	/* Hardware Version */
+	unsigned int	abi_version;	/* ABI Version */
+};
+
 #define HFI_DYN_WINS_DEFAULT	32
 
 #define PAGE_SIZE_4K		0x1000
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index c7c67ca..0cc8c88 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -36,12 +36,29 @@
 #include <linux/fs.h>
 #include <linux/kobject.h>
 #include <linux/cdev.h>
+#include <linux/compat.h>
+#include <linux/compiler.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/mman.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/poll.h>
 #include <linux/slab.h>
-#include <linux/jiffies.h>
-#include <linux/device.h>
-
+#include <linux/vermagic.h>
+#include <linux/delay.h>
+#include <linux/vmalloc.h>
+#include <linux/timer.h>
+#include <linux/spinlock.h>
+#include <linux/sched.h>
+#include <asm/cputable.h>
+#include <linux/io.h>
+#include <asm/machdep.h>
+#include <linux/mmu_context.h>
+#include <asm/pgalloc.h>
+#include <asm/ibmebus.h>
+#include <linux/kthread.h>
 #include <linux/hfi/hfidd_client.h>
 #include <linux/hfi/hfidd_adpt.h>
 #include <linux/hfi/hfidd_hcalls.h>
diff --git a/include/linux/hfi/hfidd_requests.h b/include/linux/hfi/hfidd_requests.h
new file mode 100644
index 0000000..b6e255f
--- /dev/null
+++ b/include/linux/hfi/hfidd_requests.h
@@ -0,0 +1,38 @@
+/*
+ * hfidd_requests.h
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
+#ifndef _HFIDD_REQUESTS_H_
+#define _HFIDD_REQUESTS_H_
+
+#define HFIDD_REQ_QUERY_DD_INFO			0x00001004
+
+#endif /* _HFIDD_REQUESTS_H_ */
-- 
1.7.3.5

