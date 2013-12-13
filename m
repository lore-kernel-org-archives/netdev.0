From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: remove a bogus TSO split
Date: Fri, 13 Dec 2013 09:15:37 -0500
Message-ID: <CADVnQymwaUNVgzqM97vfb=nfMFzVWmK8wR7fQ8Wm3i_c8+Z0jA@mail.gmail.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:53061 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab3LMOPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 09:15:42 -0500
Received: by mail-ee0-f49.google.com with SMTP id c41so900391eek.22
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 06:15:40 -0800 (PST)
In-Reply-To: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 2:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While investigating performance problems on small RPC workloads,
> I noticed linux TCP stack was always splitting the last TSO skb
> into two parts (skbs). One being a multiple of MSS, and a small one
> with the Push flag. This split is done even if TCP_NODELAY is set.
>
> Example with request/response of 4K/4K
>
> IP A > B: . ack 68432 win 2783 <nop,nop,timestamp 6524593 6525001>
> IP A > B: . 65537:68433(2896) ack 69632 win 2783 <nop,nop,timestamp 6524593 6525001>
> IP A > B: P 68433:69633(1200) ack 69632 win 2783 <nop,nop,timestamp 6524593 6525001>
> IP B > A: . ack 68433 win 2768 <nop,nop,timestamp 6525001 6524593>
> IP B > A: . 69632:72528(2896) ack 69633 win 2768 <nop,nop,timestamp 6525001 6524593>
> IP B > A: P 72528:73728(1200) ack 69633 win 2768 <nop,nop,timestamp 6525001 6524593>
> IP A > B: . ack 72528 win 2783 <nop,nop,timestamp 6524593 6525001>
> IP A > B: . 69633:72529(2896) ack 73728 win 2783 <nop,nop,timestamp 6524593 6525001>
> IP A > B: P 72529:73729(1200) ack 73728 win 2783 <nop,nop,timestamp 6524593 6525001>
>
> We think this is not needed.
>
> All the Nagle/window tests are done at this point.
>
> This patch tremendously improves performance, as the traffic now looks
> like :
>
> IP A > B: . ack 98304 win 2783 <nop,nop,timestamp 6834277 6834685>
> IP A > B: P 94209:98305(4096) ack 98304 win 2783 <nop,nop,timestamp 6834277 6834685>
> IP B > A: . ack 98305 win 2768 <nop,nop,timestamp 6834686 6834277>
> IP B > A: P 98304:102400(4096) ack 98305 win 2768 <nop,nop,timestamp 6834686 6834277>
> IP A > B: . ack 102400 win 2783 <nop,nop,timestamp 6834279 6834686>
> IP A > B: P 98305:102401(4096) ack 102400 win 2783 <nop,nop,timestamp 6834279 6834686>
> IP B > A: . ack 102401 win 2768 <nop,nop,timestamp 6834687 6834279>
> IP B > A: P 102400:106496(4096) ack 102401 win 2768 <nop,nop,timestamp 6834687 6834279>
> IP A > B: . ack 106496 win 2783 <nop,nop,timestamp 6834280 6834687>
> IP A > B: P 102401:106497(4096) ack 106496 win 2783 <nop,nop,timestamp 6834280 6834687>
> IP B > A: . ack 106497 win 2768 <nop,nop,timestamp 6834688 6834280>
> IP B > A: P 106496:110592(4096) ack 106497 win 2768 <nop,nop,timestamp 6834688 6834280>
>
>
> Before :
>
> lpq83:~# nstat >/dev/null;perf stat ./super_netperf 200 -t TCP_RR -H lpq84 -l 20 -- -r 4K,4K
> 280774
>
>  Performance counter stats for './super_netperf 200 -t TCP_RR -H lpq84 -l 20 -- -r 4K,4K':
>
>      205719.049006 task-clock                #    9.278 CPUs utilized
>          8,449,968 context-switches          #    0.041 M/sec
>          1,935,997 CPU-migrations            #    0.009 M/sec
>            160,541 page-faults               #    0.780 K/sec
>    548,478,722,290 cycles                    #    2.666 GHz                     [83.20%]
>    455,240,670,857 stalled-cycles-frontend   #   83.00% frontend cycles idle    [83.48%]
>    272,881,454,275 stalled-cycles-backend    #   49.75% backend  cycles idle    [66.73%]
>    166,091,460,030 instructions              #    0.30  insns per cycle
>                                              #    2.74  stalled cycles per insn [83.39%]
>     29,150,229,399 branches                  #  141.699 M/sec                   [83.30%]
>      1,943,814,026 branch-misses             #    6.67% of all branches         [83.32%]
>
>       22.173517844 seconds time elapsed
>
> lpq83:~# nstat | egrep "IpOutRequests|IpExtOutOctets"
> IpOutRequests                   16851063           0.0
> IpExtOutOctets                  23878580777        0.0
>
> After patch :
>
> lpq83:~# nstat >/dev/null;perf stat ./super_netperf 200 -t TCP_RR -H lpq84 -l 20 -- -r 4K,4K
> 280877
>
>  Performance counter stats for './super_netperf 200 -t TCP_RR -H lpq84 -l 20 -- -r 4K,4K':
>
>      107496.071918 task-clock                #    4.847 CPUs utilized
>          5,635,458 context-switches          #    0.052 M/sec
>          1,374,707 CPU-migrations            #    0.013 M/sec
>            160,920 page-faults               #    0.001 M/sec
>    281,500,010,924 cycles                    #    2.619 GHz                     [83.28%]
>    228,865,069,307 stalled-cycles-frontend   #   81.30% frontend cycles idle    [83.38%]
>    142,462,742,658 stalled-cycles-backend    #   50.61% backend  cycles idle    [66.81%]
>     95,227,712,566 instructions              #    0.34  insns per cycle
>                                              #    2.40  stalled cycles per insn [83.43%]
>     16,209,868,171 branches                  #  150.795 M/sec                   [83.20%]
>        874,252,952 branch-misses             #    5.39% of all branches         [83.37%]
>
>       22.175821286 seconds time elapsed
>
> lpq83:~# nstat | egrep "IpOutRequests|IpExtOutOctets"
> IpOutRequests                   11239428           0.0
> IpExtOutOctets                  23595191035        0.0
>
> Indeed, the occupancy of tx skbs (IpExtOutOctets/IpOutRequests) is higher :
> 2099 instead of 1417, thus helping GRO to be more efficient when using FQ packet
> scheduler.
>
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Cc: Van Jacobson <vanj@google.com>
> ---
>  net/ipv4/tcp_output.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 2a69f42e51ca..335e110e86ba 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1410,10 +1410,7 @@ static unsigned int tcp_mss_split_point(const struct sock *sk, const struct sk_b
>
>         needed = min(skb->len, window);
>
> -       if (max_len <= needed)
> -               return max_len;
> -
> -       return needed - needed % mss_now;
> +       return min(max_len, needed);
>  }
>
>  /* Can at least one segment of SKB be sent right now, according to the
>

Seems like a nice improvement, but if we apply this patch then AFAICT
to get the Nagle-enabled case right we also have to update
tcp_minshall_update() to notice these new non-MSS-aligned segments
going out, and count those as non-full-size segments for the
minshall-nagle check (to ensure we have no more than one outstanding
un-ACKed sub-MSS packet). Maybe something like (please excuse the
formatting):

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 70e55d2..a2ec237 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -980,7 +980,8 @@ bool tcp_is_cwnd_limited(const struct sock *sk,
u32 in_flight);
 static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss,
                                       const struct sk_buff *skb)
 {
-       if (skb->len < mss)
+       if (skb->len < mss ||
+           tcp_skb_pcount(skb) * tcp_skb_mss(skb) > skb->len)
                tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
 }

neal
