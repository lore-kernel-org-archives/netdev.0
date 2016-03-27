From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/7] net: dsa: mv88e6xxx: fix ATU FID access for
 6185
Date: Sun, 27 Mar 2016 05:04:34 +0200
Message-ID: <20160327030434.GB15402@lunn.ch>
References: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1459043983-12088-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Guenter Roeck <linux@roeck-us.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58277 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754526AbcC0DEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Mar 2016 23:04:37 -0400
Content-Disposition: inline
In-Reply-To: <1459043983-12088-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 26, 2016 at 09:59:40PM -0400, Vivien Didelot wrote:
> The 6185 family does not have a ATU FID register. It splits it in the
> ATU Control register and the ATU Operation.

Looking at the reference code, the following devices have a FID
register:
( DEV_88E6097_FAMILY | DEV_88E6165_FAMILY | DEV_88E6351_FAMILY | 
  DEV_88E6352_FAMILY)

If there are 256 databases, it gets split across the two registers.

If there are only 64, it all goes in the ATU operation.

   Andrew

> 
> Add 6185 support for FID (a.k.a. DBNum) in ATU commands.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 14 ++++++++++++++
>  drivers/net/dsa/mv88e6xxx.h |  2 +-
>  2 files changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index df3f219..4b3c466 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -961,6 +961,20 @@ static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 fid, u16 cmd)
>  		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
>  		if (ret < 0)
>  			return ret;
> +	} else if (mv88e6xxx_6185_family(ds)) {
> +		/* ATU DBNum[7:4] are located in ATU Control 15:12 */
> +		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_CONTROL);
> +		if (ret < 0)
> +			return ret;
> +
> +		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_CONTROL,
> +					   (ret & 0xfff) |
> +					   ((fid << 8) & 0xf000));
> +		if (ret < 0)
> +			return ret;
> +
> +		/* ATU DBNum[3:0] are located in ATU Operation 3:0 */
> +		cmd |= fid & 0xf;
>  	} else {
>  		return -EOPNOTSUPP;
>  	}
> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
> index febab76..94d3cb3 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -366,7 +366,7 @@ struct mv88e6xxx_switch_id {
>  };
>  
>  struct mv88e6xxx_atu_entry {
> -	u16	fid;
> +	u16	fid; /* 8-bit DBNum in 88E6185 family */
>  	u8	state;
>  	bool	trunk;
>  	u16	portv_trunkid;
> -- 
> 2.7.4
> 
