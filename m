From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [patch] net: moxa: fix an error code
Date: Wed, 02 Mar 2016 11:52:29 +0100
Message-ID: <7083740.CtlZQWRYiM@wuerfel>
References: <20160302101110.GI5533@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jonas Jensen <jonas.jensen@gmail.com>,
	Luis de Bethencourt <luis@debethencourt.com>,
	=?ISO-8859-1?Q?fran=E7ois?= romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:57663 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbcCBKwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 05:52:50 -0500
In-Reply-To: <20160302101110.GI5533@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 02 March 2016 13:11:10 Dan Carpenter wrote:
> We accidentally return IS_ERR(priv->base) which is 1 instead of
> PTR_ERR(priv->base) which is the error code.
> 
> Fixes: 6c821bd9edc9 ('net: Add MOXA ART SoCs ethernet driver')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>

nice catch!

> diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
> index 00cfd95..3e67f45 100644
> --- a/drivers/net/ethernet/moxa/moxart_ether.c
> +++ b/drivers/net/ethernet/moxa/moxart_ether.c
> @@ -474,9 +474,9 @@ static int moxart_mac_probe(struct platform_device *pdev)
>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	ndev->base_addr = res->start;
>  	priv->base = devm_ioremap_resource(p_dev, res);
> -	ret = IS_ERR(priv->base);
> -	if (ret) {
> +	if (IS_ERR(priv->base)) {
>  		dev_err(p_dev, "devm_ioremap_resource failed\n");
> +		ret = PTR_ERR(priv->base);
>  		goto init_fail;
>  	}

Did you find more of these?

it doesn't matter much either way, but if you do multiple such patches,
I'd suggest using a single PTR_ERR_OR_ZERO() instead of IS_ERR()+PTR_ERR().

I have found a couple of drivers in which that leads to better object
code, and avoids a warning about a possibly uninitialized variable
when the function gets inlined into another one (which won't happen
for this driver).

	Arnd
