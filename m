From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] RCU: introduce noref debug
Date: Fri, 6 Oct 2017 09:34:14 -0700
Message-ID: <20171006163414.GC3521@linux.vnet.ibm.com>
References: <cover.1507294365.git.pabeni@redhat.com>
 <20171006133436.GY3521@linux.vnet.ibm.com>
 <1507302609.2793.16.camel@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507302609.2793.16.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 06, 2017 at 05:10:09PM +0200, Paolo Abeni wrote:
> Hi,
> 
> On Fri, 2017-10-06 at 06:34 -0700, Paul E. McKenney wrote:
> > On Fri, Oct 06, 2017 at 02:57:45PM +0200, Paolo Abeni wrote:
> > > The networking subsystem is currently using some kind of long-lived
> > > RCU-protected, references to avoid the overhead of full book-keeping.
> > > 
> > > Such references - skb_dst() noref - are stored inside the skbs and can be
> > > moved across relevant slices of the network stack, with the users
> > > being in charge of properly clearing the relevant skb - or properly refcount
> > > the related dst references - before the skb escapes the RCU section.
> > > 
> > > We currently don't have any deterministic debug infrastructure to check
> > > the dst noref usages - and the introduction of others noref artifact is
> > > currently under discussion.
> > > 
> > > This series tries to tackle the above introducing an RCU debug infrastructure
> > > aimed at spotting incorrect noref pointer usage, in patch one. The
> > > infrastructure is small and must be explicitly enabled via a newly introduced
> > > build option.
> > > 
> > > Patch two uses such infrastructure to track dst noref usage in the networking
> > > stack.
> > > 
> > > Patch 3 and 4 are bugfixes for small buglet found running this infrastructure
> > > on basic scenarios.
> 
> Thank you for the prompt reply!
> > 
> > This patchset does not look like it handles rcu_read_lock() nesting.
> > For example, given code like this:
> > 
> > 	void foo(void)
> > 	{
> > 		rcu_read_lock();
> > 		rcu_track_noref(&key2, &noref2, true);
> > 		do_something();
> > 		rcu_track_noref(&key2, &noref2, false);
> > 		rcu_read_unlock();
> > 	}
> > 
> > 	void bar(void)
> > 	{
> > 		rcu_read_lock();
> > 		rcu_track_noref(&key1, &noref1, true);
> > 		do_something_more();
> > 		foo();
> > 		do_something_else();
> > 		rcu_track_noref(&key1, &noref1, false);
> > 		rcu_read_unlock();
> > 	}
> > 
> > 	void grill(void)
> > 	{
> > 		foo();
> > 	}
> > 
> > It looks like foo()'s rcu_read_unlock() will complain about key1.
> > You could remove foo()'s rcu_read_lock() and rcu_read_unlock(), but
> > that will break the call from grill().
> 
> Actually the code should cope correctly with your example; when foo()'s
> rcu_read_unlock() is called, 'cache' contains:
> 
> { { &key1, &noref1, 1},  // ...
> 
> and when the related __rcu_check_noref() is invoked preempt_count() is
> 2 - because the check is called before decreasing the preempt counter.
> 
> In the main loop inside __rcu_check_noref() we will hit always the
> 'continue' statement because 'cache->store[i].nesting != nesting', so
> no warn will be triggered.

You are right, it was too early, and my example wasn't correct.  How
about this one?

	void foo(void (*f)(struct s *sp), struct s **spp)
	{
		rcu_read_lock();
		rcu_track_noref(&key2, &noref2, true);
		f(spp);
		rcu_track_noref(&key2, &noref2, false);
		rcu_read_unlock();
	}

	void barcb(struct s **spp)
	{
		*spp = &noref3;
		rcu_track_noref(&key3, *spp, true);
	}

	void bar(void)
	{
		struct s *sp;

		rcu_read_lock();
		rcu_track_noref(&key1, &noref1, true);
		do_something_more();
		foo(barcb, &sp);
		do_something_else(sp);
		rcu_track_noref(&key3, sp, false);
		rcu_track_noref(&key1, &noref1, false);
		rcu_read_unlock();
	}

	void grillcb(struct s **spp)
	{
		*spp
	}

	void grill(void)
	{
		foo();
	}

How does the user select the key argument?  It looks like someone
can choose to just pass in NULL -- is that the intent, or am I confused
about this as well?

> > Or am I missing something subtle here?  Given patch 3/4, I suspect not...
> 
> The problem with the code in patch 3/4 is different; currently
> ip_route_input_noref() is basically doing:
> 
> rcu_read_lock();
> 
> rcu_track_noref(&key1, &noref1, true);
> 
> rcu_read_unlock();
> 
> So the rcu lock there silence any RCU based check inside
> ip_route_input_noref() but does not really protect the noref dst.
> 
> Please let me know if the above clarify the scenario.

OK.

I am also concerned about false negatives when the user invokes
rcu_track_noref(..., false) but then leaks the pointer anyway.  Or is
there something you are doing that catches this that I am missing?

							Thanx, Paul
