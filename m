From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Wed, 22 Oct 2014 16:24:21 -0700
Message-ID: <20141022232421.GN4977@linux.vnet.ibm.com>
References: <20141020145359.565fe5e6@voldemort.scrye.com>
 <20141021151225.5df96645@voldemort.scrye.com>
 <CA+5PVA7Ro_ejBUqsZ9StWVeu59==fGnj6e4Gx8zM4_3+Lq5s4A@mail.gmail.com>
 <CAHA+R7OUHy8XFPoip5gPvr1uqwkxgKxoSMf_pSgB1aFx=XCs8g@mail.gmail.com>
 <8738aghtyj.fsf@x220.int.ebiederm.org>
 <20141022181135.GH4977@linux.vnet.ibm.com>
 <87d29kezby.fsf@x220.int.ebiederm.org>
 <20141022185511.GI4977@linux.vnet.ibm.com>
 <CA+5PVA56ajrBQ-C9orSb9-_qhMKe994QL2x0FcKbe6BYmaWFBw@mail.gmail.com>
 <20141022224032.GA1240@declera.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Yanko Kaneti <yaneti@declera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141022224032.GA1240@declera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 23, 2014 at 01:40:32AM +0300, Yanko Kaneti wrote:
> On Wed-10/22/14-2014 15:33, Josh Boyer wrote:
> > On Wed, Oct 22, 2014 at 2:55 PM, Paul E. McKenney
> > <paulmck@linux.vnet.ibm.com> wrote:

[ . . . ]

> > > Don't get me wrong -- the fact that this kthread appears to have
> > > blocked within rcu_barrier() for 120 seconds means that something is
> > > most definitely wrong here.  I am surprised that there are no RCU CPU
> > > stall warnings, but perhaps the blockage is in the callback execution
> > > rather than grace-period completion.  Or something is preventing this
> > > kthread from starting up after the wake-up callback executes.  Or...
> > >
> > > Is this thing reproducible?
> > 
> > I've added Yanko on CC, who reported the backtrace above and can
> > recreate it reliably.  Apparently reverting the RCU merge commit
> > (d6dd50e) and rebuilding the latest after that does not show the
> > issue.  I'll let Yanko explain more and answer any questions you have.
> 
> - It is reproducible
> - I've done another build here to double check and its definitely the rcu merge
>   that's causing it. 
> 
> Don't think I'll be able to dig deeper, but I can do testing if needed.

Please!  Does the following patch help?

							Thanx, Paul

------------------------------------------------------------------------

rcu: More on deadlock between CPU hotplug and expedited grace periods

Commit dd56af42bd82 (rcu: Eliminate deadlock between CPU hotplug and
expedited grace periods) was incomplete.  Although it did eliminate
deadlocks involving synchronize_sched_expedited()'s acquisition of
cpu_hotplug.lock via get_online_cpus(), it did nothing about the similar
deadlock involving acquisition of this same lock via put_online_cpus().
This deadlock became apparent with testing involving hibernation.

This commit therefore changes put_online_cpus() acquisition of this lock
to be conditional, and increments a new cpu_hotplug.puts_pending field
in case of acquisition failure.  Then cpu_hotplug_begin() checks for this
new field being non-zero, and applies any changes to cpu_hotplug.refcount.

Reported-by: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Tested-by: Jiri Kosina <jkosina@suse.cz>

diff --git a/kernel/cpu.c b/kernel/cpu.c
index 356450f09c1f..90a3d017b90c 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -64,6 +64,8 @@ static struct {
 	 * an ongoing cpu hotplug operation.
 	 */
 	int refcount;
+	/* And allows lockless put_online_cpus(). */
+	atomic_t puts_pending;
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 	struct lockdep_map dep_map;
@@ -113,7 +115,11 @@ void put_online_cpus(void)
 {
 	if (cpu_hotplug.active_writer == current)
 		return;
-	mutex_lock(&cpu_hotplug.lock);
+	if (!mutex_trylock(&cpu_hotplug.lock)) {
+		atomic_inc(&cpu_hotplug.puts_pending);
+		cpuhp_lock_release();
+		return;
+	}
 
 	if (WARN_ON(!cpu_hotplug.refcount))
 		cpu_hotplug.refcount++; /* try to fix things up */
@@ -155,6 +161,12 @@ void cpu_hotplug_begin(void)
 	cpuhp_lock_acquire();
 	for (;;) {
 		mutex_lock(&cpu_hotplug.lock);
+		if (atomic_read(&cpu_hotplug.puts_pending)) {
+			int delta;
+
+			delta = atomic_xchg(&cpu_hotplug.puts_pending, 0);
+			cpu_hotplug.refcount -= delta;
+		}
 		if (likely(!cpu_hotplug.refcount))
 			break;
 		__set_current_state(TASK_UNINTERRUPTIBLE);
