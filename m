From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.21-rc2] iw_cxgb3: Don't use mm after its freed in
	iwch_mmap().
Date: Fri, 02 Mar 2007 16:06:36 -0600
Message-ID: <1172873196.21241.62.camel__2964.92970451272$1172873243$gmane$org@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Netdev@vger.kernel.org, General@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030528AbXCBWGi@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Don't use mm after its freed in iwch_mmap().

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_provider.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index 4af1c0f..f2774ae 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -331,6 +331,7 @@ static int iwch_mmap(struct ib_ucontext 
 	int ret = 0;
 	struct iwch_mm_entry *mm;
 	struct iwch_ucontext *ucontext;
+	u64 addr;
 
 	PDBG("%s pgoff 0x%lx key 0x%x len %d\n", __FUNCTION__, vma->vm_pgoff,
 	     key, len);
@@ -345,10 +346,11 @@ static int iwch_mmap(struct ib_ucontext 
 	mm = remove_mmap(ucontext, key, len);
 	if (!mm)
 		return -EINVAL;
+	addr = mm->addr;
 	kfree(mm);
 
-	if ((mm->addr >= rdev_p->rnic_info.udbell_physbase) &&
-	    (mm->addr < (rdev_p->rnic_info.udbell_physbase +
+	if ((addr >= rdev_p->rnic_info.udbell_physbase) &&
+	    (addr < (rdev_p->rnic_info.udbell_physbase +
 		       rdev_p->rnic_info.udbell_len))) {
 
 		/*
@@ -362,7 +364,7 @@ static int iwch_mmap(struct ib_ucontext 
 		vma->vm_flags |= VM_DONTCOPY | VM_DONTEXPAND;
 		vma->vm_flags &= ~VM_MAYREAD;
 		ret = io_remap_pfn_range(vma, vma->vm_start,
-					 mm->addr >> PAGE_SHIFT,
+					 addr >> PAGE_SHIFT,
 				         len, vma->vm_page_prot);
 	} else {
 
@@ -370,7 +372,7 @@ static int iwch_mmap(struct ib_ucontext 
 		 * Map WQ or CQ contig dma memory...
 		 */
 		ret = remap_pfn_range(vma, vma->vm_start,
-				      mm->addr >> PAGE_SHIFT,
+				      addr >> PAGE_SHIFT,
 				      len, vma->vm_page_prot);
 	}
 
