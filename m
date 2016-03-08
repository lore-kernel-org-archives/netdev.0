From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: avoid writing the same mode
Date: Tue, 8 Mar 2016 15:37:21 +0100
Message-ID: <20160308143721.GG351@lunn.ch>
References: <1457393092-22826-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52716 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753522AbcCHOhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 09:37:24 -0500
Content-Disposition: inline
In-Reply-To: <1457393092-22826-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2016 at 06:24:52PM -0500, Vivien Didelot wrote:
> There is no need to change the 802.1Q port mode for the same value.
> Thus avoid such message:
> 
>     [  401.954836] dsa dsa@0 lan0: 802.1Q Mode: Disabled (was Disabled)
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Tested-by: Andrew Lunn <andrew@lunn.ch>

Thanks
        Andrew


> ---
>  drivers/net/dsa/mv88e6xxx.c | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 1aee42d..5f07524 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1765,16 +1765,21 @@ int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
>  
>  	old = ret & PORT_CONTROL_2_8021Q_MASK;
>  
> -	ret &= ~PORT_CONTROL_2_8021Q_MASK;
> -	ret |= new & PORT_CONTROL_2_8021Q_MASK;
> +	if (new != old) {
> +		ret &= ~PORT_CONTROL_2_8021Q_MASK;
> +		ret |= new & PORT_CONTROL_2_8021Q_MASK;
>  
> -	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_2, ret);
> -	if (ret < 0)
> -		goto unlock;
> +		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_2,
> +					   ret);
> +		if (ret < 0)
> +			goto unlock;
> +
> +		netdev_dbg(ds->ports[port], "802.1Q Mode %s (was %s)\n",
> +			   mv88e6xxx_port_8021q_mode_names[new],
> +			   mv88e6xxx_port_8021q_mode_names[old]);
> +	}
>  
> -	netdev_dbg(ds->ports[port], "802.1Q Mode: %s (was %s)\n",
> -		   mv88e6xxx_port_8021q_mode_names[new],
> -		   mv88e6xxx_port_8021q_mode_names[old]);
> +	ret = 0;
>  unlock:
>  	mutex_unlock(&ps->smi_mutex);
>  
> -- 
> 2.7.2
> 
