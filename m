From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v2 03/11] soc/fsl: Introduce the DPAA BMan portal driver
Date: Mon, 24 Aug 2015 20:25:23 -0500
Message-ID: <20150825012523.GA3862@home.buserror.net>
References: <1439410497-19039-4-git-send-email-Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Roy Pledge <Roy.Pledge@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439410497-19039-4-git-send-email-Roy.Pledge@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 12, 2015 at 04:14:49PM -0400, Roy Pledge wrote:
> diff --git a/drivers/soc/fsl/qbman/bman.c b/drivers/soc/fsl/qbman/bman.c
> index 9a500ce..d6e2204 100644
> --- a/drivers/soc/fsl/qbman/bman.c
> +++ b/drivers/soc/fsl/qbman/bman.c
> @@ -165,11 +165,11 @@ static struct bman *bm_create(void *regs)
>  
>  static inline u32 __bm_in(struct bman *bm, u32 offset)
>  {
> -	return in_be32((void *)bm + offset);
> +	return ioread32be((void *)bm + offset);
>  }
>  static inline void __bm_out(struct bman *bm, u32 offset, u32 val)
>  {
> -	out_be32((void *)bm + offset, val);
> +	iowrite32be(val, (void*) bm + offset);
>  }

Don't introduce a problem in one patch and then fix it in another.  What
does this change have to do with introducing the portal driver?

>  #define bm_in(reg)		__bm_in(bm, REG_##reg)
>  #define bm_out(reg, val)	__bm_out(bm, REG_##reg, val)
> @@ -341,6 +341,7 @@ u32 bm_pool_free_buffers(u32 bpid)
>  {
>  	return bm_in(POOL_CONTENT(bpid));
>  }
> +EXPORT_SYMBOL(bm_pool_free_buffers);

If you're exporting this (or even making it global), where's the
documentation?

> +/* BTW, the drivers (and h/w programming model) already obtain the required
> + * synchronisation for portal accesses via lwsync(), hwsync(), and
> + * data-dependencies. Use of barrier()s or other order-preserving primitives
> + * simply degrade performance. Hence the use of the __raw_*() interfaces, which
> + * simply ensure that the compiler treats the portal registers as volatile (ie.
> + * non-coherent). */

volatile does not mean "non-coherent".

Be careful with this regarding endian, e.g. on ARM we can run the CPU in
big or little endian on the same chip, and the raw accessors also
unfortunately bypass endian conversion.

> +
> +/* Cache-inhibited register access. */
> +#define __bm_in(bm, o)		__raw_readl((bm)->addr_ci + (o))
> +#define __bm_out(bm, o, val)	__raw_writel((val), (bm)->addr_ci + (o))
> +#define bm_in(reg)		__bm_in(&portal->addr, BM_REG_##reg)
> +#define bm_out(reg, val)	__bm_out(&portal->addr, BM_REG_##reg, val)

Don't have multiple implementations of bm_in/out, with the same name,
where bm in both refers to "bman", but which have different functions.

> +/* Cache-enabled (index) register access */
> +#define __bm_cl_touch_ro(bm, o) dcbt_ro((bm)->addr_ce + (o))
> +#define __bm_cl_touch_rw(bm, o) dcbt_rw((bm)->addr_ce + (o))
> +#define __bm_cl_in(bm, o)	__raw_readl((bm)->addr_ce + (o))
> +#define __bm_cl_out(bm, o, val) \
> +	do { \
> +		u32 *__tmpclout = (bm)->addr_ce + (o); \
> +		__raw_writel((val), __tmpclout); \
> +		dcbf(__tmpclout); \
> +	} while (0)
> +#define __bm_cl_invalidate(bm, o) dcbi((bm)->addr_ce + (o))
> +#define bm_cl_touch_ro(reg) __bm_cl_touch_ro(&portal->addr, BM_CL_##reg##_CENA)
> +#define bm_cl_touch_rw(reg) __bm_cl_touch_rw(&portal->addr, BM_CL_##reg##_CENA)
> +#define bm_cl_in(reg)	    __bm_cl_in(&portal->addr, BM_CL_##reg##_CENA)
> +#define bm_cl_out(reg, val) __bm_cl_out(&portal->addr, BM_CL_##reg##_CENA, val)
> +#define bm_cl_invalidate(reg)\
> +	__bm_cl_invalidate(&portal->addr, BM_CL_##reg##_CENA)

Define these using functions to operate on pointers, and pass the pointer
in without all the token-pasting.  Some extra explanation of the cache
manipulation would also be helpful.

> +/* --- RCR API --- */
> +
> +/* Bit-wise logic to wrap a ring pointer by clearing the "carry bit" */
> +#define RCR_CARRYCLEAR(p) \
> +	(void *)((unsigned long)(p) & (~(unsigned long)(BM_RCR_SIZE << 6)))

This could be a function.

Where does 6 come from?  You use it again in the next function.  Please
define it symbolically.

> +
> +/* Bit-wise logic to convert a ring pointer to a ring index */
> +static inline u8 RCR_PTR2IDX(struct bm_rcr_entry *e)
> +{
> +	return ((uintptr_t)e >> 6) & (BM_RCR_SIZE - 1);
> +}

This is a function, so don't use ALLCAPS.

> +/* Increment the 'cursor' ring pointer, taking 'vbit' into account */
> +static inline void RCR_INC(struct bm_rcr *rcr)
> +{
> +	/* NB: this is odd-looking, but experiments show that it generates
> +	 * fast code with essentially no branching overheads. We increment to
> +	 * the next RCR pointer and handle overflow and 'vbit'. */
> +	struct bm_rcr_entry *partial = rcr->cursor + 1;
> +
> +	rcr->cursor = RCR_CARRYCLEAR(partial);
> +	if (partial != rcr->cursor)
> +		rcr->vbit ^= BM_RCR_VERB_VBIT;
> +}
> +
> +static inline int bm_rcr_init(struct bm_portal *portal, enum bm_rcr_pmode pmode,
> +		__maybe_unused enum bm_rcr_cmode cmode)
> +{
> +	/* This use of 'register', as well as all other occurrences, is because
> +	 * it has been observed to generate much faster code with gcc than is
> +	 * otherwise the case. */
> +	register struct bm_rcr *rcr = &portal->rcr;

What version of GCC?  Normal optimization settings?

Has the seemingly excessive use of inline also been benchmarked against
not doing so?

> +/* Buffer Pool Cleanup */
> +static inline int bm_shutdown_pool(struct bm_portal *p, u32 bpid)
> +{
> +	struct bm_mc_command *bm_cmd;
> +	struct bm_mc_result *bm_res;
> +	int aq_count = 0;
> +	bool stop = false;
> +
> +	while (!stop) {
> +		/* Acquire buffers until empty */
> +		bm_cmd = bm_mc_start(p);
> +		bm_cmd->acquire.bpid = bpid;
> +		bm_mc_commit(p, BM_MCC_VERB_CMD_ACQUIRE |  1);
> +		while (!(bm_res = bm_mc_result(p)))
> +			cpu_relax();

How long can this take?  How about a timeout?

And it looks like this happens with interrupts disabled. :-(

> +/* Compilation constants */
> +#define RCR_THRESH	2	/* reread h/w CI when running out of space */
> +#define IRQNAME		"BMan portal %d"
> +#define MAX_IRQNAME	16	/* big enough for "BMan portal %d" */
> +#define FSL_DPA_PORTAL_SHARE 1  /* Allow portals to be shared */

If (some of) these are meant to be tunable they need to go in Kconfig.

> +struct bman_portal {
> +	struct bm_portal p;

What is the conceptual difference between 'bman_portal' and 'bm_portal'?

> +	/* 2-element array. pools[0] is mask, pools[1] is snapshot. */
> +	struct bman_depletion *pools;
> +	int thresh_set;
> +	unsigned long irq_sources;
> +	u32 slowpoll;	/* only used when interrupts are off */
> +#ifdef FSL_DPA_CAN_WAIT_SYNC
> +	struct bman_pool *rcri_owned; /* only 1 release WAIT_SYNC at a time */
> +#endif
> +#ifdef FSL_DPA_PORTAL_SHARE
> +	raw_spinlock_t sharing_lock; /* only used if is_shared */
> +	int is_shared;
> +	struct bman_portal *sharing_redirect;
> +#endif
> +	/* When the cpu-affine portal is activated, this is non-NULL */
> +	const struct bm_portal_config *config;
> +	/* 64-entry hash-table of pool objects that are tracking depletion
> +	 * entry/exit (ie. BMAN_POOL_FLAG_DEPLETION). This isn't fast-path, so
> +	 * we're not fussy about cache-misses and so forth - whereas the above
> +	 * members should all fit in one cacheline.
> +	 * BTW, with 64 entries in the hash table and 64 buffer pools to track,
> +	 * you'll never guess the hash-function ... */
> +	struct bman_pool *cb[64];
> +	char irqname[MAX_IRQNAME];
> +	/* Track if the portal was alloced by the driver */
> +	u8 alloced;
> +};

Consider sorting this to minimize padding, and keeping cache-hot members
together (e.g. I see "slowpoll" which is "only used when interrupts are
off" between presumably-cache-hot things like bm_portal and the lock).

s/u8 alloced/bool alloced/

> +#ifdef FSL_DPA_PORTAL_SHARE
> +#define PORTAL_IRQ_LOCK(p, irqflags) \
> +	do { \
> +		if ((p)->is_shared) \
> +			raw_spin_lock_irqsave(&(p)->sharing_lock, irqflags); \
> +		else \
> +			local_irq_save(irqflags); \
> +	} while (0)
> +#define PORTAL_IRQ_UNLOCK(p, irqflags) \
> +	do { \
> +		if ((p)->is_shared) \
> +			raw_spin_unlock_irqrestore(&(p)->sharing_lock, \
> +						   irqflags); \
> +		else \
> +			local_irq_restore(irqflags); \
> +	} while (0)
> +#else
> +#define PORTAL_IRQ_LOCK(p, irqflags) local_irq_save(irqflags)
> +#define PORTAL_IRQ_UNLOCK(p, irqflags) local_irq_restore(irqflags)
> +#endif

Don't use macros or allcaps.

If you're using raw locks and/or local_irq_save, the time of the critical
section must be bounded.  How long can this be held for?

> +static cpumask_t affine_mask;
> +static DEFINE_SPINLOCK(affine_mask_lock);
> +static DEFINE_PER_CPU(struct bman_portal, bman_affine_portal);
> +static inline struct bman_portal *get_raw_affine_portal(void)
> +{
> +	return &get_cpu_var(bman_affine_portal);
> +}
> +#ifdef FSL_DPA_PORTAL_SHARE
> +static inline struct bman_portal *get_affine_portal(void)
> +{
> +	struct bman_portal *p = get_raw_affine_portal();
> +
> +	if (p->sharing_redirect)
> +		return p->sharing_redirect;
> +	return p;
> +}

Where can I find documentation of the sharing_redirect mechanism?  What
is it needed for in the context of getting basic datapath support
working?

> +/* GOTCHA: this object type refers to a pool, it isn't *the* pool. There may be
> + * more than one such object per BMan buffer pool, eg. if different users of the
> + * pool are operating via different portals. */
> +struct bman_pool {

So maybe call it struct bman_pool_user or similar?

> +/* In the case that the application's core loop calls
> + * bman_poll(),

application?

> we ought to balance how often we incur the overheads of the
> + * slow-path poll. We'll use two decrementer sources. The idle decrementer
> + * constant is used when the last slow-poll detected no work to do, and the busy
> + * decrementer constant when the last slow-poll had work to do. */

Why does this driver care whether the timer is implemented with a
decrementer?  What is a "decrementer source"?

> +#define SLOW_POLL_IDLE 1000
> +#define SLOW_POLL_BUSY 10
> +static u32 __poll_portal_slow(struct bman_portal *p, u32 is);
> +
> +/* Portal interrupt handler */
> +static irqreturn_t portal_isr(__always_unused int irq, void *ptr)
> +{
> +	struct bman_portal *p = ptr;
> +	u32 clear = p->irq_sources;
> +	u32 is = bm_isr_status_read(&p->p) & p->irq_sources;
> +
> +	clear |= __poll_portal_slow(p, is);
> +	bm_isr_status_clear(&p->p, clear);
> +	return IRQ_HANDLED;
> +}

No IRQ_NONE check, even behind the debug check ifdef?

> +struct bman_portal *bman_create_portal(
> +				       struct bman_portal *portal,
> +				       const struct bm_portal_config *config)
> +{
> +	struct bm_portal *__p;

Please don't use gratuitous underscores.

> +struct bman_portal *bman_create_affine_slave(struct bman_portal *redirect,
> +								int cpu)
> +{
> +#ifdef FSL_DPA_PORTAL_SHARE
> +	struct bman_portal *p = &per_cpu(bman_affine_portal, cpu);
> +
> +	BUG_ON(p->config);
> +	BUG_ON(p->is_shared);
> +	BUG_ON(!redirect->config->public_cfg.is_shared);

More BUG_ON()s...

> +static u32 __poll_portal_slow(struct bman_portal *p, u32 is)
> +{
> +	struct bman_depletion tmp;
> +	u32 ret = is;
> +
> +	/* There is a gotcha to be aware of. If we do the query before clearing
> +	 * the status register, we may miss state changes that occur between the
> +	 * two. If we write to clear the status register before the query, the
> +	 * cache-enabled query command may overtake the status register write
> +	 * unless we use a heavyweight sync (which we don't want). Instead, we
> +	 * write-to-clear the status register then *read it back* before doing
> +	 * the query, hence the odd while loop with the 'is' accumulation. */
> +	if (is & BM_PIRQ_BSCN) {
> +		struct bm_mc_result *mcr;
> +		__maybe_unused unsigned long irqflags;
> +		unsigned int i, j;
> +		u32 __is;
> +
> +		bm_isr_status_clear(&p->p, BM_PIRQ_BSCN);
> +		while ((__is = bm_isr_status_read(&p->p)) & BM_PIRQ_BSCN) {
> +			is |= __is;
> +			bm_isr_status_clear(&p->p, BM_PIRQ_BSCN);
> +		}
> +		is &= ~BM_PIRQ_BSCN;
> +		PORTAL_IRQ_LOCK(p, irqflags);
> +		bm_mc_start(&p->p);
> +		bm_mc_commit(&p->p, BM_MCC_VERB_CMD_QUERY);
> +		while (!(mcr = bm_mc_result(&p->p)))
> +			cpu_relax();
> +		tmp = mcr->query.ds.state;
> +		PORTAL_IRQ_UNLOCK(p, irqflags);

Another apparently unbounded loop inside the lock.

> +	ier = bm_isr_enable_read(&p->p);
> +	/* Using "~ier" (rather than "bits" or "~p->irq_sources") creates a
> +	 * data-dependency, ie. to protect against re-ordering. */
> +	bm_isr_status_clear(&p->p, ~ier);

Aren't bm_isr_enable_read/bm_isr_status_clear() implemented with I/O
accessors that ensure ordering anyway?

> +	PORTAL_IRQ_UNLOCK(p, irqflags);
> +	put_affine_portal();
> +	return 0;
> +}
> +EXPORT_SYMBOL(bman_irqsource_remove);
> +
> +const cpumask_t *bman_affine_cpus(void)
> +{
> +	return &affine_mask;
> +}
> +EXPORT_SYMBOL(bman_affine_cpus);
> +
> +u32 bman_poll_slow(void)
> +{
> +	struct bman_portal *p = get_poll_portal();
> +	u32 ret;
> +
> +#ifdef FSL_DPA_PORTAL_SHARE
> +	if (unlikely(p->sharing_redirect))
> +		ret = (u32)-1;
> +	else
> +#endif
> +	{
> +		u32 is = bm_isr_status_read(&p->p) & ~p->irq_sources;
> +
> +		ret = __poll_portal_slow(p, is);
> +		bm_isr_status_clear(&p->p, ret);
> +	}
> +	put_poll_portal();
> +	return ret;
> +}
> +EXPORT_SYMBOL(bman_poll_slow);
> +
> +/* Legacy wrapper */
> +void bman_poll(void)

What legacy?  This is a brand new driver, as far as mainline is
concerned.  What is this retaining compatibility with?

> +static inline struct bm_rcr_entry *try_rel_start(struct bman_portal **p,
> +#ifdef FSL_DPA_CAN_WAIT
> +					__maybe_unused struct bman_pool *pool,
> +#endif
> +					__maybe_unused unsigned long *irqflags,
> +					__maybe_unused u32 flags)

Please don't vary the arguments of a function based on an ifdef.

> +#ifdef CONFIG_FSL_DPA_CHECKING
> +	if (!atomic_dec_and_test(&pool->in_use)) {
> +		pr_crit("Parallel attempts to enter bman_released() detected.");
> +		panic("only one instance of bman_released/acquired allowed");
> +	}

No panics.

> +#ifndef __FSL_BMAN_H
> +#define __FSL_BMAN_H
> +
> +#ifdef __cplusplus
> +extern "C" {
> +#endif

This is not needed.

> +/* Enable blocking waits */
> +#define FSL_DPA_CAN_WAIT       1
> +#define FSL_DPA_CAN_WAIT_SYNC  1

Again, put them in Kconfig if it's really needed to keep both code paths.

> +
> +/* Last updated for v00.79 of the BG */

Same comment as previous patch.

> +
> +/* Portal processing (interrupt) sources */
> +#define BM_PIRQ_RCRI	0x00000002	/* RCR Ring (below threshold) */
> +#define BM_PIRQ_BSCN	0x00000001	/* Buffer depletion State Change */
> +
> +/* This wrapper represents a bit-array for the depletion state of the 64 BMan
> + * buffer pools. */
> +struct bman_depletion {
> +	u32 __state[2];
> +};

Why underscores?

> +#define BMAN_DEPLETION_EMPTY { { 0x00000000, 0x00000000 } }
> +#define BMAN_DEPLETION_FULL { { 0xffffffff, 0xffffffff } }
> +#define __bmdep_word(x) ((x) >> 5)
> +#define __bmdep_shift(x) ((x) & 0x1f)
> +#define __bmdep_bit(x) (0x80000000 >> __bmdep_shift(x))
> +static inline void bman_depletion_init(struct bman_depletion *c)
> +{
> +	c->__state[0] = c->__state[1] = 0;
> +}
> +static inline void bman_depletion_fill(struct bman_depletion *c)
> +{
> +	c->__state[0] = c->__state[1] = ~0;
> +}
> +static inline int bman_depletion_get(const struct bman_depletion *c, u8 bpid)
> +{
> +	return c->__state[__bmdep_word(bpid)] & __bmdep_bit(bpid);
> +}
> +static inline void bman_depletion_set(struct bman_depletion *c, u8 bpid)
> +{
> +	c->__state[__bmdep_word(bpid)] |= __bmdep_bit(bpid);
> +}
> +static inline void bman_depletion_unset(struct bman_depletion *c, u8 bpid)
> +{
> +	c->__state[__bmdep_word(bpid)] &= ~__bmdep_bit(bpid);
> +}

You appear to be reimplementing __set_bit()/__clear_bit/test_bit().

> +static inline dma_addr_t bm_buf_addr(const struct bm_buffer *buf)
> +{
> +	return (dma_addr_t)buf->addr;
> +}

You cannot convert a virtual address to a DMA address by casting.

> +/* Macro, so we compile better if 'v' isn't always 64-bit */

Have you actually seen a difference if the function is inlined?

> +#define bm_buffer_set64(buf, v) \
> +	do { \
> +		struct bm_buffer *__buf931 = (buf); \
> +		__buf931->hi = upper_32_bits(v); \
> +		__buf931->lo = lower_32_bits(v); \
> +	} while (0)

931?

What type is "buf" supposed to be?

> +/* See 1.5.3.5.4: "Release Command" */
> +struct bm_rcr_entry {
> +	union {
> +		struct {
> +			u8 __dont_write_directly__verb;
> +			u8 bpid; /* used with BM_RCR_VERB_CMD_BPID_SINGLE */
> +			u8 __reserved1[62];
> +		};
> +		struct bm_buffer bufs[8];
> +	};
> +} __packed;
> +#define BM_RCR_VERB_VBIT		0x80
> +#define BM_RCR_VERB_CMD_MASK		0x70	/* one of two values; */
> +#define BM_RCR_VERB_CMD_BPID_SINGLE	0x20
> +#define BM_RCR_VERB_CMD_BPID_MULTI	0x30
> +#define BM_RCR_VERB_BUFCOUNT_MASK	0x0f	/* values 1..8 */
> +
> +/* See 1.5.3.1: "Acquire Command" */
> +/* See 1.5.3.2: "Query Command" */

1.5.3.1 of what document?  In DPAARM that's "FMan Network Interfaces".

-Scott
