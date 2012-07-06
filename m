From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC V5 0/5] Multiqueue virtio-net
Date: Fri, 06 Jul 2012 15:42:01 +0800
Message-ID: <4FF696C9.5070907@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<4FF5D2B7.6080602@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, mashirle@us.ibm.com,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4FF5D2B7.6080602@hp.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 07/06/2012 01:45 AM, Rick Jones wrote:
> On 07/05/2012 03:29 AM, Jason Wang wrote:
>
>>
>> Test result:
>>
>> 1) 1 vm 2 vcpu 1q vs 2q, 1 - 1q, 2 - 2q, no pinning
>>
>> - Guest to External Host TCP STREAM
>> sessions size throughput1 throughput2   norm1 norm2
>> 1 64 650.55 655.61 100% 24.88 24.86 99%
>> 2 64 1446.81 1309.44 90% 30.49 27.16 89%
>> 4 64 1430.52 1305.59 91% 30.78 26.80 87%
>> 8 64 1450.89 1270.82 87% 30.83 25.95 84%
>
> Was the -D test-specific option used to set TCP_NODELAY?  I'm guessing 
> from your description of how packet sizes were smaller with multiqueue 
> and your need to hack tcp_write_xmit() it wasn't but since we don't 
> have the specific netperf command lines (hint hint :) I wanted to make 
> certain.
Hi Rick:

I didn't specify -D for disabling Nagle. I also collects rx packets and 
average packet size:

Guest to External Host ( 2vcpu 1q vs 2q )
sessions size tput-sq tput-mq %  norm-sq norm-mq %  #tx-pkts-sq 
#tx-pkts-mq % avg-sz-sq avg-sz-mq %
1 64 668.85 671.13 100% 25.80 26.86 104% 629038 627126 99% 1395 1403 100%
2 64 1421.29 1345.40 94% 32.06 27.57 85% 1318498 1246721 94% 1413 1414 100%
4 64 1469.96 1365.42 92% 32.44 27.04 83% 1362542 1277848 93% 1414 1401 99%
8 64 1131.00 1361.58 120% 24.81 26.76 107% 1223700 1280970 104% 1395 
1394 99%
1 256 1883.98 1649.87 87% 60.67 58.48 96% 1542775 1465836 95% 1592 1472 92%
2 256 4847.09 3539.74 73% 98.35 64.05 65% 2683346 3074046 114% 2323 1505 64%
4 256 5197.33 3283.48 63% 109.14 62.39 57% 1819814 2929486 160% 3636 
1467 40%
8 256 5953.53 3359.22 56% 122.75 64.21 52% 906071 2924148 322% 8282 1502 18%
1 512 3019.70 2646.07 87% 93.89 86.78 92% 2003780 2256077 112% 1949 1532 78%
2 512 7455.83 5861.03 78% 173.79 104.43 60% 1200322 3577142 298% 7831 
2114 26%
4 512 8962.28 7062.20 78% 213.08 127.82 59% 468142 2594812 554% 24030 
3468 14%
8 512 7849.82 8523.85 108% 175.41 154.19 87% 304923 1662023 545% 38640 
6479 16%

When multiqueue were enabled, it does have a higher packets per second 
but with a much more smaller packet size. It looks to me that multiqueue 
is faster and guest tcp have less oppotunity to build a larger skbs to 
send, so lots of small packet were required to send which leads to much 
more #exit and vhost works. One interesting thing is, if I run tcpdump 
in the host where guest run, I can get obvious throughput increasing. To 
verify the assumption, I hack the tcp_write_xmit() with following patch 
and set tcp_tso_win_divisor=1, then I multiqueue can outperform or at 
least get the same throughput as singlequeue, though it could introduce 
latency but I havent' measured it.

I'm not expert of tcp, but looks like the changes are reasonable:
- we can do full-sized TSO check in tcp_tso_should_defer() only for 
westwood, according to tcp westwood
- run tcp_tso_should_defer for tso_segs = 1 when tso is enabled.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c465d3e..166a888 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1567,7 +1567,7 @@ static bool tcp_tso_should_defer(struct sock *sk, 
struct sk_buff *skb)

         in_flight = tcp_packets_in_flight(tp);

-       BUG_ON(tcp_skb_pcount(skb) <= 1 || (tp->snd_cwnd <= in_flight));
+       BUG_ON(tp->snd_cwnd <= in_flight);

         send_win = tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;

@@ -1576,9 +1576,11 @@ static bool tcp_tso_should_defer(struct sock *sk, 
struct sk_buff *skb)

         limit = min(send_win, cong_win);

+#if 0
         /* If a full-sized TSO skb can be sent, do it. */
         if (limit >= sk->sk_gso_max_size)
                 goto send_now;
+#endif

         /* Middle in queue won't get any more data, full sendable 
already? */
         if ((skb != tcp_write_queue_tail(sk)) && (limit >= skb->len))
@@ -1795,10 +1797,9 @@ static bool tcp_write_xmit(struct sock *sk, 
unsigned int mss_now, int nonagle,
                                                      
(tcp_skb_is_last(sk, skb) ?
                                                       nonagle : 
TCP_NAGLE_PUSH))))
                                 break;
-               } else {
-                       if (!push_one && tcp_tso_should_defer(sk, skb))
-                               break;
                 }
+               if (!push_one && tcp_tso_should_defer(sk, skb))
+                       break;

                 limit = mss_now;
                 if (tso_segs > 1 && !tcp_urg_mode(tp))




>
> Instead of calling them throughput1 and throughput2, it might be more 
> clear in future to identify them as singlequeue and multiqueue.
>

Sure.
> Also, how are you combining the concurrent netperf results?  Are you 
> taking sums of what netperf reports, or are you gathering statistics 
> outside of netperf?
>

The throughput were just sumed from netperf result like what netperf 
manual suggests. The cpu utilization were measured by mpstat.
>> - TCP RR
>> sessions size throughput1 throughput2   norm1 norm2
>> 50 1 54695.41 84164.98 153% 1957.33 1901.31 97%
>
> A single instance TCP_RR test would help confirm/refute any 
> non-trivial change in (effective) path length between the two cases.
>

Yes, I would test this thanks.
> happy benchmarking,
>
> rick jones
> -- 
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
