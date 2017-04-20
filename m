From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] brcm80211: brcmfmac: Ensure that incoming skb's are
 writable
Date: Thu, 20 Apr 2017 05:49:29 -0700
Message-ID: <1492692569.22296.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170420111651.10213-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>
To: James Hughes <james.hughes@raspberrypi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34503 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965942AbdDTMtc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 08:49:32 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so16107890ioi.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 05:49:32 -0700 (PDT)
In-Reply-To: <20170420111651.10213-1-james.hughes@raspberrypi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-20 at 12:16 +0100, James Hughes wrote:
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

You mention incoming skb in patch title, yet you change part of TX path.

Please split your changes in individual ones, to ease future bisections,
and ease backports as well.


Also, while it is known that TX path can deal with cloned skbs,
it is not clear why RX path has clones.

Most drivers allocate an skb, fill it, and pass it to network stack.

So please make sure all these changes are really needed.

> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
> index d138260..0e53c8a 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
> @@ -2719,7 +2719,7 @@ static bool brcmf_sdio_prec_enq(struct pktq *q, struct sk_buff *pkt, int prec)
>  
>  static int brcmf_sdio_bus_txdata(struct device *dev, struct sk_buff *pkt)
>  {
> -	int ret = -EBADE;
> +	int ret = -EBADE, err;
>  	uint prec;
>  	struct brcmf_bus *bus_if = dev_get_drvdata(dev);
>  	struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
> @@ -2729,6 +2729,11 @@ static int brcmf_sdio_bus_txdata(struct device *dev, struct sk_buff *pkt)
>  	if (sdiodev->state != BRCMF_SDIOD_DATA)
>  		return -EIO;
>  
> +	err = skb_cow_head(pkt, bus->tx_hdrlen);
> +
> +	if (err)
> +		return err;
> +
>  	/* Add space for the header */
>  	skb_push(pkt, bus->tx_hdrlen);
>  	/* precondition: IS_ALIGNED((unsigned long)(pkt->data), 2) */
