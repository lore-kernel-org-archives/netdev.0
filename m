From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH 2/2] ixgbe,
	don't assume mapping of numa node cpus
Date: Mon, 24 Feb 2014 13:51:53 -0500
Message-ID: <1393267913-28212-3-git-send-email-prarit@redhat.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Prarit Bhargava <prarit@redhat.com>, nhorman@redhat.com,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	agospoda@redhat.com, John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1393267913-28212-1-git-send-email-prarit@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The ixgbe driver assumes that the cpus on a node are mapped 1:1 with the
indexes into arrays.  This is not the case as nodes can contain, for
example, cpus 0-7, 33-40.

This patch fixes this problem.

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Cc: Alex Duyck <alexander.h.duyck@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: nhorman@redhat.com
Cc: agospoda@redhat.com
Cc: e1000-devel@lists.sourceforge.net
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 3668288..8b3992e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -794,11 +794,15 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 {
 	struct ixgbe_q_vector *q_vector;
 	struct ixgbe_ring *ring;
-	int node = NUMA_NO_NODE;
-	int cpu = -1;
+	int node = adapter->pdev->dev.numa_node;
+	int cpu, set_affinity = 0;
 	int ring_count, size;
 	u8 tcs = netdev_get_num_tc(adapter->netdev);
 
+	if (node == NUMA_NO_NODE)
+		cpu = -1;
+	else
+		cpu = cpumask_next(v_idx - 1, cpumask_of_node(node));
 	ring_count = txr_count + rxr_count;
 	size = sizeof(struct ixgbe_q_vector) +
 	       (sizeof(struct ixgbe_ring) * ring_count);
@@ -807,10 +811,8 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 	if ((tcs <= 1) && !(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)) {
 		u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
 		if (rss_i > 1 && adapter->atr_sample_rate) {
-			if (cpu_online(v_idx)) {
-				cpu = v_idx;
-				node = cpu_to_node(cpu);
-			}
+			if (likely(cpu_online(cpu)))
+				set_affinity = 1;
 		}
 	}
 
@@ -822,7 +824,7 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 		return -ENOMEM;
 
 	/* setup affinity mask and node */
-	if (cpu != -1)
+	if (set_affinity)
 		cpumask_set_cpu(cpu, &q_vector->affinity_mask);
 	q_vector->numa_node = node;
 
-- 
1.7.9.3


------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
