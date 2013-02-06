From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 2/4] bgmac: write mac address to hardware in ndo_set_mac_address
Date: Wed,  6 Feb 2013 15:44:58 +0100
Message-ID: <1360161900-2330-3-git-send-email-hauke@hauke-m.de>
References: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:34663 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754131Ab3BFOpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 09:45:18 -0500
In-Reply-To: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The generic implementation just changes the netdev struct and does not
write the new mac address to the hardware or issues some command to do
so.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |   33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 58e0c70..c0152396 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -761,6 +761,16 @@ static void bgmac_cmdcfg_maskset(struct bgmac *bgmac, u32 mask, u32 set,
 	udelay(2);
 }
 
+static void bgmac_write_mac_address(struct bgmac *bgmac, u8 *addr)
+{
+	u32 tmp;
+
+	tmp = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) | addr[3];
+	bgmac_write(bgmac, BGMAC_MACADDR_HIGH, tmp);
+	tmp = (addr[4] << 8) | addr[5];
+	bgmac_write(bgmac, BGMAC_MACADDR_LOW, tmp);
+}
+
 #if 0 /* We don't use that regs yet */
 static void bgmac_chip_stats_update(struct bgmac *bgmac)
 {
@@ -1006,8 +1016,6 @@ static void bgmac_enable(struct bgmac *bgmac)
 static void bgmac_chip_init(struct bgmac *bgmac, bool full_init)
 {
 	struct bgmac_dma_ring *ring;
-	u8 *mac = bgmac->net_dev->dev_addr;
-	u32 tmp;
 	int i;
 
 	/* 1 interrupt per received frame */
@@ -1021,11 +1029,7 @@ static void bgmac_chip_init(struct bgmac *bgmac, bool full_init)
 	else
 		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, false);
 
-	/* Set MAC addr */
-	tmp = (mac[0] << 24) | (mac[1] << 16) | (mac[2] << 8) | mac[3];
-	bgmac_write(bgmac, BGMAC_MACADDR_HIGH, tmp);
-	tmp = (mac[4] << 8) | mac[5];
-	bgmac_write(bgmac, BGMAC_MACADDR_LOW, tmp);
+	bgmac_write_mac_address(bgmac, bgmac->net_dev->dev_addr);
 
 	if (bgmac->loopback)
 		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_ML, true);
@@ -1162,6 +1166,19 @@ static netdev_tx_t bgmac_start_xmit(struct sk_buff *skb,
 	return bgmac_dma_tx_add(bgmac, ring, skb);
 }
 
+static int bgmac_set_mac_address(struct net_device *net_dev, void *addr)
+{
+	struct bgmac *bgmac = netdev_priv(net_dev);
+	int ret;
+
+	ret = eth_prepare_mac_addr_change(net_dev, addr);
+	if (ret < 0)
+		return ret;
+	bgmac_write_mac_address(bgmac, (u8 *)addr);
+	eth_commit_mac_addr_change(net_dev, addr);
+	return 0;
+}
+
 static int bgmac_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
 {
 	struct bgmac *bgmac = netdev_priv(net_dev);
@@ -1192,7 +1209,7 @@ static const struct net_device_ops bgmac_netdev_ops = {
 	.ndo_open		= bgmac_open,
 	.ndo_stop		= bgmac_stop,
 	.ndo_start_xmit		= bgmac_start_xmit,
-	.ndo_set_mac_address	= eth_mac_addr, /* generic, sets dev_addr */
+	.ndo_set_mac_address	= bgmac_set_mac_address,
 	.ndo_do_ioctl           = bgmac_ioctl,
 };
 
-- 
1.7.10.4
