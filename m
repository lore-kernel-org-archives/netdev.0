From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: read then write PVID
Date: Tue, 8 Mar 2016 15:37:04 +0100
Message-ID: <20160308143704.GF351@lunn.ch>
References: <1457393079-22740-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52712 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039AbcCHOhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 09:37:06 -0500
Content-Disposition: inline
In-Reply-To: <1457393079-22740-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2016 at 06:24:39PM -0500, Vivien Didelot wrote:
> The port register 0x07 contains more options than just the default VID,
> even though they are not used yet. So prefer a read then write operation
> over a direct write.
> 
> This also allows to keep track of the change through dynamic debug.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Tested-by: Andrew Lunn <andrew@lunn.ch>

Thanks
        Andrew


> ---
>  drivers/net/dsa/mv88e6xxx.c | 30 ++++++++++++++++++++++++++----
>  1 file changed, 26 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 3a58a8a..1aee42d 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1166,23 +1166,45 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
>  	return 0;
>  }
>  
> -static int _mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
> +static int _mv88e6xxx_port_pvid(struct dsa_switch *ds, int port, u16 *new,
> +				u16 *old)
>  {
> +	u16 pvid;
>  	int ret;
>  
>  	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_DEFAULT_VLAN);
>  	if (ret < 0)
>  		return ret;
>  
> -	*pvid = ret & PORT_DEFAULT_VLAN_MASK;
> +	pvid = ret & PORT_DEFAULT_VLAN_MASK;
> +
> +	if (new) {
> +		ret &= ~PORT_DEFAULT_VLAN_MASK;
> +		ret |= *new & PORT_DEFAULT_VLAN_MASK;
> +
> +		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
> +					   PORT_DEFAULT_VLAN, ret);
> +		if (ret < 0)
> +			return ret;
> +
> +		netdev_dbg(ds->ports[port], "DefaultVID %d (was %d)\n", *new,
> +			   pvid);
> +	}
> +
> +	if (old)
> +		*old = pvid;
>  
>  	return 0;
>  }
>  
> +static int _mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
> +{
> +	return _mv88e6xxx_port_pvid(ds, port, NULL, pvid);
> +}
> +
>  static int _mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 pvid)
>  {
> -	return _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
> -				   pvid & PORT_DEFAULT_VLAN_MASK);
> +	return _mv88e6xxx_port_pvid(ds, port, &pvid, NULL);
>  }
>  
>  static int _mv88e6xxx_vtu_wait(struct dsa_switch *ds)
> -- 
> 2.7.2
> 
