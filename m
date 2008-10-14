From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: add tx checksum offload support
Date: Tue, 14 Oct 2008 16:17:49 +0100
Message-ID: <1223997469-5192-1-git-send-email-steve.glendinning@smsc.com>
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Jeff Garzik <jeff@garzik.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:59424 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751518AbYJNPRv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 11:17:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LAN9500 supports tx checksum offload, which slightly decreases cpu
utilisation.  The benefit isn't very large because we still require
the skb to be linearized, but it does save a few cycles.

This patch adds support for it, and enables it by default.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   75 ++++++++++++++++++++++++++++++++++++++------
 1 files changed, 65 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 51e2f5d..202979d 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -31,7 +31,7 @@
 #include "smsc95xx.h"
 
 #define SMSC_CHIPNAME			"smsc95xx"
-#define SMSC_DRIVER_VERSION		"1.0.3"
+#define SMSC_DRIVER_VERSION		"1.0.4"
 #define HS_USB_PKT_SIZE			(512)
 #define FS_USB_PKT_SIZE			(64)
 #define DEFAULT_HS_BURST_CAP_SIZE	(16 * 1024 + 5 * HS_USB_PKT_SIZE)
@@ -40,15 +40,18 @@
 #define MAX_SINGLE_PACKET_SIZE		(2048)
 #define LAN95XX_EEPROM_MAGIC		(0x9500)
 #define EEPROM_MAC_OFFSET		(0x01)
+#define DEFAULT_TX_CSUM_ENABLE		(true)
 #define DEFAULT_RX_CSUM_ENABLE		(true)
 #define SMSC95XX_INTERNAL_PHY_ID	(1)
 #define SMSC95XX_TX_OVERHEAD		(8)
+#define SMSC95XX_TX_OVERHEAD_CSUM	(12)
 #define FLOW_CTRL_TX			(1)
 #define FLOW_CTRL_RX			(2)
 
 struct smsc95xx_priv {
 	u32 mac_cr;
 	spinlock_t mac_cr_lock;
+	bool use_tx_csum;
 	bool use_rx_csum;
 };
 
@@ -556,9 +559,10 @@ static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
 		devwarn(dev, "unexpected interrupt, intdata=0x%08X", intdata);
 }
 
-/* Enable or disable Rx checksum offload engine */
-static int smsc95xx_set_rx_csum(struct usbnet *dev, bool enable)
+/* Enable or disable Tx & Rx checksum offload engines */
+static int smsc95xx_set_csums(struct usbnet *dev)
 {
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	u32 read_buf;
 	int ret = smsc95xx_read_reg(dev, COE_CR, &read_buf);
 	if (ret < 0) {
@@ -566,7 +570,12 @@ static int smsc95xx_set_rx_csum(struct usbnet *dev, bool enable)
 		return ret;
 	}
 
-	if (enable)
+	if (pdata->use_tx_csum)
+		read_buf |= Tx_COE_EN_;
+	else
+		read_buf &= ~Tx_COE_EN_;
+
+	if (pdata->use_rx_csum)
 		read_buf |= Rx_COE_EN_;
 	else
 		read_buf &= ~Rx_COE_EN_;
@@ -626,7 +635,26 @@ static int smsc95xx_ethtool_set_rx_csum(struct net_device *netdev, u32 val)
 
 	pdata->use_rx_csum = !!val;
 
-	return smsc95xx_set_rx_csum(dev, pdata->use_rx_csum);
+	return smsc95xx_set_csums(dev);
+}
+
+static u32 smsc95xx_ethtool_get_tx_csum(struct net_device *netdev)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
+	return pdata->use_tx_csum;
+}
+
+static int smsc95xx_ethtool_set_tx_csum(struct net_device *netdev, u32 val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
+	pdata->use_tx_csum = !!val;
+
+	ethtool_op_set_tx_hw_csum(netdev, pdata->use_tx_csum);
+	return smsc95xx_set_csums(dev);
 }
 
 static struct ethtool_ops smsc95xx_ethtool_ops = {
@@ -640,6 +668,8 @@ static struct ethtool_ops smsc95xx_ethtool_ops = {
 	.get_eeprom_len	= smsc95xx_ethtool_get_eeprom_len,
 	.get_eeprom	= smsc95xx_ethtool_get_eeprom,
 	.set_eeprom	= smsc95xx_ethtool_set_eeprom,
+	.get_tx_csum	= smsc95xx_ethtool_get_tx_csum,
+	.set_tx_csum	= smsc95xx_ethtool_set_tx_csum,
 	.get_rx_csum	= smsc95xx_ethtool_get_rx_csum,
 	.set_rx_csum	= smsc95xx_ethtool_set_rx_csum,
 };
@@ -757,6 +787,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 static int smsc95xx_reset(struct usbnet *dev)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	struct net_device *netdev = dev->net;
 	u32 read_buf, write_buf, burst_cap;
 	int ret = 0, timeout;
 	DECLARE_MAC_BUF(mac);
@@ -970,10 +1001,11 @@ static int smsc95xx_reset(struct usbnet *dev)
 		return ret;
 	}
 
-	/* Enable or disable Rx checksum offload engine */
-	ret = smsc95xx_set_rx_csum(dev, pdata->use_rx_csum);
+	/* Enable or disable checksum offload engines */
+	ethtool_op_set_tx_hw_csum(netdev, pdata->use_tx_csum);
+	ret = smsc95xx_set_csums(dev);
 	if (ret < 0) {
-		devwarn(dev, "Failed to set Rx csum offload: %d", ret);
+		devwarn(dev, "Failed to set csum offload: %d", ret);
 		return ret;
 	}
 
@@ -1029,6 +1061,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	spin_lock_init(&pdata->mac_cr_lock);
 
+	pdata->use_tx_csum = DEFAULT_TX_CSUM_ENABLE;
 	pdata->use_rx_csum = DEFAULT_RX_CSUM_ENABLE;
 
 	/* Init all registers */
@@ -1148,22 +1181,44 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	return 1;
 }
 
+static u32 smsc95xx_calc_csum_preamble(struct sk_buff *skb)
+{
+	int len = skb->data - skb->head;
+	u16 high_16 = (u16)(skb->csum_offset + skb->csum_start - len);
+	u16 low_16 = (u16)(skb->csum_start - len);
+	return (high_16 << 16) | low_16;
+}
+
 static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 					 struct sk_buff *skb, gfp_t flags)
 {
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	bool csum = pdata->use_tx_csum && (skb->ip_summed == CHECKSUM_PARTIAL);
+	int overhead = csum ? SMSC95XX_TX_OVERHEAD_CSUM : SMSC95XX_TX_OVERHEAD;
 	u32 tx_cmd_a, tx_cmd_b;
 
-	if (skb_headroom(skb) < SMSC95XX_TX_OVERHEAD) {
+	/* We do not advertise SG, so skbs should be already linearized */
+	BUG_ON(skb_shinfo(skb)->nr_frags);
+
+	if (skb_headroom(skb) < overhead) {
 		struct sk_buff *skb2 = skb_copy_expand(skb,
-			SMSC95XX_TX_OVERHEAD, 0, flags);
+			overhead, 0, flags);
 		dev_kfree_skb_any(skb);
 		skb = skb2;
 		if (!skb)
 			return NULL;
 	}
 
+	if (csum) {
+		u32 csum_preamble = smsc95xx_calc_csum_preamble(skb);
+		skb_push(skb, 4);
+		memcpy(skb->data, &csum_preamble, 4);
+	}
+
 	skb_push(skb, 4);
 	tx_cmd_b = (u32)(skb->len - 4);
+	if (csum)
+		tx_cmd_b |= TX_CMD_B_CSUM_ENABLE;
 	cpu_to_le32s(&tx_cmd_b);
 	memcpy(skb->data, &tx_cmd_b, 4);
 
-- 
1.5.5.1

