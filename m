From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net v2 1/3] net: bcmgenet: fix off-by-one in incrementing
 read pointer
Date: Fri, 10 Oct 2014 11:15:11 -0700
Message-ID: <CAGXr9JHyeE1xjeprLWKCjfEJbaZQGVyNZXh5H8gUAZfObWToZA@mail.gmail.com>
References: <1412963514-7718-1-git-send-email-f.fainelli@gmail.com>
	<1412963514-7718-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:54426 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbaJJSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:15:12 -0400
Received: by mail-vc0-f179.google.com with SMTP id im17so3046869vcb.24
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:15:11 -0700 (PDT)
In-Reply-To: <1412963514-7718-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good to me.

On Fri, Oct 10, 2014 at 10:51 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Commit b629be5c8399d7c423b92135eb43a86c924d1cbc ("net: bcmgenet: check
> harder for out of memory conditions") moved the increment of the local
> read pointer *before* reading from the hardware descriptor using
> dmadesc_get_length_status(), which creates an off-by-one situation.
>
> Fix this by moving again the read_ptr increment after we have read the
> hardware descriptor to get both the control block and the read pointer
> back in sync.
>
> Fixes: b629be5c8399 ("net: bcmgenet: check harder for out of memory conditions")
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Petri Gynther <pgynther@google.com>

> ---
> Changes in v2:
> - moved the rxpktprocessed and rx_read_ptr increment after refiling the control
>   block
>
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index fff2634b6f34..fdc9ec09e453 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1285,11 +1285,6 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>                 cb = &priv->rx_cbs[priv->rx_read_ptr];
>                 skb = cb->skb;
>
> -               rxpktprocessed++;
> -
> -               priv->rx_read_ptr++;
> -               priv->rx_read_ptr &= (priv->num_rx_bds - 1);
> -
>                 /* We do not have a backing SKB, so we do not have a
>                  * corresponding DMA mapping for this incoming packet since
>                  * bcmgenet_rx_refill always either has both skb and mapping or
> @@ -1404,6 +1399,10 @@ refill:
>                 err = bcmgenet_rx_refill(priv, cb);
>                 if (err)
>                         netif_err(priv, rx_err, dev, "Rx refill failed\n");
> +
> +               rxpktprocessed++;
> +               priv->rx_read_ptr++;
> +               priv->rx_read_ptr &= (priv->num_rx_bds - 1);
>         }
>
>         return rxpktprocessed;
> --
> 1.9.1
>
