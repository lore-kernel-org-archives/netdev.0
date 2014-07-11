From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 04/30] mm, netfilter: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:21 +0800
Message-ID: <1405064267-11678-5-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>,
	Tony Luck <tony.luck@intel.com>,
	linux-mm@kvack.org,
	linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	David Rientjes <rientjes@google.com>,
	Mike Galbraith <umgwanakikbuti@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
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
 net/netfilter/x_tables.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 227aa11e8409..6e7d4bc81422 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -692,10 +692,10 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
 		if (size <= PAGE_SIZE)
 			newinfo->entries[cpu] = kmalloc_node(size,
 							GFP_KERNEL,
-							cpu_to_node(cpu));
+							cpu_to_mem(cpu));
 		else
 			newinfo->entries[cpu] = vmalloc_node(size,
-							cpu_to_node(cpu));
+							cpu_to_mem(cpu));
 
 		if (newinfo->entries[cpu] == NULL) {
 			xt_free_table_info(newinfo);
@@ -801,10 +801,10 @@ static int xt_jumpstack_alloc(struct xt_table_info *i)
 	for_each_possible_cpu(cpu) {
 		if (size > PAGE_SIZE)
 			i->jumpstack[cpu] = vmalloc_node(size,
-				cpu_to_node(cpu));
+				cpu_to_mem(cpu));
 		else
 			i->jumpstack[cpu] = kmalloc_node(size,
-				GFP_KERNEL, cpu_to_node(cpu));
+				GFP_KERNEL, cpu_to_mem(cpu));
 		if (i->jumpstack[cpu] == NULL)
 			/*
 			 * Freeing will be done later on by the callers. The
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
