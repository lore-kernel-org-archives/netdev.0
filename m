From: =?ISO-8859-1?Q?Roar_Bj=F8rgum_Rotvik?= <roarbr@tihlde.org>
Subject: Problems with xfrm (IPSec) and multicast
Date: Wed, 14 Jun 2006 15:09:59 +0200
Message-ID: <44900AA7.90800@tihlde.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from [80.239.6.50] ([80.239.6.50]:14588 "EHLO
	ici-lnx1.sici.thales.no") by vger.kernel.org with ESMTP
	id S964905AbWFNNKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 09:10:04 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have configured two Linux PC's to use IPSec to encrypt some mcast tra=
ffic, using "ip=20
xfrm". Each PC has two network cards, one connected to a LAN (unencrypt=
ed side, also=20
called red side) and one connected to the other node (encrypted side, a=
lso called black side).
Currently the setup uses static keys in the SA entries, so IKE is not a=
 problem.

|<-- RED side -->|<- BLACK network ->|<-- RED side -->|
+-------+   +---------+           +---------+   +-------+
| LAN A +---+ IPSEC-A +-----------+ IPSEC-B +---+ LAN B |
+-------+   +---------+           +---------+   +-------+
10.0.10.0/24          192.168.0.0/24          10.0.20.0/24

Configuration:
Kernel tested: Linux-2.6.16.13 + 2.6.17-rc4
LAN A: 10.0.10.0/24
LAN B: 10.0.20.0/24
IPSEC-A: RED IP: 10.0.10.1, BLACK IP: 192.168.0.1
IPSEC-B: RED IP: 10.0.20.1, BLACK IP: 192.168.0.2
RED mcast group used: 239.192.20.1
BLACK mcast group used: 239.192.10.1

IPSEC-A SA and SP entries:
[root@ipsec-a ~]# ip xfrm state
src 192.168.0.1 dst 239.192.10.1
         proto esp spi 0x00000001 reqid 0 mode tunnel
         replay-window 4
         auth sha1 0x00000000010000000002000000000301
         enc aes 0x000000000000000000000000000000000000000000000001
         encap type espinudp sport 4500 dport 4500 addr 0.0.0.0

[root@ipsec-a ~]# ip xfrm policy
src 0.0.0.0/0 dst 239.192.20.1/32
         dir in priority 2147483648
         tmpl src 192.168.0.1 dst 239.192.10.1
                 proto esp reqid 0 mode tunnel
src 10.0.10.0/24 dst 239.192.20.1/32
         dir out priority 2147483648
         tmpl src 192.168.0.1 dst 239.192.10.1
                 proto esp reqid 0 mode tunnel
src 0.0.0.0/0 dst 239.192.20.1/32
         dir fwd priority 2147483648
         tmpl src 192.168.0.1 dst 239.192.10.1
                 proto esp reqid 0 mode tunnel

(The entries for IPSEC-B is similar, but the address 192.168.0.1 is cha=
nged to the IPSEC-B=20
BLACK IP 192.168.0.2).
And I have a small userspace app that opens a socket and bind to port 4=
500 and issue=20
setsockopt (fd, SOL_UDP, UDP_ENCAP) so that the kernel will accept UDP =
encap ESP packets.

When I send multicast traffic from IPSEC-A (bound to the RED interface =
10.0.10.1) to mcast=20
group 239.192.20.1, the traffic matches the out SP entry and is encrypt=
ed according to the=20
SA entry and sent as UDP encap ESP to mcast group 239.192.10.1 on the B=
LACK network.

On IPSEC-B the UDP encap ESP packet is decrypted and is visible for use=
rspace processes.=20
So far so good.

But then I start sending similar mcast traffic the other way, but from =
IPSEC-B (bound to=20
IPSEC-B RED IP 10.0.20.1). This traffic is also encrypted and sent to I=
PSEC-A.

But this packet is not decrypted at IPSEC-A, it seems to disappear. The=
 IP and UDP SNMP=20
counters increase for the received UDP encap ESP packet, but I cannot s=
ee what happens to=20
the packet after the UDP layer. Seems like it is dropped somewhere in X=
=46RM?

By sending some more packets from IPSEC-B (roughly 5-8 more packets), t=
hese packets=20
suddenly starts to be decrypted at IPSEC-A and all is well. Until I sta=
rt traffic the=20
other way around again, when the same problem occurs at IPSEC-B.

So I cannot make encrypted multicast traffic to flow both ways at the s=
ame time, and has=20
no clue as to why the first packets after changing direction is dropped=
 somewhere.

Anyone have a clue to this observed problem with linux xfrm and multica=
st or a better=20
solution for encrypted multicast on linux 2.6.x?

Any help with this is appreciated and more info (tcpdump, snmp stats an=
d so on) can be=20
obtained if needed.

--=20
Roar Bj=F8rgum Rotvik
