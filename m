From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Tue, 13 Jan 2015 14:00:30 -0800
Message-ID: <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54B54C72.8060705@dev.mellanox.co.il>
	 <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
	 <54B590FB.5040805@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Amir Ancel <amira@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Eyal Perry <eyalpe@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:36293 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136AbbAMWAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 17:00:40 -0500
Received: by mail-ie0-f171.google.com with SMTP id ar1so5518433iec.2
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 14:00:39 -0800 (PST)
In-Reply-To: <54B590FB.5040805@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-13 at 23:41 +0200, Eyal Perry wrote:
> On 1/13/2015 22:21 PM, Or Gerlitz wrote:
> > On Tue, Jan 13, 2015 at 8:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> On Tue, 2015-01-13 at 18:48 +0200, Eyal Perry wrote:
> >>> Hello Eric,
> >>> Lately we've observed performance degradation in BW of about 30-40% (depends on
> >>> the setup we use).
> >>> I've bisected the issue down to the this commit: 605ad7f1 ("tcp: refine TSO
> >>> autosizing")
> >>>
> >>> For instance, I was running the following test:
> >>> 1. Bounding net device' irqs to core 0 for both client and server side
> >>> 2. Running netperf with 64K massage size (used the following command)
> >>> $ netperf -H remote -T 1,1 -l 100 -t TCP_STREAM -- -k THROUGHPUT -M 65536 -m 65536
> >>>
> >>> I ran the test on upstream net-next including your patch and than reverted it
> >>> and these are the results I got was improvement from 14.6Gbps to 22.1Gbps.
> >>>
> >>> an additional difference I've noticed when inspecting the ethtool statics,
> >>> number of xmit_more packets increased from 4 to 160 with the reverted kernel.
> >>>
> >>> We are investigating this issue, do you have a hint?
> >> Which driver are you using for this test ?
> > AFAIK, mlx4
> Oops, forgot to mention.
> mlx4 indeed.

Make sure you do not drop packets at receiver.

(Patch might have increased raw speed, and receiver starts dropping
packets because it is not able to sustain line rate on a single flow)

If cwnd is too small, then yes, sending slightly smaller TSO packets can
impact performance, but this is desirable as well.

This is a congestion control problem.


lpaa23:~# nstat >/dev/null; DUMP_TCP_INFO=1 ./netperf -H lpaa24;nstat
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpaa24.prod.google.com () port 0 AF_INET
rto=201000 ato=0 pmtu=1500 rcv_ssthresh=29200 rtt=52 rttvar=2 snd_ssthresh=66 cwnd=102 reordering=3 total_retrans=439 ca_state=0
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    17366.51   
#kernel
IpInReceives                    379010             0.0
IpInDelivers                    379010             0.0
IpOutRequests                   494794             0.0
IcmpInErrors                    1                  0.0
IcmpInTimeExcds                 1                  0.0
IcmpOutErrors                   1                  0.0
IcmpOutTimeExcds                1                  0.0
IcmpMsgInType3                  1                  0.0
IcmpMsgOutType3                 1                  0.0
TcpActiveOpens                  18                 0.0
TcpPassiveOpens                 4                  0.0
TcpAttemptFails                 8                  0.0
TcpEstabResets                  7                  0.0
TcpInSegs                       378992             0.0
TcpOutSegs                      14993053           0.0
TcpRetransSegs                  439                0.0
TcpOutRsts                      28                 0.0
UdpInDatagrams                  16                 0.0
UdpNoPorts                      1                  0.0
UdpOutDatagrams                 17                 0.0
TcpExtTW                        3                  0.0
TcpExtDelayedACKs               1                  0.0
TcpExtTCPPrequeued              1                  0.0
TcpExtTCPHPHits                 14                 0.0
TcpExtTCPPureAcks               301046             0.0
TcpExtTCPHPAcks                 77858              0.0
TcpExtTCPSackRecovery           75                 0.0
TcpExtTCPFastRetrans            439                0.0
TcpExtTCPAbortOnData            7                  0.0
TcpExtTCPSackShifted            17                 0.0
TcpExtTCPSackMerged             57                 0.0
TcpExtTCPSackShiftFallback      234                0.0
TcpExtTCPRcvCoalesce            6                  0.0
TcpExtTCPFastOpenActive         7                  0.0
TcpExtTCPSpuriousRtxHostQueues  2                  0.0
TcpExtTCPAutoCorking            68423              0.0
TcpExtTCPOrigDataSent           14992970           0.0
TcpExtTCPHystartTrainDetect     1                  0.0
TcpExtTCPHystartTrainCwnd       70                 0.0
IpExtInOctets                   19731445           0.0
IpExtOutOctets                  21736126719        0.0
IpExtInNoECTPkts                379010             0.0


You also can see in this sample Hystart ended slow start 
with a very small cwnd of 70
