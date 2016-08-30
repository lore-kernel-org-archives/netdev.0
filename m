From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net] tg3: Fix for disallow tx coalescing time to be 0
Date: Tue, 30 Aug 2016 08:46:07 -0700
Message-ID: <CACKFLimbY8xyd5LBgyDxV_v_xrwGShy9Vb3m1pO6mboHJsKpFw@mail.gmail.com>
References: <1472567935-13177-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Satish Baddipadige <satish.baddipadige@broadcom.com>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33550 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932571AbcH3PqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 11:46:09 -0400
Received: by mail-oi0-f41.google.com with SMTP id c15so31671593oig.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 08:46:09 -0700 (PDT)
In-Reply-To: <1472567935-13177-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2016 at 7:38 AM, Ivan Vecera <ivecera@redhat.com> wrote:
> The recent commit 087d7a8c disallows to set Rx coalescing time to be 0
> as this stops generating interrupts for the incoming packets. I found
> the zero Tx coalescing time stops generating interrupts similarly for
> outgoing packets and fires Tx watchdog later. To avoid this, don't allow
> to set Tx coalescing time to 0.
>
> Cc: satish.baddipadige@broadcom.com
> Cc: siva.kallam@broadcom.com
> Cc: michael.chan@broadcom.com
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 6592612..07e3beb 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -14012,6 +14012,7 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
>         if ((ec->rx_coalesce_usecs > MAX_RXCOL_TICKS) ||
>             (!ec->rx_coalesce_usecs) ||
>             (ec->tx_coalesce_usecs > MAX_TXCOL_TICKS) ||
> +           (!ec->tx_coalesce_usecs) ||
>             (ec->rx_max_coalesced_frames > MAX_RXMAX_FRAMES) ||
>             (ec->tx_max_coalesced_frames > MAX_TXMAX_FRAMES) ||
>             (ec->rx_coalesce_usecs_irq > max_rxcoal_tick_int) ||


As Rick pointed out last time, we can remove this check which follows
the block of code above:

/* No tx interrupts will be generated if both are zero */
if ((ec->tx_coalesce_usecs == 0) &&
   (ec->tx_max_coalesced_frames == 0))
return -EINVAL;
