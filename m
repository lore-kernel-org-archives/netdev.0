From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v10 4/5] openvswitch: add layer 3 flow/port
 support
Date: Tue, 7 Jun 2016 11:46:11 +0900
Message-ID: <20160607024609.GC31696@vergenet.net>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
 <1464848686-7656-5-git-send-email-simon.horman@netronome.com>
 <CAOrHB_Cy-Gtt3OJSpAdZu3M07xNWv5dYNAbYbD6ei3H-r66vyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35830 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbcFGCqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 22:46:22 -0400
Received: by mail-pf0-f178.google.com with SMTP id c2so48237pfa.2
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 19:46:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_Cy-Gtt3OJSpAdZu3M07xNWv5dYNAbYbD6ei3H-r66vyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 02, 2016 at 03:02:18PM -0700, pravin shelar wrote:
> On Wed, Jun 1, 2016 at 11:24 PM, Simon Horman
> <simon.horman@netronome.com> wrote:

[...]

> > diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> > index 15f130e4c22b..5567529904fa 100644
> > --- a/net/openvswitch/actions.c
> > +++ b/net/openvswitch/actions.c
> > @@ -300,6 +300,51 @@ static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *flow_key,
> >         return 0;
> >  }
> >
> > +static int pop_eth(struct sk_buff *skb, struct sw_flow_key *key)
> > +{
> > +       /* Pop outermost VLAN tag to skb metadata unless a VLAN tag
> > +        * is already present there.
> > +        */
> > +       if ((skb->protocol == htons(ETH_P_8021Q) ||
> > +            skb->protocol == htons(ETH_P_8021AD)) &&
> > +           !skb_vlan_tag_present(skb)) {
> > +               int err = skb_vlan_accel(skb);
> > +               if (unlikely(err))
> > +                       return err;
> > +       }
> > +
>
> I do not think we can keep just the vlan tag and pop ethernet header.
> There are multiple issues with this.
> First networking stack can not handle suck packet. second issue even
> after this patch OVS can not parse this type of packet. third this
> patch does not allow pop-eth action on vlan tagged packet.
> There is already separate vlan related actions in OVS so lets keep it simple.

I wonder if the best solution is to simply omit handling VLAN tags
in pop_eth for now. As you mention pop_eth is not permitted on such packets.

[...]

> > diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> > index 0ea128eeeab2..2d9777abcfc9 100644
> > --- a/net/openvswitch/flow.c
> > +++ b/net/openvswitch/flow.c
> > @@ -468,28 +468,31 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
> >
> >         skb_reset_mac_header(skb);
> >
> > -       /* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
> > -        * header in the linear data area.
> > -        */
> > -       eth = eth_hdr(skb);
> > -       ether_addr_copy(key->eth.src, eth->h_source);
> > -       ether_addr_copy(key->eth.dst, eth->h_dest);
> > +       /* Link layer. */
> > +       key->eth.tci = 0;
> > +       if (key->phy.is_layer3) {
> > +               if (skb_vlan_tag_present(skb))
> > +                       key->eth.tci = htons(skb->vlan_tci);
> > +       } else {
> > +               eth = eth_hdr(skb);
> eth can be moved to this block.

Thanks, done.

[...]

> > @@ -723,9 +730,19 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
> >         key->phy.skb_mark = skb->mark;
> >         ovs_ct_fill_key(skb, key);
> >         key->ovs_flow_hash = 0;
> > +       key->phy.is_layer3 = skb->mac_len == 0;
> >         key->recirc_id = 0;
> >
> > -       return key_extract(skb, key);
> > +       err = key_extract(skb, key);
> > +       if (err < 0)
> > +               return err;
> > +
> > +       if (key->phy.is_layer3)
> > +               key->eth.type = skb->protocol;
> Now key->eth.type is set in three different function, can you
> centralize in key_extract()?

Sure, I think that the instance above can be trivially moved into
key_extract() and the one in ovs_flow_key_update() can be removed.

[...]

> > diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> > index 0bb650f4f219..1e1392c3c0ed 100644
> > --- a/net/openvswitch/flow_netlink.c
> > +++ b/net/openvswitch/flow_netlink.c

[...]

> > @@ -355,6 +359,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
> >         [OVS_KEY_ATTR_CT_ZONE]   = { .len = sizeof(u16) },
> >         [OVS_KEY_ATTR_CT_MARK]   = { .len = sizeof(u32) },
> >         [OVS_KEY_ATTR_CT_LABELS] = { .len = sizeof(struct ovs_key_ct_labels) },
> > +       [OVS_KEY_ATTR_PACKET_ETHERTYPE] = { .len = sizeof(__be16) },
> >  };
> >
> I do not see need for OVS_KEY_ATTR_PACKET_ETHERTYPE, we can use
> existing OVS_KEY_ATTR_ETHERTYPE to serialize the flow key. If there is
> no OVS_KEY_ATTR_ETHERNET attribute then its l3 packet.

The idea of OVS_KEY_ATTR_PACKET_ETHERTYPE is to allow communication of
the L2 type of the packet which is not present in an L3 packet. In terms
of GRE (non-TEB) this correlates to the Protocol Type field in the GRE
header.
