From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: tc related lockdep warning.
Date: Fri, 29 Sep 2006 08:28:18 +0200
Message-ID: <20060929062818.GA1011@ff.dom.local>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com> <20060927085427.GA1619@ff.dom.local> <451BBD6F.6020007@trash.net> <20060928131301.GB3283@ff.dom.local> <20060928072000.014009f2@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Dave Jones <davej@redhat.com>,
	hadi@cyberus.ca, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:29639 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1161425AbWI2GX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 02:23:57 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060928072000.014009f2@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 07:20:00AM -0700, Stephen Hemminger wrote:
> On Thu, 28 Sep 2006 15:13:01 +0200
> Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
> > On Thu, Sep 28, 2006 at 02:17:51PM +0200, Patrick McHardy wrote:
> > > [My mail provider is down, so responding "manually"]
> > > 
> > > Jarek Poplawski wrote:
> > > > > [NET_SCHED]: Fix fallout from dev->qdisc RCU change
> > > >
> > > > Sorry again but I can't abstain from some doubts:
> > > >
> > > > ...
> > > > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > > > index 14de297..4d891be 100644
> > > > > --- a/net/core/dev.c
> > > > > +++ b/net/core/dev.c
> > > > > @@ -1480,14 +1480,16 @@ #endif
> > > > >  	if (q->enqueue) {
> > > > >  		/* Grab device queue */
> > > > >  		spin_lock(&dev->queue_lock);
> > > > > +		q = dev->qdisc;
> > > >
> > > > I don't get it. If it is some anti-race step according to
> > > > rcu rules it should be again:
> > > > q = rcu_dereference(dev->qdisc);
> > > 
> > > At this point RCU protection is not needed anymore since we
> > > have the lock. We simply want to avoid taking the lock for
> > > devices that don't have a real qdisc attached (like loopback).
> > > Thats what the test for q->enqueue is there for. RCU is only
> > > needed to avoid races between testing q->enqueue and freeing
> > > of the qdisc.
> > 
> > But in Documentation/RCU/whatisRCU.txt I see this:
> > 
> >         /*
> >          * Return the value of field "a" of the current gbl_foo
> >          * structure.  Use rcu_read_lock() and rcu_read_unlock()
> >          * to ensure that the structure does not get deleted out
> >          * from under us, and use rcu_dereference() to ensure that
> >          * we see the initialized version of the structure (important
> >          * for DEC Alpha and for people reading the code).
> >          */
> >         int foo_get_a(void)
> >         {
> >                 int retval;
> > 
> >                 rcu_read_lock();
> >                 retval = rcu_dereference(gbl_foo)->a;
> >                 rcu_read_unlock();
> >                 return retval;
> >         }
> > 
> 
> The example uses rcu_read_lock() which is a weaker form of protection
> than a real lock, so the rcu_dereference() is needed to do memory barriers.

I don't question this and I know it is not required - I mean
what is in the parenthesis ("important ...") or here: 

>From Documentation/RCU/checklist.txt:

                The rcu_dereference() primitive is used by the various
                "_rcu()" list-traversal primitives, such as the
                list_for_each_entry_rcu().  Note that it is perfectly
                legal (if redundant) for update-side code to use
                rcu_dereference() and the "_rcu()" list-traversal
                primitives.  This is particularly useful in code
                that is common to readers and updaters.


> In the qdisc case we have the proper spin_lock() so no additional
> barrier is needed.

So why isn't it done in the code instead of comments?: 

	if (q->enqueue) {

                rcu_read_unlock();

  		/* Grab device queue */
  		spin_lock(&dev->queue_lock);
		q = dev->qdisc;
	...
	}
        rcu_read_unlock();

I mean the consequence.

Another thing is why? Now it looks RCU is good for the first test
but we don't believe it entirely (or assume the pointer could change
at this particular moment) so take this pointer again with
a real lock. I think RCU assures the consistency within it's block 
and we should only test for NULL pointer.


Jarek P.
