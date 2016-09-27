From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3] fs/select: add vmalloc fallback for select(2)
Date: Tue, 27 Sep 2016 10:45:36 +0200
Message-ID: <20160927084536.5923-1-vbabka@suse.cz>
References: <20160922164359.9035-1-vbabka@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>,
        netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>,
        Hillf Danton <hillf.zj@alibaba-inc.com>,
        Nicholas Piggin <npiggin@gmail.com>,
        Jason Baron <jbaron@akamai.com>,
        Vlastimil Babka <vbabka@suse.cz>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922164359.9035-1-vbabka@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
with the number of fds passed. We had a customer report page allocation
failures of order-4 for this allocation. This is a costly order, so it might
easily fail, as the VM expects such allocation to have a lower-order fallback.

Such trivial fallback is vmalloc(), as the memory doesn't have to be physically
contiguous and the allocation is temporary for the duration of the syscall
only. There were some concerns, whether this would have negative impact on the
system by exposing vmalloc() to userspace. Although an excessive use of vmalloc
can cause some system wide performance issues - TLB flushes etc. - a large
order allocation is not for free either and an excessive reclaim/compaction can
have a similar effect. Also note that the size is effectively limited by
RLIMIT_NOFILE which defaults to 1024 on the systems I checked. That means the
bitmaps will fit well within single page and thus the vmalloc() fallback could
be only excercised for processes where root allows a higher limit.

Note that the poll(2) syscall seems to use a linked list of order-0 pages, so
it doesn't need this kind of fallback.

[eric.dumazet@gmail.com: fix failure path logic]
[akpm@linux-foundation.org: use proper type for size]
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/select.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 8ed9da50896a..3d4f85defeab 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -29,6 +29,7 @@
 #include <linux/sched/rt.h>
 #include <linux/freezer.h>
 #include <net/busy_poll.h>
+#include <linux/vmalloc.h>
 
 #include <asm/uaccess.h>
 
@@ -554,7 +555,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 	fd_set_bits fds;
 	void *bits;
 	int ret, max_fds;
-	unsigned int size;
+	size_t size, alloc_size;
 	struct fdtable *fdt;
 	/* Allocate small arguments on the stack to save memory and be faster */
 	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
@@ -581,7 +582,14 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 	if (size > sizeof(stack_fds) / 6) {
 		/* Not enough space in on-stack array; must use kmalloc */
 		ret = -ENOMEM;
-		bits = kmalloc(6 * size, GFP_KERNEL);
+		if (size > (SIZE_MAX / 6))
+			goto out_nofds;
+
+		alloc_size = 6 * size;
+		bits = kmalloc(alloc_size, GFP_KERNEL|__GFP_NOWARN);
+		if (!bits && alloc_size > PAGE_SIZE)
+			bits = vmalloc(alloc_size);
+
 		if (!bits)
 			goto out_nofds;
 	}
@@ -618,7 +626,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 
 out:
 	if (bits != stack_fds)
-		kfree(bits);
+		kvfree(bits);
 out_nofds:
 	return ret;
 }
-- 
2.10.0
