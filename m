From: Michael Rozhavsky <mrozhavsky@mrv.com>
Subject: Re: [PATCH] e100 oops in 2.4.20
Date: Wed, 5 Feb 2003 10:22:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030205082206.GC10600@mike.nbase.co.il>
References: <20030205081210.GB10600@mike.nbase.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux.nics@intel.com
Content-Disposition: inline
In-Reply-To: <20030205081210.GB10600@mike.nbase.co.il>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please ignore this message.

On Wed, Feb 05, 2003 at 10:12:10AM +0200, Michael Rozhavsky wrote:
> Hi,
> 
> In 2.4.20 with CONFIG_NET_CARRIER_NETLINK compiled when I'm loading e100
> module I'm receiving consistent OOPS.
> 
> The reason for this is e100_update_link_state() on device init calls to
> netif_carrier_on() or netif_carrier_off() while dev->carrier_task is not
> initialized yet (will be initialized on register_netdev) and thus it
> causes NULL pointer exception.
> 
> [<c8adbfc8>] e100_find_speed_duplex
> [<c8adc46d>] e100_auto_neg
> [<c8adc4bd>] e100_phy_set_speed_duplex
> [<c8adc5b2>] e100_phy_set_loopback
> [<c8ad6ddb>] e100_hw_init
> [<c8ad6d61>] e100_init
> [<c8ad62d8>] e100_found1
> 
> I'm not sure that my fix is elegant but it works for me.
> 
> 
> --
>   Michael Rozhavsky
>   Senior Software Engineer
>   MRV International
>   Tel: +972 (4) 993-6248
>   Fax: +972 (4) 989-0564
>   http://www.mrv.com

> --- linux-2.4.20/drivers/net/e100/e100_phy.c	2002-11-29 01:53:13.000000000 +0200
> +++ linux-2.4.20-test/drivers/net/e100/e100_phy.c	2003-02-05 09:38:07.000000000 +0200
> @@ -963,14 +963,16 @@
>  
>  	/* Logical AND PHY link & netif_running */
>  	link = e100_get_link_state(bdp) && netif_running(bdp->device);
> -
> -	if (link) {
> -		if (!netif_carrier_ok(bdp->device))
> -			netif_carrier_on(bdp->device);
> -	} else {
> -		if (netif_carrier_ok(bdp->device))
> -			netif_carrier_off(bdp->device);
> -	}
> +#ifdef CONFIG_NET_CARRIER_NETLINK
> +	if (bdp->device->carrier_task)
> +#endif
> +		if (link) {
> +			if (!netif_carrier_ok(bdp->device))
> +				netif_carrier_on(bdp->device);
> +		} else {
> +			if (netif_carrier_ok(bdp->device))
> +				netif_carrier_off(bdp->device);
> +		}
>  
>  	return link;
>  }

--
  Michael Rozhavsky
  Senior Software Engineer
  MRV International
  Tel: +972 (4) 993-6248
  Fax: +972 (4) 989-0564
  http://www.mrv.com
