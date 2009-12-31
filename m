From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Thu, 31 Dec 2009 19:51:48 +0100
Message-ID: <4B3CF2C4.5070203@gmail.com>
References: <4B3C8323.1080301@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	flyboy@gmail.com, dhazelton@enter.net, mbreuer@majjas.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:47904 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbZLaSv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 13:51:57 -0500
Received: by fxm25 with SMTP id 25so6869451fxm.21
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 10:51:55 -0800 (PST)
In-Reply-To: <4B3C8323.1080301@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike McCormack wrote, On 12/31/2009 11:55 AM:

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

Could you give some scenario of the oops/fix?
Btw, even if it worked, you should use netif_tx_lock_bh
version considering sky2_detach use contexts, I guess.

Jarek P.

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


