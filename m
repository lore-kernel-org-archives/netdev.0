From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH v5 01/45] percpu_rwlock: Introduce the global
 reader-writer lock backend
Date: Wed, 23 Jan 2013 20:14:56 -0800
Message-ID: <CANN689HOmiO-5714UiyuOcjrRYW2DkR4cPLgt96f5YeB9Ws3RQ@mail.gmail.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
	<20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com>
	<1358883152.21576.55.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	rjw@sisk.pl, sbw@mit.edu, fweisbec@gmail.com,
	linux@arm.linux.org.uk, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:43650 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104Ab3AXEO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 23:14:57 -0500
Received: by mail-qa0-f52.google.com with SMTP id d13so89755qak.11
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 20:14:57 -0800 (PST)
In-Reply-To: <1358883152.21576.55.camel@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2013 at 11:32 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Tue, 2013-01-22 at 13:03 +0530, Srivatsa S. Bhat wrote:
>> A straight-forward (and obvious) algorithm to implement Per-CPU Reader-Writer
>> locks can also lead to too many deadlock possibilities which can make it very
>> hard/impossible to use. This is explained in the example below, which helps
>> justify the need for a different algorithm to implement flexible Per-CPU
>> Reader-Writer locks.
>>
>> We can use global rwlocks as shown below safely, without fear of deadlocks:
>>
>> Readers:
>>
>>          CPU 0                                CPU 1
>>          ------                               ------
>>
>> 1.    spin_lock(&random_lock);             read_lock(&my_rwlock);
>>
>>
>> 2.    read_lock(&my_rwlock);               spin_lock(&random_lock);
>>
>>
>> Writer:
>>
>>          CPU 2:
>>          ------
>>
>>        write_lock(&my_rwlock);
>>
>
> I thought global locks are now fair. That is, a reader will block if a
> writer is waiting. Hence, the above should deadlock on the current
> rwlock_t types.

I believe you are mistaken here. struct rw_semaphore is fair (and
blocking), but rwlock_t is unfair. The reason we can't easily make
rwlock_t fair is because tasklist_lock currently depends on the
rwlock_t unfairness - tasklist_lock readers typically don't disable
local interrupts, and tasklist_lock may be acquired again from within
an interrupt, which would deadlock if rwlock_t was fair and a writer
was queued by the time the interrupt is processed.

> We need to fix those locations (or better yet, remove all rwlocks ;-)

tasklist_lock is the main remaining user. I'm not sure about removing
rwlock_t, but I would like to at least make it fair somehow :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
