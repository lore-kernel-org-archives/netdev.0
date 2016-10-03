From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] openvswitch: correctly fragment packet with mpls headers
Date: Mon, 3 Oct 2016 11:04:46 -0700
Message-ID: <CAOrHB_Dh=OPUTbbN7QYo9Nz4cV99-k_fT4z7jSOEcnFEDKXQEg@mail.gmail.com>
References: <b0cb6efc9bfda8381af880f10fa6b3447f7d3d5d.1475512190.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:35098 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752545AbcJCSEw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 14:04:52 -0400
Received: from mfilter30-d.gandi.net (mfilter30-d.gandi.net [217.70.178.161])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id E86E81720A1
        for <netdev@vger.kernel.org>; Mon,  3 Oct 2016 20:04:49 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter30-d.gandi.net (mfilter30-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id v5bS6nkpNRxT for <netdev@vger.kernel.org>;
        Mon,  3 Oct 2016 20:04:48 +0200 (CEST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 63D2E1720B4
        for <netdev@vger.kernel.org>; Mon,  3 Oct 2016 20:04:48 +0200 (CEST)
Received: by mail-it0-f41.google.com with SMTP id r192so122857104ita.0
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 11:04:48 -0700 (PDT)
In-Reply-To: <b0cb6efc9bfda8381af880f10fa6b3447f7d3d5d.1475512190.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 3, 2016 at 9:33 AM, Jiri Benc <jbenc@redhat.com> wrote:
> If mpls headers were pushed to a defragmented packet, the refragmentation no
> longer works correctly after 48d2ab609b6b ("net: mpls: Fixups for GSO"). The
> network header has to be shifted after the mpls headers for the
> fragmentation and restored afterwards.
>
> Fixes: 48d2ab609b6b ("net: mpls: Fixups for GSO")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  net/openvswitch/actions.c | 26 +++++++++++++++++++++-----
>  1 file changed, 21 insertions(+), 5 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 4e03f64709bc..370b2ba3df4c 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -62,7 +62,8 @@ struct ovs_frag_data {
>         struct vport *vport;
>         struct ovs_skb_cb cb;
>         __be16 inner_protocol;
> -       __u16 vlan_tci;
> +       u16 network_offset;     /* valid only if inner_protocol is set */
> +       u16 vlan_tci;
>         __be16 vlan_proto;
>         unsigned int l2_len;
>         u8 l2_data[MAX_L2_LEN];
> @@ -656,7 +657,6 @@ static int ovs_vport_output(struct net *net, struct sock *sk, struct sk_buff *sk
>
>         __skb_dst_copy(skb, data->dst);
>         *OVS_CB(skb) = data->cb;
> -       skb->inner_protocol = data->inner_protocol;
>         skb->vlan_tci = data->vlan_tci;
>         skb->vlan_proto = data->vlan_proto;
>
> @@ -666,6 +666,13 @@ static int ovs_vport_output(struct net *net, struct sock *sk, struct sk_buff *sk
>         skb_postpush_rcsum(skb, skb->data, data->l2_len);
>         skb_reset_mac_header(skb);
>
> +       if (data->inner_protocol) {
> +               skb->inner_protocol = data->inner_protocol;
> +               skb->inner_network_header = skb->network_header;
> +               skb_set_network_header(skb, data->network_offset);
> +       }
> +       skb_reset_mac_len(skb);
> +
>         ovs_vport_send(vport, skb);
>         return 0;
>  }
> @@ -684,7 +691,8 @@ static struct dst_ops ovs_dst_ops = {
>  /* prepare_frag() is called once per (larger-than-MTU) frame; its inverse is
>   * ovs_vport_output(), which is called once per fragmented packet.
>   */
> -static void prepare_frag(struct vport *vport, struct sk_buff *skb)
> +static void prepare_frag(struct vport *vport, struct sk_buff *skb,
> +                        u16 orig_network_offset)
>  {
>         unsigned int hlen = skb_network_offset(skb);
>         struct ovs_frag_data *data;
> @@ -694,6 +702,7 @@ static void prepare_frag(struct vport *vport, struct sk_buff *skb)
>         data->vport = vport;
>         data->cb = *OVS_CB(skb);
>         data->inner_protocol = skb->inner_protocol;
> +       data->network_offset = orig_network_offset;
>         data->vlan_tci = skb->vlan_tci;
>         data->vlan_proto = skb->vlan_proto;
>         data->l2_len = hlen;
> @@ -706,6 +715,13 @@ static void prepare_frag(struct vport *vport, struct sk_buff *skb)
>  static void ovs_fragment(struct net *net, struct vport *vport,
>                          struct sk_buff *skb, u16 mru, __be16 ethertype)
>  {
> +       u16 orig_network_offset = 0;
> +
> +       if (skb->inner_protocol) {
> +               orig_network_offset = skb_network_offset(skb);
> +               skb->network_header = skb->inner_network_header;
> +       }
> +
This is not correct way to detect MPLS packet. inner_protocol can be
set by any tunnel device for using tunnel offloads. So this would
break the fragmentation for encapsulated packets. How about using
eth_p_mpls() as done in do-output()?
