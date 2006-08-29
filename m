From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 08/26] e1000: Deprecate mii-tool SIOCMIIREG ioctl
Date: Tue, 29 Aug 2006 09:44:32 -0700
Message-ID: <20060829164432.6872.69323.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:35082 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965078AbWH2QgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:18 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Deprecate mii-tool SIOCMIIREG ioctl. This ioctl is broken in e1000 and
ethtool has this functionality in working order.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   69 ----------------------------------------
 1 files changed, 0 insertions(+), 69 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c128f62..70d0acd 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4263,9 +4263,6 @@ e1000_mii_ioctl(struct net_device *netde
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct mii_ioctl_data *data = if_mii(ifr);
-	int retval;
-	uint16_t mii_reg;
-	uint16_t spddplx;
 	unsigned long flags;
 
 	if (adapter->hw.media_type != e1000_media_type_copper)
@@ -4287,72 +4284,6 @@ e1000_mii_ioctl(struct net_device *netde
 		spin_unlock_irqrestore(&adapter->stats_lock, flags);
 		break;
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		if (data->reg_num & ~(0x1F))
-			return -EFAULT;
-		mii_reg = data->val_in;
-		spin_lock_irqsave(&adapter->stats_lock, flags);
-		if (e1000_write_phy_reg(&adapter->hw, data->reg_num,
-					mii_reg)) {
-			spin_unlock_irqrestore(&adapter->stats_lock, flags);
-			return -EIO;
-		}
-		if (adapter->hw.media_type == e1000_media_type_copper) {
-			switch (data->reg_num) {
-			case PHY_CTRL:
-				if (mii_reg & MII_CR_POWER_DOWN)
-					break;
-				if (mii_reg & MII_CR_AUTO_NEG_EN) {
-					adapter->hw.autoneg = 1;
-					adapter->hw.autoneg_advertised = 0x2F;
-				} else {
-					if (mii_reg & 0x40)
-						spddplx = SPEED_1000;
-					else if (mii_reg & 0x2000)
-						spddplx = SPEED_100;
-					else
-						spddplx = SPEED_10;
-					spddplx += (mii_reg & 0x100)
-						   ? DUPLEX_FULL :
-						   DUPLEX_HALF;
-					retval = e1000_set_spd_dplx(adapter,
-								    spddplx);
-					if (retval) {
-						spin_unlock_irqrestore(
-							&adapter->stats_lock,
-							flags);
-						return retval;
-					}
-				}
-				if (netif_running(adapter->netdev))
-					e1000_reinit_locked(adapter);
-				else
-					e1000_reset(adapter);
-				break;
-			case M88E1000_PHY_SPEC_CTRL:
-			case M88E1000_EXT_PHY_SPEC_CTRL:
-				if (e1000_phy_reset(&adapter->hw)) {
-					spin_unlock_irqrestore(
-						&adapter->stats_lock, flags);
-					return -EIO;
-				}
-				break;
-			}
-		} else {
-			switch (data->reg_num) {
-			case PHY_CTRL:
-				if (mii_reg & MII_CR_POWER_DOWN)
-					break;
-				if (netif_running(adapter->netdev))
-					e1000_reinit_locked(adapter);
-				else
-					e1000_reset(adapter);
-				break;
-			}
-		}
-		spin_unlock_irqrestore(&adapter->stats_lock, flags);
-		break;
 	default:
 		return -EOPNOTSUPP;
 	}



---
Auke Kok <auke-jan.h.kok@intel.com>
