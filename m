From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH?] tcp and delayed acks
Date: Wed, 16 Aug 2006 16:55:32 -0400
Message-ID: <20060816205532.GF9519@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:40848 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S932217AbWHPUzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 16:55:44 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello folks,

In looking at a few benchmarks (especially netperf) run locally, it seems 
that tcp is unable to make full use of available CPU cycles as the sender 
is throttled waiting for ACKs to arrive.  The problem is exacerbated when 
the sender is using a small send buffer -- running netperf -C -c -- -s 1024 
show a miserable 420Kbit/s at essentially 0% CPU usage.  Tests over gige 
are similarly constrained to a mere 96Mbit/s.

Since there is no way for the receiver to know if the sender is being 
blocked on transmit space, would it not make sense for the receiver to 
send out any delayed ACKs when it is clear that the receiving process is 
waiting for more data?  The patch below attempts this (I make no guarantees 
of its correctness with respect to the rest of the delayed ack code).  One 
point I'm still contemplating is what to do if the receiver is waiting in 
poll/select/epoll.

[All tests run with maxcpus=1 on a 2.67GHz Woodcrest system.]

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

Base (2.6.17-rc4):
default send buffer size
netperf -C -c
 87380  16384  16384    10.02      14127.79   99.90    99.90    0.579   0.579 
 87380  16384  16384    10.02      13875.28   99.90    99.90    0.590   0.590 
 87380  16384  16384    10.01      13777.25   99.90    99.90    0.594   0.594 
 87380  16384  16384    10.02      13796.31   99.90    99.90    0.593   0.593 
 87380  16384  16384    10.01      13801.97   99.90    99.90    0.593   0.593 

netperf -C -c -- -s 1024
 87380   2048   2048    10.02         0.43   -0.04    -0.04    -7.105  -7.377
 87380   2048   2048    10.02         0.43   -0.01    -0.01    -2.337  -2.620
 87380   2048   2048    10.02         0.43   -0.03    -0.03    -5.683  -5.940
 87380   2048   2048    10.02         0.43   -0.05    -0.05    -9.373  -9.625
 87380   2048   2048    10.02         0.43   -0.05    -0.05    -9.373  -9.625

from a remote system over gigabit ethernet
netperf -H woody -C -c
 87380  16384  16384    10.03       936.23   19.32    20.47    3.382   1.791 
 87380  16384  16384    10.03       936.27   17.67    20.95    3.091   1.833 
 87380  16384  16384    10.03       936.17   19.18    20.77    3.356   1.817 
 87380  16384  16384    10.03       936.26   18.22    20.26    3.188   1.773 
 87380  16384  16384    10.03       936.26   17.35    20.54    3.036   1.797 

netperf -H woody -C -c -- -s 1024
 87380   2048   2048    10.00        95.72   10.04    6.64     17.188  5.683 
 87380   2048   2048    10.00        95.94   9.47     6.42     16.170  5.478 
 87380   2048   2048    10.00        96.83   9.62     5.72     16.283  4.840 
 87380   2048   2048    10.00        95.91   9.58     6.13     16.368  5.236 
 87380   2048   2048    10.00        95.91   9.58     6.13     16.368  5.236 


Patched:
default send buffer size
netperf -C -c
 87380  16384  16384    10.01      13923.16   99.90    99.90    0.588   0.588 
 87380  16384  16384    10.01      13854.59   99.90    99.90    0.591   0.591 
 87380  16384  16384    10.02      13840.42   99.90    99.90    0.591   0.591 
 87380  16384  16384    10.01      13810.96   99.90    99.90    0.593   0.593 
 87380  16384  16384    10.01      13771.27   99.90    99.90    0.594   0.594 

netperf -C -c -- -s 1024
 87380   2048   2048    10.02      2473.48   99.90    99.90    3.309   3.309 
 87380   2048   2048    10.02      2421.46   99.90    99.90    3.380   3.380 
 87380   2048   2048    10.02      2288.07   99.90    99.90    3.577   3.577 
 87380   2048   2048    10.02      2405.41   99.90    99.90    3.402   3.402 
 87380   2048   2048    10.02      2284.41   99.90    99.90    3.582   3.582 

netperf -H woody -C -c
 87380  16384  16384    10.04       936.10   23.04    21.60    4.033   1.890 
 87380  16384  16384    10.03       936.20   18.52    21.06    3.242   1.843 
 87380  16384  16384    10.03       936.52   17.61    21.05    3.082   1.841 
 87380  16384  16384    10.03       936.18   18.24    20.73    3.191   1.814 
 87380  16384  16384    10.03       936.28   18.30    21.04    3.202   1.841 

netperf -H woody -C -c -- -s 1024
 87380   2048   2048    10.00       142.46   10.19    7.53     11.714  4.332 
 87380   2048   2048    10.00       147.28   9.73     7.93     10.829  4.412 
 87380   2048   2048    10.00       143.37   10.64    6.54     12.161  3.738 
 87380   2048   2048    10.00       146.41   9.18     7.43     10.277  4.158 
 87380   2048   2048    10.01       145.58   9.80     7.25     11.032  4.081 

Comments/thoughts?

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.


diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 934396b..e554ceb 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1277,8 +1277,11 @@ #endif
 			/* Do not sleep, just process backlog. */
 			release_sock(sk);
 			lock_sock(sk);
-		} else
+		} else {
+			if (inet_csk_ack_scheduled(sk))
+				tcp_send_ack(sk);
 			sk_wait_data(sk, &timeo);
+		}
 
 #ifdef CONFIG_NET_DMA
 		tp->ucopy.wakeup = 0;
