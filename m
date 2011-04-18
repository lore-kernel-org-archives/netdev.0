From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v2 12/27] HFI:  Sanity check send and receive fifo parameters
Date: Sun, 17 Apr 2011 23:21:44 -0400
Message-ID: <1303096919-7367-13-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e3.ny.us.ibm.com ([32.97.182.143]:47702 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245Ab1DRDWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:22:34 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I31OQF006474
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:01:24 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3I3MWb42519120
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:32 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3MWoH001257
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 23:22:32 -0400
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
 drivers/net/hfi/core/Makefile       |    1 +
 drivers/net/hfi/core/hfidd_proto.h  |    3 +
 drivers/net/hfi/core/hfidd_window.c |  177 +++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_xlat.c   |  131 ++++++++++++++++++++++++++
 include/linux/hfi/hfidd_adpt.h      |   17 ++++
 5 files changed, 329 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/hfi/core/hfidd_xlat.c

diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
index 0224a57..8d5558d 100644
--- a/drivers/net/hfi/core/Makefile
+++ b/drivers/net/hfi/core/Makefile
@@ -4,5 +4,6 @@
 hfi_core-objs:=	hfidd_adpt.o \
 		hfidd_window.o \
 		hfidd_init.o \
+		hfidd_xlat.o \
 		hfidd_hcalls.o
 obj-$(CONFIG_HFI) += hfi_core.o
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index e7f2901..66ea5da 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -39,6 +39,9 @@ int hfidd_alloc_windows(struct hfidd_acs *p_acs);
 void hfidd_free_windows(struct hfidd_acs *p_acs);
 int hfidd_init_adapter(struct hfidd_acs *p_acs, void *uiop);
 int hfidd_age_hcall(u64 time_start);
+int hfidd_get_page_size(struct hfidd_acs *p_acs, void *addr,
+		unsigned int is_userspace, unsigned int length,
+		unsigned long long *page_size);
 int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		struct hfi_client_info *user_p,
 		struct hfi_client_info *out_p);
diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index cc775e3..5a4f395 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -35,6 +35,153 @@
 #include "hfidd_proto.h"
 #include <linux/hfi/hfidd_requests.h>
 
+#define FINISH_VECTOR_LENGTH 1
+/* Validate send fifo parameters needed for open window */
+static int hfi_check_sfifo_parm(struct hfidd_acs *p_acs,
+		unsigned int is_userspace,
+		struct hfidd_window *win_p,
+		struct hfi_client_info *client_p)
+{
+	int			rc = 0;
+	unsigned long long	page_sz;
+	unsigned long long	fv_page_sz;
+
+	/* Validate the sfifo size */
+	if ((client_p->sfifo.size < HFI_SFIFO_SIZE_MIN) ||
+	    (client_p->sfifo.size > HFI_SFIFO_SIZE_MAX)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_sfifo_parm: invalid sfifo "
+			"size = 0x%llx\n",
+			client_p->sfifo.size);
+		return -EINVAL;
+	}
+
+	/*
+	 * Validate the address of sfifo is 4k aligned, and finish vector
+	 * is cache-line aligned
+	 */
+	if ((client_p->sfifo.eaddr.use.allu) & PAGE_MASK_4K) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_sfifo_parm: not page aligned, "
+			"sfifo_addr = 0x%llx\n",
+			client_p->sfifo.eaddr.use.allu);
+		return -EINVAL;
+	}
+
+	if ((client_p->sfifo_finish_vec.use.allu) & HFI_CACHE_LINE_MASK) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_sfifo_parm: not cache aligned, "
+			"sfifo_finishvec = 0x%llx\n",
+			client_p->sfifo_finish_vec.use.allu);
+		return -EINVAL;
+	}
+	/*
+	 * Validate the send finish vector are within 4K bytes of end of sfifo
+	 */
+	if (((client_p->sfifo_finish_vec.use.kptr -
+	     (client_p->sfifo.eaddr.use.kptr +
+	      client_p->sfifo.size)) >= PAGE_SIZE_4K)) {
+
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_sfifo_parm: fv too far away, "
+			"sfifo_addr = 0x%llx\n",
+			client_p->sfifo.eaddr.use.allu);
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_sfifo_parm: fv too far away, "
+			"sfifo_finishvec = 0x%llx\n",
+			client_p->sfifo_finish_vec.use.allu);
+		return -EINVAL;
+	}
+
+	/* Validate page size of sFifo */
+	rc = hfidd_get_page_size(p_acs, client_p->sfifo.eaddr.use.kptr,
+			is_userspace, client_p->sfifo.size, &page_sz);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_sfifo_parm: fail in sfifo page size, "
+			"rc=0x%x\n", rc);
+		return rc;
+	}
+
+	/* Find out the page size of send finish vector */
+	rc = hfidd_get_page_size(p_acs, client_p->sfifo_finish_vec.use.kptr,
+			is_userspace, FINISH_VECTOR_LENGTH, &fv_page_sz);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_sfifo_parm: fail in fv page size, "
+			"rc=0x%x\n", rc);
+		return rc;
+	}
+
+	/* The page size of finish vector must be the same as sfifo */
+	if (page_sz != fv_page_sz) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_sfifo_parm: diff page sz sf=0x%llx, "
+			"fv0=0x%llx\n", page_sz, fv_page_sz);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int hfi_check_rfifo_parm(struct hfidd_acs *p_acs,
+		unsigned int is_userspace,
+		struct hfidd_window *win_p,
+		struct hfi_client_info *client_p)
+{
+	int			rc = 0;
+	unsigned long long	page_sz;
+
+	/* Validate the rfifo size */
+	if ((client_p->rfifo.size < HFI_RFIFO_SIZE_MIN) ||
+	    (client_p->rfifo.size > HFI_RFIFO_SIZE_MAX)) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_rfifo_parm: invalid rfifo size = 0x%llx\n",
+			client_p->rfifo.size);
+		return -EINVAL;
+	}
+
+	/* Validate the address of rfifo is 4K aligned */
+	if ((client_p->rfifo.eaddr.use.allu) & PAGE_MASK_4K) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_rfifo_parm: not cache aligned, "
+			"rfifo_addr = 0x%llx\n",
+			client_p->rfifo.eaddr.use.allu);
+		return -EINVAL;
+	}
+
+	/* Validate page size of rFifo */
+	rc = hfidd_get_page_size(p_acs, client_p->rfifo.eaddr.use.kptr,
+			is_userspace, client_p->rfifo.size, &page_sz);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_check_rfifo_parm: fail in rfifo page size, "
+			"rc=0x%x\n", rc);
+		return rc;
+	}
+	return 0;
+}
+
+/* Validate window parameters to setup the fifos and RDMA function */
+static int hfi_validate_window_request(struct hfidd_acs *p_acs,
+	unsigned int is_userspace, struct hfi_client_info *client_p)
+{
+	int			rc = 0;
+	struct hfidd_window	*win_p;
+
+	/* Check every input parameters..... */
+	win_p = hfi_window(p_acs, client_p->window);
+
+	/* Check the request of sFifo */
+	rc = hfi_check_sfifo_parm(p_acs, is_userspace, win_p, client_p);
+	if (rc)
+		return rc;
+	/* Check the request of rFifo */
+	rc = hfi_check_rfifo_parm(p_acs, is_userspace, win_p, client_p);
+	if (rc)
+		return rc;
+	return rc;
+}
+
 /* Validate the type, state and job id for RESERVED window */
 static int hfi_validate_reserve_window_id(struct hfidd_acs *p_acs,
 		struct hfi_client_info *client_p)
@@ -164,12 +311,29 @@ static inline int hfi_validate_window_id(struct hfidd_acs *p_acs,
 	return rc;
 }
 
+static inline void hfi_restore_window_parm(struct hfidd_acs *p_acs,
+		struct hfidd_window *win_p)
+{
+	if (win_p->type != HFIDD_RESERVE_WIN) {
+		win_p->type   = HFIDD_DYNAMIC_WIN;
+		win_p->job_id = 0;
+		if (win_p->state != WIN_HERROR)
+			win_p->state = WIN_AVAILABLE;
+	} else {
+		if (win_p->state != WIN_HERROR)
+			win_p->state = WIN_RESERVED;
+	}
+	win_p->pid   = 0;
+	win_p->is_ip = 0;
+}
+
 /* Validate window number and type for open window request */
 static int hfi_validate_window_parm(struct hfidd_acs *p_acs,
 		unsigned int is_userspace,
 		struct hfi_client_info *client_p)
 {
 	int			rc = 0;
+	struct hfidd_window	*win_p;
 
 	/* Validate the window number */
 	rc = hfi_validate_window_id(p_acs, client_p, is_userspace);
@@ -179,6 +343,19 @@ static int hfi_validate_window_parm(struct hfidd_acs *p_acs,
 			"failed, rc = 0x%x\n", rc);
 		return rc;
 	}
+
+	rc = hfi_validate_window_request(p_acs, is_userspace, client_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_validate_window_parm: "
+			"hfi_validate_window_request failed, rc = 0x%x\n", rc);
+		win_p = hfi_window(p_acs, client_p->window);
+		spin_lock(&(win_p->win_lock));
+		hfi_restore_window_parm(p_acs, win_p);
+		spin_unlock(&(win_p->win_lock));
+		return rc;
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/hfi/core/hfidd_xlat.c b/drivers/net/hfi/core/hfidd_xlat.c
new file mode 100644
index 0000000..23236cc
--- /dev/null
+++ b/drivers/net/hfi/core/hfidd_xlat.c
@@ -0,0 +1,131 @@
+/*
+ * hfidd_xlat.c
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
+#include <linux/pagemap.h>
+#include <linux/hugetlb.h>
+#include <asm/page.h>
+
+#include <linux/hfi/hfidd_internal.h>
+#include "hfidd_proto.h"
+
+int hfidd_get_page_size(struct hfidd_acs *p_acs, void *addr,
+	unsigned int is_userspace,
+	unsigned int length,
+	unsigned long long *page_size)
+{
+	int			rc = 0;
+	int			i;
+	int			num_pages;
+	struct page		**page_list;
+	struct vm_area_struct	**vma_list;
+	unsigned long long	offset;
+
+	if (!is_userspace) {
+		*page_size = PAGE_SIZE;
+		return 0;
+	}
+
+	offset = (unsigned long long)addr & ~PAGE_MASK;
+	num_pages = PAGE_ALIGN(length + offset) >> PAGE_SHIFT;
+
+	page_list = kzalloc(num_pages * sizeof(struct page *),
+			GFP_KERNEL);
+	if (page_list == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_get_page_size: kzalloc failed for page_list\n");
+		return -ENOMEM;
+	}
+
+	vma_list = kzalloc(num_pages * sizeof(struct vm_area_struct **),
+			GFP_KERNEL);
+	if (vma_list == NULL) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_get_page_size: kzalloc failed for vma_list\n");
+		rc = -ENOMEM;
+		goto out1;
+	}
+
+	down_read(&current->mm->mmap_sem);
+	rc = get_user_pages(current, current->mm,
+			(unsigned long long)addr,
+			num_pages, 1, 0,	/* yes write, no force */
+			page_list, vma_list);
+	up_read(&current->mm->mmap_sem);
+
+	if (rc < num_pages) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_get_page_size: get_user_pages failed rc = %d "
+			"and numpages %d\n", rc, num_pages);
+		if (rc < 0)
+			goto out2;
+		num_pages = rc;
+		rc = -ENOMEM;
+		goto out3;
+	}
+
+	rc = 0;
+	*page_size = PAGE_SIZE;
+	for (i = 0; i < num_pages; i++) {
+		/* check for huge pages */
+		if (is_vm_hugetlb_page(vma_list[i])) {
+			/* Find huge page size */
+			*page_size = huge_page_size(hstate_vma(vma_list[i]));
+			break;
+		}
+	}
+
+	/* If memory has huge page size, check if all pages are huge pages */
+	if (*page_size != PAGE_SIZE) {
+		for (i = 0; i < num_pages; i++) {
+			/* if not huge page, set to PAGE_SIZE */
+			if (!is_vm_hugetlb_page(vma_list[i])) {
+				*page_size = PAGE_SIZE;
+				break;
+			}
+		}
+	}
+	if (*page_size == PAGE_SIZE_16G) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_get_page_size: Large page size "
+			"0x%llx use 4G\n", *page_size);
+		*page_size = PAGE_SIZE_4G;
+	}
+
+out3:
+	for (i = 0; i < num_pages; i++)
+		page_cache_release(page_list[i]);
+out2:
+	kfree(vma_list);
+out1:
+	kfree(page_list);
+	return rc;
+}
diff --git a/include/linux/hfi/hfidd_adpt.h b/include/linux/hfi/hfidd_adpt.h
index babdb14..a41825f 100644
--- a/include/linux/hfi/hfidd_adpt.h
+++ b/include/linux/hfi/hfidd_adpt.h
@@ -36,6 +36,16 @@
 #include <linux/hfi/hfidd_client.h>
 
 
+#define HFI_SFIFO_SIZE_MIN	0x10000		/* min =  64K software limit */
+#define HFI_SFIFO_SIZE_MAX	0x800000	/* max =  8M */
+
+#define HFI_RFIFO_SIZE_MIN	0x1000		/* min =  4K */
+#define HFI_RFIFO_SIZE_MAX	0x8000000	/* max =  128M */
+
+#define HFI_CACHE_LINE_SIZE	0x80
+#define HFI_CACHE_LINE_MASK	(HFI_CACHE_LINE_SIZE - 1)
+#define HFI_CACHE_LINE_SHIFT	7
+
 #define HFI_WNUM_SHIFT		32
 #define HFI_CAUNUM_SHIFT	32
 #define HFI_SHIFT_OCTANT	3
@@ -57,4 +67,11 @@
 #define WIN_PENDING		6
 #define WIN_FAIL_CLOSE		7
 
+#define PAGE_MASK_4K		(PAGE_SIZE_4K - 1)
+#define PAGE_MASK_64K		(PAGE_SIZE_64K - 1)
+#define PAGE_MASK_1M		(PAGE_SIZE_1M - 1)
+#define PAGE_MASK_16M		(PAGE_SIZE_16M - 1)
+#define PAGE_MASK_4G		(PAGE_SIZE_4G - 1)
+#define PAGE_MASK_16G		(PAGE_SIZE_16G - 1)
+
 #endif /* _HFIDD_ADPT_H_ */
-- 
1.7.3.5

