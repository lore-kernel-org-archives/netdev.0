From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH net 1/7] net: ethernet: ti: cpsw: fix bad register access
 in probe error path
Date: Wed, 16 Nov 2016 14:33:18 -0600
Message-ID: <664c1f10-dd31-8566-852f-ee5ca0b5c46e@ti.com>
References: <1479306916-27673-1-git-send-email-johan@kernel.org>
 <1479306916-27673-2-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Johan Hovold <johan@kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306916-27673-2-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/16/2016 08:35 AM, Johan Hovold wrote:
> Make sure to resume the platform device to enable clocks before
> accessing the CPSW registers in the probe error path (e.g. for deferred
> probe).
> 
> Unhandled fault: external abort on non-linefetch (0x1008) at 0xd0872d08
> ...
> [<c04fabcc>] (cpsw_ale_control_set) from [<c04fb8b4>] (cpsw_ale_destroy+0x2c/0x44)
> [<c04fb8b4>] (cpsw_ale_destroy) from [<c04fea58>] (cpsw_probe+0xbd0/0x10c4)
> [<c04fea58>] (cpsw_probe) from [<c047b2a0>] (platform_drv_probe+0x5c/0xc0)
> 
> Note that in the unlikely event of a runtime-resume failure, we'll leak
> the ale struct.
> 
> Fixes: df828598a755 ("netdev: driver: ethernet: Add TI CPSW driver")
> Signed-off-by: Johan Hovold <johan@kernel.org>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index c6cff3d2ff05..5bc5e6189661 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -2818,7 +2818,12 @@ static int cpsw_probe(struct platform_device *pdev)
>  	return 0;
>  
>  clean_ale_ret:
> -	cpsw_ale_destroy(cpsw->ale);
> +	if (pm_runtime_get_sync(&pdev->dev) < 0) {
> +		pm_runtime_put_noidle(&pdev->dev);
> +	} else {
> +		cpsw_ale_destroy(cpsw->ale);
> +		pm_runtime_put_sync(&pdev->dev);
> +	}
>  clean_dma_ret:
>  	cpdma_ctlr_destroy(cpsw->dma);
>  clean_runtime_disable_ret:
> 

I think, wouldn't it be logically more simple to just keep CPSW PM runtime enabled during probe?
Like in below diff (not tested):

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 0548e56..deaac1b 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2657,13 +2657,12 @@ static int cpsw_probe(struct platform_device *pdev)
                goto clean_runtime_disable_ret;
        }
        cpsw->version = readl(&cpsw->regs->id_ver);
-       pm_runtime_put_sync(&pdev->dev);
 
        res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
        cpsw->wr_regs = devm_ioremap_resource(&pdev->dev, res);
        if (IS_ERR(cpsw->wr_regs)) {
                ret = PTR_ERR(cpsw->wr_regs);
-               goto clean_runtime_disable_ret;
+               goto clean_runtime_put_ret;
        }
 
        memset(&dma_params, 0, sizeof(dma_params));
@@ -2700,7 +2699,7 @@ static int cpsw_probe(struct platform_device *pdev)
        default:
                dev_err(priv->dev, "unknown version 0x%08x\n", cpsw->version);
                ret = -ENODEV;
-               goto clean_runtime_disable_ret;
+               goto clean_runtime_put_ret;
        }
        for (i = 0; i < cpsw->data.slaves; i++) {
                struct cpsw_slave *slave = &cpsw->slaves[i];
@@ -2729,7 +2728,7 @@ static int cpsw_probe(struct platform_device *pdev)
        if (!cpsw->dma) {
                dev_err(priv->dev, "error initializing dma\n");
                ret = -ENOMEM;
-               goto clean_runtime_disable_ret;
+               goto clean_runtime_put_ret;
        }
 
        cpsw->txch[0] = cpdma_chan_create(cpsw->dma, 0, cpsw_tx_handler, 0);
@@ -2831,12 +2830,16 @@ static int cpsw_probe(struct platform_device *pdev)
                }
        }
 
+       pm_runtime_put(&pdev->dev);
+
        return 0;
 
 clean_ale_ret:
        cpsw_ale_destroy(cpsw->ale);
 clean_dma_ret:
        cpdma_ctlr_destroy(cpsw->dma);
+clean_runtime_put_ret:
+       pm_runtime_put_sync(&pdev->dev);
 clean_runtime_disable_ret:
        pm_runtime_disable(&pdev->dev);
 clean_ndev_ret:

-- 
regards,
-grygorii
