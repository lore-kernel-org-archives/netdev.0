From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] packet: Use symmetric hash for PACKET_FANOUT_HASH.
Date: Fri, 1 Jul 2016 13:52:58 -0700
Message-ID: <CALx6S34B33PUMfk4R662_WEjiafjheNbH=wH9r=QhYTK14nmqw@mail.gmail.com>
References: <20160701.160854.278188334806254498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	eric@regit.org, victor@inliniac.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36640 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcGAUxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 16:53:16 -0400
Received: by mail-it0-f66.google.com with SMTP id h190so3414222ith.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 13:52:59 -0700 (PDT)
In-Reply-To: <20160701.160854.278188334806254498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 1, 2016 at 1:08 PM, David Miller <davem@davemloft.net> wrote:
>
> People who use PACKET_FANOUT_HASH want a symmetric hash, meaning that
> they want packets going in both directions on a flow to hash to the
> same bucket.
>
> The core kernel SKB hash became non-symmetric when the ipv6 flow label
> and other entities were incorporated into the standard flow hash order
> to increase entropy.
>
> But there are no users of PACKET_FANOUT_HASH who want an assymetric
> hash, they all want a symmetric one.
>
> Therefore, use the flow dissector to compute a flat symmetric hash
> over only the protocol, addresses and ports.  This hash does not get
> installed into and override the normal skb hash, so this change has
> no effect whatsoever on the rest of the stack.
>
This doesn't work for any of the UDP encapsulations, packets of an
encapsulated flow will still have asymmetric hashes.

Why are symmetric hashes required?

Tom

> Reported-by: Eric Leblond <eric@regit.org>
> Tested-by: Eric Leblond <eric@regit.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> I'll be pushing this to -stable branches as well.
>
>  include/linux/skbuff.h    |  1 +
>  net/core/flow_dissector.c | 43 +++++++++++++++++++++++++++++++++++++++++++
>  net/packet/af_packet.c    |  2 +-
>  3 files changed, 45 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index ee38a41..24859d4 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1062,6 +1062,7 @@ __skb_set_sw_hash(struct sk_buff *skb, __u32 hash, bool is_l4)
>  }
>
>  void __skb_get_hash(struct sk_buff *skb);
> +u32 __skb_get_hash_symmetric(struct sk_buff *skb);
>  u32 skb_get_poff(const struct sk_buff *skb);
>  u32 __skb_get_poff(const struct sk_buff *skb, void *data,
>                    const struct flow_keys *keys, int hlen);
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index a669dea..61ad43f 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -651,6 +651,23 @@ void make_flow_keys_digest(struct flow_keys_digest *digest,
>  }
>  EXPORT_SYMBOL(make_flow_keys_digest);
>
> +static struct flow_dissector flow_keys_dissector_symmetric __read_mostly;
> +
> +u32 __skb_get_hash_symmetric(struct sk_buff *skb)
> +{
> +       struct flow_keys keys;
> +
> +       __flow_hash_secret_init();
> +
> +       memset(&keys, 0, sizeof(keys));
> +       __skb_flow_dissect(skb, &flow_keys_dissector_symmetric, &keys,
> +                          NULL, 0, 0, 0,
> +                          FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL);
> +
> +       return __flow_hash_from_keys(&keys, hashrnd);
> +}
> +EXPORT_SYMBOL_GPL(__skb_get_hash_symmetric);
> +
>  /**
>   * __skb_get_hash: calculate a flow hash
>   * @skb: sk_buff to calculate flow hash from
> @@ -868,6 +885,29 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
>         },
>  };
>
> +static const struct flow_dissector_key flow_keys_dissector_symmetric_keys[] = {
> +       {
> +               .key_id = FLOW_DISSECTOR_KEY_CONTROL,
> +               .offset = offsetof(struct flow_keys, control),
> +       },
> +       {
> +               .key_id = FLOW_DISSECTOR_KEY_BASIC,
> +               .offset = offsetof(struct flow_keys, basic),
> +       },
> +       {
> +               .key_id = FLOW_DISSECTOR_KEY_IPV4_ADDRS,
> +               .offset = offsetof(struct flow_keys, addrs.v4addrs),
> +       },
> +       {
> +               .key_id = FLOW_DISSECTOR_KEY_IPV6_ADDRS,
> +               .offset = offsetof(struct flow_keys, addrs.v6addrs),
> +       },
> +       {
> +               .key_id = FLOW_DISSECTOR_KEY_PORTS,
> +               .offset = offsetof(struct flow_keys, ports),
> +       },
> +};
> +
>  static const struct flow_dissector_key flow_keys_buf_dissector_keys[] = {
>         {
>                 .key_id = FLOW_DISSECTOR_KEY_CONTROL,
> @@ -889,6 +929,9 @@ static int __init init_default_flow_dissectors(void)
>         skb_flow_dissector_init(&flow_keys_dissector,
>                                 flow_keys_dissector_keys,
>                                 ARRAY_SIZE(flow_keys_dissector_keys));
> +       skb_flow_dissector_init(&flow_keys_dissector_symmetric,
> +                               flow_keys_dissector_symmetric_keys,
> +                               ARRAY_SIZE(flow_keys_dissector_symmetric_keys));
>         skb_flow_dissector_init(&flow_keys_buf_dissector,
>                                 flow_keys_buf_dissector_keys,
>                                 ARRAY_SIZE(flow_keys_buf_dissector_keys));
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 9bff6ef..9f0983f 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1341,7 +1341,7 @@ static unsigned int fanout_demux_hash(struct packet_fanout *f,
>                                       struct sk_buff *skb,
>                                       unsigned int num)
>  {
> -       return reciprocal_scale(skb_get_hash(skb), num);
> +       return reciprocal_scale(__skb_get_hash_symmetric(skb), num);
>  }
>
>  static unsigned int fanout_demux_lb(struct packet_fanout *f,
> --
> 2.5.5
>
