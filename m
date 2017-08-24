From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [v2,3/3] can: m_can: Add PM Runtime
Date: Thu, 24 Aug 2017 14:00:54 +0530
Message-ID: <8037f5f9-d51f-99c3-f2e8-62c90e56a6fa@ti.com>
References: <20170724225142.19975-4-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux OMAP List <linux-omap@vger.kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Wenyou Yang <wenyou.yang@atmel.com>
To: Franklin Cooper <fcooper@ti.com>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-can@vger.kernel.org>, <wg@grandegger.com>,
        <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170724225142.19975-4-fcooper@ti.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ OMAP mailing list

On Tuesday 25 July 2017 04:21 AM, Franklin Cooper wrote:
> Add support for PM Runtime which is the new way to handle managing clocks.
> However, to avoid breaking SoCs not using PM_RUNTIME leave the old clk
> management approach in place.

Since hclk is the interface clock, I think at a minimum there needs to
be an assumption that pm_runtime_get_sync() will enable that clock and
make the module ready for access.

The only in-kernel user of this driver seems to be an atmel SoC. I am
ccing folks who added support for M_CAN on that SoC to see if hclk
management can be left to pm_runtime*() on their SoC.

If they are okay, I think its a good to atleast drop explicit hclk
enable disable in the driver. That way, we avoid double enable/disable
of interface clock (hclk).

> 
> PM_RUNTIME is required by OMAP based devices to handle clock management.
> Therefore, this allows future Texas Instruments SoCs that have the MCAN IP
> to work with this driver.
> 
> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>

Thanks,
Sekhar

> ---
>  drivers/net/can/m_can/m_can.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
> index ea48e59..93e23f5 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -23,6 +23,7 @@
>  #include <linux/of.h>
>  #include <linux/of_device.h>
>  #include <linux/platform_device.h>
> +#include <linux/pm_runtime.h>
>  #include <linux/iopoll.h>
>  #include <linux/can/dev.h>
>  
> @@ -633,11 +634,15 @@ static int m_can_clk_start(struct m_can_priv *priv)
>  	if (err)
>  		clk_disable_unprepare(priv->hclk);
>  
> +	pm_runtime_get_sync(priv->device);
> +
>  	return err;
>  }
>  
>  static void m_can_clk_stop(struct m_can_priv *priv)
>  {
> +	pm_runtime_put_sync(priv->device);
> +
>  	clk_disable_unprepare(priv->cclk);
>  	clk_disable_unprepare(priv->hclk);
>  }
> @@ -1582,6 +1587,8 @@ static int m_can_plat_probe(struct platform_device *pdev)
>  	/* Enable clocks. Necessary to read Core Release in order to determine
>  	 * M_CAN version
>  	 */
> +	pm_runtime_enable(&pdev->dev);
> +
>  	ret = clk_prepare_enable(hclk);
>  	if (ret)
>  		goto disable_hclk_ret;
> @@ -1626,6 +1633,8 @@ static int m_can_plat_probe(struct platform_device *pdev)
>  	 */
>  	tx_fifo_size = mram_config_vals[7];
>  
> +	pm_runtime_get_sync(&pdev->dev);
> +
>  	/* allocate the m_can device */
>  	dev = alloc_m_can_dev(pdev, addr, tx_fifo_size);
>  	if (!dev) {
> @@ -1670,6 +1679,7 @@ static int m_can_plat_probe(struct platform_device *pdev)
>  disable_hclk_ret:
>  	clk_disable_unprepare(hclk);
>  failed_ret:
> +	pm_runtime_put_sync(&pdev->dev);
>  	return ret;
>  }
>  
> @@ -1726,6 +1736,9 @@ static int m_can_plat_remove(struct platform_device *pdev)
>  	struct net_device *dev = platform_get_drvdata(pdev);
>  
>  	unregister_m_can_dev(dev);
> +
> +	pm_runtime_disable(&pdev->dev);
> +
>  	platform_set_drvdata(pdev, NULL);
>  
>  	free_m_can_dev(dev);
> 
