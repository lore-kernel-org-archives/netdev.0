From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 8/8] net: systemport: Establish DSA network device queue mapping
Date: Wed, 30 Aug 2017 17:18:52 -0700
Message-ID: <1504138732-65383-9-git-send-email-f.fainelli@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Cc: jiri@resnulli.us, jhs@mojatatu.com, davem@davemloft.net,
        xiyou.wangcong@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35515 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdHaA1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 20:27:17 -0400
Received: by mail-wm0-f65.google.com with SMTP id e204so3361060wma.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 17:27:17 -0700 (PDT)
In-Reply-To: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Establish a queue mapping between the DSA slave network device queues
created, and the transmit queue that SYSTEMPORT manages.

We need to configure the SYSTEMPORT transmit queue with the switch port
number and switch port queue number in order for the switch and
SYSTEMPORT hardware to utilize the out of band congestion notification.
This hardware mechanism works by looking at the switch port egress queue
and determines whether there is enough buffers for this queue, with that
class of service for a successful transmission and if not, backpressures
the SYSTEMPORT queue that is being used.

For this to work, we register a network device notifier that listens for
the registration of DSA network devices, and when that happens, extracts
the number of queues for these devices and their associated port number,
remembers that in the driver private structure and linearly maps those
queues to TX rings/queues that we manage.

This scheme works because DSA slave network deviecs always transmit
through SYSTEMPORT so when DSA slave network devices are
destroyed/brought down, the corresponding SYSTEMPORT queues are no
longer used. Also, by design of the DSA framework, the master network
device (SYSTEMPORT) is registered first.

For faster lookups we use an array of up to DSA_MAX_PORTS * number
of queues per port, and then map pointers to bcm_sysport_tx_ring such
that our ndo_select_queue() implementation can just index into that
array to locate the corresponding ring index.

Here is an example mapping with this code:

P0,Q0 -> Q0
..
P0,Q7 -> Q7
P1,Q0 -> Q8
..
P1,Q7 -> Q15
P2,Q0 -> Q16
..
P2,Q7 -> Q23
P7,Q0 -> Q24
..
P7,Q7 -> Q31

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 100 +++++++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bcmsysport.h |  11 +++-
 2 files changed, 106 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 931751e4f369..eed4c3f672d7 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1387,7 +1387,14 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
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
 
 	/* Program the number of descriptors as MAX_THRESHOLD and half of
@@ -1405,8 +1412,9 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 	napi_enable(&ring->napi);
 
 	netif_dbg(priv, hw, priv->netdev,
-		  "TDMA cfg, size=%d, desc_cpu=%p\n",
-		  ring->size, ring->desc_cpu);
+		  "TDMA cfg, size=%d, desc_cpu=%p switch q=%d,port=%d\n",
+		  ring->size, ring->desc_cpu, ring->switch_queue,
+		  ring->switch_port);
 
 	return 0;
 }
@@ -1987,6 +1995,78 @@ static int bcm_sysport_stop(struct net_device *dev)
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
+	q = queue & 0xff;
+	port = queue >> priv->per_port_num_tx_queues;
+	tx_ring = priv->ring_map[q + port * priv->per_port_num_tx_queues];
+
+	return tx_ring->index;
+}
+
+static int bcm_sysport_map_queues(struct bcm_sysport_priv *priv,
+				  struct net_device *slave_dev)
+{
+	struct net_device *dev = priv->netdev;
+	struct bcm_sysport_tx_ring *ring;
+	unsigned int num_tx_queues;
+	unsigned int q, start, port;
+
+	port = dsa_slave_dev_port_num(slave_dev);
+	num_tx_queues = slave_dev->num_tx_queues;
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
+	return NOTIFY_OK;
+}
+
+static int bcm_sysport_notifier_event(struct notifier_block *nb,
+				      unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct bcm_sysport_priv *priv;
+
+	priv = container_of(nb, struct bcm_sysport_priv, queue_nb);
+
+	if (!dsa_slave_dev_check(dev))
+		return NOTIFY_DONE;
+
+	if (event == NETDEV_REGISTER)
+		return bcm_sysport_map_queues(priv, dev);
+
+	return NOTIFY_DONE;
+}
+
 static const struct net_device_ops bcm_sysport_netdev_ops = {
 	.ndo_start_xmit		= bcm_sysport_xmit,
 	.ndo_tx_timeout		= bcm_sysport_tx_timeout,
@@ -1999,6 +2079,7 @@ static int bcm_sysport_stop(struct net_device *dev)
 	.ndo_poll_controller	= bcm_sysport_poll_controller,
 #endif
 	.ndo_get_stats64	= bcm_sysport_get_stats64,
+	.ndo_select_queue	= bcm_sysport_select_queue,
 };
 
 #define REV_FMT	"v%2x.%02x"
@@ -2148,10 +2229,17 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 
 	u64_stats_init(&priv->syncp);
 
+	priv->queue_nb.notifier_call = bcm_sysport_notifier_event;
+	ret = register_netdevice_notifier(&priv->queue_nb);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to register notifier\n");
+		goto err_deregister_fixed_link;
+	}
+
 	ret = register_netdev(dev);
 	if (ret) {
 		dev_err(&pdev->dev, "failed to register net_device\n");
-		goto err_deregister_fixed_link;
+		goto err_deregister_nb;
 	}
 
 	priv->rev = topctrl_readl(priv, REV_CNTL) & REV_MASK;
@@ -2164,6 +2252,8 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 
 	return 0;
 
+err_deregister_nb:
+	unregister_netdevice_notifier(&priv->queue_nb);
 err_deregister_fixed_link:
 	if (of_phy_is_fixed_link(dn))
 		of_phy_deregister_fixed_link(dn);
@@ -2175,6 +2265,7 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 static int bcm_sysport_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	struct device_node *dn = pdev->dev.of_node;
 
 	/* Not much to do, ndo_close has been called
@@ -2183,6 +2274,7 @@ static int bcm_sysport_remove(struct platform_device *pdev)
 	unregister_netdev(dev);
 	if (of_phy_is_fixed_link(dn))
 		of_phy_deregister_fixed_link(dn);
+	unregister_netdevice_notifier(&priv->queue_nb);
 	free_netdev(dev);
 	dev_set_drvdata(&pdev->dev, NULL);
 
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 80b4ffff63b7..8913cb0cace6 100644
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
@@ -711,6 +711,8 @@ struct bcm_sysport_tx_ring {
 	struct bcm_sysport_priv *priv;	/* private context backpointer */
 	unsigned long	packets;	/* packets statistics */
 	unsigned long	bytes;		/* bytes statistics */
+	unsigned int	switch_queue;	/* switch port queue number */
+	unsigned int	switch_port;	/* switch port queue number */
 };
 
 /* Driver private structure */
@@ -764,5 +766,12 @@ struct bcm_sysport_priv {
 
 	/* For atomic update generic 64bit value on 32bit Machine */
 	struct u64_stats_sync	syncp;
+
+	/* netdev notifier to map switch port queues */
+	struct notifier_block	queue_nb;
+	unsigned int		per_port_num_tx_queues;
+	unsigned long		queue_bitmap;
+	struct bcm_sysport_tx_ring *ring_map[DSA_MAX_PORTS * 8];
+
 };
 #endif /* __BCM_SYSPORT_H */
-- 
1.9.1
