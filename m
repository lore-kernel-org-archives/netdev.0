From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: Add default vlan for dual
 emac case also
Date: Mon, 19 May 2014 10:46:46 +0200
Message-ID: <CAGm1_kszjSKqxUONX6OodgEs4V=dV5KZRM32LhiMV44u-+AZYw@mail.gmail.com>
References: <1397023480-4181-1-git-send-email-mugunthanvnm@ti.com>
 <20140409.145624.1000792872429500740.davem@davemloft.net> <CAGm1_ktmygGNWqEvO=59ZVFbTprUHLuXAmSM3UXfVrShPJsz_g@mail.gmail.com>
 <534E1BD2.5050809@ti.com> <CAGm1_ktSCZLa2-vyeP2nygcKwrXgkyoXs94TSx=tY-HrOsZmKQ@mail.gmail.com>
 <CAGm1_kvHRx61i1fKywAdySOB0vk03E+PDsD23W89UHihoRmM7g@mail.gmail.com> <53679E48.4030909@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:59183 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaESIrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 04:47:09 -0400
Received: by mail-la0-f53.google.com with SMTP id ec20so3826220lab.12
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 01:47:07 -0700 (PDT)
In-Reply-To: <53679E48.4030909@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 5, 2014 at 4:20 PM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> On Friday 02 May 2014 02:28 PM, Yegor Yefremov wrote:
>> On Wed, Apr 16, 2014 at 3:58 PM, Yegor Yefremov
>> <yegorslists@googlemail.com> wrote:
>>> On Wed, Apr 16, 2014 at 7:57 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
>>>> On Tuesday 15 April 2014 07:16 PM, Yegor Yefremov wrote:
>>>>> On Wed, Apr 9, 2014 at 8:56 PM, David Miller <davem@davemloft.net> wrote:
>>>>>> From: Mugunthan V N <mugunthanvnm@ti.com>
>>>>>> Date: Wed, 9 Apr 2014 11:34:40 +0530
>>>>>>
>>>>>>> Dual EMAC works with VLAN segregation of the ports, so default vlan needs
>>>>>>> to be added in dual EMAC case else default vlan will be tagged for all
>>>>>>> egress packets and vlan unaware switches/servers will drop packets
>>>>>>> from the EVM.
>>>>> Hi Mugunthan,
>>>>>
>>>>> though this patch fixes drop packets issue, it introduces another
>>>>> issue. Just connect both interfaces to one switch and configure
>>>>> different subnets. As soon as you get a broadcast you have an endless
>>>>> loop and network communication is not possible at all. Before this
>>>>> patch you could operate as if you had really two independent NICs.
>>>>>
>>>>>
>>>> This patch doesn't add any multicast or unicast entry in the ALE table,
>>>> so there is no possible way that a broadcast packet is switched within
>>>> the two external ports, and this patch removes the encapsulation of the
>>>> default vlan id which is used for internal packet switching inside CPSW
>>>> switch from host and any packet received from external port will be
>>>> tagged with port vlan so internal switching will happen with that port
>>>> vlan-id which will be only that physical port and host port. so the
>>>> scenario which you mentioned cannot happen theoretically untill you
>>>> enable bridge between the dual ethernet interface and connect both to
>>>> the same interface.
>>> Have you tried the described setup? My system is Buildroot on
>>> am335x-evmsk with almost empty /etc/network/interfaces
>>>
>>> # Configure Loopback
>>> auto lo
>>> iface lo inet loopback
>>>
>>> No bridges:
>>>
>>> # brctl show
>>> bridge name     bridge id               STP enabled     interfaces
>>>
>>> And following address setup made manually:
>>>
>>> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
>>> group default
>>>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>>>     inet 127.0.0.1/8 scope host lo
>>>        valid_lft forever preferred_lft forever
>>> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
>>> state UP group default qlen 1000
>>>     link/ether 00:18:31:93:f6:49 brd ff:ff:ff:ff:ff:ff
>>>     inet 192.168.1.234/24 brd 192.168.1.255 scope global eth0
>>>        valid_lft forever preferred_lft forever
>>> 3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
>>> state DOWN group default qlen 1000
>>>     link/ether 56:90:76:5b:b5:f3 brd ff:ff:ff:ff:ff:ff
>>>     inet 192.168.4.234/24 brd 192.168.4.255 scope global eth1
>>>        valid_lft forever preferred_lft forever
>>> 4: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group
>>> default qlen 1000
>>>     link/ether de:ad:be:ef:00:00 brd ff:ff:ff:ff:ff:ff
>>>
>>> Routing table:
>>>
>>> # ip route show
>>> 192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.234
>>> 192.168.4.0/24 dev eth1  proto kernel  scope link  src 192.168.4.234
>>>
>>> Same behavior on 3.14.0-rc4-12740-gcc09039-dirty and 3.15.0-rc1-00002-ge0f8779
>>>
>>> As soon as insert the cable into eth1, my switch shows very high
>>> activity and the whole LAN in the company is dead till I remove the
>>> cable. I have no problems with the version before the fix. I don't
>>> really know, what happens inside the driver, but could make the same
>>> setup (best of all in a LAN with many Windows PCs, that send lots of
>>> broadcast) and let me know if you see the same behavior.
>> This bug seems to be in 3.12 too. See this thread
>> (http://e2e.ti.com/support/arm/sitara_arm/f/791/p/338292/1180954.aspx#1180954).
>>
>> Thanks.
>>
>> Yegor
>
> Will check this in this week.

Any news concerning this issue?

Thanks.

Yegor
