From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phy: micrel: add of configuration for LED mode
Date: Tue, 18 Mar 2014 23:39:54 +0300
Message-ID: <5328AF1A.3090008@cogentembedded.com>
References: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux-sh@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	linux-kernel@lists.codethink.co.uk, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/26/2014 02:48 PM, Ben Dooks wrote:

> Add support for the led-mode property for the following PHYs
> which have a single LED mode configuration value.

> KSZ8001 and KSZ8041 which both use register 0x1e bits 15,14 and
> KSZ8021, KSZ8031 and KSZ8051 which use register 0x1f bits 5,4
> to control the LED configuration.

> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
[...]

    Missed this patch, unfortunately and now it has been merged already... doh.

> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 5a8993b..0c9e434 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -148,15 +148,52 @@ static int ks8737_config_intr(struct phy_device *phydev)
>   	return rc < 0 ? rc : 0;
>   }
>
> +static int kszphy_setup_led(struct phy_device *phydev,
> +			    unsigned int reg, unsigned int shift)
> +{
> +
> +	struct device *dev = &phydev->dev;
> +	struct device_node *of_node = dev->of_node;
> +	int rc, temp;
> +	u32 val;
> +
> +	if (!of_node && dev->parent->of_node)
> +		of_node = dev->parent->of_node;
> +
> +	if (of_property_read_u32(of_node, "micrel,led-mode", &val))
> +		return 0;
> +
> +	temp = phy_read(phydev, reg);
> +	if (temp < 0)
> +		return temp;
> +
> +	temp &= 3 << shift;

    Hm, I guess you meant ~(3 << shift), else it wouldn't work as expected if 
the LED field is currently non-zero. Also, I think you didn't want to mask off 
unrelated bits. I'm surprised nobody has noticed this before...

> +	temp |= val << shift;
> +	rc = phy_write(phydev, reg, temp);
> +
> +	return rc < 0 ? rc : 0;
> +}
> +
>   static int kszphy_config_init(struct phy_device *phydev)
>   {
>   	return 0;
>   }
>
> +static int kszphy_config_init_led8041(struct phy_device *phydev)

    Why not ksz8041_config_init() like other names in this file?
Why mention LED in the name at all?

> +{
> +	/* single led control, register 0x1e bits 15..14 */
> +	return kszphy_setup_led(phydev, 0x1e, 14);
> +}
> +
>   static int ksz8021_config_init(struct phy_device *phydev)
>   {
> -	int rc;
>   	const u16 val = KSZPHY_OMSO_B_CAST_OFF | KSZPHY_OMSO_RMII_OVERRIDE;
> +	int rc;
> +
> +	rc = kszphy_setup_led(phydev, 0x1f, 4);
> +	if (rc)
> +		dev_err(&phydev->dev, "failed to set led mode\n");

    LED.

> +
>   	phy_write(phydev, MII_KSZPHY_OMSO, val);
>   	rc = ksz_config_flags(phydev);
>   	return rc < 0 ? rc : 0;
> @@ -166,6 +203,10 @@ static int ks8051_config_init(struct phy_device *phydev)
>   {
>   	int rc;
>
> +	rc = kszphy_setup_led(phydev, 0x1f, 4);
> +	if (rc)
> +		dev_err(&phydev->dev, "failed to set led mode\n");

    LED.

> +
>   	rc = ksz_config_flags(phydev);
>   	return rc < 0 ? rc : 0;
>   }

WBR, Sergei

