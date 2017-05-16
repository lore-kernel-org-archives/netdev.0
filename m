From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net-next: stmmac: add adjust_link function
Date: Tue, 16 May 2017 09:43:04 -0700
Message-ID: <b54c0535-f3b2-6184-1422-ec9eed22e67f@gmail.com>
References: <20170515114140.1676-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170515114140.1676-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/15/2017 04:41 AM, Corentin Labbe wrote:
> My dwmac-sun8i serie will add some if (has_sun8i) to
> stmmac_adjust_link()
> Since the current stmmac_adjust_link() alreaady have lots of if (has_gmac/gmac4),
> It is now better to create an adjust_link() function for each dwmac.

Is it really, because the diffstat really seems to indicate otherwise
and by looking at the code, I am definitively not convinced this is an
improvement other the current code.

> 
> So this patch add an adjust_link() function pointer, and move code out
> of stmmac_adjust_link to it.

Can't we keep the existing adjust_link() function and just have a
different one for dwmac-sun8i that either re-uses portions of the
existing, or duplicate just what it needs?

> 
> Removing in the process stmmac_mac_flow_ctrl/stmmac_hw_fix_mac_speed
> since there not used anymore.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/common.h       |  3 +
>  .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 54 ++++++++++++++
>  .../net/ethernet/stmicro/stmmac/dwmac100_core.c    | 46 ++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 54 ++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 83 +---------------------
>  5 files changed, 158 insertions(+), 82 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index b7ce3fbb5375..451c231006fe 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -469,11 +469,14 @@ struct stmmac_dma_ops {
>  };
>  
>  struct mac_device_info;
> +struct stmmac_priv;
>  
>  /* Helpers to program the MAC core */
>  struct stmmac_ops {
>  	/* MAC core initialization */
>  	void (*core_init)(struct mac_device_info *hw, int mtu);
> +	/* adjust link */
> +	int (*adjust_link)(struct stmmac_priv *priv);
>  	/* Enable the MAC RX/TX */
>  	void (*set_mac)(void __iomem *ioaddr, bool enable);
>  	/* Enable and verify that the IPC module is supported */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> index f3d9305e5f70..5f3aace46c41 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> @@ -26,6 +26,7 @@
>  #include <linux/slab.h>
>  #include <linux/ethtool.h>
>  #include <asm/io.h>
> +#include "stmmac.h"
>  #include "stmmac_pcs.h"
>  #include "dwmac1000.h"
>  
> @@ -75,6 +76,58 @@ static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
>  #endif
>  }
>  
> +static int dwmac1000_adjust_link(struct stmmac_priv *priv)
> +{
> +	struct net_device *ndev = priv->dev;
> +	struct phy_device *phydev = ndev->phydev;
> +	int new_state = 0;
> +	u32 tx_cnt = priv->plat->tx_queues_to_use;
> +	u32 ctrl;

Reverse christmas tree declaration please.

> +
> +	ctrl = readl(priv->ioaddr + GMAC_CONTROL);
> +
> +	if (phydev->duplex != priv->oldduplex) {
> +		new_state = 1;

bool new_state

> +		if (!(phydev->duplex))

Parenthesis not needed (this is an integer, not a bitmask)

> +			ctrl &= ~GMAC_CONTROL_DM;
> +		else
> +			ctrl |= GMAC_CONTROL_DM;
> +		priv->oldduplex = phydev->duplex;
> +	}
> +
> +	if (phydev->pause)
> +		priv->hw->mac->flow_ctrl(priv->hw, phydev->duplex, priv->flow_ctrl,
> +					 priv->pause, tx_cnt);
> +
> +	if (phydev->speed != priv->speed) {
> +		new_state = 1;
> +		switch (phydev->speed) {
> +		case 1000:

case SPEED_1000 and so on?

> +			ctrl &= ~GMAC_CONTROL_PS;
> +			break;
> +		case 100:
> +			ctrl |= GMAC_CONTROL_PS;
> +			ctrl |= GMAC_CONTROL_FES;
> +			break;
> +		case 10:
> +			ctrl |= GMAC_CONTROL_PS;
> +			ctrl |= ~GMAC_CONTROL_FES;
> +			break;
> +		default:
> +			netif_warn(priv, link, priv->dev,
> +				   "broken speed: %d\n", phydev->speed);
> +			phydev->speed = SPEED_UNKNOWN;
> +			break;
> +		}
> +		if (phydev->speed != SPEED_UNKNOWN && likely(priv->plat->fix_mac_speed))
> +			priv->plat->fix_mac_speed(priv->plat->bsp_priv, phydev->speed);
> +		priv->speed = phydev->speed;
> +	}
> +
> +	writel(ctrl, priv->ioaddr + GMAC_CONTROL);
> +	return new_state;
> +}
> +
>  static int dwmac1000_rx_ipc_enable(struct mac_device_info *hw)
>  {
>  	void __iomem *ioaddr = hw->pcsr;
> @@ -490,6 +543,7 @@ static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
>  
>  static const struct stmmac_ops dwmac1000_ops = {
>  	.core_init = dwmac1000_core_init,
> +	.adjust_link = dwmac1000_adjust_link,
>  	.set_mac = stmmac_set_mac,
>  	.rx_ipc = dwmac1000_rx_ipc_enable,
>  	.dump_regs = dwmac1000_dump_regs,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
> index 1b3609105484..ba3d46e65e1a 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
> @@ -27,6 +27,7 @@
>  #include <linux/crc32.h>
>  #include <asm/io.h>
>  #include "dwmac100.h"
> +#include "stmmac.h"
>  
>  static void dwmac100_core_init(struct mac_device_info *hw, int mtu)
>  {
> @@ -40,6 +41,50 @@ static void dwmac100_core_init(struct mac_device_info *hw, int mtu)
>  #endif
>  }
>  
> +static int dwmac100_adjust_link(struct stmmac_priv *priv)
> +{
> +	struct net_device *ndev = priv->dev;
> +	struct phy_device *phydev = ndev->phydev;
> +	int new_state = 0;
> +	u32 tx_cnt = priv->plat->tx_queues_to_use;
> +	u32 ctrl;
> +
> +	ctrl = readl(priv->ioaddr + MAC_CTRL_REG);
> +	if (phydev->duplex != priv->oldduplex) {
> +		new_state = 1;
> +		if (!(phydev->duplex))
> +			ctrl &= ~MAC_CONTROL_F;
> +		else
> +			ctrl |= MAC_CONTROL_F;
> +		priv->oldduplex = phydev->duplex;
> +	}
> +
> +	if (phydev->pause)
> +		priv->hw->mac->flow_ctrl(priv->hw, phydev->duplex, priv->flow_ctrl,
> +				priv->pause, tx_cnt);
> +
> +	if (phydev->speed != priv->speed) {
> +		new_state = 1;
> +		switch (phydev->speed) {
> +		case 100:
> +		case 10:
> +			ctrl &= ~MAC_CONTROL_PS;
> +			break;
> +		default:
> +			netif_warn(priv, link, priv->dev,
> +					"broken speed: %d\n", phydev->speed);
> +			phydev->speed = SPEED_UNKNOWN;
> +			break;
> +		}
> +		if (phydev->speed != SPEED_UNKNOWN && likely(priv->plat->fix_mac_speed))
> +			priv->plat->fix_mac_speed(priv->plat->bsp_priv, phydev->speed);
> +		priv->speed = phydev->speed;
> +	}
> +
> +	writel(ctrl, priv->ioaddr + MAC_CTRL_REG);
> +	return new_state;
> +}
> +
>  static void dwmac100_dump_mac_regs(struct mac_device_info *hw, u32 *reg_space)
>  {
>  	void __iomem *ioaddr = hw->pcsr;
> @@ -150,6 +195,7 @@ static void dwmac100_pmt(struct mac_device_info *hw, unsigned long mode)
>  
>  static const struct stmmac_ops dwmac100_ops = {
>  	.core_init = dwmac100_core_init,
> +	.adjust_link = dwmac100_adjust_link,
>  	.set_mac = stmmac_set_mac,
>  	.rx_ipc = dwmac100_rx_ipc_enable,
>  	.dump_regs = dwmac100_dump_mac_regs,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> index 48793f2e9307..133b6bcd7b61 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> @@ -19,6 +19,7 @@
>  #include <linux/io.h>
>  #include "stmmac_pcs.h"
>  #include "dwmac4.h"
> +#include "stmmac.h"
>  
>  static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
>  {
> @@ -59,6 +60,58 @@ static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
>  	writel(value, ioaddr + GMAC_INT_EN);
>  }
>  
> +static int dwmac4_adjust_link(struct stmmac_priv *priv)
> +{
> +	struct net_device *ndev = priv->dev;
> +	struct phy_device *phydev = ndev->phydev;
> +	int new_state = 0;
> +	u32 tx_cnt = priv->plat->tx_queues_to_use;
> +	u32 ctrl;
> +
> +	ctrl = readl(priv->ioaddr + MAC_CTRL_REG);
> +
> +	if (phydev->duplex != priv->oldduplex) {
> +		new_state = 1;
> +		if (!(phydev->duplex))
> +			ctrl &= ~GMAC_CONFIG_DM;
> +		else
> +			ctrl |= GMAC_CONFIG_DM;
> +		priv->oldduplex = phydev->duplex;
> +	}
> +
> +	if (phydev->pause)
> +		priv->hw->mac->flow_ctrl(priv->hw, phydev->duplex, priv->flow_ctrl,
> +					 priv->pause, tx_cnt);
> +
> +	if (phydev->speed != priv->speed) {
> +		new_state = 1;
> +		switch (phydev->speed) {
> +		case 1000:
> +			ctrl &= ~GMAC_CONFIG_PS;
> +			break;
> +		case 100:
> +			ctrl |= GMAC_CONFIG_PS;
> +			ctrl |= GMAC_CONFIG_FES;
> +			break;
> +		case 10:
> +			ctrl |= GMAC_CONFIG_PS;
> +			ctrl |= ~GMAC_CONFIG_FES;
> +			break;
> +		default:
> +			netif_warn(priv, link, priv->dev,
> +				   "broken speed: %d\n", phydev->speed);
> +			phydev->speed = SPEED_UNKNOWN;
> +			break;
> +		}
> +		if (phydev->speed != SPEED_UNKNOWN && likely(priv->plat->fix_mac_speed))
> +			priv->plat->fix_mac_speed(priv->plat->bsp_priv, phydev->speed);
> +		priv->speed = phydev->speed;
> +	}
> +
> +	writel(ctrl, priv->ioaddr + MAC_CTRL_REG);
> +	return new_state;
> +}
> +
>  static void dwmac4_rx_queue_enable(struct mac_device_info *hw,
>  				   u8 mode, u32 queue)
>  {
> @@ -669,6 +722,7 @@ static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
>  
>  static const struct stmmac_ops dwmac4_ops = {
>  	.core_init = dwmac4_core_init,
> +	.adjust_link = dwmac4_adjust_link,
>  	.set_mac = stmmac_set_mac,
>  	.rx_ipc = dwmac4_rx_ipc_enable,
>  	.rx_queue_enable = dwmac4_rx_queue_enable,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index b05a042cf2c6..fb3e2ddaa7c9 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -286,21 +286,6 @@ static inline u32 stmmac_rx_dirty(struct stmmac_priv *priv, u32 queue)
>  }
>  
>  /**
> - * stmmac_hw_fix_mac_speed - callback for speed selection
> - * @priv: driver private structure
> - * Description: on some platforms (e.g. ST), some HW system configuration
> - * registers have to be set according to the link speed negotiated.
> - */
> -static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
> -{
> -	struct net_device *ndev = priv->dev;
> -	struct phy_device *phydev = ndev->phydev;
> -
> -	if (likely(priv->plat->fix_mac_speed))
> -		priv->plat->fix_mac_speed(priv->plat->bsp_priv, phydev->speed);
> -}
> -
> -/**
>   * stmmac_enable_eee_mode - check and enter in LPI mode
>   * @priv: driver private structure
>   * Description: this function is to verify and enter in LPI mode in case of
> @@ -759,19 +744,6 @@ static void stmmac_release_ptp(struct stmmac_priv *priv)
>  }
>  
>  /**
> - *  stmmac_mac_flow_ctrl - Configure flow control in all queues
> - *  @priv: driver private structure
> - *  Description: It is used for configuring the flow control in all queues
> - */
> -static void stmmac_mac_flow_ctrl(struct stmmac_priv *priv, u32 duplex)
> -{
> -	u32 tx_cnt = priv->plat->tx_queues_to_use;
> -
> -	priv->hw->mac->flow_ctrl(priv->hw, duplex, priv->flow_ctrl,
> -				 priv->pause, tx_cnt);
> -}
> -
> -/**
>   * stmmac_adjust_link - adjusts the link parameters
>   * @dev: net device structure
>   * Description: this is the helper called by the physical abstraction layer
> @@ -793,60 +765,7 @@ static void stmmac_adjust_link(struct net_device *dev)
>  	spin_lock_irqsave(&priv->lock, flags);
>  
>  	if (phydev->link) {
> -		u32 ctrl = readl(priv->ioaddr + MAC_CTRL_REG);
> -
> -		/* Now we make sure that we can be in full duplex mode.
> -		 * If not, we operate in half-duplex mode. */
> -		if (phydev->duplex != priv->oldduplex) {
> -			new_state = 1;
> -			if (!(phydev->duplex))
> -				ctrl &= ~priv->hw->link.duplex;
> -			else
> -				ctrl |= priv->hw->link.duplex;
> -			priv->oldduplex = phydev->duplex;
> -		}
> -		/* Flow Control operation */
> -		if (phydev->pause)
> -			stmmac_mac_flow_ctrl(priv, phydev->duplex);
> -
> -		if (phydev->speed != priv->speed) {
> -			new_state = 1;
> -			switch (phydev->speed) {
> -			case 1000:
> -				if (priv->plat->has_gmac ||
> -				    priv->plat->has_gmac4)
> -					ctrl &= ~priv->hw->link.port;
> -				break;
> -			case 100:
> -				if (priv->plat->has_gmac ||
> -				    priv->plat->has_gmac4) {
> -					ctrl |= priv->hw->link.port;
> -					ctrl |= priv->hw->link.speed;
> -				} else {
> -					ctrl &= ~priv->hw->link.port;
> -				}
> -				break;
> -			case 10:
> -				if (priv->plat->has_gmac ||
> -				    priv->plat->has_gmac4) {
> -					ctrl |= priv->hw->link.port;
> -					ctrl &= ~(priv->hw->link.speed);
> -				} else {
> -					ctrl &= ~priv->hw->link.port;
> -				}
> -				break;
> -			default:
> -				netif_warn(priv, link, priv->dev,
> -					   "broken speed: %d\n", phydev->speed);
> -				phydev->speed = SPEED_UNKNOWN;
> -				break;
> -			}
> -			if (phydev->speed != SPEED_UNKNOWN)
> -				stmmac_hw_fix_mac_speed(priv);
> -			priv->speed = phydev->speed;
> -		}
> -
> -		writel(ctrl, priv->ioaddr + MAC_CTRL_REG);
> +		new_state = priv->hw->mac->adjust_link(priv);
>  
>  		if (!priv->oldlink) {
>  			new_state = 1;
> 


-- 
Florian
