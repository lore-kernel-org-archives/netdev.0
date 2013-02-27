From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
	Per-CPU Reader-Writer Locks
Date: Wed, 27 Feb 2013 20:25:51 +0100
Message-ID: <20130227192551.GA8333@redhat.com>
References: <51226F91.7000108@linux.vnet.ibm.com> <CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com> <512BBAD8.8010006@linux.vnet.ibm.com> <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com> <512C7A38.8060906@linux.vnet.ibm.com> <CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com> <512CC509.1050000@linux.vnet.ibm.com> <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com> <512D0D67.9010609@linux.vnet.ibm.com> <CANN689FuuEb9wpV43DkTtgv6syvBYL-LQxByWznyAq8dkrhzBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	Lai Jiangshan <eag0628@gmail.com>, linux-doc@vger.kernel.org,
	peterz@infradead.org, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, namhyung@kernel.org,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	vincent.guittot@linaro.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	sbw@mit.edu, tj@kernel.org, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org
To: Michel Lespinasse <walken@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANN689FuuEb9wpV43DkTtgv6syvBYL-LQxByWznyAq8dkrhzBw@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/27, Michel Lespinasse wrote:
>
> +void lg_rwlock_local_read_lock(struct lgrwlock *lgrw)
> +{
> +       preempt_disable();
> +
> +       if (__this_cpu_read(*lgrw->local_refcnt) ||
> +           arch_spin_trylock(this_cpu_ptr(lgrw->lglock->lock))) {
> +               __this_cpu_inc(*lgrw->local_refcnt);

Please look at __this_cpu_generic_to_op(). You need this_cpu_inc()
to avoid the race with irs. The same for _read_unlock.

But otherwise I agree, looks like a clever and working idea to me.
And simple!

> There is an interesting case where lg_rwlock_local_read_lock could be
> interrupted after getting the local lglock but before incrementing
> local_refcnt to 1; if that happens any nested readers within that
> interrupt will have to take the global rwlock read side. I think this
> is perfectly acceptable

Agreed.

Or interrupt can do spin_trylock(percpu-lock) after we take the global
->fallback_rwlock (if we race with write_lock + write_unlock), but I do
not see any possible deadlock in this case.

Oleg.

