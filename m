From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC 03/26] sched: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Fri, 30 Jun 2017 12:31:50 +0200
Message-ID: <CAK8P3a1o3V82Ed2CVxL-aaBs+m93xZAUWMa+bKg+zBKm_RMT_w@mail.gmail.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com> <1498780894-8253-3-git-send-email-paulmck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netfilter-devel@vger.kernel.org,
        Networking <netdev@vger.kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, dave@stgolabs.net,
        manfred@colorfullife.com, Tejun Heo <tj@kernel.org>,
        linux-arch <linux-arch@vger.kernel.org>,
        Will Deacon <will.deacon@arm.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Alan Stern <stern@rowland.harvard.edu>, parri.andrea@gmail.com,
        Linus Torvalds <torvalds@linux-foundation.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498780894-8253-3-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2017 at 2:01 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> There is no agreed-upon definition of spin_unlock_wait()'s semantics,
> and it appears that all callers could do just as well with a lock/unlock
> pair.  This commit therefore replaces the spin_unlock_wait() call in
> do_task_dead() with spin_lock() followed immediately by spin_unlock().
> This should be safe from a performance perspective because the lock is
> this tasks ->pi_lock, and this is called only after the task exits.
>
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index e91138fcde86..6dea3d9728c8 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -3461,7 +3461,8 @@ void __noreturn do_task_dead(void)
>          * is held by try_to_wake_up()
>          */
>         smp_mb();
> -       raw_spin_unlock_wait(&current->pi_lock);
> +       raw_spin_lock(&current->pi_lock);
> +       raw_spin_unlock(&current->pi_lock);

Does the raw_spin_lock()/raw_spin_unlock() imply an smp_mb() or stronger?
Maybe it would be clearer to remove the extra barrier if so.

     Arnd
