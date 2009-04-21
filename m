From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 21:39:24 +0200
Message-ID: <20090421193924.GA24404@elte.hu>
References: <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090421111541.228e977a@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Stephen Hemminger <shemminger@vyatta.com> wrote:

> +void xt_info_wrunlock_bh(void)
> +	__releases(xt_info_lock)
> +{
> +	unsigned int i;
> +
> +	for_each_possible_cpu(i) {
> +#if NR_CPUS > (PREEMPT_MASK - 1)
> +		/*
> +		 * Spin_unlock calls preempt_enable, but since we had
> +		 * to adjust the count in xt_info_wrlock_bh, do it again
> +		 */
> +		preempt_disable();
> +#endif
> +		write_unlock(&per_cpu(xt_info_locks, i));
> +	}
> +	local_bh_enable();
> +}

In the global/local lock scheme i proposed this would become:

	global_write_unlock(void)
	{
		write_unlock(&global_lock);
	}

As we dont hold the local locks during the write-locked critical 
section. No loop needed over CPUs, no preempt nesting complications, 
no lockdep complications, etc.

	Ingo
