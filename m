From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 13/27]  HFI: Send and receive fifo address translation
Date: Thu, 21 Apr 2011 17:38:43 -0400
Message-ID: <1303421937-2325-14-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e4.ny.us.ibm.com ([32.97.182.144]:59594 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755180Ab1DUVj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:26 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLJAox015260
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:19:10 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdBSf2314420
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:12 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLdBKq012595
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:11 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Prepare for a hypervisor call to set up page tables in the nMMU for the
send and receive fifo.

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
 drivers/net/hfi/core/hfidd_proto.h  |    9 ++
 drivers/net/hfi/core/hfidd_window.c |  132 ++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_xlat.c   |  210 +++++++++++++++++++++++++++++++++++
 include/linux/hfi/hfidd_adpt.h      |   28 +++++
 include/linux/hfi/hfidd_hcalls.h    |    2 +
 include/linux/hfi/hfidd_internal.h  |    1 +
 include/linux/hfi/hfidd_xlat_map.h  |   91 +++++++++++++++
 7 files changed, 473 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/hfi/hfidd_xlat_map.h

diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index 66ea5da..001f6d5 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -39,9 +39,18 @@ int hfidd_alloc_windows(struct hfidd_acs *p_acs);
 void hfidd_free_windows(struct hfidd_acs *p_acs);
 int hfidd_init_adapter(struct hfidd_acs *p_acs, void *uiop);
 int hfidd_age_hcall(u64 time_start);
+int hfidd_fifo_xlat(struct hfidd_acs *p_acs, struct fifo_info *fifo_in,
+		int is_userspace, struct hfidd_vlxmem *xlat_p);
+int hfidd_fifo_unxlat(struct hfidd_acs *p_acs, struct fifo_info *fifo_in,
+		int is_userspace, struct hfidd_vlxmem *xlat_p);
+int hfidd_fill_xlat_tab(struct hfidd_acs *p_acs, struct fifo_info *fifo_in,
+		unsigned int is_userspace, struct hfidd_vlxmem *xlat_p);
 int hfidd_get_page_size(struct hfidd_acs *p_acs, void *addr,
 		unsigned int is_userspace, unsigned int length,
 		unsigned long long *page_size);
+int hfidd_get_page_num(struct hfidd_acs *p_acs, void *start_addr,
+		unsigned long long len, unsigned long long page_sz,
+		unsigned int *pg_num_p);
 int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		struct hfi_client_info *user_p,
 		struct hfi_client_info *out_p);
diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index 5a4f395..de2e56d 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -359,6 +359,125 @@ static int hfi_validate_window_parm(struct hfidd_acs *p_acs,
 	return 0;
 }
 
+static int hfi_xlate_fifos(struct hfidd_acs *p_acs,
+		unsigned int is_userspace,
+		struct hfidd_window *win_p,
+		struct hfi_client_info *client_p)
+{
+	int	rc = 0;
+
+	/*
+	 * add 4K(finish vector) to the sfifo size then call to
+	 * xlate when return, restore the sfifo size back..............
+	 */
+	client_p->sfifo.size += PAGE_SIZE_4K;
+	rc = hfidd_fifo_xlat(p_acs, &(client_p->sfifo), is_userspace,
+			win_p->sfifo_x_tab);
+	client_p->sfifo.size -= PAGE_SIZE_4K;
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_xlate_fifos: hfidd_fifo_xlat failed, "
+			"rc = 0x%x\n", rc);
+		return rc;
+	}
+
+	rc = hfidd_fifo_xlat(p_acs, &(client_p->rfifo), is_userspace,
+			win_p->rfifo_x_tab);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_xlate_fifos: hfidd_fifo_xlat failed, "
+			"rc = 0x%x\n", rc);
+		goto hfi_xlate_fifos_err1;
+	}
+
+hfi_xlate_fifos_err1:
+	client_p->sfifo.size += PAGE_SIZE_4K;
+	hfidd_fifo_unxlat(p_acs, &(client_p->sfifo), is_userspace,
+			win_p->sfifo_x_tab);
+	client_p->sfifo.size -= PAGE_SIZE_4K;
+
+	return rc;
+}
+
+int hfi_unxlate_fifos(struct hfidd_acs *p_acs, unsigned int is_userspace,
+		struct hfidd_window *win_p, struct hfi_client_info *client_p)
+{
+	int	rc = 0;
+
+	hfidd_fifo_unxlat(p_acs, &(client_p->rfifo),
+			is_userspace, win_p->rfifo_x_tab);
+
+	client_p->sfifo.size += PAGE_SIZE_4K;
+	hfidd_fifo_unxlat(p_acs, &(client_p->sfifo),
+			is_userspace, win_p->sfifo_x_tab);
+	client_p->sfifo.size -= PAGE_SIZE_4K;
+
+	return rc;
+}
+
+static inline void hfi_free_xlate_tab(struct hfidd_window *win_p)
+{
+	kfree(win_p->sfifo_x_tab);
+	win_p->sfifo_x_tab	= NULL;
+	kfree(win_p->rfifo_x_tab);
+	win_p->rfifo_x_tab	= NULL;
+}
+
+static int hfi_alloc_xlate_tab(struct hfidd_acs *p_acs,
+		struct hfidd_window *win_p,
+		struct hfi_client_info *client_p)
+{
+	win_p->sfifo_x_tab = kzalloc(sizeof(*(win_p->sfifo_x_tab)),
+			GFP_KERNEL);
+	if (win_p->sfifo_x_tab == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_alloc_xlate_tab: kzalloc sfifo_x_tab failed\n");
+		return -ENOMEM;
+	}
+
+	win_p->rfifo_x_tab = kzalloc(sizeof(*(win_p->rfifo_x_tab)),
+			GFP_KERNEL);
+	if (win_p->rfifo_x_tab == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_alloc_xlate_tab: kzalloc rfifo_x_tab failed\n");
+		goto hfi_alloc_xlate_tab_err1;
+	}
+
+	return 0;
+
+hfi_alloc_xlate_tab_err1:
+	kfree(win_p->sfifo_x_tab);
+	win_p->sfifo_x_tab = NULL;
+	return -ENOMEM;
+}
+
+static int hfi_alloc_win_resource(struct hfidd_acs *p_acs,
+		unsigned int is_userspace,
+		struct hfidd_window *win_p,
+		struct hfi_client_info *client_p)
+{
+	int	rc = 0;
+
+	rc = hfi_alloc_xlate_tab(p_acs, win_p, client_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_alloc_win_resource: hfi_alloc_xlate_tab "
+			"failed, rc = 0x%x\n", rc);
+		return rc;
+	}
+
+	rc = hfi_xlate_fifos(p_acs, is_userspace, win_p, client_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_alloc_win_resource: hfi_xlate_fifos "
+			"failed, rc = 0x%x\n", rc);
+		hfi_free_xlate_tab(win_p);
+		return rc;
+	}
+
+	return 0;
+}
+
 /*
  * Allows an user/kernel window to send/receive network traffic thru HFI
  * adapter. This function will allocate the system resources needed to open
@@ -371,6 +490,7 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 {
 	int			rc = 0;
 	struct hfi_client_info	*local_p = NULL;
+	struct hfidd_window	*win_p = NULL;
 
 	/* Allocate local data structure */
 	local_p = kmalloc(sizeof(struct hfi_client_info), GFP_KERNEL);
@@ -398,9 +518,21 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		goto hfidd_open_window_func_err1;
 	}
 
+	win_p = hfi_window(p_acs, local_p->window);
+
+	rc = hfi_alloc_win_resource(p_acs, is_userspace, win_p, local_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_open_window_func: hfi_alloc_win_resource "
+			"failed, rc = 0x%x\n", rc);
+		goto hfidd_open_window_func_err2;
+	}
+
 	kfree(local_p);
 	return rc;
 
+hfidd_open_window_func_err2:
+	hfi_restore_window_parm(p_acs, win_p);
 hfidd_open_window_func_err1:
 	kfree(local_p);
 	return rc;
diff --git a/drivers/net/hfi/core/hfidd_xlat.c b/drivers/net/hfi/core/hfidd_xlat.c
index 23236cc..760d7e6 100644
--- a/drivers/net/hfi/core/hfidd_xlat.c
+++ b/drivers/net/hfi/core/hfidd_xlat.c
@@ -129,3 +129,213 @@ out1:
 	kfree(page_list);
 	return rc;
 }
+
+int hfidd_get_page_num(struct hfidd_acs *p_acs,
+		void			*start_addr,
+		unsigned long long	len,
+		unsigned long long	page_sz,
+		unsigned int		*pg_num_p)
+{
+	int			rc = 0;
+	int			pg_shift_count;
+	unsigned long long	address_mask;
+	unsigned long long	offset_mask;
+	unsigned long long	offset;
+
+	if (pg_num_p == NULL || len == 0) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_get_page_num: len=%llx pg_num_p=0x%llx\n",
+			len, (unsigned long long)pg_num_p);
+		return -EINVAL;
+	}
+
+	/*
+	 * Pre-Calculate Masks and shift count:
+	 */
+	if (page_sz == PAGE_SIZE_4K) {
+		offset_mask			= PAGE_MASK_4K;
+		pg_shift_count			= PAGE_SHIFT_4K;
+	} else if (page_sz == PAGE_SIZE_64K) {
+		offset_mask			= PAGE_MASK_64K;
+		pg_shift_count			= PAGE_SHIFT_64K;
+	} else if (page_sz == PAGE_SIZE_16M) {
+		offset_mask			= PAGE_MASK_16M;
+		pg_shift_count			= PAGE_SHIFT_16M;
+	} else if (page_sz == PAGE_SIZE_4G) {
+		offset_mask			= PAGE_MASK_4G;
+		pg_shift_count			= PAGE_SHIFT_4G;
+	} else {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_get_page_num: invalid page_sz 0x%llx "
+			"return EINVAL\n", page_sz);
+		return -EINVAL;
+	}
+	address_mask = ~offset_mask;
+
+	/*
+	 * Calculate the buffer offsets into the first page:
+	 */
+	offset = (unsigned long long)start_addr & offset_mask;
+	*pg_num_p  = (len + offset + offset_mask) >> pg_shift_count;
+
+	return rc;
+}
+
+int hfidd_fill_xlat_tab(struct hfidd_acs *p_acs, struct fifo_info *fifo_in,
+	unsigned int is_userspace, struct hfidd_vlxmem *xlat_p)
+{
+	unsigned int		num_pages;
+	unsigned long long	page_size;
+	int			rc = 0;
+
+	rc = hfidd_get_page_size(p_acs, fifo_in->eaddr.use.kptr, is_userspace,
+			fifo_in->size, &page_size);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_fill_xlat_tab: hfidd_get_page_size failed, "
+			" rc=0x%x\n", rc);
+		return rc;
+	}
+
+	/* Get num of pages based in buffer page size */
+	rc = hfidd_get_page_num(p_acs, fifo_in->eaddr.use.kptr,
+			fifo_in->size, page_size, &num_pages);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_fill_xlat_tab:: hfidd_get_page_num return "
+			"rc 0x%x\n", rc);
+		return rc;
+	}
+
+	xlat_p->v_addr = (caddr_t)(fifo_in->eaddr.use.kptr);
+	xlat_p->e_addr = (caddr_t)(fifo_in->eaddr.use.allu & ~(page_size - 1));
+	xlat_p->page_sz = page_size;
+	xlat_p->num_page = num_pages;
+	xlat_p->len = num_pages * page_size;
+	xlat_p->num_kpage = (xlat_p->len) / PAGE_SIZE;
+
+	return 0;
+}
+
+int hfidd_fifo_xlat(struct hfidd_acs *p_acs, struct fifo_info *fifo_in,
+		int is_userspace, struct hfidd_vlxmem *xlat_p)
+{
+	int			rc = 0;
+	int			i;
+	unsigned int		num_pages, pg_code;
+	unsigned long long	page_size;
+	unsigned long long	*l_pages;
+	struct page		**page_list;
+	unsigned int		hw_page = 0;
+
+	if ((fifo_in == NULL) || (xlat_p == NULL)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_fifo_xlat: Invalid fifo_in 0x%llx\n",
+			(unsigned long long)fifo_in);
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_fifo_xlat: Invalid xlat_p 0x%llx\n",
+			(unsigned long long)xlat_p);
+		return -EINVAL;
+	}
+
+	rc = hfidd_fill_xlat_tab(p_acs, fifo_in, is_userspace, xlat_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_fifo_xlat: hfidd_fill_xlat_tab failed, "
+			"rc = 0x%x\n", rc);
+		return rc;
+	}
+
+	/* num_page is number of pages of page_sz */
+	num_pages = xlat_p->num_page;
+	page_size = xlat_p->page_sz;
+
+	l_pages = vmalloc(num_pages * sizeof(unsigned long long));
+	if (l_pages == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_fifo_xlat: vmalloc failed for l_pages\n");
+		return -ENOMEM;
+	}
+
+	if (!is_userspace) {
+		void *curr_addr = xlat_p->e_addr;
+
+		for (i = 0; i < num_pages; i++) {
+			l_pages[i] = __pa(curr_addr);
+			curr_addr += page_size;
+		}
+	} else {
+		/* For page_list use number of kernel pages */
+		page_list = kzalloc(xlat_p->num_kpage * sizeof(struct page *),
+			GFP_KERNEL);
+		if (page_list == NULL) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_fifo_xlat: kzalloc failed "
+				"for page_list\n");
+			rc = -ENOMEM;
+			goto out_err0;
+		}
+
+		down_read(&current->mm->mmap_sem);
+		rc = get_user_pages(current, current->mm,
+				(unsigned long long)(xlat_p->e_addr),
+				xlat_p->num_kpage, 1, 0, /* write, !force */
+				page_list, NULL);
+		up_read(&current->mm->mmap_sem);
+
+		if (rc < xlat_p->num_kpage) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_fifo_xlat: get_user_pages failed, "
+				"rc = 0x%x\n", rc);
+			goto out_err1;
+		}
+
+		for (i = 0; i < num_pages;) {
+			l_pages[hw_page] = page_to_phys(page_list[i]);
+			hw_page++;
+			i += (page_size / PAGE_SIZE);
+		}
+
+		xlat_p->page_list = (void *)page_list;
+	}
+
+	xlat_p->l_pages = (void *)l_pages;
+	xlat_p->map_page_sz = page_size;
+	xlat_p->m_addr = xlat_p->e_addr;
+	xlat_p->num_page_sz.num_code.fields.pg_num = num_pages;
+	encode_pg_sz(page_size, &pg_code);
+	xlat_p->num_page_sz.num_code.fields.pg_code =
+		(pg_code << HFI_PAGE_CODE_SHIFT);
+	return 0;
+
+out_err1:
+	if (rc > 0) {
+		for (i = 0; i < rc; i++)
+			page_cache_release(page_list[i]);
+		rc = -EINVAL;
+	}
+	kfree(page_list);
+out_err0:
+	vfree(l_pages);
+	return rc;
+}
+
+int hfidd_fifo_unxlat(struct hfidd_acs *p_acs, struct fifo_info *fifo_in,
+		int is_userspace, struct hfidd_vlxmem *xlat_p)
+{
+	int		rc = 0;
+	int		i;
+	struct page	**page_list;
+
+	if (!is_userspace)
+		return 0;
+	page_list = (struct page **)xlat_p->page_list;
+	if (page_list != NULL) {
+		/* For page list we used number of kernel pages */
+		for (i = 0; i < xlat_p->num_kpage; i++)
+			page_cache_release(page_list[i]);
+		kfree(page_list);
+		xlat_p->page_list = NULL;
+	}
+	return rc;
+}
diff --git a/include/linux/hfi/hfidd_adpt.h b/include/linux/hfi/hfidd_adpt.h
index a41825f..8eab059 100644
--- a/include/linux/hfi/hfidd_adpt.h
+++ b/include/linux/hfi/hfidd_adpt.h
@@ -74,4 +74,32 @@
 #define PAGE_MASK_4G		(PAGE_SIZE_4G - 1)
 #define PAGE_MASK_16G		(PAGE_SIZE_16G - 1)
 
+#define PAGE_CODE_4K	0x00000000
+#define PAGE_CODE_64K	0x00000001
+#define PAGE_CODE_1M	0x00000002
+#define PAGE_CODE_16M	0x00000003
+#define PAGE_CODE_256M	0x00000004
+#define PAGE_CODE_4G	0x00000005
+#define PAGE_CODE_INVAL	0x00000007
+#define PAGE_CODE_MASK	0x00000007
+
+static inline void encode_pg_sz(unsigned long long pg_sz,
+		unsigned int *pg_sz_code)
+{
+	if (pg_sz == PAGE_SIZE_4K)
+		*pg_sz_code = PAGE_CODE_4K;
+	else if (pg_sz == PAGE_SIZE_64K)
+		*pg_sz_code = PAGE_CODE_64K;
+	else if (pg_sz == PAGE_SIZE_1M)
+		*pg_sz_code = PAGE_CODE_1M;
+	else if (pg_sz == PAGE_SIZE_16M)
+		*pg_sz_code = PAGE_CODE_16M;
+	else if (pg_sz == PAGE_SIZE_256M)
+		*pg_sz_code = PAGE_CODE_256M;
+	else if (pg_sz == PAGE_SIZE_4G)
+		*pg_sz_code = PAGE_CODE_4G;
+	else
+		*pg_sz_code = PAGE_CODE_INVAL;
+}
+
 #endif /* _HFIDD_ADPT_H_ */
diff --git a/include/linux/hfi/hfidd_hcalls.h b/include/linux/hfi/hfidd_hcalls.h
index 2a374e6..57140a0 100644
--- a/include/linux/hfi/hfidd_hcalls.h
+++ b/include/linux/hfi/hfidd_hcalls.h
@@ -42,6 +42,8 @@
 #define H_NMMU_START			0xF028
 #define H_NMMU_STOP			0xF02C
 
+#define HFI_PAGE_CODE_SHIFT	28
+
 #define EEH_QUERY	1
 #define COMP_QUERY	2
 
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
index 290e809..8e097d0 100644
--- a/include/linux/hfi/hfidd_internal.h
+++ b/include/linux/hfi/hfidd_internal.h
@@ -63,6 +63,7 @@
 #include <linux/hfi/hfidd_client.h>
 #include <linux/hfi/hfidd_adpt.h>
 #include <linux/hfi/hfidd_hcalls.h>
+#include <linux/hfi/hfidd_xlat_map.h>
 
 #define MAX_D_WIN_PER_HFI	(p_acs->dds.num_d_windows)
 
diff --git a/include/linux/hfi/hfidd_xlat_map.h b/include/linux/hfi/hfidd_xlat_map.h
new file mode 100644
index 0000000..e5d1869
--- /dev/null
+++ b/include/linux/hfi/hfidd_xlat_map.h
@@ -0,0 +1,91 @@
+/*
+ * hfidd_xlat_map.h
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
+#ifndef _HFIDD_XLAT_MAP_H_
+#define _HFIDD_XLAT_MAP_H_
+
+#include <linux/hfi/hfidd_client.h>
+
+/*
+ * So we can shift rather than divide!
+ */
+#define PAGE_SHIFT_2K		11
+#define PAGE_SHIFT_4K		12
+#define PAGE_SHIFT_64K		16
+#define PAGE_SHIFT_1M		20
+#define PAGE_SHIFT_16M		24
+#define PAGE_SHIFT_4G		32
+
+struct page_num_code {
+	union {
+		unsigned long long	llu_value;
+		struct num_and_code {
+			unsigned int	pg_num;
+			unsigned int	pg_code;
+		} fields;
+	} num_code;
+};
+
+struct hfidd_vlxmem {
+	unsigned long long	page_sz;	/* actual page size */
+	unsigned int		num_page;	/* calculated using actual
+						   page size */
+	unsigned int		rsvd;
+	struct page_num_code	num_page_sz;	/* page num and size code
+						   mapping */
+	unsigned long long	map_page_sz;	/* page size used for mapping */
+	caddr_t			m_addr;		/* aligned address start for
+						   mapping */
+	caddr_t			v_addr;		/* user given vaddr */
+	caddr_t			e_addr;
+
+	unsigned long long	len;
+	unsigned long long	access_flag;
+	void			*l_pages;
+
+	unsigned long long	mr_handle;
+	unsigned int		l_key;
+
+	struct task		*xd;
+
+	int			num_kpage;	/* num of kernel pages */
+	atomic_t		*share_cnt;	/* # of processes sharing this
+						   submr */
+	unsigned int		num_chunks;	/* number of chunks the mr is
+						   divided */
+	caddr_t			mr_addr;	/* aligned submr starting
+						   address */
+	void			*page_list;	/* struct page_list */
+	unsigned int		liobn;		/* logical I/O bus number */
+};
+
+#endif
-- 
1.7.3.5

