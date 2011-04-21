From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 15/27] HFI: Set up nMMU page tables for the send and receive fifos
Date: Thu, 21 Apr 2011 17:38:45 -0400
Message-ID: <1303421937-2325-16-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e8.ny.us.ibm.com ([32.97.182.138]:47324 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753881Ab1DUVjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:35 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLE04X000345
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:14:00 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdFIS143304
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:22 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLdBFR012671
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:12 -0400
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
 drivers/net/hfi/core/hfidd_proto.h  |    3 +
 drivers/net/hfi/core/hfidd_window.c |  259 ++++++++++++++++++++++++++++++++++-
 include/linux/hfi/hfidd_hcalls.h    |   16 ++
 include/linux/hfi/hfidd_internal.h  |    2 +
 4 files changed, 279 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index fb9c8c8..ff39a02 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -54,6 +54,9 @@ int hfidd_get_page_num(struct hfidd_acs *p_acs, void *start_addr,
 int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		struct hfi_client_info *user_p,
 		struct hfi_client_info *out_p);
+int hfi_register_rpages(struct hfidd_acs *p_acs, unsigned long long mr_handle,
+		unsigned int submr, struct hfidd_vlxmem *xtab_p,
+		unsigned int *mapped_pages);
 int hfidd_get_phyp_page(struct hfidd_acs *p_acs, caddr_t *page,
 	caddr_t *laddr, int size);
 void hfidd_release_phyp_page(caddr_t page, int size);
diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index de2e56d..6d90af6 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -359,6 +359,220 @@ static int hfi_validate_window_parm(struct hfidd_acs *p_acs,
 	return 0;
 }
 
+
+/*
+ * Map the Effective Address pages for Memory Regions.
+ * If more than one page, need to setup a page containing
+ * all the effective address pages
+ */
+int hfi_register_rpages(struct hfidd_acs *p_acs,
+			unsigned long long mr_handle,
+			unsigned int submr,
+			struct hfidd_vlxmem *xtab_p,
+			unsigned int *mapped_pages)
+{
+	unsigned int		map_num;
+	long long		hvrc = 0;
+	unsigned int		num_page_left, num_page_total;
+	char			*effective_addr;
+	void			*l_pages;
+	void			*hcall_array = NULL;
+	unsigned long long	logical_hcall_array = 0;
+	unsigned long long	logical_addr = 0;
+	struct page_num_code	num_page_sz;
+	int			rc = 0;
+
+	effective_addr = xtab_p->m_addr;
+	num_page_total = xtab_p->num_page_sz.num_code.fields.pg_num;
+	num_page_sz.num_code.fields.pg_code =
+			xtab_p->num_page_sz.num_code.fields.pg_code;
+	l_pages = xtab_p->l_pages;
+
+	if (num_page_total > MIN_NUM_PAGES_NMMU_HCALL) {
+		hcall_array = (void *)__get_free_pages(GFP_KERNEL,
+			get_order(PAGE_SIZE_4K));
+		if (hcall_array == NULL) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfi_register_rpages: __get_free_pages "
+				"failed\n");
+			return -ENOMEM;
+		}
+
+		logical_hcall_array = __pa(hcall_array);
+		memset(hcall_array, 0, PAGE_SIZE_4K);
+	}
+
+	num_page_left = num_page_total;
+	while (num_page_left > 0) {
+		if (num_page_left > MAX_NUM_PAGES_NMMU_HCALL)
+			map_num = MAX_NUM_PAGES_NMMU_HCALL;
+		else
+			map_num = num_page_left;
+
+		num_page_sz.num_code.fields.pg_num = map_num;
+
+		if (map_num == MIN_NUM_PAGES_NMMU_HCALL) {
+			logical_addr = *(unsigned long long *)(l_pages);
+		} else {
+		memcpy(hcall_array, l_pages,
+				sizeof(unsigned long long) *
+				map_num);
+			logical_addr = logical_hcall_array;
+		}
+
+		hvrc = hfi_modify_mr(p_acs->dds.torr_id,
+				(unsigned long long)NMMU_MAP,
+				(unsigned long long)mr_handle,
+				(unsigned long long)submr,
+				(unsigned long long)effective_addr,
+				logical_addr,
+				(unsigned long long)
+				num_page_sz.num_code.llu_value);
+
+		if (hvrc != H_SUCCESS) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfi_register_rpages: HFI_MODIFY_MR "
+				"failed, map_num=0x%x, m_addr=0x%llx\n",
+				map_num, (unsigned long long)effective_addr);
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfi_register_rpages: HFI_MODIFY_MR "
+				"failed, page_sz=0x%llx, hvrc=0x%llx\n",
+				xtab_p->page_sz, hvrc);
+			rc = -EINVAL;
+			break;
+		}
+
+		effective_addr   += map_num * (xtab_p->map_page_sz);
+		l_pages  += map_num * sizeof(unsigned long long);
+		num_page_left -= map_num;
+	}
+
+	/* pass back the number of pages successfully mapped */
+	if (mapped_pages)
+		*mapped_pages = num_page_total - num_page_left;
+	if (num_page_total > MIN_NUM_PAGES_NMMU_HCALL)
+		free_pages((unsigned long)hcall_array, get_order(PAGE_SIZE_4K));
+
+	vfree(xtab_p->l_pages);
+	xtab_p->l_pages = NULL;
+	return rc;
+}
+
+/*
+ * Setup Memory regions for FIFOs. First call
+ * ALLOCATE MR hcall and then MODIFY MR hcall with MAP flag.
+ */
+static int hfi_register_MMU(struct hfidd_acs *p_acs, unsigned int win_index,
+		unsigned int jid, struct hfidd_vlxmem *xtab_p)
+{
+	long long		hvrc = 0;
+	int			rc = 0;
+	unsigned long long	access_ctl;
+	unsigned int		page_code;
+	unsigned long long	l_key = 0;
+	unsigned long long	liobn = 0;
+	caddr_t			addr;
+
+	page_code = (xtab_p->num_page_sz.num_code.fields.pg_code >>
+			HFI_PAGE_CODE_SHIFT) & PAGE_CODE_MASK;
+
+	/* primary and second must be same size */
+	access_ctl = (page_code << HFI_PRI_PAGE_SIZE_SHIFT) |
+		     (page_code << HFI_SEC_PAGE_SIZE_SHIFT) |
+		     (1 << HFI_ELWA_SHIFT);
+	access_ctl = access_ctl << HFI_ACCESS_CTL_SHIFT;
+
+	hvrc = hfi_allocate_mr(p_acs->dds.torr_id,
+			NMMU_MR,
+			(unsigned long long)
+			(xtab_p->e_addr), /* aligned userinput addr */
+			(unsigned long long)
+			(xtab_p->num_page * xtab_p->page_sz),
+			access_ctl,
+			(unsigned long long)jid,
+			(unsigned long long)xtab_p->mr_handle,
+			(unsigned long long *)&(xtab_p->mr_handle),
+			&l_key,
+			&liobn);
+
+	xtab_p->l_key = (unsigned int)l_key;
+	addr = xtab_p->e_addr;
+	if (hvrc != H_SUCCESS) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_register_MMU: HFI_ALLOCATE_MR failed, "
+			"hvrc = 0x%llx\n", hvrc);
+		return -EINVAL;
+	}
+
+	rc = hfi_register_rpages(p_acs, xtab_p->mr_handle, 0, xtab_p, NULL);
+	if (rc != 0) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_register_MMU: hfi_register_rpages failed, "
+			"rc = 0x%x\n", rc);
+
+		hvrc = hfi_free_mr(p_acs->dds.torr_id,
+				NMMU_MR,
+				(unsigned long long)xtab_p->mr_handle,
+				0);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/* Call FREE MR hcall to free the FIFOs and RDMA context memory regions */
+static int hfi_unregister_MMU(struct hfidd_acs *p_acs,
+		struct hfidd_vlxmem *xtab_p)
+{
+	long long hvrc = 0;
+	int rc = 0;
+
+	hvrc = hfi_free_mr(p_acs->dds.torr_id,
+			NMMU_MR,
+			(unsigned long long)xtab_p->mr_handle,
+			0);
+	if (hvrc != H_SUCCESS) {
+		rc = -EIO;
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_unregister_MMU: HFI_FREE_MR failed, "
+			"hvrc = 0x%llx\n", hvrc);
+	}
+	return rc;
+}
+
+/* Setup all the window Memory Regions needed for network traffic  */
+static int hfi_setup_window_in_MMU(struct hfidd_acs *p_acs,
+		unsigned int is_userspace, struct hfidd_window *win_p)
+{
+	int			rc = 0;
+
+	/* Register sfifo and finish vector  memory in MMU */
+	rc = hfi_register_MMU(p_acs, win_p->index, win_p->job_id,
+			win_p->sfifo_x_tab);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_setup_window_in_MMU: sfifo register "
+			"failed, rc = 0x%x\n", rc);
+		goto sfifo_err;
+	}
+
+	/* Register rfifo */
+	rc = hfi_register_MMU(p_acs, win_p->index, win_p->job_id,
+			win_p->rfifo_x_tab);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_setup_window_in_MMU: rfifo register "
+			"failed, rc = 0x%x\n", rc);
+		goto rfifo_err;
+	}
+
+	return 0;
+
+rfifo_err:
+	hfi_unregister_MMU(p_acs, win_p->sfifo_x_tab);
+sfifo_err:
+	return rc;
+}
+
 static int hfi_xlate_fifos(struct hfidd_acs *p_acs,
 		unsigned int is_userspace,
 		struct hfidd_window *win_p,
@@ -399,7 +613,7 @@ hfi_xlate_fifos_err1:
 	return rc;
 }
 
-int hfi_unxlate_fifos(struct hfidd_acs *p_acs, unsigned int is_userspace,
+static int hfi_unxlate_fifos(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		struct hfidd_window *win_p, struct hfi_client_info *client_p)
 {
 	int	rc = 0;
@@ -451,6 +665,15 @@ hfi_alloc_xlate_tab_err1:
 	return -ENOMEM;
 }
 
+static void hfi_free_win_resource(struct hfidd_acs *p_acs,
+		unsigned int is_userspace,
+		struct hfidd_window *win_p,
+		struct hfi_client_info *client_p)
+{
+	hfi_unxlate_fifos(p_acs, is_userspace, win_p, client_p);
+	hfi_free_xlate_tab(win_p);
+}
+
 static int hfi_alloc_win_resource(struct hfidd_acs *p_acs,
 		unsigned int is_userspace,
 		struct hfidd_window *win_p,
@@ -478,6 +701,30 @@ static int hfi_alloc_win_resource(struct hfidd_acs *p_acs,
 	return 0;
 }
 
+static int hfi_setup_window_parm(struct hfidd_acs *p_acs,
+			unsigned int is_userspace,
+			struct hfidd_window *win_p,
+			struct hfi_client_info *client_p)
+{
+	int	rc = 0;
+
+	/* Copy client info into window */
+	memcpy(&(win_p->client_info), client_p, sizeof(struct hfi_client_info));
+
+	/* Call hcall to allocate/map MR in the MMU */
+	rc = hfi_setup_window_in_MMU(p_acs, is_userspace, win_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_setup_window_parm: hfi_setup_window_in_MMU "
+			"failed, rc = 0x%x\n", rc);
+		goto setup_window_parm_err1;
+	}
+	return 0;
+
+setup_window_parm_err1:
+	return rc;
+}
+
 /*
  * Allows an user/kernel window to send/receive network traffic thru HFI
  * adapter. This function will allocate the system resources needed to open
@@ -528,9 +775,19 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		goto hfidd_open_window_func_err2;
 	}
 
+	rc = hfi_setup_window_parm(p_acs, is_userspace, win_p, local_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_open_window_func: hfi_setup_window_parm "
+			"failed, rc = 0x%x\n", rc);
+		goto hfidd_open_window_func_err3;
+	}
+
 	kfree(local_p);
 	return rc;
 
+hfidd_open_window_func_err3:
+	hfi_free_win_resource(p_acs, is_userspace, win_p, local_p);
 hfidd_open_window_func_err2:
 	hfi_restore_window_parm(p_acs, win_p);
 hfidd_open_window_func_err1:
diff --git a/include/linux/hfi/hfidd_hcalls.h b/include/linux/hfi/hfidd_hcalls.h
index 9fa87c5..3c9f556 100644
--- a/include/linux/hfi/hfidd_hcalls.h
+++ b/include/linux/hfi/hfidd_hcalls.h
@@ -45,7 +45,23 @@
 #define H_NMMU_FREE_RESOURCE		0xF034
 #define H_NMMU_MODIFY_RESOURCE		0xF03C
 
+#define NMMU_MR		0
+
+#define NMMU_MAP	1
+#define NMMU_UNMAP	0
+#define NMMU_CHECK	2
+
 #define HFI_PAGE_CODE_SHIFT	28
+#define HFI_PRI_PAGE_SIZE_SHIFT	24
+#define HFI_ELWA_SHIFT		23
+#define HFI_ERWA_SHIFt		22
+#define HFI_ERRA_SHIFT		21
+#define HFI_ERAO_SHIFT		20
+#define HFI_ESMR_SHIFT		18
+#define HFI_SEC_PAGE_SIZE_SHIFT	14
+#define HFI_SUBMR_NUM_SHIFT	11
+
+#define HFI_ACCESS_CTL_SHIFT	32
 
 #define EEH_QUERY	1
 #define COMP_QUERY	2
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index 8e097d0..820df48 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -66,6 +66,8 @@
 #include <linux/hfi/hfidd_xlat_map.h>
 
 #define MAX_D_WIN_PER_HFI	(p_acs->dds.num_d_windows)
+#define MAX_NUM_PAGES_NMMU_HCALL 512
+#define MIN_NUM_PAGES_NMMU_HCALL 1
 
 #define HFIDD_DEV_NAME		"hfi"
 #define HFIDD_CLASS_NAME	"hfi"
-- 
1.7.3.5

