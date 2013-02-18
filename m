From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH v6 07/46] percpu_rwlock: Allow writers to be readers, and
 add lockdep annotations
Date: Mon, 18 Feb 2013 23:51:41 +0800
Message-ID: <CANN689Ec4g7jMapv8ChAEom+gEDQ8RDVLa07CKwJ==YO+MUUrA@mail.gmail.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
	<20130218123913.26245.7713.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	vincent.guittot@linaro.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130218123913.26245.7713.stgit@srivatsabhat.in.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 18, 2013 at 8:39 PM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
> @@ -200,6 +217,16 @@ void percpu_write_lock_irqsave(struct percpu_rwlock *pcpu_rwlock,
>
>         smp_mb(); /* Complete the wait-for-readers, before taking the lock */
>         write_lock_irqsave(&pcpu_rwlock->global_rwlock, *flags);
> +
> +       /*
> +        * It is desirable to allow the writer to acquire the percpu-rwlock
> +        * for read (if necessary), without deadlocking or getting complaints
> +        * from lockdep. To achieve that, just increment the reader_refcnt of
> +        * this CPU - that way, any attempt by the writer to acquire the
> +        * percpu-rwlock for read, will get treated as a case of nested percpu
> +        * reader, which is safe, from a locking perspective.
> +        */
> +       this_cpu_inc(pcpu_rwlock->rw_state->reader_refcnt);

I find this quite disgusting, but once again this may be because I
don't like unfair recursive rwlocks.

In my opinion, the alternative of explicitly not taking the read lock
when one already has the write lock sounds *much* nicer.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
