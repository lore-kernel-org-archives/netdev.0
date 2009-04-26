From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH] netfilter: use per-CPU recursive lock {XV}
Date: Sun, 26 Apr 2009 15:31:35 -0400
Message-ID: <20090426193135.GA30851@Krystal>
References: <20090421111541.228e977a@nehalam> <20090421193924.GA24404@elte.hu> <20090421143927.52d7d89d@nehalam> <alpine.LFD.2.00.0904220821240.3101@localhost.localdomain> <20090423210938.1501507b@nehalam> <49F146FF.5050200@cosmosbay.com> <20090424091839.6e13ebec@nehalam> <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756297AbZDZTbz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49F4A6E3.7080102@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Eric Dumazet (dada1@cosmosbay.com) wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> 
> > Epilogue due to master Jarek. Lockdep carest not about the locking
> > doth bestowed. Therefore no keys are needed.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> So far, so good, should be ready for inclusion now, nobody complained :)
> 
> I include the final patch, merge of your last two patches.
> 
> David, could you please review it once again and apply it if it's OK ?
> 
[...]
> +/*
> + * Per-CPU read/write lock associated with per-cpu table entries.
> + * This is not a general solution but makes reader locking fast since
> + * there is no shared variable to cause cache ping-pong; but adds an
> + * additional write-side penalty since update must lock all
> + * possible CPU's.
> + *
> + * Read lock is used by ip/arp/ip6 tables rule processing which runs per-cpu.
> + * It needs to ensure that the rules are not being changed while packet
> + * is being processed. In some cases, the read lock will be acquired
> + * twice on the same CPU; this is okay because read locks handle nesting.
> + *
> + * Write lock is used in two cases:
> + *    1. reading counter values
> + *       all readers need to be stopped and the per-CPU values are summed.
> + *
> + *    2. replacing tables
> + *       any readers that are using the old tables have to complete
> + *       before freeing the old table. This is handled by reading
> + *	  as a side effect of reading counters
> + */
> +DECLARE_PER_CPU(rwlock_t, xt_info_locks);
> +
> +static inline void xt_info_rdlock_bh(void)
> +{
> +	/*
> +	 * Note: can not use read_lock_bh(&__get_cpu_var(xt_info_locks))
> +	 * because need to ensure that preemption is disable before
> +	 * acquiring per-cpu-variable, so do it as a two step process
> +	 */
> +	local_bh_disable();

Why do you need to disable bottom halves on the read-side ? You could
probably just disable preemption, given this lock is nestable on the
read-side anyway. Or I'm missing something obvious ?

> +	read_lock(&__get_cpu_var(xt_info_locks));
> +}
> +
> +static inline void xt_info_rdunlock_bh(void)
> +{
> +	read_unlock_bh(&__get_cpu_var(xt_info_locks));
> +}
> +
> +static inline void xt_info_wrlock(unsigned int cpu)
> +{
> +	write_lock(&per_cpu(xt_info_locks, cpu));
> +}
> +
> +static inline void xt_info_wrunlock(unsigned int cpu)
> +{
> +
> +	write_unlock(&per_cpu(xt_info_locks, cpu));
> +}
>  

[...]

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
