From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 1/8] b44: check register instead of PHY address to detect external PHY
Date: Fri, 20 Dec 2013 02:16:06 +0100
Message-ID: <1387502173-21743-2-git-send-email-hauke@hauke-m.de>
References: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:53937 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756365Ab3LTBQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 20:16:30 -0500
In-Reply-To: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet core supported by b44 supports an internal PHY integrated
into the mac core, which is supported by the b44 driver and an external
PHY to which the mac core is connected. This external PHY could be a
switch connected through MII, which is often the case when this core is
used on home routers. The usage of an external PHY was assumed when the
PHY address 30 was used and an internal PHY was assumed when the PHY
address was different. To verify that b44_phy_reset() was called and
checked if it worked, otherwise PHY address 30 was assumed, an external
PHY. It is better to check the register which says which PHY is
connected to the MAC instead of checking the PHY address.
The interface to an external PHY was only activated when this register
was set.

This also changes B44_FLAG_INTERNAL_PHY to B44_FLAG_EXTERNAL_PHY, it is
easier to check.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |   18 +++++++++---------
 drivers/net/ethernet/broadcom/b44.h |    2 +-
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 90e54d5..3c7909e 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -284,7 +284,7 @@ static int __b44_writephy(struct b44 *bp, int phy_addr, int reg, u32 val)
 
 static inline int b44_readphy(struct b44 *bp, int reg, u32 *val)
 {
-	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY)
+	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
 		return 0;
 
 	return __b44_readphy(bp, bp->phy_addr, reg, val);
@@ -292,7 +292,7 @@ static inline int b44_readphy(struct b44 *bp, int reg, u32 *val)
 
 static inline int b44_writephy(struct b44 *bp, int reg, u32 val)
 {
-	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY)
+	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
 		return 0;
 
 	return __b44_writephy(bp, bp->phy_addr, reg, val);
@@ -321,7 +321,7 @@ static int b44_phy_reset(struct b44 *bp)
 	u32 val;
 	int err;
 
-	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY)
+	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
 		return 0;
 	err = b44_writephy(bp, MII_BMCR, BMCR_RESET);
 	if (err)
@@ -423,7 +423,7 @@ static int b44_setup_phy(struct b44 *bp)
 
 	b44_wap54g10_workaround(bp);
 
-	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY)
+	if (bp->flags & B44_FLAG_EXTERNAL_PHY)
 		return 0;
 	if ((err = b44_readphy(bp, B44_MII_ALEDCTRL, &val)) != 0)
 		goto out;
@@ -521,7 +521,7 @@ static void b44_check_phy(struct b44 *bp)
 {
 	u32 bmsr, aux;
 
-	if (bp->phy_addr == B44_PHY_ADDR_NO_PHY) {
+	if (bp->flags & B44_FLAG_EXTERNAL_PHY) {
 		bp->flags |= B44_FLAG_100_BASE_T;
 		bp->flags |= B44_FLAG_FULL_DUPLEX;
 		if (!netif_carrier_ok(bp->dev)) {
@@ -1315,7 +1315,7 @@ static void b44_chip_reset(struct b44 *bp, int reset_kind)
 	if (!(br32(bp, B44_DEVCTRL) & DEVCTRL_IPP)) {
 		bw32(bp, B44_ENET_CTRL, ENET_CTRL_EPSEL);
 		br32(bp, B44_ENET_CTRL);
-		bp->flags &= ~B44_FLAG_INTERNAL_PHY;
+		bp->flags |= B44_FLAG_EXTERNAL_PHY;
 	} else {
 		u32 val = br32(bp, B44_DEVCTRL);
 
@@ -1324,7 +1324,7 @@ static void b44_chip_reset(struct b44 *bp, int reset_kind)
 			br32(bp, B44_DEVCTRL);
 			udelay(100);
 		}
-		bp->flags |= B44_FLAG_INTERNAL_PHY;
+		bp->flags &= ~B44_FLAG_EXTERNAL_PHY;
 	}
 }
 
@@ -1828,8 +1828,8 @@ static int b44_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		DUPLEX_FULL : DUPLEX_HALF;
 	cmd->port = 0;
 	cmd->phy_address = bp->phy_addr;
-	cmd->transceiver = (bp->flags & B44_FLAG_INTERNAL_PHY) ?
-		XCVR_INTERNAL : XCVR_EXTERNAL;
+	cmd->transceiver = (bp->flags & B44_FLAG_EXTERNAL_PHY) ?
+		XCVR_EXTERNAL : XCVR_INTERNAL;
 	cmd->autoneg = (bp->flags & B44_FLAG_FORCE_LINK) ?
 		AUTONEG_DISABLE : AUTONEG_ENABLE;
 	if (cmd->autoneg == AUTONEG_ENABLE)
diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
index 8993d72..8ed7d6b 100644
--- a/drivers/net/ethernet/broadcom/b44.h
+++ b/drivers/net/ethernet/broadcom/b44.h
@@ -376,7 +376,7 @@ struct b44 {
 #define B44_FLAG_ADV_10FULL	0x02000000
 #define B44_FLAG_ADV_100HALF	0x04000000
 #define B44_FLAG_ADV_100FULL	0x08000000
-#define B44_FLAG_INTERNAL_PHY	0x10000000
+#define B44_FLAG_EXTERNAL_PHY	0x10000000
 #define B44_FLAG_RX_RING_HACK	0x20000000
 #define B44_FLAG_TX_RING_HACK	0x40000000
 #define B44_FLAG_WOL_ENABLE	0x80000000
-- 
1.7.10.4
