From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v12 7/9] openvswitch: add Ethernet push and pop actions
Date: Thu, 20 Oct 2016 21:22:21 -0700
Message-ID: <CAOrHB_Bj+0DNePDKQ64Gtx9SyxS4cy20Y-1RLC4Dpd3DKJpsjA@mail.gmail.com>
References: <cover.1476708212.git.jbenc@redhat.com> <bf8e49c178a2f8ed9adb02e30470be5163d46296.1476708213.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:50657 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbcJUEW0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 00:22:26 -0400
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 2DCD6172094
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:22:25 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id IjR-Usw2-2_v for <netdev@vger.kernel.org>;
        Fri, 21 Oct 2016 06:22:23 +0200 (CEST)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 7BA3D17209B
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:22:23 +0200 (CEST)
Received: by mail-it0-f43.google.com with SMTP id 66so134363750itl.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 21:22:23 -0700 (PDT)
In-Reply-To: <bf8e49c178a2f8ed9adb02e30470be5163d46296.1476708213.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 6:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> It's not allowed to push Ethernet header in front of another Ethernet
> header.
>
> It's not allowed to pop Ethernet header if there's a vlan tag. This
> preserves the invariant that L3 packet never has a vlan tag.
>
> Based on previous versions by Lorand Jakab and Simon Horman.
>
> Signed-off-by: Lorand Jakab <lojakab@cisco.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  include/uapi/linux/openvswitch.h | 15 ++++++++++++
>  net/openvswitch/actions.c        | 49 ++++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/flow_netlink.c   | 18 +++++++++++++++
>  3 files changed, 82 insertions(+)
>
...
...
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 064cbcb7b0c5..a63572fb878e 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -317,6 +317,47 @@ static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *flow_key,
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
> +       /* safe right before invalidate_flow_key */
> +       key->mac_proto = MAC_PROTO_NONE;
> +       invalidate_flow_key(key);
> +       return 0;
> +}
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
> +       skb->mac_len = ETH_HLEN;
> +

The eth pop substracts ETH_HLEN but here the length is set. I think it
should be consistent with respect to eth-pop.
