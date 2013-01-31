From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v7 net-next 01/12] bridge: Add vlan filtering infrastructure
Date: Thu, 31 Jan 2013 15:13:25 -0500
Message-ID: <510AD065.9010403@redhat.com>
References: <1359601979-14942-1-git-send-email-vyasevic@redhat.com> <1359601979-14942-2-git-send-email-vyasevic@redhat.com> <CAHXqBFL88O=cSse5AdhoKMMMrvgvn7oYAhMxt0rw9ffv49Z7hw@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	shmulik.ladkani@gmail.com
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567Ab3AaUNd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 15:13:33 -0500
In-Reply-To: <CAHXqBFL88O=cSse5AdhoKMMMrvgvn7oYAhMxt0rw9ffv49Z7hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2013 02:57 PM, Micha=B3 Miros=B3aw wrote:
> 2013/1/31 Vlad Yasevich <vyasevic@redhat.com>:
>> Adds an optional infrustructure component to bridge that would allow
>> native vlan filtering in the bridge.  Each bridge port (as well
>> as the bridge device) now get a VLAN bitmap.  Each bit in the bitmap
>> is associated with a vlan id.  This way if the bit corresponding to
>> the vid is set in the bitmap that the packet with vid is allowed to
>> enter and exit the port.
>>
>> Write access the bitmap is protected by RTNL and read access
>> protected by RCU.
> [...]
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
>> +               struct net_device *dev =3D vlans_to_port(v)->dev;
>> +
>> +               if (dev->features & NETIF_F_HW_VLAN_FILTER)
>> +                       dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, v=
id);
>> +       }
>> +
>> +       clear_bit(vid, v->vlan_bitmap);
>> +       if (first_bit =3D=3D last_bit) {
>
> if (bitmap_empty(v->vlan_bitmap, BR_VLAN_BITMAP_LEN))

Yeah.  I didn't have the clear_bit about before, but with it=20
bitmap_empty() is much better.

>
>> +               if (v->port_idx) {
>> +                       struct net_bridge_port *p =3D vlans_to_port(=
v);
>> +                       rcu_assign_pointer(p->vlan_info, NULL);
>> +               } else {
>> +                       struct net_bridge *br =3D vlans_to_bridge(v)=
;
>> +                       rcu_assign_pointer(br->vlan_info, NULL);
>> +               }
>
> You seem to use vlans_to_port/vlans_to_bridge only to get at
> vlan_info. Maybe that could be abstracted to a single interface, or
> even change v->parent to be a 'net_port_vlans **'?

Hmm..  net_port_vlan** has appeal.  I'll see if I can make it work.

Thanks
-vlad
>
> Best Regards,
> Micha=B3 Miros=B3aw
>
