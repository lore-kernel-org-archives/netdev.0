From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Wed, 26 Aug 2009 12:29:34 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908261223210.9933@gentwo.org>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org> <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, niv@linux.vnet.ibm.com,
	sri@linux.vnet.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:40542 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751287AbZHZQaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 12:30:09 -0400
In-Reply-To: <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2009, Sridhar Samudrala wrote:

> Could you check if the UDP packet losses you are seeing are accounted for in
> qdisc drops with this patch. But i am not completely positive on this as this
> case happens only if qdisc is deactivated.

This does not work. qdisc drops are still not reported. They are reported
for IP and UDP.

Test tool crashes on first TX overrun:

clameter@rd-strategy3-deb64:~$ ./mcast -n1 -r400000
Receiver: Listening to control channel 239.0.192.1
Receiver: Subscribing to 0 MC addresses 239.0.192-254.2-254 offset 0
origin 10.2.36.123
Sender: Sending 400000 msgs/ch/sec on 1 channels. Probe interval=0.001-1
sec.
sendto: No buffer space available
Socket Send error

netstat reports exactly one packet loss:


clameter@rd-strategy3-deb64:~$ netstat -su
IcmpMsg:
    InType3: 1
    OutType3: 1
Udp:
    298 packets received
    0 packets to unknown port received.
    0 packet receive errors
    7232136 packets sent
    SndbufErrors: 1

root@rd-strategy3-deb64:/home/clameter#tc -s qdisc show
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1
1 1 1 1
 Sent 6208 bytes 64 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

SNMP report one drop:

root@rd-strategy3-deb64:/home/clameter#cat /proc/net/snmp
Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors
ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests
OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails
FragOKs FragFails FragCreates
Ip: 2 64 1114 0 0 0 0 0 1114 7232754 1 0 0 0 0 0 0 0 0
Icmp: InMsgs InErrors InDestUnreachs InTimeExcds InParmProbs InSrcQuenchs
InRedirects InEchos InEchoReps InTimestamps InTimestampReps InAddrMasks
InAddrMaskReps OutMsgs OutErrors OutDestUnreachs OutTimeExcds OutParmProbs
OutSrcQuenchs OutRedirects OutEchos OutEchoReps OutTimestamps
OutTimestampReps OutAddrMasks OutAddrMaskReps
Icmp: 1 0 1 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0
IcmpMsg: InType3 OutType3
IcmpMsg: 1 1
Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens
AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs
OutRsts
Tcp: 1 200 120000 -1 26 4 0 0 2 774 595 0 0 0
Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufErrors
Udp: 308 0 0 7232146 0 1
UdpLite: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors
SndbufErrors
UdpLite: 0 0 0 0 0 0

