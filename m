From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 5/5] net: dsa: lan9303: refactor
 lan9303_get_ethtool_stats
Date: Thu, 3 Aug 2017 11:04:20 -0700
Message-ID: <d91c3159-57a3-dea3-462e-24a4156127b2@gmail.com>
References: <20170803094507.3439-1-privat@egil-hjelmeland.no>
 <20170803094507.3439-6-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803094507.3439-6-privat@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2017 02:45 AM, Egil Hjelmeland wrote:
> In lan9303_get_ethtool_stats: Get rid of 0x400 constant magic
> by using new lan9303_read_switch_reg() inside loop.
> Reduced scope of two variables.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
> ---
>  drivers/net/dsa/lan9303-core.c | 26 ++++++++++++++++----------
>  1 file changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
> index 6f409755ba1a..5aaa46146c27 100644
> --- a/drivers/net/dsa/lan9303-core.c
> +++ b/drivers/net/dsa/lan9303-core.c
> @@ -435,6 +435,13 @@ static int lan9303_write_switch_port(
>  		chip, LAN9303_SWITCH_PORT_REG(port, regnum), val);
>  }
>  
> +static int lan9303_read_switch_port(
> +	struct lan9303 *chip, int port, u16 regnum, u32 *val)
> +{

This indentation is really funny, why not just break it up that way:

static int lan9303_read_switch_port(struct lan9303 *chip, int port
				    u16 regnum, u32 *val)
{
}

This applies to patch 5 as well, other than that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> +	return lan9303_read_switch_reg(
> +		chip, LAN9303_SWITCH_PORT_REG(port, regnum), val);
> +}
> +
>  static int lan9303_detect_phy_setup(struct lan9303 *chip)
>  {
>  	int reg;
> @@ -709,19 +716,18 @@ static void lan9303_get_ethtool_stats(struct dsa_switch *ds, int port,
>  				      uint64_t *data)
>  {
>  	struct lan9303 *chip = ds->priv;
> -	u32 reg;
> -	unsigned int u, poff;
> -	int ret;
> -
> -	poff = port * 0x400;
> +	unsigned int u;
>  
>  	for (u = 0; u < ARRAY_SIZE(lan9303_mib); u++) {
> -		ret = lan9303_read_switch_reg(chip,
> -					      lan9303_mib[u].offset + poff,
> -					      &reg);
> +		u32 reg;
> +		int ret;
> +
> +		ret = lan9303_read_switch_port(
> +			chip, port, lan9303_mib[u].offset, &reg);
> +
>  		if (ret)
> -			dev_warn(chip->dev, "Reading status reg %u failed\n",
> -				 lan9303_mib[u].offset + poff);
> +			dev_warn(chip->dev, "Reading status port %d reg %u failed\n",
> +				 port, lan9303_mib[u].offset);
>  		data[u] = reg;
>  	}
>  }
> 


-- 
Florian
