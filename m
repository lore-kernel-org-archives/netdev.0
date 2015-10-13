From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: smsc: disable energy detect mode
Date: Tue, 13 Oct 2015 12:26:00 -0700
Message-ID: <561D5AC8.7040801@gmail.com>
References: <1444713189-23063-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	Georg.Soffel@bosch-si.com
To: Heiko Schocher <hs@denx.de>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444713189-23063-1-git-send-email-hs@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/10/15 22:13, Heiko Schocher wrote:
> On some boards the energy enable detect mode leads in
> trouble with some switches, so make the enabling of
> this mode configurable through DT.
> 
> Signed-off-by: Heiko Schocher <hs@denx.de>
> ---
> 
>  .../devicetree/bindings/net/smsc-lan87xx.txt       | 19 +++++++++++++++++
>  drivers/net/phy/smsc.c                             | 24 +++++++++++++++++-----
>  2 files changed, 38 insertions(+), 5 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/smsc-lan87xx.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/smsc-lan87xx.txt b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
> new file mode 100644
> index 0000000..39aa1dc
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
> @@ -0,0 +1,19 @@
> +SMSC LAN87xx Ethernet PHY
> +
> +Some boards require special tuning values. Configure them
> +through an Ethernet OF device node.
> +
> +Optional properties:
> +
> +- disable-energy-detect:
> +  If set, do not enable energy detect mode for the SMSC phy.
> +  default: enable energy detect mode

Although energy detection is something that is implemented by many PHYs,
I am not sure a generic property is suitable here, I would prefix that
with the SMSC vendor prefix here to make it clear this only applies to
this PHY.

Would not you want to make it a reverse property here though, something
like this:

smsc,energy-detect: boolean, when present indicates the PHY reliably
supports energy detection


> +
> +Examples:
> +
> +	/* Attach to an Ethernet device with autodetected PHY */
> +	&cpsw_emac0 {
> +		phy_id = <&davinci_mdio>, <0>;
> +		phy-mode = "mii";
> +		disable-energy-detect;
> +	};
> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> index 70b0895..f90fbf3 100644
> --- a/drivers/net/phy/smsc.c
> +++ b/drivers/net/phy/smsc.c
> @@ -43,16 +43,30 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
>  
>  static int smsc_phy_config_init(struct phy_device *phydev)
>  {
> +#ifdef CONFIG_OF
> +	int len;
> +	struct device *dev = &phydev->dev;
> +	struct device_node *of_node = dev->of_node;

That does not need to be ifdefd out, at best annontate with __maybe_unused?

> +#endif
>  	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
> +	int enable_energy = 1;
>  
>  	if (rc < 0)
>  		return rc;
>  
> -	/* Enable energy detect mode for this SMSC Transceivers */
> -	rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
> -		       rc | MII_LAN83C185_EDPWRDOWN);
> -	if (rc < 0)
> -		return rc;
> +#ifdef CONFIG_OF
> +	if (!of_node && dev->parent->of_node)
> +		of_node = dev->parent->of_node;

That looks strange, why would the property be placed at the parent level
when this is a PHY device tree node property?

> +	if (of_find_property(of_node, "disable-energy-detect", &len))
> +		enable_energy = 0;
> +#endif
> +	if (enable_energy) {
> +		/* Enable energy detect mode for this SMSC Transceivers */
> +		rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
> +			       rc | MII_LAN83C185_EDPWRDOWN);
> +		if (rc < 0)
> +			return rc;
> +	}
>  
>  	return smsc_phy_ack_interrupt(phydev);
>  }
> 


-- 
Florian
