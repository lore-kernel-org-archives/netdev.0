From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net: qualcomm: rmnet: Support recycling frames
 to real device
Date: Fri, 27 Oct 2017 14:00:20 -0700
Message-ID: <CAKgT0Ufnupf=fUbivLWrMhmfkcx4f0ApZ7gS_9VK7P7J8zB1aw@mail.gmail.com>
References: <1509136208-14768-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:52543 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932329AbdJ0VAW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 17:00:22 -0400
Received: by mail-qt0-f195.google.com with SMTP id 31so10004487qtz.9
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 14:00:22 -0700 (PDT)
In-Reply-To: <1509136208-14768-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 1:30 PM, Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org> wrote:
> For deaggregation, the real device receives a large linear skb and
> passes it on to rmnet. rmnet creates new skbs from this large frame.
>
> If the real device supports recycling, it does not need to allocate
> the large skbs during packet reception and can instead reuse them.
>
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
> index 29842cc..7869fcf 100644
> --- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
> +++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
> @@ -108,7 +108,10 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
>                 while ((skbn = rmnet_map_deaggregate(skb)) != NULL)
>                         __rmnet_map_ingress_handler(skbn, port);
>
> -               consume_skb(skb);
> +               if (skb->destructor)
> +                       skb->destructor(skb);
> +               else
> +                       consume_skb(skb);
>         } else {
>                 __rmnet_map_ingress_handler(skb, port);
>         }

This doesn't make sense to me, maybe I am missing something. What
"real device" is setting the skb->destructor() and doing it to somehow
handle recycling? The only driver I can find that is setting
skb->desctructor() is the Chelsio drivers, and they appear to be using
it to just clean-up DMA mappings in their transmit path.

Thanks.

- Alex
