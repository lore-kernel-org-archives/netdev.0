From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 3/3] net: systemport: Add a check for oversized packets
Date: Thu, 28 May 2015 21:00:48 -0700
Message-ID: <CAGXr9JHJ5X9FVTO-+-61HnFfsf=1dz7ObbbLxxDy9Zx=UbqhqQ@mail.gmail.com>
References: <1432851884-12026-1-git-send-email-f.fainelli@gmail.com>
	<1432851884-12026-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:36242 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbbE2EAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 00:00:49 -0400
Received: by qgf2 with SMTP id 2so24775921qgf.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 21:00:48 -0700 (PDT)
In-Reply-To: <1432851884-12026-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 3:24 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Occasionnaly we may get oversized packets from the hardware which exceed
> the nomimal 2KiB buffer size we allocate SKBs with. Add an early check
> which drops the packet to avoid invoking skb_over_panic() and move on to
> processing the next packet.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Petri Gynther <pgynther@google.com>

> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index d777b0db9e63..909ad7a0d480 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -638,6 +638,14 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
>                           p_index, priv->rx_c_index, priv->rx_read_ptr,
>                           len, status);
>
> +               if (unlikely(len > RX_BUF_LENGTH)) {
> +                       netif_err(priv, rx_status, ndev, "oversized packet\n");
> +                       ndev->stats.rx_length_errors++;
> +                       ndev->stats.rx_errors++;
> +                       dev_kfree_skb_any(skb);
> +                       goto next;
> +               }
> +
>                 if (unlikely(!(status & DESC_EOP) || !(status & DESC_SOP))) {
>                         netif_err(priv, rx_status, ndev, "fragmented packet!\n");
>                         ndev->stats.rx_dropped++;
> --
> 2.1.0
>
