From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v12 5/9] openvswitch: add processing of L3 packets
Date: Tue, 18 Oct 2016 22:13:45 -0700
Message-ID: <CAOrHB_B1-29CM=DWpWuRVbTRriW2ViJRZULMS22+NSPwW_J_=Q@mail.gmail.com>
References: <cover.1476708212.git.jbenc@redhat.com> <a4590d690c169e0021031405463c8629a6e9ecb8.1476708213.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:37633 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbcJSFNu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 01:13:50 -0400
Received: from mfilter41-d.gandi.net (mfilter41-d.gandi.net [217.70.178.173])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 39278C5A5F
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:13:49 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter41-d.gandi.net (mfilter41-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id N4PZcSHuCRWw for <netdev@vger.kernel.org>;
        Wed, 19 Oct 2016 07:13:47 +0200 (CEST)
Received: from mail-it0-f44.google.com (mail-it0-f44.google.com [209.85.214.44])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 80F65C5A4F
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:13:47 +0200 (CEST)
Received: by mail-it0-f44.google.com with SMTP id m138so18430774itm.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 22:13:47 -0700 (PDT)
In-Reply-To: <a4590d690c169e0021031405463c8629a6e9ecb8.1476708213.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 6:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Support receiving, extracting flow key and sending of L3 packets (packets
> without an Ethernet header).
>
> Note that even after this patch, non-Ethernet interfaces are still not
> allowed to be added to bridges. Similarly, netlink interface for sending and
> receiving L3 packets to/from user space is not in place yet.
>
> Based on previous versions by Lorand Jakab and Simon Horman.
>
> Signed-off-by: Lorand Jakab <lojakab@cisco.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  net/openvswitch/datapath.c |  17 ++------
>  net/openvswitch/flow.c     | 101 ++++++++++++++++++++++++++++++++++-----------
>  net/openvswitch/vport.c    |  16 +++++++
>  3 files changed, 96 insertions(+), 38 deletions(-)
>
...

> @@ -505,28 +511,35 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>
>         skb_reset_mac_header(skb);
>
> -       /* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
> -        * header in the linear data area.
> -        */
> -       eth = eth_hdr(skb);
> -       ether_addr_copy(key->eth.src, eth->h_source);
> -       ether_addr_copy(key->eth.dst, eth->h_dest);
> +       /* Link layer. */
> +       clear_vlan(key);
> +       if (key->mac_proto == MAC_PROTO_NONE) {
> +               if (unlikely(eth_type_vlan(skb->protocol)))
> +                       return -EINVAL;
>
> -       __skb_pull(skb, 2 * ETH_ALEN);
> -       /* We are going to push all headers that we pull, so no need to
> -        * update skb->csum here.
> -        */
> +               skb_reset_network_header(skb);
> +       } else {
> +               eth = eth_hdr(skb);
> +               ether_addr_copy(key->eth.src, eth->h_source);
> +               ether_addr_copy(key->eth.dst, eth->h_dest);
>
> -       if (unlikely(parse_vlan(skb, key)))
> -               return -ENOMEM;
> +               __skb_pull(skb, 2 * ETH_ALEN);
> +               /* We are going to push all headers that we pull, so no need to
> +               * update skb->csum here.
> +               */
>
> -       key->eth.type = parse_ethertype(skb);
> -       if (unlikely(key->eth.type == htons(0)))
> -               return -ENOMEM;
> +               if (unlikely(parse_vlan(skb, key)))
> +                       return -ENOMEM;
>
> -       skb_reset_network_header(skb);
> +               skb->protocol = parse_ethertype(skb);

I am not sure about changing skb->protocol here.
By changing this skb loosing information about packet type. Therefore
if packet re-enters OVS (through different bridge), this packet would
look like L3 packet. function key_extract_mac_proto() would not see
TEB type packet.

> +               if (unlikely(skb->protocol == htons(0)))
> +                       return -ENOMEM;
> +
> +               skb_reset_network_header(skb);
> +               __skb_push(skb, skb->data - skb_mac_header(skb));
> +       }
>         skb_reset_mac_len(skb);
> -       __skb_push(skb, skb->data - skb_mac_header(skb));
> +       key->eth.type = skb->protocol;
>
>         /* Network layer. */
>         if (key->eth.type == htons(ETH_P_IP)) {
> @@ -721,6 +734,20 @@ int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
>         return key_extract(skb, key);
>  }
>
> +static u8 key_extract_mac_proto(struct sk_buff *skb)
> +{
> +       switch (skb->dev->type) {
> +       case ARPHRD_ETHER:
> +               return MAC_PROTO_ETHERNET;
> +       case ARPHRD_NONE:
> +               if (skb->protocol == htons(ETH_P_TEB))
> +                       return MAC_PROTO_ETHERNET;
> +               return MAC_PROTO_NONE;
> +       }
> +       WARN_ON_ONCE(1);
> +       return MAC_PROTO_ETHERNET;
> +}
> +
