From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Sat, 15 Jan 2011 15:11:08 +0300
Message-ID: <4D318EDC.2050500@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:16957 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827Ab1AOMLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 07:11:13 -0500
In-Reply-To: <26330.1295049912@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jay Vosburgh wrote:
> Oleg V. Ukhno <olegu@yandex-team.ru> wrote:
>> Jay Vosburgh wrote:
>>
>>> 	Also, what does a round robin in 802.3ad provide that the
>>> existing round robin does not?  My presumption is that you're looking to
>>> get the aggregator autoconfiguration that 802.3ad provides, but you
>>> don't say.
> 
> 	I'm still curious about this question.  Given the rather
> intricate setup of your particular network (described below), I'm not
> sure why 802.3ad is of benefit over traditional etherchannel
> (balance-rr / balance-xor).
Yes, I wanted 802.3ad autoconfiguration. Besides, all switches I use 
support LACP so I've chosen 802.3ad link aggregation.
Of course, it would be cool it both 802.3ad and balance-rr modes 
supported such load striping feature.

> 
>> Yes, I am resetting MAC addresses when transmitting packets to have switch
>> to put packets into different ports of the receiving etherchannel.
> 
> 	By "etherchannel" do you really mean "Cisco switch with a
> port-channel group using LACP"?
Yes, exactly
> 
>> I am using this patch to provide full-mesh ISCSI connectivity between at
>> least 4 hosts (all hosts of course are in same ethernet segment) and every
>> host is connected with aggregate link with 4 slaves(usually).
>> Using round-robin I provide near-equal load striping when transmitting,
>> using MAC address magic I force switch to stripe packets over all slave
>> links in destination port-channel(when number of rx-ing slaves is equal to
>> number ot tx-ing slaves and is even).
> 
> 	By "MAC address magic" do you mean that you're assigning
> specifically chosen MAC addresses to the slaves so that the switch's
> hash is essentially "assigning" the bonding slaves to particular ports
> on the outgoing port-channel group?

Yes, so I am able to make equal load striping even for single TCP 
session between just two hosts not only for transmiting host, but also 
for receiving host(iperf, when doing TCP test, is able to utilize all 
available bandwith in given etherchannel).

> 
> 	Assuming that this is the case, it's an interesting idea, but
> I'm unconvinced that it's better on 802.3ad vs. balance-rr.  Unless I'm
> missing something, you can get everything you need from an option to
> have balance-rr / balance-xor utilize the slave's permanent address as
> the source address for outgoing traffic.

Yes, balance-rr would satisfy my requrements if patched for doing "MAC 
address magic"(replacing MAC address of packets being transmitted by 
slave's permanent address), except for 802.3ad link autoconfiguration.
"Pure" balance-rr won't allow to utilize whole etherchannel bandwidth 
when transmitting data just between 2 hosts( for example, when I have 
one iSCSI initiator and one iSCSI target). balance-xor is not what I 
wanted because data transmitted on source host will stick to any, but 
single slave.


> 
> 
>>> 	This is the code that resets the MAC header as described above.
>>> It doesn't quite match the documentation, since it only resets the MAC
>>> for ETH_P_IP packets.
>> Yes, I really meant that my patch applies to ETH_P_IP packets and I've
>> missed that from documentation I wrote.
> 
> 	Is limiting this to just ETH_P_IP really a means to exclude ARP,
> or is there some advantage to (effectively) only balancing IP traffic,
> and leaving other traffic (IPv6, for one) essentially unbalanced (when
> exiting the switch through the destination port-channel group, which
> you've set to use a src-mac hash)?
> 
Well, when making initial version of this patch(it was for 2.6.18 
kernel), I meant just excluding ARP .

> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 

-- 
Best regards,

Oleg Ukhno
