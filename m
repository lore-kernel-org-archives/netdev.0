From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 1/5] driver/net: enic: Add multi tx support for enic
Date: Wed,  4 Sep 2013 11:17:14 +0530
Message-ID: <1378273638-7780-2-git-send-email-govindarajulu90@gmail.com>
References: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
Cc: benve@cisco.com, ssujith@cisco.com, nistrive@cisco.com,
	umalhi@cisco.com,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch adds multi tx support for enic.

Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |  2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c | 36 +++++++++++++++++++----------
 2 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index be16731..34b637a 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -37,7 +37,7 @@
 
 #define ENIC_BARS_MAX		6
 
-#define ENIC_WQ_MAX		1
+#define ENIC_WQ_MAX		8
 #define ENIC_RQ_MAX		8
 #define ENIC_CQ_MAX		(ENIC_WQ_MAX + ENIC_RQ_MAX)
 #define ENIC_INTR_MAX		(ENIC_CQ_MAX + 2)
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index bcf15b1..1ab3f18 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -128,10 +128,10 @@ static int enic_wq_service(struct vnic_dev *vdev, struct cq_desc *cq_desc,
 		completed_index, enic_wq_free_buf,
 		opaque);
 
-	if (netif_queue_stopped(enic->netdev) &&
+	if (netif_tx_queue_stopped(netdev_get_tx_queue(enic->netdev, q_number)) &&
 	    vnic_wq_desc_avail(&enic->wq[q_number]) >=
 	    (MAX_SKB_FRAGS + ENIC_DESC_MAX_SPLITS))
-		netif_wake_queue(enic->netdev);
+		netif_wake_subqueue(enic->netdev, q_number);
 
 	spin_unlock(&enic->wq_lock[q_number]);
 
@@ -292,10 +292,15 @@ static irqreturn_t enic_isr_msix_rq(int irq, void *data)
 static irqreturn_t enic_isr_msix_wq(int irq, void *data)
 {
 	struct enic *enic = data;
-	unsigned int cq = enic_cq_wq(enic, 0);
-	unsigned int intr = enic_msix_wq_intr(enic, 0);
+	unsigned int cq;
+	unsigned int intr;
 	unsigned int wq_work_to_do = -1; /* no limit */
 	unsigned int wq_work_done;
+	unsigned int wq_irq;
+
+	wq_irq = (u32)irq - enic->msix_entry[enic_msix_wq_intr(enic, 0)].vector;
+	cq = enic_cq_wq(enic, wq_irq);
+	intr = enic_msix_wq_intr(enic, wq_irq);
 
 	wq_work_done = vnic_cq_service(&enic->cq[cq],
 		wq_work_to_do, enic_wq_service, NULL);
@@ -511,14 +516,18 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 	struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
-	struct vnic_wq *wq = &enic->wq[0];
+	struct vnic_wq *wq;
 	unsigned long flags;
+	unsigned int txq_map;
 
 	if (skb->len <= 0) {
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
+	txq_map = skb_get_queue_mapping(skb) % enic->wq_count;
+	wq = &enic->wq[txq_map];
+
 	/* Non-TSO sends must fit within ENIC_NON_TSO_MAX_DESC descs,
 	 * which is very likely.  In the off chance it's going to take
 	 * more than * ENIC_NON_TSO_MAX_DESC, linearize the skb.
@@ -531,23 +540,23 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	spin_lock_irqsave(&enic->wq_lock[0], flags);
+	spin_lock_irqsave(&enic->wq_lock[txq_map], flags);
 
 	if (vnic_wq_desc_avail(wq) <
 	    skb_shinfo(skb)->nr_frags + ENIC_DESC_MAX_SPLITS) {
-		netif_stop_queue(netdev);
+		netif_tx_stop_queue(netdev_get_tx_queue(netdev, txq_map));
 		/* This is a hard error, log it */
 		netdev_err(netdev, "BUG! Tx ring full when queue awake!\n");
-		spin_unlock_irqrestore(&enic->wq_lock[0], flags);
+		spin_unlock_irqrestore(&enic->wq_lock[txq_map], flags);
 		return NETDEV_TX_BUSY;
 	}
 
 	enic_queue_wq_skb(enic, wq, skb);
 
 	if (vnic_wq_desc_avail(wq) < MAX_SKB_FRAGS + ENIC_DESC_MAX_SPLITS)
-		netif_stop_queue(netdev);
+		netif_tx_stop_queue(netdev_get_tx_queue(netdev, txq_map));
 
-	spin_unlock_irqrestore(&enic->wq_lock[0], flags);
+	spin_unlock_irqrestore(&enic->wq_lock[txq_map], flags);
 
 	return NETDEV_TX_OK;
 }
@@ -1369,7 +1378,7 @@ static int enic_open(struct net_device *netdev)
 
 	enic_set_rx_mode(netdev);
 
-	netif_wake_queue(netdev);
+	netif_tx_wake_all_queues(netdev);
 
 	for (i = 0; i < enic->rq_count; i++)
 		napi_enable(&enic->napi[i]);
@@ -2032,7 +2041,8 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * instance data is initialized to zero.
 	 */
 
-	netdev = alloc_etherdev(sizeof(struct enic));
+	netdev = alloc_etherdev_mqs(sizeof(struct enic),
+				    ENIC_RQ_MAX, ENIC_WQ_MAX);
 	if (!netdev)
 		return -ENOMEM;
 
@@ -2198,6 +2208,8 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_dev_close;
 	}
 
+	netif_set_real_num_tx_queues(netdev, enic->wq_count);
+
 	/* Setup notification timer, HW reset task, and wq locks
 	 */
 
-- 
1.8.4
