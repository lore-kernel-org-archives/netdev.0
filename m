From: Guenter <linux@roeck-us.net>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: sleep in _mv88e6xxx_stats_wait
Date: Fri, 10 Jul 2015 10:10:27 -0700
Message-ID: <20150710171027.GB6585@groeck-UX31A>
References: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35064 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932590AbbGJRKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 13:10:32 -0400
Content-Disposition: inline
In-Reply-To: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 12:57:28PM -0400, Vivien Didelot wrote:
> The current _mv88e6xxx_stats_wait function does not sleep while testing
> the stats busy bit. Fix this by using the generic _mv88e6xxx_wait
> function.
> 
> Note that it requires to move _mv88e6xxx_wait on top of
> _mv88e6xxx_stats_wait to avoid undefined reference compilation error.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 52 +++++++++++++++++++--------------------------
>  1 file changed, 22 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index f6c7409..7753db1 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -557,19 +557,31 @@ static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
>  	return false;
>  }
>  
> +/* Must be called with SMI lock held */
> +static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
> +			   u16 mask)
> +{
> +	unsigned long timeout = jiffies + HZ / 10;
> +
> +	while (time_before(jiffies, timeout)) {
> +		int ret;
> +
> +		ret = _mv88e6xxx_reg_read(ds, reg, offset);
> +		if (ret < 0)
> +			return ret;
> +		if (!(ret & mask))
> +			return 0;
> +
> +		usleep_range(1000, 2000);
> +	}
> +	return -ETIMEDOUT;
> +}
> +
>  /* Must be called with SMI mutex held */
>  static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
>  {
> -	int ret;
> -	int i;
> -
> -	for (i = 0; i < 10; i++) {
> -		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_OP);
> -		if ((ret & GLOBAL_STATS_OP_BUSY) == 0)
> -			return 0;
> -	}

Hi Vivien,

is this really beneficial and/or needed ? It adds at least 1ms delay
to a loop which did not have any delay at all unless the register
read itself was sleeping. Is the original function seen to return
a timeout error under some circumstances ?

Thanks,
Guenter
