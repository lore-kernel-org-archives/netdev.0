From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next]smsc911x: Adding support for Micochip LAN9250
 Ethernet controller
Date: Wed, 26 Apr 2017 16:34:13 +0200
Message-ID: <20170426143413.GC665@lunn.ch>
References: <C3C28FB10418274EB7FD7C2B85C796A441247573@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com, steve.glendinning@shawell.net
To: David.Cai@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42000 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1176582AbdDZOeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 10:34:16 -0400
Content-Disposition: inline
In-Reply-To: <C3C28FB10418274EB7FD7C2B85C796A441247573@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 01:55:52PM +0000, David.Cai@microchip.com wrote:
> From: David Cai <david.cai@microchip.com>
> 
> Adding support for Microchip LAN9250 Ethernet controller.
> 
> Signed-off-by: David Cai <david.cai@microchip.com>
> ---
> Changes
> V2
>  -  email format changed
>  - remove unnecessary text in commit log Changes
> V3
>  - defined all supported Ethernet controller chip ID.
>  - removed pdata->sub_generation = 0;
>  - changed 'if (pdata->sub_generation)' to 
>  	 if (pdata>generation == 4 && pdata->sub_generation)
>  
>  drivers/net/ethernet/smsc/smsc911x.c | 55 ++++++++++++++++++++++++------------
>  drivers/net/ethernet/smsc/smsc911x.h | 19 +++++++++++++
>  2 files changed, 56 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index fa5ca09..e35fe96 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -25,7 +25,7 @@
>   *   LAN9215, LAN9216, LAN9217, LAN9218
>   *   LAN9210, LAN9211
>   *   LAN9220, LAN9221
> - *   LAN89218
> + *   LAN89218,LAN9250
>   *
>   */
>  
> @@ -104,6 +104,9 @@ struct smsc911x_data {
>  	/* used to decide which workarounds apply */
>  	unsigned int generation;
>  
> +	/* used to decide which sub generation product work arounds to apply */
> +	unsigned int sub_generation;
> +
>  	/* device configuration (copied from platform_data during probe) */
>  	struct smsc911x_platform_config config;
>  
> @@ -1450,6 +1453,8 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
>  	unsigned int timeout;
>  	unsigned int temp;
>  	int ret;
> +	unsigned int reset_offset = HW_CFG;
> +	unsigned int reset_mask = HW_CFG_SRST_;
>  
>  	/*
>  	 * Make sure to power-up the PHY chip before doing a reset, otherwise @@ -1476,15 +1481,23 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
>  		}
>  	}
>  
> +	if (pdata->generation == 4 && pdata->sub_generation) {
> +		/* special reset for  LAN9250 */
> +		reset_offset = RESET_CTL;
> +		reset_mask = RESET_CTL_DIGITAL_RST_;
> +	}

Hi David

Thanks for adding the chip ID #defines. But the point of doing that is
that you can then change this above to:

  	if (pdata->idrev & 0xFFFF0000 == LAN9250) {
		reset_offset = RESET_CTL;
		reset_mask = RESET_CTL_DIGITAL_RST_;
}

which is much more readable.

      Andrew
