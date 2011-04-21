From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 18/27] HFI: Map window registers into user process
Date: Thu, 21 Apr 2011 17:38:48 -0400
Message-ID: <1303421937-2325-19-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e38.co.us.ibm.com ([32.97.110.159]:36256 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab1DUVjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 17:39:43 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LDrvVM004286
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 07:53:57 -0600
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdCrM095812
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 15:39:12 -0600
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLdCDZ012731
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:12 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

User-space applications send and receive without kernel involvement, once
the window is open. A page of hardware registers controlling the appropriate
window is mapped into the user's address space.

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
 drivers/net/hfi/core/hfidd_map.c    |   99 +++++++++++++++++++++++++++++++++++
 drivers/net/hfi/core/hfidd_proto.h  |    4 ++
 drivers/net/hfi/core/hfidd_window.c |   51 ++++++++++++++++++-
 4 files changed, 154 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/hfi/core/hfidd_map.c

diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
index 8d5558d..3adf07e 100644
--- a/drivers/net/hfi/core/Makefile
+++ b/drivers/net/hfi/core/Makefile
@@ -5,5 +5,6 @@ hfi_core-objs:=	hfidd_adpt.o \
 		hfidd_window.o \
 		hfidd_init.o \
 		hfidd_xlat.o \
+		hfidd_map.o \
 		hfidd_hcalls.o
 obj-$(CONFIG_HFI) += hfi_core.o
diff --git a/drivers/net/hfi/core/hfidd_map.c b/drivers/net/hfi/core/hfidd_map.c
new file mode 100644
index 0000000..816e7ae
--- /dev/null
+++ b/drivers/net/hfi/core/hfidd_map.c
@@ -0,0 +1,99 @@
+/*
+ * hfidd_map.c
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
+#include <linux/io.h>
+#include <linux/hfi/hfidd_internal.h>
+
+int hfidd_mmap(struct hfidd_acs *p_acs, void **eaddr, int size,
+		unsigned long vm_flag, unsigned long long busaddr,
+		unsigned long long offset)
+{
+	struct vm_area_struct	*vma;
+	unsigned long		vsize;
+	int			rc;
+
+	down_write(&current->mm->mmap_sem);
+	*eaddr = (void *)do_mmap(NULL, (unsigned long)*eaddr, size, PROT_WRITE,
+			MAP_SHARED | MAP_ANONYMOUS,
+			offset);
+	up_write(&current->mm->mmap_sem);
+	if (*eaddr) {
+		vma = find_vma(current->mm, (u64) *eaddr);
+		if (!vma) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfidd_mmap: find_vma failed\n");
+			return -ENOMEM;
+		}
+	} else {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_mmap: do_mmap failed\n");
+		return -ENOMEM;
+	}
+
+	vsize = vma->vm_end - vma->vm_start;
+	if (vsize != size) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_mmap: Wrong sizes: vsize = %ld "
+			"size = %d\n", vsize, size);
+		return -EINVAL;
+	}
+
+	if (vm_flag == VM_RESERVED)
+		vma->vm_page_prot = pgprot_val(vma->vm_page_prot);
+	else
+		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	vma->vm_flags |= vm_flag;
+
+	rc = remap_pfn_range(vma, vma->vm_start, busaddr >> PAGE_SHIFT, size,
+			vma->vm_page_prot);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_mmap: remap_pfn_range failed\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+int hfidd_unmap(void *addr, int size)
+{
+	int rc = 0;
+	struct mm_struct *mm = current->mm;
+
+	if (mm && (addr != NULL)) {
+		down_write(&mm->mmap_sem);
+		rc = do_munmap(mm, (unsigned long)addr, size);
+		up_write(&mm->mmap_sem);
+	}
+
+	return rc;
+}
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index c4ed215..1f7fe80 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -57,6 +57,10 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 int hfi_register_rpages(struct hfidd_acs *p_acs, unsigned long long mr_handle,
 		unsigned int submr, struct hfidd_vlxmem *xtab_p,
 		unsigned int *mapped_pages);
+int hfidd_mmap(struct hfidd_acs *p_acs, void **eaddr, int size,
+		unsigned long vm_flag, unsigned long long busaddr,
+		unsigned long long offset);
+int hfidd_unmap(void *addr, int size);
 int hfidd_get_phyp_page(struct hfidd_acs *p_acs, caddr_t *page,
 	caddr_t *laddr, int size);
 void hfidd_release_phyp_page(caddr_t page, int size);
diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index c20277b..5d319a1 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -874,6 +874,44 @@ setup_window_parm_err1:
 	return rc;
 }
 
+/* Map the window mmio registers - only user space window */
+static int hfi_map_mmio_regs(struct hfidd_acs *p_acs,
+		unsigned int is_userspace,
+		struct hfidd_window *win_p,
+		struct hfi_client_info *client_p)
+{
+	int			rc = 0;
+	unsigned long long	offset;
+	void			*tmp_eaddr;
+
+	if (!is_userspace) {
+		/* No translation, just pass back the logical address */
+		client_p->mmio_regs.use.kptr = (void *)win_p->mmio_regs;
+		win_p->client_info.mmio_regs.use.kptr =
+				(void *)win_p->mmio_regs;
+	} else {
+		/*
+		 * Translate mmio_regs from logical to effective address: 1st
+		 * page
+		 */
+		tmp_eaddr = 0;
+		offset = (client_p->window) << PAGE_SHIFT_64K;
+		rc = hfidd_mmap(p_acs, &tmp_eaddr, PAGE_SIZE_64K,
+				VM_RESERVED | VM_IO,
+				(long long)win_p->mmio_regs, offset);
+		if (rc) {
+			dev_printk(KERN_ERR, p_acs->hfidd_dev,
+				"hfi_map_mmio_regs: hfidd_mmap mmio_regs "
+				"failed, rc = 0x%x, mmio_regs = 0x%llx\n",
+				rc, (unsigned long long)win_p->mmio_regs);
+			return rc;
+		}
+		client_p->mmio_regs.use.kptr = tmp_eaddr;
+		win_p->client_info.mmio_regs.use.kptr = tmp_eaddr;
+	}
+	return 0;
+}
+
 /*
  * Allows an user/kernel window to send/receive network traffic thru HFI
  * adapter. This function will allocate the system resources needed to open
@@ -940,6 +978,14 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		goto hfidd_open_window_func_err4;
 	}
 
+	rc = hfi_map_mmio_regs(p_acs, is_userspace, win_p, local_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_open_window_func: hfi_map_mmio_regs "
+			"failed, rc = 0x%x\n", rc);
+		goto hfidd_open_window_func_err4;
+	}
+
 	/* tell user the local ISR id */
 	local_p->local_isrid = p_acs->isr;
 	win_p->client_info.local_isrid = p_acs->isr;
@@ -951,7 +997,7 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		dev_printk(KERN_ERR, p_acs->hfidd_dev,
 			"hfidd_open_window_func: hfi_copy_to_user "
 			"failed, rc = 0x%x\n", rc);
-		goto hfidd_open_window_func_err4;
+		goto hfidd_open_window_func_err5;
 	}
 
 	spin_lock(&(win_p->win_lock));
@@ -963,6 +1009,9 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 	kfree(local_p);
 	return rc;
 
+hfidd_open_window_func_err5:
+	if (is_userspace)
+		hfidd_unmap(local_p->mmio_regs.use.kptr, PAGE_SIZE_64K);
 hfidd_open_window_func_err4:
 	hfi_destroy_window_parm(p_acs, is_userspace, win_p, local_p);
 hfidd_open_window_func_err3:
-- 
1.7.3.5

