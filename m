From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [RFC PATCHv4] net: fec: Ensure clocks are enabled while using
 mdio bus
Date: Mon, 29 Jun 2015 02:04:59 +0000
Message-ID: <BLUPR03MB373F2684A8C9BF38719B930F5AA0@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1435512972-24014-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Cory Tusar <cory.tusar@pid1solutions.com>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0147.outbound.protection.outlook.com ([65.55.169.147]:24133
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752812AbbF2Ch1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 22:37:27 -0400
In-Reply-To: <1435512972-24014-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch> Sent: Monday, June 29, 2015 1:36 AM
> To: netdev
> Cc: Duan Fugang-B38611; Duan Fugang-B38611; Cory Tusar; Andrew Lunn
> Subject: [RFC PATCHv4] net: fec: Ensure clocks are enabled while using
> mdio bus
> 
> When a switch is attached to the mdio bus, the mdio bus can be used while
> the interface is not open. If the IPG clock is not enabled, MDIO
> reads/writes will simply time out. Add support for runtime PM to control
> the clocks and other resources. Enable/disable the clocks using runtime
> PM, with open()/close() and mdio read()/write() function triggering
> runtime PM operations. Auto suspend is used, since there are likely to be
> a number of MDIO operations in a burst during DSA probe.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Cc: Duan Andy <fugang.duan@freescale.com>
> ---
> 
> RFC since net-next is closed for the merge window. Please send comments,
> Acked-by, etc, and i will then resubmit once net-next reopens.
> 
> 
>  drivers/net/ethernet/freescale/fec_main.c | 62 ++++++++++++++++++++++---
> ------
>  1 file changed, 45 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index bf4cf3fbb5f2..9b4d53132180 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -24,6 +24,7 @@
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/string.h>
> +#include <linux/pm_runtime.h>
>  #include <linux/ptrace.h>
>  #include <linux/errno.h>
>  #include <linux/ioport.h>
> @@ -77,6 +78,7 @@ static void fec_enet_itr_coal_init(struct net_device
> *ndev);
>  #define FEC_ENET_RAEM_V	0x8
>  #define FEC_ENET_RAFL_V	0x8
>  #define FEC_ENET_OPD_V	0xFFF0
> +#define FEC_MDIO_PM_TIMEOUT  100 /* ms */
> 
>  static struct platform_device_id fec_devtype[] = {
>  	{
> @@ -1763,11 +1765,15 @@ static void fec_enet_adjust_link(struct
> net_device *ndev)  static int fec_enet_mdio_read(struct mii_bus *bus, int
> mii_id, int regnum)  {
>  	struct fec_enet_private *fep = bus->priv;
> +	struct device *dev = &fep->pdev->dev;

In probe(), you enable runtime pm for ndev->dev, but other functions you use pdev->dev
ndev->dev.parent = pdev->dev


>  	unsigned long time_left;
> +	int ret = 0;
> 
>  	fep->mii_timeout = 0;
>  	init_completion(&fep->mdio_done);
> 
> +	pm_runtime_get_sync(dev);
> +
Maybe you need to add check the return value in here like:

Ret = pm_runtime_get_sync(dev);
if (IS_ERR_VALUE(ret))
	return ret;


>  	/* start a read op */
>  	writel(FEC_MMFR_ST | FEC_MMFR_OP_READ |
>  		FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) | @@ -1779,22
> +1785,32 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id,
> int regnum)
>  	if (time_left == 0) {
>  		fep->mii_timeout = 1;
>  		netdev_err(fep->netdev, "MDIO read timeout\n");
> -		return -ETIMEDOUT;
> +		ret = -ETIMEDOUT;
> +		goto out;
>  	}
> 
> -	/* return value */
> -	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> +	ret = FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> +
> +out:
> +	pm_runtime_mark_last_busy(dev);
> +	pm_runtime_put_autosuspend(dev);
> +
> +	return ret;
>  }
> 
>  static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int
> regnum,
>  			   u16 value)
>  {
>  	struct fec_enet_private *fep = bus->priv;
> +	struct device *dev = &fep->pdev->dev;

Same as above...

>  	unsigned long time_left;
> +	int ret = 0;
> 
>  	fep->mii_timeout = 0;
>  	init_completion(&fep->mdio_done);
> 
> +	pm_runtime_get_sync(dev);
> +

Same as above...


>  	/* start a write op */
>  	writel(FEC_MMFR_ST | FEC_MMFR_OP_WRITE |
>  		FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) | @@ -1807,10
> +1823,13 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int
> mii_id, int regnum,
>  	if (time_left == 0) {
>  		fep->mii_timeout = 1;
>  		netdev_err(fep->netdev, "MDIO write timeout\n");
> -		return -ETIMEDOUT;
> +		ret  = -ETIMEDOUT;
>  	}
> 
> -	return 0;
> +	pm_runtime_mark_last_busy(dev);
> +	pm_runtime_put_autosuspend(dev);
> +
> +	return ret;
>  }
> 
>  static int fec_enet_clk_enable(struct net_device *ndev, bool enable) @@
> -2844,9 +2863,7 @@ fec_enet_open(struct net_device *ndev)
>  	int ret;
> 
>  	pinctrl_pm_select_default_state(&fep->pdev->dev);
> -	ret = fec_enet_clk_enable(ndev, true);
> -	if (ret)
> -		return ret;
> +	pm_runtime_get_sync(&fep->pdev->dev);

Add return value check

> 
>  	/* I should reset the ring buffers here, but I don't yet know
>  	 * a simple way to do that.
> @@ -2874,7 +2891,8 @@ fec_enet_open(struct net_device *ndev)
>  err_enet_mii_probe:
>  	fec_enet_free_buffers(ndev);
>  err_enet_alloc:
> -	fec_enet_clk_enable(ndev, false);
> +	pm_runtime_mark_last_busy(&fep->pdev->dev);
> +	pm_runtime_put_autosuspend(&fep->pdev->dev);
>  	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
>  	return ret;
>  }
> @@ -2895,8 +2913,10 @@ fec_enet_close(struct net_device *ndev)
>  	phy_disconnect(fep->phy_dev);
>  	fep->phy_dev = NULL;
> 
> -	fec_enet_clk_enable(ndev, false);
>  	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
> +	pm_runtime_mark_last_busy(&fep->pdev->dev);
> +	pm_runtime_put_autosuspend(&fep->pdev->dev);
> +
>  	fec_enet_free_buffers(ndev);
> 
>  	return 0;
> @@ -3426,8 +3446,9 @@ fec_probe(struct platform_device *pdev)
> 
>  	/* Carrier starts down, phylib will bring it up */
>  	netif_carrier_off(ndev);
> -	fec_enet_clk_enable(ndev, false);
>  	pinctrl_pm_select_sleep_state(&pdev->dev);
> +	pm_runtime_set_active(&ndev->dev);
> +	pm_runtime_enable(&ndev->dev);
> 
>  	ret = register_netdev(ndev);
>  	if (ret)
> @@ -3441,6 +3462,12 @@ fec_probe(struct platform_device *pdev)
> 
>  	fep->rx_copybreak = COPYBREAK_DEFAULT;
>  	INIT_WORK(&fep->tx_timeout_work, fec_enet_timeout_work);
> +
> +	pm_runtime_set_autosuspend_delay(&ndev->dev, FEC_MDIO_PM_TIMEOUT);
> +	pm_runtime_use_autosuspend(&ndev->dev);
> +	pm_runtime_mark_last_busy(&ndev->dev);
> +	pm_runtime_put_autosuspend(&ndev->dev);
> +
>  	return 0;
> 
>  failed_register:
> @@ -3496,10 +3523,11 @@ static int __maybe_unused fec_suspend(struct
> device *dev)
>  		netif_device_detach(ndev);
>  		netif_tx_unlock_bh(ndev);
>  		fec_stop(ndev);
> -		fec_enet_clk_enable(ndev, false);
>  		if (!(fep->wol_flag & FEC_WOL_FLAG_ENABLE))
>  			pinctrl_pm_select_sleep_state(&fep->pdev->dev);
>  	}
> +
> +	fec_enet_clk_enable(ndev, false);

Why do you move out the api from netif runnig condition ?

>  	rtnl_unlock();
> 
>  	if (fep->reg_phy && !(fep->wol_flag & FEC_WOL_FLAG_ENABLE)) @@ -
> 3529,12 +3557,12 @@ static int __maybe_unused fec_resume(struct device
> *dev)
>  	}
> 
>  	rtnl_lock();
> +	ret = fec_enet_clk_enable(ndev, true);
> +	if (ret) {
> +		rtnl_unlock();
> +		goto failed_clk;
> +	}

Same as above...

>  	if (netif_running(ndev)) {
> -		ret = fec_enet_clk_enable(ndev, true);
> -		if (ret) {
> -			rtnl_unlock();
> -			goto failed_clk;
> -		}
>  		if (fep->wol_flag & FEC_WOL_FLAG_ENABLE) {
>  			if (pdata && pdata->sleep_mode_enable)
>  				pdata->sleep_mode_enable(false);
> --
> 2.1.4

The last, why don't you implement the runtime pm callback in the patch ?
You should disable/enable clocks in the callback as my previous mail comments.
