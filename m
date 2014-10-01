From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 1/2] sunvnet: Process Rx data packets in a BH
 handler
Date: Wed, 1 Oct 2014 15:39:14 -0400
Message-ID: <20141001193914.GL17706@oracle.com>
References: <20141001185615.GH17706@oracle.com>
 <1412190559.16704.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34199 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaJATjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:39:20 -0400
Content-Disposition: inline
In-Reply-To: <1412190559.16704.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/01/14 12:09), Eric Dumazet wrote:
> > -
> > +	/* BH context cannot call netif_receive_skb */
> > +	netif_rx_ni(skb);
> 
> Really ? What about the standard and less expensive netif_receive_skb ?

I can't use netif_receive_skb in this case:
the TCP retransmit timers are softirq context. They can pre-empt here, 
and result in a deadlock on socket locks. E.g.,

tcp_write_timer+0xc/0xa0 <-- wants sk_lock
call_timer_fn+0x24/0x120
run_timer_softirq+0x214/0x2a0
__do_softirq+0xb8/0x200
do_softirq+0x8c/0xc0
local_bh_enable+0xac/0xc0
ip_finish_output+0x254/0x4a0
ip_output+0xc4/0xe0
ip_local_out+0x2c/0x40
ip_queue_xmit+0x140/0x3c0
tcp_transmit_skb+0x448/0x740
tcp_write_xmit+0x220/0x480
__tcp_push_pending_frames+0x38/0x100
tcp_rcv_established+0x214/0x780
tcp_v4_do_rcv+0x154/0x300
tcp_v4_rcv+0x6cc/0xa60   <-- takes sk_lock
  :
netif_receive_skb
 

Ideally I would have liked to  use netif_receive_skb (it boosts perf)
but I had to back off for this reason.

> > +
> > +	struct mutex            vnet_rx_mutex; /* serializes rx_workq */
> > +	struct work_struct      rx_work;
> > +	struct workqueue_struct *rx_workq;
> > +
> >  };
> 
> Could you describe in the changelog why all this is needed ?

So I gave a short summary in the cover letter, but more details

- processing packets in ldc_rx context risks live-lock
- I experimented with a few things, including NAPI, and just using a simple tasklet
  to take care of the data packet handling. With Both NAPI and tasklet, I'm able
  to use netif_receive_skb safely, however, mpstat shows that one CPU ends up
  doing all the processing, and scaling was inhibited.
- further, with  NAPI the budget gets in the way. 

Regarding your other comments"
  "You basically found a way to overcome NAPI standard limits (budget of 64)"
As I said in the cover letter, coercing a budget on sunvnet ends up actually
hurting perf significantly, as we end up sending additional stop/start messages.
To achieve that budget, we'd have to keep a lot more state in vnet to remember
the position in the stream but *not* send a STOP/START, and instead resume
at the next napi_schedule from where we left off.

Doing all this would end up just re-inventing much of the code in process_backlog
anyway.

--Sowmini

 
