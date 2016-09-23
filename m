From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Fri, 23 Sep 2016 12:12:06 -0300
Message-ID: <20160923151205.GC17222@localhost.localdomain>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160922223411.GA17222@localhost.localdomain>
 <1474586490.28155.10.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160923124517.GB17222@localhost.localdomain>
 <1474638171.28155.18.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160923140932.GA9307@localhost.localdomain>
 <1474641392.28155.27.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42525 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1035173AbcIWPMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 11:12:09 -0400
Content-Disposition: inline
In-Reply-To: <1474641392.28155.27.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 07:36:32AM -0700, Eric Dumazet wrote:
> On Fri, 2016-09-23 at 11:09 -0300, Marcelo Ricardo Leitner wrote:
> > On Fri, Sep 23, 2016 at 06:42:51AM -0700, Eric Dumazet wrote:
> > > On Fri, 2016-09-23 at 09:45 -0300, Marcelo Ricardo Leitner wrote:
> > > 
> > > > Aye. In that case, what about using tail instead of end?
> > > 
> > > 
> > > What do you mean exactly ?
> > 
> > Something like:
> > -skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
> > +skb->truesize = SKB_TRUESIZE(skb_tail_offset(skb));
> 
> Certainly not ;)
> 
> This would be lying.

Yep, but also so is adding txbuf to the equation to account for that,
right? :-) Unless you're considering that acks should/can be sort of
accounted by the txbuf instead, then it makes sense to sum the buffer
sizes in there.

> We really want a precise memory accounting to avoid OOM.

Indeed

> 
> Some USB drivers use 8KB for their skb->head, you do not want to pretend
> its 66+NET_SKB_PAF=F bytes just because there is no payload in the
> packet.

Oh.

> 
> > 
> > And define skb_tail_offset() to something similar skb_end_offset(), so
> > that it would account only for the data and not unused space in the
> > buffer.
> > 
> > > 
> > > >  Because
> > > > accounting for something that we have to tweak the limits to accept is
> > > > like adding a constant to both sides of the equation.
> > > > But perhaps that would cut out too much of the fat which could be used
> > > > later by the stack.
> > > 
> > > Are you facing a particular problem with current code ?
> > > 
> > 
> > For TCP, no, just wondering. :-)
> > 
> > I'm having similar issues with SCTP: if the socket gets backlogged, the
> > buffer accounting gets pretty messy. SCTP calculates the rwnd to be just
> > rcvbuf/2, but this ratio is often different in backlog and it causes the
> > advertized window to be too big, resulting in packet drops in the
> > backlog.
> > 
> > SCTP has some way to identify and compensate this "extra" rwnd, via
> > rwnd_press, and will shrink it if it detects that the window is bigger
> > than the buffer available. But as the socket is backlogged, it's doesn't
> > kick in soon enough to prevent such drops.
> > 
> > It's not just a matter of adjusting the overhead ratio (rcvbuf/2)
> > because with SCTP the packets may have different sizes, so a packet with
> > a chunk of 100 bytes will have a ratio and another with 1000 bytes will
> > have another, within the same association.
> > 
> > So I'm leaning towards on updating truesize before adding to the
> > backlog, but to account just for the actual packet, regardless of the
> > buffer that was used for it. It still has the overhead ratio issue with
> > different packet sizes, though, but smaller.
> > 
> > Note that SCTP doesn't have buffer auto-tuning yet.
> 
> Also for TCP, we might need to use sk->sk_wmem_queued instead of
> sk->sk_sndbuf

This is interesting. Then it would only stretch the backlog limit if
there is a heavy tx going on.

> 
> This is because SACK processing can suddenly split skbs in 1-MSS pieces.
> 
> Problem is that for very large BDP, we can end up with thousands of skb
> in backlog. So I am also considering to try to coalesce stupid ACK sent
> by non GRO receivers or simply the verbose SACK blocks...
> 
> eg if backlog is under pressure and its tail is : 
> 
> ACK 1   <sack 4000:5000>
> 
> and the incoming packet is :
> 
> ACK 1  <sack 4000:6000>
> 
> Then we could replace the tail by the incoming packet with minimal
> impact.
> 
> Since we might receive hundred of 'sequential' SACK blocks, this would
> help to reduce time taken by the application to process the (now
> smaller) backlog
> 

That would be cool.

Thanks,
Marcelo
