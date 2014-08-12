From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH] tcp: don't use timestamp from repaired skb-s to
 calculate RTT
Date: Tue, 12 Aug 2014 18:34:36 +0400
Message-ID: <20140812143436.GA29992@paralelels.com>
References: <1407836714-26813-1-git-send-email-avagin@openvz.org>
 <1407845701.10122.60.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140812123320.GA27421@paralelels.com>
 <1407849283.10122.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: Andrey Vagin <avagin@openvz.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407849283.10122.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 12, 2014 at 06:14:43AM -0700, Eric Dumazet wrote:
> On Tue, 2014-08-12 at 16:33 +0400, Andrew Vagin wrote:
> > On Tue, Aug 12, 2014 at 05:15:01AM -0700, Eric Dumazet wrote:
> > > On Tue, 2014-08-12 at 13:45 +0400, Andrey Vagin wrote:
> > > > We don't know right timestamp for repaired skb-s. Wrong RTT estimations
> > > > isn't good, because some congestion modules heavily depends on it.
> > > > 
> > > > This patch adds the TCPCB_REPAIRED flag, which is included in
> > > > TCPCB_RETRANS.
> > > 
> > > ...
> > > 
> > > > +
> > > > +				/* All packets are restored as if they have
> > > > +				 * already been sent. skb_mstamp isn't set to
> > > > +				 * avoid wrong rtt estimation.
> > > > +				 */
> > > > +				if (tp->repair) {
> > > > +					TCP_SKB_CB(skb)->sacked |= TCPCB_REPAIRED;
> > > > +					TCP_SKB_CB(skb)->when = tcp_time_stamp;
> > > > +				}
> > > >  			}
> > > >  
> > > >  			/* Try to append data to the end of skb. */
> > > 
> > > 
> > > Are you sure TCP_SKB_CB(skb)->when needs to be set ?
> > 
> > It's used in tcp_rearm_rto() for calculating a retransmit timeout.
> > ...
> > 	const u32 rto_time_stamp = TCP_SKB_CB(skb)->when + rto;
> > 	s32 delta = (s32)(rto_time_stamp - tcp_time_stamp);
> > ...
> > 
> > "when" is used as a start point, so I think it's acceptable here.
> > 
> > I will add a comment. Thanks.
> 
> tcp_rearm_rto() does the following :
> 
> 
>         if (!tp->packets_out) {
>                 inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
>         } else {
>                 u32 rto = inet_csk(sk)->icsk_rto;
>                 /* Offset the time elapsed after installing regular RTO */
>                 if (icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
>                     icsk->icsk_pending == ICSK_TIME_LOSS_PROBE) {
>                         struct sk_buff *skb = tcp_write_queue_head(sk);
>                         const u32 rto_time_stamp = TCP_SKB_CB(skb)->when + rto;
> 
> This means that : at least one packet was transmitted (packets_out is not 0)

This one packet may be repaired:

static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
                           int push_one, gfp_t gfp)
	...
	while ((skb = tcp_send_head(sk))) {
		...
		if (unlikely(tp->repair) && tp->repair_queue == TCP_SEND_QUEUE)
                        goto repair; /* Skip network transmission */
		...
		TCP_SKB_CB(skb)->when = tcp_time_stamp;
		...
repair:
		/* Advance the send_head.  This one is sent out.
		 * This call will increment packets_out.
		 */
		tcp_event_new_data_sent(sk, skb)
			tp->packets_out += tcp_skb_pcount(skb);
	}

Looks like we need move setting of "when" in tcp_write_xmit, because it
is set here for all normal skb-s.


> 
> Since we timestamp all packets we transmit (look at tcp_transmit_skb() callers, all doing :
> 
> TCP_SKB_CB(skb)->when = tcp_time_stamp; 
> 
> Then, write queue head was timestamped properly at the time packet was sent,
> not at the time tcp repair code reinjected skbs into the write queue.
> 
> 
> 
> 
