From: Brian Haley <brian.haley@hp.com>
Subject: Re: [IPV6] Fix ICMPv6 redirect handling with target multicast address
Date: Sun, 30 Sep 2007 23:27:35 -0400
Message-ID: <47006927.3030701@hp.com>
References: <46FD2B37.6040502@hp.com>	<OF5FC97D70.5FD0A80A-ON88257365.00025E58-88257365.00048D1E@us.ibm.com> <20070929.100448.41933886.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 8bit
Cc: dlstevens@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelrim04.cce.hp.com ([161.114.21.25]:14227 "EHLO
	ccerelrim04.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbXJAEAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 00:00:31 -0400
In-Reply-To: <20070929.100448.41933886.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yoshifuji,

YOSHIFUJI Hideaki / ???? wrote:
> Dave, Brian,
> 
> Let me double check this patch.
> 
> Regards,
> 
> --yoshfuji
> 
> In article <OF5FC97D70.5FD0A80A-ON88257365.00025E58-88257365.00048D1E@us.ibm.com> (at Fri, 28 Sep 2007 17:50:38 -0700), David Stevens <dlstevens@us.ibm.com> says:
> 
>> Brian,
>>         A multicast address should never be the target of a neighbor
>> discovery request; the sender should use the mapping function for all
>> multicasts. So, I'm not sure that your example can ever happen, and it
>> certainly is ok to send ICMPv6 errors to multicast addresses in general.
>> But I don't see that it hurts anything. either (since it should never 
>> happen :-)),

TAHI generates a lot of packets that shouldn't happen :) see below for 
the problem.  The patch in ndisc_send_redirect() is probably 
unnecessary, but since the code was identical I figured it wouldn't hurt.

>> so I don't particularly object, either.
>>         I think it'd also be better if you add the check to be:
>>
>>         if (ipv6_addr_type(target) & 
>> (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST))

I did have it:

if (ipv6_addr_type(target) &
     (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST) ==
     (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST))

but changed it since I had proposed ipv6_addr_linklocal() in a previous 
patch because there are other possible users of that.

This is the actual packet trace that was sent to me, edited to remove 
non-relevant data, but I've actually been unable to reproduce Packet 12 
below (note the Destination MAC).  My knee-jerk reaction was the 
proposed patch.  It could just be timing-related, I'll do more testing 
Monday.  Strangely, the TAHI test passes anyway, but it shouldn't.

Packet 10 : Icmpv6 : Redirect
Ethernet
Destination MAC.........................00:1A:4B:EB:FC:E6
Source MAC..............................00:00:10:10:10:60
Ipv6
Version.................................6
Next Header.............................58
Hop Limit...............................255
Source IP.....................FE80:0000:0000:0000:0200:10FF:FE10:1060
Destination IP................3000:0000:0000:0000:021A:4BFF:FEEB:FCE6
Icmpv6
Type....................................0x89
Code....................................0x00
Reserved................................0x00000000
Target Address................FF02:0000:0000:0000:0000:0000:0000:0001
Destination Address...........3001:0000:0000:0000:0200:10FF:FE10:1180
Options
LLAddressOption
   Option Type.............................2
   Option Length...........................1
   Link-Layer Address......................0x000010101061

Packet 11 : Icmpv6 : Echo Request
Ethernet
Destination MAC.........................00:1A:4B:EB:FC:E6
Source MAC..............................00:00:10:10:10:60
Ipv6
Version.................................6
Next Header.............................58
Hop Limit...............................255
Source IP.....................3001:0000:0000:0000:0200:10FF:FE10:1180
Destination IP................3000:0000:0000:0000:021A:4BFF:FEEB:FCE6
Icmpv6
Type....................................0x80
Code....................................0x00
Identifier..............................0x0000
Sequence Number.........................0x0000
Data....................................0x00

Packet 12 : Icmpv6 : Echo Reply
Ethernet
Destination MAC.........................33:33:00:00:00:01
Source MAC..............................00:1A:4B:EB:FC:E6
Ipv6
Version.................................6
Next Header.............................58
Hop Limit...............................64
Source IP.....................3000:0000:0000:0000:021A:4BFF:FEEB:FCE6
Destination IP................3001:0000:0000:0000:0200:10FF:FE10:1180
Icmpv6
Type....................................0x81
Code....................................0x00
Identifier..............................0x0000
Sequence Number.........................0x0000
Data....................................0x00

This should have been sent to 00:00:10:10:10:60

-Brian
