From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 1/6] spinlock: Add library function to allocate spinlock buckets array
Date: Fri, 9 Sep 2016 16:19:52 -0700
Message-ID: <1473463197-3076903-2-git-send-email-tom@herbertland.com>
References: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56311 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755105AbcIIXUR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:20:17 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u89NK2Eo016495
        for <netdev@vger.kernel.org>; Fri, 9 Sep 2016 16:20:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25c3j88tsd-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 16:20:17 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 f72c3bb876e311e6970d0002c991e86a-75be6a50 for <netdev@vger.kernel.org>;        Fri,
 09 Sep 2016 16:20:16 -0700
In-Reply-To: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two new library functions alloc_bucket_spinlocks and
free_bucket_spinlocks. These are use to allocate and free an array
of spinlocks that are useful as locks for hash buckets. The interface
specifies the maximum number of spinlocks in the array as well
as a CPU multiplier to derive the number of spinlocks to allocate.
The number to allocated is rounded up to a power of two to make
the array amenable to hash lookup.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/spinlock.h |  6 +++++
 lib/Makefile             |  2 +-
 lib/bucket_locks.c       | 63 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 70 insertions(+), 1 deletion(-)
 create mode 100644 lib/bucket_locks.c

diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
index 47dd0ce..4ebdfbf 100644
--- a/include/linux/spinlock.h
+++ b/include/linux/spinlock.h
@@ -416,4 +416,10 @@ extern int _atomic_dec_and_lock(atomic_t *atomic, spinlock_t *lock);
 #define atomic_dec_and_lock(atomic, lock) \
 		__cond_lock(lock, _atomic_dec_and_lock(atomic, lock))
 
+int alloc_bucket_spinlocks(spinlock_t **locks, unsigned int *lock_mask,
+			   unsigned int max_size, unsigned int cpu_mult,
+			   gfp_t gfp);
+
+void free_bucket_spinlocks(spinlock_t *locks);
+
 #endif /* __LINUX_SPINLOCK_H */
diff --git a/lib/Makefile b/lib/Makefile
index cfa68eb..a1dedf1 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -37,7 +37,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iov_iter.o clz_ctz.o \
 	 bsearch.o find_bit.o llist.o memweight.o kfifo.o \
 	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o \
-	 once.o
+	 once.o bucket_locks.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += hexdump.o
diff --git a/lib/bucket_locks.c b/lib/bucket_locks.c
new file mode 100644
index 0000000..bb9bf11
--- /dev/null
+++ b/lib/bucket_locks.c
@@ -0,0 +1,63 @@
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/mm.h>
+#include <linux/export.h>
+
+/* Allocate an array of spinlocks to be accessed by a hash. Two arguments
+ * indicate the number of elements to allocate in the array. max_size
+ * gives the maximum number of elements to allocate. cpu_mult gives
+ * the number of locks per CPU to allocate. The size is rounded up
+ * to a power of 2 to be suitable as a hash table.
+ */
+int alloc_bucket_spinlocks(spinlock_t **locks, unsigned int *locks_mask,
+			   unsigned int max_size, unsigned int cpu_mult,
+			   gfp_t gfp)
+{
+	unsigned int i, size;
+#if defined(CONFIG_PROVE_LOCKING)
+	unsigned int nr_pcpus = 2;
+#else
+	unsigned int nr_pcpus = num_possible_cpus();
+#endif
+	spinlock_t *tlocks = NULL;
+
+	if (cpu_mult) {
+		nr_pcpus = min_t(unsigned int, nr_pcpus, 64UL);
+		size = min_t(unsigned int, nr_pcpus * cpu_mult, max_size);
+	} else {
+		size = max_size;
+	}
+	size = roundup_pow_of_two(size);
+
+	if (!size)
+		return -EINVAL;
+
+	if (sizeof(spinlock_t) != 0) {
+#ifdef CONFIG_NUMA
+		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
+		    gfp == GFP_KERNEL)
+			tlocks = vmalloc(size * sizeof(spinlock_t));
+#endif
+		if (gfp != GFP_KERNEL)
+			gfp |= __GFP_NOWARN | __GFP_NORETRY;
+
+		if (!tlocks)
+			tlocks = kmalloc_array(size, sizeof(spinlock_t), gfp);
+		if (!tlocks)
+			return -ENOMEM;
+		for (i = 0; i < size; i++)
+			spin_lock_init(&tlocks[i]);
+	}
+	*locks = tlocks;
+	*locks_mask = size - 1;
+
+	return 0;
+}
+EXPORT_SYMBOL(alloc_bucket_spinlocks);
+
+void free_bucket_spinlocks(spinlock_t *locks)
+{
+	kvfree(locks);
+}
+EXPORT_SYMBOL(free_bucket_spinlocks);
-- 
2.8.0.rc2
