From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net 2/3] udp_offload: Set encapsulation before inner completes.
Date: Fri, 29 Apr 2016 18:42:48 -0700
Message-ID: <CALx6S35N7PtaERFCs27X5GuqUZKYkPFeG8ZQB=0uGpydw+ABEg@mail.gmail.com>
References: <1461968887-4993-1-git-send-email-jarno@ovn.org>
	<1461968887-4993-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33858 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbcD3Bmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 21:42:49 -0400
Received: by mail-io0-f169.google.com with SMTP id 190so118679251iow.1
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 18:42:49 -0700 (PDT)
In-Reply-To: <1461968887-4993-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2016 at 3:28 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> UDP tunnel segmentation code relies on the inner offsets being set for
> an UDP tunnel GSO packet.  The inner *_complete() functions will set
> the inner offsets only if the encapsulation is set before calling
> them, but udp_gro_complete() set it only after the inner *_complete()
> functions were done.
>
> Also, remove the setting of the inner_mac_header in udp_gro_complete()
> as it was wrongly set to the beginning of the UDP tunnel header rather
> than the inner MAC header.
>
How did you test this? Do you have a test case for the problem?

The general problem is that skb->encapsulation is the indicator that
the inner offsets are valid, but there are many instances where we set
skb->encapsulation independently of setting the inner headers. It
would be nice if setting the flag and setting the inner headers were
somehow unified.

Thanks,
Tom

> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>  net/ipv4/udp_offload.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 0ed2daf..e330c0e 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -399,6 +399,11 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
>
>         uh->len = newlen;
>
> +       /* Set encapsulation before calling into inner gro_complete() functions
> +        * to make them set up the inner offsets.
> +        */
> +       skb->encapsulation = 1;
> +
>         rcu_read_lock();
>
>         uo_priv = rcu_dereference(udp_offload_base);
> @@ -421,9 +426,6 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
>         if (skb->remcsum_offload)
>                 skb_shinfo(skb)->gso_type |= SKB_GSO_TUNNEL_REMCSUM;
>
> -       skb->encapsulation = 1;
> -       skb_set_inner_mac_header(skb, nhoff + sizeof(struct udphdr));
> -
>         return err;
>  }
>
> --
> 2.7.4
>
