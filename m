From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] udp: clear rps flow table for packets recv
 on UDP unconnected sockets
Date: Sun, 10 Aug 2014 18:59:38 +0200
Message-ID: <1407689978.10122.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1408091013240.1087@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36678 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbaHJQ7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 12:59:40 -0400
Received: by mail-pd0-f172.google.com with SMTP id y13so3583438pdi.3
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2014 09:59:40 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1408091013240.1087@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-08-09 at 10:15 -0700, Tom Herbert wrote:
> This patch addresses a problem posed by Eric Dumazet in RPS/RFS
> concerning the interaction between connected sockets and traffic on
> unnconnected sockets.
> 
> On a server which has both traffic using connected connected sockets
> and traffic that is going through unconnected UDP sockets, it is
> very possible that the connected sockets could heavily populate the
> RPS flow tables. Packets received on unconnected sockets would then
> be steered based on unrelated entries in the flow tables which leads
> to suboptimal steering. This happens even if the connections that
> populate the table are inactive with no traffic, as long as the
> connected sockets simply remain open unrelated traffic can be steered
> using that information. This problem would further be exacerbated
> if the packets on the unconnected UDP sockets are actually part of
> long lived flows (which apparently would happen with QUIC in their
> current implementation).
> 
> This patch clears the RPS flow hash table for packet recieved on
> unnconnected UDP sockets. The effect is that the "flows" on unconnected
> socekts will be steered using RPS. We don't do this for unconnected UDP
> tunnels (encap_rcv) under the assumption that the flow table entries
> will be adjusted during processing of inner packets.
> 
> Tested using super_netperf UDP_RR with 200 flows. Did not see any
> noticeable regression in writing to flow table for every packet.
> 
> Before fix:
>   76.99% CPU utilization
>   112/158/230 90/95/99% latencies
>   1.62776e+06 tps
> 
> After fix:
>   76.03% CPU utilization
>   115/162/239 90/95/99% latencies
>   1.62257e+06 tps
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/ipv4/udp.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index f57c0e4..7ba764a 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1444,6 +1444,8 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  	if (inet_sk(sk)->inet_daddr) {
>  		sock_rps_save_rxhash(sk, skb);
>  		sk_mark_napi_id(sk, skb);
> +	} else {
> +		sock_rps_reset_flow_hash(skb->hash);
>  	}
>  
>  	rc = sock_queue_rcv_skb(sk, skb);


I believe this patch is absolutely wrong.

1) Your benchmarks are either all TCP, either all UDP, so you cant see
any problem with these kind of heuristics.

Now, a server might have a mixed workload, with some TCP flows, and some
thousands of 'unconnected' UDP messages per second.

This patch would completely destroy TCP performance, by lowering RFS hit
rate (table would be almost empty)

If this was valid, admin would not setup RFS in the first place.

2) there is no guarantee skb->hash at this time is spread, so you might
add a false sharing in some cases (GRE tunnels for instance), as
rps_reset_sock_flow() would constantly set the same entry to RPS_NO_CPU
from multiple cpus.

Lets face it, RFS only works if workload is specialized, not generic.

If you want RFS being more usable, you need to find a way so that UDP
messages do not share a hash table used by TCP (which by definition only
deals with connected flows)
