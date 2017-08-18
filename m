From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 4/6] dpaa_eth: add NETIF_F_RXHASH
Date: Fri, 18 Aug 2017 11:56:26 +0300
Message-ID: <1503046588-24349-5-git-send-email-madalin.bucur@nxp.com>
References: <1503046588-24349-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0043.outbound.protection.outlook.com ([104.47.41.43]:22304
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751013AbdHRI4l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 04:56:41 -0400
In-Reply-To: <1503046588-24349-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the skb hash when then FMan Keygen hash result is available.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     | 19 ++++++++++++++++---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |  1 +
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c |  9 +++++++--
 drivers/net/ethernet/freescale/fman/fman_port.c    | 11 +++++++++++
 drivers/net/ethernet/freescale/fman/fman_port.h    |  2 ++
 5 files changed, 37 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 6d89e74..ef30038 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -236,7 +236,7 @@ static int dpaa_netdev_init(struct net_device *net_dev,
 	net_dev->max_mtu = dpaa_get_max_mtu();
 
 	net_dev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-				 NETIF_F_LLTX);
+				 NETIF_F_LLTX | NETIF_F_RXHASH);
 
 	net_dev->hw_features |= NETIF_F_SG | NETIF_F_HIGHDMA;
 	/* The kernels enables GSO automatically, if we declare NETIF_F_SG.
@@ -2237,12 +2237,13 @@ static enum qman_cb_dqrr_result rx_default_dqrr(struct qman_portal *portal,
 	dma_addr_t addr = qm_fd_addr(fd);
 	enum qm_fd_format fd_format;
 	struct net_device *net_dev;
-	u32 fd_status;
+	u32 fd_status, hash_offset;
 	struct dpaa_bp *dpaa_bp;
 	struct dpaa_priv *priv;
 	unsigned int skb_len;
 	struct sk_buff *skb;
 	int *count_ptr;
+	void *vaddr;
 
 	fd_status = be32_to_cpu(fd->status);
 	fd_format = qm_fd_get_format(fd);
@@ -2288,7 +2289,8 @@ static enum qman_cb_dqrr_result rx_default_dqrr(struct qman_portal *portal,
 	dma_unmap_single(dpaa_bp->dev, addr, dpaa_bp->size, DMA_FROM_DEVICE);
 
 	/* prefetch the first 64 bytes of the frame or the SGT start */
-	prefetch(phys_to_virt(addr) + qm_fd_get_offset(fd));
+	vaddr = phys_to_virt(addr);
+	prefetch(vaddr + qm_fd_get_offset(fd));
 
 	fd_format = qm_fd_get_format(fd);
 	/* The only FD types that we may receive are contig and S/G */
@@ -2309,6 +2311,14 @@ static enum qman_cb_dqrr_result rx_default_dqrr(struct qman_portal *portal,
 
 	skb->protocol = eth_type_trans(skb, net_dev);
 
+	if (net_dev->features & NETIF_F_RXHASH && priv->keygen_in_use &&
+	    !fman_port_get_hash_result_offset(priv->mac_dev->port[RX],
+					      &hash_offset))
+		skb_set_hash(skb, be32_to_cpu(*(u32 *)(vaddr + hash_offset)),
+			     // if L4 exists, it was used in the hash generation
+			     be32_to_cpu(fd->status) & FM_FD_STAT_L4CV ?
+				PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
+
 	skb_len = skb->len;
 
 	if (unlikely(netif_receive_skb(skb) == NET_RX_DROP))
@@ -2774,6 +2784,9 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 	if (err)
 		goto init_ports_failed;
 
+	/* Rx traffic distribution based on keygen hashing defaults to on */
+	priv->keygen_in_use = true;
+
 	priv->percpu_priv = devm_alloc_percpu(dev, *priv->percpu_priv);
 	if (!priv->percpu_priv) {
 		dev_err(dev, "devm_alloc_percpu() failed\n");
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
index 496a12c..bd94220 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -159,6 +159,7 @@ struct dpaa_priv {
 	struct list_head dpaa_fq_list;
 
 	u8 num_tc;
+	bool keygen_in_use;
 	u32 msg_enable;	/* net_device message level */
 
 	struct {
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
index 965f652..faea674 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
@@ -402,6 +402,8 @@ static void dpaa_get_strings(struct net_device *net_dev, u32 stringset,
 static int dpaa_get_hash_opts(struct net_device *dev,
 			      struct ethtool_rxnfc *cmd)
 {
+	struct dpaa_priv *priv = netdev_priv(dev);
+
 	cmd->data = 0;
 
 	switch (cmd->flow_type) {
@@ -409,7 +411,8 @@ static int dpaa_get_hash_opts(struct net_device *dev,
 	case TCP_V6_FLOW:
 	case UDP_V4_FLOW:
 	case UDP_V6_FLOW:
-		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		if (priv->keygen_in_use)
+			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		/* Fall through */
 	case IPV4_FLOW:
 	case IPV6_FLOW:
@@ -421,7 +424,8 @@ static int dpaa_get_hash_opts(struct net_device *dev,
 	case AH_V6_FLOW:
 	case ESP_V4_FLOW:
 	case ESP_V6_FLOW:
-		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		if (priv->keygen_in_use)
+			cmd->data |= RXH_IP_SRC | RXH_IP_DST;
 		break;
 	default:
 		cmd->data = 0;
@@ -458,6 +462,7 @@ static void dpaa_set_hash(struct net_device *net_dev, bool enable)
 	rxport = mac_dev->port[0];
 
 	fman_port_use_kg_hash(rxport, enable);
+	priv->keygen_in_use = enable;
 }
 
 static int dpaa_set_hash_opts(struct net_device *dev,
diff --git a/drivers/net/ethernet/freescale/fman/fman_port.c b/drivers/net/ethernet/freescale/fman/fman_port.c
index b0ad9c4..451bae7 100644
--- a/drivers/net/ethernet/freescale/fman/fman_port.c
+++ b/drivers/net/ethernet/freescale/fman/fman_port.c
@@ -1720,6 +1720,17 @@ u32 fman_port_get_qman_channel_id(struct fman_port *port)
 }
 EXPORT_SYMBOL(fman_port_get_qman_channel_id);
 
+int fman_port_get_hash_result_offset(struct fman_port *port, u32 *offset)
+{
+	if (port->buffer_offsets.hash_result_offset == ILLEGAL_BASE)
+		return -EINVAL;
+
+	*offset = port->buffer_offsets.hash_result_offset;
+
+	return 0;
+}
+EXPORT_SYMBOL(fman_port_get_hash_result_offset);
+
 static int fman_port_probe(struct platform_device *of_dev)
 {
 	struct fman_port *port;
diff --git a/drivers/net/ethernet/freescale/fman/fman_port.h b/drivers/net/ethernet/freescale/fman/fman_port.h
index 5a99611..e86ca6a 100644
--- a/drivers/net/ethernet/freescale/fman/fman_port.h
+++ b/drivers/net/ethernet/freescale/fman/fman_port.h
@@ -151,6 +151,8 @@ int fman_port_enable(struct fman_port *port);
 
 u32 fman_port_get_qman_channel_id(struct fman_port *port);
 
+int fman_port_get_hash_result_offset(struct fman_port *port, u32 *offset);
+
 struct fman_port *fman_port_bind(struct device *dev);
 
 #endif /* __FMAN_PORT_H */
-- 
2.1.0
