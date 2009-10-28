From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 1/7] bitmap: Introduce bitmap_set, bitmap_clear, bitmap_find_next_zero_area
Date: Wed, 28 Oct 2009 17:43:11 +0900
Message-ID: <1256719397-4258-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lothar Wassmann <LW@KARO-electronics.de>,
	linux-usb@vger.kernel.org, Roland Dreier <rolandd@cisco.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	netdev@vger.kernel.org, Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org,
	linux-altix@sgi.com, Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-ia64-owner@vger.kernel.org>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This introduces new bitmap functions:

bitmap_set: Set specified bit area
bitmap_clear: Clear specified bit area
bitmap_find_next_zero_area: Find free bit area

These are mostly stolen from iommu helper. The differences are:

- Use find_next_bit instead of doing test_bit for each bit

- Rewrite bitmap_set and bitmap_clear

  Instead of setting or clearing for each bit.

- Check the last bit of the limit

  iommu-helper doesn't want to find such area

- The return value if there is no zero area

  find_next_zero_area in iommu helper: returns -1
  bitmap_find_next_zero_area: return >= bitmap size

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@ozlabs.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Lothar Wassmann <LW@KARO-electronics.de>
Cc: linux-usb@vger.kernel.org
Cc: Roland Dreier <rolandd@cisco.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-altix@sgi.com
Cc: Joerg Roedel <joerg.roedel@amd.com>
---
 include/linux/bitmap.h |   11 ++++++
 lib/bitmap.c           |   81 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 92 insertions(+), 0 deletions(-)

diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
index 756d78b..daf8c48 100644
--- a/include/linux/bitmap.h
+++ b/include/linux/bitmap.h
@@ -42,6 +42,9 @@
  * bitmap_empty(src, nbits)			Are all bits zero in *src?
  * bitmap_full(src, nbits)			Are all bits set in *src?
  * bitmap_weight(src, nbits)			Hamming Weight: number set bits
+ * bitmap_set(dst, pos, nbits)			Set specified bit area
+ * bitmap_clear(dst, pos, nbits)		Clear specified bit area
+ * bitmap_find_next_zero_area(buf, len, pos, n, mask)	Find bit free area
  * bitmap_shift_right(dst, src, n, nbits)	*dst = *src >> n
  * bitmap_shift_left(dst, src, n, nbits)	*dst = *src << n
  * bitmap_remap(dst, src, old, new, nbits)	*dst = map(old, new)(src)
@@ -108,6 +111,14 @@ extern int __bitmap_subset(const unsigned long *bitmap1,
 			const unsigned long *bitmap2, int bits);
 extern int __bitmap_weight(const unsigned long *bitmap, int bits);
 
+extern void bitmap_set(unsigned long *map, int i, int len);
+extern void bitmap_clear(unsigned long *map, int start, int nr);
+extern unsigned long bitmap_find_next_zero_area(unsigned long *map,
+					 unsigned long size,
+					 unsigned long start,
+					 unsigned int nr,
+					 unsigned long align_mask);
+
 extern int bitmap_scnprintf(char *buf, unsigned int len,
 			const unsigned long *src, int nbits);
 extern int __bitmap_parse(const char *buf, unsigned int buflen, int is_user,
diff --git a/lib/bitmap.c b/lib/bitmap.c
index 7025658..11bf497 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -271,6 +271,87 @@ int __bitmap_weight(const unsigned long *bitmap, int bits)
 }
 EXPORT_SYMBOL(__bitmap_weight);
 
+#define BITMAP_FIRST_WORD_MASK(start) (~0UL << ((start) % BITS_PER_LONG))
+
+void bitmap_set(unsigned long *map, int start, int nr)
+{
+	unsigned long *p = map + BIT_WORD(start);
+	const int size = start + nr;
+	int bits_to_set = BITS_PER_LONG - (start % BITS_PER_LONG);
+	unsigned long mask_to_set = BITMAP_FIRST_WORD_MASK(start);
+
+	while (nr - bits_to_set >= 0) {
+		*p |= mask_to_set;
+		nr -= bits_to_set;
+		bits_to_set = BITS_PER_LONG;
+		mask_to_set = ~0UL;
+		p++;
+	}
+	if (nr) {
+		mask_to_set &= BITMAP_LAST_WORD_MASK(size);
+		*p |= mask_to_set;
+	}
+}
+EXPORT_SYMBOL(bitmap_set);
+
+void bitmap_clear(unsigned long *map, int start, int nr)
+{
+	unsigned long *p = map + BIT_WORD(start);
+	const int size = start + nr;
+	int bits_to_clear = BITS_PER_LONG - (start % BITS_PER_LONG);
+	unsigned long mask_to_clear = BITMAP_FIRST_WORD_MASK(start);
+
+	while (nr - bits_to_clear >= 0) {
+		*p &= ~mask_to_clear;
+		nr -= bits_to_clear;
+		bits_to_clear = BITS_PER_LONG;
+		mask_to_clear = ~0UL;
+		p++;
+	}
+	if (nr) {
+		mask_to_clear &= BITMAP_LAST_WORD_MASK(size);
+		*p &= ~mask_to_clear;
+	}
+}
+EXPORT_SYMBOL(bitmap_clear);
+
+/*
+ * bitmap_find_next_zero_area - find a contiguous aligned zero area
+ * @map: The address to base the search on
+ * @size: The bitmap size in bits
+ * @start: The bitnumber to start searching at
+ * @nr: The number of zeroed bits we're looking for
+ * @align_mask: Alignment mask for zero area
+ *
+ * The @align_mask should be one less than a power of 2; the effect is that
+ * the bit offset of all zero areas this function finds is multiples of that
+ * power of 2. A @align_mask of 0 means no alignment is required.
+ */
+unsigned long bitmap_find_next_zero_area(unsigned long *map,
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
+	index = __ALIGN_MASK(index, align_mask);
+
+	end = index + nr;
+	if (end > size)
+		return end;
+	i = find_next_bit(map, end, index);
+	if (i < end) {
+		start = i + 1;
+		goto again;
+	}
+	return index;
+}
+EXPORT_SYMBOL(bitmap_find_next_zero_area);
+
 /*
  * Bitmap printing & parsing functions: first version by Bill Irwin,
  * second version by Paul Jackson, third by Joe Korty.
-- 
1.6.5.1

