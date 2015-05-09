From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2] net: fec: add support of ethtool get_regs
Date: Sat,  9 May 2015 23:56:35 +0200
Message-ID: <1431208595-7301-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, B38611@freescale.com,
	rmk+kernel@arm.linux.org.uk, Frank.Li@freescale.com,
	LW@KARO-electronics.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38123 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbbEIV4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:56:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables the ethtool's "-d" and "--register-dump"
options for fec devices.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

Changelog:
v2: (thanks Russell King and David Miler for the feedback)
- don't use memcpy_fromio to copy registers

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 66d47e4..5875913 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2118,6 +2118,32 @@ static void fec_enet_get_drvinfo(struct net_device *ndev,
 	strlcpy(info->bus_info, dev_name(&ndev->dev), sizeof(info->bus_info));
 }
 
+static int fec_enet_get_regs_len(struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct resource *r;
+	int s = 0;
+
+	r = platform_get_resource(fep->pdev, IORESOURCE_MEM, 0);
+	if (r) {
+		s = resource_size(r);
+	}
+
+	return s;
+}
+
+static void fec_enet_get_regs(struct net_device *ndev,
+			      struct ethtool_regs *regs, void *regbuf)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	u32 __iomem *theregs = (u32 __iomem *) fep->hwp;
+	u32 *buf = (u32 *)regbuf;
+	int i;
+
+	for (i = 0; i < regs->len / sizeof(u32); i++)
+		buf[i] = readl(&theregs[i]);
+}
+
 static int fec_enet_get_ts_info(struct net_device *ndev,
 				struct ethtool_ts_info *info)
 {
@@ -2515,6 +2541,8 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
+	.get_regs_len		= fec_enet_get_regs_len,
+	.get_regs		= fec_enet_get_regs,
 	.nway_reset		= fec_enet_nway_reset,
 	.get_link		= ethtool_op_get_link,
 	.get_coalesce		= fec_enet_get_coalesce,
-- 
1.7.4.4
