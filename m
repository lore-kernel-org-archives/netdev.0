From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v7 net-next 01/12] bridge: Add vlan filtering infrastructure
Date: Thu, 31 Jan 2013 21:50:21 -0500
Message-ID: <510B2D6D.4050908@redhat.com>
References: <1359601979-14942-1-git-send-email-vyasevic@redhat.com> <1359601979-14942-2-git-send-email-vyasevic@redhat.com> <CAHXqBFL88O=cSse5AdhoKMMMrvgvn7oYAhMxt0rw9ffv49Z7hw@mail.gmail.com> <510AD065.9010403@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	shmulik.ladkani@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492Ab3BACua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 21:50:30 -0500
In-Reply-To: <510AD065.9010403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2013 03:13 PM, Vlad Yasevich wrote:
> On 01/31/2013 02:57 PM, Micha=B3 Miros=B3aw wrote:
>> 2013/1/31 Vlad Yasevich <vyasevic@redhat.com>:
>>> Adds an optional infrustructure component to bridge that would allo=
w
>>> native vlan filtering in the bridge.  Each bridge port (as well
>>> as the bridge device) now get a VLAN bitmap.  Each bit in the bitma=
p
>>> is associated with a vlan id.  This way if the bit corresponding to
>>> the vid is set in the bitmap that the packet with vid is allowed to
>>> enter and exit the port.
>>>
>>> Write access the bitmap is protected by RTNL and read access
>>> protected by RCU.
>> [...]
>>> +static int __vlan_del(struct net_port_vlans *v, u16 vid)
>>> +{
>>> +       unsigned long first_bit;
>>> +       unsigned long last_bit;
>>> +
>>> +       if (!test_bit(vid, v->vlan_bitmap))
>>> +               return -EINVAL;
>>> +
>>> +       /* Check to see if any other vlans are in this table.  If t=
his
>>> +        * is the last vlan, delete the whole structure.  If this i=
s
>>> not the
>>> +        * last vlan, just clear the bit.
>>> +        */
>>> +       first_bit =3D find_first_bit(v->vlan_bitmap, BR_VLAN_BITMAP=
_LEN);
>>> +       last_bit =3D find_last_bit(v->vlan_bitmap, BR_VLAN_BITMAP_L=
EN);
>>> +
>>> +       if (v->port_idx && vid) {
>>> +               struct net_device *dev =3D vlans_to_port(v)->dev;
>>> +
>>> +               if (dev->features & NETIF_F_HW_VLAN_FILTER)
>>> +                       dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, =
vid);
>>> +       }
>>> +
>>> +       clear_bit(vid, v->vlan_bitmap);
>>> +       if (first_bit =3D=3D last_bit) {
>>
>> if (bitmap_empty(v->vlan_bitmap, BR_VLAN_BITMAP_LEN))
>
> Yeah.  I didn't have the clear_bit about before, but with it
> bitmap_empty() is much better.
>
>>
>>> +               if (v->port_idx) {
>>> +                       struct net_bridge_port *p =3D vlans_to_port=
(v);
>>> +                       rcu_assign_pointer(p->vlan_info, NULL);
>>> +               } else {
>>> +                       struct net_bridge *br =3D vlans_to_bridge(v=
);
>>> +                       rcu_assign_pointer(br->vlan_info, NULL);
>>> +               }
>>
>> You seem to use vlans_to_port/vlans_to_bridge only to get at
>> vlan_info. Maybe that could be abstracted to a single interface, or
>> even change v->parent to be a 'net_port_vlans **'?
>
> Hmm..  net_port_vlan** has appeal.  I'll see if I can make it work.

So, I went about rewriting this only to realize that there is a bug in
patch 10 and I need the conversion functions to fix it.
I can't really abstract it to a single interface without adding the=20
whole nbp/port layer on top of the bridge device and that's overkill.=20
Changing to net_port_vlans** doesn't buy me anything other then obfusca=
tion.

So I think I am going to keep the much simpler parent pointer and=20
conversion functions since I will need them later.

Thanks
-vlad
>
> Thanks
> -vlad
>>
>> Best Regards,
>> Micha=B3 Miros=B3aw
>>
>
