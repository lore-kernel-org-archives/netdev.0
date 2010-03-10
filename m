From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 3/4] smsc75xx: add TX checksum offload
Date: Wed, 10 Mar 2010 18:26:56 +0000
Message-ID: <1268245617-13698-4-git-send-email-steve.glendinning@smsc.com>
References: <1268245617-13698-1-git-send-email-steve.glendinning@smsc.com>
 <1268245617-13698-2-git-send-email-steve.glendinning@smsc.com>
 <1268245617-13698-3-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:48054 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932190Ab0CJS1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:27:09 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 8366267E44
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:26:57 +0000 (GMT)
In-Reply-To: <1268245617-13698-3-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc75xx.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 73f6d78..8841643 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -40,6 +40,7 @@
 #define MAX_SINGLE_PACKET_SIZE		(9000)
 #define LAN75XX_EEPROM_MAGIC		(0x7500)
 #define EEPROM_MAC_OFFSET		(0x01)
+#define DEFAULT_TX_CSUM_ENABLE		(true)
 #define DEFAULT_RX_CSUM_ENABLE		(true)
 #define SMSC75XX_INTERNAL_PHY_ID	(1)
 #define SMSC75XX_TX_OVERHEAD		(8)
@@ -625,6 +626,8 @@ static const struct ethtool_ops smsc75xx_ethtool_ops = {
 	.get_eeprom_len	= smsc75xx_ethtool_get_eeprom_len,
 	.get_eeprom	= smsc75xx_ethtool_get_eeprom,
 	.set_eeprom	= smsc75xx_ethtool_set_eeprom,
+	.get_tx_csum	= ethtool_op_get_tx_csum,
+	.set_tx_csum	= ethtool_op_set_tx_hw_csum,
 	.get_rx_csum	= smsc75xx_ethtool_get_rx_csum,
 	.set_rx_csum	= smsc75xx_ethtool_set_rx_csum,
 };
@@ -943,6 +946,7 @@ static int smsc75xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net, "RFE_CTL set to 0x%08x", pdata->rfe_ctl);
 
 	/* Enable or disable checksum offload engines */
+	ethtool_op_set_tx_hw_csum(dev->net, DEFAULT_TX_CSUM_ENABLE);
 	ret = smsc75xx_set_rx_csum_offload(dev);
 	check_warn_return(ret, "Failed to set rx csum offload: %d", ret);
 
@@ -1190,6 +1194,9 @@ static struct sk_buff *smsc75xx_tx_fixup(struct usbnet *dev,
 
 	tx_cmd_a = (u32)(skb->len & TX_CMD_A_LEN) | TX_CMD_A_FCS;
 
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		tx_cmd_a |= TX_CMD_A_IPE | TX_CMD_A_TPE;
+
 	tx_cmd_b = 0;
 
 	skb_push(skb, 4);
-- 
1.6.6.1

