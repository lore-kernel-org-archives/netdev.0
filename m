From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 2/3] tg3: make it possible to provide phy_id in ioctl
Date: Wed,  6 Feb 2013 23:46:07 +0100
Message-ID: <1360190768-390-3-git-send-email-hauke@hauke-m.de>
References: <1360190768-390-1-git-send-email-hauke@hauke-m.de>
Cc: mcarlson@broadcom.com, mchan@broadcom.com, nsujir@broadcom.com,
	netdev@vger.kernel.org, m@bues.ch,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:36073 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756368Ab3BFWqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 17:46:30 -0500
In-Reply-To: <1360190768-390-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In OpenWrt we currently use a switch driver which uses the ioctls to
configure the switch in the phy. We have to provide the phy_id to do
so, but without this patch this is not possible.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/tg3.c |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 90195e3..d9e81d6 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1091,7 +1091,8 @@ static void tg3_switch_clocks(struct tg3 *tp)
 
 #define PHY_BUSY_LOOPS	5000
 
-static int tg3_readphy(struct tg3 *tp, int reg, u32 *val)
+static int __tg3_readphy(struct tg3 *tp, unsigned int phy_addr, int reg,
+			 u32 *val)
 {
 	u32 frame_val;
 	unsigned int loops;
@@ -1107,7 +1108,7 @@ static int tg3_readphy(struct tg3 *tp, int reg, u32 *val)
 
 	*val = 0x0;
 
-	frame_val  = ((tp->phy_addr << MI_COM_PHY_ADDR_SHIFT) &
+	frame_val  = ((phy_addr << MI_COM_PHY_ADDR_SHIFT) &
 		      MI_COM_PHY_ADDR_MASK);
 	frame_val |= ((reg << MI_COM_REG_ADDR_SHIFT) &
 		      MI_COM_REG_ADDR_MASK);
@@ -1144,7 +1145,13 @@ static int tg3_readphy(struct tg3 *tp, int reg, u32 *val)
 	return ret;
 }
 
-static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
+static int tg3_readphy(struct tg3 *tp, int reg, u32 *val)
+{
+	return __tg3_readphy(tp, tp->phy_addr, reg, val);
+}
+
+static int __tg3_writephy(struct tg3 *tp, unsigned int phy_addr, int reg,
+			  u32 val)
 {
 	u32 frame_val;
 	unsigned int loops;
@@ -1162,7 +1169,7 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 
 	tg3_ape_lock(tp, tp->phy_ape_lock);
 
-	frame_val  = ((tp->phy_addr << MI_COM_PHY_ADDR_SHIFT) &
+	frame_val  = ((phy_addr << MI_COM_PHY_ADDR_SHIFT) &
 		      MI_COM_PHY_ADDR_MASK);
 	frame_val |= ((reg << MI_COM_REG_ADDR_SHIFT) &
 		      MI_COM_REG_ADDR_MASK);
@@ -1197,6 +1204,11 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 	return ret;
 }
 
+static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
+{
+	return __tg3_writephy(tp, tp->phy_addr, reg, val);
+}
+
 static int tg3_phy_cl45_write(struct tg3 *tp, u32 devad, u32 addr, u32 val)
 {
 	int err;
@@ -12969,7 +12981,8 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -EAGAIN;
 
 		spin_lock_bh(&tp->lock);
-		err = tg3_readphy(tp, data->reg_num & 0x1f, &mii_regval);
+		err = __tg3_readphy(tp, data->phy_id & 0x1f,
+				    data->reg_num & 0x1f, &mii_regval);
 		spin_unlock_bh(&tp->lock);
 
 		data->val_out = mii_regval;
@@ -12985,7 +12998,8 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -EAGAIN;
 
 		spin_lock_bh(&tp->lock);
-		err = tg3_writephy(tp, data->reg_num & 0x1f, data->val_in);
+		err = __tg3_writephy(tp, data->phy_id & 0x1f,
+				     data->reg_num & 0x1f, data->val_in);
 		spin_unlock_bh(&tp->lock);
 
 		return err;
-- 
1.7.10.4
