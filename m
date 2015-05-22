From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v4 net-next 05/11] net: Add full IPv6 addresses to flow_keys
Date: Thu, 21 May 2015 21:16:58 -0700
Message-ID: <CAHA+R7PWHdAa9Tc5zHkx7k8+7NH_M5_9OF8vO3aOVQRw0NkyAw@mail.gmail.com>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
	<1432253506-3646977-6-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38276 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbbEVERA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 00:17:00 -0400
Received: by wichy4 with SMTP id hy4so34267875wic.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 21:16:59 -0700 (PDT)
In-Reply-To: <1432253506-3646977-6-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 5:11 PM, Tom Herbert <tom@herbertland.com> wrote:
>  static inline void ip6_set_txhash(struct sock *sk)
>  {
> @@ -700,8 +714,11 @@ static inline void ip6_set_txhash(struct sock *sk)
>
>         memset(&keys, 0, sizeof(keys));
>
> -       keys.addrs.src = (__force __be32)ipv6_addr_hash(&np->saddr);
> -       keys.addrs.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
> +       memcpy(&keys.addrs.v6addrs.src, &np->saddr,
> +              sizeof(keys.addrs.v6addrs.src));
> +       memcpy(&keys.addrs.v6addrs.dst, &sk->sk_v6_daddr,
> +              sizeof(keys.addrs.v6addrs.dst));
> +       keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
>         keys.ports.src = inet->inet_sport;
>         keys.ports.dst = inet->inet_dport;
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 017fb84..d77619f 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -178,10 +178,12 @@ ip:
>                 if (!skb_flow_dissector_uses_key(flow_dissector,
>                                                  FLOW_DISSECTOR_KEY_IPV4_ADDRS))
>                         break;
> +
>                 key_addrs = skb_flow_dissector_target(flow_dissector,
> -                                                     FLOW_DISSECTOR_KEY_IPV4_ADDRS,
> -                                                     target_container);
> -               memcpy(key_addrs, &iph->saddr, sizeof(*key_addrs));
> +                             FLOW_DISSECTOR_KEY_IPV4_ADDRS, target_container);
> +               memcpy(&key_addrs->v4addrs, &iph->saddr,
> +                      sizeof(key_addrs->v4addrs));
> +               key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
>                 break;
>         }
>         case htons(ETH_P_IPV6): {
> @@ -203,8 +205,11 @@ ipv6:
>                                                               FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
>                                                               target_container);
>
> -                       key_addrs->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
> -                       key_addrs->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
> +                       key_addrs->v4addrs.src =
> +                               (__force __be32)ipv6_addr_hash(&iph->saddr);
> +                       key_addrs->v4addrs.dst =
> +                               (__force __be32)ipv6_addr_hash(&iph->daddr);
> +                       key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;


Comparing with the change in ip6_set_txhash(), this one reads odd, not sure
if you do this intentionally?
