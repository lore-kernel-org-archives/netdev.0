From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] brcm80211: brcmfmac: Ensure that incoming skb's are
 writable
Date: Thu, 20 Apr 2017 21:48:25 +0200
Message-ID: <b6891d80-cc5f-3bcd-72aa-1de2d9bb9144@broadcom.com>
References: <20170420111651.10213-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>
To: James Hughes <james.hughes@raspberrypi.org>,
        netdev@vger.kernel.org, Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38399 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947198AbdDTTs2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:48:28 -0400
Received: by mail-wm0-f51.google.com with SMTP id r190so1318987wme.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 12:48:27 -0700 (PDT)
In-Reply-To: <20170420111651.10213-1-james.hughes@raspberrypi.org>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ linux-wireless

On 4/20/2017 1:16 PM, James Hughes wrote:
> The driver was adding header information to incoming skb
> without ensuring the head was uncloned and hence writable.
> 
> skb_cow_head has been used to ensure they are writable, however,
> this required some changes to error handling to ensure that
> if skb_cow_head failed it was not ignored.
> 
> This really needs to be reviewed by someone who is more familiar
> with this code base to ensure any deallocation of skb's is
> still correct.
> 
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
> ---
>   .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    | 15 ++++++++--
>   .../wireless/broadcom/brcm80211/brcmfmac/core.c    | 23 +++++-----------
>   .../broadcom/brcm80211/brcmfmac/fwsignal.c         | 32 +++++++++++++++++-----
>   .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |  7 ++++-
>   4 files changed, 51 insertions(+), 26 deletions(-)
> 

[...]

> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> index 5eaac13..08272e8 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> @@ -198,7 +198,7 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
>   	int ret;
>   	struct brcmf_if *ifp = netdev_priv(ndev);
>   	struct brcmf_pub *drvr = ifp->drvr;
> -	struct ethhdr *eh = (struct ethhdr *)(skb->data);
> +	struct ethhdr *eh;
>   
>   	brcmf_dbg(DATA, "Enter, bsscfgidx=%d\n", ifp->bsscfgidx);
>   
> @@ -212,23 +212,14 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
>   	}
>   
>   	/* Make sure there's enough room for any header */
> -	if (skb_headroom(skb) < drvr->hdrlen) {
> -		struct sk_buff *skb2;
> -
> -		brcmf_dbg(INFO, "%s: insufficient headroom\n",
> -			  brcmf_ifname(ifp));
> -		drvr->bus_if->tx_realloc++;
> -		skb2 = skb_realloc_headroom(skb, drvr->hdrlen);
> -		dev_kfree_skb(skb);
> -		skb = skb2;
> -		if (skb == NULL) {
> -			brcmf_err("%s: skb_realloc_headroom failed\n",
> -				  brcmf_ifname(ifp));
> -			ret = -ENOMEM;
> -			goto done;
> -		}

What you are throwing away here is code that assures there is sufficient 
headroom for protocol and bus layer in the tx path, because that is 
determined by drvr->hdrlen. This is where the skb is handed to the 
driver so if you could leave the functionality above *and* assure it is 
writeable that would be the best solution as there is no need for all 
the other changes down the tx path.

> +	ret = skb_cow_head(skb, drvr->hdrlen);
> +	if (ret) {

So move the realloc code above here instead of simply freeing the skb.

> +		dev_kfree_skb_any(skb);
> +		goto done;
>   	}
>   
> +	eh = (struct ethhdr *)(skb->data);

Now this is actually a separate fix so I would like a separate patch for it.

I have a RPi3 sitting on my desk so how can I replicate the issue. It 
was something about broadcast/multicast traffic when using AP mode and a 
bridge, right?

Regards,
Arend
