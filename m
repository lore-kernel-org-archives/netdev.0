From: Kan Liang <kan.liang@intel.com>
Subject: [PATCH V8 2/8] test_bitmap: unit tests for lib/bitmap.c
Date: Thu, 18 Feb 2016 07:39:50 -0500
Message-ID: <1455799196-8947-3-git-send-email-kan.liang@intel.com>
References: <1455799196-8947-1-git-send-email-kan.liang@intel.com>
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com, Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org,
	ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29079 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1947707AbcBRUAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 15:00:14 -0500
In-Reply-To: <1455799196-8947-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

This is mainly testing bitmap construction and conversion to/from u32[]
for now.

Tested:
  qemu i386, x86_64, ppc, ppc64 BE and LE, ARM.

Signed-off-by: David Decotigny <decot@googlers.com>
---
 lib/Kconfig.debug                     |   8 +
 lib/Makefile                          |   1 +
 lib/test_bitmap.c                     | 358 ++++++++++++++++++++++++++++++++++
 tools/testing/selftests/lib/Makefile  |   2 +-
 tools/testing/selftests/lib/bitmap.sh |  10 +
 5 files changed, 378 insertions(+), 1 deletion(-)
 create mode 100644 lib/test_bitmap.c
 create mode 100755 tools/testing/selftests/lib/bitmap.sh

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index ecb9e75..f890ee5 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1738,6 +1738,14 @@ config TEST_KSTRTOX
 config TEST_PRINTF
 	tristate "Test printf() family of functions at runtime"
 
+config TEST_BITMAP
+	tristate "Test bitmap_*() family of functions at runtime"
+	default n
+	help
+	  Enable this option to test the bitmap functions at boot.
+
+	  If unsure, say N.
+
 config TEST_RHASHTABLE
 	tristate "Perform selftest on resizable hash table"
 	default n
diff --git a/lib/Makefile b/lib/Makefile
index a7c26a4..dda4039 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -43,6 +43,7 @@ obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
 obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_keys.o
 obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_key_base.o
 obj-$(CONFIG_TEST_PRINTF) += test_printf.o
+obj-$(CONFIG_TEST_BITMAP) += test_bitmap.o
 
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o += -DDEBUG
diff --git a/lib/test_bitmap.c b/lib/test_bitmap.c
new file mode 100644
index 0000000..e2cbd43
--- /dev/null
+++ b/lib/test_bitmap.c
@@ -0,0 +1,358 @@
+/*
+ * Test cases for printf facility.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/bitmap.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/printk.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+
+static unsigned total_tests __initdata;
+static unsigned failed_tests __initdata;
+
+static char pbl_buffer[PAGE_SIZE] __initdata;
+
+
+static bool __init
+__check_eq_uint(const char *srcfile, unsigned int line,
+		const unsigned int exp_uint, unsigned int x)
+{
+	if (exp_uint != x) {
+		pr_warn("[%s:%u] expected %u, got %u\n",
+			srcfile, line, exp_uint, x);
+		return false;
+	}
+	return true;
+}
+
+
+static bool __init
+__check_eq_bitmap(const char *srcfile, unsigned int line,
+		  const unsigned long *exp_bmap, unsigned int exp_nbits,
+		  const unsigned long *bmap, unsigned int nbits)
+{
+	if (exp_nbits != nbits) {
+		pr_warn("[%s:%u] bitmap length mismatch: expected %u, got %u\n",
+			srcfile, line, exp_nbits, nbits);
+		return false;
+	}
+
+	if (!bitmap_equal(exp_bmap, bmap, nbits)) {
+		pr_warn("[%s:%u] bitmaps contents differ: expected \"%*pbl\", got \"%*pbl\"\n",
+			srcfile, line,
+			exp_nbits, exp_bmap, nbits, bmap);
+		return false;
+	}
+	return true;
+}
+
+static bool __init
+__check_eq_pbl(const char *srcfile, unsigned int line,
+	       const char *expected_pbl,
+	       const unsigned long *bitmap, unsigned int nbits)
+{
+	snprintf(pbl_buffer, sizeof(pbl_buffer), "%*pbl", nbits, bitmap);
+	if (strcmp(expected_pbl, pbl_buffer)) {
+		pr_warn("[%s:%u] expected \"%s\", got \"%s\"\n",
+			srcfile, line,
+			expected_pbl, pbl_buffer);
+		return false;
+	}
+	return true;
+}
+
+static bool __init
+__check_eq_u32_array(const char *srcfile, unsigned int line,
+		     const u32 *exp_arr, unsigned int exp_len,
+		     const u32 *arr, unsigned int len)
+{
+	if (exp_len != len) {
+		pr_warn("[%s:%u] array length differ: expected %u, got %u\n",
+			srcfile, line,
+			exp_len, len);
+		return false;
+	}
+
+	if (memcmp(exp_arr, arr, len*sizeof(*arr))) {
+		pr_warn("[%s:%u] array contents differ\n", srcfile, line);
+		print_hex_dump(KERN_WARNING, "  exp:  ", DUMP_PREFIX_OFFSET,
+			       32, 4, exp_arr, exp_len*sizeof(*exp_arr), false);
+		print_hex_dump(KERN_WARNING, "  got:  ", DUMP_PREFIX_OFFSET,
+			       32, 4, arr, len*sizeof(*arr), false);
+		return false;
+	}
+
+	return true;
+}
+
+#define __expect_eq(suffix, ...)					\
+	({								\
+		int result = 0;						\
+		total_tests++;						\
+		if (!__check_eq_ ## suffix(__FILE__, __LINE__,		\
+					   ##__VA_ARGS__)) {		\
+			failed_tests++;					\
+			result = 1;					\
+		}							\
+		result;							\
+	})
+
+#define expect_eq_uint(...)		__expect_eq(uint, ##__VA_ARGS__)
+#define expect_eq_bitmap(...)		__expect_eq(bitmap, ##__VA_ARGS__)
+#define expect_eq_pbl(...)		__expect_eq(pbl, ##__VA_ARGS__)
+#define expect_eq_u32_array(...)	__expect_eq(u32_array, ##__VA_ARGS__)
+
+static void __init test_zero_fill_copy(void)
+{
+	DECLARE_BITMAP(bmap1, 1024);
+	DECLARE_BITMAP(bmap2, 1024);
+
+	bitmap_zero(bmap1, 1024);
+	bitmap_zero(bmap2, 1024);
+
+	/* single-word bitmaps */
+	expect_eq_pbl("", bmap1, 23);
+
+	bitmap_fill(bmap1, 19);
+	expect_eq_pbl("0-18", bmap1, 1024);
+
+	bitmap_copy(bmap2, bmap1, 23);
+	expect_eq_pbl("0-18", bmap2, 1024);
+
+	bitmap_fill(bmap2, 23);
+	expect_eq_pbl("0-22", bmap2, 1024);
+
+	bitmap_copy(bmap2, bmap1, 23);
+	expect_eq_pbl("0-18", bmap2, 1024);
+
+	bitmap_zero(bmap1, 23);
+	expect_eq_pbl("", bmap1, 1024);
+
+	/* multi-word bitmaps */
+	bitmap_zero(bmap1, 1024);
+	expect_eq_pbl("", bmap1, 1024);
+
+	bitmap_fill(bmap1, 109);
+	expect_eq_pbl("0-108", bmap1, 1024);
+
+	bitmap_copy(bmap2, bmap1, 1024);
+	expect_eq_pbl("0-108", bmap2, 1024);
+
+	bitmap_fill(bmap2, 1024);
+	expect_eq_pbl("0-1023", bmap2, 1024);
+
+	bitmap_copy(bmap2, bmap1, 1024);
+	expect_eq_pbl("0-108", bmap2, 1024);
+
+	/* the following tests assume a 32- or 64-bit arch (even 128b
+	 * if we care)
+	 */
+
+	bitmap_fill(bmap2, 1024);
+	bitmap_copy(bmap2, bmap1, 109);  /* ... but 0-padded til word length */
+	expect_eq_pbl("0-108,128-1023", bmap2, 1024);
+
+	bitmap_fill(bmap2, 1024);
+	bitmap_copy(bmap2, bmap1, 97);  /* ... but aligned on word length */
+	expect_eq_pbl("0-108,128-1023", bmap2, 1024);
+
+	bitmap_zero(bmap2, 97);  /* ... but 0-padded til word length */
+	expect_eq_pbl("128-1023", bmap2, 1024);
+}
+
+static void __init test_bitmap_u32_array_conversions(void)
+{
+	DECLARE_BITMAP(bmap1, 1024);
+	DECLARE_BITMAP(bmap2, 1024);
+	u32 exp_arr[32], arr[32];
+	unsigned nbits;
+
+	for (nbits = 0 ; nbits < 257 ; ++nbits) {
+		const unsigned int used_u32s = DIV_ROUND_UP(nbits, 32);
+		unsigned int i, rv;
+
+		bitmap_zero(bmap1, nbits);
+		bitmap_set(bmap1, nbits, 1024 - nbits);  /* garbage */
+
+		memset(arr, 0xff, sizeof(arr));
+		rv = bitmap_to_u32array(arr, used_u32s, bmap1, nbits);
+		expect_eq_uint(nbits, rv);
+
+		memset(exp_arr, 0xff, sizeof(exp_arr));
+		memset(exp_arr, 0, used_u32s*sizeof(*exp_arr));
+		expect_eq_u32_array(exp_arr, 32, arr, 32);
+
+		bitmap_fill(bmap2, 1024);
+		rv = bitmap_from_u32array(bmap2, nbits, arr, used_u32s);
+		expect_eq_uint(nbits, rv);
+		expect_eq_bitmap(bmap1, 1024, bmap2, 1024);
+
+		for (i = 0 ; i < nbits ; ++i) {
+			/*
+			 * test conversion bitmap -> u32[]
+			 */
+
+			bitmap_zero(bmap1, 1024);
+			__set_bit(i, bmap1);
+			bitmap_set(bmap1, nbits, 1024 - nbits);  /* garbage */
+
+			memset(arr, 0xff, sizeof(arr));
+			rv = bitmap_to_u32array(arr, used_u32s, bmap1, nbits);
+			expect_eq_uint(nbits, rv);
+
+			/* 1st used u32 words contain expected bit set, the
+			 * remaining words are left unchanged (0xff)
+			 */
+			memset(exp_arr, 0xff, sizeof(exp_arr));
+			memset(exp_arr, 0, used_u32s*sizeof(*exp_arr));
+			exp_arr[i/32] = (1U<<(i%32));
+			expect_eq_u32_array(exp_arr, 32, arr, 32);
+
+
+			/* same, with longer array to fill
+			 */
+			memset(arr, 0xff, sizeof(arr));
+			rv = bitmap_to_u32array(arr, 32, bmap1, nbits);
+			expect_eq_uint(nbits, rv);
+
+			/* 1st used u32 words contain expected bit set, the
+			 * remaining words are all 0s
+			 */
+			memset(exp_arr, 0, sizeof(exp_arr));
+			exp_arr[i/32] = (1U<<(i%32));
+			expect_eq_u32_array(exp_arr, 32, arr, 32);
+
+			/*
+			 * test conversion u32[] -> bitmap
+			 */
+
+			/* the 1st nbits of bmap2 are identical to
+			 * bmap1, the remaining bits of bmap2 are left
+			 * unchanged (all 1s)
+			 */
+			bitmap_fill(bmap2, 1024);
+			rv = bitmap_from_u32array(bmap2, nbits,
+						  exp_arr, used_u32s);
+			expect_eq_uint(nbits, rv);
+
+			expect_eq_bitmap(bmap1, 1024, bmap2, 1024);
+
+			/* same, with more bits to fill
+			 */
+			memset(arr, 0xff, sizeof(arr));  /* garbage */
+			memset(arr, 0, used_u32s*sizeof(u32));
+			arr[i/32] = (1U<<(i%32));
+
+			bitmap_fill(bmap2, 1024);
+			rv = bitmap_from_u32array(bmap2, 1024, arr, used_u32s);
+			expect_eq_uint(used_u32s*32, rv);
+
+			/* the 1st nbits of bmap2 are identical to
+			 * bmap1, the remaining bits of bmap2 are cleared
+			 */
+			bitmap_zero(bmap1, 1024);
+			__set_bit(i, bmap1);
+			expect_eq_bitmap(bmap1, 1024, bmap2, 1024);
+
+
+			/*
+			 * test short conversion bitmap -> u32[] (1
+			 * word too short)
+			 */
+			if (used_u32s > 1) {
+				bitmap_zero(bmap1, 1024);
+				__set_bit(i, bmap1);
+				bitmap_set(bmap1, nbits,
+					   1024 - nbits);  /* garbage */
+				memset(arr, 0xff, sizeof(arr));
+
+				rv = bitmap_to_u32array(arr, used_u32s - 1,
+							bmap1, nbits);
+				expect_eq_uint((used_u32s - 1)*32, rv);
+
+				/* 1st used u32 words contain expected
+				 * bit set, the remaining words are
+				 * left unchanged (0xff)
+				 */
+				memset(exp_arr, 0xff, sizeof(exp_arr));
+				memset(exp_arr, 0,
+				       (used_u32s-1)*sizeof(*exp_arr));
+				if ((i/32) < (used_u32s - 1))
+					exp_arr[i/32] = (1U<<(i%32));
+				expect_eq_u32_array(exp_arr, 32, arr, 32);
+			}
+
+			/*
+			 * test short conversion u32[] -> bitmap (3
+			 * bits too short)
+			 */
+			if (nbits > 3) {
+				memset(arr, 0xff, sizeof(arr));  /* garbage */
+				memset(arr, 0, used_u32s*sizeof(*arr));
+				arr[i/32] = (1U<<(i%32));
+
+				bitmap_zero(bmap1, 1024);
+				rv = bitmap_from_u32array(bmap1, nbits - 3,
+							  arr, used_u32s);
+				expect_eq_uint(nbits - 3, rv);
+
+				/* we are expecting the bit < nbits -
+				 * 3 (none otherwise), and the rest of
+				 * bmap1 unchanged (0-filled)
+				 */
+				bitmap_zero(bmap2, 1024);
+				if (i < nbits - 3)
+					__set_bit(i, bmap2);
+				expect_eq_bitmap(bmap2, 1024, bmap1, 1024);
+
+				/* do the same with bmap1 initially
+				 * 1-filled
+				 */
+
+				bitmap_fill(bmap1, 1024);
+				rv = bitmap_from_u32array(bmap1, nbits - 3,
+							 arr, used_u32s);
+				expect_eq_uint(nbits - 3, rv);
+
+				/* we are expecting the bit < nbits -
+				 * 3 (none otherwise), and the rest of
+				 * bmap1 unchanged (1-filled)
+				 */
+				bitmap_zero(bmap2, 1024);
+				if (i < nbits - 3)
+					__set_bit(i, bmap2);
+				bitmap_set(bmap2, nbits-3, 1024 - nbits + 3);
+				expect_eq_bitmap(bmap2, 1024, bmap1, 1024);
+			}
+		}
+	}
+}
+
+static int __init test_bitmap_init(void)
+{
+	test_zero_fill_copy();
+	test_bitmap_u32_array_conversions();
+
+	if (failed_tests == 0)
+		pr_info("all %u tests passed\n", total_tests);
+	else
+		pr_warn("failed %u out of %u tests\n",
+			failed_tests, total_tests);
+
+	return failed_tests ? -EINVAL : 0;
+}
+
+static void __exit test_bitmap_cleanup(void)
+{
+}
+
+module_init(test_bitmap_init);
+module_exit(test_bitmap_cleanup);
+
+MODULE_AUTHOR("david decotigny <david.decotigny@googlers.com>");
+MODULE_LICENSE("GPL");
diff --git a/tools/testing/selftests/lib/Makefile b/tools/testing/selftests/lib/Makefile
index 47147b9..0836006 100644
--- a/tools/testing/selftests/lib/Makefile
+++ b/tools/testing/selftests/lib/Makefile
@@ -3,6 +3,6 @@
 # No binaries, but make sure arg-less "make" doesn't trigger "run_tests"
 all:
 
-TEST_PROGS := printf.sh
+TEST_PROGS := printf.sh bitmap.sh
 
 include ../lib.mk
diff --git a/tools/testing/selftests/lib/bitmap.sh b/tools/testing/selftests/lib/bitmap.sh
new file mode 100755
index 0000000..2da187b
--- /dev/null
+++ b/tools/testing/selftests/lib/bitmap.sh
@@ -0,0 +1,10 @@
+#!/bin/sh
+# Runs bitmap infrastructure tests using test_bitmap kernel module
+
+if /sbin/modprobe -q test_bitmap; then
+	/sbin/modprobe -q -r test_bitmap
+	echo "bitmap: ok"
+else
+	echo "bitmap: [FAIL]"
+	exit 1
+fi
-- 
1.8.3.1
