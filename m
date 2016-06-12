From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [Bridge] [PATCH net-next v2] bridge: Synchronize unicast
 filtering with FDB
Date: Sun, 12 Jun 2016 15:35:23 +0900
Message-ID: <575D02AB.6040008@gmail.com>
References: <1465215613-3468-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <20160610.223512.206489271156278288.davem@davemloft.net>
 <575C39B1.3010300@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	netdev@bof.de
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33712 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbcFLGf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 02:35:27 -0400
Received: by mail-pf0-f178.google.com with SMTP id y124so35972465pfy.0
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2016 23:35:27 -0700 (PDT)
In-Reply-To: <575C39B1.3010300@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/06/12 (=E6=97=A5) 1:17, Nikolay Aleksandrov via Bridge wrote:
> On 06/11/2016 07:35 AM, David Miller wrote:
>> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> Date: Mon,  6 Jun 2016 21:20:13 +0900
>>
>>> Patrick Schaaf reported that flooding due to a missing fdb entry of
>>> the address of macvlan on the bridge device caused high CPU
>>> consumption of an openvpn process behind a tap bridge port.
>>> Adding an fdb entry of the macvlan address can suppress flooding
>>> and avoid this problem.
>>>
>>> This change makes bridge able to synchronize unicast filtering with
>>> fdb automatically so admin do not need to manually add an fdb entry=
=2E
>>> This effectively supports IFF_UNICAST_FLT in bridge, thus adding an
>>> macvlan device would not place bridge into promiscuous mode as well=
=2E
>>>
>>> v2:
>>> - Test vlan with br_vlan_should_use() in br_fdb_sync_uc() as per
>>>    Nikolay Aleksandrov.
>>>
>>> Reported-by: Patrick Schaaf <netdev@bof.de>
>>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>
>> I really need bridging experts to review and ACK/NACK this.
>>
>> Thanks.
>>
>
> Oops, I almost missed the v2, sorry about that. So, technically it lo=
oks correct, but
> I only fear the scalability impact of the change. If there're a large=
 number of vlans
> adding a macvlan (or any device that syncs uc addr) might become very=
 slow and every
> flag change will become very slow too without an option to revert to =
the original
> behaviour so we'll have to wait for the entries to be added in order =
to delete them.
> Another common scenario is having 8021q interfaces on top of the brid=
ge with different
> mac addresses for some of the configured vlans (or with macvlans on t=
op of them for VRR),
> that use case would suffer as well because their macs need to be loca=
l only for those vlans,
> and not the 2000+ other vlans that might exist.
> On every sync_uc() call all the fdb entries get deleted and added aga=
in, so even after deleting
> some manually they can come back unexpectedly after some operation an=
d also the message storm from
> all the deletes and adds could be problematic as well.
>
> E.g. 2000 br0 vlans, 25 macvlans on br0 (adding them took more than 5=
 minutes, 53k fdb entries):
> $ bridge fdb del de:8e:9f:16:c5:71 dev br0 vlan 289
> $ ip l set br0 multicast on
> $ bridge fdb | grep 289 | grep de:8e:9f:16:c5:71
> de:8e:9f:16:c5:71 dev br0 vlan 1289 master br0 permanent
> de:8e:9f:16:c5:71 dev br0 vlan 289 master br0 permanent
>
> In fact you can't escape the slow performance even if you delete all =
entries because on the
> next flag change or interface add, they will be added back.

I still think this auto-sync should be done, otherwise macvlan imposes=20
promiscuous mode on bridge even if you manually add such fdb entries.
I believe most of your concern would disappear by making use of=20
__dev_uc_sync() instead.
Indeed it seems that there is no easy way to propagate the combination=20
of uc addr and vlan from upper device, so local entries for unneeded=20
vlan can still be created even if using __dev_uc_sync(). In case you=20
worry about those unneeded entries, I can add a knob to disable this=20
feature.
Are you comfortable with this change?

Toshiaki Makita
