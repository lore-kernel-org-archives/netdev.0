From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 4/5] net/socket: add helpers for recvmmsg
Date: Sun, 27 Nov 2016 17:21:33 +0100
Message-ID: <1480263693.9705.28.camel@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
         <56ac598a3f8b677d58cc9fec5470df230c6d1f70.1480086321.git.pabeni@redhat.com>
         <1480113022.8455.580.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54688 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751821AbcK0QVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 11:21:42 -0500
In-Reply-To: <1480113022.8455.580.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, 2016-11-25 at 14:30 -0800, Eric Dumazet wrote:
> On Fri, 2016-11-25 at 16:39 +0100, Paolo Abeni wrote:
> > _skb_try_recv_datagram_batch dequeues multiple skb's from the
> > socket's receive queue, and runs the bulk_destructor callback under
> > the receive queue lock.
> 
> ...
> 
> > +	last = (struct sk_buff *)queue;
> > +	first = (struct sk_buff *)queue->next;
> > +	skb_queue_walk(queue, skb) {
> > +		last = skb;
> > +		totalsize += skb->truesize;
> > +		if (++datagrams == batch)
> > +			break;
> > +	}
> 
> This is absolutely not good.
> 
> Walking through a list, bringing 2 cache lines per skb, is not the
> proper way to deal with bulking.
> 
> And I do not see where 'batch' value coming from user space is capped ?
> 
> Is it really vlen argument coming from recvmmsg() system call ???
> 
> This code runs with BH masked, so you do not want to give user a way to
> make you loop there 1000 times 
> 
> Bulking is nice, only if you do not compromise with system stability and
> latency requirements from other users/applications.

Thank you for reviewing this.

You are right, the cacheline miss while accessing skb->truesize has
measurable performance impact, and the max burst length comes in from
recvmmsg(). 

We can easily cap the burst to some max value (e.g. 64 or less) and we
can pass to the bulk destructor the skb list and burst length without
accessing skb truesize beforehand. If the burst is short, say 8 skbs or
less, the bulk destructor walk again the list and release the memory,
elsewhere it defers the release after __skb_try_recv_datagram_batch()
completion: we walk the list without the lock held and we acquire it
later again to release all the memory. 

Thank you again,

Paolo
