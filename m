From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: network stream fairness
Date: Mon, 9 Nov 2015 17:50:29 +0100
Message-ID: <5640CED5.6040103@axis.com>
References: <5640BEAC.10404@axis.com>	 <1447084258.17135.39.camel@edumazet-glaptop2.roam.corp.google.com>	 <5640C15E.805@axis.com>	 <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com> <1447086271.17135.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:36280 "EHLO bes.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbbKIQud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2015 11:50:33 -0500
In-Reply-To: <1447086271.17135.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2015 05:24 PM, Eric Dumazet wrote:
> On Mon, 2015-11-09 at 08:07 -0800, Eric Dumazet wrote:
> 
>> Your numbers suggest a cwnd growth then, which might show a CC bug.
>>
>> Please run the following when your iper3 runs on regular 4.3 kernel
>>
>> for i in `seq 1 10`
>> do
>> ss -temoi dst 192.168.0.141
>> sleep 1
>> done
>>

See output at the end of the mail.

iperf3 output sample:
[  4]  24.00-24.53  sec  1.92 MBytes  30.2 Mbits/sec                  
[  6]  24.00-24.53  sec  3.84 MBytes  60.5 Mbits/sec                  
[SUM]  24.00-24.53  sec  5.76 MBytes  90.7 Mbits/sec     


> 
> Another thing to try is to change tcp_limit_output_bytes back to 131072

I tried both

sysctl -w net.ipv4.tcp_limit_output_bytes=131072
sysctl -w net.ipv4.tcp_limit_output_bytes=13107

Neither appears to solve the problem.

I don't know why but
echo 3000 > /sys/class/net/eth0/queues/tx-0/byte_queue_limits/limit_max
solves it. Feels weird that setting tcp_limit_output_bytes doesn't fix it.

> 
> Of course, your driver be the problem as well, but I am guessing it is
> not upstream ?

It's not upstreamed, but it is GPL, so I could probably upload it somewhere
if that helps.






for i in `seq 1 20`; do ss -temoi dst 192.168.0.141; sleep 1; done
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      106                              192.168.0.1:54574                           192.168.0.141:5201     timer:(on,190ms,0) rto:0.2 ato:0.04 cwnd:10 qack:14 bidir uid:20283 ino:7902591 sk:ffff880223311800
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      1448   0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      1448   0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      1448   0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      1448   0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
State      Recv-Q Send-Q                         Local Address:Port                             Peer Address:Port   
ESTAB      0      0                                192.168.0.1:54576                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901837 sk:ffff880143735800
ESTAB      0      0                                192.168.0.1:54574                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 qack:10 uid:20283 ino:7902591 sk:ffff880223311800
ESTAB      0      0                                192.168.0.1:54578                           192.168.0.141:5201     rto:0.2 ato:0.04 cwnd:10 uid:20283 ino:7901838 sk:ffff880143735040
