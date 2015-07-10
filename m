From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Fri, 10 Jul 2015 13:44:00 -0700
Message-ID: <55A02E90.1090602@gmail.com>
References: <559FF511.5080102@list.ru> <559FF5A3.2030607@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <559FF5A3.2030607@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/15 09:41, Stas Sergeev wrote:
> 
> Currently fixed_phy driver recognizes only the link-up state.
> This simple patch adds an implementation of link-down state.
> The actual change is 1-line, the rest is an indentation.

It is not clear to me how this is useful, if you have a link_update
callback manipulating the link state, the fixed PHY driver returns
appropriate MII_BMSR values and always re-initializes everything.

Is this meant to be some sort of optimization? If so, you could just
avoid the re-intendation completely and do a goto instead?

> 
> Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
> 
> CC: Florian Fainelli <f.fainelli@gmail.com>
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> ---
>  drivers/net/phy/fixed_phy.c | 99 +++++++++++++++++++++++----------------------
>  1 file changed, 50 insertions(+), 49 deletions(-)
> 
> diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
> index 1960b46..a5d93cf 100644
> --- a/drivers/net/phy/fixed_phy.c
> +++ b/drivers/net/phy/fixed_phy.c
> @@ -52,58 +52,59 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
>  	u16 lpagb = 0;
>  	u16 lpa = 0;
> 
> -	if (fp->status.duplex) {
> -		bmcr |= BMCR_FULLDPLX;
> -
> -		switch (fp->status.speed) {
> -		case 1000:
> -			bmsr |= BMSR_ESTATEN;
> -			bmcr |= BMCR_SPEED1000;
> -			lpagb |= LPA_1000FULL;
> -			break;
> -		case 100:
> -			bmsr |= BMSR_100FULL;
> -			bmcr |= BMCR_SPEED100;
> -			lpa |= LPA_100FULL;
> -			break;
> -		case 10:
> -			bmsr |= BMSR_10FULL;
> -			lpa |= LPA_10FULL;
> -			break;
> -		default:
> -			pr_warn("fixed phy: unknown speed\n");
> -			return -EINVAL;
> -		}
> -	} else {
> -		switch (fp->status.speed) {
> -		case 1000:
> -			bmsr |= BMSR_ESTATEN;
> -			bmcr |= BMCR_SPEED1000;
> -			lpagb |= LPA_1000HALF;
> -			break;
> -		case 100:
> -			bmsr |= BMSR_100HALF;
> -			bmcr |= BMCR_SPEED100;
> -			lpa |= LPA_100HALF;
> -			break;
> -		case 10:
> -			bmsr |= BMSR_10HALF;
> -			lpa |= LPA_10HALF;
> -			break;
> -		default:
> -			pr_warn("fixed phy: unknown speed\n");
> -			return -EINVAL;
> -		}
> -	}
> -
> -	if (fp->status.link)
> +	if (fp->status.link) {
>  		bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
> 
> -	if (fp->status.pause)
> -		lpa |= LPA_PAUSE_CAP;
> +		if (fp->status.duplex) {
> +			bmcr |= BMCR_FULLDPLX;
> +
> +			switch (fp->status.speed) {
> +			case 1000:
> +				bmsr |= BMSR_ESTATEN;
> +				bmcr |= BMCR_SPEED1000;
> +				lpagb |= LPA_1000FULL;
> +				break;
> +			case 100:
> +				bmsr |= BMSR_100FULL;
> +				bmcr |= BMCR_SPEED100;
> +				lpa |= LPA_100FULL;
> +				break;
> +			case 10:
> +				bmsr |= BMSR_10FULL;
> +				lpa |= LPA_10FULL;
> +				break;
> +			default:
> +				pr_warn("fixed phy: unknown speed\n");
> +				return -EINVAL;
> +			}
> +		} else {
> +			switch (fp->status.speed) {
> +			case 1000:
> +				bmsr |= BMSR_ESTATEN;
> +				bmcr |= BMCR_SPEED1000;
> +				lpagb |= LPA_1000HALF;
> +				break;
> +			case 100:
> +				bmsr |= BMSR_100HALF;
> +				bmcr |= BMCR_SPEED100;
> +				lpa |= LPA_100HALF;
> +				break;
> +			case 10:
> +				bmsr |= BMSR_10HALF;
> +				lpa |= LPA_10HALF;
> +				break;
> +			default:
> +				pr_warn("fixed phy: unknown speed\n");
> +				return -EINVAL;
> +			}
> +		}
> 
> -	if (fp->status.asym_pause)
> -		lpa |= LPA_PAUSE_ASYM;
> +		if (fp->status.pause)
> +			lpa |= LPA_PAUSE_CAP;
> +
> +		if (fp->status.asym_pause)
> +			lpa |= LPA_PAUSE_ASYM;
> +	}
> 
>  	fp->regs[MII_PHYSID1] = 0;
>  	fp->regs[MII_PHYSID2] = 0;
> 


-- 
Florian
