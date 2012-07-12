From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] tcp: TCP Small Queues
Date: Thu, 12 Jul 2012 02:00:33 +0200
Message-ID: <1342051233.3265.8206.camel@edumazet-glaptop>
References: <1342021831.3265.8174.camel@edumazet-glaptop>
	<CAB_+Fg496FgQZkJE8uf_4RX_wW+fz1p5Rq8rY=BuA=c6KPakpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, codel@lists.bufferbloat.net, ncardwell@google.com,
	David Miller <davem@davemloft.net>, mattmathis@google.com
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAB_+Fg496FgQZkJE8uf_4RX_wW+fz1p5Rq8rY=BuA=c6KPakpA@mail.gmail.com>
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

Note : netdev mailing list doesnt accept HTML ;)

On Wed, 2012-07-11 at 12:29 -0700, Nandita Dukkipati wrote:
> I have a couple of high level questions on the two solutions for
> maintain small queues at qdisc: 1) using codel's feedback versus 2)
> the approach in TSQ to explicitly limit bytes per-flow
> to tcp_limit_output_bytes.
> 
> 
> 1. multiple flows case: codel feedback (be it drop/ECN or direct
> feedback like in your patch with fq_codel: report congestion
> notification at enqueue time) seems to work in maintaining small
> queues regardless of the number of connections. TSQ probably won't
> achieve this goal when number of flows is large. Is this correct?


Problem with codel/fq_codel is that the congestion is delayed.

And my patch (signaling congestion to local tcp senders) raised several
issues.

I had then TSQ idea to have a more general mechanism (not depending on a
particular qdisc setup)

TCP Small Queue is effective even with a large number of flows because
with standard pfifo_fast, we can without TCP Small Queue store 1000
packets in Qdisc, each being 64KB. Thats 64 MBytes...

With TCP Small Queue, you can reach this level of occupancy using 500
flows (2 packets per flow)

Without TCP Small Queue, you can reach this level using 16 flows.

(This of course assumes TSO is on, but modern NIC are TSO enabled)

> 2. cwnd adjustment: codel feedback directly and explicitly controls
> snd_cwnd which in turn will also adjust the send buffer size to
> appropriate value. That's a nice property, which TSQ probably won't
> have because it doesn't explicitly adjust snd_cwnd. 
> 
> Considering these two points, why TSQ over the Codel feedback
> approach?

I dont think they compete. They are in fact complementary.

If you use codel/fq_codel + TSQ, you have both per flow limitation in
qdisc (TSQ) + sojourn time aware and multi flow aware feedback.
