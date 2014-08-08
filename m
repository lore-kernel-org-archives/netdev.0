From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH 2/2] ethernet: arc: Add support for Rockchip SoC glue
 layer device tree bindings
Date: Fri, 08 Aug 2014 18:07:15 +0530
Message-ID: <53E4C47B.50906@gmail.com>
References: <1407500875-23851-1-git-send-email-romain.perier@gmail.com> <1407500875-23851-2-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: heiko@sntech.de, max.schwarz@online.de, b.galvani@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Romain Perier <romain.perier@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50520 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756622AbaHHMiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 08:38:46 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so7247433pad.39
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 05:38:46 -0700 (PDT)
In-Reply-To: <1407500875-23851-2-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2014 05:57 PM, Romain Perier wrote:
> This patch defines a platform glue layer for Rockchip SoCs which support
> arc-emac driver. It ensures that regulator for the rmii is on before trying
> to connect to the ethernet controller. It applies right speed and mode changes
> to the grf when ethernet settings changes.
>
(...)

> +static const struct of_device_id rockchip_emac_dt_ids[] = {
> +	{ .compatible = "rockchip,rk3066-emac", .data = (void *)rockchip_emac_soc_grf_offset },
> +	{ .compatible = "rockchip,rk3188-emac", .data = (void *)rockchip_emac_soc_grf_offset + 1 },
> +	{ /* Sentinel */ }
> +};
> +
> +MODULE_DEVICE_TABLE(of, rockchip_emac_dt_ids);
> +

Move these ids after probe and remove functionalities..

> +static int rockchip_grf_set_phy_speed(const struct rockchip_priv_data *emac, unsigned int speed)

(...)

> +static void rockchip_set_mac_speed(void *priv, unsigned int speed)
> +{
> +	struct rockchip_priv_data *emac = priv;
> +	int ret = 0;
> +
> +	ret = rockchip_grf_set_phy_speed(emac, speed);
> +	if (ret) {
> +		if (ret == -ENOTSUPP)
> +			pr_err("phy interface (%d) or speed (%u) not supported\n", emac->interface, speed);
> +		return ret;

This func() is void. So why are returning ret..?

> +	}
> +}
> +
> +static int rockchip_emac_probe(struct platform_device *pdev)
> +{
> +	struct rockchip_priv_data *emac = NULL;
> +	struct emac_platform_data *emac_plat_data = NULL;
> +	struct device *dev = &pdev->dev;
> +	const struct of_device_id *match = NULL;
> +	int ret = 0;
> +	u32 data = 0;
> +
> +	emac = dev_get_platdata(dev);
> +
> +	if (!emac) {
> +		emac = devm_kzalloc(dev, sizeof(*emac), GFP_KERNEL);
> +		if (!emac)
> +			return -ENOMEM;
> +	}
> +
> +	emac_plat_data = devm_kzalloc(dev, sizeof(*emac_plat_data), GFP_KERNEL);
> +	if (!emac_plat_data)
> +		return -ENOMEM;

one line space..?

(...)

> +        /* Optional regulator for PHY */
> +	emac->regulator = devm_regulator_get_optional(dev, "phy");
> +	if (IS_ERR(emac->regulator)) {
> +		if (PTR_ERR(emac->regulator) == -EPROBE_DEFER)
> +			return ERR_PTR(-EPROBE_DEFER);
> +		dev_info(dev, "no regulator found\n");

Its on error. So dev_err()..?

> +		emac->regulator = NULL;
> +	}
> +
> +	if (emac->regulator) {
> +		ret = regulator_enable(emac->regulator);
> +		if (ret)
> +			return ret;
> +	}
> +
> +	ret = rockchip_grf_set_phy_speed(emac, 100);
> +	if (ret) {
> +		if (ret == -ENOTSUPP)
> +			dev_err(dev, "phy interface not supported (%d)\n", emac->interface);
> +		return ret;
> +	}
> +
> +	return emac_drv_probe(dev, emac_plat_data);
> +}
> +
> +static int rockchip_emac_remove(struct platform_device *pdev)
> +{
> +	struct rockchip_priv_data *emac = dev_get_platdata(&pdev->dev);
> +	struct net_device *ndev = dev_get_drvdata(&pdev->dev);
> +
> +	if (emac->regulator)
> +		regulator_disable(emac->regulator);
> +	return emac_drv_remove(ndev);
> +}
> +
> +static struct platform_driver rockchip_emac_driver = {
> +	.probe = rockchip_emac_probe,
> +	.remove = rockchip_emac_remove,
> +	.driver = {
> +		.name = DRV_NAME,
> +		.owner = THIS_MODULE,

This field updated by module_platform_driver()

Thanks..

-- 
Regards,
Varka Bhadram.
