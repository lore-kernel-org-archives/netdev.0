From: Octavian Purdila <opurdila@ixiacom.com>
Subject: TCP receive splice performance
Date: Mon, 12 May 2008 15:45:50 +0300
Message-ID: <200805121545.50390.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3025 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753275AbYELMqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 08:46:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I have been playing with the tcp receive splice implementation and noticed 
some strange results. 

The tests were run with client and server on two machines with GB interfaces 
(PPC 800MHz, 32K cache size) connected back to back. Both client and server 
machine were running a 2.6.25 kernel.

In the first test case the client was doing read(/dev/zero) write(socket), and 
the server read(socket) write(/dev/null). Throughput  was 68MB/s.

In the second test case the same test was performed, only this time with some 
modification in the network stack to disable the copying from/to userspace. 
Throughput was 122-123MB which is practically line-rate.

For the third testcase I was using splice(/some/file, socket) on the client 
and splice(socket, /dev/null) on the server. Throughput was 113MB/s. 

Now the strange part: when lowering the tcp_rmem buffer sizes to 32K or 
setting SOCK_RECVBUF to 16K (which AFAIK is the same thing) the throughput 
was 121-122MB/s.

oprofiling the two splice runs shows that in the 113 case tcp_read_sock is 
responsible for about 3% CPU time while in the 122 case tcp_read_sock is only 
responsible for 1.5% CPU time. In the second test case tcp_recvmsg is 
responsible for 1.5% CPU time.

For the 113 case there are about 400K tcp_read_sock calls per 5 seconds, and 
in the 122 case there are 420K tcp_read_sock calls per 5 seconds. Detailed 
profiling seems to point that about 50% from tcp_read_sock, in the 113 case, 
is spent when touching the tcp header in tcp_recv_skb.

The only clue for the 32K magic buffer size that I see is that L1cache of the 
processor is 32K. Could it be that the splice code has a big impact on the 
cache and that is pushing the tcp headers out the cache? 

tcp_headers should be in the cache before the tcp_read_sock call, since the 
softirq processing is touching the tcp headers, right?

Any ideas of how I can debug this further?

Thanks,
tavi
