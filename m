From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] drivers/net: Use RCU_INIT_POINTER(x, NULL) in tun.c
Date: Mon, 24 Mar 2014 07:09:39 +0200
Message-ID: <20140324050939.GB8832@redhat.com>
References: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>
 <20140323194113.GA13633@redhat.com>
 <1395604457.9117.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140323213349.GA8832@redhat.com>
 <20140323221256.GG4405@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Monam Agarwal <monamagarwal123@gmail.com>, davem@davemloft.net,
	jasowang@redhat.com, xemul@parallels.com, wuzhy@linux.vnet.ibm.com,
	therbert@google.com, yamato@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140323221256.GG4405@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 23, 2014 at 03:12:56PM -0700, Paul E. McKenney wrote:
> On Sun, Mar 23, 2014 at 11:33:49PM +0200, Michael S. Tsirkin wrote:
> > On Sun, Mar 23, 2014 at 12:54:17PM -0700, Eric Dumazet wrote:
> > > On Sun, 2014-03-23 at 21:41 +0200, Michael S. Tsirkin wrote:
> > > 
> > > > The rcu_assign_pointer() ensures that the initialization of a structure       
> > > > is carried out before storing a pointer to that structure. 
> > > > In the case of the NULL pointer, there is no structure to initialize,
> > > > so we can safely drop smp_wmb in this case.
> > > > 
> > > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > > 
> > > > --
> > > > 
> > > > Lightly tested.
> > > > v is evaluated twice here but that should be ok since this
> > > > only happens when v is a constant, so evaluating it should
> > > > have no side effects.
> > > > Paul, what do you think?
> > > > 
> > > > diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> > > > index 72bf3a0..d33c9ec 100644
> > > > --- a/include/linux/rcupdate.h
> > > > +++ b/include/linux/rcupdate.h
> > > > @@ -587,7 +587,8 @@ static inline void rcu_preempt_sleep_check(void)
> > > >   */
> > > >  #define rcu_assign_pointer(p, v) \
> > > >  	do { \
> > > > -		smp_wmb(); \
> > > > +		if (!__builtin_constant_p(v) || (v)) \
> > > > +			smp_wmb(); \
> > > >  		ACCESS_ONCE(p) = RCU_INITIALIZER(v); \
> > > >  	} while (0)
> > > >  
> > > 
> > > Yeah, I suggest you read d322f45ceed525daa changelog ;)
> > > 
> > 
> > Oh I see. It does not seem hard to silence that warning though.
> > See below.
> 
> This would at the very least need to be tested under a wide variety
> of compilers.

Seems an incredibly strict requirement for something that just
silences a warning.
What exactly should I test?
I intended to just verify this produces same code as before
d322f45ceed525daa under a recent gcc.

>  And we need to keep 
> 
> > Alternatively apply these patches everywhere though it does
> > look like too much work for too little gain to me.
> > 
> > -->
> > 
> > rcu: optimize rcu_assign_pointer with NULL
> > 
> > The rcu_assign_pointer() dropped __builtin_constant_p check to
> > avoid a compiler warning, but we can actually work around it without
> > adding code.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > 
> > ---
> > 
> > Untested, too late here, sorry.
> > 
> > 
> > diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> > index 72bf3a0..9111d40 100644
> > --- a/include/linux/rcupdate.h
> > +++ b/include/linux/rcupdate.h
> > @@ -585,9 +585,14 @@ static inline void rcu_preempt_sleep_check(void)
> >   * please be careful when making changes to rcu_assign_pointer() and the
> >   * other macros that it invokes.
> >   */
> > +/* The convoluted __builtin_constant_p logic is here to prevent
> > + * gcc from emitting a warning when passed a pointer to a variable.
> > + */
> >  #define rcu_assign_pointer(p, v) \
> >  	do { \
> > -		smp_wmb(); \
> > +		if (!__builtin_constant_p(v) || \
> > +		    (__builtin_constant_p(v) ? (v) : NULL)) \
> 
> You lost me on this one.  If "v" is not a built-in constant, we want
> the smp_wmb(), right?

If "v" is not a built-in constant, then !__builtin_constant_p(v)
is true so (__builtin_constant_p(v) ? (v) : NULL))
is never evaluated.

Basically if (

	1.   !A ||
	2.   A ? B : C

If A  is false, only 1 is evaluated and the expression evaluates to true
If A  is true, then 2 evaluates to B.
C is never evaluated.

Makes sense? Did I miss anything?

But the effect as far as I can tell is that instead of converting v to
integer type we convert an expression involving v, so even though it's
able to figure out the value, gcc understands it's not a typo
and does not warn.


	

> 							Thanx, Paul
> 
> > +			smp_wmb(); \
> >  		ACCESS_ONCE(p) = RCU_INITIALIZER(v); \
> >  	} while (0)
> > 
> > 
