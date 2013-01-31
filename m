From: Simon Barber <simon@superduper.net>
Subject: Re: [Bridge] [PATCH v7 net-next 01/12] bridge: Add vlan filtering
 infrastructure
Date: Thu, 31 Jan 2013 13:46:27 -0800
Message-ID: <510AE633.2060102@superduper.net>
References: <1359601979-14942-1-git-send-email-vyasevic@redhat.com> <1359601979-14942-2-git-send-email-vyasevic@redhat.com> <CAHXqBFL88O=cSse5AdhoKMMMrvgvn7oYAhMxt0rw9ffv49Z7hw@mail.gmail.com> <510AD51D.6080506@superduper.net> <510AD571.6060309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	shmulik.ladkani@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from masada.superduper.net ([85.119.82.91]:38444 "EHLO
	masada.superduper.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755266Ab3AaVqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 16:46:38 -0500
In-Reply-To: <510AD571.6060309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Great - I look forward to seeing this functionality in the kernel - thi=
s=20
will be very useful. Are you releasing brctl patches too?

Simon

On 01/31/2013 12:34 PM, Vlad Yasevich wrote:
> On 01/31/2013 03:33 PM, Simon Barber wrote:
>> I wrote a similar patch a few years ago:
>>
>> https://lists.linux-foundation.org/pipermail/bridge/2006-September/0=
05046.html
>>
>>
>>
>> This patch also added the possibility to define a native vlan for ea=
ch
>> port and for the bridge port itself - is there any interest in this
>> feature as well as the filtering?
>>
>
> See patch 5 and 6 and the series :)
>
> -vlad
>
>> Simon
>>
>>
>> On 01/31/2013 11:57 AM, Micha=B3 Miros=B3aw wrote:
>>> 2013/1/31 Vlad Yasevich <vyasevic@redhat.com>:
>>>> Adds an optional infrustructure component to bridge that would all=
ow
>>>> native vlan filtering in the bridge.  Each bridge port (as well
>>>> as the bridge device) now get a VLAN bitmap.  Each bit in the bitm=
ap
>>>> is associated with a vlan id.  This way if the bit corresponding t=
o
>>>> the vid is set in the bitmap that the packet with vid is allowed t=
o
>>>> enter and exit the port.
>>>>
>>>> Write access the bitmap is protected by RTNL and read access
>>>> protected by RCU.
>>> [...]
>>>> +static int __vlan_del(struct net_port_vlans *v, u16 vid)
>>>> +{
>>>> +       unsigned long first_bit;
>>>> +       unsigned long last_bit;
>>>> +
>>>> +       if (!test_bit(vid, v->vlan_bitmap))
>>>> +               return -EINVAL;
>>>> +
>>>> +       /* Check to see if any other vlans are in this table.  If =
this
>>>> +        * is the last vlan, delete the whole structure.  If this =
is
>>>> not the
>>>> +        * last vlan, just clear the bit.
>>>> +        */
>>>> +       first_bit =3D find_first_bit(v->vlan_bitmap, BR_VLAN_BITMA=
P_LEN);
>>>> +       last_bit =3D find_last_bit(v->vlan_bitmap, BR_VLAN_BITMAP_=
LEN);
>>>> +
>>>> +       if (v->port_idx && vid) {
>>>> +               struct net_device *dev =3D vlans_to_port(v)->dev;
>>>> +
>>>> +               if (dev->features & NETIF_F_HW_VLAN_FILTER)
>>>> +                       dev->netdev_ops->ndo_vlan_rx_kill_vid(dev,
>>>> vid);
>>>> +       }
>>>> +
>>>> +       clear_bit(vid, v->vlan_bitmap);
>>>> +       if (first_bit =3D=3D last_bit) {
>>>
>>> if (bitmap_empty(v->vlan_bitmap, BR_VLAN_BITMAP_LEN))
>>>
>>>> +               if (v->port_idx) {
>>>> +                       struct net_bridge_port *p =3D vlans_to_por=
t(v);
>>>> +                       rcu_assign_pointer(p->vlan_info, NULL);
>>>> +               } else {
>>>> +                       struct net_bridge *br =3D vlans_to_bridge(=
v);
>>>> +                       rcu_assign_pointer(br->vlan_info, NULL);
>>>> +               }
>>>
>>> You seem to use vlans_to_port/vlans_to_bridge only to get at
>>> vlan_info. Maybe that could be abstracted to a single interface, or
>>> even change v->parent to be a 'net_port_vlans **'?
>>>
>>> Best Regards,
>>> Micha=B3 Miros=B3aw
>>>
>
