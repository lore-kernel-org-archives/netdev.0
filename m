From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Thu, 31 Dec 2009 10:58:15 -0500
Message-ID: <4B3CCA17.5020707@majjas.com>
References: <4B3C8323.1080301@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	flyboy@gmail.com, dhazelton@enter.net
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta2.srv.hcvlny.cv.net ([167.206.4.197]:36084 "EHLO
	mta2.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbZLaP6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 10:58:42 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta2.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KVI00KNLXPTPS30@mta2.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Thu, 31 Dec 2009 10:58:41 -0500 (EST)
In-reply-to: <4B3C8323.1080301@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This doesn't solve the issue on my system. Just ran a test - same 
errors. I don't think that the under-load errors I'm seeing involve 
sky2_detatch. I'm thinking it's related to the dhcp AF_INTERNET fix that 
solved the lockup under load - that something outside of sky2 is 
corrupting an skb.
On 12/31/2009 5:55 AM, Mike McCormack wrote:
> netif_device_detach() does not take the tx_lock, so it's
>   possible that a call to sky2_xmit_frame is still in
>   progress after netif_device_detach() is complete.
>
> Take netif_tx_lock() to make sure all transmits have
>   stopped while we're disabling the devices and that
>   no other CPU is still transmitting a frame after
>   we've disabling the device.
>
> Proposed fix for "sky2 panic under load" reported by Berck E. Nash.
>
> Signed-off-by: Mike McCormack<mikem@ring3k.org>
> ---
>   drivers/net/sky2.c |    2 ++
>   1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index faa4841..8ae8520 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -3176,7 +3176,9 @@ static void sky2_reset(struct sky2_hw *hw)
>   static void sky2_detach(struct net_device *dev)
>   {
>   	if (netif_running(dev)) {
> +		netif_tx_lock(dev);
>   		netif_device_detach(dev);	/* stop txq */
> +		netif_tx_unlock(dev);
>   		sky2_down(dev);
>   	}
>   }
>    

