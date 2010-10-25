From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Reproducible VLAN/e1000e crash in 2.6.36 vanilla.
Date: Mon, 25 Oct 2010 23:38:22 +0200
Message-ID: <1288042702.3296.5.camel@edumazet-laptop>
References: <4CC5C51F.3000606@candelatech.com>
	 <4CC5F40D.8050302@candelatech.com>  <4CC5F7EB.7010307@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35553 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755409Ab0JYVia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 17:38:30 -0400
Received: by wwe15 with SMTP id 15so3993467wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 14:38:29 -0700 (PDT)
In-Reply-To: <4CC5F7EB.7010307@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 octobre 2010 =C3=A0 14:34 -0700, John Fastabend a =C3=A9cri=
t :
> On 10/25/2010 2:18 PM, Ben Greear wrote:
> > On 10/25/2010 10:57 AM, Ben Greear wrote:
> >>
> >> To re-create, setup 2 802.1q vlans on different physical interface=
s on
> >> the same system,
> >> set up routing rules such that send-to-self works, and pass traffi=
c
> >> (UDP/IPv4 in this case,
> >> but doesn't seem to matter).
> >> Stop traffic, then attempt to create additional 802.1q vlans on th=
e same
> >> physical interfaces.
> >> The crash only appears to happen after having sent traffic on the
> >> interface.
> >>
> >> Likely it will also crash if one system is sending to another, but=
 so
> >> far we've
> >> just tested sending-to-self.
> >>
> >> This appears very reproducible for us, and appears to be the same
> >> problem that
> >> I had reported against our hacked kernel here:
> >>
> >> http://www.spinics.net/lists/netdev/msg144748.html
> >=20
> > Bleh, I think I see the problem.
> >=20
> > If a NIC is in promis mode, it can receive VLAN packets for which t=
here
> > are no VLAN devices.
> >=20
> > static gro_result_t
> > vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
> >                  unsigned int vlan_tci, struct sk_buff *skb)
> > {
> >          struct sk_buff *p;
> >          struct net_device *vlan_dev;
> >          u16 vlan_id;
> >=20
> >          if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master=
)))
> >                  skb->deliver_no_wcard =3D 1;
> >=20
> >          skb->skb_iif =3D skb->dev->ifindex;
> >          __vlan_hwaccel_put_tag(skb, vlan_tci);
> >          vlan_id =3D vlan_tci & VLAN_VID_MASK;
> >          vlan_dev =3D vlan_group_get_device(grp, vlan_id);
> >=20
> >          if (vlan_dev)
> >                  skb->dev =3D vlan_dev;
> >          else if (vlan_id) {
> >                  if (!(skb->dev->flags & IFF_PROMISC))
> >                          goto drop;
> >                  skb->pkt_type =3D PACKET_OTHERHOST;
> >          }
> >=20
> > You hit that else branch, and then skb->dev remains the physical
> > device.
> >=20
> > Later, it's passed to:
> >=20
> > int vlan_hwaccel_do_receive(struct sk_buff *skb)
> > {
> > 	struct net_device *dev =3D skb->dev;
> > 	struct vlan_rx_stats     *rx_stats;
> >=20
> > 	skb->dev =3D vlan_dev_info(dev)->real_dev;
> > 	netif_nit_deliver(skb);
> >=20
>=20
> Looks like this should be fixed on net-next,
>=20
> bool vlan_hwaccel_do_receive(struct sk_buff **skbp)
> {
>         struct sk_buff *skb =3D *skbp;
>         u16 vlan_id =3D skb->vlan_tci & VLAN_VID_MASK;
>         struct net_device *vlan_dev;
>         struct vlan_rx_stats *rx_stats;
>=20
>         vlan_dev =3D vlan_find_dev(skb->dev, vlan_id);
>         if (!vlan_dev) {
>                 if (vlan_id)
>                         skb->pkt_type =3D PACKET_OTHERHOST;
>                 return false;
>         }
>=20
> If the vlan_dev is not found do not set skb->dev and return false the=
n
> in __netif_receive_skb,
>=20
>       if (vlan_tx_tag_present(skb)) {
>                 if (pt_prev) {
>                         ret =3D deliver_skb(skb, pt_prev, orig_dev);
>                         pt_prev =3D NULL;
>                 }
>                 if (vlan_hwaccel_do_receive(&skb)) {
>                         ret =3D __netif_receive_skb(skb);
>                         goto out;
>                 } else if (unlikely(!skb))
>                         goto out;
>         }
>=20

Yes but net-next is totally different beast for vlans ;)

We should make a patch for 2.6.36, not bringing huge vlan stuff added
for 2.6.37=20



