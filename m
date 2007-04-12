From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection stops after high load.
Date: Thu, 12 Apr 2007 10:59:19 -0700
Message-ID: <461E7377.3020708@candelatech.com>
References: <461D2DEA.4010806@candelatech.com>	<461D447C.4070408@candelatech.com>	<20070411.134804.50594117.davem@davemloft.net>	<461D4DD7.7020207@candelatech.com> <p73y7kx7iol.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:39230 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030651AbXDLR7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 13:59:30 -0400
In-Reply-To: <p73y7kx7iol.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Ben Greear <greearb@candelatech.com> writes:
>> I don't mind adding printks...and I've started reading through the code,
>> but there is a lot of it, and indiscriminate printks will likely just
>> hide the problem because it will slow down performance so much.
> 
> You could add /proc/net/snmp counters for interesting events (e.g. GFP_ATOMIC
> allocations failing). Perhaps netstat -s already shows something interesting.

I will look for more interesting events to add counters for, thanks for
the suggestion.  Thanks for the rest of the suggestions and patches from
others as well, I will be trying those out today and will let you know how
it goes.  I can also try this on the 2.6.20 kernel.

This is on the machine connected to itself.  This is by far the easiest
way to reproduce the problem.  This is from the stalled state.  About 3-5 minutes
later (I wasn't watching too closely), the connection briefly started up again
and then stalled again.  While it is stalled and sending ACKs, the netstat -an
counters remain the same.  It appears this run/stall behaviour happens repeatedly,
as the over-all bits-per-second average overnight was around 90Mbps, and it runs at ~800Mbps
when running full speed.

from netstat -an:
tcp        0 759744 20.20.20.30:33012           20.20.20.20:33011           ESTABLISHED
tcp        0 722984 20.20.20.20:33011           20.20.20.30:33012           ESTABLISHED


I'm not sure if netstat -s shows interesting things or not...it does show a very large
number of packets in and out.  I ran it twice..about 5 seconds apart.  I pasted some
values from the second run on the right-hand side where the numbers looked interesting.
This info is at the bottom of this email.

For GFP_ATOMIC allocations failing, doesn't that show up as order X allocation failure
messages in the kernel (I see no messages of this type.)?


Here is a tcpdump of the connection in the stalled state.  As you can see by
the 'time' output, it's running at around 100,000 packets per second.  tcpdump
dropped the vast majority of these.  Based on the network interface stats, I
believe both sides of the connection are sending acks at about the same
rate (about 160kpps when tcpdump is not running it seems).


10:46:46.541490 IP 20.20.20.20.33011 > 20.20.20.30.33012: . ack 48 win 6132 <nop,nop,timestamp 85158912 84963208>
10:46:46.541494 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
10:46:46.541567 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
10:46:46.541653 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
10:46:46.541886 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
10:46:46.541891 IP 20.20.20.20.33011 > 20.20.20.30.33012: . ack 48 win 6132 <nop,nop,timestamp 85158912 84963208>
10:46:46.541895 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
10:46:46.541988 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
10:46:46.542077 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
10:46:46.542307 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158913 84963208>
10:46:46.542312 IP 20.20.20.20.33011 > 20.20.20.30.33012: . ack 48 win 6132 <nop,nop,timestamp 85158913 84963208>
10:46:46.542321 IP 20.20.20.20.33011 > 20.20.20.30.33012: . ack 48 win 6132 <nop,nop,timestamp 85158913 84963208>
10:46:46.542410 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158913 84963208>
10:46:46.542494 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158913 84963208>
10:46:46.542708 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158913 84963208>
10:46:46.542718 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158913 84963208>
10:46:46.542735 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158913 84963208>
10:46:46.542818 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158913 84963208>
10:46:46.542899 IP 20.20.20.20.33011 > 20.20.20.30.33012: . ack 48 win 6132 <nop,nop,timestamp 85158913 84963208>

4214 packets captured
253889 packets received by filter
244719 packets dropped by kernel

real    0m2.640s
user    0m0.067s
sys     0m0.079s


Two netstat -s outputs....about 5 seconds apart.

[root@lf1001-240 ipv4]# netstat -s
Ip:
     2823452436 total packets received       2840939253 total packets received
     1 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     2823452435 incoming packets delivered   2840939252 incoming packets delivered
     1549687963 requests sent out            1565951477 requests sent out

Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
Tcp:
     77 active connections openings
     74 passive connection openings
     0 failed connection attempts
     122 connection resets received
     10 connections established
     2823426197 segments received            2840914122 segments received
     1549683727 segments send out            1565948373 segments send out
     2171 segments retransmited              2187 segments retransmited
     0 bad segments received.
     2203 resets sent
Udp:
     21739 packets received
     0 packets to unknown port received.
     0 packet receive errors
     4236 packets sent
TcpExt:
     1164 invalid SYN cookies received
     31323 packets pruned from receive queue because of socket buffer overrun    31337
     4 TCP sockets finished time wait in fast timer
     8 packets rejects in established connections because of timestamp
     91542 delayed acks sent                                                     91645
     1902 delayed acks further delayed because of locked socket
     Quick ack mode was activated 2201 times
     2 packets directly queued to recvmsg prequeue.
     1323185164 packets header predicted                                         1324477473
     63077636 acknowledgments not containing data received                       63141338
     17021279 predicted acknowledgments                                          17043867
     2035 times recovered from packet loss due to fast retransmit
     8 times recovered from packet loss due to SACK data
     Detected reordering 13 times using reno fast retransmit
     Detected reordering 642 times using time stamp
     1971 congestion windows fully recovered
     16017 congestion windows partially recovered using Hoe heuristic
     19 congestion windows recovered after partial ack
     0 TCP data loss events
     1 timeouts in loss state
     225 fast retransmits
     3 forward retransmits
     151 other TCP timeouts
     TCPRenoRecoveryFail: 1
     11658529 packets collapsed in receive queue due to low socket buffer        11664170
     123 DSACKs sent for old packets
     70 DSACKs received
     132 connections aborted due to timeout



[root@lf1001-240 ipv4]# netstat -s
Ip:
     2840939253 total packets received
     1 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     2840939252 incoming packets delivered
     1565951477 requests sent out
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
Tcp:
     77 active connections openings
     74 passive connection openings
     0 failed connection attempts
     122 connection resets received
     10 connections established
     2840914122 segments received
     1565948373 segments send out
     2187 segments retransmited
     0 bad segments received.
     2203 resets sent
Udp:
     21755 packets received
     0 packets to unknown port received.
     0 packet receive errors
     4239 packets sent
TcpExt:
     1164 invalid SYN cookies received
     31337 packets pruned from receive queue because of socket buffer overrun
     4 TCP sockets finished time wait in fast timer
     8 packets rejects in established connections because of timestamp
     91645 delayed acks sent
     1912 delayed acks further delayed because of locked socket
     Quick ack mode was activated 2217 times
     2 packets directly queued to recvmsg prequeue.
     1324477473 packets header predicted
     63141338 acknowledgments not containing data received
     17043867 predicted acknowledgments
     2037 times recovered from packet loss due to fast retransmit
     8 times recovered from packet loss due to SACK data
     Detected reordering 13 times using reno fast retransmit
     Detected reordering 642 times using time stamp
     1973 congestion windows fully recovered
     16021 congestion windows partially recovered using Hoe heuristic
     19 congestion windows recovered after partial ack
     0 TCP data loss events
     1 timeouts in loss state
     225 fast retransmits
     3 forward retransmits
     153 other TCP timeouts
     TCPRenoRecoveryFail: 1
     11664170 packets collapsed in receive queue due to low socket buffer
     123 DSACKs sent for old packets
     70 DSACKs received
     132 connections aborted due to timeout



> 
> -Andi
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

