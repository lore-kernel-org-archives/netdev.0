From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: systemport: Add support for switch tag HW extraction
Date: Wed, 29 Jul 2015 15:32:40 -0700
Message-ID: <1438209160-6898-4-git-send-email-f.fainelli@gmail.com>
References: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Broadcom SYSTEMPORT Ethernet controller is capable of extracting a
switch tag (4-bytes Broadcom tag) and put it in the second 32-bits word
of its pre-pended Receive Status Block. When this feature is requested,
make sure that we can satisfy it by turning on receive checksum offload,
and copy the 32-bits words with the tag into skb->cb[] using the
appropriate helper function: dsa_copy_brcm_tag().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 40 +++++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bcmsysport.h |  1 +
 2 files changed, 40 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 4566cdf0bc39..a3db2d9f1c36 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -173,6 +173,23 @@ static int bcm_sysport_set_tx_csum(struct net_device *dev,
 	return 0;
 }
 
+static int bcm_sysport_set_rx_sw_tag(struct net_device *dev,
+				     netdev_features_t wanted)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	u32 reg;
+
+	priv->rx_tag_extract = !!(wanted & NETIF_F_HW_SWITCH_TAG_RX);
+	reg = rbuf_readl(priv, RBUF_CONTROL);
+	if (priv->rx_tag_extract)
+		reg |= RBUF_BRCM_TAG_STRIP;
+	else
+		reg &= ~RBUF_BRCM_TAG_STRIP;
+	rbuf_writel(priv, reg, RBUF_CONTROL);
+
+	return 0;
+}
+
 static int bcm_sysport_set_features(struct net_device *dev,
 				    netdev_features_t features)
 {
@@ -184,10 +201,25 @@ static int bcm_sysport_set_features(struct net_device *dev,
 		ret = bcm_sysport_set_rx_csum(dev, wanted);
 	if (changed & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
 		ret = bcm_sysport_set_tx_csum(dev, wanted);
+	if (changed & NETIF_F_HW_SWITCH_TAG_RX)
+		ret = bcm_sysport_set_rx_sw_tag(dev, wanted);
 
 	return ret;
 }
 
+static netdev_features_t bcm_sysport_fix_features(struct net_device *dev,
+						  netdev_features_t features)
+{
+	/* In order for the switch tag extraction to work, we need to turn on
+	 * the RXCHK block and enable receive checksum offload, do this here to
+	 * satisfy the feature request.
+	 */
+	if (features & NETIF_F_HW_SWITCH_TAG_RX)
+		features |= NETIF_F_RXCSUM;
+
+	return features;
+}
+
 /* Hardware counters must be kept in sync because the order/offset
  * is important here (order in structure declaration = order in hardware)
  */
@@ -670,6 +702,10 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 		if (likely(status & DESC_L4_CSUM))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+		/* Extract the switch egress tag */
+		if (likely(priv->rx_tag_extract))
+			dsa_copy_brcm_tag(skb, &rsb->brcm_egress_tag);
+
 		/* Hardware pre-pends packets with 2bytes before Ethernet
 		 * header plus we have the Receive Status Block, strip off all
 		 * of this from the SKB.
@@ -1721,6 +1757,7 @@ static const struct net_device_ops bcm_sysport_netdev_ops = {
 	.ndo_open		= bcm_sysport_open,
 	.ndo_stop		= bcm_sysport_stop,
 	.ndo_set_features	= bcm_sysport_set_features,
+	.ndo_fix_features	= bcm_sysport_fix_features,
 	.ndo_set_rx_mode	= bcm_sysport_set_rx_mode,
 	.ndo_set_mac_address	= bcm_sysport_change_mac,
 };
@@ -1806,7 +1843,8 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 
 	/* HW supported features, none enabled by default */
 	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_HIGHDMA |
-				NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+				NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+				NETIF_F_HW_SWITCH_TAG_RX;
 
 	/* Request the WOL interrupt and advertise suspend if available */
 	priv->wol_irq_disabled = 1;
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index f28bf545d7f4..6d925401d706 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -680,6 +680,7 @@ struct bcm_sysport_priv {
 	unsigned int		rx_chk_en:1;
 	unsigned int		tsb_en:1;
 	unsigned int		crc_fwd:1;
+	unsigned int		rx_tag_extract:1;
 	u16			rev;
 	u32			wolopts;
 	unsigned int		wol_irq_disabled:1;
-- 
2.1.0
