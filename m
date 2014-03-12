From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 net-next 1/3] filter: add Extended BPF interpreter
 and converter
Date: Wed, 12 Mar 2014 15:22:15 -0400 (EDT)
Message-ID: <20140312.152215.347361365901821816.davem@davemloft.net>
References: <1394512892-5448-1-git-send-email-ast@plumgrid.com>
	<1394512892-5448-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, mingo@kernel.org, wad@chromium.org,
	rostedt@goodmis.org, a.p.zijlstra@chello.nl, hpa@zytor.com,
	hagen@jauu.net, jesse@nicira.com, tglx@linutronix.de,
	edumazet@google.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, fweisbec@gmail.com, acme@infradead.org,
	penberg@iki.fi, arjan@infradead.org, hch@infradead.org,
	xemul@parallels.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394512892-5448-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 10 Mar 2014 21:41:30 -0700

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 1a869488b8ae..2c13d000389c 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3054,6 +3054,7 @@ extern int		netdev_max_backlog;
>  extern int		netdev_tstamp_prequeue;
>  extern int		weight_p;
>  extern int		bpf_jit_enable;
> +extern int		bpf_ext_enable;

I don't like seeing config ifdefs in C code, so please adjust the
bpf_jit_enable declaration with something like:

#ifdef CONFIG_BPF_JIT
extern int		bpf_jit_enable;
#else
#define bpf_jit_enable	0
#endif

Then you can kill the ifdefs here:

> +#ifdef CONFIG_BPF_JIT
> +	if (bpf_ext_enable && !bpf_jit_enable)
> +#else
> +	if (bpf_ext_enable)
> +#endif

And here:

> +#ifdef CONFIG_BPF_JIT
> +	if (bpf_ext_enable && !bpf_jit_enable) {
> +#else
> +	if (bpf_ext_enable) {
> +#endif

Next:

> +#ifdef CONFIG_64BIT
> +		DL(BPF_STX, BPF_XADD, BPF_DW)
> +#endif
 ...
> +#ifdef CONFIG_64BIT
> +BPF_STX_BPF_XADD_BPF_DW: /* lock xadd *(u64 *)(A + insn->off) += X */
> +	atomic64_add((u64)X, (atomic64_t *)(ulong)(A + insn->off));
> +	CONT;
> +#endif

I'm not too happy about instructions which are only available on
certain architectures.

I'd rather see best effort emulation than wholesale lack of support.

We have an implementation of 64-bit atomics for 32-bit systems or
those without true atomic compare-and-saw etc. ops in lib/atomic64.c
so the routines are always available.

64-bit stores and loads are trivial.
