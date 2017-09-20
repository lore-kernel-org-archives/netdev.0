From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 25/31] fork: Define usercopy region in thread_stack slab caches
Date: Wed, 20 Sep 2017 13:45:31 -0700
Message-ID: <1505940337-79069-26-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        David Windsor <dave@nullcore.net>,
        Ingo Molnar <mingo@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andy Lutomirski <luto@kernel.org>,
        linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
        linux-mm@kvack.org, kernel-hardening@lists.openwall.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Windsor <dave@nullcore.net>

In support of usercopy hardening, this patch defines a region in the
thread_stack slab caches in which userspace copy operations are allowed.
Since the entire thread_stack needs to be available to userspace, the
entire slab contents are whitelisted. Note that the slab-based thread
stack is only present on systems with THREAD_SIZE < PAGE_SIZE and
!CONFIG_VMAP_STACK.

cache object allocation:
    kernel/fork.c:
        alloc_thread_stack_node(...):
            return kmem_cache_alloc_node(thread_stack_cache, ...)

        dup_task_struct(...):
            ...
            stack = alloc_thread_stack_node(...)
            ...
            tsk->stack = stack;

        copy_process(...):
            ...
            dup_task_struct(...)

        _do_fork(...):
            ...
            copy_process(...)

This region is known as the slab cache's usercopy region. Slab caches
can now check that each copy operation involving cache-managed memory
falls entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, split patch, provide usage trace]
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Rik van Riel <riel@redhat.com>
---
I wasn't able to test this, so anyone with a system that can try running
with a large PAGE_SIZE and without VMAP_STACK would be appreciated.
---
 kernel/fork.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index dc1437f8b702..720109dc723a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -278,8 +278,9 @@ static void free_thread_stack(struct task_struct *tsk)
 
 void thread_stack_cache_init(void)
 {
-	thread_stack_cache = kmem_cache_create("thread_stack", THREAD_SIZE,
-					      THREAD_SIZE, 0, NULL);
+	thread_stack_cache = kmem_cache_create_usercopy("thread_stack",
+					THREAD_SIZE, THREAD_SIZE, 0, 0,
+					THREAD_SIZE, NULL);
 	BUG_ON(thread_stack_cache == NULL);
 }
 # endif
-- 
2.7.4
