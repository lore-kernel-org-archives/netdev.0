From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 16/30] mm, ixgbe: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:33 +0800
Message-ID: <1405064267-11678-17-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>,
	Tony Luck <tony.luck@intel.com>,
	linux-mm@kvack.org,
	linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	David Rientjes <rientjes@google.com>,
	Mike Galbraith <umgwanakikbuti@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f5aa3311ea28..46dc083573ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1962,7 +1962,7 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
 		/* we can reuse buffer as-is, just make sure it is local */
-		if (likely(page_to_nid(page) == numa_node_id()))
+		if (likely(page_to_nid(page) == numa_mem_id()))
 			return true;
 
 		/* this page cannot be reused so discard it */
@@ -1974,7 +1974,7 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 			rx_buffer->page_offset, size, truesize);
 
 	/* avoid re-using remote pages */
-	if (unlikely(page_to_nid(page) != numa_node_id()))
+	if (unlikely(page_to_nid(page) != numa_mem_id()))
 		return false;
 
 #if (PAGE_SIZE < 8192)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
