From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: 2.6.24-rc6-mm1
Date: Wed, 09 Jan 2008 08:57:53 +0900
Message-ID: <20080109085753O.fujita.tomonori@lab.ntt.co.jp>
References: <64bb37e0801061203l503f29f0hd922a1347f8169ac@mail.gmail.com>
	<20080107151639P.fujita.tomonori@lab.ntt.co.jp>
	<20080108155948.GC26114@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, just.for.lkml@googlemail.com,
	tomof@acm.org, jarkao2@gmail.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, neilb@suse.de, bfields@fieldses.org,
	netdev@vger.kernel.org, tom@opengridcomputing.com
To: mingo@elte.hu, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:43816 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbYAHX7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:59:22 -0500
In-Reply-To: <20080108155948.GC26114@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jan 2008 16:59:48 +0100
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
> > The patches are available at:
> > 
> > http://www.kernel.org/pub/linux/kernel/people/tomo/iommu/
> > 
> > Or if you prefer the git tree:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/tomo/linux-2.6-misc.git 
> > iommu-sg-fixes
> 
> btw., these improvements to the IOMMU code are in -mm and will go into 
> v2.6.25, right? The changes look robust to me.

Thanks, they have been in -mm though the iommu helper fix hasn't
yet. Balbir Singh found the bug in 2.6.24-rc6-mm1. I've just check
mmotm and found that the IOMMU helper patch doesn't include the fix.

Andrew, can you replace

iommu-sg-add-iommu-helper-functions-for-the-free-area-management.patch

with the updated patch:

http://ozlabs.org/pipermail/linuxppc-dev/2007-December/048997.html

For your convenience I've attached the updated patch too.

Hopefully, they will go into v2.6.25. At least, I hope that the
patches (0001-0011) that make the IOMMUs respect segment size limits
when merging sg lists will be merged. They are simple and I got ACKs
on POWER and PARISC.


Thanks,

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] add IOMMU helper functions for the free area management

This adds IOMMU helper functions for the free area management.  These
functions take care of LLD's segment boundary limit for IOMMUs.  They would be
useful for IOMMUs that use bitmap for the free area management.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 include/linux/iommu-helper.h |    7 ++++
 lib/Makefile                 |    1 +
 lib/iommu-helper.c           |   80 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 88 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/iommu-helper.h
 create mode 100644 lib/iommu-helper.c

diff --git a/include/linux/iommu-helper.h b/include/linux/iommu-helper.h
new file mode 100644
index 0000000..4dd4c04
--- /dev/null
+++ b/include/linux/iommu-helper.h
@@ -0,0 +1,7 @@
+extern unsigned long iommu_area_alloc(unsigned long *map, unsigned long size,
+				      unsigned long start, unsigned int nr,
+				      unsigned long shift,
+				      unsigned long boundary_size,
+				      unsigned long align_mask);
+extern void iommu_area_free(unsigned long *map, unsigned long start,
+			    unsigned int nr);
diff --git a/lib/Makefile b/lib/Makefile
index b6793ed..0e7383f 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -64,6 +64,7 @@ obj-$(CONFIG_SMP) += percpu_counter.o
 obj-$(CONFIG_AUDIT_GENERIC) += audit.o
 
 obj-$(CONFIG_SWIOTLB) += swiotlb.o
+obj-$(CONFIG_IOMMU_HELPER) += iommu-helper.o
 obj-$(CONFIG_FAULT_INJECTION) += fault-inject.o
 
 lib-$(CONFIG_GENERIC_BUG) += bug.o
diff --git a/lib/iommu-helper.c b/lib/iommu-helper.c
new file mode 100644
index 0000000..495575a
--- /dev/null
+++ b/lib/iommu-helper.c
@@ -0,0 +1,80 @@
+/*
+ * IOMMU helper functions for the free area management
+ */
+
+#include <linux/module.h>
+#include <linux/bitops.h>
+
+static unsigned long find_next_zero_area(unsigned long *map,
+					 unsigned long size,
+					 unsigned long start,
+					 unsigned int nr,
+					 unsigned long align_mask)
+{
+	unsigned long index, end, i;
+again:
+	index = find_next_zero_bit(map, size, start);
+
+	/* Align allocation */
+	index = (index + align_mask) & ~align_mask;
+
+	end = index + nr;
+	if (end >= size)
+		return -1;
+	for (i = index; i < end; i++) {
+		if (test_bit(i, map)) {
+			start = i+1;
+			goto again;
+		}
+	}
+	return index;
+}
+
+static inline void set_bit_area(unsigned long *map, unsigned long i,
+				int len)
+{
+	unsigned long end = i + len;
+	while (i < end) {
+		__set_bit(i, map);
+		i++;
+	}
+}
+
+static inline int is_span_boundary(unsigned int index, unsigned int nr,
+				   unsigned long shift,
+				   unsigned long boundary_size)
+{
+	shift = (shift + index) & (boundary_size - 1);
+	return shift + nr > boundary_size;
+}
+
+unsigned long iommu_area_alloc(unsigned long *map, unsigned long size,
+			       unsigned long start, unsigned int nr,
+			       unsigned long shift, unsigned long boundary_size,
+			       unsigned long align_mask)
+{
+	unsigned long index;
+again:
+	index = find_next_zero_area(map, size, start, nr, align_mask);
+	if (index != -1) {
+		if (is_span_boundary(index, nr, shift, boundary_size)) {
+			/* we could do more effectively */
+			start = index + 1;
+			goto again;
+		}
+		set_bit_area(map, index, nr);
+	}
+	return index;
+}
+EXPORT_SYMBOL(iommu_area_alloc);
+
+void iommu_area_free(unsigned long *map, unsigned long start, unsigned int nr)
+{
+	unsigned long end = start + nr;
+
+	while (start < end) {
+		__clear_bit(start, map);
+		start++;
+	}
+}
+EXPORT_SYMBOL(iommu_area_free);
-- 
1.5.3.4


