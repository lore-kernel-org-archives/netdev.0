From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 03/14] udp: Don't set skb->encapsulation with RCO
Date: Wed, 4 May 2016 19:42:31 -0700
Message-ID: <CAKgT0UeUTpuENPxOr7APFZ1YrVkCha=10qk=hh67eNb1u3Pexg@mail.gmail.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
	<1462410164-1953217-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35094 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755736AbcEECmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 22:42:36 -0400
Received: by mail-io0-f171.google.com with SMTP id d62so72969008iof.2
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 19:42:31 -0700 (PDT)
In-Reply-To: <1462410164-1953217-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2016 at 6:02 PM, Tom Herbert <tom@herbertland.com> wrote:
> When RCO is in effect we want to ensure that the outer checksum is
> properly offloaded. Don't set skb->encapsulation in this case to
> ensure that checksum offload is later considered for hw_features
> instead of hw_enc_features.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/ipv4/udp_offload.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index b556ef6..4eedec6 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -94,11 +94,13 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>         do {
>                 unsigned int len;
>
> -               if (remcsum)
> +               if (remcsum) {
>                         skb->ip_summed = CHECKSUM_NONE;
> -
> -               /* Set up inner headers if we are offloading inner checksum */
> -               if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +                       skb->encapsulation = 0;
> +               } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +                       /* Set up inner headers if we are offloading inner
> +                        * checksum
> +                        */
>                         skb_reset_inner_headers(skb);
>                         skb->encapsulation = 1;
>                 }


Why are you wasting cycles clearing a value that should have already
been cleared?

We set skb->encapsulation to 0 for the incoming skb before we segment
it.  As such all of the segments we get should also not have it set.
It seems like you are just wasting cycles writing it again even though
it isn't written.

- Alex
