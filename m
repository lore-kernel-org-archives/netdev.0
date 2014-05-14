From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 01/15] net: qdisc: use rcu prefix and silence sparse
 warnings
Date: Wed, 14 May 2014 12:39:12 -0700
Message-ID: <5373C660.7030301@gmail.com>
References: <20140430163250.9021.21199.stgit@nitbit.x32> <20140430163504.9021.12828.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, jhs@mojatatu.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: eric.dumazet@gmail.com, paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:61510 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaENTj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:39:26 -0400
Received: by mail-ob0-f181.google.com with SMTP id wm4so38634obc.12
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 12:39:26 -0700 (PDT)
In-Reply-To: <20140430163504.9021.12828.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2014 09:35 AM, John Fastabend wrote:
> Add __rcu notation to qdisc handling by doing this we can make
> smatch output more legible. And anyways some of the cases should
> be using rcu_dereference() see qdisc_all_tx_empty(),
> qdisc_tx_chainging(), and so on.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Now I'm trying to resolve the lingering sparse errors/warnings and I
have one that I'm not sure about. Maybe someone has some insight,

net/sched/sch_generic.c:694:9: error: bad constant expression
net/sched/sch_generic.c:694:9: error: cannot size expression
net/sched/sch_generic.c:751:9: error: bad constant expression
net/sched/sch_generic.c:751:9: error: cannot size expression
net/sched/sch_generic.c:800:17: error: bad constant expression
net/sched/sch_generic.c:800:17: error: cannot size expression
net/sched/sch_generic.c:886:9: error: bad constant expression
net/sched/sch_generic.c:886:9: error: cannot size expression
net/sched/sch_generic.c:908:17: error: bad constant expression
net/sched/sch_generic.c:908:17: error: cannot size expression

Here are (what I believe are) the relevant changes to trigger it,

>   include/linux/netdevice.h |   29 ++++-------------------------
>   include/net/sch_generic.h |   29 +++++++++++++++++++++++------
>   net/core/dev.c            |   45 +++++++++++++++++++++++++++++++++++++++++++--
>   net/sched/sch_generic.c   |    4 ++--
>   net/sched/sch_mqprio.c    |    6 ++++--
>   net/sched/sch_teql.c      |    9 +++++----
>   6 files changed, 81 insertions(+), 41 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a803d79..4826988 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -546,7 +546,7 @@ struct netdev_queue {
>    * read mostly part
>    */
>   	struct net_device	*dev;
> -	struct Qdisc		*qdisc;
> +	struct Qdisc __rcu	*qdisc;

Add __rcu here,

>   	struct Qdisc		*qdisc_sleeping;
>   #ifdef CONFIG_SYSFS
>   	struct kobject		kobj;

[...]

> +++ b/net/sched/sch_generic.c

[...]

> @@ -871,7 +871,7 @@ static void dev_init_scheduler_queue(struct net_device *dev,
>   {
>   	struct Qdisc *qdisc = _qdisc;
>
> -	dev_queue->qdisc = qdisc;
> +	rcu_assign_pointer(dev_queue->qdisc, qdisc);
>   	dev_queue->qdisc_sleeping = qdisc;
>   }

Then rcu_assign_pointer() operations throw the "bad constant expression"
and "cannot size expression" errors. The line numbers are a bit off from
the errors above due to some other improvements/fixes but this is line
886 from above sparse output.

I've done similar types of transformations before without sparse errors
so I thought I might see what changed. After doing a revert of

"rcu: Define rcu_assign_pointer() in terms of smp_store_release()"
commit 88c1863066ccfa456797e12c5d8b4631aa1ad0d0

Sparse no longer throws an error. Here is the diff of that commit for
reference

> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index 00a7fd6..4550f22 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -44,7 +44,6 @@
>  #include <linux/debugobjects.h>
>  #include <linux/bug.h>
>  #include <linux/compiler.h>
> -#include <asm/barrier.h>
>
>  extern int rcu_expedited; /* for sysctl */
>  #ifdef CONFIG_RCU_TORTURE_TEST
> @@ -582,7 +581,12 @@ static inline void rcu_preempt_sleep_check(void)
>   * please be careful when making changes to rcu_assign_pointer() and the
>   * other macros that it invokes.
>   */
> -#define rcu_assign_pointer(p, v) smp_store_release(&p, RCU_INITIALIZER(v))
> +#define rcu_assign_pointer(p, v) \
> +       do { \
> +               smp_wmb(); \
> +               ACCESS_ONCE(p) = RCU_INITIALIZER(v); \
> +       } while (0)
> +
>
>  /**
>   * rcu_access_pointer() - fetch RCU pointer with no dereferencing

At the moment I'm not seeing what changed that would cause the error.
Any ideas what I got wrong here?

Thanks!
John

-- 
John Fastabend         Intel Corporation
