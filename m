From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 02/26] rewrite READ_ONCE/WRITE_ONCE
Date: Thu,  2 Mar 2017 17:38:10 +0100
Message-ID: <20170302163834.2273519-3-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>
To: kasan-dev@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:64263 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753349AbdCBQsW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 11:48:22 -0500
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_KASAN is enabled, the READ_ONCE/WRITE_ONCE macros cause
rather large kernel stacks, e.g.:

mm/vmscan.c: In function 'shrink_page_list':
mm/vmscan.c:1333:1: error: the frame size of 3456 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
block/cfq-iosched.c: In function 'cfqg_stats_add_aux':
block/cfq-iosched.c:750:1: error: the frame size of 4048 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
fs/btrfs/disk-io.c: In function 'open_ctree':
fs/btrfs/disk-io.c:3314:1: error: the frame size of 3136 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
fs/btrfs/relocation.c: In function 'build_backref_tree':
fs/btrfs/relocation.c:1193:1: error: the frame size of 4336 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
fs/fscache/stats.c: In function 'fscache_stats_show':
fs/fscache/stats.c:287:1: error: the frame size of 6512 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
fs/jbd2/commit.c: In function 'jbd2_journal_commit_transaction':
fs/jbd2/commit.c:1139:1: error: the frame size of 3760 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]

This attempts a rewrite of the two macros, using a simpler implementation
for the most common case of having a naturally aligned 1, 2, 4, or (on
64-bit architectures) 8  byte object that can be accessed with a single
instruction.  For these, we go back to a volatile pointer dereference
that we had with the ACCESS_ONCE macro.

READ_ONCE/WRITE_ONCE also try to handle unaligned objects and objects
of other sizes by forcing either a word-size access (which may trap
on some architectures) or doing a non-atomic memcpy. I could not figure
out what these are actually used for, but they appear to be done
intentionally, so I'm leaving that code untouched.

I had to fix up a couple of files that either use WRITE_ONCE() as an
implicit typecast, or ignore the result of READ_ONCE(). In all cases,
the modified code seems no worse to me than the original.

Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/x86/include/asm/switch_to.h |  2 +-
 fs/overlayfs/util.c              |  6 ++---
 include/linux/compiler.h         | 47 ++++++++++++++++++++++++++++++++--------
 3 files changed, 42 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/switch_to.h b/arch/x86/include/asm/switch_to.h
index fcc5cd387fd1..0c243dd569fe 100644
--- a/arch/x86/include/asm/switch_to.h
+++ b/arch/x86/include/asm/switch_to.h
@@ -30,7 +30,7 @@ static inline void prepare_switch_to(struct task_struct *prev,
 	 *
 	 * To minimize cache pollution, just follow the stack pointer.
 	 */
-	READ_ONCE(*(unsigned char *)next->thread.sp);
+	(void)READ_ONCE(*(unsigned char *)next->thread.sp);
 #endif
 }
 
diff --git a/fs/overlayfs/util.c b/fs/overlayfs/util.c
index 952286f4826c..1c10632a48bb 100644
--- a/fs/overlayfs/util.c
+++ b/fs/overlayfs/util.c
@@ -222,8 +222,8 @@ void ovl_dentry_update(struct dentry *dentry, struct dentry *upperdentry)
 
 void ovl_inode_init(struct inode *inode, struct inode *realinode, bool is_upper)
 {
-	WRITE_ONCE(inode->i_private, (unsigned long) realinode |
-		   (is_upper ? OVL_ISUPPER_MASK : 0));
+	WRITE_ONCE(inode->i_private, (void *)((unsigned long) realinode |
+		   (is_upper ? OVL_ISUPPER_MASK : 0)));
 }
 
 void ovl_inode_update(struct inode *inode, struct inode *upperinode)
@@ -231,7 +231,7 @@ void ovl_inode_update(struct inode *inode, struct inode *upperinode)
 	WARN_ON(!upperinode);
 	WARN_ON(!inode_unhashed(inode));
 	WRITE_ONCE(inode->i_private,
-		   (unsigned long) upperinode | OVL_ISUPPER_MASK);
+		   (void *)((unsigned long) upperinode | OVL_ISUPPER_MASK));
 	if (!S_ISDIR(upperinode->i_mode))
 		__insert_inode_hash(inode, (unsigned long) upperinode);
 }
diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index 56b90897a459..b619f5853af8 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -288,6 +288,10 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
 	}
 }
 
+#define __ALIGNED_WORD(x)						\
+	((sizeof(x) == 1 || sizeof(x) == 2 || sizeof(x) == 4 ||		\
+	  sizeof(x) == sizeof(long)) && (sizeof(x) == __alignof__(x)))	\
+
 /*
  * Prevent the compiler from merging or refetching reads or writes. The
  * compiler is also forbidden from reordering successive instances of
@@ -309,8 +313,13 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
  * mutilate accesses that either do not require ordering or that interact
  * with an explicit memory barrier or atomic instruction that provides the
  * required ordering.
+ *
+ * Unaligned data is particularly tricky here: if the type that gets
+ * passed in is not naturally aligned, we cast to a type of higher
+ * alignment, which is not well-defined in C. This is fine as long
+ * as the actual data is aligned, but otherwise might require a trap
+ * to satisfy the load.
  */
-
 #define __READ_ONCE(x, check)						\
 ({									\
 	union { typeof(x) __val; char __c[1]; } __u;			\
@@ -320,7 +329,32 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
 		__read_once_size_nocheck(&(x), __u.__c, sizeof(x));	\
 	__u.__val;							\
 })
-#define READ_ONCE(x) __READ_ONCE(x, 1)
+
+#define __WRITE_ONCE(x, val)						\
+({									\
+	union { typeof(x) __val; char __c[1]; } __u =			\
+		{ .__val = (__force typeof(x)) (val) };			\
+	__write_once_size(&(x), __u.__c, sizeof(x));			\
+	__u.__val;							\
+})
+
+
+/*
+ * the common case is simple: x is naturally aligned, not an array,
+ * and accessible with a single load, avoiding the need for local
+ * variables. With KASAN, this is important as any call to
+ *__write_once_size(),__read_once_size_nocheck() or __read_once_size()
+ * uses significant amounts of stack space for checking that we don't
+ * overflow the union.
+ */
+#define __READ_ONCE_SIMPLE(x)						\
+	(typeof(x))(*(volatile typeof(&(x)))&(x))
+
+#define __WRITE_ONCE_SIMPLE(x, val)					\
+	({*(volatile typeof(&(x)))&(x) = (val); })
+
+#define READ_ONCE(x) __builtin_choose_expr(__ALIGNED_WORD(x), 		\
+	__READ_ONCE_SIMPLE(x), __READ_ONCE(x, 1))
 
 /*
  * Use READ_ONCE_NOCHECK() instead of READ_ONCE() if you need
@@ -328,13 +362,8 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
  */
 #define READ_ONCE_NOCHECK(x) __READ_ONCE(x, 0)
 
-#define WRITE_ONCE(x, val) \
-({							\
-	union { typeof(x) __val; char __c[1]; } __u =	\
-		{ .__val = (__force typeof(x)) (val) }; \
-	__write_once_size(&(x), __u.__c, sizeof(x));	\
-	__u.__val;					\
-})
+#define WRITE_ONCE(x, val) do { __builtin_choose_expr(__ALIGNED_WORD(x), \
+	__WRITE_ONCE_SIMPLE(x, val), __WRITE_ONCE(x, val)); } while (0)
 
 #endif /* __KERNEL__ */
 
-- 
2.9.0
