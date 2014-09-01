From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Mon, 1 Sep 2014 11:31:59 +0200
Message-ID: <20140901093159.GB27892@worktop.ger.corp.intel.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
 <1408683665.5648.69.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Ingo Molnar <mingo@elte.hu>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1408683665.5648.69.camel@marge.simpson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 22, 2014 at 07:01:05AM +0200, Mike Galbraith wrote:
> > +++ b/include/net/busy_poll.h
> > @@ -109,7 +109,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
> >  		cpu_relax();
> >  
> >  	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
> > -		 !need_resched() && !busy_loop_timeout(end_time));
> > +		 !need_resched() && !busy_loop_timeout(end_time) &&
> > +		 nr_running_this_cpu() < 2);
> >  

So as has been said by now; this is horrible.

We should not export nr_running like this ever. Your usage of < 2
implies this can be hit with nr_running == 0, and therefore you can also
hit it with nr_running == 1 where the one is not network related and you
get random delays.

Worse still, you have BH (and thereby preemption) disabled, you should
not _ever_ have undefined and indefinite waits like that.

You also destroy any hope of dropping into lower power states; even when
there's never going to be a packet ever again, also bad.

All in all, a complete trainwreck.

NAK.
