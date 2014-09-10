From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2] net: bpf: only build bpf_jit_binary_{alloc,free}() when jit selected
Date: Wed, 10 Sep 2014 15:01:02 +0200
Message-ID: <1410354062-25337-1-git-send-email-dborkman@redhat.com>
Cc: fengguang.wu@intel.com, ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbaIJNBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 09:01:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since BPF JIT depends on the availability of module_alloc() and
module_free() helpers (HAVE_BPF_JIT and MODULES), we better build
that code only in case we have BPF_JIT in our config enabled, just
like with other JIT code. Fixes builds for arm/marzen_defconfig
and sh/rsk7269_defconfig.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Fixes: 738cbe72adc5 ("net: bpf: consolidate JIT binary allocator")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v1->v2:
  - Sorry, we can reduce it further and remove the else part of
    the code as bpf_jit_binary_{alloc,free} helpers are only used
    from within JIT code anyway, of course.

 include/linux/filter.h | 78 +++++++++++++++++++++++++-------------------------
 kernel/bpf/core.c      |  2 ++
 2 files changed, 41 insertions(+), 39 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 4b59ede..1a0bc6d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -4,12 +4,18 @@
 #ifndef __LINUX_FILTER_H__
 #define __LINUX_FILTER_H__
 
+#include <stdarg.h>
+
 #include <linux/atomic.h>
 #include <linux/compat.h>
 #include <linux/skbuff.h>
+#include <linux/linkage.h>
+#include <linux/printk.h>
 #include <linux/workqueue.h>
-#include <uapi/linux/filter.h>
+
 #include <asm/cacheflush.h>
+
+#include <uapi/linux/filter.h>
 #include <uapi/linux/bpf.h>
 
 struct sk_buff;
@@ -363,14 +369,6 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 				  gfp_t gfp_extra_flags);
 void __bpf_prog_free(struct bpf_prog *fp);
 
-typedef void (*bpf_jit_fill_hole_t)(void *area, unsigned int size);
-
-struct bpf_binary_header *
-bpf_jit_binary_alloc(unsigned int proglen, u8 **image_ptr,
-		     unsigned int alignment,
-		     bpf_jit_fill_hole_t bpf_fill_ill_insns);
-void bpf_jit_binary_free(struct bpf_binary_header *hdr);
-
 static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 {
 	bpf_prog_unlock_ro(fp);
@@ -393,6 +391,38 @@ void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 void bpf_int_jit_compile(struct bpf_prog *fp);
 
+#ifdef CONFIG_BPF_JIT
+typedef void (*bpf_jit_fill_hole_t)(void *area, unsigned int size);
+
+struct bpf_binary_header *
+bpf_jit_binary_alloc(unsigned int proglen, u8 **image_ptr,
+		     unsigned int alignment,
+		     bpf_jit_fill_hole_t bpf_fill_ill_insns);
+void bpf_jit_binary_free(struct bpf_binary_header *hdr);
+
+void bpf_jit_compile(struct bpf_prog *fp);
+void bpf_jit_free(struct bpf_prog *fp);
+
+static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
+				u32 pass, void *image)
+{
+	pr_err("flen=%u proglen=%u pass=%u image=%pK\n",
+	       flen, proglen, pass, image);
+	if (image)
+		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
+			       16, 1, image, proglen, false);
+}
+#else
+static inline void bpf_jit_compile(struct bpf_prog *fp)
+{
+}
+
+static inline void bpf_jit_free(struct bpf_prog *fp)
+{
+	bpf_prog_unlock_free(fp);
+}
+#endif /* CONFIG_BPF_JIT */
+
 #define BPF_ANC		BIT(15)
 
 static inline u16 bpf_anc_helper(const struct sock_filter *ftest)
@@ -440,36 +470,6 @@ static inline void *bpf_load_pointer(const struct sk_buff *skb, int k,
 	return bpf_internal_load_pointer_neg_helper(skb, k, size);
 }
 
-#ifdef CONFIG_BPF_JIT
-#include <stdarg.h>
-#include <linux/linkage.h>
-#include <linux/printk.h>
-
-void bpf_jit_compile(struct bpf_prog *fp);
-void bpf_jit_free(struct bpf_prog *fp);
-
-static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
-				u32 pass, void *image)
-{
-	pr_err("flen=%u proglen=%u pass=%u image=%pK\n",
-	       flen, proglen, pass, image);
-	if (image)
-		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
-			       16, 1, image, proglen, false);
-}
-#else
-#include <linux/slab.h>
-
-static inline void bpf_jit_compile(struct bpf_prog *fp)
-{
-}
-
-static inline void bpf_jit_free(struct bpf_prog *fp)
-{
-	bpf_prog_unlock_free(fp);
-}
-#endif /* CONFIG_BPF_JIT */
-
 static inline int bpf_tell_extensions(void)
 {
 	return SKF_AD_MAX;
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 8ee520f..8b70024 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -128,6 +128,7 @@ void __bpf_prog_free(struct bpf_prog *fp)
 }
 EXPORT_SYMBOL_GPL(__bpf_prog_free);
 
+#ifdef CONFIG_BPF_JIT
 struct bpf_binary_header *
 bpf_jit_binary_alloc(unsigned int proglen, u8 **image_ptr,
 		     unsigned int alignment,
@@ -163,6 +164,7 @@ void bpf_jit_binary_free(struct bpf_binary_header *hdr)
 {
 	module_free(NULL, hdr);
 }
+#endif /* CONFIG_BPF_JIT */
 
 /* Base function for offset calculation. Needs to go into .text section,
  * therefore keeping it non-static as well; will also be used by JITs
-- 
1.7.11.7
