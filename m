From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 3/3] openvswitch: Fix skb->protocol for vlan frames.
Date: Tue, 29 Nov 2016 23:34:29 -0800
Message-ID: <CAOrHB_C3yZSYfZ=k1E0-4X5mkbEYpWMCEBVwL1a3jfVTAiM4vQ@mail.gmail.com>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org> <1480462253-114713-3-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>, Eric Garver <e@erig.me>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:57448 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755970AbcK3Hef (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 02:34:35 -0500
Received: from mfilter28-d.gandi.net (mfilter28-d.gandi.net [217.70.178.159])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 0A494C5A78
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 08:34:33 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter28-d.gandi.net (mfilter28-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id jJ3fyXN6ZCoC for <netdev@vger.kernel.org>;
        Wed, 30 Nov 2016 08:34:31 +0100 (CET)
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 91036C5A4F
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 08:34:31 +0100 (CET)
Received: by mail-io0-f172.google.com with SMTP id a124so334470096ioe.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 23:34:31 -0800 (PST)
In-Reply-To: <1480462253-114713-3-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 3:30 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> Do not always set skb->protocol to be the ethertype of the L3 header.
> For a packet with non-accelerated VLAN tags skb->protocol needs to be
> the ethertype of the outermost non-accelerated VLAN ethertype.
>
> Any VLAN offloading is undone on the OVS netlink interface, and any
> VLAN tags added by userspace are non-accelerated, as are double tagged
> VLAN packets.
>
> Fixes: 018c1dda5f ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
> Fixes: 5108bbaddc ("openvswitch: add processing of L3 packets")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Looks much better now. Thanks for fixing it. I have one minor comment.

Acked-by: Pravin B Shelar <pshelar@ovn.org>

> ---
> v3: Set skb->protocol properly also for double tagged packets, as suggested
>     by Pravin.  This patch is no longer needed for the MTU test failure, as
>     the new patch 2/3 addresses that.
>
>  net/openvswitch/datapath.c |  1 -
>  net/openvswitch/flow.c     | 62 +++++++++++++++++++++++-----------------------
>  2 files changed, 31 insertions(+), 32 deletions(-)
>
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 08aa926..e2fe2e5 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -354,6 +354,7 @@ static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>                 res = parse_vlan_tag(skb, &key->eth.vlan);
>                 if (res <= 0)
>                         return res;
> +               skb->protocol = key->eth.vlan.tpid;
>         }
>
>         /* Parse inner vlan tag. */
> @@ -361,6 +362,11 @@ static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>         if (res <= 0)
>                 return res;
>
> +       /* If the outer vlan tag was accelerated, skb->protocol should
> +        * refelect the inner vlan type. */
> +       if (!eth_type_vlan(skb->protocol))

Since you would be spinning another version, can you change this
condition to directly check for skb-vlan-tag rather than indirectly
checking for the vlan accelerated case?
