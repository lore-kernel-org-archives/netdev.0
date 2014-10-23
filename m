From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Thu, 23 Oct 2014 13:05:07 -0700
Message-ID: <20141023200507.GC4977@linux.vnet.ibm.com>
References: <20141022181135.GH4977@linux.vnet.ibm.com>
 <87d29kezby.fsf@x220.int.ebiederm.org>
 <20141022185511.GI4977@linux.vnet.ibm.com>
 <CA+5PVA56ajrBQ-C9orSb9-_qhMKe994QL2x0FcKbe6BYmaWFBw@mail.gmail.com>
 <20141022224032.GA1240@declera.com>
 <20141022232421.GN4977@linux.vnet.ibm.com>
 <1414044566.2031.1.camel@declera.com>
 <20141023122750.GP4977@linux.vnet.ibm.com>
 <20141023153333.GA19278@linux.vnet.ibm.com>
 <20141023195159.GA2331@declera.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Yanko Kaneti <yaneti@declera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:39574 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932449AbaJWUJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2014 16:09:07 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 23 Oct 2014 16:09:02 -0400
Content-Disposition: inline
In-Reply-To: <20141023195159.GA2331@declera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2014 at 10:51:59PM +0300, Yanko Kaneti wrote:
> On Thu-10/23/14-2014 08:33, Paul E. McKenney wrote:
> > On Thu, Oct 23, 2014 at 05:27:50AM -0700, Paul E. McKenney wrote:
> > > On Thu, Oct 23, 2014 at 09:09:26AM +0300, Yanko Kaneti wrote:
> > > > On Wed, 2014-10-22 at 16:24 -0700, Paul E. McKenney wrote:
> > > > > On Thu, Oct 23, 2014 at 01:40:32AM +0300, Yanko Kaneti wrote:
> > > > > > On Wed-10/22/14-2014 15:33, Josh Boyer wrote:
> > > > > > > On Wed, Oct 22, 2014 at 2:55 PM, Paul E. McKenney
> > > > > > > <paulmck@linux.vnet.ibm.com> wrote:
> > > > > 
> > > > > [ . . . ]
> > > > > 
> > > > > > > > Don't get me wrong -- the fact that this kthread appears to 
> > > > > > > > have
> > > > > > > > blocked within rcu_barrier() for 120 seconds means that 
> > > > > > > > something is
> > > > > > > > most definitely wrong here.  I am surprised that there are no 
> > > > > > > > RCU CPU
> > > > > > > > stall warnings, but perhaps the blockage is in the callback 
> > > > > > > > execution
> > > > > > > > rather than grace-period completion.  Or something is 
> > > > > > > > preventing this
> > > > > > > > kthread from starting up after the wake-up callback executes.  
> > > > > > > > Or...
> > > > > > > > 
> > > > > > > > Is this thing reproducible?
> > > > > > > 
> > > > > > > I've added Yanko on CC, who reported the backtrace above and can
> > > > > > > recreate it reliably.  Apparently reverting the RCU merge commit
> > > > > > > (d6dd50e) and rebuilding the latest after that does not show the
> > > > > > > issue.  I'll let Yanko explain more and answer any questions you 
> > > > > > > have.
> > > > > > 
> > > > > > - It is reproducible
> > > > > > - I've done another build here to double check and its definitely 
> > > > > > the rcu merge
> > > > > >   that's causing it.
> > > > > > 
> > > > > > Don't think I'll be able to dig deeper, but I can do testing if 
> > > > > > needed.
> > > > > 
> > > > > Please!  Does the following patch help?
> > > > 
> > > > Nope, doesn't seem to make a difference to the modprobe ppp_generic 
> > > > test
> > > 
> > > Well, I was hoping.  I will take a closer look at the RCU merge commit
> > > and see what suggests itself.  I am likely to ask you to revert specific
> > > commits, if that works for you.
> > 
> > Well, rather than reverting commits, could you please try testing the
> > following commits?
> > 
> > 11ed7f934cb8 (rcu: Make nocb leader kthreads process pending callbacks after spawning)
> > 
> > 73a860cd58a1 (rcu: Replace flush_signals() with WARN_ON(signal_pending()))
> > 
> > c847f14217d5 (rcu: Avoid misordering in nocb_leader_wait())
> > 
> > 	For whatever it is worth, I am guessing this one.
> 
> Indeed, c847f14217d5 it is.
> 
> Much to my embarrasment I just noticed that in addition to the
> rcu merge, triggering the bug "requires" my specific Fedora rawhide network
> setup. Booting in single mode and modprobe ppp_generic is fine. The bug
> appears when starting with my regular fedora network setup, which in my case 
> includes 3 ethernet adapters and a libvirt birdge+nat setup.
> 
> Hope that helps. 
> 
> I am attaching the config.

It does help a lot, thank you!!!

The following patch is a bit of a shot in the dark, and assumes that
commit 1772947bd012 (rcu: Handle NOCB callbacks from irq-disabled idle
code) introduced the problem.  Does this patch fix things up?

							Thanx, Paul

------------------------------------------------------------------------

rcu: Kick rcuo kthreads after their CPU goes offline

If a no-CBs CPU were to post an RCU callback with interrupts disabled
after it entered the idle loop for the last time, there might be no
deferred wakeup for the corresponding rcuo kthreads.  This commit
therefore adds a set of calls to do_nocb_deferred_wakeup() after the
CPU has gone completely offline.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 84b41b3c6ebd..4f3d25a58786 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3493,8 +3493,10 @@ static int rcu_cpu_notify(struct notifier_block *self,
 	case CPU_DEAD_FROZEN:
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
-		for_each_rcu_flavor(rsp)
+		for_each_rcu_flavor(rsp) {
 			rcu_cleanup_dead_cpu(cpu, rsp);
+			do_nocb_deferred_wakeup(this_cpu_ptr(rsp->rda));
+		}
 		break;
 	default:
 		break;
