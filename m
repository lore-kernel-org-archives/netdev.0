From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 07/15] tg3: Move phylib report to end of tg3_init_one
Date: Mon, 3 Nov 2008 02:12:47 -0800
Message-ID: <1225751623.6184@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4898 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697AbYKCWd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, phylib reports appear with a eth%d prefix.  Move the line
after register_netdev() and place it alongside the other informative
messages.  Update nearby informative messages accordingly.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   30 +++++++++++++++++-------------
 1 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 978d1f0..aebc645 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1360,10 +1360,6 @@ static int tg3_phy_init(struct tg3 *tp)
 
 	phydev->advertising = phydev->supported;
 
-	printk(KERN_INFO
-	       "%s: attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
-	       tp->dev->name, phydev->drv->name, phydev->dev.bus_id);
-
 	return 0;
 }
 
@@ -13547,26 +13543,34 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_apeunmap;
 	}
 
-	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] "
-	       "(%s) %s Ethernet %pM\n",
+	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x] (%s) MAC address %pM\n",
 	       dev->name,
 	       tp->board_part_number,
 	       tp->pci_chip_rev_id,
-	       tg3_phy_string(tp),
 	       tg3_bus_string(tp, str),
-	       ((tp->tg3_flags & TG3_FLAG_10_100_ONLY) ? "10/100Base-TX" :
-		((tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) ? "1000Base-SX" :
-		 "10/100/1000Base-T")),
 	       dev->dev_addr);
 
-	printk(KERN_INFO "%s: RXcsums[%d] LinkChgREG[%d] "
-	       "MIirq[%d] ASF[%d] WireSpeed[%d] TSOcap[%d]\n",
+	if (tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED)
+		printk(KERN_INFO
+		       "%s: attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
+		       tp->dev->name,
+		       tp->mdio_bus->phy_map[PHY_ADDR]->drv->name,
+		       tp->mdio_bus->phy_map[PHY_ADDR]->dev.bus_id);
+	else
+		printk(KERN_INFO
+		       "%s: attached PHY is %s (%s Ethernet) (WireSpeed[%d])\n",
+		       tp->dev->name, tg3_phy_string(tp),
+		       ((tp->tg3_flags & TG3_FLAG_10_100_ONLY) ? "10/100Base-TX" :
+			((tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) ? "1000Base-SX" :
+			 "10/100/1000Base-T")),
+		       (tp->tg3_flags2 & TG3_FLG2_NO_ETH_WIRE_SPEED) == 0);
+
+	printk(KERN_INFO "%s: RXcsums[%d] LinkChgREG[%d] MIirq[%d] ASF[%d] TSOcap[%d]\n",
 	       dev->name,
 	       (tp->tg3_flags & TG3_FLAG_RX_CHECKSUMS) != 0,
 	       (tp->tg3_flags & TG3_FLAG_USE_LINKCHG_REG) != 0,
 	       (tp->tg3_flags & TG3_FLAG_USE_MI_INTERRUPT) != 0,
 	       (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0,
-	       (tp->tg3_flags2 & TG3_FLG2_NO_ETH_WIRE_SPEED) == 0,
 	       (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) != 0);
 	printk(KERN_INFO "%s: dma_rwctrl[%08x] dma_mask[%d-bit]\n",
 	       dev->name, tp->dma_rwctrl,
-- 
1.5.6.4



