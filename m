From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH V2] net: stmmac: socfpga: Remove re-registration of reset
 controller
Date: Thu, 21 Apr 2016 00:27:11 +0200
Message-ID: <5718023F.1060707@denx.de>
References: <1461110753-7641-1-git-send-email-marex@denx.de> <5717F1DF.1020004@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
	Matthew Gerlach <mgerlach@opensource.altera.com>,
	"David S . Miller" <davem@davemloft.net>
To: Dinh Nguyen <dinguyen@opensource.altera.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:41865 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbcDTW1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 18:27:22 -0400
In-Reply-To: <5717F1DF.1020004@opensource.altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2016 11:17 PM, Dinh Nguyen wrote:
> On 04/19/2016 07:05 PM, Marek Vasut wrote:
>> Both socfpga_dwmac_parse_data() in dwmac-socfpga.c and stmmac_dvr_probe()
>> in stmmac_main.c functions call devm_reset_control_get() to register an
>> reset controller for the stmmac. This results in an attempt to register
>> two reset controllers for the same non-shared reset line.
>>
>> The first attempt to register the reset controller works fine. The second
>> attempt fails with warning from the reset controller core, see below.
>> The warning is produced because the reset line is non-shared and thus
>> it is allowed to have only up-to one reset controller associated with
>> that reset line, not two or more.
>>
>> The solution is not great. Since the hardware needs to toggle the reset
>> before calling stmmac_dvr_probe() to perform mandatory preconfiguration,
>> this patch splits socfpga_dwmac_init_probe() from socfpga_dwmac_init().
>>
>> The socfpga_dwmac_init_probe() temporarily registers the reset controller,
>> performs the pre-configuration and unregisters the reset controller again.
>> This function is only called from the socfpga_dwmac_probe().
>>
>> The original socfpga_dwmac_init() is tweaked to use reset controller
>> pointer from the stmmac_priv (private data of the stmmac core) instead
>> of the local instance, which was used before.
>>
>> Finally, plat_dat->exit and socfpga_dwmac_exit() is no longer necessary,
>> since the functionality is already performed by the stmmac core.
>>
>> ------------[ cut here ]------------
>> WARNING: CPU: 0 PID: 1 at drivers/reset/core.c:187 __of_reset_control_get+0x218/0x270
>> Modules linked in:
>> CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.6.0-rc4-next-20160419-00015-gabb2477-dirty #4
>> Hardware name: Altera SOCFPGA
>> [<c010f290>] (unwind_backtrace) from [<c010b82c>] (show_stack+0x10/0x14)
>> [<c010b82c>] (show_stack) from [<c0373da4>] (dump_stack+0x94/0xa8)
>> [<c0373da4>] (dump_stack) from [<c011bcc0>] (__warn+0xec/0x104)
>> [<c011bcc0>] (__warn) from [<c011bd88>] (warn_slowpath_null+0x20/0x28)
>> [<c011bd88>] (warn_slowpath_null) from [<c03a6eb4>] (__of_reset_control_get+0x218/0x270)
>> [<c03a6eb4>] (__of_reset_control_get) from [<c03a701c>] (__devm_reset_control_get+0x54/0x90)
>> [<c03a701c>] (__devm_reset_control_get) from [<c041fa30>] (stmmac_dvr_probe+0x1b4/0x8e8)
>> [<c041fa30>] (stmmac_dvr_probe) from [<c04298c8>] (socfpga_dwmac_probe+0x1b8/0x28c)
>> [<c04298c8>] (socfpga_dwmac_probe) from [<c03d6ffc>] (platform_drv_probe+0x4c/0xb0)
>> [<c03d6ffc>] (platform_drv_probe) from [<c03d54ec>] (driver_probe_device+0x224/0x2bc)
>> [<c03d54ec>] (driver_probe_device) from [<c03d5630>] (__driver_attach+0xac/0xb0)
>> [<c03d5630>] (__driver_attach) from [<c03d382c>] (bus_for_each_dev+0x6c/0xa0)
>> [<c03d382c>] (bus_for_each_dev) from [<c03d4ad4>] (bus_add_driver+0x1a4/0x21c)
>> [<c03d4ad4>] (bus_add_driver) from [<c03d60ac>] (driver_register+0x78/0xf8)
>> [<c03d60ac>] (driver_register) from [<c0101760>] (do_one_initcall+0x40/0x170)
>> [<c0101760>] (do_one_initcall) from [<c0800e38>] (kernel_init_freeable+0x1dc/0x27c)
>> [<c0800e38>] (kernel_init_freeable) from [<c05d1bd4>] (kernel_init+0x8/0x114)
>> [<c05d1bd4>] (kernel_init) from [<c01076f8>] (ret_from_fork+0x14/0x3c)
>> ---[ end trace 059d2fbe87608fa9 ]---
>>
>> Signed-off-by: Marek Vasut <marex@denx.de>
>> Cc: Matthew Gerlach <mgerlach@opensource.altera.com>
>> Cc: Dinh Nguyen <dinguyen@opensource.altera.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> ---
>> V2: Add missing stmmac_rst = NULL; into socfpga_dwmac_init_probe()
>> ---
>>  .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 70 ++++++++++++----------
>>  1 file changed, 39 insertions(+), 31 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> index 76d671e..5885a2e 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> @@ -49,7 +49,6 @@ struct socfpga_dwmac {
>>  	u32	reg_shift;
>>  	struct	device *dev;
>>  	struct regmap *sys_mgr_base_addr;
>> -	struct reset_control *stmmac_rst;
>>  	void __iomem *splitter_base;
>>  	bool f2h_ptp_ref_clk;
>>  };
>> @@ -92,15 +91,6 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>>  	struct device_node *np_splitter;
>>  	struct resource res_splitter;
>>  
>> -	dwmac->stmmac_rst = devm_reset_control_get(dev,
>> -						  STMMAC_RESOURCE_NAME);
>> -	if (IS_ERR(dwmac->stmmac_rst)) {
>> -		dev_info(dev, "Could not get reset control!\n");
>> -		if (PTR_ERR(dwmac->stmmac_rst) == -EPROBE_DEFER)
>> -			return -EPROBE_DEFER;
>> -		dwmac->stmmac_rst = NULL;
>> -	}
>> -
>>  	dwmac->interface = of_get_phy_mode(np);
>>  
>>  	sys_mgr_base_addr = syscon_regmap_lookup_by_phandle(np, "altr,sysmgr-syscon");
>> @@ -194,30 +184,23 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
>>  	return 0;
>>  }
>>  
>> -static void socfpga_dwmac_exit(struct platform_device *pdev, void *priv)
>> -{
>> -	struct socfpga_dwmac	*dwmac = priv;
>> -
>> -	/* On socfpga platform exit, assert and hold reset to the
>> -	 * enet controller - the default state after a hard reset.
>> -	 */
>> -	if (dwmac->stmmac_rst)
>> -		reset_control_assert(dwmac->stmmac_rst);
>> -}
>> -
>>  static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
>>  {
>> -	struct socfpga_dwmac	*dwmac = priv;
>> +	struct socfpga_dwmac *dwmac = priv;
>>  	struct net_device *ndev = platform_get_drvdata(pdev);
>>  	struct stmmac_priv *stpriv = NULL;
>>  	int ret = 0;
>>  
>> -	if (ndev)
>> -		stpriv = netdev_priv(ndev);
>> +	if (!ndev)
>> +		return -EINVAL;
>> +
>> +	stpriv = netdev_priv(ndev);
>> +	if (!stpriv)
>> +		return -EINVAL;
>>  
>>  	/* Assert reset to the enet controller before changing the phy mode */
>> -	if (dwmac->stmmac_rst)
>> -		reset_control_assert(dwmac->stmmac_rst);
>> +	if (stpriv->stmmac_rst)
>> +		reset_control_assert(stpriv->stmmac_rst);
>>  
>>  	/* Setup the phy mode in the system manager registers according to
>>  	 * devicetree configuration
>> @@ -227,8 +210,8 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
>>  	/* Deassert reset for the phy configuration to be sampled by
>>  	 * the enet controller, and operation to start in requested mode
>>  	 */
>> -	if (dwmac->stmmac_rst)
>> -		reset_control_deassert(dwmac->stmmac_rst);
>> +	if (stpriv->stmmac_rst)
>> +		reset_control_deassert(stpriv->stmmac_rst);
>>  
>>  	/* Before the enet controller is suspended, the phy is suspended.
>>  	 * This causes the phy clock to be gated. The enet controller is
>> @@ -245,12 +228,38 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
>>  	 * control register 0, and can be modified by the phy driver
>>  	 * framework.
>>  	 */
>> -	if (stpriv && stpriv->phydev)
>> +	if (stpriv->phydev)
>>  		phy_resume(stpriv->phydev);
>>  
>>  	return ret;
>>  }
>>  
>> +static int socfpga_dwmac_init_probe(struct socfpga_dwmac *dwmac)
>> +{
>> +	struct reset_control *stmmac_rst;
>> +	int ret;
>> +
>> +	stmmac_rst = reset_control_get(dwmac->dev, STMMAC_RESOURCE_NAME);
>> +	if (IS_ERR(stmmac_rst)) {
>> +		dev_info(dwmac->dev, "Could not get reset control!\n");
>> +		if (PTR_ERR(stmmac_rst) == -EPROBE_DEFER)
>> +			return -EPROBE_DEFER;
>> +		stmmac_rst = NULL;
>> +	}
>> +
>> +	if (stmmac_rst)
>> +		reset_control_assert(stmmac_rst);
>> +
>> +	ret = socfpga_dwmac_setup(dwmac);
>> +
>> +	if (stmmac_rst) {
>> +		reset_control_deassert(stmmac_rst);
>> +		reset_control_put(stmmac_rst);
>> +	}
>> +
>> +	return ret;
>> +}
> 
> I don't think you this function because...
> 
>> +
>>  static int socfpga_dwmac_probe(struct platform_device *pdev)
>>  {
>>  	struct plat_stmmacenet_data *plat_dat;
>> @@ -279,10 +288,9 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
>>  
>>  	plat_dat->bsp_priv = dwmac;
>>  	plat_dat->init = socfpga_dwmac_init;
>> -	plat_dat->exit = socfpga_dwmac_exit;
>>  	plat_dat->fix_mac_speed = socfpga_dwmac_fix_mac_speed;
>>  
>> -	ret = socfpga_dwmac_init(pdev, plat_dat->bsp_priv);
>> +	ret = socfpga_dwmac_init_probe(dwmac);
>>  	if (ret)
>>  		return ret;
>>  
>>
> 
> if you modify the patch to call stmmac_dvr_probe() before calling
> socfpga_dwmac_init(), then you would already have the reset control
> information.

I was under the impression that you must call socfpga_dwmac_init()
before stmmac_dvr_probe() for whatever hardware-related reason. If
you are absolutely certain this is not necessary, then that's just
perfect and the patch can be simplified even further -- just remove
the call to socfpga_dwmac_init() from probe altogether , the dwmac
core code will call plat_dat->init at the end of probe .

So shall we do that ? I am happy to spin V3 like that if you confirm
that it's legal to do things in the aforementioned order.

> Something like this:
> 
> ---------------------------------8<--------------------------------
> 
> @@ -269,14 +252,13 @@ static int socfpga_dwmac_probe(struct
> platform_device *pdev)
> 
>         plat_dat->bsp_priv = dwmac;
>         plat_dat->init = socfpga_dwmac_init;
> -       plat_dat->exit = socfpga_dwmac_exit;
>         plat_dat->fix_mac_speed = socfpga_dwmac_fix_mac_speed;
> 
> -       ret = socfpga_dwmac_init(pdev, plat_dat->bsp_priv);
> -       if (ret)
> -               return ret;
> +       ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
> 
> -       return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
> +       if (!ret)
> +               ret = socfpga_dwmac_init(pdev, plat_dat->bsp_priv);
> +       return ret;
>  }
> 
> 
> What do you think?



> Dinh
> 


-- 
Best regards,
Marek Vasut
