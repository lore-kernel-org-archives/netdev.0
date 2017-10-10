From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: ftgmac100: Request clock and set speed
Date: Mon, 9 Oct 2017 22:04:07 -0700
Message-ID: <0150f64f-6093-1cca-465b-8ec158abe7e6@gmail.com>
References: <20171010044925.21078-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew Jeffery <andrew@aj.id.au>
To: Joel Stanley <joel@jms.id.au>,
        "David S . Miller" <davem@davemloft.net>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35427 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdJJFEL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 01:04:11 -0400
In-Reply-To: <20171010044925.21078-1-joel@jms.id.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/09/2017 09:49 PM, Joel Stanley wrote:
> According to the ASPEED datasheet, gigabit speeds require a clock of
> 100MHz or higher. Other speeds require 25MHz or higher.
> 
> Signed-off-by: Joel Stanley <joel@jms.id.au>
> ---

> @@ -161,6 +170,9 @@ static int ftgmac100_reset_and_config_mac(struct ftgmac100 *priv)
>  		break;
>  	}
>  
> +	if (freq && priv->clk)
> +		clk_set_rate(priv->clk, freq);

Checking for priv->clk should not be necessary all public clk APIs can
deal with a NULL clock pointer.

> +
>  	/* (Re)initialize the queue pointers */
>  	priv->rx_pointer = 0;
>  	priv->tx_clean_pointer = 0;
> @@ -1775,6 +1787,13 @@ static int ftgmac100_probe(struct platform_device *pdev)
>  	priv->dev = &pdev->dev;
>  	INIT_WORK(&priv->reset_task, ftgmac100_reset_task);
>  
> +	/* Enable clock if present */
> +	priv->clk = devm_clk_get(&pdev->dev, NULL);
> +	if (!IS_ERR(priv->clk))
> +		clk_prepare_enable(priv->clk);
> +	else
> +		priv->clk = NULL;

Same here.

> +
>  	/* map io memory */
>  	priv->res = request_mem_region(res->start, resource_size(res),
>  				       dev_name(&pdev->dev));
> @@ -1883,6 +1902,9 @@ static int ftgmac100_remove(struct platform_device *pdev)
>  
>  	unregister_netdev(netdev);
>  
> +	if (priv->clk)
> +		clk_disable_unprepare(priv->clk);

And here.

> +
>  	/* There's a small chance the reset task will have been re-queued,
>  	 * during stop, make sure it's gone before we free the structure.
>  	 */
> 

-- 
Florian
