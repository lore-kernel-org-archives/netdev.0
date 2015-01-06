From: Erik Grinaker <erik@bengler.no>
Subject: Re: TCP connection issues against Amazon S3
Date: Tue, 6 Jan 2015 16:11:27 +0000
Message-ID: <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no> <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49057 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751785AbbAFQL3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 11:11:29 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 25DEE20A44
	for <netdev@vger.kernel.org>; Tue,  6 Jan 2015 11:11:29 -0500 (EST)
In-Reply-To: <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 06 Jan 2015, at 16:04, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-01-06 at 15:14 +0000, Erik Grinaker wrote:
>> (CCing Yuchung, as his name comes up in the relevant commits)
>> 
>> After upgrading from Ubuntu 12.04.5 to 14.04.1 we have begun seeing
>> intermittent TCP connection hangs for HTTP image requests against
>> Amazon S3. 3-5% of requests will suddenly stall in the middle of the
>> transfer before timing out. We see this problem across a range of
>> servers, in several data centres and networks, all located in Norway.
>> 
>> A packet dump [1] shows repeated ACK retransmits for some of the
>> requests. Using Ubuntu mainline kernels, we found the problem to have
>> been introduced between 3.11.10 and 3.12.0, possibly in
>> 0f7cc9a3c2bd89b15720dbf358e9b9e62af27126. The problem is also present
>> in 3.18.1. Disabling tcp_window_scaling seems to solve it, but has
>> obvious drawbacks for transfer speeds. Other sysctls do not seem to
>> affect it.
>> 
>> I am not sure if this is fundamentally a kernel bug or a network
>> issue, but we did not see this problem with older kernels.
>> 
>> [1] http://abstrakt.bengler.no/tcp-issues-s3.pcap.bz2
> 
> 
> CC netdev
> 
> This looks like the bug we fixed here :
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=39bb5e62867de82b269b07df900165029b928359

Has that patch gone into a release? Because the problem persists with 3.18.1.

> Could you post output of 'nstat' command ?

Sure:

#kernel
IpInReceives                    1676194            0.0
IpInDelivers                    1676115            0.0
IpOutRequests                   1163105            0.0
IcmpInErrors                    826                0.0
IcmpInEchoReps                  826                0.0
IcmpOutErrors                   824                0.0
IcmpOutTimeExcds                10                 0.0
IcmpOutTimestamps               814                0.0
IcmpMsgInType8                  826                0.0
IcmpMsgOutType0                 814                0.0
IcmpMsgOutType3                 10                 0.0
TcpActiveOpens                  2004               0.0
TcpPassiveOpens                 1102               0.0
TcpAttemptFails                 5                  0.0
TcpEstabResets                  34                 0.0
TcpInSegs                       1667699            0.0
TcpOutSegs                      1159990            0.0
TcpRetransSegs                  26                 0.0
TcpOutRsts                      504                0.0
UdpInDatagrams                  2002               0.0
UdpOutDatagrams                 2087               0.0
Ip6InReceives                   1                  0.0
Ip6InNoRoutes                   1                  0.0
Ip6OutRequests                  10                 0.0
Ip6OutDiscards                  3                  0.0
Ip6OutNoRoutes                  1                  0.0
Ip6OutMcastPkts                 7                  0.0
Ip6InOctets                     76                 0.0
Ip6OutOctets                    728                0.0
Ip6OutMcastOctets               520                0.0
Ip6InNoECTPkts                  1                  0.0
Icmp6OutMsgs                    4                  0.0
Icmp6OutNeighborSolicits        1                  0.0
Icmp6OutMLDv2Reports            3                  0.0
Icmp6OutType135                 1                  0.0
Icmp6OutType143                 3                  0.0
TcpExtEmbryonicRsts             5                  0.0
TcpExtPruneCalled               1                  0.0
TcpExtTW                        1897               0.0
TcpExtDelayedACKs               3058               0.0
TcpExtDelayedACKLocked          13                 0.0
TcpExtDelayedACKLost            2330               0.0
TcpExtTCPPrequeued              3084               0.0
TcpExtTCPDirectCopyFromPrequeue 10944              0.0
TcpExtTCPHPHits                 1246417            0.0
TcpExtTCPPureAcks               7512               0.0
TcpExtTCPHPAcks                 3219               0.0
TcpExtTCPSackRecovery           2                  0.0
TcpExtTCPLossUndo               4                  0.0
TcpExtTCPFastRetrans            2                  0.0
TcpExtTCPTimeouts               18                 0.0
TcpExtTCPLossProbes             145                0.0
TcpExtTCPLossProbeRecovery      125                0.0
TcpExtTCPSackRecoveryFail       1                  0.0
TcpExtTCPRcvCollapsed           22                 0.0
TcpExtTCPDSACKOldSent           43                 0.0
TcpExtTCPDSACKRecv              3                  0.0
TcpExtTCPAbortOnData            113                0.0
TcpExtTCPDSACKIgnoredNoUndo     3                  0.0
TcpExtTCPSpuriousRTOs           2                  0.0
TcpExtTCPSackShiftFallback      3                  0.0
TcpExtTCPRcvCoalesce            927994             0.0
TcpExtTCPOFOQueue               300911             0.0
TcpExtTCPOFOMerge               76                 0.0
TcpExtTCPSpuriousRtxHostQueues  24                 0.0
IpExtInBcastPkts                5588               0.0
IpExtInOctets                   2454079082         0.0
IpExtOutOctets                  56232776           0.0
IpExtInBcastOctets              3218688            0.0
IpExtInNoECTPkts                1676194            0.0
