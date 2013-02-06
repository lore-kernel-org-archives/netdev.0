From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 4/4] bgmac: add ndo_set_rx_mode netdev ops
Date: Wed,  6 Feb 2013 16:51:49 +0100
Message-ID: <1360165909-5910-1-git-send-email-hauke@hauke-m.de>
References: <1360161900-2330-5-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:34941 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551Ab3BFPwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 10:52:08 -0500
In-Reply-To: <1360161900-2330-5-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When changing the device from or to promisc mode this only affects the
device after the device is bought up the next time. For bridging it is
needed to change the device to promisc mode while it is up, which is
possible with this patch.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---

v2:
  * Improved comit message

 drivers/net/ethernet/broadcom/bgmac.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index e0775c4..23c8d4a 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -771,6 +771,16 @@ static void bgmac_write_mac_address(struct bgmac *bgmac, u8 *addr)
 	bgmac_write(bgmac, BGMAC_MACADDR_LOW, tmp);
 }
 
+static void bgmac_set_rx_mode(struct net_device *net_dev)
+{
+	struct bgmac *bgmac = netdev_priv(net_dev);
+
+	if (net_dev->flags & IFF_PROMISC)
+		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, false);
+	else
+		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, false);
+}
+
 #if 0 /* We don't use that regs yet */
 static void bgmac_chip_stats_update(struct bgmac *bgmac)
 {
@@ -1024,10 +1034,7 @@ static void bgmac_chip_init(struct bgmac *bgmac, bool full_init)
 	/* Enable 802.3x tx flow control (honor received PAUSE frames) */
 	bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_RPI, 0, true);
 
-	if (bgmac->net_dev->flags & IFF_PROMISC)
-		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, false);
-	else
-		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, false);
+	bgmac_set_rx_mode(bgmac->net_dev);
 
 	bgmac_write_mac_address(bgmac, bgmac->net_dev->dev_addr);
 
@@ -1209,6 +1216,7 @@ static const struct net_device_ops bgmac_netdev_ops = {
 	.ndo_open		= bgmac_open,
 	.ndo_stop		= bgmac_stop,
 	.ndo_start_xmit		= bgmac_start_xmit,
+	.ndo_set_rx_mode	= bgmac_set_rx_mode,
 	.ndo_set_mac_address	= bgmac_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl           = bgmac_ioctl,
-- 
1.7.10.4
