From: "pupilla@libero.it" <pupilla@libero.it>
Subject: mtu issue with ipsec tunnel and netfilter snat
Date: Wed, 9 Jan 2013 10:01:54 +0100 (CET)
Message-ID: <23599275.2918881357722114614.JavaMail.defaultUser@defaultHost>
Reply-To: "pupilla@libero.it" <pupilla@libero.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outrelay02.libero.it ([212.52.84.102]:35155 "EHLO
	outrelay02.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757411Ab3AIJB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 04:01:56 -0500
Received: from wmail47 (172.31.0.237) by outrelay02.libero.it (8.5.140.03)
        id 50D43E1301F7EA78 for netdev@vger.kernel.org; Wed, 9 Jan 2013 10:01:54 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody.
 
I'm experimenting a pretty strange
problem with an ipsec gateway source
natting packets running linux 3.6.9
on slackware 14 32bit
 
Here is the network schema.
 
customer private network 10.148.0.0/16
|
|
+ipsec customer gateway (checkpoint)
||
||---ipsec tunnel 10.148.0.0/16<->172.16.128.0/28 (des3/md5)
||   mtu=1446
||
++ linux_gw_snat ipsec gateway (SNAT all packets from 10.81.128.0/21 to 
172.16.128.1)
||
||---ipsec tunnel 10.148.0.0/16<->10.81.128.0/21 (aes/sha1/ipcomp)
||   mtu=1430
||
+linux_final ipsec gateway
|
|
client 10.81.128.176
 

Here is a tcpdump capture taken on
linux_gw_snat:

15:35:05.123634 IP (tos 0x40, ttl 56, id 41983, offset 0, flags [DF], proto 
TCP (6), length 1500)
    10.148.12.23.3229 > 172.16.128.1.4019: Flags [P.], cksum 0x961d (correct), 
seq 1619799544:1619801004, ack 2757141216, win 49640, length 1460
15:35:06.153638 IP (tos 0x40, ttl 56, id 41984, offset 0, flags [DF], proto 
TCP (6), length 1500)
    10.148.12.23.3229 > 172.16.128.1.2616: Flags [P.], cksum 0x837f (correct), 
seq 1603048284:1603049744, ack 1511439922, win 49640, length 1460
15:35:07.393657 IP (tos 0x40, ttl 56, id 41985, offset 0, flags [DF], proto 
TCP (6), length 1500)
    10.148.12.23.3229 > 172.16.128.1.4019: Flags [P.], cksum 0x961d (correct), 
seq 0:1460, ack 1, win 49640, length 1460
15:35:11.913425 IP (tos 0x40, ttl 56, id 41986, offset 0, flags [DF], proto 
TCP (6), length 1500)
    10.148.12.23.3229 > 172.16.128.1.4019: Flags [P.], cksum 0x961d (correct), 
seq 0:1460, ack 1, win 49640, length 1460
15:35:20.934013 IP (tos 0x40, ttl 56, id 23204, offset 0, flags [DF], proto 
TCP (6), length 1500)
    10.148.12.23.3229 > 172.16.128.1.4019: Flags [P.], cksum 0x961d (correct), 
seq 0:1460, ack 1, win 49640, length 1460
15:35:26.393357 IP (tos 0x40, ttl 56, id 23205, offset 0, flags [DF], proto 
TCP (6), length 1500)
    10.148.12.23.3229 > 172.16.128.1.4014: Flags [P.], cksum 0x24f2 (correct), 
seq 1570503240:1570504700, ack 585563091, win 49640, length 1460

As you can see there are incoming
1500 bytes packets (these are the
decrypted ipsec packets) with DF
bit set.
These packets are never delivered to
the final client 10.81.128.176 (the
destination address is 172.16.128.1
which is the ip used for SNATing
the original ip 10.81.128.176).

IMHO this is a mtu issue: 1500
bytes packets cannot be routed
inside the ipsec tunnel.

But why linux_gw_snat is not sending
icmp need to frag packets to 10.148.12.23?

Any response are welcome.

TIA
