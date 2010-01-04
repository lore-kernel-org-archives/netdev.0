From: Milan Dadok <milan@dadok.name>
Subject: RE: [PATCH] 1/1 net: packet: Keep 802.1Q VLAN tag in packet on SOCK_DGRAM socket - resend
Date: Mon, 4 Jan 2010 18:11:17 +0100
Message-ID: <001c01ca8d60$eda21640$c8e642c0$@name>
References: <001801ca8d1d$90c68de0$b253a9a0$@name> <4B41F292.8080908@trash.net> <001b01ca8d52$817d07d0$84771770$@name> <4B421785.6090403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <uaca@alumni.uv.es>, <johann.baudy@gnu-log.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: 'Patrick McHardy' <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.kvados.cz ([194.213.53.146]:35285 "EHLO mailgw.kvados.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392Ab0ADRLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 12:11:24 -0500
In-Reply-To: <4B421785.6090403@trash.net>
Content-Language: cs
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Patrick McHardy wrote:
>> Currently pseudo-header contains for OUTGOING packet on physical card (vlan10@eth1)
>> a) HW accelarated network card  
>> protocol = ethertype IPv4 (0x0800)
>> tci = vlan number = 10
>> and data starts with 4500 0028
>> 
>> b) non HW accelerated network card 
>> protocol = ethertype 802.1Q (0x8100)
>> tci = 0
>> and data starts with 4500 0028
>> vlan tci and real protocol number (ARP,IPV4,IPV6) of data is lost 
>>
>As mentioned in the text I quoted, this is apparently what is
>intended for SOCK_DGRAM packet sockets. The accelerated case is
>inconsistent and vlan_tci should be cleared I guess.
>
>I agree that sll_protocol should reflect the network protocol
>in this case however.

There are probablly two solution SOCK_DGRAM
A. sll_protocol will have outer network protokol and packet data will have all data after that network protokol field
	(sll tci will be <>0 only with VLAN acceleration)

B. ssl_protocol will have the most inner network protokol (Ipv4, ARP, Ipv6)
	and cooked sll will have fields for restore all encapsulation protocols
	(on eth1 I need to know, if packet is send with vlan 1010 in vlan 10 or as vlan 10 in vlan 1010)

>> I have no problems with received packets, only outgoing packet have problem.
>> I think that out packet on SOCK_DGRAM sockets MUST BE in same format as in (received) packet on same interface.
>> Can we agree on this?
>
>Yes, agreed.

Now receive path is working as in solution A (if I remember correctly from my tests)
- packet data with all 802.1Q tags are send throu SOCK_DGRAM in same format as in SOCK_RAW (expect MAC header)
  (on HW vlan accel first VLAN tag is in tci field of TPACKET_V2)

Outgoing packet in SOCK_RAW is same as in receive.
Outgoing packet in SOCK_DGRAM - solution B with invalid sll_protokol

My patch is trying to change behaviour of outgoing packet in SOCK_DGRAM to same format as in received SOCK_DGRAM or SOCK_RAW

PS. There is one BIG question - how can I write kernel filter for filter explicit vlan number,
which can be used at the same time on HW vlan accelerated card (outer VLAN is in tci) and
non HW vlan accelerated card (outer VLAN is at the beggining of packet data)

Only solution I found, is to use user level filter and recreate vlan tag from sll tci in userspace before running filter.

Milan







