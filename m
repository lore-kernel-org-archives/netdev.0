From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 16216] New: wrong source addr of UDP packets
 when using policy routing
Date: Wed, 16 Jun 2010 18:46:20 +0200
Message-ID: <4C18FFDC.8060102@trash.net>
References: <bug-16216-10286@https.bugzilla.kernel.org/> <20100616093328.0671254b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, borg@uu3.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43757 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755778Ab0FPQqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 12:46:24 -0400
In-Reply-To: <20100616093328.0671254b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 15 Jun 2010 15:14:43 GMT bugzilla-daemon@bugzilla.kernel.org wrote:
>
>   
>> https://bugzilla.kernel.org/show_bug.cgi?id=16216
>>
>>            Summary: wrong source addr of UDP packets when using policy
>>                     routing
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 2.6.24.7
>>     
>
> The reporter has confirmed that this issue persistes in 2.6.34.
>
>   
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: IPV4
>>         AssignedTo: shemminger@linux-foundation.org
>>         ReportedBy: borg@uu3.net
>>         Regression: No
>>
>>
>> When policy routing is used, UDP packets have wrong source address.
>> Source addr is probably taken from looking up routing table (main) to given
>> destination instead of being set just after POSTROUTING, looking up cache.
>>
>> This how it looks like doing simple netcat test:
>> (tcpdump is run on aa.aa.47.90)
>> 16:38:02.053053 IP aa.aa.47.67.32826 > aa.aa.47.90.660: UDP, length 8
>> 16:38:05.660394 IP bb.bbb.241.62.660 > aa.aa.47.67.32826: UDP, length 8
>>
>> aa.aa.47.90 have specific setup having 3 routing tables: main, 10, 20
>> and all of them have default gateway. bb.bbb.241.62 is an addr of 
>> outgoing interface of default route from main table.
>> If a packet cames from specific interface
>> its being stored to ipset and when packet is going to be sent out of the box
>> its being marked in mangle OUTPUT matching specific ipset:
>>
>> ### mangle PREROUTING ###
>> fw="iptables -t mangle -A PREROUTING"
>> $fw -i vlan0.13 -j SET --add-set gw10 src
>> $fw -i lan2 -j SET --add-set gw20 src
>>
>> ### mangle OUTPUT ###
>> fw="iptables -t mangle -A OUTPUT"
>> $fw -m set --set gw10 dst -j MARK --set-mark 10
>> $fw -m set --set gw10 dst -j ACCEPT
>> $fw -m set --set gw20 dst -j MARK --set-mark 20
>> $fw -m set --set gw20 dst -j ACCEPT
>>
>> % ip rule show
>> 32764:  from all fwmark 0x14 lookup 20
>> 32765:  from all fwmark 0xa lookup 10

This is know behaviour, fwmarks don't work for source address selection
since before the source address is chosen, you don't even have a packet
which could be marked.
