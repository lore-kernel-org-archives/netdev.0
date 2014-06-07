From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: net: netlink executing RO memory
Date: Sat, 7 Jun 2014 22:40:43 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1406072239580.3830@nanos>
References: <5390D152.30702@oracle.com> <53915571.7050801@oracle.com> <53932AA2.4050204@oracle.com> <alpine.DEB.2.10.1406072139410.3830@nanos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1406072139410.3830@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 7 Jun 2014, Thomas Gleixner wrote:
> On Sat, 7 Jun 2014, Sasha Levin wrote:
> So one thing which might give us at least some data is the debug patch
> below. With CONFIG_STACKTRACE enabled and 
> 
> # echo 1 >/sys/kernel/debug/tracing/options/stacktrace
> 
> we should get a recording of rcu_free() calls along with the
> stacktrace for each. So we should be able to see which code path
> actually queued the thing. Maybe that's enough of an hint, but at
> least it gives us an idea which code path to instrument further.

This one is better..

Thanks,

	tglx
---------------------

diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
index 962d1d5..7241235 100644
--- a/kernel/rcu/tree_plugin.h
+++ b/kernel/rcu/tree_plugin.h
@@ -698,6 +698,7 @@ EXPORT_SYMBOL_GPL(call_rcu);
 void kfree_call_rcu(struct rcu_head *head,
 		    void (*func)(struct rcu_head *rcu))
 {
+	trace_printk("head: %p func: %pS\n", head, func);
 	__call_rcu(head, func, &rcu_preempt_state, -1, 1);
 }
 EXPORT_SYMBOL_GPL(kfree_call_rcu);
@@ -1091,6 +1092,7 @@ static void rcu_preempt_check_callbacks(int cpu)
 void kfree_call_rcu(struct rcu_head *head,
 		    void (*func)(struct rcu_head *rcu))
 {
+	trace_printk("head: %p func: %pS\n", head, func);
 	__call_rcu(head, func, &rcu_sched_state, -1, 1);
 }
 EXPORT_SYMBOL_GPL(kfree_call_rcu);
diff --git a/lib/debugobjects.c b/lib/debugobjects.c
index e0731c3..fd5cafd 100644
--- a/lib/debugobjects.c
+++ b/lib/debugobjects.c
@@ -693,6 +693,9 @@ repeat:
 
 			switch (obj->state) {
 			case ODEBUG_STATE_ACTIVE:
+				trace_printk("free %p obj %p\n", address,
+					     obj->object);
+				tracing_off();
 				debug_print_object(obj, "free");
 				descr = obj->descr;
 				state = obj->state;
 
