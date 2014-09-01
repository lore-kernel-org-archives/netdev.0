From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Mon, 1 Sep 2014 12:19:39 +0200
Message-ID: <20140901101939.GA31157@worktop.ger.corp.intel.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
 <1408683665.5648.69.camel@marge.simpson.net>
 <20140901093159.GB27892@worktop.ger.corp.intel.com>
 <20140901095219.GD21269@redhat.com>
 <20140901100434.GD27892@worktop.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140901100434.GD27892@worktop.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 01, 2014 at 12:04:34PM +0200, Peter Zijlstra wrote:
> On Mon, Sep 01, 2014 at 12:52:19PM +0300, Michael S. Tsirkin wrote:
> > On Mon, Sep 01, 2014 at 11:31:59AM +0200, Peter Zijlstra wrote:
> > > On Fri, Aug 22, 2014 at 07:01:05AM +0200, Mike Galbraith wrote:
> > > > > +++ b/include/net/busy_poll.h
> > > > > @@ -109,7 +109,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
> > > > >  		cpu_relax();
> > > > >  
> > > > >  	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
> > > > > -		 !need_resched() && !busy_loop_timeout(end_time));
> > > > > +		 !need_resched() && !busy_loop_timeout(end_time) &&
> > > > > +		 nr_running_this_cpu() < 2);
> > > > >  
> > > 
> > > So as has been said by now; this is horrible.
> > > 
> > > We should not export nr_running like this ever. Your usage of < 2
> > > implies this can be hit with nr_running == 0, and therefore you can also
> > > hit it with nr_running == 1 where the one is not network related and you
> > > get random delays.
> > > 
> > > Worse still, you have BH (and thereby preemption) disabled, you should
> > > not _ever_ have undefined and indefinite waits like that.
> > > 
> > > You also destroy any hope of dropping into lower power states; even when
> > > there's never going to be a packet ever again, also bad.
> > 
> > Hmm this patch sometimes makes us exit from the busy loop *earlier*.
> > How can this interfere with dropping into lower power states?
> 
> Ah.. jetlag.. :/ I read it like it owuld indefinitely spin if there was
> only the 'one' task, not avoid the spin unless there was the one task.
> 
> The nr_running thing is still horrible, but let me reread this patch
> description to see if it explains why that is a good thing.

OK I suppose that more or less makes sense, the contextual behaviour is
of course tedious in that it makes behaviour less predictable. The
'other' tasks might not want to generate data and you then destroy
throughput by not spinning.

I'm not entirely sure I see how its all supposed to work though; the
various poll functions call sk_busy_poll() and do_select() also loops.

The patch only kills the sk_busy_poll() loop, but then do_select() will
still loop and not sleep, so how is this helping?
