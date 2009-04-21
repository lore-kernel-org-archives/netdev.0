From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 09:13:52 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>
References: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net> <20090416234955.GL6924@linux.vnet.ibm.com> <20090417012812.GA25534@linux.vnet.ibm.com> <20090418094001.GA2369@ioremap.net>
 <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com>
 <20090420160121.268a8226@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090420160121.268a8226@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, so others already pointed out how dangerous/buggy this looks, but I'd 
like to strengthen that a bit more:

On Mon, 20 Apr 2009, Stephen Hemminger wrote:
> +
> +/**
> + * xt_table_info_rdlock_bh - recursive read lock for xt table info
> + *
> + * Table processing calls this to hold off any changes to table
> + * (on current CPU). Always leaves with bottom half disabled.
> + * If called recursively, then assumes bh/preempt already disabled.
> + */
> +void xt_info_rdlock_bh(void)
> +{
> +	struct xt_info_lock *lock;
> +
> +	preempt_disable();
> +	lock = &__get_cpu_var(xt_info_locks);
> +	if (likely(++lock->depth == 0))
> +		spin_lock_bh(&lock->lock);
> +	preempt_enable_no_resched();
> +}
> +EXPORT_SYMBOL_GPL(xt_info_rdlock_bh);

This function is FUCKED UP.

It's total crap for several reasons"

 - the already-mentioned race with bottom half locking.

   If bottom halfs aren't already disabled, then if a bottom half comes in 
   after the "++lock->depth" and before the spin_lock_bh(), then you will 
   have no locking AT ALL for the processing of that bottom half - it will 
   just increment the lock depth again, and nobody will have locked 
   anything at all.

   And if for some reason, you can prove that bottom half processing is 
   already disabled, then ALL THAT OTHER CRAP is just that - CRAP. The 
   whole preemption disabling, the whole "_bh()" thing, everything.

   So either it's horribly buggy, or it's horribly broken and pointless. 
   Take your pick.

 - the total lack of comments. Why does that "count" protect anything? 
   It's not a recursive lock, since there is no ownership (two 
   independent accessors could call this and both "get" the lock), so you 
   had damn well better create some big-ass comments about why it's ok in 
   this case, and what the rules are that make it ok.

   So DON'T GO AROUND CALLING IT A RECURSIVE LOCK! Don't write comments 
   that are TOTAL AND UTTER SH*T! Just DON'T!

   It's a "reader lock". It's not "recursive".  It never was recursive, it 
   never will be, and calling it that is just a sign that whoever wrote 
   the function is a moron and doesn't know what he is doing. STOP DOING THIS!

 - that _idiotic_ "preempt_enable_no_resched()". F*ck me, but the comment 
   already says that preemption is disabled when exiting, so why does it 
   even bother to enable it? Why play those mindless games with preemption 
   counts, knowing that they are bogus?

   Do it readably. Disable preemption first, and just re-enable it at 
   UNLOCK time. No odd pseudo-reenables anywhere.

Oh, I know very well that the spli-locking will disable preemption, so 
it's "correct" to play those games, but the point is, it's just damn 
stupid and annoying. It just makes the source code actively _misleading_ 
to see crap like that - it looks like you enabled preemption, when in fact 
the code very much on purpose does _not_ enable preemption at all. 

In other words, I really REALLY hate that patch. I think it looks slightly 
better than Eric Dumazet's original patch (at least the locking subtlety 
is now in a function of its own and _could_ be commented upon sanely and 
if it wasn't broken it might be acceptable), but quite frankly, I'd still 
horribly disgusted with the crap.

Why are you doing this insane thing? If you want a read-lock, just use the 
damned read-write locks already! Ad far as I can tell, this lock is in 
_no_ way better than just using those counting reader-writer locks, except 
it is open-coded and looks buggy.

There is basically _never_ a good reason to re-implement locking 
primitives: you'll just introduce bugs. As proven very ably by the amount 
of crap above in what is supposed to be a very simple function.

If you want a counting read-lock (in _order_ to allow recursion, but not 
because the lock itself is somehow recursive!), then that function should 
look like this:

	void xt_info_rdlock_bh(void)
	{
		struct xt_info_lock *lock

		local_bh_disable();
		lock = &__get_cpu_var(xt_info_locks);
		read_lock(&lock->lock);
	}

And then the "unlock" should be the reverse. No games, no crap, and 
hopefully then no bugs. And if you do it that way, you don't even need the 
comments, although quite frankly, it probably makes a lot of sense to talk 
about the interaction between "local_bh_disable()" and the preempt count, 
and why you're not using "read_lock_bh()".

And if you don't want a read-lock, then fine - don't use a read-lock, do 
something else. But then don't just re-implement it (badly) either and 
call it something else!

			Linus

PS: Ingo, why do the *_bh() functions in kernel/spinlock.c do _both_ a 
"local_bh_disable()" and a "preempt_disable()"? BH disable should disable 
preemption too, no? Or am I confused? In which case we need that in 
the above rdlock_bh too.
