From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] RCU: introduce noref debug
Date: Tue, 10 Oct 2017 21:02:25 -0700
Message-ID: <20171011040225.GU3521@linux.vnet.ibm.com>
References: <cover.1507294365.git.pabeni@redhat.com>
 <20171006133436.GY3521@linux.vnet.ibm.com>
 <1507302609.2793.16.camel@redhat.com>
 <20171006163414.GC3521@linux.vnet.ibm.com>
 <1507567992.21825.9.camel@redhat.com>
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
In-Reply-To: <1507567992.21825.9.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 06:53:12PM +0200, Paolo Abeni wrote:
> On Fri, 2017-10-06 at 09:34 -0700, Paul E. McKenney wrote:
> > On Fri, Oct 06, 2017 at 05:10:09PM +0200, Paolo Abeni wrote:
> > > Hi,
> > > 
> > > On Fri, 2017-10-06 at 06:34 -0700, Paul E. McKenney wrote:
> > > > On Fri, Oct 06, 2017 at 02:57:45PM +0200, Paolo Abeni wrote:
> > > > > The networking subsystem is currently using some kind of long-lived
> > > > > RCU-protected, references to avoid the overhead of full book-keeping.
> > > > > 
> > > > > Such references - skb_dst() noref - are stored inside the skbs and can be
> > > > > moved across relevant slices of the network stack, with the users
> > > > > being in charge of properly clearing the relevant skb - or properly refcount
> > > > > the related dst references - before the skb escapes the RCU section.
> > > > > 
> > > > > We currently don't have any deterministic debug infrastructure to check
> > > > > the dst noref usages - and the introduction of others noref artifact is
> > > > > currently under discussion.
> > > > > 
> > > > > This series tries to tackle the above introducing an RCU debug infrastructure
> > > > > aimed at spotting incorrect noref pointer usage, in patch one. The
> > > > > infrastructure is small and must be explicitly enabled via a newly introduced
> > > > > build option.
> > > > > 
> > > > > Patch two uses such infrastructure to track dst noref usage in the networking
> > > > > stack.
> > > > > 
> > > > > Patch 3 and 4 are bugfixes for small buglet found running this infrastructure
> > > > > on basic scenarios.
> > > 
> > > Thank you for the prompt reply!
> > > > 
> > > > This patchset does not look like it handles rcu_read_lock() nesting.
> > > > For example, given code like this:
> > > > 
> > > > 	void foo(void)
> > > > 	{
> > > > 		rcu_read_lock();
> > > > 		rcu_track_noref(&key2, &noref2, true);
> > > > 		do_something();
> > > > 		rcu_track_noref(&key2, &noref2, false);
> > > > 		rcu_read_unlock();
> > > > 	}
> > > > 
> > > > 	void bar(void)
> > > > 	{
> > > > 		rcu_read_lock();
> > > > 		rcu_track_noref(&key1, &noref1, true);
> > > > 		do_something_more();
> > > > 		foo();
> > > > 		do_something_else();
> > > > 		rcu_track_noref(&key1, &noref1, false);
> > > > 		rcu_read_unlock();
> > > > 	}
> > > > 
> > > > 	void grill(void)
> > > > 	{
> > > > 		foo();
> > > > 	}
> > > > 
> > > > It looks like foo()'s rcu_read_unlock() will complain about key1.
> > > > You could remove foo()'s rcu_read_lock() and rcu_read_unlock(), but
> > > > that will break the call from grill().
> > > 
> > > Actually the code should cope correctly with your example; when foo()'s
> > > rcu_read_unlock() is called, 'cache' contains:
> > > 
> > > { { &key1, &noref1, 1},  // ...
> > > 
> > > and when the related __rcu_check_noref() is invoked preempt_count() is
> > > 2 - because the check is called before decreasing the preempt counter.
> > > 
> > > In the main loop inside __rcu_check_noref() we will hit always the
> > > 'continue' statement because 'cache->store[i].nesting != nesting', so
> > > no warn will be triggered.
> > 
> > You are right, it was too early, and my example wasn't correct.  How
> > about this one?
> > 
> > 	void foo(void (*f)(struct s *sp), struct s **spp)
> > 	{
> > 		rcu_read_lock();
> > 		rcu_track_noref(&key2, &noref2, true);
> > 		f(spp);
> > 		rcu_track_noref(&key2, &noref2, false);
> > 		rcu_read_unlock();
> > 	}
> > 
> > 	void barcb(struct s **spp)
> > 	{
> > 		*spp = &noref3;
> > 		rcu_track_noref(&key3, *spp, true);
> > 	}
> > 
> > 	void bar(void)
> > 	{
> > 		struct s *sp;
> > 
> > 		rcu_read_lock();
> > 		rcu_track_noref(&key1, &noref1, true);
> > 		do_something_more();
> > 		foo(barcb, &sp);
> > 		do_something_else(sp);
> > 		rcu_track_noref(&key3, sp, false);
> > 		rcu_track_noref(&key1, &noref1, false);
> > 		rcu_read_unlock();
> > 	}
> > 
> > 	void grillcb(struct s **spp)
> > 	{
> > 		*spp
> > 	}
> > 
> > 	void grill(void)
> > 	{
> > 		foo();
> > 	}
> 
> You are right: this will generate a splat, even if the code it safe.
> The false positive can be avoided looking for leaked references only in
> the outermost rcu unlook. I did a previous implementation performing
> such check, but it emitted very generic splat so I tried to be more
> strict. The latter choice allowed to find/do 3/4.
> 
> What about using save_stack_trace() in rcu_track_noref(, true) and
> reporting such stack trace when the check in the outer most rcu fails?
> 
> the current strict/false-postive-prone check could be enabled under an
> additional build flag.

Linus and Ingo will ask me how users decide how they should set that
additional build flag.  Especially given that if there is code that
requires non-strict checking, isn't everyone required to set up non-strict
checking to avoid false positives?  Unless you can also configure out
all the code that requires non-strict checking, I suppose, but how
would you keep track of what to configure out?

> > How does the user select the key argument?  It looks like someone
> > can choose to just pass in NULL -- is that the intent, or am I confused
> > about this as well?
> 
> The 'key' argument is intented to discriminate the scope of the same
> noref dst attached to different skbs, which happens e.g. as a result of
> as skb_dst_copy().
> 
> In a generic use case, it can be NULL, too.

OK.  There will probably be some discussion about the API in that case.

> > I am also concerned about false negatives when the user invokes
> > rcu_track_noref(..., false) but then leaks the pointer anyway.  Or is
> > there something you are doing that catches this that I am missing?
> 
> If the rcu_track_noref(..., false) is misplaced or missing, yes we can
> have false negative. 
> 
> In the noref rcu use-case the rcu_track_noref(, false) call is/must be
> placed side-by-side with the code clearing the the noref pointer, so
> is/should be quite easy avoiding such mistakes.

True enough.  Except that if people were good about always clearing the
pointer, then the pointer couldn't leak, right?  Or am I missing something
in your use cases?

Or to put it another way -- have you been able to catch any real
pointer-leak bugs with this?  The other RCU debug options have had
pretty long found-bug lists before we accepted them.

							Thanx, Paul
