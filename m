From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Fri, 5 Jun 2009 09:25:53 -0700
Message-ID: <20090605162553.GC6778@linux.vnet.ibm.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <200906051425.02924.rusty@rustcorp.com.au> <20090605053010.GD7125@linux.vnet.ibm.com> <200906060025.57961.rusty@rustcorp.com.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200906060025.57961.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 06, 2009 at 12:25:57AM +0930, Rusty Russell wrote:
> On Fri, 5 Jun 2009 03:00:10 pm Paul E. McKenney wrote:
> > On Fri, Jun 05, 2009 at 02:25:01PM +0930, Rusty Russell wrote:
> > > +	/* lg->eventfds is RCU-protected */
> > > +	preempt_disable();
> >
> > Suggest changing to rcu_read_lock() to match the synchronize_rcu().
> 
> Ah yes, much better.  As I was implementing it I warred with myself since
> lguest aims for simplicity above all else.  But since we only ever add things
> to the array, RCU probably is simpler.

;-)

> > > +	for (i = 0; i < cpu->lg->num_eventfds; i++) {
> > > +		if (cpu->lg->eventfds[i].addr == cpu->pending_notify) {
> > > +			eventfd_signal(cpu->lg->eventfds[i].event, 1);
> >
> > Shouldn't this be something like the following?
> >
> > 		p = rcu_dereference(cpu->lg->eventfds);
> > 		if (p[i].addr == cpu->pending_notify) {
> > 			eventfd_signal(p[i].event, 1);
> 
> Hmm, need to read num_eventfds first, too.  It doesn't matter if we get the old
> ->num_eventfds and the new ->eventfds, but the other way around would be bad.

Yep!!!  ;-)

> Here's the inter-diff:
> 
> diff --git a/drivers/lguest/lguest_user.c b/drivers/lguest/lguest_user.c
> --- a/drivers/lguest/lguest_user.c
> +++ b/drivers/lguest/lguest_user.c
> @@ -39,18 +39,24 @@ static int break_guest_out(struct lg_cpu
> 
>  bool send_notify_to_eventfd(struct lg_cpu *cpu)
>  {
> -	unsigned int i;
> +	unsigned int i, num;
> +	struct lg_eventfds *eventfds;
> +
> +	/* Make sure we grab the total number before accessing the array. */
> +	cpu->lg->num_eventfds = num;
> +	rmb();
> 
>  	/* lg->eventfds is RCU-protected */
>  	rcu_read_lock();
> -	for (i = 0; i < cpu->lg->num_eventfds; i++) {
> -		if (cpu->lg->eventfds[i].addr == cpu->pending_notify) {
> -			eventfd_signal(cpu->lg->eventfds[i].event, 1);
> +	eventfds = rcu_dereference(cpu->lg->eventfds);
> +	for (i = 0; i < num; i++) {
> +		if (eventfds[i].addr == cpu->pending_notify) {
> +			eventfd_signal(eventfds[i].event, 1);
>  			cpu->pending_notify = 0;
>  			break;
>  		}
>  	}
> -	preempt_enable();
> +	rcu_read_unlock();
>  	return cpu->pending_notify == 0;
>  }

It is possible to get rid of the rmb() and wmb() as well, doing
something like the following:

	struct lg_eventfds_num {
		unsigned int n;
		struct lg_eventfds a[0];
	}

Then the rcu_dereference() gets you a pointer to a struct lg_eventfds_num,
which has the array and its length in guaranteed synchronization without
the need for barriers.

Does this work for you, or is there some complication that I am missing?

							Thanx, Paul

