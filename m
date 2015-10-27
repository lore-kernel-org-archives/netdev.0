From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 2/4] ipv4: add defensive check for CHECKSUM_PARTIAL
 skbs in ip_fragment
Date: Tue, 27 Oct 2015 09:06:10 -0700
Message-ID: <CALx6S35PRhHOtxowWqF4YJYgVMmMiQgn1hf58XXh8QCizY4qcQ@mail.gmail.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
	<1445958135-19805-3-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35809 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964811AbbJ0QGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 12:06:11 -0400
Received: by iofz202 with SMTP id z202so225968377iof.2
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 09:06:10 -0700 (PDT)
In-Reply-To: <1445958135-19805-3-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 8:02 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> CHECKSUM_PARTIAL skbs should never arrive in ip_fragment. If we get one
> of those warn about them once and handle them gracefully by recalculating
> the checksum.
>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Benjamin Coddington <bcodding@redhat.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv4/ip_output.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 0b02417..3f94a3b 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -533,6 +533,11 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
>
>         dev = rt->dst.dev;
>
> +       /* for offloaded checksums cleanup checksum before fragmentation */
> +       if (WARN_ON_ONCE(skb->ip_summed == CHECKSUM_PARTIAL) &&
> +           (err = skb_checksum_help(skb)))
> +               goto fail;
> +
Why the WARN_ON_ONCE? Is there a prior check somewhere that avoid this
condition?

>         /*
>          *      Point into the IP datagram header.
>          */
> @@ -657,9 +662,6 @@ slow_path_clean:
>         }
>
>  slow_path:
> -       /* for offloaded checksums cleanup checksum before fragmentation */
> -       if ((skb->ip_summed == CHECKSUM_PARTIAL) && skb_checksum_help(skb))
> -               goto fail;
>         iph = ip_hdr(skb);
>
>         left = skb->len - hlen;         /* Space per frame */
> --
> 2.5.0
>
