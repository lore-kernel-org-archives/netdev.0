From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Tue, 10 Jul 2012 19:06:27 +0200
Message-ID: <1341939987.3265.5741.camel@edumazet-glaptop>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
	<1341845722.3265.3065.camel@edumazet-glaptop>
	<1341933215.3265.5476.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, ycheng@google.com,
	codel@lists.bufferbloat.net, mattmathis@google.com, ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1341933215.3265.5476.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-10 at 17:13 +0200, Eric Dumazet wrote:
> This introduce TSQ (TCP Small Queues)
> 
> TSQ goal is to reduce number of TCP packets in xmit queues (qdisc &
> device queues), to reduce RTT and cwnd bias, part of the bufferbloat
> problem.
> 
> sk->sk_wmem_alloc not allowed to grow above a given limit,
> allowing no more than ~128KB [1] per tcp socket in qdisc/dev layers at a
> given time.
> 
> TSO packets are sized/capped to half the limit, so that we have two
> TSO packets in flight, allowing better bandwidth use.
> 
> As a side effect, setting the limit to 40000 automatically reduces the
> standard gso max limit (65536) to 40000/2 : It can help to reduce
> latencies of high prio packets, having smaller TSO packets.
> 
> This means we divert sock_wfree() to a tcp_wfree() handler, to
> queue/send following frames when skb_orphan() [2] is called for the
> already queued skbs.
> 
> Results on my dev machine (tg3 nic) are really impressive, using
> standard pfifo_fast, and with or without TSO/GSO. Without reduction of
> nominal bandwidth.
> 
> I no longer have 3MBytes backlogged in qdisc by a single netperf
> session, and both side socket autotuning no longer use 4 Mbytes.
> 
> As skb destructor cannot restart xmit itself ( as qdisc lock might be
> taken at this point ), we delegate the work to a tasklet. We use one
> tasklest per cpu for performance reasons.
> 
> 
> 
> [1] New /proc/sys/net/ipv4/tcp_limit_output_bytes tunable
> [2] skb_orphan() is usually called at TX completion time,
>   but some drivers call it in their start_xmit() handler.
>   These drivers should at least use BQL, or else a single TCP
>   session can still fill the whole NIC TX ring, since TSQ will
>   have no effect.
> 
> Not-Yet-Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

By the way, Rick Jones asked me :

"Is there also any chance in service demand?"

I copy here my answer since its a very good point:

I worked on the idea of a CoDel like feedback, to have a timed limit
instead of byte limit ("allow up to 1ms" delay in qdisc/dev queue.)

But it seemed a bit complex : I would need to add skb fields to properly
track the residence time (sojourn time) of queued packets.

Alternative would be to have a per tcp socket tracking array,
but it might be expensive to search a packet in it...

With multi queue devices or bad qdiscs, we can have reordering in skb
orphanings. So the lookup can be relatively expensive.
