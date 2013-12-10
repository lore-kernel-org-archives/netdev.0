From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net 5/5] qlcnic: Use spinlock per transmit queue
Date: Tue, 10 Dec 2013 12:33:05 -0500
Message-ID: <3059519f25683ec7f84f6a9710778f4bf967d7b0.1386648865.git.himanshu.madhani@qlogic.com>
References: <cover.1386648865.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:27953 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755421Ab3LJSFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 13:05:51 -0500
In-Reply-To: <cover.1386648865.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Driver was using common spinlock to protect Tx descriptor cleanup
for all Tx queues.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      | 3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c | 3 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c   | 4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 4 +---
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 631ea0a..1842fe4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -578,6 +578,8 @@ struct qlcnic_host_tx_ring {
 	dma_addr_t phys_addr;
 	dma_addr_t hw_cons_phys_addr;
 	struct netdev_queue *txq;
+	/* Lock to protect Tx descriptors cleanup */
+	spinlock_t tx_clean_lock;
 } ____cacheline_internodealigned_in_smp;
 
 /*
@@ -1093,7 +1095,6 @@ struct qlcnic_adapter {
 	struct qlcnic_filter_hash rx_fhash;
 	struct list_head vf_mc_list;
 
-	spinlock_t tx_clean_lock;
 	spinlock_t mac_learn_lock;
 	/* spinlock for catching rcv filters for eswitch traffic */
 	spinlock_t rx_mac_learn_lock;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index e9c21e5..e5e7902 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -134,6 +134,7 @@ void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter,
 	struct qlcnic_skb_frag *buffrag;
 	int i, j;
 
+	spin_lock(&tx_ring->tx_clean_lock);
 	cmd_buf = tx_ring->cmd_buf_arr;
 	for (i = 0; i < tx_ring->num_desc; i++) {
 		buffrag = cmd_buf->frag_array;
@@ -157,6 +158,8 @@ void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter,
 		}
 		cmd_buf++;
 	}
+
+	spin_unlock(&tx_ring->tx_clean_lock);
 }
 
 void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 312c6cd..d9e8e10 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -784,7 +784,7 @@ static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_skb_frag *frag;
 
-	if (!spin_trylock(&adapter->tx_clean_lock))
+	if (!spin_trylock(&tx_ring->tx_clean_lock))
 		return 1;
 
 	sw_consumer = tx_ring->sw_consumer;
@@ -840,7 +840,7 @@ static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter,
 	 */
 	hw_consumer = le32_to_cpu(*(tx_ring->hw_consumer));
 	done = (sw_consumer == hw_consumer);
-	spin_unlock(&adapter->tx_clean_lock);
+	spin_unlock(&tx_ring->tx_clean_lock);
 
 	return done;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 2c8cac0..b8a245a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1756,7 +1756,6 @@ void __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	if (qlcnic_sriov_vf_check(adapter))
 		qlcnic_sriov_cleanup_async_list(&adapter->ahw->sriov->bc);
 	smp_mb();
-	spin_lock(&adapter->tx_clean_lock);
 	netif_carrier_off(netdev);
 	adapter->ahw->linkup = 0;
 	netif_tx_disable(netdev);
@@ -1777,7 +1776,6 @@ void __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	for (ring = 0; ring < adapter->drv_tx_rings; ring++)
 		qlcnic_release_tx_buffers(adapter, &adapter->tx_ring[ring]);
-	spin_unlock(&adapter->tx_clean_lock);
 }
 
 /* Usage: During suspend and firmware recovery module */
@@ -2172,6 +2170,7 @@ int qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter,
 		}
 		memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
 		tx_ring->cmd_buf_arr = cmd_buf_arr;
+		spin_lock_init(&tx_ring->tx_clean_lock);
 	}
 
 	if (qlcnic_83xx_check(adapter) ||
@@ -2299,7 +2298,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rwlock_init(&adapter->ahw->crb_lock);
 	mutex_init(&adapter->ahw->mem_lock);
 
-	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
 
 	qlcnic_register_dcb(adapter);
-- 
1.8.1.4
