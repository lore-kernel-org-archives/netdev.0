From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Clear the PDOWN bit on setup
Date: Sat, 26 Mar 2016 14:36:56 -0400
Message-ID: <87shzdgk6v.fsf@ketchup.mtl.sfl>
References: <1458951004-27424-1-git-send-email-patrick@puiterwijk.org> <1458951004-27424-2-git-send-email-patrick@puiterwijk.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux@arm.linux.org.uk, andrew@lunn.ch, netdev@vger.kernel.org,
	dennis@ausil.us, pbrobinson@gmail.com,
	Patrick Uiterwijk <patrick@puiterwijk.org>
To: Patrick Uiterwijk <patrick@puiterwijk.org>, linux@roeck-us.net,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45503 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbcCZShE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 14:37:04 -0400
In-Reply-To: <1458951004-27424-2-git-send-email-patrick@puiterwijk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Uiterwijk <patrick@puiterwijk.org> writes:

> Some of the vendor-specific bootloaders set up this part
> of the initialization for us, so this was never added.
> However, since upstream bootloaders don't initialize the
> chip specifically, they leave the fiber MII's PDOWN flag
> set, which means that the CPU port doesn't connect.
>
> This patch checks whether this flag has been clear prior
> by something else, and if not make us clear it.
>
> Signed-off-by: Patrick Uiterwijk <patrick@puiterwijk.org>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 99 +++++++++++++++++++++++++++++++--------------
>  drivers/net/dsa/mv88e6xxx.h |  8 ++++
>  2 files changed, 76 insertions(+), 31 deletions(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 13db5d8..05b2efb 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -2264,6 +2264,57 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
>  	mutex_unlock(&ps->smi_mutex);
>  }
>  
> +static int _mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
> +				     int reg, int val)
> +{
> +	int ret;
> +
> +	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
> +	if (ret < 0)
> +		goto clear;
> +
> +	ret = _mv88e6xxx_phy_write_indirect(ds, port, reg, val);
> +clear:
> +	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
> +
> +	return ret;
> +}
> +
> +static int _mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page,
> +				    int reg)
> +{
> +	int ret;
> +
> +	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
> +	if (ret < 0)
> +		goto clear;
> +
> +	ret = _mv88e6xxx_phy_read_indirect(ds, port, reg);
> +clear:
> +	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
> +
> +	return ret;
> +}
> +
> +static int mv88e6xxx_power_on_serdes(struct dsa_switch *ds)
> +{
> +	int ret;
> +
> +	ret = _mv88e6xxx_phy_page_read(ds, REG_FIBER_SERDES, PAGE_FIBER_SERDES,
> +				       MII_BMCR);
> +	if (ret < 0)
> +		return ret;
> +
> +	if (ret & BMCR_PDOWN) {
> +		ret = ret & ~BMCR_PDOWN;
> +		ret = _mv88e6xxx_phy_page_write(ds, REG_FIBER_SERDES,
> +						PAGE_FIBER_SERDES, MII_BMCR,
> +						ret);
> +	}
> +
> +	return ret;
> +}
> +
>  static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> @@ -2367,6 +2418,23 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  			goto abort;
>  	}
>  
> +	/* If this port is connected to a SerDes, make sure the SerDes is not
> +	 * powered down.
> +	 */
> +	if (mv88e6xxx_6352_family(ds)) {
> +		ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_STATUS);
> +		if (ret < 0)
> +			goto abort;
> +		ret &= PORT_STATUS_CMODE_MASK;
> +		if ((ret == PORT_STATUS_CMODE_100BASE_X) ||
> +		    (ret == PORT_STATUS_CMODE_1000BASE_X) ||
> +		    (ret == PORT_STATUS_CMODE_SGMII)) {
> +			ret = mv88e6xxx_power_on_serdes(ds);
> +			if (ret < 0)
> +				goto abort;
> +		}
> +	}
> +
>  	/* Port Control 2: don't force a good FCS, set the maximum frame size to
>  	 * 10240 bytes, disable 802.1q tags checking, don't discard tagged or
>  	 * untagged frames on this port, do a destination address lookup on all
> @@ -2708,21 +2776,6 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
>  	return 0;
>  }
>  
> -static int _mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page,
> -				    int reg)
> -{
> -	int ret;
> -
> -	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
> -	if (ret < 0)
> -		goto clear;
> -	ret = _mv88e6xxx_phy_read_indirect(ds, port, reg);
> -clear:
> -	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
> -
> -	return ret;
> -}
> -
>  int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> @@ -2735,22 +2788,6 @@ int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
>  	return ret;
>  }
>  
> -static int _mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
> -				     int reg, int val)
> -{
> -	int ret;
> -
> -	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
> -	if (ret < 0)
> -		goto clear;
> -
> -	ret = _mv88e6xxx_phy_write_indirect(ds, port, reg, val);
> -clear:
> -	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
> -
> -	return ret;
> -}
> -
>  int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
>  			     int reg, int val)
>  {

Please introduce directly _mv88e6xxx_phy_page_{read,write} above
mv88e6xxx_setup_port in patch 1/2, where they will actually be
needed. That will avoid to move them in patch 2/2.

Thanks,
Vivien
