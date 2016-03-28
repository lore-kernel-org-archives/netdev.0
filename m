From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: macb: Only call GPIO functions if there is a valid
 GPIO
Date: Mon, 28 Mar 2016 20:30:11 +0300
Message-ID: <56F96A23.4000001@cogentembedded.com>
References: <1459169262-3941-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	patches@opensource.wolfsonmicro.com
To: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>,
	nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459169262-3941-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/28/2016 03:47 PM, Charles Keepax wrote:

> GPIOlib will print warning messages if we call GPIO functions without a
> valid GPIO. Change the code to avoid doing so.
>
> Signed-off-by: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
> ---
>   drivers/net/ethernet/cadence/macb.c | 8 +++++---
>   1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 6619178..71bb42e 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2957,9 +2957,10 @@ static int macb_probe(struct platform_device *pdev)
>   	phy_node =  of_get_next_available_child(np, NULL);
>   	if (phy_node) {
>   		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
> -		if (gpio_is_valid(gpio))
> +		if (gpio_is_valid(gpio)) {
>   			bp->reset_gpio = gpio_to_desc(gpio);
> -		gpiod_direction_output(bp->reset_gpio, 1);
> +			gpiod_direction_output(bp->reset_gpio, 1);
> +		}

    Oops, sorry for missing this while fixing this code.

>   	}
>   	of_node_put(phy_node);
>
> @@ -3029,7 +3030,8 @@ static int macb_remove(struct platform_device *pdev)
>   		mdiobus_free(bp->mii_bus);
>
>   		/* Shutdown the PHY if there is a GPIO reset */
> -		gpiod_set_value(bp->reset_gpio, 0);
> +		if (bp->reset_gpio)
> +			gpiod_set_value(bp->reset_gpio, 0);

    Hm, this function was previously OK to call with NULL (it didn't curse)...

>
>   		unregister_netdev(dev);
>   		clk_disable_unprepare(bp->tx_clk);

MBR, Sergei
