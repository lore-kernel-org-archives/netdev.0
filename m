From: Patrick McHardy <kaber@trash.net>
Subject: Re: Wrong padding of short packets send by a tagged-vlan interface?
Date: Mon, 07 Jul 2008 23:06:20 +0200
Message-ID: <4872854C.201@trash.net>
References: <Pine.LNX.4.64.0807072210470.15459@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38532 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756002AbYGGVGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:06:23 -0400
In-Reply-To: <Pine.LNX.4.64.0807072210470.15459@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote:
> Hello,
> 
> I have a problem that I'm not able to connect from selected linux hosts 
> to a newly installed Netware 6.5 server. After two days of debugging I 
> discovered that the problem seems to be caused by an insufficient 
> padding of a .1q tagged packets.
> 
> Currently, if a packet is too short, it is extended to 60(+4) octets for 
> both untagged and tagged ones. Unfortunately, when a .1Q tag is removed 
> on a receive side, such packet is likely to be dropped as it may become 
> too short (56 bytes):
> 
> This is a normal (working) ping with 84B (IP) + 14B (eth hdr) = 98B octets:
> # ping -c 2 192.168.0.194
> PING 192.168.0.194 (192.168.0.194) 56(84) bytes of data.
> 64 bytes from 192.168.0.194: icmp_seq=1 ttl=128 time=0.137 ms
> 64 bytes from 192.168.0.194: icmp_seq=2 ttl=128 time=0.141 ms
> 
> This is a shorter (working) ping with 46 (IP) + 14B (eth hdr) = 60B octets:
> # ping -c 2 192.168.0.194 -s 18
> PING 192.168.0.194 (192.168.0.194) 18(46) bytes of data.
> 26 bytes from 192.168.0.194: icmp_seq=1 ttl=128 time=0.137 ms
> 26 bytes from 192.168.0.194: icmp_seq=2 ttl=128 time=0.144 ms
> 
> This one does not work (45+14 = 59): # ping -c 2 192.168.0.194 -s 17
> PING 192.168.0.194 (192.168.0.194) 17(45) bytes of data.
> 
> --- 192.168.0.194 ping statistics ---
> 2 packets transmitted, 0 received, 100% packet loss, time 999ms
> 
> I believe that my problem can be solved if we start padding .1Q packets 
> with 4 more octets but I'm not able to find a proper place where to fix it.

Nice catch, if this really is the problem :) For a fix I'd suggest to
add a skb_ether_pad() function that performs the necessary padding
depending on skb->protocol and change the ethernet drivers to use it
instead of skb_padto().



