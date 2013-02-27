From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: avoid wakeups for pure ACK
Date: Wed, 27 Feb 2013 09:05:03 -0800
Message-ID: <1361984703.11403.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Andi Kleen <ak@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:38368 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760239Ab3B0RFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 12:05:08 -0500
Received: by mail-pa0-f47.google.com with SMTP id bj3so544899pad.20
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 09:05:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP prequeue mechanism purpose is to let incoming packets
being processed by the thread currently blocked in tcp_recvmsg(),
instead of behalf of the softirq handler, to better adapt flow
control on receiver host capacity to schedule the consumer.

But in typical request/answer workloads, we send request, then
block to receive the answer. And before the actual answer, TCP
stack receives the ACK packets acknowledging the request.

Processing pure ACK on behalf of the thread blocked in tcp_recvmsg()
is a waste of resources, as thread has to immediately sleep again
because it got no payload.

This patch avoids the extra context switches and scheduler overhead.

Before patch :

a:~# echo 0 >/proc/sys/net/ipv4/tcp_low_latency
a:~# perf stat ./super_netperf 300 -t TCP_RR -l 10 -H 7.7.7.84 -- -r 8k,8k
231676

 Performance counter stats for './super_netperf 300 -t TCP_RR -l 10 -H 7.7.7.84 -- -r 8k,8k':

     116251.501765 task-clock                #   11.369 CPUs utilized          
         5,025,463 context-switches          #    0.043 M/sec                  
         1,074,511 CPU-migrations            #    0.009 M/sec                  
           216,923 page-faults               #    0.002 M/sec                  
   311,636,972,396 cycles                    #    2.681 GHz                    
   260,507,138,069 stalled-cycles-frontend   #   83.59% frontend cycles idle   
   155,590,092,840 stalled-cycles-backend    #   49.93% backend  cycles idle   
   100,101,255,411 instructions              #    0.32  insns per cycle        
                                             #    2.60  stalled cycles per insn
    16,535,930,999 branches                  #  142.243 M/sec                  
       646,483,591 branch-misses             #    3.91% of all branches        

      10.225482774 seconds time elapsed

After patch :

a:~# echo 0 >/proc/sys/net/ipv4/tcp_low_latency
a:~# perf stat ./super_netperf 300 -t TCP_RR -l 10 -H 7.7.7.84 -- -r 8k,8k
233297

 Performance counter stats for './super_netperf 300 -t TCP_RR -l 10 -H 7.7.7.84 -- -r 8k,8k':

      91084.870855 task-clock                #    8.887 CPUs utilized          
         2,485,916 context-switches          #    0.027 M/sec                  
           815,520 CPU-migrations            #    0.009 M/sec                  
           216,932 page-faults               #    0.002 M/sec                  
   245,195,022,629 cycles                    #    2.692 GHz                    
   202,635,777,041 stalled-cycles-frontend   #   82.64% frontend cycles idle   
   124,280,372,407 stalled-cycles-backend    #   50.69% backend  cycles idle   
    83,457,289,618 instructions              #    0.34  insns per cycle        
                                             #    2.43  stalled cycles per insn
    13,431,472,361 branches                  #  147.461 M/sec                  
       504,470,665 branch-misses             #    3.76% of all branches        

      10.249594448 seconds time elapsed

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Andi Kleen <ak@linux.intel.com>
---
David : Feel free to postpone this to 3.10.
I'll send a patch to move tcp_prequeue() out of line when net-next opens

 include/net/tcp.h |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 23f2e98..cf0694d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1045,6 +1045,10 @@ static inline bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 	if (sysctl_tcp_low_latency || !tp->ucopy.task)
 		return false;
 
+	if (skb->len <= tcp_hdrlen(skb) &&
+	    skb_queue_len(&tp->ucopy.prequeue) == 0)
+		return false;
+
 	__skb_queue_tail(&tp->ucopy.prequeue, skb);
 	tp->ucopy.memory += skb->truesize;
 	if (tp->ucopy.memory > sk->sk_rcvbuf) {
