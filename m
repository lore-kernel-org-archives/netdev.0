From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Tue, 7 Sep 2010 11:10:00 -0700
Message-ID: <20100907181000.GF2448@linux.vnet.ibm.com>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<20100907171917.GD2448@linux.vnet.ibm.com>
	<201009071956.54499.sven.eckelmann@gmx.de>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwlltHuzzzSOjJt@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201009071956.54499.sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2010 at 07:56:53PM +0200, Sven Eckelmann wrote:
> Thanks for your comment. I removed the parts you don't refer to (makes it lot 
> easier to find the actual comment).

I guess I can always refer to the original to see the related code.  ;-)

> Paul E. McKenney wrote:
> > > +
> > > +#include <linux/if_arp.h>
> > > +
> > > +#define MIN(x, y) ((x) < (y) ? (x) : (y))
> > > +
> > > +struct batman_if *get_batman_if_by_netdev(struct net_device *net_dev)
> > > +{
> > > +     struct batman_if *batman_if;
> > > +
> > > +     rcu_read_lock();
> > > +     list_for_each_entry_rcu(batman_if, &if_list, list) {
> > > +             if (batman_if->net_dev == net_dev)
> > > +                     goto out;
> > > +     }
> > > +
> > > +     batman_if = NULL;
> > > +
> > > +out:
> > > +     rcu_read_unlock();
> > 
> > Here we are leaking an RCU-protected pointer outside of the RCU read-side
> > critical section.  Why is this safe?
> 
> First thing: Their is another rcu related problem with a call_rcu and the 
> missing explicit (so not done implizit by another function) synchronize_rcu 
> before the shutdown. This was fixed right after this patch was send for a 
> review... bad timing, but ok.

Fair enough!

> > Here is the sequence of events that I am concerned about:
> > 
> > 1.      CPU 0 executes the code above, obtains a pointer, and is about
> >         ready to return.
> > 
> > 2.      CPU 1 executes hardif_remove_interface(), and calls
> >         hardif_disable_interface(), which calls
> >         hardif_deactivate_interface(), which sets ->if_status to
> >         IF_INACTIVE.  Then hardif_disable_interface() sets ->if_status
> >         to IF_NOT_IN_USE.  Then hardif_remove_interface() frees
> >         the interface via call_rcu().
> > 
> > 3.      Of course, call_rcu() waits for an RCU grace period to elapse,
> >         but we are no longer in an RCU read-side critical section,
> >         so there is nothing stopping the grace period from completing
> >         before we are done with the batman_if pointer.
> > 
> > Or am I missing some other interlock that prevents
> > hardif_remove_interface() from freeing this structure?
> > 
> > I have similar concerns with your other RCU read-side critical sections.
> 
> Looks to me like a valid point. I have to think a little bit how to solve it 
> correctly. Feel free to add more comments about other rcu cruelties in it.

One approach would be to extend the RCU read-side critical section to
cover all uses of the RCU-protected pointer.  Another approach would be
to take a reference count (or something similar) before the pointer
leaves the RCU read-side critical section.

Could you please take a look at Documentation/RCU/checklist.txt?

Because I am not familiar with the BATMAN device, it is all too easy
for me to miss subtleties in the code.

							Thanx, Paul
