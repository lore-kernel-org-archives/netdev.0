From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 09/12] net: dsa: mv88e6xxx: add SMI
 detection helper
Date: Tue, 14 Jun 2016 23:50:34 +0200
Message-ID: <20160614215034.GH12832@lunn.ch>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-10-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46192 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbcFNVuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 17:50:37 -0400
Content-Disposition: inline
In-Reply-To: <20160614183153.32327-10-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 02:31:50PM -0400, Vivien Didelot wrote:
> Extract the allocation and switch ID reading code used by both legacy
> and new probing into an helper function which uses a info structure to
> describe how to access the switch ID register.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 74 ++++++++++++++++++++-------------------------
>  1 file changed, 32 insertions(+), 42 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 8ac9f9a..2f36d01 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -3631,22 +3631,15 @@ mv88e6xxx_lookup_info(unsigned int prod_num, const struct mv88e6xxx_info *table,
>  	return NULL;
>  }
>  
> -static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
> -				       struct device *host_dev, int sw_addr,
> -				       void **priv)
> +static struct mv88e6xxx_priv_state *
> +mv88e6xxx_smi_detect(struct device *dev, struct mii_bus *bus, int sw_addr,
> +		     const struct mv88e6xxx_info *info)
>  {
> -	const struct mv88e6xxx_info *info;
>  	struct mv88e6xxx_priv_state *ps;
> -	struct mii_bus *bus;
> -	const char *name;
>  	int id, prod_num, rev;
> -	int err;
>  
> -	bus = dsa_host_dev_to_mii_bus(host_dev);
> -	if (!bus)
> -		return NULL;
> -
> -	id = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
> +	id = __mv88e6xxx_reg_read(bus, sw_addr, info->port_base_addr,
> +				  PORT_SWITCH_ID);
>  	if (id < 0)
>  		return NULL;
>  
> @@ -3658,28 +3651,46 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
>  	if (!info)
>  		return NULL;
>  
> -	name = info->name;
> +	dev_info(dev, "switch 0x%x detected: %s, revision %u\n", prod_num,
> +		 info->name, rev);
>  
> -	ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
> +	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
>  	if (!ps)
>  		return NULL;

I don't like the way this detect function goes a lot further than
detection. I would say detection finished when you have the info
structure. Return at that point, and let the probe do the rest.

       Andrew
