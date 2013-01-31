From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v7 net-next 01/12] bridge: Add vlan filtering infrastructure
Date: Thu, 31 Jan 2013 20:57:01 +0100
Message-ID: <CAHXqBFL88O=cSse5AdhoKMMMrvgvn7oYAhMxt0rw9ffv49Z7hw@mail.gmail.com>
References: <1359601979-14942-1-git-send-email-vyasevic@redhat.com> <1359601979-14942-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	shmulik.ladkani@gmail.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:63012 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341Ab3AaT5W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 14:57:22 -0500
Received: by mail-oa0-f43.google.com with SMTP id l10so3418409oag.2
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 11:57:21 -0800 (PST)
In-Reply-To: <1359601979-14942-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/31 Vlad Yasevich <vyasevic@redhat.com>:
> Adds an optional infrustructure component to bridge that would allow
> native vlan filtering in the bridge.  Each bridge port (as well
> as the bridge device) now get a VLAN bitmap.  Each bit in the bitmap
> is associated with a vlan id.  This way if the bit corresponding to
> the vid is set in the bitmap that the packet with vid is allowed to
> enter and exit the port.
>
> Write access the bitmap is protected by RTNL and read access
> protected by RCU.
[...]
> +static int __vlan_del(struct net_port_vlans *v, u16 vid)
> +{
> +       unsigned long first_bit;
> +       unsigned long last_bit;
> +
> +       if (!test_bit(vid, v->vlan_bitmap))
> +               return -EINVAL;
> +
> +       /* Check to see if any other vlans are in this table.  If thi=
s
> +        * is the last vlan, delete the whole structure.  If this is =
not the
> +        * last vlan, just clear the bit.
> +        */
> +       first_bit =3D find_first_bit(v->vlan_bitmap, BR_VLAN_BITMAP_L=
EN);
> +       last_bit =3D find_last_bit(v->vlan_bitmap, BR_VLAN_BITMAP_LEN=
);
> +
> +       if (v->port_idx && vid) {
> +               struct net_device *dev =3D vlans_to_port(v)->dev;
> +
> +               if (dev->features & NETIF_F_HW_VLAN_FILTER)
> +                       dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, vi=
d);
> +       }
> +
> +       clear_bit(vid, v->vlan_bitmap);
> +       if (first_bit =3D=3D last_bit) {

if (bitmap_empty(v->vlan_bitmap, BR_VLAN_BITMAP_LEN))

> +               if (v->port_idx) {
> +                       struct net_bridge_port *p =3D vlans_to_port(v=
);
> +                       rcu_assign_pointer(p->vlan_info, NULL);
> +               } else {
> +                       struct net_bridge *br =3D vlans_to_bridge(v);
> +                       rcu_assign_pointer(br->vlan_info, NULL);
> +               }

You seem to use vlans_to_port/vlans_to_bridge only to get at
vlan_info. Maybe that could be abstracted to a single interface, or
even change v->parent to be a 'net_port_vlans **'?

Best Regards,
Micha=B3 Miros=B3aw
