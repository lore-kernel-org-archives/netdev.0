From: Marc Zyngier <marc.zyngier@arm.com>
Subject: [PATCH] net: sun4i-emac: add promiscuous support
Date: Fri, 11 Apr 2014 10:46:17 +0100
Message-ID: <1397209577-24443-1-git-send-email-marc.zyngier@arm.com>
Cc: Stefan Roese <sr@denx.de>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: linux-sunxi@googlegroups.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw-tnat.austin.arm.com ([217.140.110.23]:53484 "EHLO
	collaborate-mta1.arm.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755998AbaDKJqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 05:46:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sun4i-emac driver is rather primitive, and doesn't support
promiscuous mode. This makes usage such as bridging impossible,
which is a shame on virtualization capable HW such as the
Allwinner A20.

The fix is fairly simple: move the RX setup code to the ndo_set_rx_mode
vector, and add the required HW configuration when IFF_PROMISC is passed
by the core code.

This has been tested on a generic A20 box running a few virtual
machines hanging off a bridge with the EMAC chip as the link to the
outside world.

Cc: Stefan Roese <sr@denx.de>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
Signed-off-by: Marc Zyngier <marc.zyngier@arm.com>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c | 30 ++++++++++++++++++++---------
 1 file changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 511f6ee..6343beb 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -268,15 +268,6 @@ static unsigned int emac_setup(struct net_device *ndev)
 	writel(reg_val | EMAC_TX_MODE_ABORTED_FRAME_EN,
 		db->membase + EMAC_TX_MODE_REG);
 
-	/* set up RX */
-	reg_val = readl(db->membase + EMAC_RX_CTL_REG);
-
-	writel(reg_val | EMAC_RX_CTL_PASS_LEN_OOR_EN |
-		EMAC_RX_CTL_ACCEPT_UNICAST_EN | EMAC_RX_CTL_DA_FILTER_EN |
-		EMAC_RX_CTL_ACCEPT_MULTICAST_EN |
-		EMAC_RX_CTL_ACCEPT_BROADCAST_EN,
-		db->membase + EMAC_RX_CTL_REG);
-
 	/* set MAC */
 	/* set MAC CTL0 */
 	reg_val = readl(db->membase + EMAC_MAC_CTL0_REG);
@@ -309,6 +300,26 @@ static unsigned int emac_setup(struct net_device *ndev)
 	return 0;
 }
 
+static void emac_set_rx_mode(struct net_device *ndev)
+{
+	struct emac_board_info *db = netdev_priv(ndev);
+	unsigned int reg_val;
+
+	/* set up RX */
+	reg_val = readl(db->membase + EMAC_RX_CTL_REG);
+
+	if (ndev->flags & IFF_PROMISC)
+		reg_val |= EMAC_RX_CTL_PASS_ALL_EN;
+	else
+		reg_val &= ~EMAC_RX_CTL_PASS_ALL_EN;
+
+	writel(reg_val | EMAC_RX_CTL_PASS_LEN_OOR_EN |
+		EMAC_RX_CTL_ACCEPT_UNICAST_EN | EMAC_RX_CTL_DA_FILTER_EN |
+		EMAC_RX_CTL_ACCEPT_MULTICAST_EN |
+		EMAC_RX_CTL_ACCEPT_BROADCAST_EN,
+		db->membase + EMAC_RX_CTL_REG);
+}
+
 static unsigned int emac_powerup(struct net_device *ndev)
 {
 	struct emac_board_info *db = netdev_priv(ndev);
@@ -782,6 +793,7 @@ static const struct net_device_ops emac_netdev_ops = {
 	.ndo_stop		= emac_stop,
 	.ndo_start_xmit		= emac_start_xmit,
 	.ndo_tx_timeout		= emac_timeout,
+	.ndo_set_rx_mode	= emac_set_rx_mode,
 	.ndo_do_ioctl		= emac_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
-- 
1.8.3.4
