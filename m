From: Roman Yepishev <roman.yepishev@gmail.com>
Subject: UDP Fragmentation Offload fragments packets with DF bit
Date: Thu, 14 Mar 2013 18:18:29 +0200
Message-ID: <CAPTwTV-Yz6My6=LCA9T=-JYWUX79DQiC0Yn2yPP6Z38wy0HXyw@mail.gmail.com>
References: <CAPTwTV_nG7-FUNeie_6Djdd=QshE_bO=fR+L5C3fN48S48KWdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:46181 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757975Ab3CNQSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 12:18:30 -0400
Received: by mail-ie0-f169.google.com with SMTP id 13so3294206iea.28
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 09:18:29 -0700 (PDT)
In-Reply-To: <CAPTwTV_nG7-FUNeie_6Djdd=QshE_bO=fR+L5C3fN48S48KWdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This message was originally sent to KVM mailing list but I feel this
question is more appropriate here.

"tracepath www.example.net" does not work when a VM has UFO enabled
(as it is with virtio NIC):

$ sudo ethtool -k eth0 | grep udp
udp-fragmentation-offload: on

$ tracepath www.example.net
 1:  vlan3.gw.lappyfamily.net                              1.992ms
 2:  no reply

$ sudo ethtool -K eth0 ufo off
$ tracepath www.example.net
 1:  potato.lappyfamily.net                                0.447ms pmtu 1500
 1:  vlan3.gw.lappyfamily.net                              0.463ms
 2:  local-gw.236.teremki.kiev.ua                          1.268ms
...

tracepath works by sending a 65536-byte UDP packet with DF bit set,
then adjusts the packet size according to the ICMP replies for PMTU
discovery. However, when UDP fragmentation offload is enabled, the
packets are _fragmented_ into lots of small 1500-byte size packets.
The remote host does not need to send ICMP fragmentation-needed
responses, and it looks like my upstream ISP router drops incoming UDP
packets that are larger than 32K completely so it will return neither
ICMP time exceeded messages nor the message that a port is closed.

This is seen on the vnet2 tap device:
17:50:53.522206 IP (tos 0x0, ttl 1, id 0, offset 0, flags [DF], proto
UDP (17), length 65535)
    192.168.100.8.51765 > 192.0.43.10.44444: UDP, length 65507

This is what seen leaving the host interface:
17:50:53.522398 IP (tos 0x0, ttl 1, id 0, offset 0, flags [+], proto
UDP (17), length 1500)
    192.168.100.8.51765 > 192.0.43.10.44444: UDP, length 65507
17:50:53.522416 IP (tos 0x0, ttl 1, id 0, offset 1480, flags [+],
proto UDP (17), length 1500)
    192.168.100.8 > 192.0.43.10: udp
...

I have checked 3.2.0 and 3.8.0 kernel hosts and they all happily split
a DF packet as seen above.

It looks like a bug to me. I assume that if an IP packet carrying this
UDP payload has DF bit set then it should not be fragmented even when
fragmentation is handled by the NIC (or VM host in our case). Does
this look like a real issue?

-- 
Regards, Roman Yepishev
