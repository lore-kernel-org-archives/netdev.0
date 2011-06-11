From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] ixgbe: use per NUMA node lock for FCoE DDP
Date: Fri, 10 Jun 2011 20:02:21 -0700
Message-ID: <1307761341-5267-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3248 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758563Ab1FKDCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 23:02:32 -0400
In-Reply-To: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Adds per NUMA node lock to have CPU pass thru its NUMA lock
first before contending for global DDP fcoe->lock to setup
DDP lock, this is to reduce contentions across NUMA nodes.

Allocates and initialize per NUMA node lock in added
ixgbe_fcoe_lock_init and then have current CPU's numa_node_id
based NUMA node lock acquired before taking global fcoe->lock.

The node lock is allocated from its NUMA node using kzalloc_node.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_fcoe.c |   50 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_fcoe.h |    1 +
 2 files changed, 49 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index f5f39ed..aadff4f 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -109,6 +109,7 @@ int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid)
 	len = ddp->len;
 	/* if there an error, force to invalidate ddp context */
 	if (ddp->err) {
+		spin_lock(fcoe->node_lock[numa_node_id()]);
 		spin_lock_bh(&fcoe->lock);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCFLT, 0);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCFLTRW,
@@ -122,6 +123,7 @@ int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid)
 				(xid | IXGBE_FCDMARW_RE));
 		fcbuff = IXGBE_READ_REG(&adapter->hw, IXGBE_FCBUFF);
 		spin_unlock_bh(&fcoe->lock);
+		spin_unlock(fcoe->node_lock[numa_node_id()]);
 		if (fcbuff & IXGBE_FCBUFF_VALID)
 			udelay(100);
 	}
@@ -294,6 +296,7 @@ static int ixgbe_fcoe_ddp_setup(struct net_device *netdev, u16 xid,
 
 	/* program DMA context */
 	hw = &adapter->hw;
+	spin_lock(fcoe->node_lock[numa_node_id()]);
 	spin_lock_bh(&fcoe->lock);
 
 	/* turn on last frame indication for target mode as FCP_RSPtarget is
@@ -315,6 +318,7 @@ static int ixgbe_fcoe_ddp_setup(struct net_device *netdev, u16 xid,
 	IXGBE_WRITE_REG(hw, IXGBE_FCFLTRW, fcfltrw);
 
 	spin_unlock_bh(&fcoe->lock);
+	spin_unlock(fcoe->node_lock[numa_node_id()]);
 
 	return 1;
 
@@ -634,6 +638,42 @@ static void ixgbe_fcoe_ddp_pools_alloc(struct ixgbe_adapter *adapter)
 	}
 }
 
+static void ixgbe_fcoe_locks_free(struct ixgbe_fcoe *fcoe)
+{
+	int node;
+
+	if (!fcoe->node_lock)
+		return;
+
+	for_each_node_with_cpus(node)
+			kfree(fcoe->node_lock[node]);
+
+	kfree(fcoe->node_lock);
+	fcoe->node_lock = NULL;
+}
+
+static void ixgbe_fcoe_lock_init(struct ixgbe_fcoe *fcoe)
+{
+	int node;
+	spinlock_t *node_lock;
+
+	fcoe->node_lock = kzalloc(sizeof(node_lock) * num_possible_nodes(),
+				  GFP_KERNEL);
+	if (!fcoe->node_lock)
+		return;
+
+	for_each_node_with_cpus(node) {
+		node_lock = kzalloc_node(sizeof(*node_lock) , GFP_KERNEL, node);
+		if (!node_lock) {
+			ixgbe_fcoe_locks_free(fcoe);
+			return;
+		}
+		spin_lock_init(node_lock);
+		fcoe->node_lock[node] = node_lock;
+	}
+	spin_lock_init(&fcoe->lock);
+}
+
 /**
  * ixgbe_configure_fcoe - configures registers for fcoe at start
  * @adapter: ptr to ixgbe adapter
@@ -654,12 +694,16 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 #endif
 
 	if (!fcoe->pool) {
-		spin_lock_init(&fcoe->lock);
+		ixgbe_fcoe_lock_init(fcoe);
+		if (!fcoe->node_lock) {
+			e_err(drv, "failed to initialize fcoe locks\n");
+			return;
+		}
 
 		ixgbe_fcoe_ddp_pools_alloc(adapter);
 		if (!fcoe->pool) {
 			e_err(drv, "failed to alloc percpu fcoe DDP pools\n");
-			return;
+			goto out_locks_free;
 		}
 
 		/* Extra buffer to be shared by all DDPs for HW work around */
@@ -735,6 +779,8 @@ out_extra_ddp_buffer:
 	kfree(fcoe->extra_ddp_buffer);
 out_ddp_pools:
 	ixgbe_fcoe_ddp_pools_free(fcoe);
+out_locks_free:
+	ixgbe_fcoe_locks_free(fcoe);
 }
 
 /**
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index d876e7a..8618892 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -69,6 +69,7 @@ struct ixgbe_fcoe {
 	struct pci_pool **pool;
 	atomic_t refcnt;
 	spinlock_t lock;
+	struct spinlock **node_lock;
 	struct ixgbe_fcoe_ddp ddp[IXGBE_FCOE_DDP_MAX];
 	unsigned char *extra_ddp_buffer;
 	dma_addr_t extra_ddp_buffer_dma;
-- 
1.7.5.2

