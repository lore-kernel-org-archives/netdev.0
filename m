From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC] reciprocal_divide: correction/update of the algorithm
Date: Mon, 13 Jan 2014 22:42:49 +0100
Message-ID: <20140113214249.GK6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dborkman@redhat.com, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, darkjames-ws@darkjames.pl
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is a RFC and part of a series Daniel Borkmann and me want to
do when introducing prandom_u32_range{,_ro} and prandom_u32_max{,_ro}
helpers later this week.

At first Jakub Zawadzki noticed that some divisions by reciprocal_divide
were not correct:
http://www.wireshark.org/~darkjames/reciprocal-buggy.c

He could also show this with BPF:
http://www.wireshark.org/~darkjames/set-and-dump-filter-k-bug.c

Also: reciprocal_value and reciprocal_divide always return 0 for
divisions by 1.  This is a bit worrisome as those functions also get
used in mm/slab.c and lib/flex_array.c. Bonding already seems to check
for the 1-divisor case and handles that correctly. We don't know about
other problems, yet.

I propose an correction/update of the algorithm
based on the paper "T. Granlund and P. L. Montgomery:
Division by Invariant Integers Using Multiplication"
<http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.1.2556>

The assembler implementation from Agner Fog, found here
<http://www.agner.org/optimize/asmlib.zip>, helped a lot while
implementing.

I would like to have feedback if people see problems with this patch or
have concerns about performance. I did some testing on x86-64 and found
no problems so far but did no performance evaluation, yet.

The current code does break the call-sides of reciprocal_divide. The necessary
changes will be part of the full series, then.

Thanks!
---
 include/linux/reciprocal_div.h | 12 +++++++++---
 lib/reciprocal_div.c           | 22 ++++++++++++++++++----
 2 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/include/linux/reciprocal_div.h b/include/linux/reciprocal_div.h
index f9c90b3..6f17a87 100644
--- a/include/linux/reciprocal_div.h
+++ b/include/linux/reciprocal_div.h
@@ -22,11 +22,17 @@
  * Should not be called before each reciprocal_divide(),
  * or else the performance is slower than a normal divide.
  */
-extern u32 reciprocal_value(u32 B);
 
+struct reciprocal_value {
+	u32 m;
+	u8 sh1, sh2;
+};
 
-static inline u32 reciprocal_divide(u32 A, u32 R)
+struct reciprocal_value reciprocal_value(u32 d);
+
+static inline u32 reciprocal_divide(u32 a, struct reciprocal_value R)
 {
-	return (u32)(((u64)A * R) >> 32);
+	u32 t = (u32)(((u64)a * R.m) >> 32);
+	return (t + ((a - t) >> R.sh1)) >> R.sh2;
 }
 #endif
diff --git a/lib/reciprocal_div.c b/lib/reciprocal_div.c
index 75510e9..b741b30 100644
--- a/lib/reciprocal_div.c
+++ b/lib/reciprocal_div.c
@@ -1,11 +1,25 @@
+#include <linux/kernel.h>
 #include <asm/div64.h>
 #include <linux/reciprocal_div.h>
 #include <linux/export.h>
 
-u32 reciprocal_value(u32 k)
+/* For a description of the algorithmus please look at
+ * linux/reciprocal_div.h
+ */
+
+struct reciprocal_value reciprocal_value(u32 d)
 {
-	u64 val = (1LL << 32) + (k - 1);
-	do_div(val, k);
-	return (u32)val;
+	struct reciprocal_value R;
+	u64 m;
+	int l;
+
+	l = fls(d - 1);
+	m = ((1ULL << 32) * ((1ULL << l) - d));
+	do_div(m, d);
+	++m;
+	R.m = (u32)m;
+	R.sh1 = min(l, 1);
+	R.sh2 = max(l-1, 0);
+	return R;
 }
 EXPORT_SYMBOL(reciprocal_value);
-- 
1.8.4.2
