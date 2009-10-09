From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
	bitmap_find_next_zero_area
Date: Fri,  9 Oct 2009 17:29:15 +0900
Message-ID: <1255076961-21325-2-git-send-email-akinobu.mita@gmail.com>
References: <>
 <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@suse.de>,
	linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>,
	x86@kernel.org, netdev@vger.kernel.org,
	Akinobu Mita <akinobu.mita@gmail.com>, linux-altix@sgi.com,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linuxppc-dev@ozlabs.org, Ingo Molnar <mingo@redhat.com>,
	Paul Mackerras <paulus@samba.org>,
	"H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Lothar Wassmann <LW@KARO-electronics.de>
To: linux-kernel@vger.kernel.org,
	 akpm@linux-foundation.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

This introduces new bitmap functions:

bitmap_set: Set specified bit area
bitmap_clear: Clear specified bit area
bitmap_find_next_zero_area: Find free bit area

These are stolen from iommu helper.

I changed the return value of bitmap_find_next_zero_area if there is
no zero area.

find_next_zero_area in iommu helper: returns -1
bitmap_find_next_zero_area: return >= bitmap size

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
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 include/linux/bitmap.h |   11 +++++++++++
 lib/bitmap.c           |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 0 deletions(-)

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
index 7025658..95070fa 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -271,6 +271,53 @@ int __bitmap_weight(const unsigned long *bitmap, int bits)
 }
 EXPORT_SYMBOL(__bitmap_weight);
 
+void bitmap_set(unsigned long *map, int i, int len)
+{
+	int end = i + len;
+
+	while (i < end) {
+		__set_bit(i, map);
+		i++;
+	}
+}
+EXPORT_SYMBOL(bitmap_set);
+
+void bitmap_clear(unsigned long *map, int start, int nr)
+{
+	int end = start + nr;
+
+	while (start < end) {
+		__clear_bit(start, map);
+		start++;
+	}
+}
+EXPORT_SYMBOL(bitmap_clear);
+
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
+	index = (index + align_mask) & ~align_mask;
+
+	end = index + nr;
+	if (end >= size)
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
1.5.4.3
