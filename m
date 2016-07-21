From: =?iso-8859-1?Q?Pommnitz_J=F6rg?= <Pommnitz@iabg.de>
Subject: AW: IPv6 IPSec incompatibilities between 2.6.23 and 3.6.18 (and
 probably later)
Date: Thu, 21 Jul 2016 09:57:42 +0000
Message-ID: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEC4E@ExMbx1.iabg.de>
References: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEB52@ExMbx1.iabg.de>
 <AM4PR0501MB19408B7B4BBFDE17EB980F74DB370@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ilan Tayari <ilant@mellanox.com>,
	Shanker Wang <shankerwangmiao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.iabg.de ([62.245.167.132]:59620 "EHLO mail2.iabg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529AbcGUJ5s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 05:57:48 -0400
In-Reply-To: <AM4PR0501MB19408B7B4BBFDE17EB980F74DB370@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilan and Shanker,
I did as you asked.
Setup: Three nodes all connected to the same Ethernet hub.
Node 1: fd01:1b10:1000::1 is running 3.18.36
Node 2: fd01:1b10:1000::2 is running 2.6.23.12
Node 3: fd01:1b10:1000::3 is running 3.18.36 and generates the traffic =
with the command "ping6 -I lan1 ff0e::1"

All three nodes are configured with the following script (IP6ADDR adjus=
ted for every node):
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DBegin=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
#!/bin/bash

IP6ANYADDR=3D::/0
IP6BCAST=3Dff0e::1
KEY=3D"0x7bef6ecaf06d29ef55b24aca6e19964b332e02e75be676a3"
#IFNAME=3Dradio
IFNAME=3Dlan1
IP6ADDR=3Dfd01:1b10:1000::X
PREFIX6=3D64
SPI=3D0x1

ip link set dev ${IFNAME} up
ip addr add ${IP6ADDR}/${PREFIX6} dev ${IFNAME}
echo "flush; spdflush;" | setkey -c
echo "add ${IP6ADDR} ${IP6BCAST} esp ${SPI} -m tunnel -E aes-cbc ${KEY}=
;" | setkey -c
echo "spdadd ${IP6ANYADDR} ${IP6BCAST} any -P in ipsec esp/tunnel/${IP6=
ADDR}-${IP6BCAST}/require;" | setkey -c
echo "spdadd ${IP6ANYADDR} ${IP6BCAST} any -P out ipsec esp/tunnel/${IP=
6ADDR}-${IP6BCAST}/require;" | setkey -c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DEnd=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

To capture the debug information I used the following script:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DBegin=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
uname -a
echo "tcpdump -lni lan1 -c 5"
tcpdump -lni lan1 -c 5
echo "cat /proc/net/xfrm_stat"
cat /proc/net/xfrm_stat
echo "ip -s xfrm state"
ip -s xfrm state
echo "ip -s xfrm policy"
ip -s xfrm policy
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DEnd=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Debug log from Node 1, Receiver running 3.6.18:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DBegin=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Linux node-0-001 3.18.36-node-5875 #1 Tue Jul 12 14:00:52 CEST 2016 i68=
6 i686 i686 GNU/Linux
tcpdump -lni lan1 -c 5
12:03:09.580943 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x69), length 136
12:03:10.581006 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x6a), length 136
12:03:11.581068 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x6b), length 136
12:03:12.581131 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x6c), length 136
12:03:13.581193 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x6d), length 136
cat /proc/net/xfrm_stat
XfrmInError                     0
XfrmInBufferError               0
XfrmInHdrError                  0
XfrmInNoStates                  0
XfrmInStateProtoError           0
XfrmInStateModeError            0
XfrmInStateSeqError             0
XfrmInStateExpired              0
XfrmInStateMismatch             0
XfrmInStateInvalid              0
XfrmInTmplMismatch              0
XfrmInNoPols                    0
XfrmInPolBlock                  0
XfrmInPolError                  0
XfrmOutError                    0
XfrmOutBundleGenError           0
XfrmOutBundleCheckError         0
XfrmOutNoStates                 0
XfrmOutStateProtoError          0
XfrmOutStateModeError           0
XfrmOutStateSeqError            0
XfrmOutStateExpired             0
XfrmOutPolBlock                 0
XfrmOutPolDead                  0
XfrmOutPolError                 0
XfrmFwdHdrError                 0
XfrmOutStateInvalid             0
XfrmAcquireError                0
ip -s xfrm state
src fd01:1b10:1000::1 dst ff0e::1
        proto esp spi 0x00000001(1) reqid 0(0x00000000) mode tunnel
        replay-window 0 seq 0x00000000 flag  (0x00000000)
        enc cbc(aes) 0x7bef6ecaf06d29ef55b24aca6e19964b332e02e75be676a3=
 (192 bits)
        sel src ::/0 dst ::/0 uid 0
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 12:01:44 use -
        stats:
          replay-window 0 replay 0 failed 0
ip -s xfrm policy
src ::/0 dst ff0e::1/128 uid 0
        dir out action allow index 41 priority 2147483648 share any fla=
g  (0x00000000)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 12:01:44 use -
        tmpl src fd01:1b10:1000::1 dst ff0e::1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tu=
nnel
                level required share any
                enc-mask 00000000 auth-mask 00000000 comp-mask 00000000
src ::/0 dst ff0e::1/128 uid 0
        dir fwd action allow index 34 priority 2147483648 share any fla=
g  (0x00000000)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 12:01:44 use -
        tmpl src fd01:1b10:1000::1 dst ff0e::1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tu=
nnel
                level required share any
                enc-mask 00000000 auth-mask 00000000 comp-mask 00000000
src ::/0 dst ff0e::1/128 uid 0
        dir in action allow index 24 priority 2147483648 share any flag=
  (0x00000000)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 12:01:44 use -
        tmpl src fd01:1b10:1000::1 dst ff0e::1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tu=
nnel
                level required share any
                enc-mask 00000000 auth-mask 00000000 comp-mask 00000000
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DEnd=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Debug log from Node 2, Receiver running 2.6.23.12 (Note: 2.6.23 did not=
 have /proc/net/xfrm_stat):
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DBegin=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Linux node-0-001 2.6.23.12-node-4908 #3 Mon Dec 15 17:28:03 CET 2014 i6=
86 GNU/Linux
tcpdump -lni lan1 -c 5
11:54:06.506723 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x75), length 136
11:54:06.506723 IP6 fd01:1b10:1000::3 > ff0e::1: ICMP6, echo request, s=
eq 117, length 64
11:54:07.506696 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x76), length 136
11:54:07.506696 IP6 fd01:1b10:1000::3 > ff0e::1: ICMP6, echo request, s=
eq 118, length 64
11:54:08.506731 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x77), length 136
cat /proc/net/xfrm_stat
ip -s xfrm state
src fd01:1b10:1000::2 dst ff0e::1
        proto esp spi 0x00000001(1) reqid 0(0x00000000) mode tunnel
        replay-window 0 seq 0x00000000 flag  (0x00000000)
        enc cbc(aes) 0x7bef6ecaf06d29ef55b24aca6e19964b332e02e75be676a3=
 (192 bits)
        sel src ::/0 dst ::/0 uid 0
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          8320(bytes), 80(packets)
          add 2016-07-21 11:52:48 use 2016-07-21 11:52:49
        stats:
          replay-window 0 replay 0 failed 0
ip -s xfrm policy
src ::/0 dst ff0e::1/128 uid 0
        dir in action allow index 24 priority 2147483648 share any flag=
 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 11:52:48 use -
        tmpl src fd01:1b10:1000::2 dst ff0e::1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tu=
nnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
src ::/0 dst ff0e::1/128 uid 0
        dir out action allow index 41 priority 2147483648 share any fla=
g 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 11:52:48 use -
        tmpl src fd01:1b10:1000::2 dst ff0e::1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tu=
nnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
src ::/0 dst ff0e::1/128 uid 0
        dir fwd action allow index 34 priority 2147483648 share any fla=
g 0x00000000
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 11:52:48 use -
        tmpl src fd01:1b10:1000::2 dst ff0e::1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tu=
nnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DEnd=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Debug log from Node 3, Sender running 3.6.18:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DBegin=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Linux node-0-005 3.18.36-node-5875 #1 Tue Jul 12 14:00:52 CEST 2016 i68=
6 i686 i686 GNU/Linux
tcpdump -lni lan1 -c 5
10:27:07.369198 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5b), length 136
10:27:08.369261 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5c), length 136
10:27:09.369323 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5d), length 136
10:27:10.369386 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5e), length 136
10:27:11.369448 IP6 fd01:1b10:1000::3 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5f), length 136
cat /proc/net/xfrm_stat
XfrmInError                     0
XfrmInBufferError               0
XfrmInHdrError                  0
XfrmInNoStates                  0
XfrmInStateProtoError           0
XfrmInStateModeError            0
XfrmInStateSeqError             0
XfrmInStateExpired              0
XfrmInStateMismatch             0
XfrmInStateInvalid              0
XfrmInTmplMismatch              0
XfrmInNoPols                    0
XfrmInPolBlock                  0
XfrmInPolError                  0
XfrmOutError                    0
XfrmOutBundleGenError           0
XfrmOutBundleCheckError         0
XfrmOutNoStates                 0
XfrmOutStateProtoError          0
XfrmOutStateModeError           0
XfrmOutStateSeqError            0
XfrmOutStateExpired             0
XfrmOutPolBlock                 0
XfrmOutPolDead                  0
XfrmOutPolError                 0
XfrmFwdHdrError                 0
XfrmOutStateInvalid             0
XfrmAcquireError                0
ip -s xfrm state
src fd01:1b10:1000::3 dst ff0e::1
        proto esp spi 0x00000001(1) reqid 0(0x00000000) mode tunnel
        replay-window 0 seq 0x00000000 flag  (0x00000000)
        enc cbc(aes) 0x7bef6ecaf06d29ef55b24aca6e19964b332e02e75be676a3=
 (192 bits)
        sel src ::/0 dst ::/0 uid 0
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          9880(bytes), 95(packets)
          add 2016-07-21 10:25:32 use 2016-07-21 10:25:37
        stats:
          replay-window 0 replay 0 failed 0
ip -s xfrm policy
src ::/0 dst ff0e::1/128 uid 0
        dir out action allow index 41 priority 2147483648 share any fla=
g  (0x00000000)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 10:25:32 use 2016-07-21 10:27:11
        tmpl src fd01:1b10:1000::3 dst ff0e::1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tu=
nnel
                level required share any
                enc-mask 00000000 auth-mask 00000000 comp-mask 00000000
src ::/0 dst ff0e::1/128 uid 0
        dir fwd action allow index 34 priority 2147483648 share any fla=
g  (0x00000000)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 10:25:32 use -
        tmpl src fd01:1b10:1000::3 dst ff0e::1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tu=
nnel
                level required share any
                enc-mask 00000000 auth-mask 00000000 comp-mask 00000000
src ::/0 dst ff0e::1/128 uid 0
        dir in action allow index 24 priority 2147483648 share any flag=
  (0x00000000)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2016-07-21 10:25:32 use -
        tmpl src fd01:1b10:1000::3 dst ff0e::1
                proto esp spi 0x00000000(0) reqid 0(0x00000000) mode tu=
nnel
                level required share any
                enc-mask 00000000 auth-mask 00000000 comp-mask 00000000
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DEnd=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

A difference between 2.6.23 and 3.6.18 is the value of the Masks in the=
 policies:

2.6.23: enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
3.6.18: enc-mask 00000000 auth-mask 00000000 comp-mask 00000000

I have no idea, what these masks mean. Is this important?

Regards
  Joerg

> -----Urspr=FCngliche Nachricht-----
> Von: Ilan Tayari [mailto:ilant@mellanox.com]
> Gesendet: Dienstag, 19. Juli 2016 17:04
> An: Pommnitz J=F6rg
> Cc: netdev@vger.kernel.org
> Betreff: RE: IPv6 IPSec incompatibilities between 2.6.23 and 3.6.18 (=
and
> probably later)
>
>  > On the receiving side (e.g. fd01:1b10:1000::1) I see the decrypted
> packets with
> > the 2.6.23 kernel:
> > but NOT with the newer kernel:
>
> Hi Joerg,
>
> First steps to debug this would be:
> cat /proc/net/xfrm_stat
> ip -s xfrm state
> ip -s xfrm policy
>
> First command will show some error accounting, which can point to the
> culprit code.
> Second and third command will show existing objects, and some statist=
ics
> like when the last packet was used with them.
>
> Last thing - for your safety you should keep those session keys priva=
te.
>
> Ilan.

________________________________
Industrieanlagen-Betriebsgesellschaft mbH

Sitz der Gesellschaft: Ottobrunn, Registergericht: Amtsgericht M=FCnche=
n, HRB 5499
Gesch=E4ftsf=FChrung: Prof. Dr.-Ing. Rudolf F. Schwarz
Vorsitzender des Aufsichtsrats: RA Engelbert Kupka MdL a.D.
