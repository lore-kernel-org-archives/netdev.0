From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/3] mm, percpu: add support for __GFP_NOWARN flag
Date: Tue, 17 Oct 2017 16:55:52 +0200
Message-ID: <beeeab23cda20c0b0ee3e4ccb30b91518de6c075.1508251210.git.daniel@iogearbox.net>
References: <cover.1508251210.git.daniel@iogearbox.net>
Cc: tj@kernel.org, ast@kernel.org, john.fastabend@gmail.com,
        mark.rutland@arm.com, richard@nod.at, sp3485@columbia.edu,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1508251210.git.daniel@iogearbox.net>
In-Reply-To: <cover.1508251210.git.daniel@iogearbox.net>
References: <cover.1508251210.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an option for pcpu_alloc() to support __GFP_NOWARN flag.
Currently, we always throw a warning when size or alignment
is unsupported (and also dump stack on failed allocation
requests). The warning itself is harmless since we return
NULL anyway for any failed request, which callers are
required to handle anyway. However, it becomes harmful when
panic_on_warn is set.

The rationale for the WARN() in pcpu_alloc() is that it can
be tracked when larger than supported allocation requests are
made such that allocations limits can be tweaked if warranted.
This makes sense for in-kernel users, however, there are users
of pcpu allocator where allocation size is derived from user
space requests, e.g. when creating BPF maps. In these cases,
the requests should fail gracefully without throwing a splat.

The current work-around was to check allocation size against
the upper limit of PCPU_MIN_UNIT_SIZE from call-sites for
bailing out prior to a call to pcpu_alloc() in order to
avoid throwing the WARN(). This is bad in multiple ways since
PCPU_MIN_UNIT_SIZE is an implementation detail, and having
the checks on call-sites only complicates the code for no
good reason. Thus, lets fix it generically by supporting the
__GFP_NOWARN flag that users can then use with calling the
__alloc_percpu_gfp() helper instead.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Tejun Heo <tj@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>
---
 mm/percpu.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index aa121ce..a0e0c82 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1329,7 +1329,9 @@ static struct pcpu_chunk *pcpu_chunk_addr_search(void *addr)
  * @gfp: allocation flags
  *
  * Allocate percpu area of @size bytes aligned at @align.  If @gfp doesn't
- * contain %GFP_KERNEL, the allocation is atomic.
+ * contain %GFP_KERNEL, the allocation is atomic. If @gfp has __GFP_NOWARN
+ * then no warning will be triggered on invalid or failed allocation
+ * requests.
  *
  * RETURNS:
  * Percpu pointer to the allocated area on success, NULL on failure.
@@ -1337,10 +1339,11 @@ static struct pcpu_chunk *pcpu_chunk_addr_search(void *addr)
 static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 				 gfp_t gfp)
 {
+	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
+	bool do_warn = !(gfp & __GFP_NOWARN);
 	static int warn_limit = 10;
 	struct pcpu_chunk *chunk;
 	const char *err;
-	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
 	int slot, off, cpu, ret;
 	unsigned long flags;
 	void __percpu *ptr;
@@ -1361,7 +1364,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE ||
 		     !is_power_of_2(align))) {
-		WARN(true, "illegal size (%zu) or align (%zu) for percpu allocation\n",
+		WARN(do_warn, "illegal size (%zu) or align (%zu) for percpu allocation\n",
 		     size, align);
 		return NULL;
 	}
@@ -1482,7 +1485,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 fail:
 	trace_percpu_alloc_percpu_fail(reserved, is_atomic, size, align);
 
-	if (!is_atomic && warn_limit) {
+	if (!is_atomic && do_warn && warn_limit) {
 		pr_warn("allocation failed, size=%zu align=%zu atomic=%d, %s\n",
 			size, align, is_atomic, err);
 		dump_stack();
@@ -1507,7 +1510,9 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
  *
  * Allocate zero-filled percpu area of @size bytes aligned at @align.  If
  * @gfp doesn't contain %GFP_KERNEL, the allocation doesn't block and can
- * be called from any context but is a lot more likely to fail.
+ * be called from any context but is a lot more likely to fail. If @gfp
+ * has __GFP_NOWARN then no warning will be triggered on invalid or failed
+ * allocation requests.
  *
  * RETURNS:
  * Percpu pointer to the allocated area on success, NULL on failure.
-- 
1.9.3
