From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave	instead
 of master
Date: Tue, 08 Mar 2011 00:09:48 +0100
Message-ID: <4D7565BC.4050201@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com> <4D737D00.20406@gmail.com> <20110306133413.GB2795@psychotron.redhat.com> <20110307125059.GA6053@psychotron.brq.redhat.com> <20110307224338.GU11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40182 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756385Ab1CGXJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 18:09:50 -0500
Received: by wyg36 with SMTP id 36so4705726wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 15:09:49 -0800 (PST)
In-Reply-To: <20110307224338.GU11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/03/2011 23:43, Andy Gospodarek a =E9crit :
> On Mon, Mar 07, 2011 at 01:51:00PM +0100, Jiri Pirko wrote:
>> Recent patch "bonding: move processing of recv handlers into
>> handle_frame()" caused a regression on following net scheme:
>>
>> eth0 - bond0 - bond0.5
>>
>> where arp monitoring is happening over vlan. This patch fixes it by
>> reinjecting the arp packet into bonding slave device so the bonding
>> rx_handler can pickup and process it.
>>
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>> ---
>>   net/core/dev.c |    8 ++++----
>>   1 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index c71bd18..3d88458 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3094,12 +3094,12 @@ void netdev_rx_handler_unregister(struct net=
_device *dev)
>>   }
>>   EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
>>
>> -static void vlan_on_bond_hook(struct sk_buff *skb)
>> +static void vlan_on_bond_hook(struct sk_buff *skb, struct net_devic=
e *orig_dev)
>>   {
>>   	/*
>>   	 * Make sure ARP frames received on VLAN interfaces stacked on
>>   	 * bonding interfaces still make their way to any base bonding
>> -	 * device that may have registered for a specific ptype.
>> +	 * device by reinjecting the frame into bonding slave (orig_dev)
>>   	 */
>>   	if (skb->dev->priv_flags&  IFF_802_1Q_VLAN&&
>>   	vlan_dev_real_dev(skb->dev)->priv_flags&  IFF_BONDING&&
>> @@ -3108,7 +3108,7 @@ static void vlan_on_bond_hook(struct sk_buff *=
skb)
>>
>>   		if (!skb2)
>>   			return;
>> -		skb2->dev =3D vlan_dev_real_dev(skb->dev);
>> +		skb2->dev =3D orig_dev;
>>   		netif_rx(skb2);
>>   	}
>>   }
>> @@ -3202,7 +3202,7 @@ ncls:
>>   			goto out;
>>   	}
>>
>> -	vlan_on_bond_hook(skb);
>> +	vlan_on_bond_hook(skb, orig_dev);
>>
>>   	/* deliver only exact match when indicated */
>>   	null_or_dev =3D deliver_exact ? skb->dev : NULL;
>
> This patch doesn't work.
>
> My setup has bond0.100 ->  bond0 ->  eth2 and eth3.  ARP monitoring i=
s
> enabled as is arp_valiate.
>
> The initial problem was just that just before vlan_on_bond_hook is
> called, skb->dev =3D bond0.100 and orig_dev =3D eth2.   (This is afte=
r
> running goto another_route and having been called back through
> __netif_receive_skb since vlan_hwaccel_do_receive it true.)
>
> Now vlan_on_bond_hook is called and we have 2 skbs.
>
> The original skb still have skb->dev =3D bond0.100 and orig_dev =3D e=
th2.
> Since bond_arp_rcv is registered for traffic only to bond0, the handl=
er
> is not hit and the frame is dropped (or processed by another handler)=
=2E

After Jiri's last patch series, bond_arp_rcv() is not registered anymor=
e as a protocol handler on=20
bond0, but directly called from inside bond_handle_frame(), through bon=
d->recv_probe.

Because bond_handler_frame() is a rx_handler for the slave interfaces, =
bond_arp_rcv() is now called=20
at the slave level and not a the master level anymore.

Hence this patch and the reason I thought it should work.

Did you tested this patch with Jiri's previous patches applied before?

> The cloned skb has skb->dev =3D bond0 and is put back on the receive =
queue
> and comes back through __netif_receive_skb.  This frame will match th=
e
> ptype entry for bond_arp_rcv, but since orig_dev =3D bond0 in this ca=
se,
> the code in bond_arp_rcv will not handle the frame.

I definitely hate all those unnecessary reinjects from rx_handler. The =
another_round loop is=20
designed to allow for stacking inside __netif_receive_skb().

Jiri apparently has another (better) solution in mind. I hope to see it=
, but Jiri arguably want some=20
of the patchs in the queue to flow before adding more.

Does someone had a look at my proposal of a late_delivery property for =
packet_type, previously in=20
this thread, to handle the situation where a given protocol handler reg=
istered on a particular=20
device would like to receive the final skb instead of the one at the ti=
me it crossed that particular=20
device?

>
> If we truly want to track the original interface that received the
> frame, the following is a better option.  With the recursive nature o=
f
> __netif_receive_skb at this point, we should really consider setting
> orig_dev from skb_iif rather than just from skb->dev.

Or we can remove all this orig_dev stuff...

	Nicolas.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 30440e7..500fdbc 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3135,7 +3135,6 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>
>   	if (!skb->skb_iif)
>   		skb->skb_iif =3D skb->dev->ifindex;
> -	orig_dev =3D skb->dev;
>
>   	skb_reset_network_header(skb);
>   	skb_reset_transport_header(skb);
> @@ -3145,6 +3144,7 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>
>   	rcu_read_lock();
>
> +	orig_dev =3D dev_get_by_index_rcu(dev_net(skb->dev),skb->skb_iif);
>   another_round:
>
>   	__this_cpu_inc(softnet_data.processed);
>
>

