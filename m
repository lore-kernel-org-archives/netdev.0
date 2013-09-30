From: Rob Herring <robherring2@gmail.com>
Subject: [RFC PATCH] net: calxedaxgmac: add mac address learning
Date: Mon, 30 Sep 2013 15:17:09 -0500
Message-ID: <1380572229-32150-1-git-send-email-robherring2@gmail.com>
Cc: Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

The Calxeda xgmac must learn secondary mac addresses such as those
behind a bridge in order to properly receive packets with those mac
addresses. Add mac address learning on transmit with aging of entries.
The mac addresses are added to the driver's unicast address list, so
they are visible to user via "bridge fdb show" command.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 84 ++++++++++++++++++++++++++++++++++++
 1 file changed, 84 insertions(+)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 48f5288..2afe8b7 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -360,6 +360,12 @@ struct xgmac_extra_stats {
 	unsigned long rx_process_stopped;
 	unsigned long tx_early;
 	unsigned long fatal_bus_error;
+	unsigned long learning_drop;
+};
+
+struct xgmac_mac {
+	char mac_addr[ETH_ALEN];
+	unsigned long time;
 };
 
 struct xgmac_priv {
@@ -384,6 +390,8 @@ struct xgmac_priv {
 	struct napi_struct napi;
 
 	int max_macs;
+	struct xgmac_mac mac_list[32];
+
 	struct xgmac_extra_stats xstats;
 
 	spinlock_t stats_lock;
@@ -392,8 +400,11 @@ struct xgmac_priv {
 	char tx_pause;
 	int wolopts;
 	struct work_struct tx_timeout_work;
+	struct delayed_work mac_aging_work;
 };
 
+#define XGMAC_AGING_TIMEOUT	(120 * HZ)
+
 /* XGMAC Configuration Settings */
 #define MAX_MTU			9000
 #define PAUSE_TIME		0x400
@@ -1047,6 +1058,8 @@ static int xgmac_open(struct net_device *dev)
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + XGMAC_DMA_STATUS);
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + XGMAC_DMA_INTR_ENA);
 
+	schedule_delayed_work(&priv->mac_aging_work, 5 * HZ);
+
 	return 0;
 }
 
@@ -1059,6 +1072,7 @@ static int xgmac_open(struct net_device *dev)
 static int xgmac_stop(struct net_device *dev)
 {
 	struct xgmac_priv *priv = netdev_priv(dev);
+	int i;
 
 	netif_stop_queue(dev);
 
@@ -1073,9 +1087,74 @@ static int xgmac_stop(struct net_device *dev)
 	/* Release and free the Rx/Tx resources */
 	xgmac_free_dma_desc_rings(priv);
 
+	cancel_delayed_work_sync(&priv->mac_aging_work);
+	for (i = 0; i < priv->max_macs; i++) {
+		if (!is_valid_ether_addr(priv->mac_list[i].mac_addr))
+			continue;
+		priv->mac_list[i].time = 0;
+		dev_uc_del(dev, priv->mac_list[i].mac_addr);
+		memset(priv->mac_list[i].mac_addr, 0, ETH_ALEN);
+	}
+
 	return 0;
 }
 
+static void xgmac_mac_aging_work(struct work_struct *work)
+{
+	int i;
+	struct xgmac_priv *priv =
+		container_of(work, struct xgmac_priv, mac_aging_work.work);
+	struct net_device *dev = priv->dev;
+
+	for (i = 0; i < priv->max_macs; i++) {
+		if (time_is_after_jiffies(priv->mac_list[i].time + XGMAC_AGING_TIMEOUT))
+			continue;
+		if (!is_valid_ether_addr(priv->mac_list[i].mac_addr))
+			continue;
+
+		priv->mac_list[i].time = 0;
+		printk("unlearned addr %pM\n", priv->mac_list[i].mac_addr);
+		dev_uc_del(dev, priv->mac_list[i].mac_addr);
+		memset(priv->mac_list[i].mac_addr, 0, ETH_ALEN);
+	}
+
+	schedule_delayed_work(to_delayed_work(work), 5 * HZ);
+}
+
+static void xgmac_learn_mac(struct xgmac_priv *priv, struct sk_buff *skb)
+{
+	struct net_device *dev = priv->dev;
+	struct ethhdr *phdr = (struct ethhdr *)(skb->data);
+	char *src_addr = phdr->h_source;
+	int i, slot = -1;
+
+	if (ether_addr_equal(src_addr, dev->dev_addr) ||
+	    !is_valid_ether_addr(src_addr))
+		return;
+
+	for (i = 0; i < priv->max_macs; i++) {
+		/* update timestamp if we already learned the address */
+		if (ether_addr_equal(priv->mac_list[i].mac_addr, src_addr)) {
+			priv->mac_list[i].time = jiffies;
+			return;
+		}
+		/* find empty slot */
+		if ((slot < 0) && !priv->mac_list[i].time)
+			slot = i;
+	}
+
+	/* Check if we've already filled all slots */
+	if (slot < 0) {
+		priv->xstats.learning_drop++;
+		return;
+	}
+
+	printk("learned addr %pM\n", src_addr);
+	priv->mac_list[slot].time = jiffies;
+	memcpy(priv->mac_list[slot].mac_addr, src_addr, ETH_ALEN);
+	dev_uc_add_excl(dev, src_addr);
+}
+
 /**
  *  xgmac_xmit:
  *  @skb : the socket buffer
@@ -1155,6 +1234,9 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (tx_dma_ring_space(priv) > MAX_SKB_FRAGS)
 			netif_start_queue(dev);
 	}
+
+	xgmac_learn_mac(priv, skb);
+
 	return NETDEV_TX_OK;
 
 dma_err:
@@ -1605,6 +1687,7 @@ static const struct xgmac_stats xgmac_gstrings_stats[] = {
 	XGMAC_STAT(rx_ip_header_error),
 	XGMAC_STAT(rx_da_filter_fail),
 	XGMAC_STAT(fatal_bus_error),
+	XGMAC_STAT(learning_drop),
 	XGMAC_HW_STAT(rx_watchdog, XGMAC_MMC_RXWATCHDOG),
 	XGMAC_HW_STAT(tx_vlan, XGMAC_MMC_TXVLANFRAME),
 	XGMAC_HW_STAT(rx_vlan, XGMAC_MMC_RXVLANFRAME),
@@ -1743,6 +1826,7 @@ static int xgmac_probe(struct platform_device *pdev)
 	SET_ETHTOOL_OPS(ndev, &xgmac_ethtool_ops);
 	spin_lock_init(&priv->stats_lock);
 	INIT_WORK(&priv->tx_timeout_work, xgmac_tx_timeout_work);
+	INIT_DELAYED_WORK(&priv->mac_aging_work, xgmac_mac_aging_work);
 
 	priv->device = &pdev->dev;
 	priv->dev = ndev;
-- 
1.8.1.2
