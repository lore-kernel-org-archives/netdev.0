From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: how to mix bridges and bonding inc. vlans correctly on Kernel > 3.10
Date: Wed, 13 Nov 2013 17:43:27 +0100
Message-ID: <09CA67A8-FB72-419F-BCE7-9E68842E8BCE@profihost.ag>
References: <52838590.5070806@profihost.ag> <20131113141244.GM19702@redhat.com> <52838AC8.8070005@profihost.ag> <52839540.6020908@gmail.com> <5283980D.7020508@profihost.ag> <20131113162136.GP19702@redhat.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:44274 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881Ab3KMQn3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 11:43:29 -0500
In-Reply-To: <20131113162136.GP19702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Am 13.11.2013 um 17:21 schrieb Veaceslav Falico <vfalico@redhat.com>:
> 
>> On Wed, Nov 13, 2013 at 04:17:33PM +0100, Stefan Priebe - Profihost AG wrote:
>> Am 13.11.2013 16:05, schrieb Vlad Yasevich:
>>> On 11/13/2013 09:20 AM, Stefan Priebe - Profihost AG wrote:
>>>> Hi Falico,
>>>> Am 13.11.2013 15:12, schrieb Veaceslav Falico:
>>>>> On Wed, Nov 13, 2013 at 02:58:40PM +0100, Stefan Priebe - Profihost AG
>>>>> wrote:
>>>>>> Hello,
>>>>>> 
>>>>>> while my vlans, bridging and bonding stuff was working until 3.9 i
>>>>>> never
>>>>>> thought about how it is right. So maybe i was always wrong.
>>>>>> 
>>>>>> I've this:
>>>>>> 
>>>>>> eth2
>>>>>>     \
>>>>>>      -- bond1 -- vmbr1
>>>>>>     /
>>>>>> eth3
>>>>>> 
>>>>>> This works fine and as expected now i want to have a vlan using the
>>>>>> bonding and using a bridge.
>>>>>> 
>>>>>> I the past i had this:
>>>>>> eth2
>>>>>>     \
>>>>>>      -- bond1 -- vmbr1
>>>>>>     /              \
>>>>>> eth3                 \ vmbr1.3000
>>>>>>                           \ ---- tap114i1
>>>>>> 
>>>>>> This was working fine until 3.9.X since 3.10. Right now using 3.10 i
>>>>>> need to put eth2 and eth3 into promisc mode to get it working ;-( this
>>>>>> is bad!
>>>>> 
>>>>> As a guess - do you use arp monitoring for bonding? Try using miimon -
>>>>> there were some issues with it in 3.10, which were fixed by some huge
>>>>> patchsets that will never hit 3.10 stable.
>>>>> Also, the bonding configuration would be welcome.
>>>> 
>>>> Debian Bonding konfiguration looks like this:
>>>> auto bond1
>>>> iface bond1 inet manual
>>>>         slaves eth2 eth3
>>>>         bond-mode 802.3ad
>>>>         bond_miimon 100
>>>>         bond_updelay 200
>>>>         bond_downdelay 0
>>>> 
>>>> This should be miimon using lacp and not arp isn't it?
>>>> Anything more needed?
>>> 
>>> Hmm..  With 802.3ad mode, when the bond is a port on the bridge, the
>>> bond should place all of its ports into promiscuous mode.  Do you see
>>> the the kernel messages that say that?
>> 
>> No it does not - i only see:
>> # dmesg -c|egrep "promiscuous|forward"
>> [    5.445161] device bond0 entered promiscuous mode
>> [    7.670701] device bond1 entered promiscuous mode
>> [    7.845472] vmbr0: port 1(bond0) entered forwarding state
>> [    7.845474] vmbr0: port 1(bond0) entered forwarding state
>> [    8.269769] vmbr1: port 1(bond1) entered forwarding state
>> [    8.269771] vmbr1: port 1(bond1) entered forwarding state
>> 
>> Now adding variant 1:
>> # dmesg -c|egrep "promiscuous|forward"
>> [   85.919382] device tap113i0 entered promiscuous mode
>> [   85.965018] vmbr0: port 2(tap113i0) entered forwarding state
>> [   85.965023] vmbr0: port 2(tap113i0) entered forwarding state
>> [   86.263292] device tap113i1 entered promiscuous mode
>> [   86.314151] device vmbr1.3000 entered promiscuous mode
>> [   86.314153] device vmbr1 entered promiscuous mode
>> [   86.314192] vmbr1v3000: port 1(vmbr1.3000) entered forwarding state
>> [   86.314196] vmbr1v3000: port 1(vmbr1.3000) entered forwarding state
>> [   86.318116] vmbr1v3000: port 2(tap113i1) entered forwarding state
>> [   86.318120] vmbr1v3000: port 2(tap113i1) entered forwarding state
>> [  101.382129] vmbr1v3000: port 1(vmbr1.3000) entered forwarding state
>> 
>> Now it looks like this:
>> # ip a l|grep PROMISC
>> 13: tap113i0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc
>> htb master vmbr0 state UNKNOWN qlen 500
>> 14: tap113i1: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc
>> htb master vmbr1v3000 state UNKNOWN qlen 500
> 
> eth* should get into forwarding mode cause bond0 is a port of the bridge
> and should propagate its state towards its slaves. Something is wrong here.
> 
> Maybe we're looking at the wrong direction - and the promisc for the
> ethernet drivers got broken?
> 
> What ethernet cards/driver do you use for eth*?

intel igb

> 
>> 
>> Greets,
>> Stefan
>> 
>> 
>> Main question is - is this one correct:
> 
> Both are correct. Here's my setup (sorry for stretching):
> 
> +---------------+           +------------+              +-------------+           +---------+           +------+
> |     bond1     |           |            |              |   bridge0   |           |         |           |      |
> |  192.168.2.1  |  master   | bridge0.15 |  neighbour   | 192.168.3.1 |  master   |  bond0  |  master   | eth2 |
> |               | --------> |            | ------------ | 192.168.4.1 | --------> |         | --------> |      |
> +---------------+           +------------+              +-------------+           +---------+           +------+
>                                                                                    |
>                                                                                    | master
>                                                                                    v
> +---------------+                                                                 +---------+
> |    dummy0     |                                                                 |  eth0   |
> +---------------+                                                                 +---------+
> 
> (disregard that dummy0).
> 
> All 192.168.X.1 ips are pingable (via the correct vlans) on both net-next and stable 3.10.19.
> 
>>>>>> eth2
>>>>>>     \
>>>>>>      -- bond1 -- vmbr1
>>>>>>     /              \
>>>>>> eth3                 \ vmbr1.3000
>>>>>>                           \ ---- tap114i1
>> 
>> <= does not work at all
>> 
>> or this one?:
>>>>>> eth2
>>>>>>     \
>>>>>>      -- bond1 -- vmbr1
>>>>>>     /     \
>>>>>> eth3        ----- bond1.3000 --- vmbr1v3000
>>>>>>                                     \ ---- tap114i1
>> 
>> <= works if i manually put eth2 and eth3 into promiscous mode.
>> 
>>> -vlad
>>> 
>>>> One thing i forgot the one with vmbr1.3000 does not work at all eben not
>>>> with promisc mode. The one below works fine if i set eth2 and eth3 into
>>>> promisc mode.
>>>> 
>>>> Stefan
>>>> 
>>>>>> I also tried this one without success:
>>>>>> eth2
>>>>>>     \
>>>>>>      -- bond1 -- vmbr1
>>>>>>     /     \
>>>>>> eth3        ----- bond1.3000 --- vmbr1v3000
>>>>>>                                     \ ---- tap114i1
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> Greets,
>>>>>> Stefan
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
