From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2] rocker: remove rocker parameter from functions that have rocker_port parameter
Date: Mon,  1 Jun 2015 13:25:04 +0900
Message-ID: <1433132704-21927-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36516 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754718AbbFAEZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:25:13 -0400
Received: by pdjm12 with SMTP id m12so15324843pdj.3
        for <netdev@vger.kernel.org>; Sun, 31 May 2015 21:25:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rocker (switch) of a rocker_port may be trivially obtained from
the latter it seems cleaner not to pass the former to a function when
the latter is being passed anyway.

rocker_port_rx_proc() is omitted from this change as it is a hot path case.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Acked-by: Scott Feldman <sfeldma@gmail.com>

---
v2
* Dropped RFC designation
* Omit rocker_port_rx_proc() from this change as it is a hot path case,
  as suggested by Scott Feldman
* Added Scott Feldman's Ack
---
 drivers/net/ethernet/rocker/rocker.c | 115 ++++++++++++++---------------------
 1 file changed, 45 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 36f7edfc3c7a..d246647b3653 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -1172,11 +1172,11 @@ static void rocker_dma_rings_fini(struct rocker *rocker)
 	rocker_dma_ring_destroy(rocker, &rocker->cmd_ring);
 }
 
-static int rocker_dma_rx_ring_skb_map(const struct rocker *rocker,
-				      const struct rocker_port *rocker_port,
+static int rocker_dma_rx_ring_skb_map(const struct rocker_port *rocker_port,
 				      struct rocker_desc_info *desc_info,
 				      struct sk_buff *skb, size_t buf_len)
 {
+	const struct rocker *rocker = rocker_port->rocker;
 	struct pci_dev *pdev = rocker->pdev;
 	dma_addr_t dma_handle;
 
@@ -1201,8 +1201,7 @@ static size_t rocker_port_rx_buf_len(const struct rocker_port *rocker_port)
 	return rocker_port->dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 }
 
-static int rocker_dma_rx_ring_skb_alloc(const struct rocker *rocker,
-					const struct rocker_port *rocker_port,
+static int rocker_dma_rx_ring_skb_alloc(const struct rocker_port *rocker_port,
 					struct rocker_desc_info *desc_info)
 {
 	struct net_device *dev = rocker_port->dev;
@@ -1219,8 +1218,7 @@ static int rocker_dma_rx_ring_skb_alloc(const struct rocker *rocker,
 	skb = netdev_alloc_skb_ip_align(dev, buf_len);
 	if (!skb)
 		return -ENOMEM;
-	err = rocker_dma_rx_ring_skb_map(rocker, rocker_port, desc_info,
-					 skb, buf_len);
+	err = rocker_dma_rx_ring_skb_map(rocker_port, desc_info, skb, buf_len);
 	if (err) {
 		dev_kfree_skb_any(skb);
 		return err;
@@ -1257,15 +1255,15 @@ static void rocker_dma_rx_ring_skb_free(const struct rocker *rocker,
 	dev_kfree_skb_any(skb);
 }
 
-static int rocker_dma_rx_ring_skbs_alloc(const struct rocker *rocker,
-					 const struct rocker_port *rocker_port)
+static int rocker_dma_rx_ring_skbs_alloc(const struct rocker_port *rocker_port)
 {
 	const struct rocker_dma_ring_info *rx_ring = &rocker_port->rx_ring;
+	const struct rocker *rocker = rocker_port->rocker;
 	int i;
 	int err;
 
 	for (i = 0; i < rx_ring->size; i++) {
-		err = rocker_dma_rx_ring_skb_alloc(rocker, rocker_port,
+		err = rocker_dma_rx_ring_skb_alloc(rocker_port,
 						   &rx_ring->desc_info[i]);
 		if (err)
 			goto rollback;
@@ -1278,10 +1276,10 @@ rollback:
 	return err;
 }
 
-static void rocker_dma_rx_ring_skbs_free(const struct rocker *rocker,
-					 const struct rocker_port *rocker_port)
+static void rocker_dma_rx_ring_skbs_free(const struct rocker_port *rocker_port)
 {
 	const struct rocker_dma_ring_info *rx_ring = &rocker_port->rx_ring;
+	const struct rocker *rocker = rocker_port->rocker;
 	int i;
 
 	for (i = 0; i < rx_ring->size; i++)
@@ -1327,7 +1325,7 @@ static int rocker_port_dma_rings_init(struct rocker_port *rocker_port)
 		goto err_dma_rx_ring_bufs_alloc;
 	}
 
-	err = rocker_dma_rx_ring_skbs_alloc(rocker, rocker_port);
+	err = rocker_dma_rx_ring_skbs_alloc(rocker_port);
 	if (err) {
 		netdev_err(rocker_port->dev, "failed to alloc rx dma ring skbs\n");
 		goto err_dma_rx_ring_skbs_alloc;
@@ -1353,7 +1351,7 @@ static void rocker_port_dma_rings_fini(struct rocker_port *rocker_port)
 {
 	struct rocker *rocker = rocker_port->rocker;
 
-	rocker_dma_rx_ring_skbs_free(rocker, rocker_port);
+	rocker_dma_rx_ring_skbs_free(rocker_port);
 	rocker_dma_ring_bufs_free(rocker, &rocker_port->rx_ring,
 				  PCI_DMA_BIDIRECTIONAL);
 	rocker_dma_ring_destroy(rocker, &rocker_port->rx_ring);
@@ -1588,22 +1586,20 @@ static irqreturn_t rocker_rx_irq_handler(int irq, void *dev_id)
  * Command interface
  ********************/
 
-typedef int (*rocker_cmd_prep_cb_t)(const struct rocker *rocker,
-				    const struct rocker_port *rocker_port,
+typedef int (*rocker_cmd_prep_cb_t)(const struct rocker_port *rocker_port,
 				    struct rocker_desc_info *desc_info,
 				    void *priv);
 
-typedef int (*rocker_cmd_proc_cb_t)(const struct rocker *rocker,
-				    const struct rocker_port *rocker_port,
+typedef int (*rocker_cmd_proc_cb_t)(const struct rocker_port *rocker_port,
 				    const struct rocker_desc_info *desc_info,
 				    void *priv);
 
-static int rocker_cmd_exec(struct rocker *rocker,
-			   struct rocker_port *rocker_port,
+static int rocker_cmd_exec(struct rocker_port *rocker_port,
 			   enum switchdev_trans trans,
 			   rocker_cmd_prep_cb_t prepare, void *prepare_priv,
 			   rocker_cmd_proc_cb_t process, void *process_priv)
 {
+	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_desc_info *desc_info;
 	struct rocker_wait *wait;
 	unsigned long flags;
@@ -1622,7 +1618,7 @@ static int rocker_cmd_exec(struct rocker *rocker,
 		goto out;
 	}
 
-	err = prepare(rocker, rocker_port, desc_info, prepare_priv);
+	err = prepare(rocker_port, desc_info, prepare_priv);
 	if (err) {
 		spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
 		goto out;
@@ -1644,7 +1640,7 @@ static int rocker_cmd_exec(struct rocker *rocker,
 		return err;
 
 	if (process)
-		err = process(rocker, rocker_port, desc_info, process_priv);
+		err = process(rocker_port, desc_info, process_priv);
 
 	rocker_desc_gen_clear(desc_info);
 out:
@@ -1653,8 +1649,7 @@ out:
 }
 
 static int
-rocker_cmd_get_port_settings_prep(const struct rocker *rocker,
-				  const struct rocker_port *rocker_port,
+rocker_cmd_get_port_settings_prep(const struct rocker_port *rocker_port,
 				  struct rocker_desc_info *desc_info,
 				  void *priv)
 {
@@ -1674,8 +1669,7 @@ rocker_cmd_get_port_settings_prep(const struct rocker *rocker,
 }
 
 static int
-rocker_cmd_get_port_settings_ethtool_proc(const struct rocker *rocker,
-					  const struct rocker_port *rocker_port,
+rocker_cmd_get_port_settings_ethtool_proc(const struct rocker_port *rocker_port,
 					  const struct rocker_desc_info *desc_info,
 					  void *priv)
 {
@@ -1713,8 +1707,7 @@ rocker_cmd_get_port_settings_ethtool_proc(const struct rocker *rocker,
 }
 
 static int
-rocker_cmd_get_port_settings_macaddr_proc(const struct rocker *rocker,
-					  const struct rocker_port *rocker_port,
+rocker_cmd_get_port_settings_macaddr_proc(const struct rocker_port *rocker_port,
 					  const struct rocker_desc_info *desc_info,
 					  void *priv)
 {
@@ -1746,8 +1739,7 @@ struct port_name {
 };
 
 static int
-rocker_cmd_get_port_settings_phys_name_proc(const struct rocker *rocker,
-					    const struct rocker_port *rocker_port,
+rocker_cmd_get_port_settings_phys_name_proc(const struct rocker_port *rocker_port,
 					    const struct rocker_desc_info *desc_info,
 					    void *priv)
 {
@@ -1788,8 +1780,7 @@ rocker_cmd_get_port_settings_phys_name_proc(const struct rocker *rocker,
 }
 
 static int
-rocker_cmd_set_port_settings_ethtool_prep(const struct rocker *rocker,
-					  const struct rocker_port *rocker_port,
+rocker_cmd_set_port_settings_ethtool_prep(const struct rocker_port *rocker_port,
 					  struct rocker_desc_info *desc_info,
 					  void *priv)
 {
@@ -1819,8 +1810,7 @@ rocker_cmd_set_port_settings_ethtool_prep(const struct rocker *rocker,
 }
 
 static int
-rocker_cmd_set_port_settings_macaddr_prep(const struct rocker *rocker,
-					  const struct rocker_port *rocker_port,
+rocker_cmd_set_port_settings_macaddr_prep(const struct rocker_port *rocker_port,
 					  struct rocker_desc_info *desc_info,
 					  void *priv)
 {
@@ -1844,8 +1834,7 @@ rocker_cmd_set_port_settings_macaddr_prep(const struct rocker *rocker,
 }
 
 static int
-rocker_cmd_set_port_learning_prep(const struct rocker *rocker,
-				  const struct rocker_port *rocker_port,
+rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 				  struct rocker_desc_info *desc_info,
 				  void *priv)
 {
@@ -1870,8 +1859,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker *rocker,
 static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
-			       SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_ethtool_proc,
 			       ecmd);
@@ -1880,8 +1868,7 @@ static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
-			       SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_macaddr_proc,
 			       macaddr);
@@ -1890,8 +1877,7 @@ static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
-			       SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_set_port_settings_ethtool_prep,
 			       ecmd, NULL, NULL);
 }
@@ -1899,8 +1885,7 @@ static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
-			       SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_set_port_settings_macaddr_prep,
 			       macaddr, NULL, NULL);
 }
@@ -1908,7 +1893,7 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_port_set_learning(struct rocker_port *rocker_port,
 				    enum switchdev_trans trans)
 {
-	return rocker_cmd_exec(rocker_port->rocker, rocker_port, trans,
+	return rocker_cmd_exec(rocker_port, trans,
 			       rocker_cmd_set_port_learning_prep,
 			       NULL, NULL, NULL);
 }
@@ -2114,8 +2099,7 @@ rocker_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
 	return 0;
 }
 
-static int rocker_cmd_flow_tbl_add(const struct rocker *rocker,
-				   const struct rocker_port *rocker_port,
+static int rocker_cmd_flow_tbl_add(const struct rocker_port *rocker_port,
 				   struct rocker_desc_info *desc_info,
 				   void *priv)
 {
@@ -2172,8 +2156,7 @@ static int rocker_cmd_flow_tbl_add(const struct rocker *rocker,
 	return 0;
 }
 
-static int rocker_cmd_flow_tbl_del(const struct rocker *rocker,
-				   const struct rocker_port *rocker_port,
+static int rocker_cmd_flow_tbl_del(const struct rocker_port *rocker_port,
 				   struct rocker_desc_info *desc_info,
 				   void *priv)
 {
@@ -2282,8 +2265,7 @@ rocker_cmd_group_tbl_add_l3_unicast(struct rocker_desc_info *desc_info,
 	return 0;
 }
 
-static int rocker_cmd_group_tbl_add(const struct rocker *rocker,
-				    const struct rocker_port *rocker_port,
+static int rocker_cmd_group_tbl_add(const struct rocker_port *rocker_port,
 				    struct rocker_desc_info *desc_info,
 				    void *priv)
 {
@@ -2328,8 +2310,7 @@ static int rocker_cmd_group_tbl_add(const struct rocker *rocker,
 	return 0;
 }
 
-static int rocker_cmd_group_tbl_del(const struct rocker *rocker,
-				    const struct rocker_port *rocker_port,
+static int rocker_cmd_group_tbl_del(const struct rocker_port *rocker_port,
 				    struct rocker_desc_info *desc_info,
 				    void *priv)
 {
@@ -2460,8 +2441,7 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
 
-	return rocker_cmd_exec(rocker, rocker_port, trans,
-			       rocker_cmd_flow_tbl_add,
+	return rocker_cmd_exec(rocker_port, trans, rocker_cmd_flow_tbl_add,
 			       found, NULL, NULL);
 }
 
@@ -2492,7 +2472,7 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 	rocker_port_kfree(trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker, rocker_port, trans,
+		err = rocker_cmd_exec(rocker_port, trans,
 				      rocker_cmd_flow_tbl_del,
 				      found, NULL, NULL);
 		rocker_port_kfree(trans, found);
@@ -2782,8 +2762,7 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
 
-	return rocker_cmd_exec(rocker, rocker_port, trans,
-			       rocker_cmd_group_tbl_add,
+	return rocker_cmd_exec(rocker_port, trans, rocker_cmd_group_tbl_add,
 			       found, NULL, NULL);
 }
 
@@ -2811,7 +2790,7 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 	rocker_group_tbl_entry_free(trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker, rocker_port, trans,
+		err = rocker_cmd_exec(rocker_port, trans,
 				      rocker_cmd_group_tbl_del,
 				      found, NULL, NULL);
 		rocker_group_tbl_entry_free(trans, found);
@@ -4219,8 +4198,7 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	struct port_name name = { .buf = buf, .len = len };
 	int err;
 
-	err = rocker_cmd_exec(rocker_port->rocker, rocker_port,
-			      SWITCHDEV_TRANS_NONE,
+	err = rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
 			      rocker_cmd_get_port_settings_prep, NULL,
 			      rocker_cmd_get_port_settings_phys_name_proc,
 			      &name);
@@ -4600,8 +4578,7 @@ static void rocker_port_get_strings(struct net_device *netdev, u32 stringset,
 }
 
 static int
-rocker_cmd_get_port_stats_prep(const struct rocker *rocker,
-			       const struct rocker_port *rocker_port,
+rocker_cmd_get_port_stats_prep(const struct rocker_port *rocker_port,
 			       struct rocker_desc_info *desc_info,
 			       void *priv)
 {
@@ -4625,8 +4602,7 @@ rocker_cmd_get_port_stats_prep(const struct rocker *rocker,
 }
 
 static int
-rocker_cmd_get_port_stats_ethtool_proc(const struct rocker *rocker,
-				       const struct rocker_port *rocker_port,
+rocker_cmd_get_port_stats_ethtool_proc(const struct rocker_port *rocker_port,
 				       const struct rocker_desc_info *desc_info,
 				       void *priv)
 {
@@ -4666,8 +4642,7 @@ rocker_cmd_get_port_stats_ethtool_proc(const struct rocker *rocker,
 static int rocker_cmd_get_port_stats_ethtool(struct rocker_port *rocker_port,
 					     void *priv)
 {
-	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
-			       SWITCHDEV_TRANS_NONE,
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE,
 			       rocker_cmd_get_port_stats_prep, NULL,
 			       rocker_cmd_get_port_stats_ethtool_proc,
 			       priv);
@@ -4780,7 +4755,7 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
 
 	netif_receive_skb(skb);
 
-	return rocker_dma_rx_ring_skb_alloc(rocker, rocker_port, desc_info);
+	return rocker_dma_rx_ring_skb_alloc(rocker_port, desc_info);
 }
 
 static struct rocker_port *rocker_port_napi_rx_get(struct napi_struct *napi)
@@ -4858,9 +4833,9 @@ static void rocker_remove_ports(const struct rocker *rocker)
 	kfree(rocker->ports);
 }
 
-static void rocker_port_dev_addr_init(const struct rocker *rocker,
-				      struct rocker_port *rocker_port)
+static void rocker_port_dev_addr_init(struct rocker_port *rocker_port)
 {
+	const struct rocker *rocker = rocker_port->rocker;
 	const struct pci_dev *pdev = rocker->pdev;
 	int err;
 
@@ -4890,7 +4865,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
 	INIT_LIST_HEAD(&rocker_port->trans_mem);
 
-	rocker_port_dev_addr_init(rocker, rocker_port);
+	rocker_port_dev_addr_init(rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
 	dev->ethtool_ops = &rocker_port_ethtool_ops;
 	dev->switchdev_ops = &rocker_port_switchdev_ops;
-- 
2.1.4
