From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 1/2] pgtable: Add API to query if write combining is available
Date: Sun,  5 Oct 2014 11:22:21 +0300
Message-ID: <1412497342-12451-2-git-send-email-ogerlitz@mellanox.com>
References: <1412497342-12451-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moshe Lazer <moshel@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46508 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751203AbaJEIXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 04:23:15 -0400
In-Reply-To: <1412497342-12451-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Lazer <moshel@mellanox.com>

Currently the kernel write-combining interface provides a best effort
mechanism in which the caller simply invokes pgprot_writecombine().

If write combining is available, the region is mapped for it, otherwise
the region is (silently) mapped as non-cached.

In some cases, however, the calling driver must know if write combining
is available, so a silent best effort mechanism is not sufficient.

Add writecombine_available(), which returns true if the system
supports write combining and false if it doesn't.

Signed-off-by: Moshe Lazer <moshel@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 arch/arm/include/asm/pgtable.h       |    6 ++++++
 arch/arm64/include/asm/pgtable.h     |    5 +++++
 arch/ia64/include/asm/pgtable.h      |    6 ++++++
 arch/powerpc/include/asm/pgtable.h   |    6 ++++++
 arch/x86/include/asm/pgtable_types.h |    2 ++
 arch/x86/mm/pat.c                    |    9 +++++++++
 include/asm-generic/pgtable.h        |    8 ++++++++
 7 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index 01baef0..ce06b64 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -119,6 +119,12 @@ extern pgprot_t		pgprot_s2_device;
 #define pgprot_writecombine(prot) \
 	__pgprot_modify(prot, L_PTE_MT_MASK, L_PTE_MT_BUFFERABLE)
 
+#define writecombine_available writecombine_available
+static inline bool writecombine_available(void)
+{
+	return true;
+}
+
 #define pgprot_stronglyordered(prot) \
 	__pgprot_modify(prot, L_PTE_MT_MASK, L_PTE_MT_UNCACHED)
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index ffe1ba0..6ab0630 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -296,6 +296,11 @@ static inline int has_transparent_hugepage(void)
 	__pgprot_modify(prot, PTE_ATTRINDX_MASK, PTE_ATTRINDX(MT_DEVICE_nGnRnE) | PTE_PXN | PTE_UXN)
 #define pgprot_writecombine(prot) \
 	__pgprot_modify(prot, PTE_ATTRINDX_MASK, PTE_ATTRINDX(MT_NORMAL_NC) | PTE_PXN | PTE_UXN)
+#define writecombine_available writecombine_available
+static inline bool writecombine_available(void)
+{
+	return true;
+}
 #define __HAVE_PHYS_MEM_ACCESS_PROT
 struct file;
 extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 7935115..2e44501 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -356,6 +356,12 @@ static inline void set_pte(pte_t *ptep, pte_t pteval)
 #define pgprot_noncached(prot)		__pgprot((pgprot_val(prot) & ~_PAGE_MA_MASK) | _PAGE_MA_UC)
 #define pgprot_writecombine(prot)	__pgprot((pgprot_val(prot) & ~_PAGE_MA_MASK) | _PAGE_MA_WC)
 
+#define writecombine_available writecombine_available
+static inline bool writecombine_available(void)
+{
+	return true;
+}
+
 struct file;
 extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				     unsigned long size, pgprot_t vma_prot);
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index d98c1ec..3232d98 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -267,6 +267,12 @@ extern int ptep_set_access_flags(struct vm_area_struct *vma, unsigned long addre
 
 #define pgprot_writecombine pgprot_noncached_wc
 
+#define writecombine_available writecombine_available
+static inline bool writecombine_available(void)
+{
+	return true;
+}
+
 struct file;
 extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				     unsigned long size, pgprot_t vma_prot);
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index f216963..7d3dc79 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -337,6 +337,8 @@ extern int nx_enabled;
 
 #define pgprot_writecombine	pgprot_writecombine
 extern pgprot_t pgprot_writecombine(pgprot_t prot);
+#define writecombine_available  writecombine_available
+bool writecombine_available(void);
 
 /* Indicate that x86 has its own track and untrack pfn vma functions */
 #define __HAVE_PFNMAP_TRACKING
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 6574388..851ee51 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -797,6 +797,15 @@ pgprot_t pgprot_writecombine(pgprot_t prot)
 }
 EXPORT_SYMBOL_GPL(pgprot_writecombine);
 
+bool writecombine_available(void)
+{
+	if (pat_enabled)
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL_GPL(writecombine_available);
+
 #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_X86_PAT)
 
 static struct memtype *memtype_get_idx(loff_t pos)
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 53b2acc..2cb40d9 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -249,6 +249,14 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 #define pgprot_writecombine pgprot_noncached
 #endif
 
+#ifndef writecombine_available
+#define writecombine_available writecombine_available
+static inline bool writecombine_available(void)
+{
+	return false;
+}
+#endif
+
 /*
  * When walking page tables, get the address of the next boundary,
  * or the end address of the range if that comes earlier.  Although no
-- 
1.7.1
