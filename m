From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.35-rc2-git1 - lib/idr.c:605 invoked
 rcu_dereference_check() without protection!
Date: Mon, 7 Jun 2010 17:12:34 -0700
Message-ID: <20100608001234.GE2387@linux.vnet.ibm.com>
References: <AANLkTim06fRB-Kvm12v2umq8MxRxbcl3gdbNsiRTDmia@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivek Goyal <vgoyal@redhat.com>, Eric Paris <eparis@redhat.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <axboe@kernel.dk>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTim06fRB-Kvm12v2umq8MxRxbcl3gdbNsiRTDmia@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 07, 2010 at 02:23:17PM -0400, Miles Lane wrote:
> [    2.677955] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    2.679089] ---------------------------------------------------
> [    2.680276] lib/idr.c:605 invoked rcu_dereference_check() without protection!
> [    2.681499]
> [    2.681500] other info that might help us debug this:
> [    2.681501]
> [    2.685509]
> [    2.685510] rcu_scheduler_active = 1, debug_locks = 1
> [    2.688221] 1 lock held by swapper/1:
> [    2.689587]  #0:  (mtd_table_mutex){+.+...}, at:
> [<ffffffff812bea45>] register_mtd_user+0x1a/0x69
> [    2.691096]
> [    2.691098] stack backtrace:
> [    2.694059] Pid: 1, comm: swapper Not tainted 2.6.35-rc2-git1 #8
> [    2.695601] Call Trace:
> [    2.697243]  [<ffffffff81064e9c>] lockdep_rcu_dereference+0x9d/0xa5
> [    2.698868]  [<ffffffff811b9c86>] idr_get_next+0x60/0x124
> [    2.700556]  [<ffffffff812be779>] __mtd_next_device+0x1b/0x1d
> [    2.702238]  [<ffffffff812bea7c>] register_mtd_user+0x51/0x69
> [    2.703964]  [<ffffffff816cca45>] init_mtdchar+0xb3/0xd3
> [    2.705686]  [<ffffffff816cc992>] ? init_mtdchar+0x0/0xd3
> [    2.707470]  [<ffffffff810001ef>] do_one_initcall+0x59/0x14e
> [    2.709255]  [<ffffffff816a768a>] kernel_init+0x144/0x1ce
> [    2.711082]  [<ffffffff81003054>] kernel_thread_helper+0x4/0x10
> [    2.712862]  [<ffffffff813ca480>] ? restore_args+0x0/0x30
> [    2.714647]  [<ffffffff816a7546>] ? kernel_init+0x0/0x1ce
> [    2.716415]  [<ffffffff81003050>] ? kernel_thread_helper+0x0/0x10

This looks like a new one!  Does the following patch take care of it?

							Thanx, Paul

------------------------------------------------------------------------

commit 2d54a6c31b72c902b09d365e9c66205a5c07e549
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Mon Jun 7 17:09:45 2010 -0700

    idr: fix RCU lockdep splat in idr_get_next()
    
    Convert to rcu_dereference_raw() given that many callers may have many
    different locking models.
    
    Located-by: Miles Lane <miles.lane@gmail.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/lib/idr.c b/lib/idr.c
index 2eb1dca..f099f25 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -599,7 +599,7 @@ void *idr_get_next(struct idr *idp, int *nextidp)
 	/* find first ent */
 	n = idp->layers * IDR_BITS;
 	max = 1 << n;
-	p = rcu_dereference(idp->top);
+	p = rcu_dereference_raw(idp->top);
 	if (!p)
 		return NULL;
 
@@ -607,7 +607,7 @@ void *idr_get_next(struct idr *idp, int *nextidp)
 		while (n > 0 && p) {
 			n -= IDR_BITS;
 			*paa++ = p;
-			p = rcu_dereference(p->ary[(id >> n) & IDR_MASK]);
+			p = rcu_dereference_raw(p->ary[(id >> n) & IDR_MASK]);
 		}
 
 		if (p) {
