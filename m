From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 2/3] openvswitch: Use is_skb_forwardable() for
 length check.
Date: Tue, 29 Nov 2016 23:23:34 -0800
Message-ID: <CAOrHB_DP5PL=YNSZxL=aXDoOJNA=sSgMV3HL_mAp1ZBoLTSmvw@mail.gmail.com>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org> <1480462253-114713-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>, Eric Garver <e@erig.me>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:50603 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755401AbcK3HXw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 02:23:52 -0500
Received: from mfilter39-d.gandi.net (mfilter39-d.gandi.net [217.70.178.170])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 138D9C5A6C
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 08:23:38 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter39-d.gandi.net (mfilter39-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Ws8OfeDd92iz for <netdev@vger.kernel.org>;
        Wed, 30 Nov 2016 08:23:36 +0100 (CET)
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 715F5C5A78
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 08:23:36 +0100 (CET)
Received: by mail-io0-f174.google.com with SMTP id m5so196495667ioe.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 23:23:36 -0800 (PST)
In-Reply-To: <1480462253-114713-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 3:30 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> Use is_skb_forwardable() instead of an explicit length check.  This
> gets around the apparent MTU check failure in OVS test cases when
> skb->protocol is not properly set in case of non-accelerated VLAN
> skbs.
>
> Suggested-by: Pravin Shelar <pshelar@ovn.org>
> Fixes: 5108bbaddc ("openvswitch: add processing of L3 packets")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
> v3: New patch suggested by Pravin.
>
> net/openvswitch/vport.c | 38 ++++++++++++++------------------------
>  1 file changed, 14 insertions(+), 24 deletions(-)
>
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index b6c8524..076b39f 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c

>  void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
>  {
> -       int mtu = vport->dev->mtu;
> -
>         switch (vport->dev->type) {
>         case ARPHRD_NONE:
>                 if (mac_proto == MAC_PROTO_ETHERNET) {
> @@ -504,11 +485,20 @@ void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
>                 goto drop;
>         }
>
> -       if (unlikely(packet_length(skb, vport->dev) > mtu &&
> -                    !skb_is_gso(skb))) {
> -               net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
> -                                    vport->dev->name,
> -                                    packet_length(skb, vport->dev), mtu);
> +       if (unlikely(!is_skb_forwardable(vport->dev, skb))) {

This would easy to read if you inverse the if condition here.

> +               /* Log only if the device is up. */
> +               if (vport->dev->flags & IFF_UP) {

since is_skb_forwardable() is checking for IFF_UP we can remove same
check from internal-device send() op.

> +                       unsigned int length = skb->len
> +                               - vport->dev->hard_header_len;
> +
> +                       if (!skb_vlan_tag_present(skb)
> +                           && eth_type_vlan(skb->protocol))
> +                               length -= VLAN_HLEN;
> +
> +                       net_warn_ratelimited("%s: dropped over-mtu packet %d > %d\n",
> +                                            vport->dev->name, length,
> +                                            vport->dev->mtu);
> +               }
>                 vport->dev->stats.tx_errors++;
>                 goto drop;
>         }
> --
> 2.1.4
>
