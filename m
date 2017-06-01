From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 1 Jun 2017 11:30:00 +1000
Message-ID: <20170601113000.7458d252@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/phy/marvell.c

between commit:

  898805e0cdf7 ("net: phy: fix marvell phy status reading")

from the net tree and commit:

  e1dde8dc5b27 ("net: phy: marvell: Refactor some bigger functions")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/phy/marvell.c
index 57297ba23987,1a72bebc588a..000000000000
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@@ -1082,119 -1133,106 +1133,104 @@@ static int marvell_update_link(struct p
  	return 0;
  }
  
- /* marvell_read_status_page
-  *
-  * Description:
-  *   Check the link, then figure out the current state
-  *   by comparing what we advertise with what the link partner
-  *   advertises.  Start by checking the gigabit possibilities,
-  *   then move on to 10/100.
-  */
- static int marvell_read_status_page(struct phy_device *phydev, int page)
+ static int marvell_read_status_page_an(struct phy_device *phydev,
+ 				       int fiber)
  {
- 	int adv;
- 	int err;
+ 	int status;
  	int lpa;
  	int lpagb;
- 	int status = 0;
- 	int fiber;
+ 	int adv;
  
- 	/* Detect and update the link, but return if there
- 	 * was an error */
- 	if (page == MII_M1111_FIBER)
- 		fiber = 1;
- 	else
- 		fiber = 0;
+ 	status = phy_read(phydev, MII_M1011_PHY_STATUS);
+ 	if (status < 0)
+ 		return status;
  
- 	err = marvell_update_link(phydev, fiber);
- 	if (err)
- 		return err;
+ 	lpa = phy_read(phydev, MII_LPA);
+ 	if (lpa < 0)
+ 		return lpa;
  
- 	if (AUTONEG_ENABLE == phydev->autoneg) {
- 		status = phy_read(phydev, MII_M1011_PHY_STATUS);
- 		if (status < 0)
- 			return status;
+ 	lpagb = phy_read(phydev, MII_STAT1000);
+ 	if (lpagb < 0)
+ 		return lpagb;
  
- 		lpa = phy_read(phydev, MII_LPA);
- 		if (lpa < 0)
- 			return lpa;
+ 	adv = phy_read(phydev, MII_ADVERTISE);
+ 	if (adv < 0)
+ 		return adv;
  
- 		lpagb = phy_read(phydev, MII_STAT1000);
- 		if (lpagb < 0)
- 			return lpagb;
 -	lpa &= adv;
 -
+ 	if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
+ 		phydev->duplex = DUPLEX_FULL;
+ 	else
+ 		phydev->duplex = DUPLEX_HALF;
  
- 		adv = phy_read(phydev, MII_ADVERTISE);
- 		if (adv < 0)
- 			return adv;
+ 	status = status & MII_M1011_PHY_STATUS_SPD_MASK;
+ 	phydev->pause = 0;
+ 	phydev->asym_pause = 0;
  
- 		if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
- 			phydev->duplex = DUPLEX_FULL;
- 		else
- 			phydev->duplex = DUPLEX_HALF;
+ 	switch (status) {
+ 	case MII_M1011_PHY_STATUS_1000:
+ 		phydev->speed = SPEED_1000;
+ 		break;
  
- 		status = status & MII_M1011_PHY_STATUS_SPD_MASK;
- 		phydev->pause = phydev->asym_pause = 0;
+ 	case MII_M1011_PHY_STATUS_100:
+ 		phydev->speed = SPEED_100;
+ 		break;
  
- 		switch (status) {
- 		case MII_M1011_PHY_STATUS_1000:
- 			phydev->speed = SPEED_1000;
- 			break;
+ 	default:
+ 		phydev->speed = SPEED_10;
+ 		break;
+ 	}
  
- 		case MII_M1011_PHY_STATUS_100:
- 			phydev->speed = SPEED_100;
- 			break;
+ 	if (!fiber) {
+ 		phydev->lp_advertising =
+ 			mii_stat1000_to_ethtool_lpa_t(lpagb) |
+ 			mii_lpa_to_ethtool_lpa_t(lpa);
  
- 		default:
- 			phydev->speed = SPEED_10;
- 			break;
+ 		if (phydev->duplex == DUPLEX_FULL) {
+ 			phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
+ 			phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
  		}
- 
- 		if (!fiber) {
- 			phydev->lp_advertising = mii_stat1000_to_ethtool_lpa_t(lpagb) |
- 					 mii_lpa_to_ethtool_lpa_t(lpa);
- 
- 			if (phydev->duplex == DUPLEX_FULL) {
- 				phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
- 				phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
- 			}
- 		} else {
- 			/* The fiber link is only 1000M capable */
- 			phydev->lp_advertising = fiber_lpa_to_ethtool_lpa_t(lpa);
- 
- 			if (phydev->duplex == DUPLEX_FULL) {
- 				if (!(lpa & LPA_PAUSE_FIBER)) {
- 					phydev->pause = 0;
- 					phydev->asym_pause = 0;
- 				} else if ((lpa & LPA_PAUSE_ASYM_FIBER)) {
- 					phydev->pause = 1;
- 					phydev->asym_pause = 1;
- 				} else {
- 					phydev->pause = 1;
- 					phydev->asym_pause = 0;
- 				}
+ 	} else {
+ 		/* The fiber link is only 1000M capable */
+ 		phydev->lp_advertising = fiber_lpa_to_ethtool_lpa_t(lpa);
+ 
+ 		if (phydev->duplex == DUPLEX_FULL) {
+ 			if (!(lpa & LPA_PAUSE_FIBER)) {
+ 				phydev->pause = 0;
+ 				phydev->asym_pause = 0;
+ 			} else if ((lpa & LPA_PAUSE_ASYM_FIBER)) {
+ 				phydev->pause = 1;
+ 				phydev->asym_pause = 1;
+ 			} else {
+ 				phydev->pause = 1;
+ 				phydev->asym_pause = 0;
  			}
  		}
- 	} else {
- 		int bmcr = phy_read(phydev, MII_BMCR);
+ 	}
+ 	return 0;
+ }
  
- 		if (bmcr < 0)
- 			return bmcr;
+ static int marvell_read_status_page_fixed(struct phy_device *phydev)
+ {
+ 	int bmcr = phy_read(phydev, MII_BMCR);
  
- 		if (bmcr & BMCR_FULLDPLX)
- 			phydev->duplex = DUPLEX_FULL;
- 		else
- 			phydev->duplex = DUPLEX_HALF;
+ 	if (bmcr < 0)
+ 		return bmcr;
  
- 		if (bmcr & BMCR_SPEED1000)
- 			phydev->speed = SPEED_1000;
- 		else if (bmcr & BMCR_SPEED100)
- 			phydev->speed = SPEED_100;
- 		else
- 			phydev->speed = SPEED_10;
+ 	if (bmcr & BMCR_FULLDPLX)
+ 		phydev->duplex = DUPLEX_FULL;
+ 	else
+ 		phydev->duplex = DUPLEX_HALF;
  
- 		phydev->pause = phydev->asym_pause = 0;
- 		phydev->lp_advertising = 0;
- 	}
+ 	if (bmcr & BMCR_SPEED1000)
+ 		phydev->speed = SPEED_1000;
+ 	else if (bmcr & BMCR_SPEED100)
+ 		phydev->speed = SPEED_100;
+ 	else
+ 		phydev->speed = SPEED_10;
+ 
+ 	phydev->pause = 0;
+ 	phydev->asym_pause = 0;
+ 	phydev->lp_advertising = 0;
  
  	return 0;
  }
