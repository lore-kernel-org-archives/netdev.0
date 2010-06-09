From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: RFS seems to have incompatiblities with bridged vlans
Date: Tue, 08 Jun 2010 18:08:43 -0700
Message-ID: <4C0EE99B.8030300@intel.com>
References: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>	<20100607145910.2458ac87@nehalam>	<4C0D7312.1020300@intel.com>	<1276006721.2486.141.camel@edumazet-laptop> <AANLkTiluIibUglhf28JAeSLzBC0E1Zw0STPoqFTbXcev@mail.gmail.com> <4C0ED931.6030402@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Peter Lieven <pl@dlh.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "tim.gardner@canonical.com" <tim.gardner@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17996 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754794Ab0FIBID (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 21:08:03 -0400
In-Reply-To: <4C0ED931.6030402@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tim Gardner wrote:
> On 06/08/2010 05:00 PM, Tom Herbert wrote:
>> How about only checking against dev->num_rx_queues when that value i=
s
>> greater than one.  Since bonding device is calling alloc_netdev, it =
is
>> not going to set the queue mapping, but dev->num_rx_queues will be o=
ne
>> in that case (this handles any intermediate driver that does do
>> multiple queues).
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 6f330ce..30ab66d 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2270,7 +2270,7 @@ static int get_rps_cpu(struct net_device *dev,
>> struct sk_buff *skb,
>>                  u16 v16[2];
>>          } ports;
>>
>> -       if (skb_rx_queue_recorded(skb)) {
>> +       if (skb_rx_queue_recorded(skb)&&  dev->num_rx_queues>  1) {
>>                  u16 index =3D skb_get_rx_queue(skb);
>>                  if (unlikely(index>=3D dev->num_rx_queues)) {
>>                          if (net_ratelimit()) {
>>


Problem with this is it doesn't address mis-aligned num_rx_queues.  For=
 example=20
with the bonding driver defaulting to 16 queues now. We could end up wi=
th a base=20
driver with 16+ queues and a bond with 16.  Then we have the same issue=
 again.

  eth0  -------> bond / bridge ---------> vlan.id
(nbrxq=3D64)      (nbrxq=3D16)              (nbrxq=3DX)

>>
>> On Tue, Jun 8, 2010 at 7:18 AM, Eric Dumazet<eric.dumazet@gmail.com>=
  wrote:
>>> Le lundi 07 juin 2010 =E0 15:30 -0700, John Fastabend a =E9crit :
>>>
>>>> There is always a possibility that the underlying device sets the
>>>> queue_mapping to be greater then num_cpus.  Also I suspect the sam=
e
>>>> issue exists with bonding devices.  Maybe something like the follo=
wing
>>>> is worth while? compile tested only,
>>>>
>>>> [PATCH] 8021q: vlan reassigns dev without check queue_mapping
>>>>
>>>> recv path reassigns skb->dev without sanity checking the
>>>> queue_mapping field.  This can result in the queue_mapping
>>>> field being set incorrectly if the new dev supports less
>>>> queues then the underlying device.
>>>>
>>>> This patch just resets the queue_mapping to 0 which should
>>>> resolve this issue?  Any thoughts?
>>>>
>>>> The same issue could happen on bonding devices as well.
>>>>
>>>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
>>>> ---
>>>>
>>>>    net/8021q/vlan_core.c |    6 ++++++
>>>>    1 files changed, 6 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>>>> index bd537fc..ad309f8 100644
>>>> --- a/net/8021q/vlan_core.c
>>>> +++ b/net/8021q/vlan_core.c
>>>> @@ -21,6 +21,9 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struc=
t
>>>> vlan_group *grp,
>>>>        if (!skb->dev)
>>>>                goto drop;
>>>>
>>>> +     if (unlikely(skb->queue_mapping>=3D skb->dev->real_num_tx_qu=
eues))
>>>> +             skb_set_queue_mapping(skb, 0);
>>>> +
>>>>        return (polling ? netif_receive_skb(skb) : netif_rx(skb));
>>>>
>>>>    drop:
>>>> @@ -93,6 +96,9 @@ vlan_gro_common(struct napi_struct *napi, struct
>>>> vlan_group *grp,
>>>>        if (!skb->dev)
>>>>                goto drop;
>>>>
>>>> +     if (unlikely(skb->queue_mapping>=3D skb->dev->real_num_tx_qu=
eues))
>>>> +             skb_set_queue_mapping(skb, 0);
>>>> +
>>>>        for (p =3D napi->gro_list; p; p =3D p->next) {
>>>>                NAPI_GRO_CB(p)->same_flow =3D
>>>>                        p->dev =3D=3D skb->dev&&  !compare_ether_he=
ader(
>>>> --
>>> Only a workaround, added in hot path in a otherwise 'good' driver
>>> (multiqueue enabled and ready)

Agreed thanks!

>>>
>>> eth0  ------->  bond / bridge --------->  vlan.id
>>> (nbtxq=3D8)      (ntxbq=3D1)        (nbtxq=3DX)
>>>
>>> X is capped to 1 because of bond/bridge, while bond has no "queue"
>>> (LLTX driver)
>>>
>>> Solutions :
>>>
>>> 1) queue_mapping could be silently tested in get_rps_cpu()...
>>>
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 6f330ce..3a3f7f6 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -2272,14 +2272,11 @@ static int get_rps_cpu(struct net_device *d=
ev, struct sk_buff *skb,
>>>
>>>         if (skb_rx_queue_recorded(skb)) {
>>>                 u16 index =3D skb_get_rx_queue(skb);
>>> -               if (unlikely(index>=3D dev->num_rx_queues)) {
>>> -                       if (net_ratelimit()) {
>>> -                               pr_warning("%s received packet on q=
ueue "
>>> -                                       "%u, but number of RX queue=
s is %u\n",
>>> -                                       dev->name, index, dev->num_=
rx_queues);
>>> -                       }
>>> -                       goto done;
>>> -               }
>>> +               if (WARN_ONCE(index>=3D dev->num_rx_queues,
>>> +                               KERN_WARNING "%s received packet on=
 queue %u, "
>>> +                               "but number of RX queues is %u\n",
>>> +                               dev->name, index, dev->num_rx_queue=
s))
>>> +                       index %=3D dev->num_rx_queues;
>>>                 rxqueue =3D dev->_rx + index;
>>>         } else
>>>                 rxqueue =3D dev->_rx;
>>>
>>>

Looks good to me.

>>>
>>> 2) bond/bridge should setup more queues, just in case.
>>>    We probably need to be able to make things more dynamic,
>>>    (propagate nbtxq between layers) but not for 2.6.35
>>>
>>>

The bonding driver is already multiq per Andy Gospodarek's patch commit=
 bb1d912,=20
but unless the bond and bridge devices use the max num_rx_queues of the=
re=20
underlying devices this could still go wrong.

The bonding driver would possibly need to increase num_rx_queues and=20
num_tx_queues when a device is enslaved or be set to some maximum at in=
it for=20
this to work right.

>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/=
bond_main.c
>>> index 5e12462..ce813dd 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -5012,8 +5012,8 @@ int bond_create(struct net *net, const char *=
name)
>>>
>>>         rtnl_lock();
>>>
>>> -       bond_dev =3D alloc_netdev(sizeof(struct bonding), name ? na=
me : "",
>>> -                               bond_setup);
>>> +       bond_dev =3D alloc_netdev_mq(sizeof(struct bonding), name ?=
 name : "",
>>> +                                  bond_setup, max(64, nr_cpu_ids))=
;
>>>         if (!bond_dev) {
>>>                 pr_err("%s: eek! can't alloc netdev!\n", name);
>>>                 rtnl_unlock();
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> Huh, so you guys are looking at the same issue (only my issue is RPS)=
=2E=20
> See http://marc.info/?l=3Dlinux-netdev&m=3D127603240621028&w=3D2. I'm=
 in favor=20
> of dropping the warning when no queues have been allocated.
>=20
> How about this (see attached).

Prefer Eric's patch see first comment.

Thanks,
John

>=20
> rtg
>=20
>=20

