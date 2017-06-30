From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 03/26] sched: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Fri, 30 Jun 2017 05:35:29 -0700
Message-ID: <20170630123529.GS2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-3-git-send-email-paulmck@linux.vnet.ibm.com>
 <CAK8P3a1o3V82Ed2CVxL-aaBs+m93xZAUWMa+bKg+zBKm_RMT_w@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:33829 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751689AbdF3Mfh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 08:35:37 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5UCZ3mL050161
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 08:35:36 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2bd6te43b8-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 08:35:36 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Fri, 30 Jun 2017 08:35:34 -0400
Content-Disposition: inline
In-Reply-To: <CAK8P3a1o3V82Ed2CVxL-aaBs+m93xZAUWMa+bKg+zBKm_RMT_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 30, 2017 at 12:31:50PM +0200, Arnd Bergmann wrote:
> On Fri, Jun 30, 2017 at 2:01 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > There is no agreed-upon definition of spin_unlock_wait()'s semantics,
> > and it appears that all callers could do just as well with a lock/unlock
> > pair.  This commit therefore replaces the spin_unlock_wait() call in
> > do_task_dead() with spin_lock() followed immediately by spin_unlock().
> > This should be safe from a performance perspective because the lock is
> > this tasks ->pi_lock, and this is called only after the task exits.
> >
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index e91138fcde86..6dea3d9728c8 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -3461,7 +3461,8 @@ void __noreturn do_task_dead(void)
> >          * is held by try_to_wake_up()
> >          */
> >         smp_mb();
> > -       raw_spin_unlock_wait(&current->pi_lock);
> > +       raw_spin_lock(&current->pi_lock);
> > +       raw_spin_unlock(&current->pi_lock);
> 
> Does the raw_spin_lock()/raw_spin_unlock() imply an smp_mb() or stronger?
> Maybe it would be clearer to remove the extra barrier if so.

No, it does not in general, but it does on most architectures, and
there are ways to allow those architectures to gain the benefit of their
stronger locks.  For example, would this work?  

> >          * is held by try_to_wake_up()
> >          */
> > -       smp_mb();
> > -       raw_spin_unlock_wait(&current->pi_lock);
> > +       smp_mb__before_spinlock();
> > +       raw_spin_lock(&current->pi_lock);
> > +       raw_spin_unlock(&current->pi_lock);

							Thanx, Paul
