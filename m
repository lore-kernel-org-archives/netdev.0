From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 2/2] qede: Add aRFS support
Date: Thu, 13 Apr 2017 04:54:45 -0700
Message-ID: <20170413115445.16662-3-manish.chopra@cavium.com>
References: <20170413115445.16662-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0050.outbound.protection.outlook.com ([104.47.33.50]:32235
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753293AbdDMLzL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 07:55:11 -0400
In-Reply-To: <20170413115445.16662-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for aRFS for TCP and UDP
protocols with IPv4/IPv6.

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h        |  22 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c | 441 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c   |  50 ++-
 3 files changed, 508 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 5e7ad25..7e18ae6 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -41,6 +41,9 @@
 #include <linux/mutex.h>
 #include <linux/bpf.h>
 #include <linux/io.h>
+#ifdef CONFIG_RFS_ACCEL
+#include <linux/cpu_rmap.h>
+#endif
 #include <linux/qed/common_hsi.h>
 #include <linux/qed/eth_common.h>
 #include <linux/qed/qed_if.h>
@@ -237,7 +240,10 @@ struct qede_dev {
 	u16				vxlan_dst_port;
 	u16				geneve_dst_port;
 
-	bool wol_enabled;
+#ifdef CONFIG_RFS_ACCEL
+	struct qede_arfs		*arfs;
+#endif
+	bool				wol_enabled;
 
 	struct qede_rdma_dev		rdma_info;
 
@@ -439,6 +445,20 @@ struct qede_fastpath {
 #define QEDE_SP_VXLAN_PORT_CONFIG	2
 #define QEDE_SP_GENEVE_PORT_CONFIG	3
 
+#ifdef CONFIG_RFS_ACCEL
+int qede_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
+		       u16 rxq_index, u32 flow_id);
+void qede_process_arfs_filters(struct qede_dev *edev, bool free_fltr);
+void qede_poll_for_freeing_arfs_filters(struct qede_dev *edev);
+void qede_arfs_filter_op(void *dev, void *filter, u8 fw_rc);
+void qede_free_arfs(struct qede_dev *edev);
+int qede_alloc_arfs(struct qede_dev *edev);
+
+#define QEDE_SP_ARFS_CONFIG	4
+#define QEDE_SP_TASK_POLL_DELAY	(5 * HZ)
+#define QEDE_RFS_MAX_FLTR	256
+#endif
+
 struct qede_reload_args {
 	void (*func)(struct qede_dev *edev, struct qede_reload_args *args);
 	union {
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index b00a4fc..8c594a3 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -38,6 +38,447 @@
 #include <linux/qed/qed_if.h>
 #include "qede.h"
 
+#ifdef CONFIG_RFS_ACCEL
+struct qede_arfs_tuple {
+	union {
+		__be32 src_ipv4;
+		struct in6_addr src_ipv6;
+	};
+	union {
+		__be32 dst_ipv4;
+		struct in6_addr dst_ipv6;
+	};
+	__be16  src_port;
+	__be16  dst_port;
+	__be16  eth_proto;
+	u8      ip_proto;
+};
+
+struct qede_arfs_fltr_node {
+#define QEDE_FLTR_VALID	 0
+	unsigned long state;
+
+	/* pointer to aRFS packet buffer */
+	void *data;
+
+	/* dma map address of aRFS packet buffer */
+	dma_addr_t mapping;
+
+	/* length of aRFS packet buffer */
+	int buf_len;
+
+	/* tuples to hold from aRFS packet buffer */
+	struct qede_arfs_tuple tuple;
+
+	u32 flow_id;
+	u16 sw_id;
+	u16 rxq_id;
+	u16 next_rxq_id;
+	bool filter_op;
+	bool used;
+	struct hlist_node node;
+};
+
+struct qede_arfs {
+#define QEDE_ARFS_POLL_COUNT	100
+#define QEDE_RFS_FLW_BITSHIFT	(4)
+#define QEDE_RFS_FLW_MASK	((1 << QEDE_RFS_FLW_BITSHIFT) - 1)
+	struct hlist_head	arfs_hl_head[1 << QEDE_RFS_FLW_BITSHIFT];
+
+	/* lock for filter list access */
+	spinlock_t		arfs_list_lock;
+	unsigned long		*arfs_fltr_bmap;
+	int			filter_count;
+	bool			enable;
+};
+
+static void qede_configure_arfs_fltr(struct qede_dev *edev,
+				     struct qede_arfs_fltr_node *n,
+				     u16 rxq_id, bool add_fltr)
+{
+	const struct qed_eth_ops *op = edev->ops;
+
+	if (n->used)
+		return;
+
+	DP_VERBOSE(edev, NETIF_MSG_RX_STATUS,
+		   "%s arfs filter flow_id=%d, sw_id=%d, src_port=%d, dst_port=%d, rxq=%d\n",
+		   add_fltr ? "Adding" : "Deleting",
+		   n->flow_id, n->sw_id, ntohs(n->tuple.src_port),
+		   ntohs(n->tuple.dst_port), rxq_id);
+
+	n->used = true;
+	n->filter_op = add_fltr;
+	op->ntuple_filter_config(edev->cdev, n, n->mapping, n->buf_len, 0,
+				 rxq_id, add_fltr);
+}
+
+static void
+qede_free_arfs_filter(struct qede_dev *edev,  struct qede_arfs_fltr_node *fltr)
+{
+	kfree(fltr->data);
+	clear_bit(fltr->sw_id, edev->arfs->arfs_fltr_bmap);
+	kfree(fltr);
+}
+
+void qede_arfs_filter_op(void *dev, void *filter, u8 fw_rc)
+{
+	struct qede_arfs_fltr_node *fltr = filter;
+	struct qede_dev *edev = dev;
+
+	if (fw_rc) {
+		DP_NOTICE(edev,
+			  "Failed arfs filter configuration fw_rc=%d, flow_id=%d, sw_id=%d, src_port=%d, dst_port=%d, rxq=%d\n",
+			  fw_rc, fltr->flow_id, fltr->sw_id,
+			  ntohs(fltr->tuple.src_port),
+			  ntohs(fltr->tuple.dst_port), fltr->rxq_id);
+
+		spin_lock_bh(&edev->arfs->arfs_list_lock);
+
+		fltr->used = false;
+		clear_bit(QEDE_FLTR_VALID, &fltr->state);
+
+		spin_unlock_bh(&edev->arfs->arfs_list_lock);
+		return;
+	}
+
+	spin_lock_bh(&edev->arfs->arfs_list_lock);
+
+	fltr->used = false;
+
+	if (fltr->filter_op) {
+		set_bit(QEDE_FLTR_VALID, &fltr->state);
+		if (fltr->rxq_id != fltr->next_rxq_id)
+			qede_configure_arfs_fltr(edev, fltr, fltr->rxq_id,
+						 false);
+	} else {
+		clear_bit(QEDE_FLTR_VALID, &fltr->state);
+		if (fltr->rxq_id != fltr->next_rxq_id) {
+			fltr->rxq_id = fltr->next_rxq_id;
+			qede_configure_arfs_fltr(edev, fltr,
+						 fltr->rxq_id, true);
+		}
+	}
+
+	spin_unlock_bh(&edev->arfs->arfs_list_lock);
+}
+
+/* Should be called while qede_lock is held */
+void qede_process_arfs_filters(struct qede_dev *edev, bool free_fltr)
+{
+	int i;
+
+	for (i = 0; i <= QEDE_RFS_FLW_MASK; i++) {
+		struct hlist_node *temp;
+		struct hlist_head *head;
+		struct qede_arfs_fltr_node *fltr;
+
+		head = &edev->arfs->arfs_hl_head[i];
+
+		hlist_for_each_entry_safe(fltr, temp, head, node) {
+			bool del = false;
+
+			if (edev->state != QEDE_STATE_OPEN)
+				del = true;
+
+			spin_lock_bh(&edev->arfs->arfs_list_lock);
+
+			if ((!test_bit(QEDE_FLTR_VALID, &fltr->state) &&
+			     !fltr->used) || free_fltr) {
+				hlist_del(&fltr->node);
+				dma_unmap_single(&edev->pdev->dev,
+						 fltr->mapping,
+						 fltr->buf_len, DMA_TO_DEVICE);
+				qede_free_arfs_filter(edev, fltr);
+				edev->arfs->filter_count--;
+			} else {
+				if ((rps_may_expire_flow(edev->ndev,
+							 fltr->rxq_id,
+							 fltr->flow_id,
+							 fltr->sw_id) || del) &&
+							 !free_fltr)
+					qede_configure_arfs_fltr(edev, fltr,
+								 fltr->rxq_id,
+								 false);
+			}
+
+			spin_unlock_bh(&edev->arfs->arfs_list_lock);
+		}
+	}
+
+	spin_lock_bh(&edev->arfs->arfs_list_lock);
+
+	if (!edev->arfs->filter_count) {
+		if (edev->arfs->enable) {
+			edev->arfs->enable = false;
+			edev->ops->configure_arfs_searcher(edev->cdev, false);
+		}
+	} else {
+		set_bit(QEDE_SP_ARFS_CONFIG, &edev->sp_flags);
+		schedule_delayed_work(&edev->sp_task,
+				      QEDE_SP_TASK_POLL_DELAY);
+	}
+
+	spin_unlock_bh(&edev->arfs->arfs_list_lock);
+}
+
+/* This function waits until all aRFS filters get deleted and freed.
+ * On timeout it frees all filters forcefully.
+ */
+void qede_poll_for_freeing_arfs_filters(struct qede_dev *edev)
+{
+	int count = QEDE_ARFS_POLL_COUNT;
+
+	while (count) {
+		qede_process_arfs_filters(edev, false);
+
+		if (!edev->arfs->filter_count)
+			break;
+
+		msleep(100);
+		count--;
+	}
+
+	if (!count) {
+		DP_NOTICE(edev, "Timeout in polling for arfs filter free\n");
+
+		/* Something is terribly wrong, free forcefully */
+		qede_process_arfs_filters(edev, true);
+	}
+}
+
+int qede_alloc_arfs(struct qede_dev *edev)
+{
+	int i;
+
+	edev->arfs = vzalloc(sizeof(*edev->arfs));
+	if (!edev->arfs)
+		return -ENOMEM;
+
+	spin_lock_init(&edev->arfs->arfs_list_lock);
+
+	for (i = 0; i <= QEDE_RFS_FLW_MASK; i++)
+		INIT_HLIST_HEAD(&edev->arfs->arfs_hl_head[i]);
+
+	edev->ndev->rx_cpu_rmap = alloc_irq_cpu_rmap(QEDE_RSS_COUNT(edev));
+	if (!edev->ndev->rx_cpu_rmap) {
+		vfree(edev->arfs);
+		edev->arfs = NULL;
+		return -ENOMEM;
+	}
+
+	edev->arfs->arfs_fltr_bmap = vzalloc(BITS_TO_LONGS(QEDE_RFS_MAX_FLTR));
+	if (!edev->arfs->arfs_fltr_bmap) {
+		free_irq_cpu_rmap(edev->ndev->rx_cpu_rmap);
+		edev->ndev->rx_cpu_rmap = NULL;
+		vfree(edev->arfs);
+		edev->arfs = NULL;
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+void qede_free_arfs(struct qede_dev *edev)
+{
+	if (!edev->arfs)
+		return;
+
+	if (edev->ndev->rx_cpu_rmap)
+		free_irq_cpu_rmap(edev->ndev->rx_cpu_rmap);
+
+	edev->ndev->rx_cpu_rmap = NULL;
+	vfree(edev->arfs->arfs_fltr_bmap);
+	edev->arfs->arfs_fltr_bmap = NULL;
+	vfree(edev->arfs);
+	edev->arfs = NULL;
+}
+
+static bool qede_compare_ip_addr(struct qede_arfs_fltr_node *tpos,
+				 const struct sk_buff *skb)
+{
+	if (skb->protocol == htons(ETH_P_IP)) {
+		if (tpos->tuple.src_ipv4 == ip_hdr(skb)->saddr &&
+		    tpos->tuple.dst_ipv4 == ip_hdr(skb)->daddr)
+			return true;
+		else
+			return false;
+	} else {
+		struct in6_addr *src = &tpos->tuple.src_ipv6;
+		u8 size = sizeof(struct in6_addr);
+
+		if (!memcmp(src, &ipv6_hdr(skb)->saddr, size) &&
+		    !memcmp(&tpos->tuple.dst_ipv6, &ipv6_hdr(skb)->daddr, size))
+			return true;
+		else
+			return false;
+	}
+}
+
+static struct qede_arfs_fltr_node *
+qede_arfs_htbl_key_search(struct hlist_head *h, const struct sk_buff *skb,
+			  __be16 src_port, __be16 dst_port, u8 ip_proto)
+{
+	struct qede_arfs_fltr_node *tpos;
+
+	hlist_for_each_entry(tpos, h, node)
+		if (tpos->tuple.ip_proto == ip_proto &&
+		    tpos->tuple.eth_proto == skb->protocol &&
+		    qede_compare_ip_addr(tpos, skb) &&
+		    tpos->tuple.src_port == src_port &&
+		    tpos->tuple.dst_port == dst_port)
+			return tpos;
+
+	return NULL;
+}
+
+static struct qede_arfs_fltr_node *
+qede_alloc_filter(struct qede_dev *edev, int min_hlen)
+{
+	struct qede_arfs_fltr_node *n;
+	int bit_id;
+
+	bit_id = find_first_zero_bit(edev->arfs->arfs_fltr_bmap,
+				     QEDE_RFS_MAX_FLTR);
+
+	if (bit_id >= QEDE_RFS_MAX_FLTR)
+		return NULL;
+
+	n = kzalloc(sizeof(*n), GFP_ATOMIC);
+	if (!n)
+		return NULL;
+
+	n->data = kzalloc(min_hlen, GFP_ATOMIC);
+	if (!n->data) {
+		kfree(n);
+		return NULL;
+	}
+
+	n->sw_id = (u16)bit_id;
+	set_bit(bit_id, edev->arfs->arfs_fltr_bmap);
+	return n;
+}
+
+int qede_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
+		       u16 rxq_index, u32 flow_id)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qede_arfs_fltr_node *n;
+	int min_hlen, rc, tp_offset;
+	struct ethhdr *eth;
+	__be16 *ports;
+	u16 tbl_idx;
+	u8 ip_proto;
+
+	if (skb->encapsulation)
+		return -EPROTONOSUPPORT;
+
+	if (skb->protocol != htons(ETH_P_IP) &&
+	    skb->protocol != htons(ETH_P_IPV6))
+		return -EPROTONOSUPPORT;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		ip_proto = ip_hdr(skb)->protocol;
+		tp_offset = sizeof(struct iphdr);
+	} else {
+		ip_proto = ipv6_hdr(skb)->nexthdr;
+		tp_offset = sizeof(struct ipv6hdr);
+	}
+
+	if (ip_proto != IPPROTO_TCP && ip_proto != IPPROTO_UDP)
+		return -EPROTONOSUPPORT;
+
+	ports = (__be16 *)(skb->data + tp_offset);
+	tbl_idx = skb_get_hash_raw(skb) & QEDE_RFS_FLW_MASK;
+
+	spin_lock_bh(&edev->arfs->arfs_list_lock);
+
+	n = qede_arfs_htbl_key_search(&edev->arfs->arfs_hl_head[tbl_idx],
+				      skb, ports[0], ports[1], ip_proto);
+
+	if (n) {
+		/* Filter match */
+		n->next_rxq_id = rxq_index;
+
+		if (test_bit(QEDE_FLTR_VALID, &n->state)) {
+			if (n->rxq_id != rxq_index)
+				qede_configure_arfs_fltr(edev, n, n->rxq_id,
+							 false);
+		} else {
+			if (!n->used) {
+				n->rxq_id = rxq_index;
+				qede_configure_arfs_fltr(edev, n, n->rxq_id,
+							 true);
+			}
+		}
+
+		rc = n->sw_id;
+		goto ret_unlock;
+	}
+
+	min_hlen = ETH_HLEN + skb_headlen(skb);
+
+	n = qede_alloc_filter(edev, min_hlen);
+	if (!n) {
+		rc = -ENOMEM;
+		goto ret_unlock;
+	}
+
+	n->buf_len = min_hlen;
+	n->rxq_id = rxq_index;
+	n->next_rxq_id = rxq_index;
+	n->tuple.src_port = ports[0];
+	n->tuple.dst_port = ports[1];
+	n->flow_id = flow_id;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		n->tuple.src_ipv4 = ip_hdr(skb)->saddr;
+		n->tuple.dst_ipv4 = ip_hdr(skb)->daddr;
+	} else {
+		memcpy(&n->tuple.src_ipv6, &ipv6_hdr(skb)->saddr,
+		       sizeof(struct in6_addr));
+		memcpy(&n->tuple.dst_ipv6, &ipv6_hdr(skb)->daddr,
+		       sizeof(struct in6_addr));
+	}
+
+	eth = (struct ethhdr *)n->data;
+	eth->h_proto = skb->protocol;
+	n->tuple.eth_proto = skb->protocol;
+	n->tuple.ip_proto = ip_proto;
+	memcpy(n->data + ETH_HLEN, skb->data, skb_headlen(skb));
+
+	n->mapping = dma_map_single(&edev->pdev->dev, n->data,
+				    n->buf_len, DMA_TO_DEVICE);
+	if (dma_mapping_error(&edev->pdev->dev, n->mapping)) {
+		DP_NOTICE(edev, "Failed to map DMA memory for arfs\n");
+		qede_free_arfs_filter(edev, n);
+		rc = -ENOMEM;
+		goto ret_unlock;
+	}
+
+	INIT_HLIST_NODE(&n->node);
+	hlist_add_head(&n->node, &edev->arfs->arfs_hl_head[tbl_idx]);
+	edev->arfs->filter_count++;
+
+	if (edev->arfs->filter_count == 1 && !edev->arfs->enable) {
+		edev->ops->configure_arfs_searcher(edev->cdev, true);
+		edev->arfs->enable = true;
+	}
+
+	qede_configure_arfs_fltr(edev, n, n->rxq_id, true);
+
+	spin_unlock_bh(&edev->arfs->arfs_list_lock);
+
+	set_bit(QEDE_SP_ARFS_CONFIG, &edev->sp_flags);
+	schedule_delayed_work(&edev->sp_task, 0);
+	return n->sw_id;
+
+ret_unlock:
+	spin_unlock_bh(&edev->arfs->arfs_list_lock);
+	return rc;
+}
+#endif
+
 void qede_force_mac(void *dev, u8 *mac, bool forced)
 {
 	struct qede_dev *edev = dev;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 8c2baf8..02b305c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -225,6 +225,9 @@ static struct pci_driver qede_pci_driver = {
 
 static struct qed_eth_cb_ops qede_ll_ops = {
 	{
+#ifdef CONFIG_RFS_ACCEL
+		.arfs_filter_op = qede_arfs_filter_op,
+#endif
 		.link_update = qede_link_update,
 	},
 	.force_mac = qede_force_mac,
@@ -554,6 +557,9 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_udp_tunnel_del = qede_udp_tunnel_del,
 	.ndo_features_check = qede_features_check,
 	.ndo_xdp = qede_xdp,
+#ifdef CONFIG_RFS_ACCEL
+	.ndo_rx_flow_steer = qede_rx_flow_steer,
+#endif
 };
 
 /* -------------------------------------------------------------------------
@@ -603,7 +609,7 @@ static void qede_init_ndev(struct qede_dev *edev)
 {
 	struct net_device *ndev = edev->ndev;
 	struct pci_dev *pdev = edev->pdev;
-	u32 hw_features;
+	netdev_features_t hw_features;
 
 	pci_set_drvdata(pdev, ndev);
 
@@ -629,6 +635,10 @@ static void qede_init_ndev(struct qede_dev *edev)
 	hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
 		       NETIF_F_TSO_ECN | NETIF_F_GSO_UDP_TUNNEL_CSUM |
 		       NETIF_F_GSO_GRE_CSUM;
+
+	if (!IS_VF(edev) && edev->dev_info.common.num_hwfns == 1)
+		hw_features |= NETIF_F_NTUPLE;
+
 	ndev->hw_enc_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO_ECN |
 				NETIF_F_TSO6 | NETIF_F_GSO_GRE |
@@ -798,6 +808,12 @@ static void qede_sp_task(struct work_struct *work)
 		qed_ops->tunn_config(cdev, &tunn_params);
 	}
 
+#ifdef CONFIG_RFS_ACCEL
+	if (test_and_clear_bit(QEDE_SP_ARFS_CONFIG, &edev->sp_flags)) {
+		if (edev->state == QEDE_STATE_OPEN)
+			qede_process_arfs_filters(edev, false);
+	}
+#endif
 	__qede_unlock(edev);
 }
 
@@ -808,6 +824,9 @@ static void qede_update_pf_params(struct qed_dev *cdev)
 	/* 64 rx + 64 tx + 64 XDP */
 	memset(&pf_params, 0, sizeof(struct qed_pf_params));
 	pf_params.eth_pf_params.num_cons = (MAX_SB_PER_PF_MIMD - 1) * 3;
+#ifdef CONFIG_RFS_ACCEL
+	pf_params.eth_pf_params.num_arfs_filters = QEDE_RFS_MAX_FLTR;
+#endif
 	qed_ops->common->update_pf_params(cdev, &pf_params);
 }
 
@@ -962,9 +981,8 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 
 	DP_INFO(edev, "Starting qede_remove\n");
 
-	cancel_delayed_work_sync(&edev->sp_task);
-
 	unregister_netdev(ndev);
+	cancel_delayed_work_sync(&edev->sp_task);
 
 	qede_ptp_remove(edev);
 
@@ -1490,6 +1508,18 @@ static int qede_req_msix_irqs(struct qede_dev *edev)
 	}
 
 	for (i = 0; i < QEDE_QUEUE_CNT(edev); i++) {
+#ifdef CONFIG_RFS_ACCEL
+		struct qede_fastpath *fp = &edev->fp_array[i];
+
+		if (edev->ndev->rx_cpu_rmap && (fp->type & QEDE_FASTPATH_RX)) {
+			rc = irq_cpu_rmap_add(edev->ndev->rx_cpu_rmap,
+					      edev->int_info.msix[i].vector);
+			if (rc) {
+				DP_ERR(edev, "Failed to add CPU rmap\n");
+				qede_free_arfs(edev);
+			}
+		}
+#endif
 		rc = request_irq(edev->int_info.msix[i].vector,
 				 qede_msix_fp_int, 0, edev->fp_array[i].name,
 				 &edev->fp_array[i]);
@@ -1871,7 +1901,12 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode,
 
 	qede_vlan_mark_nonconfigured(edev);
 	edev->ops->fastpath_stop(edev->cdev);
-
+#ifdef CONFIG_RFS_ACCEL
+	if (!IS_VF(edev) && edev->dev_info.common.num_hwfns == 1) {
+		qede_poll_for_freeing_arfs_filters(edev);
+		qede_free_arfs(edev);
+	}
+#endif
 	/* Release the interrupts */
 	qede_sync_free_irqs(edev);
 	edev->ops->common->set_fp_int(edev->cdev, 0);
@@ -1923,6 +1958,13 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode,
 	if (rc)
 		goto err2;
 
+#ifdef CONFIG_RFS_ACCEL
+	if (!IS_VF(edev) && edev->dev_info.common.num_hwfns == 1) {
+		rc = qede_alloc_arfs(edev);
+		if (rc)
+			DP_NOTICE(edev, "aRFS memory allocation failed\n");
+	}
+#endif
 	qede_napi_add_enable(edev);
 	DP_INFO(edev, "Napi added and enabled\n");
 
-- 
2.7.2
