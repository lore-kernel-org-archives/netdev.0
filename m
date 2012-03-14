From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Wed, 14 Mar 2012 22:33:43 +0200
Message-ID: <20120314223343.23dc9df3@vostro>
References: <20120314190156.622c8cd5@vostro>
	<1331745314.6022.27.camel@edumazet-glaptop>
	<20120314192945.65867e9f@vostro>
	<1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com>
	<20120314215142.655ae607@vostro>
	<1331755965.6022.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38551 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530Ab2CNUeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 16:34:18 -0400
Received: by wejx9 with SMTP id x9so2132387wej.19
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 13:34:17 -0700 (PDT)
In-Reply-To: <1331755965.6022.55.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Mar 2012 13:12:45 -0700 Eric Dumazet
<eric.dumazet@gmail.com> wrote:

> On Wed, 2012-03-14 at 21:51 +0200, Timo Teras wrote:
> 
> > Very good point. I thought gso also enabled gro, but seems that my
> > ethtool was old.
> > 
> > And GRO was enabled along with some other stuff. Turning GRO off
> > made my tcp performance immediately a lot better; jumped from 2MB/s
> > to 8MB/s or so (not ideal yet, though; but the remainder of the
> > difference could be related to other issue).
> > 
> > So something is definitely broke in 3.0.x with GRO enabled, but GSO
> > off.
> 
> "ifconfig eth2 ; netstat -s" can really help, I suspect tcp stack
> drops

After doing several wget's that have "bad performance".

# ifconfig eth2
eth2      Link encap:Ethernet  HWaddr 00:30:18:AB:6B:56  
          inet addr:10.26.0.2  Bcast:0.0.0.0  Mask:255.255.255.252
          inet6 addr: fe80::230:18ff:feab:6b56/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:32334060 errors:0 dropped:0 overruns:0 frame:0
          TX packets:18520452 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1775070027 (1.6 GiB)  TX bytes:1962364861 (1.8 GiB)
          Interrupt:16 Base address:0xc000 

# ethtool -S eth2
NIC statistics:
     tx_packets: 2069391193
     rx_packets: 3245815642
     tx_errors: 0
     rx_errors: 645238
     rx_missed: 31414
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 3245815640
     broadcast: 2
     multicast: 0
     tx_aborted: 0
     tx_underrun: 0

netstat is busybox, so no -s. But /proc/net/netstat as parsed looks
like:
SyncookiesSent 0 
SyncookiesRecv 0 
SyncookiesFailed 3 
EmbryonicRsts 0 
PruneCalled 0 
RcvPruned 0 
OfoPruned 0 
OutOfWindowIcmps 0 
LockDroppedIcmps 0 
ArpFilter 0 
TW 15 
TWRecycled 0 
TWKilled 0 
PAWSPassive 0 
PAWSActive 0 
PAWSEstab 0 
DelayedACKs 564 
DelayedACKLocked 5 
DelayedACKLost 0 
ListenOverflows 0 
ListenDrops 0 
TCPPrequeued 73 
TCPDirectCopyFromBacklog 605264 
TCPDirectCopyFromPrequeue 15961 
TCPPrequeueDropped 0 
TCPHPHits 191774 
TCPHPHitsToUser 425 
TCPPureAcks 19228 
TCPHPAcks 112359 
TCPRenoRecovery 0 
TCPSackRecovery 2 
TCPSACKReneging 0 
TCPFACKReorder 0 
TCPSACKReorder 4 
TCPRenoReorder 0 
TCPTSReorder 2 
TCPFullUndo 2 
TCPPartialUndo 107 
TCPDSACKUndo 0 
TCPLossUndo 0 
TCPLoss 0 
TCPLostRetransmit 0 
TCPRenoFailures 0 
TCPSackFailures 0 
TCPLossFailures 0 
TCPFastRetrans 2 
TCPForwardRetrans 2 
TCPSlowStartRetrans 0 
TCPTimeouts 0 
TCPRenoRecoveryFail 0 
TCPSackRecoveryFail 0 
TCPSchedulerFailed 0 
TCPRcvCollapsed 0 
TCPDSACKOldSent 0 
TCPDSACKOfoSent 0 
TCPDSACKRecv 4 
TCPDSACKOfoRecv 0 
TCPAbortOnSyn 0 
TCPAbortOnData 6 
TCPAbortOnClose 4 
TCPAbortOnMemory 0 
TCPAbortOnTimeout 0 
TCPAbortOnLinger 0 
TCPAbortFailed 0 
TCPMemoryPressures 0 
TCPSACKDiscard 0 
TCPDSACKIgnoredOld 0 
TCPDSACKIgnoredNoUndo 0 
TCPSpuriousRTOs 0 
TCPMD5NotFound 0 
TCPMD5Unexpected 0 
TCPSackShifted 0 
TCPSackMerged 0 
TCPSackShiftFallback 4484 
TCPBacklogDrop 0 
TCPMinTTLDrop 0 
TCPDeferAcceptDrop 0 
IPReversePathFilter 4 
TCPTimeWaitOverflow 0 
