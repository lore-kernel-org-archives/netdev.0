From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v9 net-next 01/12] bridge: Add vlan filtering infrastructure
Date: Sat, 2 Feb 2013 02:04:09 +0100
Message-ID: <CAHXqBFJfPYwnxbeDR6AfG0-PQJ__=rKMxQWRcFJGseGiXyuYGg@mail.gmail.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com> <1359748930-31475-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:64065 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757093Ab3BBBEa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 20:04:30 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so3974518oag.26
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 17:04:29 -0800 (PST)
In-Reply-To: <1359748930-31475-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/1 Vlad Yasevich <vyasevic@redhat.com>:
> Adds an optional infrustructure component to bridge that would allow
> native vlan filtering in the bridge.  Each bridge port (as well
> as the bridge device) now get a VLAN bitmap.  Each bit in the bitmap
> is associated with a vlan id.  This way if the bit corresponding to
> the vid is set in the bitmap that the packet with vid is allowed to
> enter and exit the port.
[...]
+struct net_port_vlans {
+       u16                             port_idx;
+       void                            *parent;
+       struct rcu_head                 rcu;
+       unsigned long                   vlan_bitmap[BR_VLAN_BITMAP_LEN]=
;
+};
[later, in br_vlan.c]
+#define vlans_to_parent(type, pv) ((type *)(pv)->parent)

A really don't like this pointer casting. It's easy to get it wrong
(and you did in __vlan_del).

1. union { struct net_bridge *br; struct net_bridge_port *port; } paren=
t;

2. inline net_port_vlans __rcu **br_vlan_info_parent_ptr(struct
net_port_vlans *v)
{
	return v->port_idx ? &v->parent.port->vlan_info : &v->parent.br->vlan_=
info;
}

(I'm not insisting on #2. Just think about it. ;)

> @@ -156,6 +166,7 @@ struct net_bridge_port
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>         struct netpoll                  *np;
>  #endif
> +       struct net_port_vlans __rcu     *vlan_info;
>  };

Missing #ifdef CONFIG_BRIDGE_VLAN_FILTERING?

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
> +               struct net_device *dev =3D
> +                       vlans_to_parent(struct net_bridge, v)->dev;

struct net_bridge_port (or union and v->parent.port)

> +
> +               if (dev->features & NETIF_F_HW_VLAN_FILTER)
> +                       dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, vi=
d);
> +       }
> +
> +       clear_bit(vid, v->vlan_bitmap);
> +       if (first_bit =3D=3D last_bit) {

bitmap_empty() is faster than two times find_xxx_bit().

> +               if (v->port_idx) {
> +                       struct net_bridge_port *p =3D
> +                               vlans_to_parent(struct net_bridge_por=
t, v);
> +                       rcu_assign_pointer(p->vlan_info, NULL);
> +               } else {
> +                       struct net_bridge *br =3D
> +                               vlans_to_parent(struct net_bridge, v)=
;
> +                       rcu_assign_pointer(br->vlan_info, NULL);
> +               }

With inline function above:

rcu_assign_pointer(*br_vlan_info_parent_ptr(v), NULL);

> +               kfree_rcu(v, rcu);
> +       }
> +       return 0;
> +}
> +
> +static void __vlan_flush(struct net_port_vlans *v)
> +{
> +       bitmap_zero(v->vlan_bitmap, BR_VLAN_BITMAP_LEN);
> +       if (v->port_idx) {
> +               struct net_bridge_port *p =3D
> +                               vlans_to_parent(struct net_bridge_por=
t, v);
> +               rcu_assign_pointer(p->vlan_info, NULL);
> +       } else {
> +               struct net_bridge *br =3D
> +                               vlans_to_parent(struct net_bridge, v)=
;
> +               rcu_assign_pointer(br->vlan_info, NULL);
> +       }

Same here.

> +       kfree_rcu(v, rcu);
> +}

Best Regards,
Micha=C5=82 Miros=C5=82aw
