From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v9 net-next 01/12] bridge: Add vlan filtering infrastructure
Date: Fri, 01 Feb 2013 21:11:39 -0500
Message-ID: <510C75DB.5010801@redhat.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com> <1359748930-31475-2-git-send-email-vyasevic@redhat.com> <CAHXqBFJfPYwnxbeDR6AfG0-PQJ__=rKMxQWRcFJGseGiXyuYGg@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54810 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757075Ab3BBCLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 21:11:44 -0500
In-Reply-To: <CAHXqBFJfPYwnxbeDR6AfG0-PQJ__=rKMxQWRcFJGseGiXyuYGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2013 08:04 PM, Micha=C5=82 Miros=C5=82aw wrote:
> 2013/2/1 Vlad Yasevich <vyasevic@redhat.com>:
>> Adds an optional infrustructure component to bridge that would allow
>> native vlan filtering in the bridge.  Each bridge port (as well
>> as the bridge device) now get a VLAN bitmap.  Each bit in the bitmap
>> is associated with a vlan id.  This way if the bit corresponding to
>> the vid is set in the bitmap that the packet with vid is allowed to
>> enter and exit the port.
> [...]
> +struct net_port_vlans {
> +       u16                             port_idx;
> +       void                            *parent;
> +       struct rcu_head                 rcu;
> +       unsigned long                   vlan_bitmap[BR_VLAN_BITMAP_LE=
N];
> +};
> [later, in br_vlan.c]
> +#define vlans_to_parent(type, pv) ((type *)(pv)->parent)
>
> A really don't like this pointer casting. It's easy to get it wrong
> (and you did in __vlan_del).
>
> 1. union { struct net_bridge *br; struct net_bridge_port *port; } par=
ent;
>
> 2. inline net_port_vlans __rcu **br_vlan_info_parent_ptr(struct
> net_port_vlans *v)
> {
> 	return v->port_idx ? &v->parent.port->vlan_info : &v->parent.br->vla=
n_info;
> }
>
> (I'm not insisting on #2. Just think about it. ;)

I need the parent, not the vlan_info.  Sometimes I need to get to the=20
device and I really don't want to then use container_of().

I suppose I could do the union, but that's really not much different=20
then the type casts.  Just as easy to goof.

>
>> @@ -156,6 +166,7 @@ struct net_bridge_port
>>   #ifdef CONFIG_NET_POLL_CONTROLLER
>>          struct netpoll                  *np;
>>   #endif
>> +       struct net_port_vlans __rcu     *vlan_info;
>>   };
>
> Missing #ifdef CONFIG_BRIDGE_VLAN_FILTERING?

Yep.  Its in net_bridge, but not here.  Will fix.

>
>> +static int __vlan_del(struct net_port_vlans *v, u16 vid)
>> +{
>> +       unsigned long first_bit;
>> +       unsigned long last_bit;
>> +
>> +       if (!test_bit(vid, v->vlan_bitmap))
>> +               return -EINVAL;
>> +
>> +       /* Check to see if any other vlans are in this table.  If th=
is
>> +        * is the last vlan, delete the whole structure.  If this is=
 not the
>> +        * last vlan, just clear the bit.
>> +        */
>> +       first_bit =3D find_first_bit(v->vlan_bitmap, BR_VLAN_BITMAP_=
LEN);
>> +       last_bit =3D find_last_bit(v->vlan_bitmap, BR_VLAN_BITMAP_LE=
N);
>> +
>> +       if (v->port_idx && vid) {
>> +               struct net_device *dev =3D
>> +                       vlans_to_parent(struct net_bridge, v)->dev;
>
> struct net_bridge_port (or union and v->parent.port)

Yep.  Typo when doing conversions.

>
>> +
>> +               if (dev->features & NETIF_F_HW_VLAN_FILTER)
>> +                       dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, v=
id);
>> +       }
>> +
>> +       clear_bit(vid, v->vlan_bitmap);
>> +       if (first_bit =3D=3D last_bit) {
>
> bitmap_empty() is faster than two times find_xxx_bit().
>

WTH?  I did this change and now its gone...  Time to see what else I=20
somehow lost...

>> +               if (v->port_idx) {
>> +                       struct net_bridge_port *p =3D
>> +                               vlans_to_parent(struct net_bridge_po=
rt, v);
>> +                       rcu_assign_pointer(p->vlan_info, NULL);
>> +               } else {
>> +                       struct net_bridge *br =3D
>> +                               vlans_to_parent(struct net_bridge, v=
);
>> +                       rcu_assign_pointer(br->vlan_info, NULL);
>> +               }
>
> With inline function above:
>
> rcu_assign_pointer(*br_vlan_info_parent_ptr(v), NULL);
>
>> +               kfree_rcu(v, rcu);
>> +       }
>> +       return 0;
>> +}
>> +
>> +static void __vlan_flush(struct net_port_vlans *v)
>> +{
>> +       bitmap_zero(v->vlan_bitmap, BR_VLAN_BITMAP_LEN);
>> +       if (v->port_idx) {
>> +               struct net_bridge_port *p =3D
>> +                               vlans_to_parent(struct net_bridge_po=
rt, v);
>> +               rcu_assign_pointer(p->vlan_info, NULL);
>> +       } else {
>> +               struct net_bridge *br =3D
>> +                               vlans_to_parent(struct net_bridge, v=
);
>> +               rcu_assign_pointer(br->vlan_info, NULL);
>> +       }
>
> Same here.

Thanks.  I'll probably go with the union for direct reference.

-vlad
>
>> +       kfree_rcu(v, rcu);
>> +}
>
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>
