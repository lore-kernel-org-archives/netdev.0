From: Tom Herbert <tom@herbertland.com>
Subject: Re: [patch net-next v4 RFC 12/15] flow_dissector: introduce support
 for ipv6 addressses
Date: Fri, 24 Apr 2015 10:28:05 -0700
Message-ID: <CALx6S37xpnWTOQw3vivY5Ugn0BTkvxhNMhWnYABHD88cuZJ7Eg@mail.gmail.com>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
	<1429890701-30052-13-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Thomas Graf <tgraf@suug.ch>, jesse@nicira.com, kaber@trash.net,
	Tom Herbert <therbert@google.com>, edumazet@google.com,
	alexander.h.duyck@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35954 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030585AbbDXR2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:28:05 -0400
Received: by igblo3 with SMTP id lo3so20246371igb.1
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 10:28:05 -0700 (PDT)
In-Reply-To: <1429890701-30052-13-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

Thanks for this work, I think it's a good direction! Some comments below...

On Fri, Apr 24, 2015 at 8:51 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> So far, only hashes made out of ipv6 addresses could be dissected. This
> patch introduces support for dissection of full ipv6 addresses.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/net/flow_dissector.h | 13 +++++++++++++
>  net/core/flow_dissector.c    | 29 +++++++++++++++++++++--------
>  2 files changed, 34 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
> index b67ce84..7c9e84c 100644
> --- a/include/net/flow_dissector.h
> +++ b/include/net/flow_dissector.h
> @@ -3,6 +3,7 @@
>
>  #include <linux/types.h>
>  #include <linux/skbuff.h>
> +#include <linux/in6.h>
>
>  /**
>   * struct flow_dissector_key_basic:
> @@ -42,11 +43,23 @@ struct flow_dissector_key_ports {
>         };
>  };
>
> +/**
> + * struct flow_dissector_key_ipv6_addrs:
> + * @src: source ip address
> + * @dst: destination ip address
> + */
> +struct flow_dissector_key_ipv6_addrs {
> +       /* (src,dst) must be grouped, in the same way than in IP header */
> +       struct in6_addr src;
> +       struct in6_addr dst;
> +};
> +
>  enum flow_dissector_key_id {
>         FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
>         FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_addrs */
>         FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
>         FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
> +       FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
>
And we'll want to add VLAN ID, (GRE) key-id, IPv6 flow label, maybe a
couple more.

>         FLOW_DISSECTOR_KEY_MAX,
>  };
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 564288e..95e9a21 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -175,16 +175,29 @@ ipv6:
>                 ip_proto = iph->nexthdr;
>                 nhoff += sizeof(struct ipv6hdr);
>
> -               if (!skb_flow_dissector_uses_key(flow_dissector,
> -                                                FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS))
> -                       break;
> -               key_addrs = skb_flow_dissector_target(flow_dissector,
> -                                                     FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
> -                                                     target_container);
> +               if (skb_flow_dissector_uses_key(flow_dissector,
> +                                               FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
> +                       key_addrs = skb_flow_dissector_target(flow_dissector,
> +                                                             FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
> +                                                             target_container);
>
> -               key_addrs->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
> -               key_addrs->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
> +                       key_addrs->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
> +                       key_addrs->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
> +                       goto flow_label;
> +               }

So this is still folding the IPv6 addresses so that that we can fit
into jhash_3words? Can we address this now and include the full IPv6
address in the hash? I would propose that we extend the flow_keys
structure (which I think you may already be doing) for full IPv6
address, VLAN, flow label, etc., and then produce a hash across that
whole structure. jhash2 can be used on a structure.  jhash is actually
a very efficient hash performance wise-- the rest of flow dissection
is likely the dominant cost anyway. We should also minimize calls to
flow_dissector, I would propose it should be called at most once per
packet-- I'll be reposting patches to fix that in the various qdiscs.

> +               if (skb_flow_dissector_uses_key(flow_dissector,
> +                                               FLOW_DISSECTOR_KEY_IPV6_ADDRS)) {
> +                       struct flow_dissector_key_ipv6_addrs *key_ipv6_addrs;
>
> +                       key_ipv6_addrs = skb_flow_dissector_target(flow_dissector,
> +                                                                  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
> +                                                                  target_container);
> +
> +                       memcpy(key_ipv6_addrs, &iph->saddr, sizeof(*key_ipv6_addrs));
> +                       goto flow_label;
> +               }
> +               break;
> +flow_label:
>                 flow_label = ip6_flowlabel(iph);
>                 if (flow_label) {
>                         /* Awesome, IPv6 packet has a flow label so we can
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
