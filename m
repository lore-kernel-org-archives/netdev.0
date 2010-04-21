From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Wed, 21 Apr 2010 14:48:48 -0700
Message-ID: <20100421214848.GQ2563@linux.vnet.ibm.com>
References: <1271701612.2972.5.camel@dhcp231-113.rdu.redhat.com>
 <20100419230136.GA16856@linux.vnet.ibm.com>
 <1271726729.2972.13.camel@dhcp231-113.rdu.redhat.com>
 <20100420030452.GB2905@linux.vnet.ibm.com>
 <4BCD646B.1080206@cn.fujitsu.com>
 <1271766716.2972.16.camel@dhcp231-113.rdu.redhat.com>
 <j2ya44ae5cd1004200545q6be4ec82o18ae99d93e8c29c7@mail.gmail.com>
 <20100420135227.GC2628@linux.vnet.ibm.com>
 <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
 <20100421213543.GO2563@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, vgoyal@redhat.com,
	nauman@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Miles Lane <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:34205 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755393Ab0DUVsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 17:48:51 -0400
Content-Disposition: inline
In-Reply-To: <20100421213543.GO2563@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 02:35:43PM -0700, Paul E. McKenney wrote:
> On Tue, Apr 20, 2010 at 11:38:28AM -0400, Miles Lane wrote:
> > Excellent.  Here are the results on my machine.  .config appended.
> 
> First, thank you very much for testing this, Miles!

And as Tetsuo Handa pointed out privately, my patch was way broken.

Here is an updated version.

							Thanx, Paul

commit b15e561ed91b7a366c3cc635026f3b9ce6483070
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Wed Apr 21 14:04:56 2010 -0700

    sched: protect __sched_setscheduler() access to cgroups
    
    A given task's cgroups structures must remain while that task is running
    due to reference counting, so this is presumably a false positive.
    Updated to reflect feedback from Tetsuo Handa.
    
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/sched.c b/kernel/sched.c
index 14c44ec..f425a2b 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4575,9 +4575,13 @@ recheck:
 		 * Do not allow realtime tasks into groups that have no runtime
 		 * assigned.
 		 */
+		rcu_read_lock();
 		if (rt_bandwidth_enabled() && rt_policy(policy) &&
-				task_group(p)->rt_bandwidth.rt_runtime == 0)
+				task_group(p)->rt_bandwidth.rt_runtime == 0) {
+			rcu_read_unlock();
 			return -EPERM;
+		}
+		rcu_read_unlock();
 #endif
 
 		retval = security_task_setscheduler(p, policy, param);
