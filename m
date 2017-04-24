From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH v2] brcmfmac: Make skb header writable before use
Date: Mon, 24 Apr 2017 21:14:11 +0200
Message-ID: <e03e2f42-0439-5d49-d1aa-50ce2da4ff50@broadcom.com>
References: <20170424130322.476-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: James Hughes <james.hughes@raspberrypi.org>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34462 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S976468AbdDXTOQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:14:16 -0400
Received: by mail-qk0-f180.google.com with SMTP id y63so96999882qkd.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 12:14:16 -0700 (PDT)
In-Reply-To: <20170424130322.476-1-james.hughes@raspberrypi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24-4-2017 15:03, James Hughes wrote:
> The driver was making changes to the skb_header without
> ensuring it was writable (i.e. uncloned).
> This patch also removes some boiler plate header size
> checking/adjustment code as that is also handled by the
> skb_cow_header function used to make header writable.
> 
> This patch depends on
> brcmfmac: Ensure pointer correctly set if skb data location changes

Hi James,

I actually thought I was going to tackle this so I spend some time
working on it today, but I will submit that as a subsequent patch. Below
some comments but apart from that:

Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
> ---
> Changes in v2
>   Makes the _cow_ call at the entry point of the skb in to the
>   stack, means only needs to be done once, and error handling
>   is easier.
>   Split a separate minor bug fix off to a separate patch (which
>   this patch depends on)
> 
> 
> 
>  .../net/wireless/broadcom/brcm80211/brcmfmac/core.c   | 19 ++++---------------
>  1 file changed, 4 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> index 9b7c19a508ac..88f8675a94c2 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> @@ -211,22 +211,11 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
>  		goto done;
>  	}
>  
> -	/* Make sure there's enough room for any header */
> -	if (skb_headroom(skb) < drvr->hdrlen) {
> -		struct sk_buff *skb2;
> -
> -		brcmf_dbg(INFO, "%s: insufficient headroom\n",
> -			  brcmf_ifname(ifp));
> -		drvr->bus_if->tx_realloc++;
> -		skb2 = skb_realloc_headroom(skb, drvr->hdrlen);
> +	/* Make sure there's enough room for any header, and make it writable */
Please rephrase: /* Make sure there is enough writable headroom */

Just do:
	ret = skb_cow_head(skb, drvr->hdrlen);
	if (ret < 0) {
		brcmf_err("%s: skb_cow_head failed\n",
			  brcmf_ifname(ifp));
> +	if (skb_cow_head(skb, drvr->hdrlen)) {
>  		dev_kfree_skb(skb);
> -		skb = skb2;
> -		if (skb == NULL) {
> -			brcmf_err("%s: skb_realloc_headroom failed\n",
> -				  brcmf_ifname(ifp));
> -			ret = -ENOMEM;
> -			goto done;
> -		}
> +		ret = -ENOMEM;
	... and drop this assignment.

> +		goto done;
>  	}
>  
>  	/* validate length for ether packet */
> 
