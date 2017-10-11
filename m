From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/5] net: systemport: Establish lower/upper queue mapping
Date: Wed, 11 Oct 2017 10:57:50 -0700
Message-ID: <20171011175752.22030-4-f.fainelli@gmail.com>
References: <20171011175752.22030-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:48598 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757683AbdJKR7i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:59:38 -0400
Received: by mail-qt0-f193.google.com with SMTP id f8so7755399qta.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:59:38 -0700 (PDT)
In-Reply-To: <20171011175752.22030-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Establish a queue mapping between the DSA slave network device queues
created that correspond to switch port queues, and the transmit queue
that SYSTEMPORT manages.

We need to configure the SYSTEMPORT transmit queue with the switch port number
and switch port queue number in order for the switch and SYSTEMPORT hardware to
utilize the out of band congestion notification. This hardware mechanism works
by looking at the switch port egress queue and determines whether there is
enough buffers for this queue, with that class of service for a successful
transmission and if not, backpressures the SYSTEMPORT queue that is being used.

For this to work, we implement a notifier which looks at the
DSA_PORT_REGISTER event.  When DSA network devices are registered, the
framework calls the DSA notifiers when that happens, extracts the number
of queues for these devices and their associated port number, remembers
that in the driver private structure and linearly maps those queues to
TX rings/queues that we manage.

This scheme works because DSA slave network deviecs always transmit
through SYSTEMPORT so when DSA slave network devices are
destroyed/brought down, the corresponding SYSTEMPORT queues are no
longer used. Also, by design of the DSA framework, the master network
device (SYSTEMPORT) is registered first.

For faster lookups we use an array of up to DSA_MAX_PORTS * number of
queues per port, and then map pointers to bcm_sysport_tx_ring such that
our ndo_select_queue() implementation can just index into that array to
locate the corresponding ring index.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 115 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bcmsysport.h |  11 ++-
 2 files changed, 121 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 83eec9a8c275..78bed9a84e81 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1416,7 +1416,14 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 	tdma_writel(priv, 0, TDMA_DESC_RING_COUNT(index));
 	tdma_writel(priv, 1, TDMA_DESC_RING_INTR_CONTROL(index));
 	tdma_writel(priv, 0, TDMA_DESC_RING_PROD_CONS_INDEX(index));
-	tdma_writel(priv, RING_IGNORE_STATUS, TDMA_DESC_RING_MAPPING(index));
+
+	/* Configure QID and port mapping */
+	reg = tdma_readl(priv, TDMA_DESC_RING_MAPPING(index));
+	reg &= ~(RING_QID_MASK | RING_PORT_ID_MASK << RING_PORT_ID_SHIFT);
+	reg |= ring->switch_queue & RING_QID_MASK;
+	reg |= ring->switch_port << RING_PORT_ID_SHIFT;
+	reg |= RING_IGNORE_STATUS;
+	tdma_writel(priv, reg, TDMA_DESC_RING_MAPPING(index));
 	tdma_writel(priv, 0, TDMA_DESC_RING_PCP_DEI_VID(index));
 
 	/* Do not use tdma_control_bit() here because TSB_SWAP1 collides
@@ -1447,8 +1454,9 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 	napi_enable(&ring->napi);
 
 	netif_dbg(priv, hw, priv->netdev,
-		  "TDMA cfg, size=%d, desc_cpu=%p\n",
-		  ring->size, ring->desc_cpu);
+		  "TDMA cfg, size=%d, desc_cpu=%p switch q=%d,port=%d\n",
+		  ring->size, ring->desc_cpu, ring->switch_queue,
+		  ring->switch_port);
 
 	return 0;
 }
@@ -2011,6 +2019,92 @@ static const struct ethtool_ops bcm_sysport_ethtool_ops = {
 	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
 };
 
+static u16 bcm_sysport_select_queue(struct net_device *dev, struct sk_buff *skb,
+				    void *accel_priv,
+				    select_queue_fallback_t fallback)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	u16 queue = skb_get_queue_mapping(skb);
+	struct bcm_sysport_tx_ring *tx_ring;
+	unsigned int q, port;
+
+	if (!netdev_uses_dsa(dev))
+		return fallback(dev, skb);
+
+	/* DSA tagging layer will have configured the correct queue */
+	q = BRCM_TAG_GET_QUEUE(queue);
+	port = BRCM_TAG_GET_PORT(queue);
+	tx_ring = priv->ring_map[q + port * priv->per_port_num_tx_queues];
+
+	return tx_ring->index;
+}
+
+static int bcm_sysport_map_queues(struct net_device *dev,
+				  struct dsa_notifier_register_info *info)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct bcm_sysport_tx_ring *ring;
+	struct net_device *slave_dev;
+	unsigned int num_tx_queues;
+	unsigned int q, start, port;
+
+	/* We can't be setting up queue inspection for non directly attached
+	 * switches
+	 */
+	if (info->switch_number)
+		return 0;
+
+	port = info->port_number;
+	slave_dev = info->info.dev;
+
+	/* On SYSTEMPORT Lite we have twice as less queues, so we cannot do a
+	 * 1:1 mapping, we can only do a 2:1 mapping. By reducing the number of
+	 * per-port (slave_dev) network devices queue, we achieve just that.
+	 * This need to happen now before any slave network device is used such
+	 * it accurately reflects the number of real TX queues.
+	 */
+	if (priv->is_lite)
+		netif_set_real_num_tx_queues(slave_dev,
+					     slave_dev->num_tx_queues / 2);
+	num_tx_queues = slave_dev->real_num_tx_queues;
+
+	if (priv->per_port_num_tx_queues &&
+	    priv->per_port_num_tx_queues != num_tx_queues)
+		netdev_warn(slave_dev, "asymetric number of per-port queues\n");
+
+	priv->per_port_num_tx_queues = num_tx_queues;
+
+	start = find_first_zero_bit(&priv->queue_bitmap, dev->num_tx_queues);
+	for (q = 0; q < num_tx_queues; q++) {
+		ring = &priv->tx_rings[q + start];
+
+		/* Just remember the mapping actual programming done
+		 * during bcm_sysport_init_tx_ring
+		 */
+		ring->switch_queue = q;
+		ring->switch_port = port;
+		priv->ring_map[q + port * num_tx_queues] = ring;
+
+		/* Set all queues as being used now */
+		set_bit(q + start, &priv->queue_bitmap);
+	}
+
+	return 0;
+}
+
+static int bcm_sysport_dsa_notifier(struct notifier_block *unused,
+				    unsigned long event, void *ptr)
+{
+	struct dsa_notifier_register_info *info;
+
+	if (event != DSA_PORT_REGISTER)
+		return NOTIFY_DONE;
+
+	info = ptr;
+
+	return notifier_from_errno(bcm_sysport_map_queues(info->master, info));
+}
+
 static const struct net_device_ops bcm_sysport_netdev_ops = {
 	.ndo_start_xmit		= bcm_sysport_xmit,
 	.ndo_tx_timeout		= bcm_sysport_tx_timeout,
@@ -2023,6 +2117,7 @@ static const struct net_device_ops bcm_sysport_netdev_ops = {
 	.ndo_poll_controller	= bcm_sysport_poll_controller,
 #endif
 	.ndo_get_stats64	= bcm_sysport_get_stats64,
+	.ndo_select_queue	= bcm_sysport_select_queue,
 };
 
 #define REV_FMT	"v%2x.%02x"
@@ -2172,10 +2267,18 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 
 	u64_stats_init(&priv->syncp);
 
+	priv->dsa_notifier.notifier_call = bcm_sysport_dsa_notifier;
+
+	ret = register_dsa_notifier(&priv->dsa_notifier);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to register DSA notifier\n");
+		goto err_deregister_fixed_link;
+	}
+
 	ret = register_netdev(dev);
 	if (ret) {
 		dev_err(&pdev->dev, "failed to register net_device\n");
-		goto err_deregister_fixed_link;
+		goto err_deregister_notifier;
 	}
 
 	priv->rev = topctrl_readl(priv, REV_CNTL) & REV_MASK;
@@ -2188,6 +2291,8 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 
 	return 0;
 
+err_deregister_notifier:
+	unregister_dsa_notifier(&priv->dsa_notifier);
 err_deregister_fixed_link:
 	if (of_phy_is_fixed_link(dn))
 		of_phy_deregister_fixed_link(dn);
@@ -2199,11 +2304,13 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 static int bcm_sysport_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	struct device_node *dn = pdev->dev.of_node;
 
 	/* Not much to do, ndo_close has been called
 	 * and we use managed allocations
 	 */
+	unregister_dsa_notifier(&priv->dsa_notifier);
 	unregister_netdev(dev);
 	if (of_phy_is_fixed_link(dn))
 		of_phy_deregister_fixed_link(dn);
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 82e401df199e..82f70a6783cb 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -404,7 +404,7 @@ struct bcm_rsb {
 #define  RING_CONS_INDEX_MASK		0xffff
 
 #define RING_MAPPING			0x14
-#define  RING_QID_MASK			0x3
+#define  RING_QID_MASK			0x7
 #define  RING_PORT_ID_SHIFT		3
 #define  RING_PORT_ID_MASK		0x7
 #define  RING_IGNORE_STATUS		(1 << 6)
@@ -712,6 +712,8 @@ struct bcm_sysport_tx_ring {
 	struct bcm_sysport_priv *priv;	/* private context backpointer */
 	unsigned long	packets;	/* packets statistics */
 	unsigned long	bytes;		/* bytes statistics */
+	unsigned int	switch_queue;	/* switch port queue number */
+	unsigned int	switch_port;	/* switch port queue number */
 };
 
 /* Driver private structure */
@@ -765,5 +767,12 @@ struct bcm_sysport_priv {
 
 	/* For atomic update generic 64bit value on 32bit Machine */
 	struct u64_stats_sync	syncp;
+
+	/* map information between switch port queues and local queues */
+	struct notifier_block	dsa_notifier;
+	unsigned int		per_port_num_tx_queues;
+	unsigned long		queue_bitmap;
+	struct bcm_sysport_tx_ring *ring_map[DSA_MAX_PORTS * 8];
+
 };
 #endif /* __BCM_SYSPORT_H */
-- 
2.9.3
