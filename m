From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH 1/2] ixgbe,
	make interrupt allocations NUMA aware
Date: Mon, 24 Feb 2014 13:51:52 -0500
Message-ID: <1393267913-28212-2-git-send-email-prarit@redhat.com>
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

The ixgbe driver creates one queue/cpu on the system in order to spread
work out on all cpus rather than restricting work to a single cpu.  This
model, while efficient, does not take into account the NUMA configuration
of the system.

This patch introduces ixgbe_num_cpus() which returns
the number of online cpus if the adapter's PCI device has no NUMA
restrictions, and the number of cpus in the node if the PCI device is
allocated to a specific node.

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
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c   |   28 +++++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    6 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    5 +++--
 4 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 0186ea2..edee04b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -970,4 +970,6 @@ void ixgbe_sriov_reinit(struct ixgbe_adapter *adapter);
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 				  struct ixgbe_adapter *adapter,
 				  struct ixgbe_ring *tx_ring);
+
+extern int ixgbe_num_cpus(struct ixgbe_adapter *adapter);
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 32e3eaa..3668288 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -480,6 +480,27 @@ static bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 }
 
 #endif
+
+/**
+ * ixgbe_num_cpus - Return the number of cpus that this adapter should
+ *		    allocate queues for.
+ * @adapter: board private structure to allocate cpus for
+ *
+ * A pci device may be restricted via ACPI and HW to a specific NUMA node,
+ * or in other words a specific set of cpus.  If the adapter's PCI device
+ * is on a specific node, then only allocate queues for that specific node.
+ *
+ **/
+int ixgbe_num_cpus(struct ixgbe_adapter *adapter)
+{
+	int numa;
+
+	numa = adapter->pdev->dev.numa_node;
+	if (numa == NUMA_NO_NODE)
+		return num_online_cpus();
+	return nr_cpus_node(numa);
+}
+
 /**
  * ixgbe_set_sriov_queues - Allocate queues for SR-IOV devices
  * @adapter: board private structure to initialize
@@ -567,7 +588,8 @@ static bool ixgbe_set_sriov_queues(struct ixgbe_adapter *adapter)
 			fcoe->offset = vmdq_i * rss_i;
 		} else {
 			/* merge FCoE queues with RSS queues */
-			fcoe_i = min_t(u16, fcoe_i + rss_i, num_online_cpus());
+			fcoe_i = min_t(u16, fcoe_i + rss_i,
+				       ixgbe_num_cpus(adapter));
 
 			/* limit indices to rss_i if MSI-X is disabled */
 			if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
@@ -642,7 +664,7 @@ static bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 		f = &adapter->ring_feature[RING_F_FCOE];
 
 		/* merge FCoE queues with RSS queues */
-		fcoe_i = min_t(u16, f->limit + rss_i, num_online_cpus());
+		fcoe_i = min_t(u16, f->limit + rss_i, ixgbe_num_cpus(adapter));
 		fcoe_i = min_t(u16, fcoe_i, dev->num_tx_queues);
 
 		/* limit indices to rss_i if MSI-X is disabled */
@@ -1067,7 +1089,7 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	 * The default is to use pairs of vectors.
 	 */
 	v_budget = max(adapter->num_rx_queues, adapter->num_tx_queues);
-	v_budget = min_t(int, v_budget, num_online_cpus());
+	v_budget = min_t(int, v_budget, ixgbe_num_cpus(adapter));
 	v_budget += NON_Q_VECTORS;
 
 	/*
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 18076c4..b68a6e9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4953,13 +4953,13 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->subsystem_device_id = pdev->subsystem_device;
 
 	/* Set common capability flags and settings */
-	rss = min_t(int, IXGBE_MAX_RSS_INDICES, num_online_cpus());
+	rss = min_t(int, IXGBE_MAX_RSS_INDICES, ixgbe_num_cpus(adapter));
 	adapter->ring_feature[RING_F_RSS].limit = rss;
 	adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
 	adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
 	adapter->max_q_vectors = MAX_Q_VECTORS_82599;
 	adapter->atr_sample_rate = 20;
-	fdir = min_t(int, IXGBE_MAX_FDIR_INDICES, num_online_cpus());
+	fdir = min_t(int, IXGBE_MAX_FDIR_INDICES, ixgbe_num_cpus(adapter));
 	adapter->ring_feature[RING_F_FDIR].limit = fdir;
 	adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_64K;
 #ifdef CONFIG_IXGBE_DCA
@@ -8074,7 +8074,7 @@ skip_sriov:
 		}
 
 
-		fcoe_l = min_t(int, IXGBE_FCRETA_SIZE, num_online_cpus());
+		fcoe_l = min_t(int, IXGBE_FCRETA_SIZE, ixgbe_num_cpus(adapter));
 		adapter->ring_feature[RING_F_FCOE].limit = fcoe_l;
 
 		netdev->features |= NETIF_F_FSO |
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index dff0977..bfbc574 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -222,9 +222,10 @@ int ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 	if (adapter->ring_feature[RING_F_VMDQ].limit == 1) {
 		adapter->flags &= ~IXGBE_FLAG_VMDQ_ENABLED;
 		adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
-		rss = min_t(int, IXGBE_MAX_RSS_INDICES, num_online_cpus());
+		rss = min_t(int, IXGBE_MAX_RSS_INDICES,
+			    ixgbe_num_cpus(adapter));
 	} else {
-		rss = min_t(int, IXGBE_MAX_L2A_QUEUES, num_online_cpus());
+		rss = min_t(int, IXGBE_MAX_L2A_QUEUES, ixgbe_num_cpus(adapter));
 	}
 
 	adapter->ring_feature[RING_F_VMDQ].offset = 0;
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
