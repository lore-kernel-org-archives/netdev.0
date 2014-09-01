From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Mon, 1 Sep 2014 12:52:19 +0300
Message-ID: <20140901095219.GD21269@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
 <1408683665.5648.69.camel@marge.simpson.net>
 <20140901093159.GB27892@worktop.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752991AbaIAJxA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2014 05:53:00 -0400
Content-Disposition: inline
In-Reply-To: <20140901093159.GB27892@worktop.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 01, 2014 at 11:31:59AM +0200, Peter Zijlstra wrote:
> On Fri, Aug 22, 2014 at 07:01:05AM +0200, Mike Galbraith wrote:
> > > +++ b/include/net/busy_poll.h
> > > @@ -109,7 +109,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
> > >  		cpu_relax();
> > >  
> > >  	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
> > > -		 !need_resched() && !busy_loop_timeout(end_time));
> > > +		 !need_resched() && !busy_loop_timeout(end_time) &&
> > > +		 nr_running_this_cpu() < 2);
> > >  
> 
> So as has been said by now; this is horrible.
> 
> We should not export nr_running like this ever. Your usage of < 2
> implies this can be hit with nr_running == 0, and therefore you can also
> hit it with nr_running == 1 where the one is not network related and you
> get random delays.
> 
> Worse still, you have BH (and thereby preemption) disabled, you should
> not _ever_ have undefined and indefinite waits like that.
> 
> You also destroy any hope of dropping into lower power states; even when
> there's never going to be a packet ever again, also bad.

Hmm this patch sometimes makes us exit from the busy loop *earlier*.
How can this interfere with dropping into lower power states?

> All in all, a complete trainwreck.
> 
> NAK.
