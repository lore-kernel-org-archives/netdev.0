From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [Bridge] [PATCH net-next v2] bridge: Synchronize unicast
 filtering with FDB
Date: Mon, 13 Jun 2016 23:49:13 +0900
Message-ID: <575EC7E9.4040000@gmail.com>
References: <1465215613-3468-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <20160610.223512.206489271156278288.davem@davemloft.net>
 <575C39B1.3010300@cumulusnetworks.com> <575D02AB.6040008@gmail.com>
 <af1a5db5-fb9a-f3d9-f94c-b987c70f02da@lab.ntt.co.jp>
 <575E97B3.1060704@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	netdev@bof.de
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33926 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161084AbcFMOtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 10:49:18 -0400
Received: by mail-pf0-f170.google.com with SMTP id 62so46977327pfd.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 07:49:18 -0700 (PDT)
In-Reply-To: <575E97B3.1060704@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/06/13 (=E6=9C=88) 20:23, Nikolay Aleksandrov wrote:
> On 13/06/16 13:13, Toshiaki Makita wrote:
>> On 2016/06/12 15:35, Toshiaki Makita wrote:
>>> On 16/06/12 (=E6=97=A5) 1:17, Nikolay Aleksandrov via Bridge wrote:
>>>> On 06/11/2016 07:35 AM, David Miller wrote:
>>>>> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>>>> Date: Mon,  6 Jun 2016 21:20:13 +0900
>>>>>
>>>>>> Patrick Schaaf reported that flooding due to a missing fdb entry=
 of
>>>>>> the address of macvlan on the bridge device caused high CPU
>>>>>> consumption of an openvpn process behind a tap bridge port.
>>>>>> Adding an fdb entry of the macvlan address can suppress flooding
>>>>>> and avoid this problem.
>>>>>>
>>>>>> This change makes bridge able to synchronize unicast filtering w=
ith
>>>>>> fdb automatically so admin do not need to manually add an fdb en=
try.
>>>>>> This effectively supports IFF_UNICAST_FLT in bridge, thus adding=
 an
>>>>>> macvlan device would not place bridge into promiscuous mode as w=
ell.
>>>>>>
>>>>>> v2:
>>>>>> - Test vlan with br_vlan_should_use() in br_fdb_sync_uc() as per
>>>>>>     Nikolay Aleksandrov.
>>>>>>
>>>>>> Reported-by: Patrick Schaaf <netdev@bof.de>
>>>>>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>>>>
>>>>> I really need bridging experts to review and ACK/NACK this.
>>>>>
>>>>> Thanks.
>>>>>
>>>>
>>>> Oops, I almost missed the v2, sorry about that. So, technically it
>>>> looks correct, but
>>>> I only fear the scalability impact of the change. If there're a la=
rge
>>>> number of vlans
>>>> adding a macvlan (or any device that syncs uc addr) might become v=
ery
>>>> slow and every
>>>> flag change will become very slow too without an option to revert =
to
>>>> the original
>>>> behaviour so we'll have to wait for the entries to be added in ord=
er
>>>> to delete them.
>>>> Another common scenario is having 8021q interfaces on top of the
>>>> bridge with different
>>>> mac addresses for some of the configured vlans (or with macvlans o=
n
>>>> top of them for VRR),
>>>> that use case would suffer as well because their macs need to be l=
ocal
>>>> only for those vlans,
>>>> and not the 2000+ other vlans that might exist.
>>>> On every sync_uc() call all the fdb entries get deleted and added
>>>> again, so even after deleting
>>>> some manually they can come back unexpectedly after some operation=
 and
>>>> also the message storm from
>>>> all the deletes and adds could be problematic as well.
>>>>
>>>> E.g. 2000 br0 vlans, 25 macvlans on br0 (adding them took more tha=
n 5
>>>> minutes, 53k fdb entries):
>>>> $ bridge fdb del de:8e:9f:16:c5:71 dev br0 vlan 289
>>>> $ ip l set br0 multicast on
>>>> $ bridge fdb | grep 289 | grep de:8e:9f:16:c5:71
>>>> de:8e:9f:16:c5:71 dev br0 vlan 1289 master br0 permanent
>>>> de:8e:9f:16:c5:71 dev br0 vlan 289 master br0 permanent
>>>>
>>>> In fact you can't escape the slow performance even if you delete a=
ll
>>>> entries because on the
>>>> next flag change or interface add, they will be added back.
>>>
>>> I still think this auto-sync should be done, otherwise macvlan impo=
ses
>>> promiscuous mode on bridge even if you manually add such fdb entrie=
s.
>>> I believe most of your concern would disappear by making use of
>>> __dev_uc_sync() instead.
>>> Indeed it seems that there is no easy way to propagate the combinat=
ion
>>> of uc addr and vlan from upper device, so local entries for unneede=
d
>>> vlan can still be created even if using __dev_uc_sync(). In case yo=
u
>>> worry about those unneeded entries, I can add a knob to disable thi=
s
>>> feature.
>>> Are you comfortable with this change?
>>
>> Tested performance using __dev_uc_sync() and got expected results.
>> (Add 3000 br0 vlans, 50 macvlans on br0)
>>
>> * Without patch
>>   1.8s
>>
>> * Patch v2
>>   2m42s
> Your machine is much faster apparently. :-) It took me ~5 minutes for=
 25
> macvlans
> in my VM.
>
>>
>> * Patch using __dev_uc_sync()
>>   3.5s
>>   Also, a manually deleted entry is not restored by flag change.
>>
>>
>> Nikolay, David, I'd like to hear your feedback.
>> I'm thinking the performance implication now looks reasonable.
>> If you don't have objection, I'll work on v3 (using __dev_uc_sync() =
and
>> knob to disable the feature).
>>
>> Thanks,
>> Toshiaki Makita
>>
>
> The numbers sound okay, but I'd have to see the patch to be able to c=
omment
> further.

Sure.

 > I wonder why the push for this change when this can be currently
> "fixed" by adding the macs manually as local (pointing to the bridge)=
 ?

Well, there are two problems.
One is what Patrick Schaaf reported and can be solved by manually addin=
g=20
local entries as well.
The other is that macvlans force the bridge to be promiscuous. That=20
means bridge ports cannot be non-promiscuous if any macvlan exists. Thi=
s=20
is because bridge's non-promiscuous feature requires all necessary fdb=20
entries to be configured in order to sync them to brport's uc list.=20
Without sync_uc of the bridge device, bridge cannot know what addresses=
=20
are needed for brport's uc filter so we cannot get around promiscuous=20
mode with macvlans. This is what I feel is worth fixing with this patch=
=2E=20
I'm thinking this auto non-promiscuous should be transparently done wit=
h=20
macvlans...
Sorry about the lack of explanation.

Thanks,
Toshiaki Makita
