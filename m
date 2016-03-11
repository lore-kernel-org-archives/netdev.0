From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/6] net: arc_emac: support the phy reset for emac driver
Date: Fri, 11 Mar 2016 16:47:59 +0300
Message-ID: <56E2CC8F.5040703@cogentembedded.com>
References: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
 <1457693731-6966-4-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, Alexander Kochetkov <al.kochet@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Caesar Wang <wxt@rock-chips.com>, Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457693731-6966-4-git-send-email-wxt@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/11/2016 1:55 PM, Caesar Wang wrote:

> This patch adds to support the emac phy reset.
>
> 1) phy-reset-gpios:
> The phy-reset-gpios is an optional property for arc emac device tree boot.
> Change the binding document to match the driver code.
>
> 2) phy-reset-duration:
> Different boards may require different phy reset duration. Add property
> phy-reset-duration for device tree probe, so that the boards that need
> a longer reset duration can specify it in their device tree.
>
> 3) phy-reset-active-high:
> We need that for a custom hardware that needs the reverse reset sequence.
>
> Of course, this patch will fix the issue on
> https://patchwork.kernel.org/patch/8186801/.
>
> In some cases, the emac couldn't work if you don't have reset the phy.
> Let's add it to happy work.
>
> Signed-off-by: Caesar Wang <wxt@rock-chips.com>
> ---
>
>   drivers/net/ethernet/arc/emac_main.c | 41 ++++++++++++++++++++++++++++++++++++
>   1 file changed, 41 insertions(+)
>
> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> index 6446af1..42384f6a 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -764,6 +764,45 @@ static const struct net_device_ops arc_emac_netdev_ops = {
>   #endif
>   };
>
> +#ifdef CONFIG_OF
> +static void emac_reset_phy(struct net_device *pdev)
> +{
> +	int err, phy_reset;
> +	bool active_high = false;
> +	int msec = 10;
> +	struct device *dev = pdev->dev.parent;
> +	struct device_node *np = dev->of_node;
> +
> +	if (!np)
> +		return;
> +
> +	of_property_read_u32(np, "phy-reset-duration", &msec);
> +	/* A sane reset duration should not be longer than 1s */
> +	if (msec > 1000)
> +		msec = 1;
> +
> +	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
> +	if (!gpio_is_valid(phy_reset))
> +		return;
> +
> +	active_high = of_property_read_bool(np, "phy-reset-active-high");
> +
> +	err = devm_gpio_request_one(dev, phy_reset, active_high ?
> +				    GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
> +				    "phy-reset");
> +	if (err) {
> +		dev_err(dev, "failed to get phy-reset-gpios: %d\n", err);
> +		return;
> +	}
> +	msleep(msec);
> +	gpio_set_value_cansleep(phy_reset, !active_high);
> +}
[...]

    Why not make it the mii_bus::reset() method? It gets called before the 
MDIO bus scan.

MBR, Sergei
