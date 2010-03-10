From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/4] smsc75xx: add RX checksum offload
Date: Wed, 10 Mar 2010 18:26:55 +0000
Message-ID: <1268245617-13698-3-git-send-email-steve.glendinning@smsc.com>
References: <1268245617-13698-1-git-send-email-steve.glendinning@smsc.com>
 <1268245617-13698-2-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:48054 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932171Ab0CJS1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:27:08 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 76B8D67E43
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:26:57 +0000 (GMT)
In-Reply-To: <1268245617-13698-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc75xx.c |   77 ++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index ffb8d25..73f6d78 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -40,6 +40,7 @@
 #define MAX_SINGLE_PACKET_SIZE		(9000)
 #define LAN75XX_EEPROM_MAGIC		(0x7500)
 #define EEPROM_MAC_OFFSET		(0x01)
+#define DEFAULT_RX_CSUM_ENABLE		(true)
 #define SMSC75XX_INTERNAL_PHY_ID	(1)
 #define SMSC75XX_TX_OVERHEAD		(8)
 #define MAX_RX_FIFO_SIZE		(20 * 1024)
@@ -61,6 +62,7 @@ struct smsc75xx_priv {
 	struct usbnet *dev;
 	u32 rfe_ctl;
 	u32 multicast_hash_table[DP_SEL_VHF_HASH_LEN];
+	bool use_rx_csum;
 	struct mutex dataport_mutex;
 	spinlock_t rfe_ctl_lock;
 	struct work_struct set_multicast;
@@ -543,6 +545,28 @@ static void smsc75xx_status(struct usbnet *dev, struct urb *urb)
 			"unexpected interrupt, intdata=0x%08X", intdata);
 }
 
+/* Enable or disable Rx checksum offload engine */
+static int smsc75xx_set_rx_csum_offload(struct usbnet *dev)
+{
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&pdata->rfe_ctl_lock, flags);
+
+	if (pdata->use_rx_csum)
+		pdata->rfe_ctl |= RFE_CTL_TCPUDP_CKM | RFE_CTL_IP_CKM;
+	else
+		pdata->rfe_ctl &= ~(RFE_CTL_TCPUDP_CKM | RFE_CTL_IP_CKM);
+
+	spin_unlock_irqrestore(&pdata->rfe_ctl_lock, flags);
+
+	ret = smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
+	check_warn_return(ret, "Error writing RFE_CTL");
+
+	return 0;
+}
+
 static int smsc75xx_ethtool_get_eeprom_len(struct net_device *net)
 {
 	return MAX_EEPROM_SIZE;
@@ -572,6 +596,24 @@ static int smsc75xx_ethtool_set_eeprom(struct net_device *netdev,
 	return smsc75xx_write_eeprom(dev, ee->offset, ee->len, data);
 }
 
+static u32 smsc75xx_ethtool_get_rx_csum(struct net_device *netdev)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+
+	return pdata->use_rx_csum;
+}
+
+static int smsc75xx_ethtool_set_rx_csum(struct net_device *netdev, u32 val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+
+	pdata->use_rx_csum = !!val;
+
+	return smsc75xx_set_rx_csum_offload(dev);
+}
+
 static const struct ethtool_ops smsc75xx_ethtool_ops = {
 	.get_link	= usbnet_get_link,
 	.nway_reset	= usbnet_nway_reset,
@@ -583,6 +625,8 @@ static const struct ethtool_ops smsc75xx_ethtool_ops = {
 	.get_eeprom_len	= smsc75xx_ethtool_get_eeprom_len,
 	.get_eeprom	= smsc75xx_ethtool_get_eeprom,
 	.set_eeprom	= smsc75xx_ethtool_set_eeprom,
+	.get_rx_csum	= smsc75xx_ethtool_get_rx_csum,
+	.set_rx_csum	= smsc75xx_ethtool_set_rx_csum,
 };
 
 static int smsc75xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
@@ -898,6 +942,10 @@ static int smsc75xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "RFE_CTL set to 0x%08x", pdata->rfe_ctl);
 
+	/* Enable or disable checksum offload engines */
+	ret = smsc75xx_set_rx_csum_offload(dev);
+	check_warn_return(ret, "Failed to set rx csum offload: %d", ret);
+
 	smsc75xx_set_multicast(dev->net);
 
 	ret = smsc75xx_phy_initialize(dev);
@@ -997,6 +1045,8 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	INIT_WORK(&pdata->set_multicast, smsc75xx_deferred_multicast_write);
 
+	pdata->use_rx_csum = DEFAULT_RX_CSUM_ENABLE;
+
 	/* Init all registers */
 	ret = smsc75xx_reset(dev);
 
@@ -1018,8 +1068,21 @@ static void smsc75xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 	}
 }
 
+static void smsc75xx_rx_csum_offload(struct sk_buff *skb, u32 rx_cmd_a,
+				     u32 rx_cmd_b)
+{
+	if (unlikely(rx_cmd_a & RX_CMD_A_LCSM)) {
+		skb->ip_summed = CHECKSUM_NONE;
+	} else {
+		skb->csum = ntohs((u16)(rx_cmd_b >> RX_CMD_B_CSUM_SHIFT));
+		skb->ip_summed = CHECKSUM_COMPLETE;
+	}
+}
+
 static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+
 	while (skb->len > 0) {
 		u32 rx_cmd_a, rx_cmd_b, align_count, size;
 		struct sk_buff *ax_skb;
@@ -1059,7 +1122,12 @@ static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 			/* last frame in this batch */
 			if (skb->len == size) {
-				skb->ip_summed = CHECKSUM_NONE;
+				if (pdata->use_rx_csum)
+					smsc75xx_rx_csum_offload(skb, rx_cmd_a,
+						rx_cmd_b);
+				else
+					skb->ip_summed = CHECKSUM_NONE;
+
 				skb_trim(skb, skb->len - 4); /* remove fcs */
 				skb->truesize = size + sizeof(struct sk_buff);
 
@@ -1076,7 +1144,12 @@ static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			ax_skb->data = packet;
 			skb_set_tail_pointer(ax_skb, size);
 
-			ax_skb->ip_summed = CHECKSUM_NONE;
+			if (pdata->use_rx_csum)
+				smsc75xx_rx_csum_offload(ax_skb, rx_cmd_a,
+					rx_cmd_b);
+			else
+				ax_skb->ip_summed = CHECKSUM_NONE;
+
 			skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
 			ax_skb->truesize = size + sizeof(struct sk_buff);
 
-- 
1.6.6.1

