From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next]smsc911x: Adding support for Micochip LAN9250
 Ethernet controller
Date: Thu, 20 Apr 2017 00:01:54 +0200
Message-ID: <20170419220154.GA16977@lunn.ch>
References: <C3C28FB10418274EB7FD7C2B85C796A4412465FE@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com, steve.glendinning@shawell.net
To: David.Cai@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35242 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935340AbdDSWB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 18:01:59 -0400
Content-Disposition: inline
In-Reply-To: <C3C28FB10418274EB7FD7C2B85C796A4412465FE@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 09:26:43PM +0000, David.Cai@microchip.com wrote:
> Adding support for Microchip LAN9250 Ethernet controller.
> 
> Signed-off-by: David Cai <david.cai@microchip.com>
> ---
> Changes
> V2
>  -  email format changed
>  - remove unnecessary text in commit log
 
Much better, thanks.

>  drivers/net/ethernet/smsc/smsc911x.c | 32 +++++++++++++++++++++++++++-----
>  drivers/net/ethernet/smsc/smsc911x.h |  3 +++
>  2 files changed, 30 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index fa5ca09..22b1951 100644
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
>  	 * Make sure to power-up the PHY chip before doing a reset, otherwise
> @@ -1476,15 +1481,23 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
>  		}
>  	}
>  
> +	if (pdata->sub_generation) {

I know it does not make a difference at the moment, but shouldn't this
be

	if (pdata>generation == 4 && pdata->sub_generation) {

at some point other sub-generations might become important, at which
point your simpler code breaks.

> +		/* special reset for  LAN9250 */
> +		reset_offset = RESET_CTL;
> +		reset_mask = RESET_CTL_DIGITAL_RST_;
> +	}

> @@ -2251,6 +2264,9 @@ static int smsc911x_init(struct net_device *dev)
>  	/* Default generation to zero (all workarounds apply) */
>  	pdata->generation = 0;
>  
> +	/* Default sub_generation to zero */
> +	pdata->sub_generation = 0;
> +

alloc_etherdev() uses kzalloc, so sub_generation is guaranteed to be
0. No need to set it here.

>  	pdata->idrev = smsc911x_reg_read(pdata, ID_REV);
>  	switch (pdata->idrev & 0xFFFF0000) {
>  	case 0x01180000:
> @@ -2278,6 +2294,12 @@ static int smsc911x_init(struct net_device *dev)
>  		pdata->generation = 4;
>  		break;
>  
> +	case 0x92500000:
> +		/* LAN9250 */
> +		pdata->generation = 4;
> +		pdata->sub_generation = 1;
> +		break;
>

Maybe it would be more readable in general to add some #defines for
0x92500000 and all the other hex values, and then in smsc911x_init()
look at the pdata->idrev?

     Andrew
