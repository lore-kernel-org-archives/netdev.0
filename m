From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH v2] brcmfmac: Make skb header writable before use
Date: Tue, 25 Apr 2017 09:38:39 +0200
Message-ID: <ef75a194-2e0b-6586-7b31-2eb83128d2bc@broadcom.com>
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
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38221 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943081AbdDYHim (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 03:38:42 -0400
Received: by mail-wm0-f46.google.com with SMTP id r190so87921408wme.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 00:38:42 -0700 (PDT)
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
> 
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
> ---
> Changes in v2
>   Makes the _cow_ call at the entry point of the skb in to the
>   stack, means only needs to be done once, and error handling
>   is easier.
>   Split a separate minor bug fix off to a separate patch (which
>   this patch depends on)

Hi James,

Can you please indicate in this section that you want it applied for
4.12 as it is an important fix. Probably will have to wait until after
the merge window before it can get in the wireless-drivers repo.

Regards,
Arend

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
> +		goto done;
>  	}
>  
>  	/* validate length for ether packet */
> 
