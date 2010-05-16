From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Sun, 16 May 2010 22:34:56 +0200
Message-ID: <4BF056F0.8010008@ans.pl>
References: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com> <1274040928.2299.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:34731 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493Ab0EPUfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 16:35:05 -0400
In-Reply-To: <1274040928.2299.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-16 22:15, Eric Dumazet wrote:
> Le dimanche 16 mai 2010 =C3=A0 13:00 -0700, Michael Chan a =C3=A9crit=
 :
>> Krzysztof Oledzki wrote:
>>
>>> On 2010-05-16 20:51, Michael Chan wrote:
>>>> Krzysztof Oledzki wrote:
>>>>
>>>>>
>>>>> Why the driver registers 5 interrupts instead of 4? How to
>>>>> limit it to 4?
>>>>>
>>>>
>>>> The first vector (eth0-0) handles link interrupt and other slow
>>>> path events.  It also has an RX ring for non-IP packets that are
>>>> not hashed by the RSS hash.  The majority of the rx packets should
>>>> be hashed to the rx rings eth0-1 - eth0-4, so I would assign these
>>>> vectors to different CPUs.
>>>
>>> Thank you for your prompt response.
>>>
>>> In my case the first vector must be handling something more:
>>>   - "ping -f 192.168.0.1" increases interrupts on both eth1-0
>>> and eth1-4
>>>   - "ping -f 192.168.0.2" increases interrupts on both eth1-0
>>> and eth1-3
>>>   - "ping -f 192.168.0.3" increases interrupts on both eth1-0
>>> and eth1-1
>>>   - "ping -f 192.168.0.7" increases interrupts on both eth1-0
>>> and eth1-2
>>>
>>>              CPU0       CPU1       CPU2       CPU3
>>>    67:    1563979          0          0          0
>>> PCI-MSI-edge      eth1-0
>>>    68:    1072869          0          0          0
>>> PCI-MSI-edge      eth1-1
>>>    69:     137905          0          0          0
>>> PCI-MSI-edge      eth1-2
>>>    70:     259246          0          0          0
>>> PCI-MSI-edge      eth1-3
>>>    71:     760252          0          0          0
>>> PCI-MSI-edge      eth1-4
>>>
>>> As you can see, eth1-1 + eth1-2 + eth1-3 + eth1-4 ~=3D eth1-0.
>>
>> I think that ICMP ping packets will always go to ring 0 (eth1-0)
>> because they are non-IP packets.  I need to double check tomorrow
>> on how exactly the hashing works on RX.  Can you try running IP
>> traffic?  IP packets should theoretically go to rings 1 - 4.
>>
>
> ICMP packets are IP packets (Protocol=3D1)

Exactly. However, the firmware may handle ICMP and TCP in a different w=
ay.

>>> So, it seems that TX or RX is always handled by the first vector.
>>> I'll try to find if it is TX or RX.
>>>
>>> BTW: I'm using .1Q vlans over bonding, does it change anything?
>>
>> That should not matter, as the VLAN tag is stripped before hashing.
>
> warning, bonding currently is not multiqueue aware.
>
> All tx packets through bonding will use txqueue 0, since bnx2 doesnt
> provide a ndo_select_queue() function.

OK, that explains everything. Thank you Eric. I assume it may take some=
=20
time for bonding to become multiqueue aware and/or bnx2x to provide=20
ndo_select_queue?

BTW: With a normal router workload, should I expect big performance dro=
p=20
when receiving and forwarding the same packet using different CPUs?=20
Bonding provides very important functionality, I'm not able to drop it.=
 :(

Best regards,

			Krzysztof Ol=C4=99dzki
