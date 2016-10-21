From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v12 5/9] openvswitch: add processing of L3 packets
Date: Thu, 20 Oct 2016 21:19:14 -0700
Message-ID: <CAOrHB_Co3DaYJPbrcDRrnQ1P18X9B=n867uWEiaFqJcKPHs=2A@mail.gmail.com>
References: <cover.1476708212.git.jbenc@redhat.com> <a4590d690c169e0021031405463c8629a6e9ecb8.1476708213.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:52349 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752208AbcJUETW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 00:19:22 -0400
Received: from mfilter34-d.gandi.net (mfilter34-d.gandi.net [217.70.178.165])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 7A5FA17209A
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:19:18 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter34-d.gandi.net (mfilter34-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id CEr3nRjbNhcA for <netdev@vger.kernel.org>;
        Fri, 21 Oct 2016 06:19:17 +0200 (CEST)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id E7724172097
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:19:16 +0200 (CEST)
Received: by mail-it0-f43.google.com with SMTP id 139so202440455itm.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 21:19:16 -0700 (PDT)
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
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 4d67ea856067..c5b719fca8d4 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
...
...
> @@ -609,8 +597,10 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
>
>         err = ovs_flow_key_extract_userspace(net, a[OVS_PACKET_ATTR_KEY],
>                                              packet, &flow->key, log);
> -       if (err)
> +       if (err) {
> +               packet = NULL;
>                 goto err_flow_free;
> +       }
>
Why packet is set to NULL? This would leak skb memory in case of error.

>         err = ovs_nla_copy_actions(net, a[OVS_PACKET_ATTR_ACTIONS],
>                                    &flow->key, &acts, log);
...
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 96c8c4716603..7aee6e273765 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
...

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
This packet should be dropped.

> +}
> +
>  int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
>                          struct sk_buff *skb, struct sw_flow_key *key)
>  {
....

> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index dc0e2212edfc..8361b62a47c2 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -502,6 +502,22 @@ void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
>  {
>         int mtu = vport->dev->mtu;
>
> +       switch (vport->dev->type) {
> +       case ARPHRD_NONE:
> +               if (mac_proto != MAC_PROTO_NONE) {
> +                       WARN_ON_ONCE(mac_proto != MAC_PROTO_ETHERNET);
> +
It would be easy to read if you check mac_proto for MAC_PROTO_ETHERNET
and then warn otherwise.
another issue is the packet is not dropped if mac_proto is not
MAC_PROTO_ETHERNET

> +                       skb_reset_network_header(skb);
> +                       skb_reset_mac_len(skb);
> +                       skb->protocol = htons(ETH_P_TEB);
> +               }
> +               break;
> +       case ARPHRD_ETHER:
> +               if (mac_proto != MAC_PROTO_ETHERNET)
> +                       goto drop;
> +               break;
> +       }
> +
>         if (unlikely(packet_length(skb, vport->dev) > mtu &&
>                      !skb_is_gso(skb))) {
>                 net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
> --
> 1.8.3.1
>
