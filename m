From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on dummy
Date: Tue, 01 Mar 2011 14:29:12 +0100
Message-ID: <4D6CF4A8.6000205@free.fr>
References: <20110221150710.GA5651@nord.niifaq.ru>	 <4D6282DB.2080204@free.fr> <20110221153421.GA6602@nord.niifaq.ru>	 <4D628DC3.9000400@free.fr> <20110223170512.GA10277@nord.niifaq.ru>	 <4D6A6A5F.4030707@free.fr> <1298836236.8726.109.camel@edumazet-laptop>	 <4D6AB578.3010704@free.fr> <1298879114.8726.131.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrian Nord <nightnord@gmail.com>,
	lxc-users@lists.sourceforge.net, Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:41228 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808Ab1CAN30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 08:29:26 -0500
In-Reply-To: <1298879114.8726.131.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2011 08:45 AM, Eric Dumazet wrote:
> Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 21:35 +0100, Daniel Lezcano a=
 =C3=A9crit :
>> On 02/27/2011 08:50 PM, Eric Dumazet wrote:
>>> Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 16:14 +0100, Daniel Lezcano=
 a =C3=A9crit :
>>>> On 02/23/2011 06:13 PM, Andrian Nord wrote:
>>>>> On Mon, Feb 21, 2011 at 05:07:31PM +0100, Daniel Lezcano wrote:
>>>>>> I Cc'ed the netdev mailing list and Patrick in case my analysis =
is wrong
>>>>>> or incomplete.
>>>>> I'm confirming, that this happens only when macvlan's are onto du=
mmy net
>>>>> device. In case of some physical interface under macvlan there is=
 no lost
>>>>> packages and no broken checksums.
>>>> I did some tests with a 2.6.35 kernel version and it seems the che=
cksum
>>>> errors do not appear.
>>>> I noticed there are some changes in the dummy setup function:
>>>>
>>>>      dev->features   |=3D NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_=
TSO;
>>>>      dev->features   |=3D NETIF_F_NO_CSUM | NETIF_F_HIGHDMA | NETI=
=46_F_LLTX;
>>>>
>>>>
>>>> May be that was introduced by commit:
>>>>
>>>> commit 6d81f41c58c69ddde497e9e640ba5805aa26e78c
>>>> Author: Eric Dumazet<eric.dumazet@gmail.com>
>>>> Date:   Mon Sep 27 20:50:33 2010 +0000
>>>>
>>>>        dummy: percpu stats and lockless xmit
>>>>
>>>>        Converts dummy network device driver to :
>>>>
>>>>        - percpu stats
>>>>
>>>>        - 64bit stats
>>>>
>>>>        - lockless xmit (NETIF_F_LLTX)
>>>>
>>>>        - performance features added (NETIF_F_SG | NETIF_F_FRAGLIST=
 |
>>>>        NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA)
>>>>
>>>>        Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
>>>>        Signed-off-by: David S. Miller<davem@davemloft.net>
>>>>
>>>>
>>>> Eric,
>>>>
>>>> Andrian is observing, with a couple of macvlan (in bridge mode) on=
 top
>>>> of a dummy interface, a lot of checksums error and packets drop.
>>>> Each macvlan is in a different network namespace and the dummy int=
erface
>>>> is in the init_net.
>>>>
>>>> Any ideas ?
>>> Not sure I understand... I thought dummy was dropping all frames
>>> anyway ?
>>>
>>> static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_devic=
e *dev)
>>> {
>>>           struct pcpu_dstats *dstats =3D this_cpu_ptr(dev->dstats);
>>>
>>>           u64_stats_update_begin(&dstats->syncp);
>>>           dstats->tx_packets++;
>>>           dstats->tx_bytes +=3D skb->len;
>>>           u64_stats_update_end(&dstats->syncp);
>>>
>>>           dev_kfree_skb(skb);
>>>           return NETDEV_TX_OK;
>>> }
>>>
>>>
>>> Maybe you could describe the setup ?
>> Yes, it is very simple.
>>
>> There are two network namespaces.
>>
>> macvlan1 is in network namespace 1
>> macvlan2 is in network namespace 2
>>
>> Both are in "bridge" mode, so they can communicate together.
>> The lower device is dummy0 in the init network namespace.
>>
>> IMO the problem is coming from the macvlan driver:
>>
>> dev->features           =3D lowerdev->features&  MACVLAN_FEATURES
>>
>> As dummy0 has the offloading capabilities set on, the macvlan driver
>> inherit these features.
>>
>> In the normal case, dummy0 is supposed to drop the packets. But with
>> macvlan these packets are broadcasted to the other macvlan ports, so=
 no
>> checksum is computed when the packets are transmitted between macvla=
n1
>> and macvlan2.
> So where frames get bad checksums ?
>
> In this "bridge" mode, I suspect the broadcast is done _before_ sendi=
ng
> frame to dummy, so maybe macvlan should not inherit from lowerdev in
> this particular case ?

Hi Eric,

yes, you are right, the packets are sent before.

In the 'macvlan_queue_xmit', the code checks the dev is in 'bridge'=20
mode. If so, it looks if there is a destination port for the packet and=
=20
then calls the 'forward' callback which is 'dev_forward_skb'.

I was able to reproduce the same problem with qemu and an emulated=20
'e1000' card instead of dummy0. The packets are dropped too.

Patrick, do you have any suggestions to fix this ?

Thanks
   -- Daniel


