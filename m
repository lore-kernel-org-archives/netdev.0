From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net: use skb_postpush_rcsum instead of own implementations
Date: Fri, 19 Feb 2016 15:59:33 -0800
Message-ID: <CALx6S348dwJosPGcDNPKAdWcOM7DoQZUFAnWakd0-iqLNZWO4g@mail.gmail.com>
References: <bb805bd677f8ba6f5c40b485ed41009d3fef1f3d.1455924108.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jesse Gross <jesse@kernel.org>, ast@kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36230 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1427800AbcBSX7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 18:59:34 -0500
Received: by mail-io0-f179.google.com with SMTP id l127so125783840iof.3
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 15:59:33 -0800 (PST)
In-Reply-To: <bb805bd677f8ba6f5c40b485ed41009d3fef1f3d.1455924108.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 3:29 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Replace individual implementations with the recently introduced
> skb_postpush_rcsum() helper.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Tom Herbert <tom@herbertland.com>

Looks like some nice cleanup!

> ---
>  net/core/skbuff.c              | 4 +---
>  net/ipv6/reassembly.c          | 6 ++----
>  net/openvswitch/actions.c      | 8 +++-----
>  net/openvswitch/vport-netdev.c | 2 +-
>  net/openvswitch/vport.h        | 7 -------
>  5 files changed, 7 insertions(+), 20 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index a5bd067..8bd4b79 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4496,9 +4496,7 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
>                 skb->mac_len += VLAN_HLEN;
>                 __skb_pull(skb, offset);
>
> -               if (skb->ip_summed == CHECKSUM_COMPLETE)
> -                       skb->csum = csum_add(skb->csum, csum_partial(skb->data
> -                                       + (2 * ETH_ALEN), VLAN_HLEN, 0));
> +               skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
>         }
>         __vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
>         return 0;
> diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
> index 18f3498..e2ea311 100644
> --- a/net/ipv6/reassembly.c
> +++ b/net/ipv6/reassembly.c
> @@ -496,10 +496,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
>         IP6CB(head)->flags |= IP6SKB_FRAGMENTED;
>
>         /* Yes, and fold redundant checksum back. 8) */
> -       if (head->ip_summed == CHECKSUM_COMPLETE)
> -               head->csum = csum_partial(skb_network_header(head),
> -                                         skb_network_header_len(head),
> -                                         head->csum);
> +       skb_postpush_rcsum(head, skb_network_header(head),
> +                          skb_network_header_len(head));
>
>         rcu_read_lock();
>         IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 2d59df5..e9dd47b 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -158,9 +158,7 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>         new_mpls_lse = (__be32 *)skb_mpls_header(skb);
>         *new_mpls_lse = mpls->mpls_lse;
>
> -       if (skb->ip_summed == CHECKSUM_COMPLETE)
> -               skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
> -                                                            MPLS_HLEN, 0));
> +       skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
>
>         hdr = eth_hdr(skb);
>         hdr->h_proto = mpls->mpls_ethertype;
> @@ -280,7 +278,7 @@ static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *flow_key,
>         ether_addr_copy_masked(eth_hdr(skb)->h_dest, key->eth_dst,
>                                mask->eth_dst);
>
> -       ovs_skb_postpush_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
> +       skb_postpush_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
>
>         ether_addr_copy(flow_key->eth.src, eth_hdr(skb)->h_source);
>         ether_addr_copy(flow_key->eth.dst, eth_hdr(skb)->h_dest);
> @@ -639,7 +637,7 @@ static int ovs_vport_output(struct net *net, struct sock *sk, struct sk_buff *sk
>         /* Reconstruct the MAC header.  */
>         skb_push(skb, data->l2_len);
>         memcpy(skb->data, &data->l2_data, data->l2_len);
> -       ovs_skb_postpush_rcsum(skb, skb->data, data->l2_len);
> +       skb_postpush_rcsum(skb, skb->data, data->l2_len);
>         skb_reset_mac_header(skb);
>
>         ovs_vport_send(vport, skb);
> diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
> index 6a6adf3..4e39723 100644
> --- a/net/openvswitch/vport-netdev.c
> +++ b/net/openvswitch/vport-netdev.c
> @@ -58,7 +58,7 @@ static void netdev_port_receive(struct sk_buff *skb)
>                 return;
>
>         skb_push(skb, ETH_HLEN);
> -       ovs_skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
> +       skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
>         ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
>         return;
>  error:
> diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
> index c10899cb..f01f28a 100644
> --- a/net/openvswitch/vport.h
> +++ b/net/openvswitch/vport.h
> @@ -185,13 +185,6 @@ static inline struct vport *vport_from_priv(void *priv)
>  int ovs_vport_receive(struct vport *, struct sk_buff *,
>                       const struct ip_tunnel_info *);
>
> -static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
> -                                     const void *start, unsigned int len)
> -{
> -       if (skb->ip_summed == CHECKSUM_COMPLETE)
> -               skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));
> -}
> -
>  static inline const char *ovs_vport_name(struct vport *vport)
>  {
>         return vport->dev->name;
> --
> 1.9.3
>
