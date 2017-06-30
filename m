From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 02/26] task_work: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Fri, 30 Jun 2017 05:50:20 -0700
Message-ID: <20170630125020.GU2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-2-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170630110445.GA5123@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, akpm@linux-foundation.org,
        mingo@redhat.com, dave@stgolabs.net, manfred@colorfullife.com,
        tj@kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org,
        will.deacon@arm.com, peterz@infradead.org,
        stern@rowland.harvard.edu, parri.andrea@gmail.com,
        torvalds@linux-foundation.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55878 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751545AbdF3Mu1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 08:50:27 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5UCnmkC089002
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 08:50:27 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2bd6te4nd4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 08:50:27 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Fri, 30 Jun 2017 08:50:26 -0400
Content-Disposition: inline
In-Reply-To: <20170630110445.GA5123@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 30, 2017 at 01:04:45PM +0200, Oleg Nesterov wrote:
> On 06/29, Paul E. McKenney wrote:
> >
> > --- a/kernel/task_work.c
> > +++ b/kernel/task_work.c
> > @@ -109,7 +109,8 @@ void task_work_run(void)
> >  		 * the first entry == work, cmpxchg(task_works) should
> >  		 * fail, but it can play with *work and other entries.
> >  		 */
> > -		raw_spin_unlock_wait(&task->pi_lock);
> > +		raw_spin_lock(&task->pi_lock);
> > +		raw_spin_unlock(&task->pi_lock);
> 
> Well, bit the you need spin_lock_irq(). And this is one of the reasons
> why I personally think unlock_wait have some sense...

Good catch, and I clearly need to double-check the other commits for
any need to disable interrupts.  Anyway, like this, with the addition
of a flags variable, correct?

> > +		raw_spin_lock_irq(&task->pi_lock);
> > +		raw_spin_unlock_irq(&task->pi_lock);

I agree that the spin_unlock_wait() implementations would avoid the
deadlock with an acquisition from an interrupt handler, while also
avoiding the need to momentarily disable interrupts.  The ->pi_lock is
a per-task lock, so I am assuming (perhaps naively) that contention is
not a problem.  So is the overhead of interrupt disabling likely to be
noticeable here?

							Thanx, Paul
