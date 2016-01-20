From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v6 02/19] test_bitmap: unit tests for lib/bitmap.c
Date: Tue, 19 Jan 2016 16:43:47 -0800
Message-ID: <1453250644-14796-3-git-send-email-ddecotig@gmail.com>
References: <1453250644-14796-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Eugenia Emantayev <eugenia@mellanox.co.il>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>,
        Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Ed Swierk <eswierk@skyportsystems.com>,
        Robert Love <robert.w.love@intel.com>,
        "James E.J. Bottomley" <JBottomley@parallels.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-api@vger.kernel.org, linux-mips@linux-mips.org,
        fcoe-devel@open-fcoe.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1453250644-14796-1-git-send-email-ddecotig@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

This is mainly testing bitmap construction and conversion to/from u32[]
for now.

Tested:
  qemu i386, x86_64, ppc, ppc64 BE and LE, ARM.

Signed-off-by: David Decotigny <decot@googlers.com>
---
 lib/Kconfig.debug                     |   8 +
 lib/Makefile                          |   1 +
 lib/test_bitmap.c                     | 343 ++++++++++++++++++++++++++++++++++
 tools/testing/selftests/lib/Makefile  |   2 +-
 tools/testing/selftests/lib/bitmap.sh |  10 +
 5 files changed, 363 insertions(+), 1 deletion(-)
 create mode 100644 lib/test_bitmap.c
 create mode 100644 tools/testing/selftests/lib/bitmap.sh

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index ee1ac1c..9c6c564 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1731,6 +1731,14 @@ config TEST_KSTRTOX
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
index 180dd4d..ba6b7fe 100644
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
index 0000000..33e572a
--- /dev/null
+++ b/lib/test_bitmap.c
@@ -0,0 +1,343 @@
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
+__check_eq_bitmap(const unsigned long *exp_bmap, unsigned int exp_nbits,
+		  const unsigned long *bmap, unsigned int nbits)
+{
+	if (exp_nbits != nbits) {
+		pr_warn("bitmap length mismatch: expected %u, got %u\n",
+			exp_nbits, nbits);
+		return false;
+	}
+
+	if (!bitmap_equal(exp_bmap, bmap, nbits)) {
+		pr_warn("bitmaps contents differ: expected \"%*pbl\", got \"%*pbl\"\n",
+			exp_nbits, exp_bmap, nbits, bmap);
+		return false;
+	}
+	return true;
+}
+
+static int __init
+expect_eq_bitmap(const unsigned long *exp_bmap, unsigned int exp_nbits,
+	       const unsigned long *bmap, unsigned int nbits)
+{
+	total_tests++;
+	if (!__check_eq_bitmap(exp_bmap, exp_nbits, bmap, nbits)) {
+		failed_tests++;
+		return 1;
+	}
+	return 0;
+}
+
+static bool __init
+__check_eq_pbl(const char *expected_pbl,
+	       const unsigned long *bitmap, unsigned int nbits)
+{
+	snprintf(pbl_buffer, sizeof(pbl_buffer), "%*pbl", nbits, bitmap);
+	if (strcmp(expected_pbl, pbl_buffer)) {
+		pr_warn("expected \"%s\", got \"%s\"\n",
+			expected_pbl, pbl_buffer);
+		return false;
+	}
+	return true;
+}
+
+static int __init
+expect_eq_pbl(const char *expected_pbl,
+	    const unsigned long *bitmap, unsigned int nbits)
+{
+	total_tests++;
+	if (!__check_eq_pbl(expected_pbl, bitmap, nbits)) {
+		failed_tests++;
+		return 1;
+	}
+	return 0;
+}
+
+static bool __init
+__check_eq_u32_array(const u32 *exp_arr, unsigned int exp_len,
+		     const u32 *arr, unsigned int len)
+{
+	if (exp_len != len) {
+		pr_warn("array length differ: expected %u, got %u\n",
+			exp_len, len);
+		return false;
+	}
+
+	if (memcmp(exp_arr, arr, len*sizeof(*arr))) {
+		pr_warn("array contents differ\n");
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
+static int __init
+expect_eq_u32_array(const u32 *exp_arr, unsigned int exp_len,
+		  const u32 *arr, unsigned int len)
+{
+	total_tests++;
+	if (!__check_eq_u32_array(exp_arr, exp_len, arr, len)) {
+		failed_tests++;
+		return 1;
+	}
+	return 0;
+}
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
+		unsigned int i;
+
+		bitmap_zero(bmap1, nbits);
+		bitmap_set(bmap1, nbits, 1024 - nbits);  /* garbage */
+
+		memset(arr, 0xff, sizeof(arr));
+		bitmap_to_u32array(arr, used_u32s, bmap1, nbits);
+
+		memset(exp_arr, 0xff, sizeof(exp_arr));
+		memset(exp_arr, 0, used_u32s*sizeof(*exp_arr));
+		expect_eq_u32_array(exp_arr, 32, arr, 32);
+
+		bitmap_fill(bmap2, 1024);
+		bitmap_from_u32array(bmap2, nbits, arr, used_u32s);
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
+			bitmap_to_u32array(arr, used_u32s, bmap1, nbits);
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
+			bitmap_to_u32array(arr, 32, bmap1, nbits);
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
+			bitmap_from_u32array(bmap2, nbits, exp_arr, used_u32s);
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
+			bitmap_from_u32array(bmap2, 1024, arr, used_u32s);
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
+				bitmap_to_u32array(arr, used_u32s - 1,
+						   bmap1, nbits);
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
+				bitmap_from_u32array(bmap1, nbits - 3,
+						     arr, used_u32s);
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
+				bitmap_from_u32array(bmap1, nbits - 3,
+						     arr, used_u32s);
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
+module_init(test_bitmap_init);
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
new file mode 100644
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
2.7.0.rc3.207.g0ac5344
