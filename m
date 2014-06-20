From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 2/2] net: systemport: fix UniMAC reset logic
Date: Sat, 21 Jun 2014 00:14:26 +0400
Message-ID: <53A49622.80908@cogentembedded.com>
References: <1403294500-31905-1-git-send-email-f.fainelli@gmail.com> <1403294500-31905-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:50739 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757718AbaFTUOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 16:14:18 -0400
Received: by mail-lb0-f171.google.com with SMTP id s7so2684018lbd.16
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 13:14:16 -0700 (PDT)
In-Reply-To: <1403294500-31905-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/21/2014 12:01 AM, Florian Fainelli wrote:

> The UniMAC CMD_SW_RESET bit is not a self-clearing bit, so we need to
> assert it, wait a bit and clear it manually. As a result, umac_reset()
> is updated not to return any value.

> By setting CMD_SW_RESET and only that bit, we were also clearing the

    I wonder where you were setting this bit before -- the only umac_writel() 
there was wrote 0 to UMAC_CMD...

> other 31 bits, overriding the hardware reset defaults which are
> correctly set on purpose.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/net/ethernet/broadcom/bcmsysport.c | 33 ++++++++----------------------
>   1 file changed, 9 insertions(+), 24 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index f6bccd847ee6..d31f7d239064 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -1254,28 +1254,17 @@ static inline void umac_enable_set(struct bcm_sysport_priv *priv,
>   		usleep_range(1000, 2000);
>   }
>
> -static inline int umac_reset(struct bcm_sysport_priv *priv)
> +static inline void umac_reset(struct bcm_sysport_priv *priv)
>   {
> -	unsigned int timeout = 0;
>   	u32 reg;
> -	int ret = 0;
> -
> -	umac_writel(priv, 0, UMAC_CMD);
> -	while (timeout++ < 1000) {
> -		reg = umac_readl(priv, UMAC_CMD);
> -		if (!(reg & CMD_SW_RESET))
> -			break;
> -
> -		udelay(1);
> -	}
> -
> -	if (timeout == 1000) {
> -		dev_err(&priv->pdev->dev,
> -			"timeout waiting for MAC to come out of reset\n");
> -		ret = -ETIMEDOUT;
> -	}
>
> -	return ret;
> +	reg = umac_readl(priv, UMAC_CMD);
> +	reg |= CMD_SW_RESET;
> +	umac_writel(priv, reg, UMAC_CMD);
> +	udelay(10);
> +	reg = umac_readl(priv, UMAC_CMD);
> +	reg &= ~CMD_SW_RESET;
> +	umac_writel(priv, reg, UMAC_CMD);
>   }
>
>   static void umac_set_hw_addr(struct bcm_sysport_priv *priv,
[...]

WBR, Sergei
