From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Bnx2x Checksum/Length Error Over GRE Tunnel
Date: Tue, 03 Feb 2015 10:46:36 -0800
Message-ID: <1422989196.907.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54D0A345.2030108@skyatlas.com> <54D10DFE.1070604@skyatlas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: Eren =?ISO-8859-1?Q?T=FCrkay?= <erent@skyatlas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:44220 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbbBCSqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 13:46:38 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so26490382igb.2
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 10:46:38 -0800 (PST)
In-Reply-To: <54D10DFE.1070604@skyatlas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-03 at 20:05 +0200, Eren T=C3=BCrkay wrote:
> Hello,
>=20
> I am having incorrect checksum and length calculation error when usin=
g
> GRE tunnel and this leads to unstable/unreliable connections where ev=
en
> simple nc connection cannot be made correctly due to a lot of TCP
> retransmissions. The reported iperf output becomes 23Kbit/s.
>=20
> When I disable tx checksumming with "ethtool -K eth0 tx off", the
> problem seems to be solved but then I lose tcp segmentation offloadin=
g
> support, without which adds an additional overhead on 10Gbit network
> interface. With tx off, I get 4 to 7Gbit/s with parallel 40 connectio=
ns
> using iperf.
>=20
> In tcpdump output (tcpdump -i em1 proto gre) when tx checksumming is
> enabled, I see "checksum error" in every packet + "IP truncated-ip -
> 63631 bytes missing!" messages, and a lot of TCP
> retransmissions. When tx is off, checksums are correct but I get 4-7G=
bit
> output. With GSO generalization code in [0] it is reported that
> 9.3Gbit/s is possible over GRE tunnel but I'm nowhere near these resu=
lts.

Strange, I am using bnx2x with no such problem.

Please note that tcpdump can display "checksum error" because it doesn'=
t
always know the NIC will generate the checksums.

Can you please send : ifconfig -a, as I suspect an MTU issue

Here I easily reach line rate with a single flow.

ip tunnel add gre1 mode gre remote 10.246.11.52 local 10.246.11.51
ip link set gre1 up
ip addr add 7.7.8.51/24 dev gre1


lpk51:~# ip ro get 7.7.8.52
7.7.8.52 dev gre1  src 7.7.8.51=20
    cache  expires 557sec mtu 1476

lpk51:~# ./netperf -H 7.7.8.52 -Cc
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.8=
=2E52 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   =
us/KB

 87380  16384  16384    10.00      9227.94   2.52     3.96     0.715   =
1.125 =20
