From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: Introduce
 _mv88e6xxx_phy_page_{read,write}
Date: Fri, 25 Mar 2016 18:45:53 -0700
Message-ID: <56F5E9D1.9030909@roeck-us.net>
References: <1458951004-27424-1-git-send-email-patrick@puiterwijk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, netdev@vger.kernel.org, dennis@ausil.us,
	pbrobinson@gmail.com
To: Patrick Uiterwijk <patrick@puiterwijk.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39851 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbcCZBp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 21:45:59 -0400
In-Reply-To: <1458951004-27424-1-git-send-email-patrick@puiterwijk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/2016 05:10 PM, Patrick Uiterwijk wrote:
> Add versions of the phy_page_read and _write functions to
> be used in a context where the SMI mutex is held.
>
> Signed-off-by: Patrick Uiterwijk <patrick@puiterwijk.org>
> ---
>   drivers/net/dsa/mv88e6xxx.c | 42 ++++++++++++++++++++++++++++++++----------
>   1 file changed, 32 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index fa086e0..13db5d8 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -2708,37 +2708,59 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
>   	return 0;
>   }
>
> -int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
> +static int _mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page,
> +				    int reg)
>   {
> -	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>   	int ret;
>
> -	mutex_lock(&ps->smi_mutex);
>   	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
>   	if (ret < 0)
> -		goto error;
> +		goto clear;
>   	ret = _mv88e6xxx_phy_read_indirect(ds, port, reg);
> -error:
> +clear:

Is there some good reason for changing the name of those labels ?

Guenter

>   	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
> -	mutex_unlock(&ps->smi_mutex);
> +
>   	return ret;
>   }
>
> -int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
> -			     int reg, int val)
> +int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
>   {
>   	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>   	int ret;
>
>   	mutex_lock(&ps->smi_mutex);
> +	ret = _mv88e6xxx_phy_page_read(ds, port, page, reg);
> +	mutex_unlock(&ps->smi_mutex);
> +
> +	return ret;
> +}
> +
> +static int _mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
> +				     int reg, int val)
> +{
> +	int ret;
> +
>   	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
>   	if (ret < 0)
> -		goto error;
> +		goto clear;
>
>   	ret = _mv88e6xxx_phy_write_indirect(ds, port, reg, val);
> -error:
> +clear:
>   	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
> +
> +	return ret;
> +}
> +
> +int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
> +			     int reg, int val)
> +{
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	int ret;
> +
> +	mutex_lock(&ps->smi_mutex);
> +	ret = _mv88e6xxx_phy_page_write(ds, port, page, reg, val);
>   	mutex_unlock(&ps->smi_mutex);
> +
>   	return ret;
>   }
>
>
