From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net] be2net: Allow GRE to work concurrently while a
 VxLAN tunnel is configured
Date: Wed, 14 Jan 2015 18:29:30 -0800
Message-ID: <CA+mtBx9Kd8JM53RJFJ_R-ZW_FN=UhDQgBNgLNPqadGA9o3ZNiA@mail.gmail.com>
References: <1421318323-2547-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:52948 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbbAOC3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 21:29:30 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so12561174iec.1
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 18:29:30 -0800 (PST)
In-Reply-To: <1421318323-2547-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2015 at 2:38 AM, Sriharsha Basavapatna
<sriharsha.basavapatna@emulex.com> wrote:
> Other tunnels like GRE break while VxLAN offloads are enabled in Skyhawk-R. To
> avoid this, we should restrict offload features on a per-packet basis in such
> conditions.
>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
> ---
> v2 changes: fixed minor nits pointed out by Sergei Shtylyov
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c |   41 +++++++++++++++++++++++++--
>  1 file changed, 38 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index 41a0a54..d48806b 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -4383,8 +4383,9 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>   * distinguish various types of transports (VxLAN, GRE, NVGRE ..). So, offload
>   * is expected to work across all types of IP tunnels once exported. Skyhawk
>   * supports offloads for either VxLAN or NVGRE, exclusively. So we export VxLAN
> - * offloads in hw_enc_features only when a VxLAN port is added. Note this only
> - * ensures that other tunnels work fine while VxLAN offloads are not enabled.
> + * offloads in hw_enc_features only when a VxLAN port is added. If other (non
> + * VxLAN) tunnels are configured while VxLAN offloads are enabled, offloads for
> + * those other tunnels are unexported on the fly through ndo_features_check().
>   *
>   * Skyhawk supports VxLAN offloads only for one UDP dport. So, if the stack
>   * adds more than one port, disable offloads and don't re-enable them again
> @@ -4463,7 +4464,41 @@ static netdev_features_t be_features_check(struct sk_buff *skb,
>                                            struct net_device *dev,
>                                            netdev_features_t features)
>  {
> -       return vxlan_features_check(skb, features);
> +       struct be_adapter *adapter = netdev_priv(dev);
> +       u8 l4_hdr = 0;
> +
> +       /* The code below restricts offload features for some tunneled packets.
> +        * Offload features for normal (non tunnel) packets are unchanged.
> +        */
> +       if (!skb->encapsulation ||
> +           !(adapter->flags & BE_FLAGS_VXLAN_OFFLOADS))
> +               return features;
> +
> +       /* It's an encapsulated packet and VxLAN offloads are enabled. We
> +        * should disable tunnel offload features if it's not a VxLAN packet,
> +        * as tunnel offloads have been enabled only for VxLAN. This is done to
> +        * allow other tunneled traffic like GRE work fine while VxLAN
> +        * offloads are configured in Skyhawk-R.
> +        */
> +       switch (vlan_get_protocol(skb)) {
> +       case htons(ETH_P_IP):
> +               l4_hdr = ip_hdr(skb)->protocol;
> +               break;
> +       case htons(ETH_P_IPV6):
> +               l4_hdr = ipv6_hdr(skb)->nexthdr;
> +               break;
> +       default:
> +               return features;
> +       }
> +
> +       if (l4_hdr != IPPROTO_UDP ||

I don't understand why this is needed. The only GSO type with with
encapsulation allowed by device features SKB_GSO_UDP_TUNNEL. This
should not be GRE for instance. Do you see cases where protocol is not
UDP at this point?

> +           skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
> +           skb->inner_protocol != htons(ETH_P_TEB) ||
> +           skb_inner_mac_header(skb) - skb_transport_header(skb) !=
> +           sizeof(struct udphdr) + sizeof(struct vxlanhdr))
> +               return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
> +
> +       return features;
>  }
>  #endif
>
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
