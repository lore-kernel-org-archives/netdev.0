From: pravin shelar <pshelar@ovn.org>
Subject: Re: [ovs-dev] [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Thu, 7 Jul 2016 13:54:15 -0700
Message-ID: <CAOrHB_BYD40ZkWbU0dvhPOCcaCVgooksOUkejxyFoagyoiBTNw@mail.gmail.com>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com> <1467827996-32547-6-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:48407 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbcGGUyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 16:54:22 -0400
Received: from mfilter23-d.gandi.net (mfilter23-d.gandi.net [217.70.178.151])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id CBD4EC5A53
	for <netdev@vger.kernel.org>; Thu,  7 Jul 2016 22:54:19 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter23-d.gandi.net (mfilter23-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id ep8ssffnLxWk for <netdev@vger.kernel.org>;
	Thu,  7 Jul 2016 22:54:17 +0200 (CEST)
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id D3AD4C5A5D
	for <netdev@vger.kernel.org>; Thu,  7 Jul 2016 22:54:17 +0200 (CEST)
Received: by mail-io0-f174.google.com with SMTP id t74so32771261ioi.0
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 13:54:17 -0700 (PDT)
In-Reply-To: <1467827996-32547-6-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 10:59 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> From: Lorand Jakab <lojakab@cisco.com>
>
> Implementation of the pop_eth and push_eth actions in the kernel, and
> layer 3 flow support.
>
> This doesn't actually do anything yet as no layer 2 tunnel ports are
> supported yet. The original patch by Lorand was against the Open vSwitch
> tree which has L2 LISP tunnels but that is not supported in mainline Linux.
> I (Simon) plan to follow up with support for non-TEB GRE ports based on
> work by Thomas Morin.
>
> Cc: Thomas Morin <thomas.morin@orange.com>
> Signed-off-by: Lorand Jakab <lojakab@cisco.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>
> ---
....
> ---
>  include/uapi/linux/openvswitch.h     |  11 ++
>  net/openvswitch/actions.c            |  45 ++++++++
>  net/openvswitch/datapath.c           |  13 +--
>  net/openvswitch/flow.c               |  65 +++++++----
>  net/openvswitch/flow.h               |   4 +-
>  net/openvswitch/flow_netlink.c       | 213 ++++++++++++++++++++++++-----------
>  net/openvswitch/vport-geneve.c       |   2 +-
>  net/openvswitch/vport-gre.c          |   2 +-
>  net/openvswitch/vport-internal_dev.c |   6 +
>  net/openvswitch/vport-netdev.c       |  19 +++-
>  net/openvswitch/vport-netdev.h       |   2 +
>  net/openvswitch/vport-vxlan.c        |   2 +-
>  12 files changed, 279 insertions(+), 105 deletions(-)
>
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index 5cde501433eb..6f505e486e93 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
...

> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 12e8a8942a42..0001f651c934 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -301,6 +301,43 @@ static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *flow_key,
>         return 0;
>  }
>
> +/* pop_eth does not support VLAN packets as this action is never called
> + * for them.
> + */
> +static int pop_eth(struct sk_buff *skb, struct sw_flow_key *key)
> +{
> +       skb_pull_rcsum(skb, ETH_HLEN);
> +       skb_reset_mac_header(skb);
> +       skb->mac_len -= ETH_HLEN;
> +
> +       invalidate_flow_key(key);
> +       return 0;
> +}
This is changing l2 packet to l3 packet by reseting mac header. We
need to unset mac header so that OVS key-extract can identify this
packet later on, for example after recirc action.
Other option would be keeping key is_layer3 consistent with packet.
Push ethernet and pop ethernet action can unset and set the flag in
flow key. So that OVS can keep track of packet headers by looking at
packet key. When packet leaves OVS (in netdev-send) we can unset mac
header according to this flag.

> +
> +static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
> +                   const struct ovs_action_push_eth *ethh)
> +{
> +       struct ethhdr *hdr;
> +
> +       /* Add the new Ethernet header */
> +       if (skb_cow_head(skb, ETH_HLEN) < 0)
> +               return -ENOMEM;
> +
> +       skb_push(skb, ETH_HLEN);
> +       skb_reset_mac_header(skb);
> +       skb->mac_len += ETH_HLEN;
> +
> +       hdr = eth_hdr(skb);
> +       ether_addr_copy(hdr->h_source, ethh->addresses.eth_src);
> +       ether_addr_copy(hdr->h_dest, ethh->addresses.eth_dst);
> +       hdr->h_proto = skb->protocol;
> +
> +       skb_postpush_rcsum(skb, hdr, ETH_HLEN);
> +
> +       invalidate_flow_key(key);
> +       return 0;
> +}
> +
....

> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 0ea128eeeab2..86f2cfb19de3 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
...

> @@ -723,9 +729,17 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
>         key->phy.skb_mark = skb->mark;
>         ovs_ct_fill_key(skb, key);
>         key->ovs_flow_hash = 0;
> +       key->phy.is_layer3 = skb->mac_len == 0;

I do not think mac_len can be used. mac_header needs to be checked.
...

> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index c78a6a1476fb..fc94fbe1ddc3 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
...

> @@ -898,20 +922,33 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
>                                    sizeof(*cl), is_mask);
>                 *attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABELS);
>         }
> -       return 0;
> -}
>
> -static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
> -                               u64 attrs, const struct nlattr **a,
> -                               bool is_mask, bool log)
> -{
> -       int err;
> +       /* For layer 3 packets the ethernet type is provided
> +        * and treated as metadata but no MAC addresses are provided.
> +        */
> +       if (*attrs & (1ULL << OVS_KEY_ATTR_ETHERTYPE) &&
> +           !(*attrs & (1 << OVS_KEY_ATTR_ETHERNET))) {
> +               int err;
>
Here attr_ethertype can be processed irrespective of attr_ethernet.
is_layer3 can be derived independently. This way there is no need to
again process attr_ethertyp in l2_from_nlattrs().

> -       err = metadata_from_nlattrs(net, match, &attrs, a, is_mask, log);
> -       if (err)
> -               return err;
> +               err = ethertype_from_nlattrs(net, match, attrs, a, is_mask,
> +                                            log);
> +               if (err)
> +                       return err;
> +
> +               is_layer3 = true;
> +       }
>
> -       if (attrs & (1 << OVS_KEY_ATTR_ETHERNET)) {
> +       /* Always exact match is_layer3 */
> +       SW_FLOW_KEY_PUT(match, phy.is_layer3, is_mask ? true : is_layer3,
> +                       is_mask);
> +       return is_layer3;
> +}
> +
....
> +       if (*attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
> +               int err;
>
> -               SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
> -               attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
> +               err = ethertype_from_nlattrs(net, match, attrs, a, is_mask,
> +                                            log);
> +               if (err)
> +                       return err;
>         } else if (!is_mask) {
>                 SW_FLOW_KEY_PUT(match, eth.type, htons(ETH_P_802_2), is_mask);
>         }
>
> +       return 0;
> +}
> +
> +static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
> +                               u64 attrs, const struct nlattr **a,
> +                               bool is_mask, bool log)
> +{
> +       int err;
> +       bool is_layer3;
> +
> +       err = metadata_from_nlattrs(net, match, &attrs, a, is_mask, log);
> +       if (err < 0)
> +               return err;
> +       is_layer3 = err != 0;
> +
> +       if (!is_layer3) {
> +               err = l2_from_nlattrs(net, match, &attrs, a, is_mask, log);
> +               if (err < 0)
> +                       return err;
> +       }
> +
...


> diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
> index 32d8e94d9bff..adc364161626 100644
> --- a/net/openvswitch/vport-internal_dev.c
> +++ b/net/openvswitch/vport-internal_dev.c
> @@ -257,6 +257,12 @@ static netdev_tx_t internal_dev_recv(struct sk_buff *skb)
>         struct net_device *netdev = skb->dev;
>         struct pcpu_sw_netstats *stats;
>
> +       /* Only send/receive L2 packets */
> +       if (!skb->mac_len) {
> +               kfree_skb(skb);
> +               return -EINVAL;
> +       }
> +
Is mac_len consistent? I thought we decided to use
skb_mac_header_was_set() to detect l3 packets.

>         if (unlikely(!(netdev->flags & IFF_UP))) {
>                 kfree_skb(skb);
>                 netdev->stats.rx_dropped++;
> diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
> index 4e3972344aa6..733e7914f6bd 100644
> --- a/net/openvswitch/vport-netdev.c
> +++ b/net/openvswitch/vport-netdev.c
> @@ -57,8 +57,10 @@ static void netdev_port_receive(struct sk_buff *skb)
>         if (unlikely(!skb))
>                 return;
>
> -       skb_push(skb, ETH_HLEN);
> -       skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
> +       if (vport->dev->type == ARPHRD_ETHER) {
> +               skb_push(skb, ETH_HLEN);
> +               skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
> +       }
This is still required for tunnel device of ARPHRD_NONE which can
handle l2 packets.

>         ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
>         return;
>  error:
> @@ -194,6 +196,17 @@ void ovs_netdev_tunnel_destroy(struct vport *vport)
>  }
>  EXPORT_SYMBOL_GPL(ovs_netdev_tunnel_destroy);
>
> +int ovs_netdev_send(struct sk_buff *skb)
> +{
> +       /* Only send L2 packets */
> +       if (skb->mac_len)
> +               return dev_queue_xmit(skb);
> +
As commented in earlier, we can send is_layer3 flag from flow key. If
it is l3 packet then unset mac header before sending it out to keep
the packet metadata consistent.
