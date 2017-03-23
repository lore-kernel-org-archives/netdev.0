From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 23 Mar 2017 11:00:09 +1100
Message-ID: <20170323110009.15847147@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Doug Berger <opendmb@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/broadcom/genet/bcmmii.c

between commit:

  31739eae738c ("net: bcmgenet: remove bcmgenet_internal_phy_setup()")

from the net tree and commit:

  421380856d9c ("net: bcmgenet: add support for the GENETv5 hardware")

from the net-next tree.

I fixed it up (I just removed the bcmgenet_internal_phy_setup() function)
and can carry the fix as necessary. This is now fixed as far as linux-next
is concerned, but any non trivial conflicts should be mentioned to your
upstream maintainer when your tree is submitted for merging.  You may
also want to consider cooperating with the maintainer of the conflicting
tree to minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/broadcom/genet/bcmmii.c
index 2f9281936f0e,8df47c90cfc5..000000000000
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@@ -195,31 -195,49 +195,33 @@@ void bcmgenet_phy_power_set(struct net_
  	u32 reg = 0;
  
  	/* EXT_GPHY_CTRL is only valid for GENETv4 and onward */
- 	if (!GENET_IS_V4(priv))
- 		return;
- 
- 	reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
- 	if (enable) {
- 		reg &= ~EXT_CK25_DIS;
- 		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
- 		mdelay(1);
- 
- 		reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN);
- 		reg |= EXT_GPHY_RESET;
+ 	if (GENET_IS_V4(priv)) {
+ 		reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
+ 		if (enable) {
+ 			reg &= ~EXT_CK25_DIS;
+ 			bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+ 			mdelay(1);
+ 
+ 			reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN);
+ 			reg |= EXT_GPHY_RESET;
+ 			bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+ 			mdelay(1);
+ 
+ 			reg &= ~EXT_GPHY_RESET;
+ 		} else {
+ 			reg |= EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN |
+ 			       EXT_GPHY_RESET;
+ 			bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+ 			mdelay(1);
+ 			reg |= EXT_CK25_DIS;
+ 		}
  		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
- 		mdelay(1);
- 
- 		reg &= ~EXT_GPHY_RESET;
+ 		udelay(60);
  	} else {
- 		reg |= EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN | EXT_GPHY_RESET;
- 		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
  		mdelay(1);
- 		reg |= EXT_CK25_DIS;
  	}
- 	bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
- 	udelay(60);
  }
  
 -static void bcmgenet_internal_phy_setup(struct net_device *dev)
 -{
 -	struct bcmgenet_priv *priv = netdev_priv(dev);
 -	u32 reg;
 -
 -	/* Power up PHY */
 -	bcmgenet_phy_power_set(dev, true);
 -	if (!GENET_IS_V5(priv)) {
 -		/* enable APD */
 -		reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
 -		reg |= EXT_PWR_DN_EN_LD;
 -		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
 -	}
 -	bcmgenet_mii_reset(dev);
 -}
 -
  static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
  {
  	u32 reg;
