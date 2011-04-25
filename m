From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v4 17/27] HFI: Set up and call the open window hypercall
Date: Mon, 25 Apr 2011 17:23:57 -0400
Message-ID: <1303766647-30156-18-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e34.co.us.ibm.com ([32.97.110.152]:49619 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755533Ab1DYVYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 17:24:31 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PLCE2C001174
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:12:14 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3PLORs0089488
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:27 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PLOQEu032692
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:27 -0600
In-Reply-To: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
 drivers/net/hfi/core/hfidd_window.c |  179 +++++++++++++++++++++++++++++++++++
 include/linux/hfi/hfidd_hcalls.h    |    2 +
 2 files changed, 181 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index 6d90af6..c20277b 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -359,6 +359,105 @@ static int hfi_validate_window_parm(struct hfidd_acs *p_acs,
 	return 0;
 }
 
+/*
+ * Setup a page for phyp with the window parameters needed for
+ * OPEN WINDOW hcall
+ */
+int hfi_build_window_info(struct hfidd_acs *p_acs, struct hfidd_window *win_p)
+{
+	caddr_t		laddr;
+
+#define WIN_INFO	(win_p->win_open_info_p)
+#define CLIENT_INFO	(win_p->client_info)
+
+	/* OPEN WINDOW hcall requires a page to pass arguments */
+	win_p->win_open_info_p = (struct win_open_info *)
+			__get_free_pages(GFP_KERNEL, get_order(PAGE_SIZE_4K));
+	if (win_p->win_open_info_p == NULL) {
+
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_build_window_info: ___get_free_pages failed\n");
+		return -ENOMEM;
+	}
+	memset((void *)(win_p->win_open_info_p), 0, PAGE_SIZE_4K);
+
+	/* Translate virtual adress into logical addres */
+	laddr = (caddr_t)__pa((caddr_t)win_p->win_open_info_p);
+
+	win_p->win_open_info_laddr = laddr;
+	WIN_INFO->job_id = CLIENT_INFO.job_id;
+	WIN_INFO->protection_domain = win_p->job_id;
+
+	WIN_INFO->sfifo_base_eaddr = CLIENT_INFO.sfifo.eaddr.use.allu;
+	WIN_INFO->sfifo_lkey       = win_p->sfifo_x_tab->l_key;
+	WIN_INFO->sfifo_size       = CLIENT_INFO.sfifo.size;
+	WIN_INFO->sfifo_finish_vec = CLIENT_INFO.sfifo_finish_vec.use.allu;
+
+	WIN_INFO->rfifo_base_eaddr = CLIENT_INFO.rfifo.eaddr.use.allu;
+	WIN_INFO->rfifo_lkey       = win_p->rfifo_x_tab->l_key;
+	WIN_INFO->rfifo_size       = CLIENT_INFO.rfifo.size;
+
+	/* Save IP context */
+	WIN_INFO->is_ip_window = win_p->is_ip;
+	if (win_p->is_ip) {
+		WIN_INFO->multicast_enable	   = HFI_MULTICAST_ENABLE;
+		WIN_INFO->disable_src_isr_id_stamp = 0;
+		WIN_INFO->logical_port_id_valid	   = 0;
+		WIN_INFO->logical_port_id	   = 0;
+	}
+
+	return 0;
+}
+
+/* Free the phyp page used at OPEN WINDOW hcall */
+static inline void hfi_destroy_window_info(struct hfidd_acs *p_acs,
+					struct hfidd_window *win_p)
+{
+	free_pages((unsigned long)win_p->win_open_info_p,
+			get_order(PAGE_SIZE_4K));
+	win_p->win_open_info_p = NULL;
+}
+
+/* Call to OPEN WINDOW hcall */
+static int hfi_hcall_to_open_window(struct hfidd_acs *p_acs,
+				struct hfidd_window *win_p)
+{
+	int		rc = 0;
+	long long	hvrc = 0;
+	u64		ummio_regs;
+	u64		pmmio_regs;
+	u64		send_intr;
+	u64		recv_intr;
+
+	hvrc = hfi_open_window(p_acs->dds.hfi_id,
+			win_p->index,
+			H_OPEN,
+			(u64)win_p->win_open_info_laddr,
+			&ummio_regs,
+			&pmmio_regs,
+			&send_intr,
+			&recv_intr);
+
+	if (hvrc != H_SUCCESS) {
+		if (hvrc == H_HARDWARE) {
+			win_p->state = WIN_HERROR;
+			rc = -EIO;
+		} else {
+			rc = -EINVAL;
+		}
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_hcall_to_open_window: OPEN WINDOW failed, "
+			"hvrc=0x%llx\n", hvrc);
+		return rc;
+	}
+
+	/* Copy mmio_regs logical page from OPEN_WINDOW hcall */
+	win_p->mmio_regs = ummio_regs;
+	win_p->send_intr  = (unsigned int)send_intr;
+	win_p->recv_intr  = (unsigned int)recv_intr;
+
+	return 0;
+}
 
 /*
  * Map the Effective Address pages for Memory Regions.
@@ -573,6 +672,31 @@ sfifo_err:
 	return rc;
 }
 
+/* Free all the window memory regions */
+static int hfi_takedown_window_in_MMU(struct hfidd_acs *p_acs,
+		unsigned int is_userspace, struct hfidd_window *win_p)
+{
+	int	rc = 0;
+
+	rc = hfi_unregister_MMU(p_acs, win_p->rfifo_x_tab);
+	if (rc != 0) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_takedown_window_in_MMU: rfifo mr failed,"
+			"rc = 0x%x\n", rc);
+		return rc;
+	}
+
+	rc = hfi_unregister_MMU(p_acs, win_p->sfifo_x_tab);
+	if (rc != 0) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_takedown_window_in_MMU: sfifo mr failed,"
+			"rc = 0x%x\n", rc);
+		return rc;
+	}
+
+	return rc;
+}
+
 static int hfi_xlate_fifos(struct hfidd_acs *p_acs,
 		unsigned int is_userspace,
 		struct hfidd_window *win_p,
@@ -701,6 +825,19 @@ static int hfi_alloc_win_resource(struct hfidd_acs *p_acs,
 	return 0;
 }
 
+static int hfi_destroy_window_parm(struct hfidd_acs *p_acs,
+		unsigned int is_userspace,
+		struct hfidd_window *win_p,
+		struct hfi_client_info *client_p)
+{
+	int	rc = 0;
+
+	hfi_destroy_window_info(p_acs, win_p);
+
+	rc = hfi_takedown_window_in_MMU(p_acs, is_userspace, win_p);
+	return rc;
+}
+
 static int hfi_setup_window_parm(struct hfidd_acs *p_acs,
 			unsigned int is_userspace,
 			struct hfidd_window *win_p,
@@ -719,8 +856,20 @@ static int hfi_setup_window_parm(struct hfidd_acs *p_acs,
 			"failed, rc = 0x%x\n", rc);
 		goto setup_window_parm_err1;
 	}
+
+	/* Build window information for OPEN WINDOW hcall */
+	rc = hfi_build_window_info(p_acs, win_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_setup_window_parm: hfi_build_window_info "
+			"failed, rc = 0x%x\n", rc);
+		goto setup_window_parm_err2;
+	}
+
 	return 0;
 
+setup_window_parm_err2:
+	hfi_takedown_window_in_MMU(p_acs, is_userspace, win_p);
 setup_window_parm_err1:
 	return rc;
 }
@@ -783,9 +932,39 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		goto hfidd_open_window_func_err3;
 	}
 
+	rc = hfi_hcall_to_open_window(p_acs, win_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_open_window_func: hfi_hcall_to_open_window "
+			"failed, rc = 0x%x\n", rc);
+		goto hfidd_open_window_func_err4;
+	}
+
+	/* tell user the local ISR id */
+	local_p->local_isrid = p_acs->isr;
+	win_p->client_info.local_isrid = p_acs->isr;
+
+	/* Copy out the client info back to user */
+	rc = hfi_copy_to_user((void *)out_p, (void *)local_p,
+			is_userspace, sizeof(struct hfi_client_info));
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_open_window_func: hfi_copy_to_user "
+			"failed, rc = 0x%x\n", rc);
+		goto hfidd_open_window_func_err4;
+	}
+
+	spin_lock(&(win_p->win_lock));
+	/* Update the window information */
+	win_p->pid = current->tgid;
+	win_p->state = WIN_OPENED;
+	spin_unlock(&(win_p->win_lock));
+
 	kfree(local_p);
 	return rc;
 
+hfidd_open_window_func_err4:
+	hfi_destroy_window_parm(p_acs, is_userspace, win_p, local_p);
 hfidd_open_window_func_err3:
 	hfi_free_win_resource(p_acs, is_userspace, win_p, local_p);
 hfidd_open_window_func_err2:
diff --git a/include/linux/hfi/hfidd_hcalls.h b/include/linux/hfi/hfidd_hcalls.h
index a97bb5e..1e007c5 100644
--- a/include/linux/hfi/hfidd_hcalls.h
+++ b/include/linux/hfi/hfidd_hcalls.h
@@ -70,6 +70,8 @@
 
 #define HFI_ACCESS_CTL_SHIFT	32
 
+#define HFI_MULTICAST_ENABLE	1
+
 struct win_open_info {
 	/* Hyp Feedback */
 	unsigned long long	hypervisor_capabilities;
-- 
1.7.3.5

