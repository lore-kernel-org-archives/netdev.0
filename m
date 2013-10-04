From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 net-next] fix unsafe set_memory_rw from softirq
Date: Fri, 4 Oct 2013 09:51:33 +0200
Message-ID: <20131004075133.GA12313@gmail.com>
References: <1380853446-30537-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
 Eric Dumazet <edumazet@google.com>, Paul Mackerras <paulus@samba.org>,
 "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org,
 Nicolas Dichtel <nicolas.dichtel@6wind.com>, linux-s390@vger.kernel.org,
 Russell King <linux@arm.linux.org.uk>, x86@kernel.org,
 James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>,
 Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Xi Wang <xi.wang@gmail.com>,
 Matt Evans <matt@ozlabs.org>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, Stelian Nirlu <steliannirlu@gmail.com>,
 Nicolas Schichan <nschichan@freebox.fr>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 Mircea Gherzan <mgherzan@gmail.com>, Daniel Borkmann <dborkman@red
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1380853446-30537-1-git-send-email-ast@plumgrid.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> on x86 system with net.core.bpf_jit_enable = 1
> 
> sudo tcpdump -i eth1 'tcp port 22'
> 
> causes the warning:
> [   56.766097]  Possible unsafe locking scenario:
> [   56.766097]
> [   56.780146]        CPU0
> [   56.786807]        ----
> [   56.793188]   lock(&(&vb->lock)->rlock);
> [   56.799593]   <Interrupt>
> [   56.805889]     lock(&(&vb->lock)->rlock);
> [   56.812266]
> [   56.812266]  *** DEADLOCK ***
> [   56.812266]
> [   56.830670] 1 lock held by ksoftirqd/1/13:
> [   56.836838]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff8118f44c>] vm_unmap_aliases+0x8c/0x380
> [   56.849757]
> [   56.849757] stack backtrace:
> [   56.862194] CPU: 1 PID: 13 Comm: ksoftirqd/1 Not tainted 3.12.0-rc3+ #45
> [   56.868721] Hardware name: System manufacturer System Product Name/P8Z77 WS, BIOS 3007 07/26/2012
> [   56.882004]  ffffffff821944c0 ffff88080bbdb8c8 ffffffff8175a145 0000000000000007
> [   56.895630]  ffff88080bbd5f40 ffff88080bbdb928 ffffffff81755b14 0000000000000001
> [   56.909313]  ffff880800000001 ffff880800000000 ffffffff8101178f 0000000000000001
> [   56.923006] Call Trace:
> [   56.929532]  [<ffffffff8175a145>] dump_stack+0x55/0x76
> [   56.936067]  [<ffffffff81755b14>] print_usage_bug+0x1f7/0x208
> [   56.942445]  [<ffffffff8101178f>] ? save_stack_trace+0x2f/0x50
> [   56.948932]  [<ffffffff810cc0a0>] ? check_usage_backwards+0x150/0x150
> [   56.955470]  [<ffffffff810ccb52>] mark_lock+0x282/0x2c0
> [   56.961945]  [<ffffffff810ccfed>] __lock_acquire+0x45d/0x1d50
> [   56.968474]  [<ffffffff810cce6e>] ? __lock_acquire+0x2de/0x1d50
> [   56.975140]  [<ffffffff81393bf5>] ? cpumask_next_and+0x55/0x90
> [   56.981942]  [<ffffffff810cef72>] lock_acquire+0x92/0x1d0
> [   56.988745]  [<ffffffff8118f52a>] ? vm_unmap_aliases+0x16a/0x380
> [   56.995619]  [<ffffffff817628f1>] _raw_spin_lock+0x41/0x50
> [   57.002493]  [<ffffffff8118f52a>] ? vm_unmap_aliases+0x16a/0x380
> [   57.009447]  [<ffffffff8118f52a>] vm_unmap_aliases+0x16a/0x380
> [   57.016477]  [<ffffffff8118f44c>] ? vm_unmap_aliases+0x8c/0x380
> [   57.023607]  [<ffffffff810436b0>] change_page_attr_set_clr+0xc0/0x460
> [   57.030818]  [<ffffffff810cfb8d>] ? trace_hardirqs_on+0xd/0x10
> [   57.037896]  [<ffffffff811a8330>] ? kmem_cache_free+0xb0/0x2b0
> [   57.044789]  [<ffffffff811b59c3>] ? free_object_rcu+0x93/0xa0
> [   57.051720]  [<ffffffff81043d9f>] set_memory_rw+0x2f/0x40
> [   57.058727]  [<ffffffff8104e17c>] bpf_jit_free+0x2c/0x40
> [   57.065577]  [<ffffffff81642cba>] sk_filter_release_rcu+0x1a/0x30
> [   57.072338]  [<ffffffff811108e2>] rcu_process_callbacks+0x202/0x7c0
> [   57.078962]  [<ffffffff81057f17>] __do_softirq+0xf7/0x3f0
> [   57.085373]  [<ffffffff81058245>] run_ksoftirqd+0x35/0x70
> 
> cannot reuse jited filter memory, since it's readonly,
> so use original bpf insns memory to hold work_struct
> 
> defer kfree of sk_filter until jit completed freeing
> 
> tested on x86_64 and i386
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  arch/arm/net/bpf_jit_32.c       |    1 +
>  arch/powerpc/net/bpf_jit_comp.c |    1 +
>  arch/s390/net/bpf_jit_comp.c    |    4 +++-
>  arch/sparc/net/bpf_jit_comp.c   |    1 +
>  arch/x86/net/bpf_jit_comp.c     |   20 +++++++++++++++-----
>  include/linux/filter.h          |   11 +++++++++--
>  net/core/filter.c               |   11 +++++++----
>  7 files changed, 37 insertions(+), 12 deletions(-)
> 
> diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
> index f50d223..99b44e0 100644
> --- a/arch/arm/net/bpf_jit_32.c
> +++ b/arch/arm/net/bpf_jit_32.c
> @@ -930,4 +930,5 @@ void bpf_jit_free(struct sk_filter *fp)
>  {
>  	if (fp->bpf_func != sk_run_filter)
>  		module_free(NULL, fp->bpf_func);
> +	kfree(fp);
>  }
> diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
> index bf56e33..2345bdb 100644
> --- a/arch/powerpc/net/bpf_jit_comp.c
> +++ b/arch/powerpc/net/bpf_jit_comp.c
> @@ -691,4 +691,5 @@ void bpf_jit_free(struct sk_filter *fp)
>  {
>  	if (fp->bpf_func != sk_run_filter)
>  		module_free(NULL, fp->bpf_func);
> +	kfree(fp);
>  }
> diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
> index 7092392..a5df511 100644
> --- a/arch/s390/net/bpf_jit_comp.c
> +++ b/arch/s390/net/bpf_jit_comp.c
> @@ -881,7 +881,9 @@ void bpf_jit_free(struct sk_filter *fp)
>  	struct bpf_binary_header *header = (void *)addr;
>  
>  	if (fp->bpf_func == sk_run_filter)
> -		return;
> +		goto free_filter;
>  	set_memory_rw(addr, header->pages);
>  	module_free(NULL, header);
> +free_filter:
> +	kfree(fp);
>  }
> diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
> index 9c7be59..218b6b2 100644
> --- a/arch/sparc/net/bpf_jit_comp.c
> +++ b/arch/sparc/net/bpf_jit_comp.c
> @@ -808,4 +808,5 @@ void bpf_jit_free(struct sk_filter *fp)
>  {
>  	if (fp->bpf_func != sk_run_filter)
>  		module_free(NULL, fp->bpf_func);
> +	kfree(fp);
>  }
> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
> index 79c216a..1396a0a 100644
> --- a/arch/x86/net/bpf_jit_comp.c
> +++ b/arch/x86/net/bpf_jit_comp.c
> @@ -772,13 +772,23 @@ out:
>  	return;
>  }
>  
> +static void bpf_jit_free_deferred(struct work_struct *work)
> +{
> +	struct sk_filter *fp = container_of((void *)work, struct sk_filter,
> +					    insns);
> +	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
> +	struct bpf_binary_header *header = (void *)addr;
> +
> +	set_memory_rw(addr, header->pages);
> +	module_free(NULL, header);
> +	kfree(fp);
> +}

Using the data type suggestions I make further below, this could be 
written in a simpler form, as:

	struct sk_filter *fp = container_of(work, struct sk_filter, work);

Also, a question, why do you mask with PAGE_MASK here:

	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;

?

AFAICS bpf_func is the module_alloc() result - and module code is page 
aligned. So ->bpf_func is always page aligned here. (The sk_run_filter 
special case cannot happen here.)

> +
>  void bpf_jit_free(struct sk_filter *fp)
>  {
>  	if (fp->bpf_func != sk_run_filter) {
> -		unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
> -		struct bpf_binary_header *header = (void *)addr;
> -
> -		set_memory_rw(addr, header->pages);
> -		module_free(NULL, header);
> +		struct work_struct *work = (struct work_struct *)fp->insns;
> +		INIT_WORK(work, bpf_jit_free_deferred);

Missing newline between local variables and statements.

> +		schedule_work(work);
>  	}
>  }
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index a6ac848..5d66cd9 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -25,15 +25,20 @@ struct sk_filter
>  {
>  	atomic_t		refcnt;
>  	unsigned int         	len;	/* Number of filter blocks */
> +	struct rcu_head		rcu;
>  	unsigned int		(*bpf_func)(const struct sk_buff *skb,
>  					    const struct sock_filter *filter);
> -	struct rcu_head		rcu;
> +	/* insns start right after bpf_func, so that sk_run_filter() fetches
> +	 * first insn from the same cache line that was used to call into
> +	 * sk_run_filter()
> +	 */
>  	struct sock_filter     	insns[0];

Please use the customary (multi-line) comment style:

  /*
   * Comment .....
   * ...... goes here.
   */

specified in Documentation/CodingStyle.

>  };
>  
>  static inline unsigned int sk_filter_len(const struct sk_filter *fp)
>  {
> -	return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
> +	return max(fp->len * sizeof(struct sock_filter),
> +		   sizeof(struct work_struct)) + sizeof(*fp);

So, "sizeof(struct work_struct)) + sizeof(*fp)" is a pattern that repeats 
a couple of times. Might make sense to stick that into a helper of its own 
- but in general this open coded overlay allocation method looks a bit 
fragile and not very obvious in isolation.

So it could be done a bit cleaner, using an anonymous union:

	/*
	 * These two overlay, the work struct is used during workqueue 
	 * driven teardown, when the instructions are not used anymore:
	 */
	union {
		struct sock_filter     	insns[0];
		struct work_struct	work;
	};

And then all the sizeof() calculations become obvious and sk_filter_len() 
could be eliminated - I've marked the conversions in the code further 
below.

>  extern int sk_filter(struct sock *sk, struct sk_buff *skb);
> @@ -67,11 +72,13 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
>  }
>  #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
>  #else
> +#include <linux/slab.h>

Inlines in the middle of header files are generally frowned upon.

The standard pattern is to put them at the top, that way it's easier to 
see the dependencies and there's also less .config dependent inclusion, 
which makes header hell cleanup work easier.

>  static inline void bpf_jit_compile(struct sk_filter *fp)
>  {
>  }
>  static inline void bpf_jit_free(struct sk_filter *fp)
>  {
> +	kfree(fp);
>  }
>  #define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
>  #endif
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 6438f29..ad5eaba 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -644,7 +644,6 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
>  	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
>  
>  	bpf_jit_free(fp);
> -	kfree(fp);
>  }
>  EXPORT_SYMBOL(sk_filter_release_rcu);
>  
> @@ -677,13 +676,15 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
>  {
>  	struct sk_filter *fp;
>  	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
> +	unsigned int sk_fsize = max_t(u32, fsize, sizeof(struct work_struct))
> +		+ sizeof(*fp);

Using the structure definition I suggested, this could be replaced with 
the more obvious:

	unsigned int sk_fsize = max(fsize, sizeof(*fp));

>  	int err;
>  
>  	/* Make sure new filter is there and in the right amounts. */
>  	if (fprog->filter == NULL)
>  		return -EINVAL;
>  
> -	fp = kmalloc(fsize + sizeof(*fp), GFP_KERNEL);
> +	fp = kmalloc(sk_fsize, GFP_KERNEL);
>  	if (!fp)
>  		return -ENOMEM;
>  	memcpy(fp->insns, fprog->filter, fsize);
> @@ -723,6 +724,8 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>  {
>  	struct sk_filter *fp, *old_fp;
>  	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
> +	unsigned int sk_fsize = max_t(u32, fsize, sizeof(struct work_struct))
> +		+ sizeof(*fp);

This too could be written as:

	unsigned int sk_fsize = max(fsize, sizeof(*fp));

>  	int err;
>  
>  	if (sock_flag(sk, SOCK_FILTER_LOCKED))
> @@ -732,11 +735,11 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>  	if (fprog->filter == NULL)
>  		return -EINVAL;
>  
> -	fp = sock_kmalloc(sk, fsize+sizeof(*fp), GFP_KERNEL);
> +	fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
>  	if (!fp)
>  		return -ENOMEM;
>  	if (copy_from_user(fp->insns, fprog->filter, fsize)) {
> -		sock_kfree_s(sk, fp, fsize+sizeof(*fp));
> +		sock_kfree_s(sk, fp, sk_fsize);
>  		return -EFAULT;
>  	}

A couple of questions/suggestions:

1)

I took a brief look at arch/x86/net/bpf_jit_comp.c while reviewing this 
patch.

You need to split up bpf_jit_compile(), it's an obscenely large, ~600 
lines long function. We don't do that in modern, maintainable kernel code.

2)

This 128 bytes extra padding:

        /* Most of BPF filters are really small,
         * but if some of them fill a page, allow at least
         * 128 extra bytes to insert a random section of int3
         */
        sz = round_up(proglen + sizeof(*header) + 128, PAGE_SIZE);

why is it done? It's not clear to me from the comment.

3)

It's nice code altogether! Are there any plans to generalize its 
interfaces, to allow arbitrary bytecode to be used by other kernel 
subsystems as well? In particular tracing filters could make use of it, 
but it would also allow safe probe points.

Thanks,

	Ingo
