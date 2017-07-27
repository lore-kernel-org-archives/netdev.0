From: Laura Abbott <labbott@redhat.com>
Subject: Re: [PATCH net] xgene: Don't fail probe, if there is no clk resource
 for SGMII interfaces
Date: Thu, 27 Jul 2017 14:03:42 -0700
Message-ID: <22ee6284-7b23-7664-d6cf-23687f09a3be@redhat.com>
References: <20170713092144.31751508094@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        isubramanian@apm.com, kchudgar@apm.com, qnguyen@apm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170713092144.31751508094@solo.franken.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/13/2017 01:57 AM, Thomas Bogendoerfer wrote:
> From: Thomas Bogendoerfer <tbogendoerfer@suse.de>
> 
> This change fixes following problem
> 
> [    1.827940] xgene-enet: probe of 1f210030.ethernet failed with error -2
> 
> which leads to a missing ethernet interface (reproducable at least on
> Gigabyte MP30-AR0 and APM Mustang systems).
> 
> The check for a valid clk resource fails, because DT doesn't provide a
> clock for sgenet1. But the driver doesn't use this clk, if the ethernet
> port is connected via SGMII. Therefore this patch avoids probing for clk
> on SGMII interfaces.
> 
> Fixes: 9aea7779b764 drivers: net: xgene: Fix crash on DT systems
> Signed-off-by: Thomas Bogendoerfer <tbogendoerfer@suse.de>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 22 ++++++++++++----------
>  1 file changed, 12 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index d3906f6b01bd..86058a9f3417 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -1785,16 +1785,18 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>  
>  	xgene_enet_gpiod_get(pdata);
>  
> -	pdata->clk = devm_clk_get(&pdev->dev, NULL);
> -	if (IS_ERR(pdata->clk)) {
> -		/* Abort if the clock is defined but couldn't be retrived.
> -		 * Always abort if the clock is missing on DT system as
> -		 * the driver can't cope with this case.
> -		 */
> -		if (PTR_ERR(pdata->clk) != -ENOENT || dev->of_node)
> -			return PTR_ERR(pdata->clk);
> -		/* Firmware may have set up the clock already. */
> -		dev_info(dev, "clocks have been setup already\n");
> +	if (pdata->phy_mode != PHY_INTERFACE_MODE_SGMII) {
> +		pdata->clk = devm_clk_get(&pdev->dev, NULL);
> +		if (IS_ERR(pdata->clk)) {
> +			/* Abort if the clock is defined but couldn't be
> +			 * retrived. Always abort if the clock is missing on
> +			 * DT system as the driver can't cope with this case.
> +			 */
> +			if (PTR_ERR(pdata->clk) != -ENOENT || dev->of_node)
> +				return PTR_ERR(pdata->clk);
> +			/* Firmware may have set up the clock already. */
> +			dev_info(dev, "clocks have been setup already\n");
> +		}
>  	}
>  
>  	if (pdata->phy_mode != PHY_INTERFACE_MODE_XGMII)
> 

This change causes boot failures for me on my APM Mustang system running
Fedora rawhide:

[   16.669089] Synchronous External Abort: synchronous external abort (0x9600000
[   16.669099] Internal error: : 96000010 [#1] SMP                              
[   16.669103] Modules linked in: xgene_enet(+) at803x realtek mdio_xgene xgenes
[   16.669127] CPU: 2 PID: 534 Comm: systemd-udevd Not tainted 4.13.0-0.rc1.git1
[   16.669128] Hardware name: AppliedMicro X-Gene Mustang Board/X-Gene Mustang 6
[   16.669131] task: ffff8003e6f8ce00 task.stack: ffff8003e4fd8000              
[   16.669144] PC is at xgene_enet_wr_mac+0xa0/0x128 [xgene_enet]               
[   16.669152] LR is at xgene_enet_wr_mac+0x64/0x128 [xgene_enet] 

<snip>
           
[   16.669345] [<ffff000000de19f0>] xgene_enet_wr_mac+0xa0/0x128 [xgene_enet]   
[   16.669354] [<ffff000000de2fc0>] xgene_sgmac_reset+0x28/0x48 [xgene_enet]    
[   16.669362] [<ffff000000de3b50>] xgene_sgmac_init+0x1e0/0x2e8 [xgene_enet]   
[   16.669370] [<ffff000000de8564>] xgene_enet_probe+0xfa4/0x1368 [xgene_enet]  
[   16.669376] [<ffff0000086f14f0>] platform_drv_probe+0x60/0xc0                
[   16.669379] [<ffff0000086ee86c>] driver_probe_device+0x31c/0x458             
[   16.669381] [<ffff0000086eea8c>] __driver_attach+0xe4/0x130                  
[   16.669384] [<ffff0000086ebfd4>] bus_for_each_dev+0x5c/0xa8                  
[   16.669386] [<ffff0000086edf30>] driver_attach+0x30/0x40                     
[   16.669388] [<ffff0000086ed8d0>] bus_add_driver+0x220/0x2c0                  
[   16.669390] [<ffff0000086efd04>] driver_register+0x6c/0x118                  
[   16.669392] [<ffff0000086f142c>] __platform_driver_register+0x54/0x60        
[   16.669400] [<ffff000000e05014>] xgene_enet_driver_init+0x14/0x1000 [xgene_e]
[   16.669404] [<ffff000008083834>] do_one_initcall+0x44/0x138                  
[   16.669408] [<ffff0000081a327c>] do_init_module+0x64/0x1d0                   
[   16.669410] [<ffff0000081a1dc4>] load_module+0x151c/0x1770                   
[   16.669413] [<ffff0000081a2330>] SyS_finit_module+0xd8/0xf0                  
[   16.669415] [<ffff00000808364c>] __sys_trace_return+0x0/0x4                  
[   16.669418] Code: 14000004 d503201f d28218e0 95f24031 (b94002a2)     

I suspect the clock is actually needed on some systems.

Thanks,
Laura
