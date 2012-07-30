From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net 1/5] tg3: Request APE_LOCK_PHY before PHY access
Date: Sun, 29 Jul 2012 22:15:41 -0700
Message-ID: <1343625345-5155-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2424 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab2G3FDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 01:03:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to prevent PHY access conflict with APE firmware.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   37 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/tg3.h |    1 +
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 9a009fd..a528f9a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -672,6 +672,12 @@ static int tg3_ape_lock(struct tg3 *tp, int locknum)
 		else
 			bit = 1 << tp->pci_fn;
 		break;
+	case TG3_APE_LOCK_PHY0:
+	case TG3_APE_LOCK_PHY1:
+	case TG3_APE_LOCK_PHY2:
+	case TG3_APE_LOCK_PHY3:
+		bit = APE_LOCK_REQ_DRIVER;
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -723,6 +729,12 @@ static void tg3_ape_unlock(struct tg3 *tp, int locknum)
 		else
 			bit = 1 << tp->pci_fn;
 		break;
+	case TG3_APE_LOCK_PHY0:
+	case TG3_APE_LOCK_PHY1:
+	case TG3_APE_LOCK_PHY2:
+	case TG3_APE_LOCK_PHY3:
+		bit = APE_LOCK_GRANT_DRIVER;
+		break;
 	default:
 		return;
 	}
@@ -1052,6 +1064,8 @@ static int tg3_readphy(struct tg3 *tp, int reg, u32 *val)
 		udelay(80);
 	}
 
+	tg3_ape_lock(tp, tp->phy_ape_lock);
+
 	*val = 0x0;
 
 	frame_val  = ((tp->phy_addr << MI_COM_PHY_ADDR_SHIFT) &
@@ -1086,6 +1100,8 @@ static int tg3_readphy(struct tg3 *tp, int reg, u32 *val)
 		udelay(80);
 	}
 
+	tg3_ape_unlock(tp, tp->phy_ape_lock);
+
 	return ret;
 }
 
@@ -1105,6 +1121,8 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 		udelay(80);
 	}
 
+	tg3_ape_lock(tp, tp->phy_ape_lock);
+
 	frame_val  = ((tp->phy_addr << MI_COM_PHY_ADDR_SHIFT) &
 		      MI_COM_PHY_ADDR_MASK);
 	frame_val |= ((reg << MI_COM_REG_ADDR_SHIFT) &
@@ -1135,6 +1153,8 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 		udelay(80);
 	}
 
+	tg3_ape_unlock(tp, tp->phy_ape_lock);
+
 	return ret;
 }
 
@@ -13648,6 +13668,23 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	tg3_flag_set(tp, PAUSE_AUTONEG);
 	tp->link_config.flowctrl = FLOW_CTRL_TX | FLOW_CTRL_RX;
 
+	if (tg3_flag(tp, ENABLE_APE)) {
+		switch (tp->pci_fn) {
+		case 0:
+			tp->phy_ape_lock = TG3_APE_LOCK_PHY0;
+			break;
+		case 1:
+			tp->phy_ape_lock = TG3_APE_LOCK_PHY1;
+			break;
+		case 2:
+			tp->phy_ape_lock = TG3_APE_LOCK_PHY2;
+			break;
+		case 3:
+			tp->phy_ape_lock = TG3_APE_LOCK_PHY3;
+			break;
+		}
+	}
+
 	if (tg3_flag(tp, USE_PHYLIB))
 		return tg3_phy_init(tp);
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index a1b75cd..6fb45a5 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3107,6 +3107,7 @@ struct tg3 {
 	int				old_link;
 
 	u8				phy_addr;
+	u8				phy_ape_lock;
 
 	/* PHY info */
 	u32				phy_id;
-- 
1.7.1
