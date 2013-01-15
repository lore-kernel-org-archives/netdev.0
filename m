From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: per route MTU settings
Date: Tue, 15 Jan 2013 18:07:59 +0100
Message-ID: <DUB107-W269A7F1946A7B27212F3F8ED2D0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: <pupilla@libero.it>, <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s32.dub0.hotmail.com ([157.55.0.231]:24043 "EHLO
	dub0-omc1-s32.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756566Ab3AORIJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2013 12:08:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi pupilla,

looks like the behavior changed with 3.2-rc5 and "[PATCH 5/5] ipv4:
Don't use the cached pmtu informations for input routes" ([1], [2]).

Actually, a "mtu lock XYZ" applied to a route is a bit of a corner case.


Steffen, you already made this statement once and I can only agree with you:

> The router that can't send the packet to the next hop network has to
> send the ICMP Destination Unreachable message. We never propagated
> learned PMTU informations and I would not like to change this


But here is our issue:
- the linux "ip_forwarder" has an MTU of 1500 Byte on relevant interfaces
- there is a route with a "static" mtu lock at 1200 Byte
- the box is supposed to forward a packet heading the 1200B MTU route

What happens is:
- the packet is dropped (because it exceeds the 1200 Byte)
- an ICMP Type 3 Code 4 message is generated with 576 Byte next-hop MTU

Notice that the 576 Byte indicated as next-hop MTU in the ICMP packet
doesn't match neither outgoing interface MTU, nor the static route's MTU.

Prior to your patch (for example in 3.2-rc4), 1200 Byte was indicated as
MTU in the ICMP packet.


root@ubuntuvm:~# cat /proc/version
Linux version 3.2.0-030200rc5-generic (root@gomeisa) (gcc version 4.4.3 (Ubuntu 4.4.3-4ubuntu5) ) #201112091935 SMP Sat Dec 10 00:36:07 UTC 2011
root@ubuntuvm:~# echo 1> /proc/sys/net/ipv4/ip_forward
root@ubuntuvm:~# echo 0> /proc/sys/net/ipv4/conf/eth0/send_redirects
root@ubuntuvm:~# ip route add 8.8.8.8/32 via 10.0.0.254 mtu lock 1200
root@ubuntuvm:~# ip r
default via 10.0.0.254 dev eth0 metric 100
8.8.8.8 via 10.0.0.254 dev eth0 mtu lock 1200
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.55
root@ubuntuvm:~# tcpdump -nvvv icmp -i eth0
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
01:49:20.193798 IP (tos 0x0, ttl 128, id 12090, offset 0, flags [DF], proto ICMP (1), length 1428)
10.0.0.3> 8.8.8.8: ICMP echo request, id 1, seq 4150, length 1408
01:49:20.193847 IP (tos 0xc0, ttl 64, id 15646, offset 0, flags [none], proto ICMP (1), length 576)
10.0.0.55> 10.0.0.3: ICMP 8.8.8.8 unreachable - need to frag (mtu 576), length 556
IP (tos 0x0, ttl 128, id 12090, offset 0, flags [DF], proto ICMP (1), length 1428)
10.0.0.3> 8.8.8.8: ICMP echo request, id 1, seq 4150, length 1408
^C
2 packets captured
2 packets received by filter
0 packets dropped by kernel


Now, what is the kernel supposed to do in this case?

In my opinion either act like <3.2-rc4 and return 1200 Byte in the ICMP
error message or forward the packet anyway (we have the necessary interface
MTU to do it), ignoring the route with "mtu lock".


Steffen, could you share your opinion about this?


Its probably a good idea to avoid "mtu lock" on routes completely though.



Regards,

Lukas

[1] http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commit;h=261663b0ee2ee8e3947f4c11c1a08be18cd2cea1
[2] http://patchwork.ozlabs.org/patch/127288/

 		 	   		  