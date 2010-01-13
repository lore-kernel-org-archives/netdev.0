From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: Proper ctrlmode handling for CAN devices
Date: Wed, 13 Jan 2010 20:56:23 +0100
Message-ID: <4B4E2567.8060907@grandegger.com>
References: <1263403629-18827-1-git-send-email-chripell@fsfe.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1263403629-18827-1-git-send-email-chripell-VaTbYqLCNhc@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Christian,

Christian Pellegrin wrote:
> This patch adds error checking of ctrlmode values for CAN devices. As
> an example all availabe bits are implemented in the mcp251x driver.
> 
> Signed-off-by: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
> ---
>  drivers/net/can/at91_can.c        |    1 +
>  drivers/net/can/bfin_can.c        |    1 +
>  drivers/net/can/dev.c             |   13 +++++++++++--
>  drivers/net/can/mcp251x.c         |   32 ++++++++++++++++++++++++++++++--
>  drivers/net/can/mscan/mscan.c     |    1 +
>  drivers/net/can/sja1000/sja1000.c |    1 +
>  drivers/net/can/ti_hecc.c         |    1 +
>  drivers/net/can/usb/ems_usb.c     |    1 +
>  include/linux/can/dev.h           |    2 ++
>  9 files changed, 49 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
> index f728749..a2f29a3 100644
> --- a/drivers/net/can/at91_can.c
> +++ b/drivers/net/can/at91_can.c
> @@ -1073,6 +1073,7 @@ static int __init at91_can_probe(struct platform_device *pdev)
>  	priv->can.bittiming_const = &at91_bittiming_const;
>  	priv->can.do_set_bittiming = at91_set_bittiming;
>  	priv->can.do_set_mode = at91_set_mode;
> +	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
>  	priv->reg_base = addr;
>  	priv->dev = dev;
>  	priv->clk = clk;
> diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
> index 7e1926e..bf7f9ba 100644
> --- a/drivers/net/can/bfin_can.c
> +++ b/drivers/net/can/bfin_can.c
> @@ -603,6 +603,7 @@ struct net_device *alloc_bfin_candev(void)
>  	priv->can.bittiming_const = &bfin_can_bittiming_const;
>  	priv->can.do_set_bittiming = bfin_can_set_bittiming;
>  	priv->can.do_set_mode = bfin_can_set_mode;
> +	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
>  
>  	return dev;
>  }
> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index c1bb29f..e25ab98 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
> @@ -587,13 +587,22 @@ static int can_changelink(struct net_device *dev,
>  
>  	if (data[IFLA_CAN_CTRLMODE]) {
>  		struct can_ctrlmode *cm;
> +		u32 ctrlmode;
>  
>  		/* Do not allow changing controller mode while running */
>  		if (dev->flags & IFF_UP)
>  			return -EBUSY;
>  		cm = nla_data(data[IFLA_CAN_CTRLMODE]);
> -		priv->ctrlmode &= ~cm->mask;
> -		priv->ctrlmode |= cm->flags;
> +		if (cm->flags & ~priv->ctrlmode_supported)
> +			return -EOPNOTSUPP;
> +		ctrlmode = priv->ctrlmode & ~cm->mask;
> +		ctrlmode |= cm->flags;
> +		if (priv->check_ctrlmode) {
> +			err = priv->check_ctrlmode(ctrlmode);
> +			if (err < 0)
> +				return err;
> +		}

Could you please explain, what the "check_ctrlmode" callback is good
for. For me it seems useless, at a first glance. Without, also the
variable ctrlmode is not necessary.

> +		priv->ctrlmode = ctrlmode;
>  	}
>  
>  	if (data[IFLA_CAN_BITTIMING]) {
> diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
> index afa2fa4..0ad8786 100644
> --- a/drivers/net/can/mcp251x.c
> +++ b/drivers/net/can/mcp251x.c
> @@ -538,10 +538,14 @@ static void mcp251x_set_normal_mode(struct spi_device *spi)
>  
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
>  		/* Put device into loopback mode */
> -		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_LOOPBACK);
> +	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
> +		/* Put device into liste-only mode */
> +		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_LISTEN_ONLY);
>  	} else {
>  		/* Put device into normal mode */
> -		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_NORMAL);
> +		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_NORMAL |
> +				  (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT ?
> +				   CANCTRL_OSM : 0));
>  
>  		/* Wait for the device to enter normal mode */
>  		timeout = jiffies + HZ;
> @@ -917,6 +921,25 @@ static void mcp251x_irq_work_handler(struct work_struct *ws)
>  	}
>  }
>  
> +static inline int mcp251x_match_bits(u32 arg, u32 mask)
> +{
> +	if ((arg & mask) == mask)
> +		return 1;
> +	return 0;
> +}
> +
> +static int mcp251x_check_ctrlmode(u32 ctrlmode)
> +{
> +	if (mcp251x_match_bits(ctrlmode, CAN_CTRLMODE_LOOPBACK |
> +			       CAN_CTRLMODE_LISTENONLY) ||
> +	    mcp251x_match_bits(ctrlmode, CAN_CTRLMODE_LOOPBACK |
> +			       CAN_CTRLMODE_ONE_SHOT) ||
> +	    mcp251x_match_bits(ctrlmode, CAN_CTRLMODE_ONE_SHOT |
> +			       CAN_CTRLMODE_LISTENONLY))
> +		return -EOPNOTSUPP;

In another mail you mentioned, that "ENOTSUPP" does not result in a
useful user space error message. I checked "errno.h" of my Linux
distribution and there ENOTSUPP is not even defined, in contrast to
"EOPNOTSUPP". Hm, ENOTSUPP is used in may places in the kernel and also
in some CAN source files and I think we should fix that.

> +	return 0;
> +}

For me this check never fails if "priv->can.ctrlmode_supported" is set
properly. Or have I missed something?

The rest looks ok.

Thanks,

Wolfgang.
