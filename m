From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Fri, 24 Oct 2014 17:20:48 -0700
Message-ID: <10136.1414196448@famine>
References: <20141024162943.GA16621@declera.com> <20141024165454.GS4977@linux.vnet.ibm.com> <20141024170931.GA21849@declera.com> <20141024172009.GV4977@linux.vnet.ibm.com> <20141024173526.GA26058@declera.com> <20141024183226.GW4977@linux.vnet.ibm.com> <20141024212557.GA15537@declera.com> <20141024214927.GA4977@linux.vnet.ibm.com> <8915.1414190047@famine> <20141024225931.GC4977@linux.vnet.ibm.com> <20141024230524.GA16023@linux.vnet.ibm.com>
Cc: Yanko Kaneti <yaneti@declera.com>,
	Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	mroos@linux.ee, tj@kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20141024230524.GA16023@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

>On Fri, Oct 24, 2014 at 03:59:31PM -0700, Paul E. McKenney wrote:
[...]
>> Hmmm...  It sure looks like we have some callbacks stuck here.  I clearly
>> need to take a hard look at the sleep/wakeup code.
>> 
>> Thank you for running this!!!
>
>Could you please try the following patch?  If no joy, could you please
>add rcu:rcu_nocb_wake to the list of ftrace events?

	I tried the patch, it did not change the behavior.

	I enabled the rcu:rcu_barrier and rcu:rcu_nocb_wake tracepoints
and ran it again (with this patch and the first patch from earlier
today); the trace output is a bit on the large side so I put it and the
dmesg log at:

http://people.canonical.com/~jvosburgh/nocb-wake-dmesg.txt

http://people.canonical.com/~jvosburgh/nocb-wake-trace.txt

	-J


>							Thanx, Paul
>
>------------------------------------------------------------------------
>
>rcu: Kick rcuo kthreads after their CPU goes offline
>
>If a no-CBs CPU were to post an RCU callback with interrupts disabled
>after it entered the idle loop for the last time, there might be no
>deferred wakeup for the corresponding rcuo kthreads.  This commit
>therefore adds a set of calls to do_nocb_deferred_wakeup() after the
>CPU has gone completely offline.
>
>Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>
>diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
>index 84b41b3c6ebd..f6880052b917 100644
>--- a/kernel/rcu/tree.c
>+++ b/kernel/rcu/tree.c
>@@ -3493,8 +3493,10 @@ static int rcu_cpu_notify(struct notifier_block *self,
> 	case CPU_DEAD_FROZEN:
> 	case CPU_UP_CANCELED:
> 	case CPU_UP_CANCELED_FROZEN:
>-		for_each_rcu_flavor(rsp)
>+		for_each_rcu_flavor(rsp) {
> 			rcu_cleanup_dead_cpu(cpu, rsp);
>+			do_nocb_deferred_wakeup(per_cpu_ptr(rsp->rda, cpu));
>+		}
> 		break;
> 	default:
> 		break;
>

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
