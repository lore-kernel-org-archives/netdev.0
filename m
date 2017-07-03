From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 08/26] locking: Remove spin_unlock_wait() generic
 definitions
Date: Mon, 3 Jul 2017 14:10:35 -0700
Message-ID: <20170703211035.GH2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-8-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170630091928.GC9726@arm.com>
 <20170630123815.GT2393@linux.vnet.ibm.com>
 <20170630131339.GA14118@arm.com>
 <20170630221840.GI2393@linux.vnet.ibm.com>
 <20170703131514.GE1573@arm.com>
 <20170703161851.GY2393@linux.vnet.ibm.com>
 <CA+55aFzA+dk8P-wWFX_rYE09A-3uCL8_7ZNG4jC1+c0x4COQkQ@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Will Deacon <will.deacon@arm.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Manfred Spraul <manfred@colorfullife.com>,
        Tejun Heo <tj@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Alan Stern <stern@rowland.harvard.edu>,
        Andrea Parri <parri.andrea@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:35293 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752378AbdGCVKm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 17:10:42 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v63L98fU065092
        for <netdev@vger.kernel.org>; Mon, 3 Jul 2017 17:10:41 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2bfc03tkp6-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 17:10:41 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Mon, 3 Jul 2017 17:10:40 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFzA+dk8P-wWFX_rYE09A-3uCL8_7ZNG4jC1+c0x4COQkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 03, 2017 at 09:40:22AM -0700, Linus Torvalds wrote:
> On Mon, Jul 3, 2017 at 9:18 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > Agreed, and my next step is to look at spin_lock() followed by
> > spin_is_locked(), not necessarily the same lock.
> 
> Hmm. Most (all?) "spin_is_locked()" really should be about the same
> thread that took the lock (ie it's about asserts and lock debugging).

Good to know, that does make things easier.  ;-)

I am not certain that it is feasible to automatically recognize
non-assert/non-debugging use cases of spin_is_locked(), but there is
aways manual inspection.

> The optimistic ABBA avoidance pattern for spinlocks *should* be
> 
>     spin_lock(inner)
>     ...
>     if (!try_lock(outer)) {
>            spin_unlock(inner);
>            .. do them in the right order ..
> 
> so I don't think spin_is_locked() should have any memory barriers.
> 
> In fact, the core function for spin_is_locked() is arguably
> arch_spin_value_unlocked() which doesn't even do the access itself.

OK, so we should rework any cases where people are relying on acquisition
of one spin_lock() being ordered with a later spin_is_locked() on some
other lock by that same thread.

							Thanx, Paul
