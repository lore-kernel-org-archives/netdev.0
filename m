From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 net-next 1/3] filter: add Extended BPF interpreter
 and converter
Date: Fri, 07 Mar 2014 15:38:08 -0500 (EST)
Message-ID: <20140307.153808.649644634357014854.davem@davemloft.net>
References: <1394076617-8108-1-git-send-email-ast@plumgrid.com>
	<1394076617-8108-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, mingo@kernel.org, wad@chromium.org,
	rostedt@goodmis.org, a.p.zijlstra@chello.nl, hpa@zytor.com,
	hagen@jauu.net, jesse@nicira.com, tglx@linutronix.de,
	masami.hiramatsu.pt@hitachi.com, tom.zanussi@linux.intel.com,
	jovi.zhangwei@gmail.com, edumazet@google.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	fweisbec@gmail.com, acme@infradead.org, penberg@iki.fi,
	arjan@infradead.org, hch@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394076617-8108-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed,  5 Mar 2014 19:30:15 -0800

> Extended BPF extends old BPF in the following ways:
> - from 2 to 10 registers
>   Original BPF has two registers (A and X) and hidden frame pointer.
>   Extended BPF has ten registers and read-only frame pointer.
> - from 32-bit registers to 64-bit registers
>   semantics of old 32-bit ALU operations are preserved via 32-bit
>   subregisters
> - if (cond) jump_true; else jump_false;
>   old BPF insns are replaced with:
>   if (cond) jump_true; /* else fallthrough */
> - adds signed > and >= insns
> - 16 4-byte stack slots for register spill-fill replaced with
>   up to 512 bytes of multi-use stack space
> - introduces bpf_call insn and register passing convention for zero
>   overhead calls from/to other kernel functions (not part of this patch)
> - adds arithmetic right shift insn
> - adds swab32/swab64 insns
> - adds atomic_add insn
> - old tax/txa insns are replaced with 'mov dst,src' insn
> 
> Extended BPF is designed to be JITed with one to one mapping, which
> allows GCC/LLVM backends to generate optimized BPF code that performs
> almost as fast as natively compiled code

I have no fundamental objections to this work, but these patches still
need some adjustments.

> @@ -637,6 +641,10 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
>  {
>  	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
>  
> +	if ((void *)fp->bpf_func == (void *)sk_run_filter_ext)
> +		/* arch specific jit_free are expecting this value */
> +		fp->bpf_func = sk_run_filter;
> +

You should never need to cast ->bpf_func for any reason, the types have
to be correct on both sides of assignments and tests.

Furthermore, for this case, I think we should not continue to use
ad-hoc mechanisms for the JIT implementations to test this condition.

Rather, make some explicit piece of state for this, and have the JITs
test that instead.

> +	/* sock_filter_ext insns must be executed by sk_run_filter_ext */
> +	fp->bpf_func = (typeof(fp->bpf_func))sk_run_filter_ext;

Likewise.

'ctx' is an sk_buff pointer, you keep casting back and forth between void and
sk_buff * in sk_run_filter_ext, please do not do this.

You cannot make this thing opaque, the interpreter must operate in an environment
where the type of the memory behind 'ctx' is not ambiguous.  Therefore using a
void pointer and all these casts is not appropriate at all.

> @@ -676,6 +759,9 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
>  	if (fprog->filter == NULL)
>  		return -EINVAL;
>  
> +	if (bpf_ext_enable)
> +		return sk_prepare_filter_ext(pfp, fprog, NULL);
> +
>  	fp = kmalloc(sk_filter_size(fprog->len), GFP_KERNEL);
>  	if (!fp)
>  		return -ENOMEM;

To me this is the wrong priority, if the user has JIT enabled it should
take priority over translation into extended BPF.

> @@ -726,21 +812,27 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>  	if (fprog->filter == NULL)
>  		return -EINVAL;
>  
> -	fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
> -	if (!fp)
> -		return -ENOMEM;
> -	if (copy_from_user(fp->insns, fprog->filter, fsize)) {
> -		sock_kfree_s(sk, fp, sk_fsize);
> -		return -EFAULT;
> -	}
> +	if (bpf_ext_enable) {
> +		err = sk_prepare_filter_ext(&fp, fprog, sk);
> +		if (err)
> +			return err;

Likewise.

> +#ifdef __x86_64
> +#define LOAD_IMM /**/
> +#define K insn->imm
> +#else
> +#define LOAD_IMM (K = insn->imm)
> +	s32 K = insn->imm;
> +#endif

There is no way we should have a cpu type ifdef in this code.  Please pick one
way or the other and get rid of the CPP test entirely.
