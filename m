From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Sun, 21 Dec 2014 11:52:47 -0800
Message-ID: <5497250F.2020906@gmail.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <5496D8E2.1090700@mojatatu.com> <54971A93.6050700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:38046 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbaLUTxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 14:53:03 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so18768041obc.11
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 11:53:02 -0800 (PST)
In-Reply-To: <54971A93.6050700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2014 11:08 AM, Roopa Prabhu wrote:
> On 12/21/14, 6:27 AM, Jamal Hadi Salim wrote:
>>
>> Sorry for the latency, Ive been down with a bad flu (its bad when i cant
>> type on my keyboard sitting infront of me;->),  recovering and the
>> thread seems to have caught on - should be able to catchup in the
>> next few days.
>> I am beginning to reach a conclusion that the current switchdev approach
>> is *not* going to work for SRIOV. I also worry it may be too late
>> to change that.
>> Shrijeet wanted to set up a BOF for netdev to have hopefully final
>> consensus. Shrijeet, are you going to make an official request for the
>> BOF?
>>
>> Sorry John, I dont have enough energy to address all your points but i
>> will try to just focus on SRIOV and will save a few bytes while at it.
>>

not a problem thanks for the response. I might try to document this
somewhere if folks think it would be useful. Something describing
how it works today would be helpful is my thought. Showing the
various stacked cases and how messages get propagated. (Some cases
being with bridge, without bridge, with bridge and multiple uplinks,
with bridge + VLAN filtering, macvlan, SR-IOV + bridge + VMDQ, etc.)

Its not a small task so likely won't get to it until after the new
year.

>>
>> On 12/16/14 11:35, John Fastabend wrote:
>>
>>> But in the SR-IOV case you have multiple "Cpu ports" and you want
>>> to send packets to each of them depending on the configuration.
>>>
>>>
>>>     port0   port1     port2  port3
>>>      |        |        |      |      uplinks
>>>   +------------------------------+
>>>   |                              |
>>>   |       SRIOV edge relay       |
>>>   |                              |
>>>   +------------------------------+
>>>                   |                   downlink
>>>
>>>
>>
>> Two points above:
>> 1) Did you flip uplink vs down link above?
>> (I Thought URP was the wire link)

yes sorry typo hopefully not too confusing.

>> 2) What you are not showing above which is *very important* is that
>> infact there is an underlying embedded fdb.

Yes. There is an embedded FDB.

>>
>> point #2 brings out a lot of the weird things in some of the bridge
>> code. IOW, you have an *offloaded* bridge with _bridge ports_
>> visible in the kernel but not the bridge that is controlled
>> by standard Linux bridge tools. I am not saying that the model is
>> wrong; on the contrary what Ben had exposed may fall under the
>> same category i.e you have E_BRIDGE flag on the netdev to say it sits
>> on top of an offloaded bridge and you dont need a br0 to run
>> bridge command on. But then we need some proxy (TheClassThingy) to act
>> as intemediary to the offloaded hardware.
>> If you do that then the vf becomes simply a bridge port - which
>> means bridge port ops apply.
>>
>> SRIOV it seems to have morphed its own toolkit.

Yes, but I don't think its too late to bring it into the picture here.

>> The PF port, when acting as the control interface, is actually
>> TheClassThingy we discuss on/off.

Yep or if you take Jiri's approach any port on the nic could be used
to manage this.

>> To add an fdb entry to point to vf 1, where TheClassThingy is eth1:
>> ip link set eth1 vf 1 mac aa:bb:cc:dd:ee:ff vlan 10
>>
>> IMO, SRIOV should expose these ports with names and ifindices
>> (probably does already) and pre-populated master or something
>> which points to its parent, then i can do the following:
>> bridge fdb add aa:bb:cc:dd:ee:ff vlan 10 dev vf1 master
> I had a slightly different understanding of how this would work for
> SRIOV. So, am attempting to respond to your questions for John..., ...so
> that he can correct my understanding too ..if needed :).
>
> I think SRIOV VF's do have netdevs (John can confirm, I maybe wrong). To
> me if SRIOV has a single fdb for all VF's under a PF,
> and it wants to bypass the bridge driver, there is still no reason to
> refer to the PF as a master.
> You can use self and go to the vf driver directly and it will do the
> right thing.

The VF's may have netdev's if they are in the host. In this case you
could use 'bridge fdb' to manage them. In many use cases though the
VFs are directly assigned to VMs and then are outside the hosts
management domain. For this case you can either let the host tell the
driver which addresses it would want to receive.

Another _idea_ would be to create a "shadow" netdev in the host
to manage the port even when the VF is direct assigned. Then you
could use all your normal commands from the host to set the MTU,
set any MACs, etc. At the moment as Jamal noted we have a subset
of 'ip link' commands that we use to work on VFs when they are not
in the host domain.

	'ip link set ethx vf # ...'

In the SR-IOV case you would have a PF and then a set of eth-vf#
netdev's which are not attached to a VF but act as the management
interface for the port.

>
> bridge fdb add aa:bb:cc:dd:ee:ff vlan 10 dev vf1 self
>
>>
>> master in such a case will go to TheClassThingy which would pass
>> such control to the underlying hardware.
>> The PF still stays but not as the management interface.
>

I think this is not specific to SR-IOV though right. This is the
same point for both "real" switch ASICs and SR-IOV. Using the netdev
directly as a management interace (a la rocker) seems to work OK.
But does it become cleaner to have the switch object represented
explicitly for management.

> Even if 'TheClassThingy' where there, you wouldn't refer to it as the
> master (ie the PF will not have a netdev master/slave relationship with
> the VF). 'master' will still be used for the netdev 'upper'  device if
> VF was enslaved to one (which could be a bridge).
>

Sounds right to me.

>
> Thanks,
> Roopa
>
>


-- 
John Fastabend         Intel Corporation
