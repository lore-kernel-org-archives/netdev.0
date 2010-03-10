From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 4/4] smsc75xx: add TX segmentation offload support
Date: Wed, 10 Mar 2010 18:26:57 +0000
Message-ID: <1268245617-13698-5-git-send-email-steve.glendinning@smsc.com>
References: <1268245617-13698-1-git-send-email-steve.glendinning@smsc.com>
 <1268245617-13698-2-git-send-email-steve.glendinning@smsc.com>
 <1268245617-13698-3-git-send-email-steve.glendinning@smsc.com>
 <1268245617-13698-4-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:48054 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932417Ab0CJS1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:27:10 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 8791667E45
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:26:57 +0000 (GMT)
In-Reply-To: <1268245617-13698-4-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc75xx.c |   30 +++++++++++++++++++++++++++---
 1 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 8841643..300e3e7 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -42,6 +42,7 @@
 #define EEPROM_MAC_OFFSET		(0x01)
 #define DEFAULT_TX_CSUM_ENABLE		(true)
 #define DEFAULT_RX_CSUM_ENABLE		(true)
+#define DEFAULT_TSO_ENABLE		(true)
 #define SMSC75XX_INTERNAL_PHY_ID	(1)
 #define SMSC75XX_TX_OVERHEAD		(8)
 #define MAX_RX_FIFO_SIZE		(20 * 1024)
@@ -615,6 +616,16 @@ static int smsc75xx_ethtool_set_rx_csum(struct net_device *netdev, u32 val)
 	return smsc75xx_set_rx_csum_offload(dev);
 }
 
+static int smsc75xx_ethtool_set_tso(struct net_device *netdev, u32 data)
+{
+	if (data)
+		netdev->features |= NETIF_F_TSO | NETIF_F_TSO6;
+	else
+		netdev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+
+	return 0;
+}
+
 static const struct ethtool_ops smsc75xx_ethtool_ops = {
 	.get_link	= usbnet_get_link,
 	.nway_reset	= usbnet_nway_reset,
@@ -630,6 +641,8 @@ static const struct ethtool_ops smsc75xx_ethtool_ops = {
 	.set_tx_csum	= ethtool_op_set_tx_hw_csum,
 	.get_rx_csum	= smsc75xx_ethtool_get_rx_csum,
 	.set_rx_csum	= smsc75xx_ethtool_set_rx_csum,
+	.get_tso	= ethtool_op_get_tso,
+	.set_tso	= smsc75xx_ethtool_set_tso,
 };
 
 static int smsc75xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
@@ -950,6 +963,8 @@ static int smsc75xx_reset(struct usbnet *dev)
 	ret = smsc75xx_set_rx_csum_offload(dev);
 	check_warn_return(ret, "Failed to set rx csum offload: %d", ret);
 
+	smsc75xx_ethtool_set_tso(dev->net, DEFAULT_TSO_ENABLE);
+
 	smsc75xx_set_multicast(dev->net);
 
 	ret = smsc75xx_phy_initialize(dev);
@@ -1051,6 +1066,9 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	pdata->use_rx_csum = DEFAULT_RX_CSUM_ENABLE;
 
+	/* We have to advertise SG otherwise TSO cannot be enabled */
+	dev->net->features |= NETIF_F_SG;
+
 	/* Init all registers */
 	ret = smsc75xx_reset(dev);
 
@@ -1180,8 +1198,7 @@ static struct sk_buff *smsc75xx_tx_fixup(struct usbnet *dev,
 {
 	u32 tx_cmd_a, tx_cmd_b;
 
-	/* We do not advertise SG, so skbs should be already linearized */
-	BUG_ON(skb_shinfo(skb)->nr_frags);
+	skb_linearize(skb);
 
 	if (skb_headroom(skb) < SMSC75XX_TX_OVERHEAD) {
 		struct sk_buff *skb2 =
@@ -1197,7 +1214,14 @@ static struct sk_buff *smsc75xx_tx_fixup(struct usbnet *dev,
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		tx_cmd_a |= TX_CMD_A_IPE | TX_CMD_A_TPE;
 
-	tx_cmd_b = 0;
+	if (skb_is_gso(skb)) {
+		u16 mss = max(skb_shinfo(skb)->gso_size, TX_MSS_MIN);
+		tx_cmd_b = (mss << TX_CMD_B_MSS_SHIFT) & TX_CMD_B_MSS;
+
+		tx_cmd_a |= TX_CMD_A_LSO;
+	} else {
+		tx_cmd_b = 0;
+	}
 
 	skb_push(skb, 4);
 	cpu_to_le32s(&tx_cmd_b);
-- 
1.6.6.1

