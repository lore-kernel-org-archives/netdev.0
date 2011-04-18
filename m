From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v2 19/27] HFI: Add window close request
Date: Sun, 17 Apr 2011 23:21:51 -0400
Message-ID: <1303096919-7367-20-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38155 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248Ab1DRDWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:22:34 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I33HfY018607
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:03:17 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3I3MX69210750
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:33 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3MWRg001354
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:33 -0400
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
 drivers/net/hfi/core/hfidd_init.c   |   36 +++++++++
 drivers/net/hfi/core/hfidd_proto.h  |    4 +
 drivers/net/hfi/core/hfidd_window.c |  148 +++++++++++++++++++++++++++++++++++
 include/linux/hfi/hfidd_client.h    |    8 ++
 include/linux/hfi/hfidd_hcalls.h    |    1 +
 include/linux/hfi/hfidd_requests.h  |    1 +
 6 files changed, 198 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
index 197fcc3..783ce1b 100644
--- a/drivers/net/hfi/core/hfidd_init.c
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -79,6 +79,20 @@ static int hfidd_query_dd_info(struct hfidd_acs *p_acs,
 	return rc;
 }
 
+/*
+ * This function is to check which command will be allowed after we got
+ * hfi error.
+ */
+static inline int valid_cmd_for_hfi_error(int cmd)
+{
+	switch (cmd) {
+	case HFIDD_REQ_CLOSE_WINDOW:
+		return 0;
+	default:
+		return -1;
+	}
+}
+
 /* Entry point for user space to do driver requests. */
 static ssize_t hfidd_cmd_write(struct file *filep, const char __user *buf,
 		size_t count, loff_t *pos)
@@ -129,6 +143,15 @@ static ssize_t hfidd_cmd_write(struct file *filep, const char __user *buf,
 		return -EINVAL;
 	}
 
+	if (p_acs->state != HFI_AVAIL) {
+		if (valid_cmd_for_hfi_error(cmd.req)) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_write_cmd: hfi%d not avail, "
+				"state 0x%x for cmd 0x%x\n",
+				p_acs->index, p_acs->state, cmd.req);
+			return -EIO;
+		}
+	}
 	switch (cmd.req) {
 	case HFIDD_REQ_OPEN_WINDOW:
 		if (cmd.req_len != sizeof(struct hfi_client_info)) {
@@ -144,6 +167,19 @@ static ssize_t hfidd_cmd_write(struct file *filep, const char __user *buf,
 			(struct hfi_client_info *) cmd.result.use.kptr);
 		break;
 
+	case HFIDD_REQ_CLOSE_WINDOW:
+		if (cmd.req_len != sizeof(struct hfi_window_info)) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_cmd_write: hdr.reqlen 0x%x expected "
+				"0x%lx for cmd req 0x%x\n",
+				cmd.req_len,
+				sizeof(struct hfi_window_info), cmd.req);
+			return -EINVAL;
+		}
+		rc = hfidd_close_window_func(p_acs, is_userspace,
+				(struct hfi_window_info *) buf);
+		break;
+
 	case HFIDD_REQ_QUERY_DD_INFO:
 		if (cmd.req_len != sizeof(struct hfi_query_dd_info)) {
 			dev_printk(KERN_ERR, p_acs->hfidd_dev,
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index 1f7fe80..e065d56 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -54,6 +54,10 @@ int hfidd_get_page_num(struct hfidd_acs *p_acs, void *start_addr,
 int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		struct hfi_client_info *user_p,
 		struct hfi_client_info *out_p);
+int hfidd_close_window_internal(struct hfidd_acs *p_acs,
+		unsigned int is_userspace, unsigned int win_num);
+int hfidd_close_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
+		struct hfi_window_info *user_p);
 int hfi_register_rpages(struct hfidd_acs *p_acs, unsigned long long mr_handle,
 		unsigned int submr, struct hfidd_vlxmem *xtab_p,
 		unsigned int *mapped_pages);
diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index 5d319a1..3cfe5c3 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -874,6 +874,28 @@ setup_window_parm_err1:
 	return rc;
 }
 
+/* Unmap the window mmio registers - only user space window */
+static int hfi_unmap_mmio_regs(struct hfidd_acs *p_acs,
+		struct hfidd_window *win_p,
+		unsigned int is_userspace)
+{
+	int	rc = 0;
+
+	if (is_userspace) {
+		rc = hfidd_unmap((void *)
+				(win_p->client_info.mmio_regs.use.kptr),
+				PAGE_SIZE_64K);
+		if (rc) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfi_unmap_mmio_regs: hfidd_unmap failed "
+				"rc = 0x%x\n", rc);
+			return rc;
+		}
+		win_p->client_info.mmio_regs.use.kptr = NULL;
+	}
+	return 0;
+}
+
 /* Map the window mmio registers - only user space window */
 static int hfi_map_mmio_regs(struct hfidd_acs *p_acs,
 		unsigned int is_userspace,
@@ -1023,3 +1045,129 @@ hfidd_open_window_func_err1:
 	return rc;
 }
 EXPORT_SYMBOL_GPL(hfidd_open_window_func);
+
+/*
+ * Close an user/kernel window to stop send/receive network traffic thru
+ * HFI adapter. This function will call PHYP to close the window and
+ * release the system resources allocated during open time. This function
+ * is called by hfidd_close_window_func or by abnormal end handler when
+ * the process goes away.
+ */
+int hfidd_close_window_internal(struct hfidd_acs *p_acs,
+		unsigned int is_userspace, unsigned int win_num)
+{
+	struct hfidd_window	*win_p;
+	int			rc = 0;
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"close_window_internal: win_num=0x%x\n", win_num);
+
+	if ((win_num <  min_hfi_windows(p_acs)) ||
+	    (win_num >= max_hfi_windows(p_acs))) {
+		rc = -EINVAL;
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"close_window_internal: window too large - "
+			"0x%x rc = 0x%x\n", win_num, rc);
+		goto hfidd_close_window_internal_err0;
+	}
+
+	win_p = hfi_window(p_acs, win_num);
+	if (win_p == NULL) {
+		rc = -ENOENT;
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"close_window_internal: win_p is NULL rc=0x%x\n", rc);
+		goto hfidd_close_window_internal_err0;
+	}
+
+	spin_lock(&(win_p->win_lock));
+
+	/* Make sure state is open or error state. */
+	if ((win_p->state != WIN_OPENED) &&
+	    (win_p->state != WIN_SUSPENDED) &&
+	    (win_p->state != WIN_ERROR)  &&
+	    (win_p->state != WIN_HERROR)) {
+		rc = -EFAULT;
+		spin_unlock(&(win_p->win_lock));
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_close_window_internal: bad window state=0x%x, "
+			"rc = 0x%x\n",  win_p->state, rc);
+		goto hfidd_close_window_internal_err0;
+	}
+	spin_unlock(&(win_p->win_lock));
+
+	rc = hfi_unmap_mmio_regs(p_acs, win_p, is_userspace);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_close_window_internal: hfi_unmap_mmio_regs "
+			"failed, rc = 0x%x\n", rc);
+		goto hfidd_close_window_internal_err0;
+	}
+
+	hfi_destroy_window_info(p_acs, win_p);
+
+	/* Call hcall to unregister MR in the MMU */
+	rc = hfi_takedown_window_in_MMU(p_acs, is_userspace, win_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_close_window_internal: hfi_takedown_window_in_MMU "
+			"failed, rc = 0x%x\n", rc);
+		goto hfidd_close_window_internal_err0;
+	}
+
+	hfi_free_win_resource(p_acs, is_userspace, win_p,
+		&(win_p->client_info));
+
+	spin_lock(&win_p->win_lock);
+	/* Update the window information */
+	hfi_restore_window_parm(p_acs, win_p);
+	spin_unlock(&win_p->win_lock);
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"close_window_internal: type=0x%x state=0x%x JobID=0x%x\n",
+		win_p->type, win_p->state, win_p->job_id);
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"close_window_internal: rc=0x%x\n", rc);
+	return rc;
+
+hfidd_close_window_internal_err0:
+	return rc;
+}
+
+/*
+ * This function is called by the kernel users directly or a write
+ * system call by the kernel users. It will call hfidd_close_window_internal
+ * to close a specific window.
+ */
+int hfidd_close_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
+	struct hfi_window_info *user_p)
+{
+	unsigned int		win_num;
+	int			rc = 0;
+	struct hfi_window_info	win_info;
+
+	/* Copy in win num from user */
+	rc = hfi_copy_from_user(&win_info, user_p,
+			is_userspace, sizeof(struct hfi_window_info));
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_close_window_func: hfi_copy_from_user "
+			"failed, rc = 0x%x\n", rc);
+		return rc;
+	}
+
+	win_num = win_info.window;
+
+	rc = hfidd_close_window_internal(p_acs, is_userspace, win_num);
+	if (rc) {
+		rc = -EINVAL;
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_close_window_func: close_window_internal "
+			"failed, win=0x%x rc=0x%x\n", win_num, rc);
+		return rc;
+	}
+
+	dev_printk(KERN_INFO, p_acs->hfidd_dev,
+		"close_window_func: rc=0x%x\n", rc);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(hfidd_close_window_func);
diff --git a/include/linux/hfi/hfidd_client.h b/include/linux/hfi/hfidd_client.h
index 7e4c1a7..11c8973 100644
--- a/include/linux/hfi/hfidd_client.h
+++ b/include/linux/hfi/hfidd_client.h
@@ -113,6 +113,14 @@ struct hfi_client_info {
 	struct hfi_64b		mmio_regs;		/* Output	*/
 };
 
+/*
+ * HFIDD_REQ_CLOSE_WINDOW: close window
+ */
+struct hfi_window_info {
+	struct hfi_req_hdr	hdr;
+	unsigned int		window;
+};
+
 #define MAX_TORRENTS            1
 #define MAX_HFI_PER_TORRENT     2
 #define MAX_HFIS                (MAX_TORRENTS * MAX_HFI_PER_TORRENT)
diff --git a/include/linux/hfi/hfidd_hcalls.h b/include/linux/hfi/hfidd_hcalls.h
index 1e007c5..777de8f 100644
--- a/include/linux/hfi/hfidd_hcalls.h
+++ b/include/linux/hfi/hfidd_hcalls.h
@@ -40,6 +40,7 @@
 #define H_HFI_QUERY_INTERFACE		0xF004
 #define H_HFI_STOP_INTERFACE		0xF008
 #define H_HFI_OPEN_WINDOW		0xF00C
+#define H_HFI_CLOSE_WINDOW		0xF014
 #define H_NMMU_START			0xF028
 #define H_NMMU_STOP			0xF02C
 #define H_NMMU_ALLOCATE_RESOURCE	0xF030
diff --git a/include/linux/hfi/hfidd_requests.h b/include/linux/hfi/hfidd_requests.h
index 4f1c74d..a7a38da 100644
--- a/include/linux/hfi/hfidd_requests.h
+++ b/include/linux/hfi/hfidd_requests.h
@@ -35,5 +35,6 @@
 
 #define HFIDD_REQ_OPEN_WINDOW			0x00000a01
 #define HFIDD_REQ_QUERY_DD_INFO			0x00001004
+#define HFIDD_REQ_CLOSE_WINDOW			0x00000a02
 
 #endif /* _HFIDD_REQUESTS_H_ */
-- 
1.7.3.5

