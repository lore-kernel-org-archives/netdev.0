From: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix
Date: Mon, 11 Sep 2006 11:35:11 +1000
Message-ID: <01cb01c6d542$88544620$5001010a@bluereef.local>
References: <20060906124447.642940bd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.mud.yahoo.com ([68.142.200.252]:8815 "HELO
	smtp104.biz.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S932169AbWIKBfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 21:35:18 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>,
	"Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

After some serious testing, this patch seems to fix the lockup issue 
completely. I manually applied these changes against the 2.6.17.13 release.

----- Original Message ----- 
From: "Stephen Hemminger" <shemminger@osdl.org>
To: "Jeff Garzik" <jgarzik@pobox.com>
Cc: <netdev@vger.kernel.org>
Sent: Thursday, September 07, 2006 5:44 AM
Subject: [PATCH 1/3] sky2: tx pause bug fix


> Fix problems with transmit pause frames. The driver was telling the
> GMAC to flush (not process) pause frames. Manually disabling pause wasn't
> working because of problems in the setup.
>
> This maybe the cause of the lockup under load.
> http://bugzilla.kernel.org/show_bug.cgi?id=6839
>
> Patch against netdev-2.6 git tree
>
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>
> ---
>
> drivers/net/sky2.c |  123 
> ++++++++++++++++++----------------------------------
> drivers/net/sky2.h |    2 -
> 2 files changed, 43 insertions(+), 82 deletions(-)
>
> 1419c8ab49f8fd56bad1ac0d3dcbaf830cd5a5d6
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 7ce0663..a3a4ab2 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -289,7 +289,7 @@ static void sky2_gmac_reset(struct sky2_
> static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
> {
>  struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
> - u16 ctrl, ct1000, adv, pg, ledctrl, ledover;
> + u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
>
>  if (sky2->autoneg == AUTONEG_ENABLE &&
>      !(hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == 
> CHIP_ID_YUKON_EC_U)) {
> @@ -358,6 +358,7 @@ static void sky2_phy_init(struct sky2_hw
>  ctrl = 0;
>  ct1000 = 0;
>  adv = PHY_AN_CSMA;
> + reg = 0;
>
>  if (sky2->autoneg == AUTONEG_ENABLE) {
>  if (hw->copper) {
> @@ -390,21 +391,46 @@ static void sky2_phy_init(struct sky2_hw
>  /* forced speed/duplex settings */
>  ct1000 = PHY_M_1000C_MSE;
>
> - if (sky2->duplex == DUPLEX_FULL)
> - ctrl |= PHY_CT_DUP_MD;
> + /* Disable auto update for duplex flow control and speed */
> + reg |= GM_GPCR_AU_ALL_DIS;
>
>  switch (sky2->speed) {
>  case SPEED_1000:
>  ctrl |= PHY_CT_SP1000;
> + reg |= GM_GPCR_SPEED_1000;
>  break;
>  case SPEED_100:
>  ctrl |= PHY_CT_SP100;
> + reg |= GM_GPCR_SPEED_100;
>  break;
>  }
>
> + if (sky2->duplex == DUPLEX_FULL) {
> + reg |= GM_GPCR_DUP_FULL;
> + ctrl |= PHY_CT_DUP_MD;
> + } else if (sky2->speed != SPEED_1000 && hw->chip_id != 
> CHIP_ID_YUKON_EC_U) {
> + /* Turn off flow control for 10/100mbps */
> + sky2->rx_pause = 0;
> + sky2->tx_pause = 0;
> + }
> +
> + if (!sky2->rx_pause)
> + reg |= GM_GPCR_FC_RX_DIS;
> +
> + if (!sky2->tx_pause)
> + reg |= GM_GPCR_FC_TX_DIS;
> +
> + /* Forward pause packets to GMAC? */
> + if (sky2->tx_pause || sky2->rx_pause)
> + sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
> + else
> + sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
> +
>  ctrl |= PHY_CT_RESET;
>  }
>
> + gma_write16(hw, port, GM_GP_CTRL, reg);
> +
>  if (hw->chip_id != CHIP_ID_YUKON_FE)
>  gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, ct1000);
>
> @@ -508,6 +534,7 @@ static void sky2_phy_init(struct sky2_hw
>  gm_phy_write(hw, port, PHY_MARV_LED_OVER, ledover);
>
>  }
> +
>  /* Enable phy interrupt on auto-negotiation complete (or link up) */
>  if (sky2->autoneg == AUTONEG_ENABLE)
>  gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_IS_AN_COMPL);
> @@ -570,49 +597,11 @@ static void sky2_mac_init(struct sky2_hw
>  gm_phy_read(hw, 1, PHY_MARV_INT_MASK) != 0);
>  }
>
> - if (sky2->autoneg == AUTONEG_DISABLE) {
> - reg = gma_read16(hw, port, GM_GP_CTRL);
> - reg |= GM_GPCR_AU_ALL_DIS;
> - gma_write16(hw, port, GM_GP_CTRL, reg);
> - gma_read16(hw, port, GM_GP_CTRL);
> -
> - switch (sky2->speed) {
> - case SPEED_1000:
> - reg &= ~GM_GPCR_SPEED_100;
> - reg |= GM_GPCR_SPEED_1000;
> - break;
> - case SPEED_100:
> - reg &= ~GM_GPCR_SPEED_1000;
> - reg |= GM_GPCR_SPEED_100;
> - break;
> - case SPEED_10:
> - reg &= ~(GM_GPCR_SPEED_1000 | GM_GPCR_SPEED_100);
> - break;
> - }
> -
> - if (sky2->duplex == DUPLEX_FULL)
> - reg |= GM_GPCR_DUP_FULL;
> -
> - /* turn off pause in 10/100mbps half duplex */
> - else if (sky2->speed != SPEED_1000 &&
> - hw->chip_id != CHIP_ID_YUKON_EC_U)
> - sky2->tx_pause = sky2->rx_pause = 0;
> - } else
> - reg = GM_GPCR_SPEED_1000 | GM_GPCR_SPEED_100 | GM_GPCR_DUP_FULL;
> -
> - if (!sky2->tx_pause && !sky2->rx_pause) {
> - sky2_write32(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
> - reg |=
> -     GM_GPCR_FC_TX_DIS | GM_GPCR_FC_RX_DIS | GM_GPCR_AU_FCT_DIS;
> - } else if (sky2->tx_pause && !sky2->rx_pause) {
> - /* disable Rx flow-control */
> - reg |= GM_GPCR_FC_RX_DIS | GM_GPCR_AU_FCT_DIS;
> - }
> -
> - gma_write16(hw, port, GM_GP_CTRL, reg);
> -
>  sky2_read16(hw, SK_REG(port, GMAC_IRQ_SRC));
>
> + /* Enable Transmit FIFO Underrun */
> + sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), GMAC_DEF_MSK);
> +
>  spin_lock_bh(&sky2->phy_lock);
>  sky2_phy_init(hw, port);
>  spin_unlock_bh(&sky2->phy_lock);
> @@ -1529,40 +1518,10 @@ static void sky2_link_up(struct sky2_por
>  unsigned port = sky2->port;
>  u16 reg;
>
> - /* Enable Transmit FIFO Underrun */
> - sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), GMAC_DEF_MSK);
> -
> - reg = gma_read16(hw, port, GM_GP_CTRL);
> - if (sky2->autoneg == AUTONEG_DISABLE) {
> - reg |= GM_GPCR_AU_ALL_DIS;
> -
> - /* Is write/read necessary?  Copied from sky2_mac_init */
> - gma_write16(hw, port, GM_GP_CTRL, reg);
> - gma_read16(hw, port, GM_GP_CTRL);
> -
> - switch (sky2->speed) {
> - case SPEED_1000:
> - reg &= ~GM_GPCR_SPEED_100;
> - reg |= GM_GPCR_SPEED_1000;
> - break;
> - case SPEED_100:
> - reg &= ~GM_GPCR_SPEED_1000;
> - reg |= GM_GPCR_SPEED_100;
> - break;
> - case SPEED_10:
> - reg &= ~(GM_GPCR_SPEED_1000 | GM_GPCR_SPEED_100);
> - break;
> - }
> - } else
> - reg &= ~GM_GPCR_AU_ALL_DIS;
> -
> - if (sky2->duplex == DUPLEX_FULL || sky2->autoneg == AUTONEG_ENABLE)
> - reg |= GM_GPCR_DUP_FULL;
> -
>  /* enable Rx/Tx */
> + reg = gma_read16(hw, port, GM_GP_CTRL);
>  reg |= GM_GPCR_RX_ENA | GM_GPCR_TX_ENA;
>  gma_write16(hw, port, GM_GP_CTRL, reg);
> - gma_read16(hw, port, GM_GP_CTRL);
>
>  gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
>
> @@ -1616,7 +1575,6 @@ static void sky2_link_down(struct sky2_p
>  reg = gma_read16(hw, port, GM_GP_CTRL);
>  reg &= ~(GM_GPCR_RX_ENA | GM_GPCR_TX_ENA);
>  gma_write16(hw, port, GM_GP_CTRL, reg);
> - gma_read16(hw, port, GM_GP_CTRL); /* PCI post */
>
>  if (sky2->rx_pause && !sky2->tx_pause) {
>  /* restore Asymmetric Pause bit */
> @@ -1633,6 +1591,7 @@ static void sky2_link_down(struct sky2_p
>
>  if (netif_msg_link(sky2))
>  printk(KERN_INFO PFX "%s: Link is down.\n", sky2->netdev->name);
> +
>  sky2_phy_init(hw, port);
> }
>
> @@ -1673,8 +1632,11 @@ static int sky2_autoneg_done(struct sky2
>  sky2->rx_pause = (aux & PHY_M_PS_RX_P_EN) != 0;
>  sky2->tx_pause = (aux & PHY_M_PS_TX_P_EN) != 0;
>
> - if ((sky2->tx_pause || sky2->rx_pause)
> -     && !(sky2->speed < SPEED_1000 && sky2->duplex == DUPLEX_HALF))
> + if (sky2->duplex == DUPLEX_HALF && sky2->speed != SPEED_1000
> +     && hw->chip_id != CHIP_ID_YUKON_EC_U)
> + sky2->rx_pause = sky2->tx_pause = 0;
> +
> + if (sky2->rx_pause || sky2->tx_pause)
>  sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
>  else
>  sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
> @@ -1700,7 +1662,7 @@ static void sky2_phy_intr(struct sky2_hw
>  printk(KERN_INFO PFX "%s: phy interrupt status 0x%x 0x%x\n",
>         sky2->netdev->name, istatus, phystat);
>
> - if (istatus & PHY_M_IS_AN_COMPL) {
> + if (sky2->autoneg == AUTONEG_ENABLE && (istatus & PHY_M_IS_AN_COMPL)) {
>  if (sky2_autoneg_done(sky2, phystat) == 0)
>  sky2_link_up(sky2);
>  goto out;
> @@ -2890,7 +2852,6 @@ static int sky2_set_pauseparam(struct ne
>         struct ethtool_pauseparam *ecmd)
> {
>  struct sky2_port *sky2 = netdev_priv(dev);
> - int err = 0;
>
>  sky2->autoneg = ecmd->autoneg;
>  sky2->tx_pause = ecmd->tx_pause != 0;
> @@ -2898,7 +2859,7 @@ static int sky2_set_pauseparam(struct ne
>
>  sky2_phy_reinit(sky2);
>
> - return err;
> + return 0;
> }
>
> static int sky2_get_coalesce(struct net_device *dev,
> diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
> index fa8af9f..a27194c 100644
> --- a/drivers/net/sky2.h
> +++ b/drivers/net/sky2.h
> @@ -1566,7 +1566,7 @@ enum {
>
>  GMR_FS_ANY_ERR = GMR_FS_RX_FF_OV | GMR_FS_CRC_ERR |
>    GMR_FS_FRAGMENT | GMR_FS_LONG_ERR |
> -     GMR_FS_MII_ERR | GMR_FS_BAD_FC | GMR_FS_GOOD_FC |
> +     GMR_FS_MII_ERR | GMR_FS_BAD_FC |
>    GMR_FS_UN_SIZE | GMR_FS_JABBER,
> };
>
> -- 
> 1.2.4
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html 

