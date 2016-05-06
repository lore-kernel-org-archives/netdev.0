From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 next-next 04/12] udp: Don't set skb->encapsulation with RCO
Date: Fri, 6 May 2016 13:23:57 -0700
Message-ID: <CAKgT0UepRt3dP9=g2+cdM1iL6t5j5YA_hfGcFRK40aUFCxFaXg@mail.gmail.com>
References: <1462565096-4076043-1-git-send-email-tom@herbertland.com>
	<1462565096-4076043-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38371 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758275AbcEFUX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:23:58 -0400
Received: by mail-ig0-f181.google.com with SMTP id m9so50159193ige.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 13:23:58 -0700 (PDT)
In-Reply-To: <1462565096-4076043-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 6, 2016 at 1:04 PM, Tom Herbert <tom@herbertland.com> wrote:
> When RCO is in effect we want to ensure that the outer checksum is
> properly offloaded. Don't set skb->encapsulation in this case to
> ensure that checksum offload is later considered for hw_features
> instead of hw_enc_features.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/ipv4/udp_offload.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index b556ef6..92a9222 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -94,11 +94,12 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>         do {
>                 unsigned int len;
>
> -               if (remcsum)
> +               if (remcsum) {
>                         skb->ip_summed = CHECKSUM_NONE;
> -
> -               /* Set up inner headers if we are offloading inner checksum */
> -               if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +               } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +                       /* Set up inner headers if we are offloading inner
> +                        * checksum
> +                        */
>                         skb_reset_inner_headers(skb);
>                         skb->encapsulation = 1;
>                 }

You can just drop this patch.  It doesn't actually change anything
behaviorwise.  If remcsum is set then skb->ip_summed is set to
CHECKSUM_NONE so it isn't going to hit the CHECKSUM_PARTIAL code so
you don't need the else.

- Alex
