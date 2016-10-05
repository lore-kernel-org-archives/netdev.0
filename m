From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] openvswitch: normalize vlan rx path
Date: Wed, 5 Oct 2016 17:18:08 +0300
Message-ID: <CAHsH6Gvha_Saq8SVaLhsXzNggAOwbdu6n5xLQD7HFhYweJMsmw@mail.gmail.com>
References: <cover.1475672568.git.jbenc@redhat.com> <c7f44c08104958c86c68d98f1e093d754b0ca61b.1475672569.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36689 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbcJEOSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 10:18:10 -0400
Received: by mail-wm0-f66.google.com with SMTP id b184so24817953wma.3
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 07:18:09 -0700 (PDT)
In-Reply-To: <c7f44c08104958c86c68d98f1e093d754b0ca61b.1475672569.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Oct 5, 2016 at 4:07 PM, Jiri Benc <jbenc@redhat.com> wrote:
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 4d67ea856067..c47b3da8ecf2 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -594,6 +594,16 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
>         else
>                 packet->protocol = htons(ETH_P_802_2);
>
> +       if (eth_type_vlan(packet->protocol)) {
> +               __skb_pull(packet, ETH_HLEN);
> +               skb_reset_network_header(packet);
> +               skb_reset_mac_len(packet);
> +               packet = skb_vlan_untag(packet);
> +               if (unlikely(!packet))
> +                       goto err;

I think at this point, 'eth' may point to a freed packet.
Maybe replace the 'eth' variable with a 'proto' variable caching the
value of eth_hdr(packet)->h_proto?

> +               skb_push(packet, ETH_HLEN);
> +       }
> +
>         /* Set packet's mru */
>         if (a[OVS_PACKET_ATTR_MRU]) {
>                 mru = nla_get_u16(a[OVS_PACKET_ATTR_MRU]);
> --
> 1.8.3.1
>

Eyal.
