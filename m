From: "Nori, Sekhar" <nsekhar@ti.com>
Subject: RE: [PATCH] [RFC] davinci_emac: don't WARN_ON cpdma_chan_submit
 -ENOMEM
Date: Thu, 28 Apr 2011 00:18:14 +0530
Message-ID: <B85A65D85D7EB246BE421B3FB0FBB593024CBA9B56@dbde02.ent.ti.com>
References: <1303407032-7526-1-git-send-email-bengardiner@nanometrics.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Govindarajan, Sriramakrishnan" <srk@ti.com>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Ben Gardiner <bengardiner@nanometrics.ca>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:58241 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753528Ab1D0Sss convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 14:48:48 -0400
In-Reply-To: <1303407032-7526-1-git-send-email-bengardiner@nanometrics.ca>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

[CCing netdev maintainer]

On Thu, Apr 21, 2011 at 23:00:32, Ben Gardiner wrote:
> The current implementation of emac_rx_handler, when the host is
> flooded, will result in a great deal of WARNs on the console; due to
> the return value of cpdma_chan_submit. This function can error with
> EINVAL and ENOMEM; the former when the channel is in an invalid
> state, in which case the caller is in error. The latter when a cpdma
> descriptor cannot be allocated.
> 
> When flooded, cpdma_chan_submit will return -ENOMEM;
> treat the inability to allocate a cpdma descriptor as an rx error
> similar in behaviour to when emac_rx_alloc returns NULL.
> 
> No Signed-off-by yet; not complete fix (see below).
> CC: Sriramakrishnan A G <srk@ti.com>
> 
> ---
> I'm new to network drivers -- and kernel development, really. I'd be
> happy to receive feedback on this approach of resolving the -ENOMEM
> when flooded. Is there a more conventional approach? Shoud these frames
> be recorded as 'dropped'?

Yes, that seems to be the right approach. You can look at
8139too.c as an example. dev.stats.rx_dropped is incremented
in this case.

The same stat needs to be incremented when emac_rx_alloc() fails.

> 
> Testing was performed on da850evm both with and without  "net:
> davinci_emac: fix spinlock bug with dma channel cleanup" from
> Sriramakrishnan A G applied. The behaviour was the same: the emac is
> not able to receive any frames after being flooded -- but it can still
> send. I would appreciate any insight into the potential causes of the
> lockup.

This is most likely due to the Rx channel hitting an
"End-of-Queue (EOQ)" and the driver failing to restart the
DMA on the channel by reprogramming the "Head Descriptor
Pointer (HDP)". You can verify that the HDP is indeed
NULL for Rx channel 0 (the channel used for Rx in the
driver).

I can see that there is logic in place to restart the
DMA when EOQ is hit in __cpdma_chan_submit(), but there
could be some corner case lurking somewhere.

> 
> Best Regards,
> Ben Gardiner
> 
> Nanometrics Inc.
> http://www.nanometrics.ca
> 
> ---
>  drivers/net/davinci_emac.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 7018bfe..17c48d6 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -1037,8 +1037,12 @@ static void emac_rx_handler(void *token, int len, int status)
>  recycle:
>  	ret = cpdma_chan_submit(priv->rxchan, skb, skb->data,
>  			skb_tailroom(skb), GFP_KERNEL);
> -	if (WARN_ON(ret < 0))
> +	WARN_ON(ret == -EINVAL);

I think we are better off shifting the WARN_ON to cpdma_chan_submit()
itself. Let that function decide which errors to warn on and which
ones to be just silent on.

> +	if (ret < 0) {
> +		if (netif_msg_rx_err(priv) && net_ratelimit())
> +			dev_err(emac_dev, "failed cpdma submit\n");

Or rather drop the WARN_ON() altogether since you are anyway
printing this rate limited error message.

Thanks,
Sekhar

>  		dev_kfree_skb_any(skb);
> +	}
>  }
>  
>  static void emac_tx_handler(void *token, int len, int status)
> -- 
> 1.7.1
> 
> _______________________________________________
> Davinci-linux-open-source mailing list
> Davinci-linux-open-source@linux.davincidsp.com
> http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
> 

