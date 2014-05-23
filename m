From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/1] net: Set NOCARRIER bit of etherdev state at
 initialization
Date: Fri, 23 May 2014 12:38:01 -0500
Message-ID: <1400866681.18322.27.camel@dcbw.local>
References: <537F7EEF.3060701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
	avi.kp.137@gmail.com, edumazet@google.com, netdev@vger.kernel.org
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbaEWRiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 13:38:09 -0400
In-Reply-To: <537F7EEF.3060701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-23 at 22:31 +0530, Balakumaran Kannan wrote:
> For any etherdev 'netif_carrier_ok' should succeed only after phy
> layer determines carrier state through auto-negotiation or setting
> it forcibly.
> 
> So ethernet drivers should set '__LINK_STATE_NOCARRIER' bit of
> 'dev->state' using 'netif_carrier_off' call at driver initialization.
> As it is common for all ethernet devices, 'netif_carrier_off' call
> could be moved to 'ether_setup'.

Unless I misunderstand, wouldn't this turn off carrier for all devices
until the driver explicitly sets the carrier up?

The current "carrier on until told otherwise" model is intentional,
because not all drivers support carrier detection, and thus we must
assume the carrier is on until the driver tells us it is not on.

Would this patch break that model?

Dan

> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
> ---
> 'netif_carrier_off' could be called anywhere in between
> 'alloc_etherdev' and 'phy_start'. For example,
> 1. e1000 driver calls at the end of 'e1000_probe'
> 2. intel i40e driver calls at the beginning of 'i40e_open'
> 3. realtek r8169 driver calls at the end of 'rtl_init_one'
> 
> But some driver misses this call. For example smsc911x driver doesn't
> call 'netif_carrier_off' before calling 'phy_start'. So device starts
> performing dhcp and IPv6 DAD even if carrier is not ready.
> 
> So it is better to move 'netif_carrier_off' call to 'ether_setup'. And
> drivers can remove this call from their initialization functions.
> ---
>  net/ethernet/eth.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 5dc638c..45f6703 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -369,6 +369,9 @@ void ether_setup(struct net_device *dev)
>  
>  	memset(dev->broadcast, 0xFF, ETH_ALEN);
>  
> +	/* Carrier state should be off initially */
> +	netif_carrier_off(dev);
> +
>  }
>  EXPORT_SYMBOL(ether_setup);
>  
