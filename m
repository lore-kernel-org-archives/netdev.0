From: Tom Herbert <therbert@google.com>
Subject: Re: RFS seems to have incompatiblities with bridged vlans
Date: Tue, 8 Jun 2010 18:52:37 -0700
Message-ID: <AANLkTilIzRt94SiNlcAbI6tFx2-V3XcnhWtlIG8pXIGG@mail.gmail.com>
References: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>
	<20100607145910.2458ac87@nehalam>
	<4C0D7312.1020300@intel.com>
	<1276006721.2486.141.camel@edumazet-laptop>
	<AANLkTiluIibUglhf28JAeSLzBC0E1Zw0STPoqFTbXcev@mail.gmail.com>
	<4C0ED931.6030402@canonical.com>
	<4C0EE99B.8030300@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "tim.gardner@canonical.com" <tim.gardner@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Peter Lieven <pl@dlh.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:3513 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab0FIBwl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 21:52:41 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o591qdWp021531
	for <netdev@vger.kernel.org>; Tue, 8 Jun 2010 18:52:39 -0700
Received: from pvg11 (pvg11.prod.google.com [10.241.210.139])
	by wpaz29.hot.corp.google.com with ESMTP id o591qc03003048
	for <netdev@vger.kernel.org>; Tue, 8 Jun 2010 18:52:38 -0700
Received: by pvg11 with SMTP id 11so2035151pvg.36
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 18:52:37 -0700 (PDT)
In-Reply-To: <4C0EE99B.8030300@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Problem with this is it doesn't address mis-aligned num_rx_queues. =A0=
=46or
> example with the bonding driver defaulting to 16 queues now. We could=
 end up
> with a base driver with 16+ queues and a bond with 16. =A0Then we hav=
e the
> same issue again.
>
> =A0eth0 =A0-------> bond / bridge ---------> vlan.id
> (nbrxq=3D64) =A0 =A0 =A0(nbrxq=3D16) =A0 =A0 =A0 =A0 =A0 =A0 =A0(nbrx=
q=3DX)
>

I don't think the intent is to solve this alignment problem here.  If
a driver allocates multiple queues, it should set the queue mapping
accordingly.  If this isn't the case, the meaning of queue mapping is
ambiguous (which driver is it relative to?), and using the value for
rps_cpus is probably not going to work well-- hacking the
queue-mapping to be a legal value in get_rps_cpus doesn't seem like
the right answer.

>>>
>>> On Tue, Jun 8, 2010 at 7:18 AM, Eric Dumazet<eric.dumazet@gmail.com=
>
>>> =A0wrote:
>>>>
>>>> Le lundi 07 juin 2010 =E0 15:30 -0700, John Fastabend a =E9crit :
>>>>
>>>>> There is always a possibility that the underlying device sets the
>>>>> queue_mapping to be greater then num_cpus. =A0Also I suspect the =
same
>>>>> issue exists with bonding devices. =A0Maybe something like the fo=
llowing
>>>>> is worth while? compile tested only,
>>>>>
>>>>> [PATCH] 8021q: vlan reassigns dev without check queue_mapping
>>>>>
>>>>> recv path reassigns skb->dev without sanity checking the
>>>>> queue_mapping field. =A0This can result in the queue_mapping
>>>>> field being set incorrectly if the new dev supports less
>>>>> queues then the underlying device.
>>>>>
>>>>> This patch just resets the queue_mapping to 0 which should
>>>>> resolve this issue? =A0Any thoughts?
>>>>>
>>>>> The same issue could happen on bonding devices as well.
>>>>>
>>>>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
>>>>> ---
>>>>>
>>>>> =A0 net/8021q/vlan_core.c | =A0 =A06 ++++++
>>>>> =A0 1 files changed, 6 insertions(+), 0 deletions(-)
>>>>>
>>>>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>>>>> index bd537fc..ad309f8 100644
>>>>> --- a/net/8021q/vlan_core.c
>>>>> +++ b/net/8021q/vlan_core.c
>>>>> @@ -21,6 +21,9 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, stru=
ct
>>>>> vlan_group *grp,
>>>>> =A0 =A0 =A0 if (!skb->dev)
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>>>>>
>>>>> + =A0 =A0 if (unlikely(skb->queue_mapping>=3D skb->dev->real_num_=
tx_queues))
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 skb_set_queue_mapping(skb, 0);
>>>>> +
>>>>> =A0 =A0 =A0 return (polling ? netif_receive_skb(skb) : netif_rx(s=
kb));
>>>>>
>>>>> =A0 drop:
>>>>> @@ -93,6 +96,9 @@ vlan_gro_common(struct napi_struct *napi, struc=
t
>>>>> vlan_group *grp,
>>>>> =A0 =A0 =A0 if (!skb->dev)
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>>>>>
>>>>> + =A0 =A0 if (unlikely(skb->queue_mapping>=3D skb->dev->real_num_=
tx_queues))
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 skb_set_queue_mapping(skb, 0);
>>>>> +
>>>>> =A0 =A0 =A0 for (p =3D napi->gro_list; p; p =3D p->next) {
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 NAPI_GRO_CB(p)->same_flow =3D
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->dev =3D=3D skb->de=
v&& =A0!compare_ether_header(
>>>>> --
>>>>
>>>> Only a workaround, added in hot path in a otherwise 'good' driver
>>>> (multiqueue enabled and ready)
>
> Agreed thanks!
>
>>>>
>>>> eth0 =A0-------> =A0bond / bridge ---------> =A0vlan.id
>>>> (nbtxq=3D8) =A0 =A0 =A0(ntxbq=3D1) =A0 =A0 =A0 =A0(nbtxq=3DX)
>>>>
>>>> X is capped to 1 because of bond/bridge, while bond has no "queue"
>>>> (LLTX driver)
>>>>
>>>> Solutions :
>>>>
>>>> 1) queue_mapping could be silently tested in get_rps_cpu()...
>>>>
>>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>>> index 6f330ce..3a3f7f6 100644
>>>> --- a/net/core/dev.c
>>>> +++ b/net/core/dev.c
>>>> @@ -2272,14 +2272,11 @@ static int get_rps_cpu(struct net_device *=
dev,
>>>> struct sk_buff *skb,
>>>>
>>>> =A0 =A0 =A0 =A0if (skb_rx_queue_recorded(skb)) {
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u16 index =3D skb_get_rx_queue(skb)=
;
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(index>=3D dev->num_rx_q=
ueues)) {
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (net_ratelimit())=
 {
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_w=
arning("%s received packet on queue
>>>> "
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 "%u, but number of RX queues is
>>>> %u\n",
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 dev->name, index,
>>>> dev->num_rx_queues);
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (WARN_ONCE(index>=3D dev->num_rx_=
queues,
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 KERN=
_WARNING "%s received packet on
>>>> queue %u, "
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "but=
 number of RX queues is %u\n",
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev-=
>name, index, dev->num_rx_queues))
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 index %=3D dev->num_=
rx_queues;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rxqueue =3D dev->_rx + index;
>>>> =A0 =A0 =A0 =A0} else
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rxqueue =3D dev->_rx;
>>>>
>>>>
>
> Looks good to me.
>
>>>>
>>>> 2) bond/bridge should setup more queues, just in case.
>>>> =A0 We probably need to be able to make things more dynamic,
>>>> =A0 (propagate nbtxq between layers) but not for 2.6.35
>>>>
>>>>
>
> The bonding driver is already multiq per Andy Gospodarek's patch comm=
it
> bb1d912, but unless the bond and bridge devices use the max num_rx_qu=
eues of
> there underlying devices this could still go wrong.
>
> The bonding driver would possibly need to increase num_rx_queues and
> num_tx_queues when a device is enslaved or be set to some maximum at =
init
> for this to work right.
>
>>>>
>>>> diff --git a/drivers/net/bonding/bond_main.c
>>>> b/drivers/net/bonding/bond_main.c
>>>> index 5e12462..ce813dd 100644
>>>> --- a/drivers/net/bonding/bond_main.c
>>>> +++ b/drivers/net/bonding/bond_main.c
>>>> @@ -5012,8 +5012,8 @@ int bond_create(struct net *net, const char =
*name)
>>>>
>>>> =A0 =A0 =A0 =A0rtnl_lock();
>>>>
>>>> - =A0 =A0 =A0 bond_dev =3D alloc_netdev(sizeof(struct bonding), na=
me ? name :
>>>> "",
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond=
_setup);
>>>> + =A0 =A0 =A0 bond_dev =3D alloc_netdev_mq(sizeof(struct bonding),=
 name ? name :
>>>> "",
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0bond_setup, max(64, nr_cpu_ids));
>>>> =A0 =A0 =A0 =A0if (!bond_dev) {
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("%s: eek! can't alloc netdev=
!\n", name);
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rtnl_unlock();
>>>>
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>
>> Huh, so you guys are looking at the same issue (only my issue is RPS=
). See
>> http://marc.info/?l=3Dlinux-netdev&m=3D127603240621028&w=3D2. I'm in=
 favor of
>> dropping the warning when no queues have been allocated.
>>
>> How about this (see attached).
>
> Prefer Eric's patch see first comment.
>
> Thanks,
> John
>
>>
>> rtg
>>
>>
>
>
