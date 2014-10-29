From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] netdev: Fix sleeping inside wait event
Date: Wed, 29 Oct 2014 18:31:10 +0100
Message-ID: <20141029173110.GE15602@worktop.programming.kicks-ass.net>
References: <20141028142541.GA19097@wfg-t540p.sh.intel.com>
 <20141029161657.GF3337@twins.programming.kicks-ass.net>
 <CAM_iQpXTyBT_4TrnYAoAuAE_jMto=2B=cutFggpHRMhvSrG7qg@mail.gmail.com>
 <20141029171345.GO12706@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fengguang Wu <fengguang.wu@intel.com>, LKP <lkp@01.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"oleg@redhat.com" <oleg@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141029171345.GO12706@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2014 at 06:13:45PM +0100, Peter Zijlstra wrote:
> On Wed, Oct 29, 2014 at 09:29:55AM -0700, Cong Wang wrote:
> > While you are on it, please fix rtnl_lock_unregistering_all() too?
> 
> Ah, that's hidden someplace else, sure I can do that. Thanks for
> pointing it out.

Here goes..

---
Subject: netdev: Fix sleeping inside wait event
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed Oct 29 17:04:56 CET 2014

rtnl_lock_unregistering*() take rtnl_lock() -- a mutex -- inside a
wait loop. The wait loop relies on current->state to function, but so
does mutex_lock(), nesting them makes for the inner to destroy the
outer state.

Fix this using the new wait_woken() bits.

Cc: David Miller <davem@davemloft.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Eric Biederman <ebiederm@xmission.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 net/core/dev.c       |   10 +++++-----
 net/core/rtnetlink.c |   10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7196,11 +7196,10 @@ static void __net_exit rtnl_lock_unregis
 	 */
 	struct net *net;
 	bool unregistering;
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
+	add_wait_queue(&netdev_unregistering_wq, &wait);
 	for (;;) {
-		prepare_to_wait(&netdev_unregistering_wq, &wait,
-				TASK_UNINTERRUPTIBLE);
 		unregistering = false;
 		rtnl_lock();
 		list_for_each_entry(net, net_list, exit_list) {
@@ -7212,9 +7211,10 @@ static void __net_exit rtnl_lock_unregis
 		if (!unregistering)
 			break;
 		__rtnl_unlock();
-		schedule();
+
+		wait_woken(&wait, TASK_UNINTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
 	}
-	finish_wait(&netdev_unregistering_wq, &wait);
+	remove_wait_queue(&netdev_unregistering_wq, &wait);
 }
 
 static void __net_exit default_device_exit_batch(struct list_head *net_list)
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -365,11 +365,10 @@ static void rtnl_lock_unregistering_all(
 {
 	struct net *net;
 	bool unregistering;
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
+	add_wait_queue(&netdev_unregistering_wq, &wait);
 	for (;;) {
-		prepare_to_wait(&netdev_unregistering_wq, &wait,
-				TASK_UNINTERRUPTIBLE);
 		unregistering = false;
 		rtnl_lock();
 		for_each_net(net) {
@@ -381,9 +380,10 @@ static void rtnl_lock_unregistering_all(
 		if (!unregistering)
 			break;
 		__rtnl_unlock();
-		schedule();
+
+		wait_woken(&wait, TASK_UNINTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
 	}
-	finish_wait(&netdev_unregistering_wq, &wait);
+	remove_wait_queue(&netdev_unregistering_wq, &wait);
 }
 
 /**
