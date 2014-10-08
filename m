From: Eric Wheeler <netdev@lists.ewheeler.net>
Subject: Re: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Wed, 8 Oct 2014 12:01:34 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1410081157470.16668@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>    <20140929092833.6c2cb7e9@urahara>    <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>    <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>  
 <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>   <alpine.DEB.2.00.1410061956410.7392@ware.dreamhost.com>  <1412651746.11091.98.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.00.1410071746230.3503@ware.dreamhost.com>
 <1412731718.11091.175.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from homie.mail.dreamhost.com ([208.97.132.208]:60099 "EHLO
	homiemail-a9.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753492AbaJHSp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 14:45:56 -0400
In-Reply-To: <1412731718.11091.175.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Oct 2014, Eric Dumazet wrote:

> On Tue, 2014-10-07 at 17:48 -0700, Eric Wheeler wrote:
>
>> Just += unmap->vector.len still did not work (same backtrace), so I've
>> rebuilt with PAGE_SIZE<<2 and so far so good.  I'll let it run all night
>> and see if we get any problems.
>
> Further inspection of the driver told me that unmap->vector.len should
> be 16384 already. (same than PAGE_SIZE << 2)
> (set at line 304, drivers/net/ethernet/brocade/bna/bnad.c)
>
> So you might hit memory fragmentation issues.
>
> Do you have CONFIG_COMPACTION=y in your .config ?

We're still having the backtrace.

Here's nstat -a :

IpInReceives                    305249739          0.0
IpInAddrErrors                  1100               0.0
IpInDelivers                    305232139          0.0
IpOutRequests                   256712718          0.0
IpOutNoRoutes                   197                0.0
IcmpInErrors                    10241              0.0
IcmpInCsumErrors                4200               0.0
IcmpInTimeExcds                 9753               0.0
IcmpInEchoReps                  247                0.0
IcmpInTimestamps                241                0.0
IcmpOutErrors                   10325              0.0
IcmpOutTimeExcds                9792               0.0
IcmpOutEchoReps                 286                0.0
IcmpOutTimestamps               247                0.0
IcmpMsgInType0                  241                0.0
IcmpMsgInType3                  9753               0.0
IcmpMsgInType8                  247                0.0
IcmpMsgOutType0                 247                0.0
IcmpMsgOutType3                 9792               0.0
IcmpMsgOutType8                 286                0.0
TcpActiveOpens                  9585               0.0
TcpPassiveOpens                 1233               0.0
TcpAttemptFails                 8119               0.0
TcpEstabResets                  165                0.0
TcpInSegs                       305269357          0.0
TcpOutSegs                      745563105          0.0
TcpRetransSegs                  9118               0.0
TcpOutRsts                      74110              0.0
UdpInDatagrams                  81957              0.0
UdpOutDatagrams                 141536             0.0
Ip6InReceives                   348168             0.0
Ip6InNoRoutes                   1                  0.0
Ip6InDelivers                   303971             0.0
Ip6OutRequests                  168344             0.0
Ip6InMcastPkts                  183943             0.0
Ip6OutMcastPkts                 7976               0.0
Ip6InOctets                     867026250          0.0
Ip6OutOctets                    843515112          0.0
Ip6InMcastOctets                23885658           0.0
Ip6OutMcastOctets               733912             0.0
Ip6InNoECTPkts                  348168             0.0
Icmp6InMsgs                     139747             0.0
Icmp6OutMsgs                    4120               0.0
Icmp6InGroupMembQueries         3306               0.0
Icmp6InRouterAdvertisements     135646             0.0
Icmp6InNeighborAdvertisements   795                0.0
Icmp6OutRouterSolicits          187                0.0
Icmp6OutNeighborSolicits        77                 0.0
Icmp6OutMLDv2Reports            3856               0.0
Icmp6InType130                  3306               0.0
Icmp6InType134                  135646             0.0
Icmp6InType136                  795                0.0
Icmp6OutType133                 187                0.0
Icmp6OutType135                 77                 0.0
Icmp6OutType143                 3856               0.0
TcpExtSyncookiesFailed          5                  0.0
TcpExtPruneCalled               3694               0.0
TcpExtTW                        882                0.0
TcpExtPAWSEstab                 3                  0.0
TcpExtDelayedACKs               974539             0.0
TcpExtDelayedACKLocked          21365              0.0
TcpExtDelayedACKLost            2071               0.0
TcpExtTCPPrequeued              84806172           0.0
TcpExtTCPDirectCopyFromBacklog  687333144          0.0
TcpExtTCPDirectCopyFromPrequeue 2733255078         0.0
TcpExtTCPPrequeueDropped        915                0.0
TcpExtTCPHPHits                 85972078           0.0
TcpExtTCPHPHitsToUser           790722             0.0
TcpExtTCPPureAcks               119419354          0.0
TcpExtTCPHPAcks                 72305521           0.0
TcpExtTCPRenoRecovery           36                 0.0
TcpExtTCPSackRecovery           431                0.0
TcpExtTCPFACKReorder            8                  0.0
TcpExtTCPSACKReorder            51                 0.0
TcpExtTCPTSReorder              41                 0.0
TcpExtTCPFullUndo               67                 0.0
TcpExtTCPPartialUndo            62                 0.0
TcpExtTCPDSACKUndo              176                0.0
TcpExtTCPLossUndo               11                 0.0
TcpExtTCPLostRetransmit         10                 0.0
TcpExtTCPSackFailures           6                  0.0
TcpExtTCPFastRetrans            715                0.0
TcpExtTCPForwardRetrans         411                0.0
TcpExtTCPSlowStartRetrans       495                0.0
TcpExtTCPTimeouts               3517               0.0
TcpExtTCPLossProbes             2143               0.0
TcpExtTCPLossProbeRecovery      908                0.0
TcpExtTCPRenoRecoveryFail       3                  0.0
TcpExtTCPSchedulerFailed        245                0.0
TcpExtTCPRcvCollapsed           21549              0.0
TcpExtTCPDSACKOldSent           1891               0.0
TcpExtTCPDSACKRecv              1662               0.0
TcpExtTCPAbortOnData            28                 0.0
TcpExtTCPAbortOnClose           242                0.0
TcpExtTCPAbortOnTimeout         18                 0.0
TcpExtTCPDSACKIgnoredNoUndo     928                0.0
TcpExtTCPSpuriousRTOs           5                  0.0
TcpExtTCPSackShifted            479                0.0
TcpExtTCPSackMerged             498                0.0
TcpExtTCPSackShiftFallback      2934               0.0
TcpExtIPReversePathFilter       9407               0.0
TcpExtTCPRetransFail            582                0.0
TcpExtTCPRcvCoalesce            23709443           0.0
TcpExtTCPOFOQueue               19162              0.0
TcpExtTCPChallengeACK           8098               0.0
TcpExtTCPSpuriousRtxHostQueues  2932               0.0
TcpExtTCPAutoCorking            56870637           0.0
IpExtInMcastPkts                87288              0.0
IpExtOutMcastPkts               146507             0.0
IpExtInBcastPkts                16682              0.0
IpExtInOctets                   54665312000        0.0
IpExtOutOctets                  3365913113553      0.0
IpExtInMcastOctets              2765660            0.0
IpExtOutMcastOctets             4688240            0.0
IpExtInBcastOctets              3651661            0.0
IpExtInNoECTPkts                313364477          0.0




--
Eric Wheeler, President           eWheeler, Inc. dba Global Linux Security
888-LINUX26 (888-546-8926)        Fax: 503-716-3878           PO Box 25107
www.GlobalLinuxSecurity.pro       Linux since 1996!     Portland, OR 97298

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
