From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Sat, 23 Mar 2013 09:58:05 -0700
Message-ID: <1364057885.29473.4.camel@edumazet-glaptop>
References: <20111122.192338.1206677511966747729.davem@davemloft.net>
	 <20111122183727.01ab6f04@telperion.jlyo.org>
	 <1322059124.17693.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111123.172959.909786536317740314.davem@davemloft.net>
	 <c873451a-71aa-418b-96e2-d8875e7fec3e@googlegroups.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: jlyo@jlyo.org, netdev@vger.kernel.org, davem@davemloft.net
To: parasytic@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35031 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633Ab3CWQ6I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 12:58:08 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so2016149pdj.27
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 09:58:07 -0700 (PDT)
In-Reply-To: <c873451a-71aa-418b-96e2-d8875e7fec3e@googlegroups.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 19:03 -0700, parasytic@gmail.com wrote:
> Hi List!
> 
> 
> First, I'm sorry for resurrecting an extremely old thread, but I've
> exhausted all other resources. We're experiencing this same "1 second
> retransmit" with ipv4 (including loopback). And the best part is, it
> can be replicated very easily using the 'closed' and 'tcping' tests
> provided by Jesse Young in the initial post. For reference:
> 
> 
> $ git clone git://github.com/jlyo/tcping.git
> $ cd tcping && make
> 
> 
> $ git clone git://github.com/jlyo/closed.git
> $ cd closed && make
> 
> 
> $ ./closed 0.0.0.0
> 
> 
> $ time ./tcping -f -p8009 0.0.0.0
> 
> 
> Results:
> 
> 
>         ...
>         response from 0.0.0.0:8009, seq=1907 time=0.02 ms
>         response from 0.0.0.0:8009, seq=1908 time=0.03 ms
>         response from 0.0.0.0:8009, seq=1909 time=999.11 ms
>         --- 0.0.0.0:8009 ping statistics ---
>         1909 responses, 1910 ok, 0.00% failed
>         round-trip min/avg/max = 0.0/0.6/999.1 ms
>         
>         
>         real    0m1.125s
>         user    0m0.008s
>         sys     0m0.104s
> 
> 
> 
> 
> Packet captures from tcpdump look remarkably similar to what Eric
> Dumazet shared. That eventually lead me to this thread.
> 
> 
> This happens on a fresh Ubuntu 12.10 install, and also with our tuning
> parameters. (Includes increasing the syn backlog, open file
> descriptors, TCP memory, max orphans, etc.)  I've also seen the
> problem with other kernels, within EC2 and Azure. I have not been able
> to test with ipv6 yet.
> 
> 
> $ uname -a
> Linux test 3.5.0-21-generic #32-Ubuntu SMP Tue Dec 11 18:51:59 UTC
> 2012 x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> I'm hoping to spark some interest in revisiting this issue (with focus
> on ipv4, this time).
> 
> 
> Thanks everyone!
> Jay
> 
Hi Jay

Not reproducible on current kernels (net-next tree for example)

ip netns add eric
ip netns exec eric ifconfig -a
ip netns exec eric ifconfig lo 127.0.0.1 up
ip netns exec eric ./closed 0.0.0.0 &
ip netns exec eric nstat
ip netns exec eric ./tcping -f -p8009 0.0.0.0
127.0.0.1:40832 Connected...response from 0.0.0.0:8009, seq=32799
time=0.04 ms
 closed
127.0.0.1:40999 Connected...response from 0.0.0.0:8009, seq=32800
time=0.04 ms
 closed
127.0.0.1:42795 Connected...response from 0.0.0.0:8009, seq=32801
time=0.20 ms
 closed
127.0.0.1:43226 Connected...response from 0.0.0.0:8009, seq=32802
time=0.07 ms
 closed
error connecting to host (99): Cannot assign requested address
................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
 ................................................................................................................................................................^C.--- 0.0.0.0:8009 ping statistics ---
33765 responses, 32803 ok, 0.00% failed
round-trip min/avg/max = 0.0/0.0/0.5 ms

# ip netns exec eric nstat
#kernel
IpInReceives                    197087             0.0
IpInDelivers                    197087             0.0
IpOutRequests                   197087             0.0
TcpActiveOpens                  32803              0.0
TcpPassiveOpens                 32803              0.0
TcpInSegs                       197087             0.0
TcpOutSegs                      197084             0.0
TcpRetransSegs                  3                  0.0
TcpOutRsts                      11                 0.0
TcpExtSyncookiesFailed          11                 0.0
TcpExtDelayedACKs               238                0.0
TcpExtDelayedACKLocked          248                0.0
TcpExtTCPPureAcks               65838              0.0
TcpExtTCPTimeouts               3                  0.0
IpExtInOctets                   10773240           0.0
IpExtOutOctets                  10773240           0.0


But yes, on 3.5.X kernel you might hit a bug somewhere.

Since the same sequence gives suspect TcpExtListenDrops :

# ip netns exec eric nstat 
#kernel
IpInReceives                    49367              0.0
IpInDelivers                    49367              0.0
IpOutRequests                   49367              0.0
TcpActiveOpens                  8184               0.0
TcpPassiveOpens                 8184               0.0
TcpInSegs                       49367              0.0
TcpOutSegs                      49362              0.0
TcpRetransSegs                  5                  0.0
TcpExtDelayedACKs               63                 0.0
TcpExtDelayedACKLocked          32                 0.0
TcpExtListenOverflows           4                  0.0
TcpExtListenDrops               4                  0.0
TcpExtTCPPureAcks               16624              0.0
TcpExtTCPLossUndo               1                  0.0
TcpExtTCPTimeouts               5                  0.0
IpExtInOctets                   2698036            0.0
IpExtOutOctets                  2698036            0.0
