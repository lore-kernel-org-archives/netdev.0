From: Berck Nash <flyboy@gmail.com>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Thu, 31 Dec 2009 09:33:15 -0700
Message-ID: <4B3CD24B.2000005@gmail.com>
References: <4B3C8323.1080301@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	dhazelton@enter.net, mbreuer@majjas.com
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f211.google.com ([209.85.217.211]:52680 "EHLO
	mail-gx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598AbZLaQdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 11:33:19 -0500
Received: by gxk3 with SMTP id 3so687278gxk.1
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 08:33:18 -0800 (PST)
In-Reply-To: <4B3C8323.1080301@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.  I'll patch and report back.  Since I'm not able to reproduce
this oops on demand, I'll just have to run it for a week or so and see
if it comes comes back.  I've been getting one every few days, so a week
 should be enough to see if this works.

Mike McCormack wrote:
> netif_device_detach() does not take the tx_lock, so it's
>  possible that a call to sky2_xmit_frame is still in
>  progress after netif_device_detach() is complete.
> 
> Take netif_tx_lock() to make sure all transmits have
>  stopped while we're disabling the devices and that
>  no other CPU is still transmitting a frame after
>  we've disabling the device.
> 
> Proposed fix for "sky2 panic under load" reported by Berck E. Nash.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> ---
>  drivers/net/sky2.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index faa4841..8ae8520 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -3176,7 +3176,9 @@ static void sky2_reset(struct sky2_hw *hw)
>  static void sky2_detach(struct net_device *dev)
>  {
>  	if (netif_running(dev)) {
> +		netif_tx_lock(dev);
>  		netif_device_detach(dev);	/* stop txq */
> +		netif_tx_unlock(dev);
>  		sky2_down(dev);
>  	}
>  }

