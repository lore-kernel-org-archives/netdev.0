From: Tom Herbert <therbert@google.com>
Subject: Re: RFS seems to have incompatiblities with bridged vlans
Date: Tue, 8 Jun 2010 16:00:58 -0700
Message-ID: <AANLkTiluIibUglhf28JAeSLzBC0E1Zw0STPoqFTbXcev@mail.gmail.com>
References: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>
	<20100607145910.2458ac87@nehalam>
	<4C0D7312.1020300@intel.com>
	<1276006721.2486.141.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Peter Lieven <pl@dlh.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:11031 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533Ab0FHXBC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 19:01:02 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o58N10Iu010318
	for <netdev@vger.kernel.org>; Tue, 8 Jun 2010 16:01:00 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by kpbe18.cbf.corp.google.com with ESMTP id o58N0wQw007027
	for <netdev@vger.kernel.org>; Tue, 8 Jun 2010 16:00:59 -0700
Received: by pxi6 with SMTP id 6so2320556pxi.1
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 16:00:58 -0700 (PDT)
In-Reply-To: <1276006721.2486.141.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How about only checking against dev->num_rx_queues when that value is
greater than one.  Since bonding device is calling alloc_netdev, it is
not going to set the queue mapping, but dev->num_rx_queues will be one
in that case (this handles any intermediate driver that does do
multiple queues).

diff --git a/net/core/dev.c b/net/core/dev.c
index 6f330ce..30ab66d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2270,7 +2270,7 @@ static int get_rps_cpu(struct net_device *dev,
struct sk_buff *skb,
                u16 v16[2];
        } ports;

-       if (skb_rx_queue_recorded(skb)) {
+       if (skb_rx_queue_recorded(skb) && dev->num_rx_queues > 1) {
                u16 index =3D skb_get_rx_queue(skb);
                if (unlikely(index >=3D dev->num_rx_queues)) {
                        if (net_ratelimit()) {


On Tue, Jun 8, 2010 at 7:18 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le lundi 07 juin 2010 =E0 15:30 -0700, John Fastabend a =E9crit :
>
>> There is always a possibility that the underlying device sets the
>> queue_mapping to be greater then num_cpus. =A0Also I suspect the sam=
e
>> issue exists with bonding devices. =A0Maybe something like the follo=
wing
>> is worth while? compile tested only,
>>
>> [PATCH] 8021q: vlan reassigns dev without check queue_mapping
>>
>> recv path reassigns skb->dev without sanity checking the
>> queue_mapping field. =A0This can result in the queue_mapping
>> field being set incorrectly if the new dev supports less
>> queues then the underlying device.
>>
>> This patch just resets the queue_mapping to 0 which should
>> resolve this issue? =A0Any thoughts?
>>
>> The same issue could happen on bonding devices as well.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>
>> =A0 net/8021q/vlan_core.c | =A0 =A06 ++++++
>> =A0 1 files changed, 6 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>> index bd537fc..ad309f8 100644
>> --- a/net/8021q/vlan_core.c
>> +++ b/net/8021q/vlan_core.c
>> @@ -21,6 +21,9 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct
>> vlan_group *grp,
>> =A0 =A0 =A0 if (!skb->dev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>>
>> + =A0 =A0 if (unlikely(skb->queue_mapping >=3D skb->dev->real_num_tx=
_queues))
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb_set_queue_mapping(skb, 0);
>> +
>> =A0 =A0 =A0 return (polling ? netif_receive_skb(skb) : netif_rx(skb)=
);
>>
>> =A0 drop:
>> @@ -93,6 +96,9 @@ vlan_gro_common(struct napi_struct *napi, struct
>> vlan_group *grp,
>> =A0 =A0 =A0 if (!skb->dev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>>
>> + =A0 =A0 if (unlikely(skb->queue_mapping >=3D skb->dev->real_num_tx=
_queues))
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb_set_queue_mapping(skb, 0);
>> +
>> =A0 =A0 =A0 for (p =3D napi->gro_list; p; p =3D p->next) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 NAPI_GRO_CB(p)->same_flow =3D
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->dev =3D=3D skb->dev &=
& !compare_ether_header(
>> --
>
> Only a workaround, added in hot path in a otherwise 'good' driver
> (multiqueue enabled and ready)
>
> eth0 =A0-------> bond / bridge ---------> vlan.id
> (nbtxq=3D8) =A0 =A0 =A0(ntxbq=3D1) =A0 =A0 =A0 =A0(nbtxq=3DX)
>
> X is capped to 1 because of bond/bridge, while bond has no "queue"
> (LLTX driver)
>
> Solutions :
>
> 1) queue_mapping could be silently tested in get_rps_cpu()...
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6f330ce..3a3f7f6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2272,14 +2272,11 @@ static int get_rps_cpu(struct net_device *dev=
, struct sk_buff *skb,
>
> =A0 =A0 =A0 =A0if (skb_rx_queue_recorded(skb)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u16 index =3D skb_get_rx_queue(skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(index >=3D dev->num_rx_que=
ues)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (net_ratelimit()) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warn=
ing("%s received packet on queue "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "%u, but number of RX queues is %u\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 dev->name, index, dev->num_rx_queues);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (WARN_ONCE(index >=3D dev->num_rx_qu=
eues,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 KERN_WA=
RNING "%s received packet on queue %u, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "but nu=
mber of RX queues is %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->na=
me, index, dev->num_rx_queues))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 index %=3D dev->num_rx_=
queues;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rxqueue =3D dev->_rx + index;
> =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rxqueue =3D dev->_rx;
>
>
>
> 2) bond/bridge should setup more queues, just in case.
> =A0 We probably need to be able to make things more dynamic,
> =A0 (propagate nbtxq between layers) but not for 2.6.35
>
>
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 5e12462..ce813dd 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -5012,8 +5012,8 @@ int bond_create(struct net *net, const char *na=
me)
>
> =A0 =A0 =A0 =A0rtnl_lock();
>
> - =A0 =A0 =A0 bond_dev =3D alloc_netdev(sizeof(struct bonding), name =
? name : "",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond_se=
tup);
> + =A0 =A0 =A0 bond_dev =3D alloc_netdev_mq(sizeof(struct bonding), na=
me ? name : "",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
bond_setup, max(64, nr_cpu_ids));
> =A0 =A0 =A0 =A0if (!bond_dev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("%s: eek! can't alloc netdev!\n=
", name);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rtnl_unlock();
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
