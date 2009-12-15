From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 3/4] fec: add support for Freescale i.MX25 PDK (3DS)
Date: Tue, 15 Dec 2009 21:52:24 +1000
Message-ID: <4B277878.1050804@snapgear.com>
References: <cover.1260785451.git.baruch@tkos.co.il>	<fb518184b206ec2727deda111cc5364134ace69a.1260785451.git.baruch@tkos.co.il>	<20091214103348.GV15126@pengutronix.de>
	<20091215083142.GB18290@jasper.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20091215083142.GB18290@jasper.tkos.co.il>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Baruch,

On 12/15/2009 06:31 PM, Baruch Siach wrote:
> Hi Sascha,
>
> On Mon, Dec 14, 2009 at 11:33:48AM +0100, Sascha Hauer wrote:
>> On Mon, Dec 14, 2009 at 12:19:41PM +0200, Baruch Siach wrote:
>>> +	if (!machine_is_mx25_3ds())
>>> +		return;
>>
>> We should add a flag in platform data for this. Unfortunately the fec
>> driver has no platform data at all at the moment, so this requires some
>> more work.
>
> Here is an updated patch which adds platform data to fec. I've also addressed
> the comment of Greg. I'll post a patch updating the i.MX25 PDK platform code
> shortly.
>
> baruch
>
>> From ff971bbec84501cab714703786dd4058db4a89e4 Mon Sep 17 00:00:00 2001
> Message-Id:<ff971bbec84501cab714703786dd4058db4a89e4.1260865551.git.baruch@tkos.co.il>
> From: Baruch Siach<baruch@tkos.co.il>
> Date: Mon, 14 Dec 2009 10:36:50 +0200
> Subject: [PATCH] fec: add support for PHY interface platform data
>
> The i.MX25 PDK uses RMII to communicate with its PHY. This patch adds the
> ability to configure RMII, based on platform data.
>
> Signed-off-by: Baruch Siach<baruch@tkos.co.il>
> ---
>   drivers/net/fec.c   |   22 ++++++++++++++++++++++
>   drivers/net/fec.h   |    2 ++
>   include/linux/fec.h |   21 +++++++++++++++++++++
>   3 files changed, 45 insertions(+), 0 deletions(-)
>   create mode 100644 include/linux/fec.h
>
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 16a1d58..b9a5822 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -40,6 +40,7 @@
>   #include<linux/irq.h>
>   #include<linux/clk.h>
>   #include<linux/platform_device.h>
> +#include<linux/fec.h>
>
>   #include<asm/cacheflush.h>
>
> @@ -198,6 +199,7 @@ struct fec_enet_private {
>   	uint	phy_speed;
>   	phy_info_t const	*phy;
>   	struct work_struct phy_task;
> +	phy_interface_t	phy_interface;
>
>   	uint	sequence_done;
>   	uint	mii_phy_task_queued;
> @@ -1810,6 +1812,21 @@ fec_restart(struct net_device *dev, int duplex)
>   	/* Set MII speed */
>   	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>
> +#ifndef CONFIG_M5272

I would suggest making this conditional on FEC_MIIGSK_ENR.
Although the CONFIG_M5272 is the only case here currently,
that may change over the years. And using this here may not
be obvious to the causual code reader, since the register
offset definitions don't explicitly key on CONFIG_M5272.

Regards
Greg



> +	if (fep->phy_interface == PHY_INTERFACE_MODE_RMII) {
> +		/* disable the gasket and wait */
> +		writel(0, fep->hwp + FEC_MIIGSK_ENR);
> +		while (readl(fep->hwp + FEC_MIIGSK_ENR)&  4)
> +			udelay(1);
> +
> +		/* configure the gasket: RMII, 50 MHz, no loopback, no echo */
> +		writel(1, fep->hwp + FEC_MIIGSK_CFGR);
> +
> +		/* re-enable the gasket */
> +		writel(2, fep->hwp + FEC_MIIGSK_ENR);
> +	}
> +#endif
> +
>   	/* And last, enable the transmit and receive processing */
>   	writel(2, fep->hwp + FEC_ECNTRL);
>   	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
> @@ -1847,6 +1864,7 @@ static int __devinit
>   fec_probe(struct platform_device *pdev)
>   {
>   	struct fec_enet_private *fep;
> +	struct fec_platform_data *pdata;
>   	struct net_device *ndev;
>   	int i, irq, ret = 0;
>   	struct resource *r;
> @@ -1879,6 +1897,10 @@ fec_probe(struct platform_device *pdev)
>
>   	platform_set_drvdata(pdev, ndev);
>
> +	pdata = pdev->dev.platform_data;
> +	if (pdata)
> +		fep->phy_interface = pdata->phy;
> +
>   	/* This device has up to three irqs on some platforms */
>   	for (i = 0; i<  3; i++) {
>   		irq = platform_get_irq(pdev, i);
> diff --git a/drivers/net/fec.h b/drivers/net/fec.h
> index cc47f3f..2c48b25 100644
> --- a/drivers/net/fec.h
> +++ b/drivers/net/fec.h
> @@ -43,6 +43,8 @@
>   #define FEC_R_DES_START		0x180 /* Receive descriptor ring */
>   #define FEC_X_DES_START		0x184 /* Transmit descriptor ring */
>   #define FEC_R_BUFF_SIZE		0x188 /* Maximum receive buff size */
> +#define FEC_MIIGSK_CFGR		0x300 /* MIIGSK Configuration reg */
> +#define FEC_MIIGSK_ENR		0x308 /* MIIGSK Enable reg */
>
>   #else
>
> diff --git a/include/linux/fec.h b/include/linux/fec.h
> new file mode 100644
> index 0000000..5d3523d
> --- /dev/null
> +++ b/include/linux/fec.h
> @@ -0,0 +1,21 @@
> +/* include/linux/fec.h
> + *
> + * Copyright (c) 2009 Orex Computed Radiography
> + *   Baruch Siach<baruch@tkos.co.il>
> + *
> + * Header file for the FEC platform data
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +#ifndef __LINUX_FEC_H__
> +#define __LINUX_FEC_H__
> +
> +#include<linux/phy.h>
> +
> +struct fec_platform_data {
> +	phy_interface_t phy;
> +};
> +
> +#endif

-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close,                            FAX:         +61 7 3891 3630
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
