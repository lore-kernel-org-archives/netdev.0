From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] radix-tree: must check __radix_tree_preload() return
 value
Date: Tue, 05 Sep 2017 11:46:30 -0700
Message-ID: <1504637190.15310.62.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1504634367.15310.59.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <mawilcox@microsoft.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504634367.15310.59.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

__radix_tree_preload() only disables preemption if no error is returned.

So we really need to make sure callers always check the return value.

idr_preload() contract is to always disable preemption, so we need
to add a missing preempt_disable() if an error happened.

Similarly, ida_pre_get() only needs to call preempt_enable() in the
case no error happened.

Fixes: 0a835c4f090a ("Reimplement IDR and IDA using the radix tree")
Fixes: 7ad3d4d85c7a ("ida: Move ida_bitmap to a percpu variable")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: <stable@vger.kernel.org>    [4.11+]
---
v2: addressed Linus feedback, not adding useless/confusing 'ret' variables.

 lib/radix-tree.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 3527eb364964..afb3cb4d44b6 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -463,7 +463,7 @@ radix_tree_node_free(struct radix_tree_node *node)
  * To make use of this facility, the radix tree must be initialised without
  * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
  */
-static int __radix_tree_preload(gfp_t gfp_mask, unsigned nr)
+static __must_check int __radix_tree_preload(gfp_t gfp_mask, unsigned nr)
 {
 	struct radix_tree_preload *rtp;
 	struct radix_tree_node *node;
@@ -2104,7 +2104,8 @@ EXPORT_SYMBOL(radix_tree_tagged);
  */
 void idr_preload(gfp_t gfp_mask)
 {
-	__radix_tree_preload(gfp_mask, IDR_PRELOAD_SIZE);
+	if (__radix_tree_preload(gfp_mask, IDR_PRELOAD_SIZE))
+		preempt_disable();
 }
 EXPORT_SYMBOL(idr_preload);
 
@@ -2118,13 +2119,13 @@ EXPORT_SYMBOL(idr_preload);
  */
 int ida_pre_get(struct ida *ida, gfp_t gfp)
 {
-	__radix_tree_preload(gfp, IDA_PRELOAD_SIZE);
 	/*
 	 * The IDA API has no preload_end() equivalent.  Instead,
 	 * ida_get_new() can return -EAGAIN, prompting the caller
 	 * to return to the ida_pre_get() step.
 	 */
-	preempt_enable();
+	if (!__radix_tree_preload(gfp, IDA_PRELOAD_SIZE))
+		preempt_enable();
 
 	if (!this_cpu_read(ida_bitmap)) {
 		struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);
