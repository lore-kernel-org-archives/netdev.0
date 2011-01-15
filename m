From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for single TCP session balancing
Date: Fri, 14 Jan 2011 16:05:12 -0800
Message-ID: <26330.1295049912@death>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:34549 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab1AOAFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 19:05:22 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0ENp3qY030544
	for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 16:51:03 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0F05Fgw151172
	for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 17:05:15 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0F05FDr013052
	for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 17:05:15 -0700
In-reply-to: <4D30D37B.6090908@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oleg V. Ukhno <olegu@yandex-team.ru> wrote:
>Jay Vosburgh wrote:
>
>> 	This is a violation of the 802.3ad (now 802.1ax) standard, 5.2.1
>> (f), which requires that all frames of a given "conversation" are passed
>> to a single port.
>>
>> 	The existing layer3+4 hash has a similar problem (that it may
>> send packets from a conversation to multiple ports), but for that case
>> it's an unlikely exception (only in the case of IP fragmentation), but
>> here it's the norm.  At a minimum, this must be clearly documented.
>>
>> 	Also, what does a round robin in 802.3ad provide that the
>> existing round robin does not?  My presumption is that you're looking to
>> get the aggregator autoconfiguration that 802.3ad provides, but you
>> don't say.

	I'm still curious about this question.  Given the rather
intricate setup of your particular network (described below), I'm not
sure why 802.3ad is of benefit over traditional etherchannel
(balance-rr / balance-xor).

>> 	I don't necessarily think this is a bad cheat (round robining on
>> 802.3ad as an explicit non-standard extension), since everybody wants to
>> stripe their traffic across multiple slaves.  I've given some thought to
>> making round robin into just another hash mode, but this also does some
>> magic to the MAC addresses of the outgoing frames (more on that below).
>Yes, I am resetting MAC addresses when transmitting packets to have switch
>to put packets into different ports of the receiving etherchannel.

	By "etherchannel" do you really mean "Cisco switch with a
port-channel group using LACP"?

>I am using this patch to provide full-mesh ISCSI connectivity between at
>least 4 hosts (all hosts of course are in same ethernet segment) and every
>host is connected with aggregate link with 4 slaves(usually).
>Using round-robin I provide near-equal load striping when transmitting,
>using MAC address magic I force switch to stripe packets over all slave
>links in destination port-channel(when number of rx-ing slaves is equal to
>number ot tx-ing slaves and is even).

	By "MAC address magic" do you mean that you're assigning
specifically chosen MAC addresses to the slaves so that the switch's
hash is essentially "assigning" the bonding slaves to particular ports
on the outgoing port-channel group?

	Assuming that this is the case, it's an interesting idea, but
I'm unconvinced that it's better on 802.3ad vs. balance-rr.  Unless I'm
missing something, you can get everything you need from an option to
have balance-rr / balance-xor utilize the slave's permanent address as
the source address for outgoing traffic.

>[...] So I am able to utilize all slaves
>for tx and for rx up to maximum capacity; besides I am getting L2 link
>failure detection (and load rebalancing), which is (in my opinion) much
>faster and robust than L3 or than dm-multipath provides.
>It's my idea with the patch

	Can somebody (John?) more knowledgable than I about dm-multipath
comment on the above?

>> 	This is the code that resets the MAC header as described above.
>> It doesn't quite match the documentation, since it only resets the MAC
>> for ETH_P_IP packets.
>Yes, I really meant that my patch applies to ETH_P_IP packets and I've
>missed that from documentation I wrote.

	Is limiting this to just ETH_P_IP really a means to exclude ARP,
or is there some advantage to (effectively) only balancing IP traffic,
and leaving other traffic (IPv6, for one) essentially unbalanced (when
exiting the switch through the destination port-channel group, which
you've set to use a src-mac hash)?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
