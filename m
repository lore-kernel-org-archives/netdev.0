From: Eyal Perry <eyalpe@dev.mellanox.co.il>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Sun, 18 Jan 2015 18:22:33 +0200
Message-ID: <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com>
References: <54B54C72.8060705@dev.mellanox.co.il>
	<1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
	<54B590FB.5040805@dev.mellanox.co.il>
	<1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Amir Ancel <amira@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:54183 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbbARQWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 11:22:34 -0500
Received: by mail-oi0-f50.google.com with SMTP id v63so5145227oia.9
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 08:22:33 -0800 (PST)
In-Reply-To: <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 12:00 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Make sure you do not drop packets at receiver. (Patch might have increased raw speed, and receiver starts dropping packets because it is not able to sustain line rate on a single flow)

Hi Eric,

I double checked that there are no drops on the receiver (ifconfig,
ethtool, and net_dropmonitor).

> If cwnd is too small, then yes, sending slightly smaller TSO packets can impact performance, but this is desirable as well. This is a congestion control problem.

How can we reliably measure the cwnd? tpci_snd_cwnd is not consistent
across runs.
Anyway, we don't see difference in the TSO packets size (see results below).

> lpaa23:~# nstat >/dev/null; DUMP_TCP_INFO=1 ./netperf -H lpaa24;nstat
[...]
>
> You also can see in this sample Hystart ended slow start with a very small cwnd of 70

We see the issue also on very long runs so I don't understand how is
it related to the slow start mechanism.


Below, are two measurements with all the statistics.
* with your patch:
$ nstat >/dev/null; netperf -H remote;nstat
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
11.11.11.36 () port 0 AF_INET
tcpi_rto 204000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
tcpi_rtt 79 tcpi_rttvar 14 tcpi_snd_ssthresh 214 tpci_snd_cwnd 634
tcpi_reordering 3 tcpi_total_retrans 0
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    18537.46
#kernel
IpInReceives                    260728             0.0
IpInDelivers                    260728             0.0
IpOutRequests                   355684             0.0
TcpActiveOpens                  2                  0.0
TcpInSegs                       260729             0.0
TcpOutSegs                      16004157           0.0
UdpInDatagrams                  1                  0.0
UdpOutDatagrams                 7                  0.0
UdpIgnoredMulti                 1                  0.0
Ip6InReceives                   4                  0.0
Ip6InDelivers                   4                  0.0
Ip6OutRequests                  3                  0.0
Ip6InMcastPkts                  1                  0.0
Ip6InOctets                     288                0.0
Ip6OutOctets                    856                0.0
Ip6InMcastOctets                72                 0.0
Ip6InNoECTPkts                  4                  0.0
Icmp6InMsgs                     1                  0.0
Icmp6InNeighborAdvertisements   1                  0.0
Icmp6InType136                  1                  0.0
TcpExtDelayedACKs               2                  0.0
TcpExtTCPHPHits                 3                  0.0
TcpExtTCPPureAcks               208131             0.0
TcpExtTCPHPAcks                 52591              0.0
TcpExtTCPAutoCorking            49920              0.0
TcpExtTCPOrigDataSent           16004146           0.0
TcpExtTCPHystartTrainDetect     1                  0.0
TcpExtTCPHystartTrainCwnd       214                0.0
IpExtInBcastPkts                1                  0.0
IpExtInOctets                   13560399           0.0
IpExtOutOctets                  23192484354        0.0
IpExtInBcastOctets              367                0.0
IpExtInNoECTPkts                260728             0.0

* And without it:
$ nstat >/dev/null; netperf -H remote;nstat
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
11.11.11.37 () port 0 AF_INET
tcpi_rto 204000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
tcpi_rtt 108 tcpi_rttvar 13 tcpi_snd_ssthresh 801 tpci_snd_cwnd 809
tcpi_reordering 64 tcpi_total_retrans 6
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    26826.32
#kernel
IpInReceives                    431716             0.0
IpInDelivers                    431716             0.0
IpOutRequests                   521537             0.0
TcpActiveOpens                  2                  0.0
TcpInSegs                       431676             0.0
TcpOutSegs                      23164903           0.0
TcpRetransSegs                  6                  0.0
UdpInDatagrams                  3                  0.0
UdpOutDatagrams                 1                  0.0
UdpIgnoredMulti                 40                 0.0
Ip6InReceives                   4                  0.0
Ip6InDelivers                   4                  0.0
Ip6OutRequests                  4                  0.0
Ip6InOctets                     288                0.0
Ip6OutOctets                    928                0.0
Ip6InNoECTPkts                  4                  0.0
Icmp6InMsgs                     1                  0.0
Icmp6OutMsgs                    1                  0.0
Icmp6InNeighborAdvertisements   1                  0.0
Icmp6OutNeighborSolicits        1                  0.0
Icmp6InType136                  1                  0.0
Icmp6OutType135                 1                  0.0
TcpExtDelayedACKs               1                  0.0
TcpExtTCPHPHits                 2                  0.0
TcpExtTCPPureAcks               291894             0.0
TcpExtTCPHPAcks                 139775             0.0
TcpExtTCPSackRecovery           5                  0.0
TcpExtTCPTSReorder              1                  0.0
TcpExtTCPPartialUndo            1                  0.0
TcpExtTCPDSACKUndo              4                  0.0
TcpExtTCPFastRetrans            6                  0.0
TcpExtTCPDSACKRecv              6                  0.0
TcpExtTCPDSACKIgnoredNoUndo     1                  0.0
TcpExtTCPSackShifted            46436              0.0
TcpExtTCPSackMerged             1306               0.0
TcpExtTCPSackShiftFallback      4414               0.0
TcpExtTCPAutoCorking            274120             0.0
TcpExtTCPOrigDataSent           23164893           0.0
TcpExtTCPHystartTrainDetect     1                  0.0
TcpExtTCPHystartTrainCwnd       71                 0.0
IpExtInBcastPkts                42                 0.0
IpExtInOctets                   23066435           0.0
IpExtOutOctets                  33567160556        0.0
IpExtInBcastOctets              4275               0.0
IpExtInNoECTPkts                431716             0.0


Please let me know if you see something in the results.

Regards,
Eyal.
