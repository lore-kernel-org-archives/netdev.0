From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v2 net-next 2/2] openvswitch: Fix skb->protocol for vlan frames.
Date: Mon, 28 Nov 2016 23:21:16 -0800
Message-ID: <CAOrHB_B15uBYL-nVhsCoRKzZ1Akmn0ZDcee57VUXGAjMNEAAWQ@mail.gmail.com>
References: <1480387276-123557-1-git-send-email-jarno@ovn.org> <1480387276-123557-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:58517 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbcK2HVp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 02:21:45 -0500
Received: from mfilter6-d.gandi.net (mfilter6-d.gandi.net [217.70.178.135])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 42F01C5A4F
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 08:21:43 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter6-d.gandi.net (mfilter6-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 0t7TJgaZzMSS for <netdev@vger.kernel.org>;
        Tue, 29 Nov 2016 08:21:18 +0100 (CET)
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 5B634C5A50
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 08:21:18 +0100 (CET)
Received: by mail-io0-f175.google.com with SMTP id j65so275385113iof.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 23:21:18 -0800 (PST)
In-Reply-To: <1480387276-123557-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 6:41 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> Do not set skb->protocol to be the ethertype of the L3 header, unless
> the packet only has the L3 header.  For a non-hardware offloaded VLAN
> frame skb->protocol needs to be one of the VLAN ethertypes.
>
> Any VLAN offloading is undone on the OVS netlink interface.  Also any
> VLAN tags added by userspace are non-offloaded.
>
> Incorrect skb->protocol value on a full-size non-offloaded VLAN skb
> causes packet drop due to failing MTU check, as the VLAN header should
> not be counted in when considering MTU in ovs_vport_send().
>
I think we should move to is_skb_forwardable() type of packet length
check in vport-send and get rid of skb-protocol checks altogether.

> Fixes: 5108bbaddc ("openvswitch: add processing of L3 packets")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
> v2: Set skb->protocol when an ETH_P_TEB frame is received via ARPHRD_NONE
>     interface.
>
>  net/openvswitch/datapath.c |  1 -
>  net/openvswitch/flow.c     | 30 ++++++++++++++++++++++--------
>  2 files changed, 22 insertions(+), 9 deletions(-)
...
...
> @@ -531,15 +538,22 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>                 if (unlikely(parse_vlan(skb, key)))
>                         return -ENOMEM;
>
> -               skb->protocol = parse_ethertype(skb);
> -               if (unlikely(skb->protocol == htons(0)))
> +               key->eth.type = parse_ethertype(skb);
> +               if (unlikely(key->eth.type == htons(0)))
>                         return -ENOMEM;
>
> +               if (skb->protocol == htons(ETH_P_TEB)) {
> +                       if (key->eth.vlan.tci & htons(VLAN_TAG_PRESENT)
> +                           && !skb_vlan_tag_present(skb))
> +                               skb->protocol = key->eth.vlan.tpid;
> +                       else
> +                               skb->protocol = key->eth.type;
> +               }
> +

I am not sure if this work in case of nested vlans.
Can we move skb-protocol assignment to parse_vlan() to avoid checking
for non-accelerated vlan case again here?
