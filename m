From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [v2,1/3] can: m_can: Make hclk optional
Date: Thu, 24 Aug 2017 13:30:30 +0530
Message-ID: <6f574628-51cd-0db8-e5aa-e7ae4a9cf79a@ti.com>
References: <20170724225142.19975-2-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Kristo, Tero" <t-kristo@ti.com>, Tony Lindgren <tony@atomide.com>,
        Linux OMAP List <linux-omap@vger.kernel.org>
To: Franklin Cooper <fcooper@ti.com>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-can@vger.kernel.org>, <wg@grandegger.com>,
        <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170724225142.19975-2-fcooper@ti.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ some OMAP folks and Linux OMAP list

On Tuesday 25 July 2017 04:21 AM, Franklin Cooper wrote:
> Hclk is the MCAN's interface clock. However, for OMAP based devices such as
> DRA7 SoC family the interface clock is handled by hwmod. Therefore, this
> interface clock is managed by hwmod driver via pm_runtime_get and
> pm_runtime_put calls. Therefore, this interface clock isn't defined in DT
> and thus the driver shouldn't fail if this clock isn't found.

I agree that hclk is defined as interface clock for M_CAN IP on DRA76x.

However, there may be a need for the driver to know the value of hclk to
properly configure the RAM watchdog register which has a counter
counting down using hclk. Looks like the driver does not use the RAM
watchdog today. But if there is a need to configure it in future, it
might be a problem.

Is there a restriction in OMAP architecture against passing the
interface clock also in the 'clocks' property in DT. I have not tried it
myself, but wonder if you hit an issue that led to this patch.

> 
> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
> ---
> Version 2 changes:
> Used NULL instead of 0 for unused hclk handle
> 
>  drivers/net/can/m_can/m_can.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
> index f4947a7..ea48e59 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -1568,8 +1568,13 @@ static int m_can_plat_probe(struct platform_device *pdev)
>  	hclk = devm_clk_get(&pdev->dev, "hclk");
>  	cclk = devm_clk_get(&pdev->dev, "cclk");
>  
> -	if (IS_ERR(hclk) || IS_ERR(cclk)) {
> -		dev_err(&pdev->dev, "no clock found\n");
> +	if (IS_ERR(hclk)) {
> +		dev_warn(&pdev->dev, "hclk could not be found\n");
> +		hclk = NULL;

What is the purpose of NULL setting the clock. I think this is taking it
into a very implementation defined territory and the result could be
different on different architectures. See Russell's explanation here:
https://lkml.org/lkml/2016/11/10/799

Thanks,
Sekhar

> +	}
> +
> +	if (IS_ERR(cclk)) {
> +		dev_err(&pdev->dev, "cclk could not be found\n");
>  		ret = -ENODEV;
>  		goto failed_ret;
>  	}
> 
