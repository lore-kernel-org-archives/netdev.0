From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 3/3] net: GSO encapsulation for IP packets
Date: Tue, 11 Feb 2014 11:12:20 -0800
Message-ID: <CAADnVQ+PcO9-BGVE+ExFZt_sxhN1gDtiXtxMHPfHEX7wB3cWWg@mail.gmail.com>
References: <alpine.DEB.2.02.1402110928030.7010@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	ogerlitz@mellanox.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:55929 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbaBKTMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 14:12:21 -0500
Received: by mail-qc0-f175.google.com with SMTP id x13so13505731qcv.6
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 11:12:21 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1402110928030.7010@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 11, 2014 at 9:43 AM, Tom Herbert <therbert@google.com> wrote:
> The UDP GSO code assume that only encapsulated packets are Ethernet
> frames. This patch fixes that so that we can support IP protocol
> encpasulation (GUE, GRE/UDP, etc.)
>
> We overload the inner_protocol field in the skb to store either the
> Ethertype or the IP protocol (latter is indicated by ip_encapsulation
> bit). As far as I can tell this should not adversely affect preexiting
> uses for inner_protocol.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/skbuff.h |  8 ++++++--
>  net/core/skbuff.c      |  1 +
>  net/ipv4/udp.c         | 12 +++++++++++-
>  3 files changed, 18 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 1f689e6..757ed39 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -512,7 +512,11 @@ struct sk_buff {
>          * headers if needed
>          */
>         __u8                    encapsulation:1;
> -       /* 6/8 bit hole (depending on ndisc_nodetype presence) */
> +       /* skbuf encpasulates an IP packet, inner_protocol should be
> +        * interpreted as an IP protocol, encapsulation bit is also set
> +        */
> +       __u8                    ip_encapsulation:1;
> +       /* 5/7 bit hole (depending on ndisc_nodetype presence) */
>         kmemcheck_bitfield_end(flags2);
>
>  #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
> @@ -530,7 +534,7 @@ struct sk_buff {
>                 __u32           reserved_tailroom;
>         };
>
> -       __be16                  inner_protocol;
> +       __u16                   inner_protocol;
>         __u16                   inner_transport_header;
>         __u16                   inner_network_header;
>         __u16                   inner_mac_header;
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 8f519db..64c6190 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -687,6 +687,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>         new->ooo_okay           = old->ooo_okay;
>         new->no_fcs             = old->no_fcs;
>         new->encapsulation      = old->encapsulation;
> +       new->ip_encapsulation   = old->ip_encapsulation;
>  #ifdef CONFIG_XFRM
>         new->sp                 = secpath_get(old->sp);
>  #endif
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 77bd16f..48d8cb2 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2497,7 +2497,17 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
>
>         /* segment inner packet. */
>         enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
> -       segs = skb_mac_gso_segment(skb, enc_features);
> +
> +       if (skb->ip_encapsulation) {
> +               const struct net_offload *ops;
> +               ops = rcu_dereference(inet_offloads[skb->inner_protocol]);
> +               if (likely(ops && ops->callbacks.gso_segment))
> +                       segs = ops->callbacks.gso_segment(skb, enc_features);
> +       } else {
> +               skb->protocol = htons(ETH_P_TEB);

duplicate assignment ? Do you want to remove line 2496 which did the same
or proto=teb applies to ip_encap case as well?

> +               segs = skb_mac_gso_segment(skb, enc_features);
> +       }
> +
>         if (!segs || IS_ERR(segs)) {
>                 skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
>                                      mac_len);
> --
> 1.9.0.rc1.175.g0b1dcb5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
