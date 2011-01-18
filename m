From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Wed, 19 Jan 2011 01:22:12 +0300
Message-ID: <4D361294.2060304@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	Christophe Paasch <christoph.paasch@uclouvain.be>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elephant.yandex.ru ([77.88.34.7]:26454 "EHLO elephant.yandex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136Ab1ARWWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 17:22:16 -0500
In-Reply-To: <28837.1295382268@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jay Vosburgh wrote:
> 
> 	One item I'd like to see some more data on is the level of
> reordering at the receiver in Oleg's system.
> 
> 	One of the reasons round robin isn't as useful as it once was is
> due to the rise of NAPI and interrupt coalescing, both of which will
> tend to increase the reordering of packets at the receiver when the
> packets are evenly striped.  In the old days, it was one interrupt, one
> packet.  Now, it's one interrupt or NAPI poll, many packets.  With the
> packets striped across interfaces, this will tend to increase
> reordering.  E.g.,
> 
> 	slave 1		slave 2		slave 3
> 	Packet 1	P2		P3
> 	P4		P5		P6
> 	P7		P8		P9
> 
> 	and so on.  A poll of slave 1 will get packets 1, 4 and 7 (and
> probably several more), then a poll of slave 2 will get 2, 5 and 8, etc.
> 
> 	I haven't done much testing with this lately, but I suspect this
> behavior hasn't really changed.  Raising the tcp_reordering sysctl value
> can mitigate this somewhat (by making TCP more tolerant of this), but
> that doesn't help non-TCP protocols.
> 
> 	Barring evidence to the contrary, I presume that Oleg's system
> delivers out of order at the receiver.  That's not automatically a
> reason to reject it, but this entire proposal is sufficiently complex to
> configure that very explicit documentation will be necessary.

Jay, here is some network stats from one of my iSCSI targets with avg 
load of 1.5-2.5Gbit/sec(4 slaves in etherchannel).Not perfect and not 
very "clean"(there are more interfaces on host, than these 4)
[root@<somehost> ~]# netstat -st 

IcmpMsg: 

     InType0: 6 

     InType3: 1872 

     InType8: 60557 

     InType11: 23 

     OutType0: 60528 

     OutType3: 1755 

     OutType8: 6 

Tcp: 

     1298909 active connections openings 

     61090 passive connection openings 

     2374 failed connection attempts 

     62781 connection resets received 

     3 connections established 

     1268233942 segments received 

     1198020318 segments send out 

     18939618 segments retransmited 

     0 bad segments received. 

     23643 resets sent 

TcpExt:
     294935 TCP sockets finished time wait in fast timer
     472 time wait sockets recycled by time stamp
     819481 delayed acks sent
     295332 delayed acks further delayed because of locked socket
     Quick ack mode was activated 30616377 times
     3516920 packets directly queued to recvmsg prequeue.
     4353 packets directly received from backlog
     44873453 packets directly received from prequeue
     1442812750 packets header predicted
     1077442 packets header predicted and directly queued to user
     2123453975 acknowledgments not containing data received
     2375328274 predicted acknowledgments
     8462439 times recovered from packet loss due to fast retransmit
     Detected reordering 19203 times using reno fast retransmit
     Detected reordering 100 times using time stamp
     3429 congestion windows fully recovered
     11760 congestion windows partially recovered using Hoe heuristic
     398 congestion windows recovered after partial ack
     0 TCP data loss events
     3671 timeouts after reno fast retransmit
     6 timeouts in loss state
     18919118 fast retransmits
     11637 retransmits in slow start
     1756 other TCP timeouts
     TCPRenoRecoveryFail: 3187
     62779 connections reset due to early user close
IpExt:
     InBcastPkts: 512616
[root@<somehost> ~]# uptime
  00:35:49 up 42 days,  8:27,  1 user,  load average: 3.70, 3.80, 4.07
[root@<somehost> ~]# sysctl -a|grep tcp_reo
net.ipv4.tcp_reordering = 3

I will get back with "clean" results after I'll setup test system tomorrow.
TcpExt stats from other hosts are similar.

> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 

-- 
Best regards,
Oleg Ukhno
