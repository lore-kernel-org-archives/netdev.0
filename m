From: "Jens Renner (EFE)" <renner@efe-gmbh.de>
Subject: [PATCH] net: ethernet: xilinx_emaclite: keep protocol selector bits
 by reading ANAR
Date: Tue, 28 May 2013 18:10:38 +0200
Message-ID: <51A4D6FE.3080308@efe-gmbh.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:64896 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934694Ab3E1QK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 12:10:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reads the PHY's MII_ADVERTISE register (ANAR) before modifying it.
Hence, the protocol selector bits (4:0) which indicate IEEE 803.3u support are
prevented from being cleared. While the selector bits are fixed / read-only on
some PHYs, not setting them correctly on others (like TI DP83630) makes the
PHY fall back to 10/half mode which should be avoided.

Signed-off-by: Jens Renner <renner@efe-gmbh.de>
---
drivers/net/ethernet/xilinx/xilinx_emaclite.c               |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 919b983..4a67af1 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -922,7 +922,7 @@ void xemaclite_adjust_link(struct net_device *ndev)
 static int xemaclite_open(struct net_device *dev)
 {
        struct net_local *lp = netdev_priv(dev);
-       int retval;
+       int retval, adv;

        /* Just to be safe, stop the device first */
        xemaclite_disable_interrupts(lp);
@@ -946,7 +946,10 @@ static int xemaclite_open(struct net_device *dev)
                phy_write(lp->phy_dev, MII_CTRL1000, 0);

                /* Advertise only 10 and 100mbps full/half duplex speeds */
-               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL);
+               adv = phy_read(lp->phy_dev, MII_ADVERTISE);
+               if (adv < 0)
+                       return adv;
+               phy_write(lp->phy_dev, MII_ADVERTISE, adv | ADVERTISE_ALL);

                /* Restart auto negotiation */
                bmcr = phy_read(lp->phy_dev, MII_BMCR);
