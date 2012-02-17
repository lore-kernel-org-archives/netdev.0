From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v8 1/8] sk_run_filter: add support for custom
 load_pointer
Date: Fri, 17 Feb 2012 04:04:35 +0100
Message-ID: <a5e0a6a86bb8a20919b9ae80fd510e46.squirrel@webmail.greenhost.nl>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.org,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org,
	"Will Drewry" <wad@chromium.org>
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1329422549-16407-1-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, February 16, 2012 21:02, Will Drewry wrote:
> This change allows CONFIG_SECCOMP to make use of BPF programs for
> user-controlled system call filtering (as shown in this patch series).
>
> To minimize the impact on existing BPF evaluation, function pointer
> use must be declared at sk_chk_filter-time.  This allows ancillary
> load instructions to be generated that use the function pointer rather
> than adding _any_ code to the existing LD_* instruction paths.
>
> Crude performance numbers using udpflood -l 10000000 against dummy0.
> 3 trials for baseline, 3 for with tcpdump. Averaged then differenced.
> Hard to believe trials were repeated at least a couple more times.
>
> * x86 32-bit (Atom N570 @ 1.66 GHz 2 core HT) [stackprot]:
> - Without:  94.05s - 76.36s = 17.68s
> - With:     86.22s - 73.30s = 12.92s
> - Slowdown per call: -476 nanoseconds
>
> * x86 32-bit (Atom N570 @ 1.66 GHz 2 core HT) [no stackprot]:
> - Without:  92.06s - 77.81s = 14.25s
> - With:     91.77s - 76.91s = 14.86s
> - Slowdown per call: +61 nanoseconds
>
> * x86 64-bit (Atom N570 @ 1.66 GHz 2 core HT) [stackprot]:
> - Without: 122.58s - 99.54s = 23.04s
> - With:    115.52s - 98.99s = 16.53s
> - Slowdown per call:  -651 nanoseconds
>
> * x86 64-bit (Atom N570 @ 1.66 GHz 2 core HT) [no stackprot]:
> - Without: 114.95s - 91.92s = 23.03s
> - With:    110.47s - 90.79s = 19.68s
> - Slowdown per call: -335 nanoseconds
>
> This makes the x86-32-nossp make sense.  Added register pressure always
> makes x86-32 sad.

Your 32-bit numbers are better than your 64-bit numbers, so I don't get
this comment.

> If this is a concern, I could change the call
> approach to bpf_run_filter to see if I can alleviate it a bit.
>
> That said, the x86-*-ssp numbers show a marked increase in performance.
> I've tested and retested and I keep getting these results. I'm also
> suprised by the nossp speed up on 64-bit, but I dunno. I haven't looked
> at the full disassembly of the call path. If that is required for the
> performance differences I'm seeing, please let me know. Or if I there is
> a preferred cpu to run this against - atoms can be a little weird.

Yeah, testing on Atom is a bit silly.

> v8: - fixed variable positioning and bad cast (eric.dumazet@gmail.com)
>     - no longer passes A as a pointer (inspection of x86 asm shows A is
>       %ebx again; thanks eric.dumazet@gmail.com)
>     - cleaned up switch macros and expanded use
>       (joe@perches.com, indan@nul.nu)
>     - added length fn pointer and handled LD_W_LEN/LDX_W_LEN
>     - moved from a wrapping struct to a typedef for the function
>       pointer. (matches existing function pointer style)
>     - added comprehensive comment above the typedef.
>     - benchmarks
> v7: - first cut
>
> Signed-off-by: Will Drewry <wad@chromium.org>
> ---
>  include/linux/filter.h |   69 +++++++++++++++++++++-
>  net/core/filter.c      |  152 +++++++++++++++++++++++++++++++++++++----------
>  2 files changed, 185 insertions(+), 36 deletions(-)
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 8eeb205..d22ad46 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -110,6 +110,9 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>   */
>  #define BPF_MEMWORDS 16
>
> +/* BPF program (checking) flags */
> +#define BPF_CHK_FLAGS_NO_SKB	1
> +
>  /* RATIONALE. Negative offsets are invalid in BPF.
>     We use them to reference ancillary data.
>     Unlike introduction new instructions, it does not break
> @@ -145,17 +148,67 @@ struct sk_filter
>  	struct sock_filter     	insns[0];
>  };
>
> +/**
> + * struct bpf_load_fns - callbacks for bpf_run_filter
> + * These functions are called by bpf_run_filter if bpf_chk_filter
> + * was invoked with BPF_CHK_FLAGS_NO_SKB.
> + *
> + * pointer:
> + * @data: const pointer to the data passed into bpf_run_filter
> + * @k: offset into @skb's data
> + * @size: the size of the requested data in bytes: 1, 2, or 4.
> + * @buffer: If non-NULL, a 32-bit buffer for staging data.
> + *
> + * Returns a pointer to the requested data.
> + *
> + * This function operates similarly to load_pointer in net/core/filter.c
> + * except that the pointer to the returned data must already be
> + * byteswapped as appropriate to the source data and endianness.
> + * @buffer may be used if the data needs to be staged.
> + *
> + * length:
> + * @data: const pointer to the data passed into bpf_fun_filter
> + *
> + * Returns the length of the data.
> + */
> +struct bpf_load_fns {
> +	void *(*pointer)(const void *data, int k, unsigned int size,
> +			 void *buffer);
> +	u32 (*length)(const void *data);
> +};

Like I said in the other email, length is useless for the non-skb case.
If you really want to add it, just make it a constant. And 'pointer' isn't
the best name.

> +
>  static inline unsigned int sk_filter_len(const struct sk_filter *fp)
>  {
>  	return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
>  }
>
> +extern unsigned int bpf_run_filter(const void *data,
> +				   const struct sock_filter *filter,
> +				   const struct bpf_load_fns *load_fn);
> +
> +/**
> + *	sk_run_filter - run a filter on a socket
> + *	@skb: buffer to run the filter on
> + *	@fentry: filter to apply
> + *
> + * Runs bpf_run_filter with the struct sk_buff-specific data
> + * accessor behavior.
> + */
> +static inline unsigned int sk_run_filter(const struct sk_buff *skb,
> +					 const struct sock_filter *filter)
> +{
> +	return bpf_run_filter(skb, filter, NULL);
> +}
> +
>  extern int sk_filter(struct sock *sk, struct sk_buff *skb);
> -extern unsigned int sk_run_filter(const struct sk_buff *skb,
> -				  const struct sock_filter *filter);
>  extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
>  extern int sk_detach_filter(struct sock *sk);
> -extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
> +extern int bpf_chk_filter(struct sock_filter *filter, unsigned int flen, u32 flags);
> +
> +static inline int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
> +{
> +	return bpf_chk_filter(filter, flen, 0);
> +}
>
>  #ifdef CONFIG_BPF_JIT
>  extern void bpf_jit_compile(struct sk_filter *fp);
> @@ -228,6 +281,16 @@ enum {
>  	BPF_S_ANC_HATYPE,
>  	BPF_S_ANC_RXHASH,
>  	BPF_S_ANC_CPU,
> +	/* Used to differentiate SKB data and generic data */
> +	BPF_S_ANC_LD_W_ABS,
> +	BPF_S_ANC_LD_H_ABS,
> +	BPF_S_ANC_LD_B_ABS,
> +	BPF_S_ANC_LD_W_LEN,
> +	BPF_S_ANC_LD_W_IND,
> +	BPF_S_ANC_LD_H_IND,
> +	BPF_S_ANC_LD_B_IND,
> +	BPF_S_ANC_LDX_W_LEN,
> +	BPF_S_ANC_LDX_B_MSH,
>  };
>
>  #endif /* __KERNEL__ */
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 5dea452..a5c98a9 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -98,9 +98,10 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
>  EXPORT_SYMBOL(sk_filter);
>
>  /**
> - *	sk_run_filter - run a filter on a socket
> - *	@skb: buffer to run the filter on
> + *	bpf_run_filter - run a filter on a BPF program

The filter is the BPF program, so this comment is weird.

> + *	@data: buffer to run the filter on
>   *	@fentry: filter to apply
> + *	@load_fns: custom data accessor functions
>   *
>   * Decode and apply filter instructions to the skb->data.
>   * Return length to keep, 0 for none. @skb is the data we are
> @@ -108,9 +109,13 @@ EXPORT_SYMBOL(sk_filter);
>   * Because all jumps are guaranteed to be before last instruction,
>   * and last instruction guaranteed to be a RET, we dont need to check
>   * flen. (We used to pass to this function the length of filter)
> + *
> + * load_fn is only used if SKF_FLAGS_USE_LOAD_FNS was specified
> + * to sk_chk_generic_filter.

Stale comment.

>   */
> -unsigned int sk_run_filter(const struct sk_buff *skb,
> -			   const struct sock_filter *fentry)
> +unsigned int bpf_run_filter(const void *data,
> +			    const struct sock_filter *fentry,
> +			    const struct bpf_load_fns *load_fns)
>  {
>  	void *ptr;
>  	u32 A = 0;			/* Accumulator */
> @@ -128,6 +133,7 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
>  #else
>  		const u32 K = fentry->k;
>  #endif
> +#define SKB(_data) ((const struct sk_buff *)(_data))

Urgh!

If you had done:
		const struct sk_buff *skb = data;

at the top, all those changed wouldn't be needed and it would look better too.

>
>  		switch (fentry->code) {
>  		case BPF_S_ALU_ADD_X:
> @@ -213,7 +219,7 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
>  		case BPF_S_LD_W_ABS:
>  			k = K;
>  load_w:
> -			ptr = load_pointer(skb, k, 4, &tmp);
> +			ptr = load_pointer(data, k, 4, &tmp);
>  			if (ptr != NULL) {
>  				A = get_unaligned_be32(ptr);
>  				continue;
> @@ -222,7 +228,7 @@ load_w:
>  		case BPF_S_LD_H_ABS:
>  			k = K;
>  load_h:
> -			ptr = load_pointer(skb, k, 2, &tmp);
> +			ptr = load_pointer(data, k, 2, &tmp);
>  			if (ptr != NULL) {
>  				A = get_unaligned_be16(ptr);
>  				continue;
> @@ -231,17 +237,17 @@ load_h:
>  		case BPF_S_LD_B_ABS:
>  			k = K;
>  load_b:
> -			ptr = load_pointer(skb, k, 1, &tmp);
> +			ptr = load_pointer(data, k, 1, &tmp);
>  			if (ptr != NULL) {
>  				A = *(u8 *)ptr;
>  				continue;
>  			}
>  			return 0;
>  		case BPF_S_LD_W_LEN:
> -			A = skb->len;
> +			A = SKB(data)->len;
>  			continue;
>  		case BPF_S_LDX_W_LEN:
> -			X = skb->len;
> +			X = SKB(data)->len;
>  			continue;
>  		case BPF_S_LD_W_IND:
>  			k = X + K;
> @@ -253,7 +259,7 @@ load_b:
>  			k = X + K;
>  			goto load_b;
>  		case BPF_S_LDX_B_MSH:
> -			ptr = load_pointer(skb, K, 1, &tmp);
> +			ptr = load_pointer(data, K, 1, &tmp);
>  			if (ptr != NULL) {
>  				X = (*(u8 *)ptr & 0xf) << 2;
>  				continue;
> @@ -288,29 +294,29 @@ load_b:
>  			mem[K] = X;
>  			continue;
>  		case BPF_S_ANC_PROTOCOL:
> -			A = ntohs(skb->protocol);
> +			A = ntohs(SKB(data)->protocol);
>  			continue;
>  		case BPF_S_ANC_PKTTYPE:
> -			A = skb->pkt_type;
> +			A = SKB(data)->pkt_type;
>  			continue;
>  		case BPF_S_ANC_IFINDEX:
> -			if (!skb->dev)
> +			if (!SKB(data)->dev)
>  				return 0;
> -			A = skb->dev->ifindex;
> +			A = SKB(data)->dev->ifindex;
>  			continue;
>  		case BPF_S_ANC_MARK:
> -			A = skb->mark;
> +			A = SKB(data)->mark;
>  			continue;
>  		case BPF_S_ANC_QUEUE:
> -			A = skb->queue_mapping;
> +			A = SKB(data)->queue_mapping;
>  			continue;
>  		case BPF_S_ANC_HATYPE:
> -			if (!skb->dev)
> +			if (!SKB(data)->dev)
>  				return 0;
> -			A = skb->dev->type;
> +			A = SKB(data)->dev->type;
>  			continue;
>  		case BPF_S_ANC_RXHASH:
> -			A = skb->rxhash;
> +			A = SKB(data)->rxhash;
>  			continue;
>  		case BPF_S_ANC_CPU:
>  			A = raw_smp_processor_id();
> @@ -318,15 +324,15 @@ load_b:
>  		case BPF_S_ANC_NLATTR: {
>  			struct nlattr *nla;
>
> -			if (skb_is_nonlinear(skb))
> +			if (skb_is_nonlinear(SKB(data)))
>  				return 0;
> -			if (A > skb->len - sizeof(struct nlattr))
> +			if (A > SKB(data)->len - sizeof(struct nlattr))
>  				return 0;
>
> -			nla = nla_find((struct nlattr *)&skb->data[A],
> -				       skb->len - A, X);
> +			nla = nla_find((struct nlattr *)&SKB(data)->data[A],
> +				       SKB(data)->len - A, X);
>  			if (nla)
> -				A = (void *)nla - (void *)skb->data;
> +				A = (void *)nla - (void *)SKB(data)->data;
>  			else
>  				A = 0;
>  			continue;
> @@ -334,22 +340,71 @@ load_b:
>  		case BPF_S_ANC_NLATTR_NEST: {
>  			struct nlattr *nla;
>
> -			if (skb_is_nonlinear(skb))
> +			if (skb_is_nonlinear(SKB(data)))
>  				return 0;
> -			if (A > skb->len - sizeof(struct nlattr))
> +			if (A > SKB(data)->len - sizeof(struct nlattr))
>  				return 0;
>
> -			nla = (struct nlattr *)&skb->data[A];
> -			if (nla->nla_len > A - skb->len)
> +			nla = (struct nlattr *)&SKB(data)->data[A];
> +			if (nla->nla_len > A - SKB(data)->len)
>  				return 0;
>
>  			nla = nla_find_nested(nla, X);
>  			if (nla)
> -				A = (void *)nla - (void *)skb->data;
> +				A = (void *)nla - (void *)SKB(data)->data;
>  			else
>  				A = 0;
>  			continue;
>  		}

All changes up to here are unnecessary.

> +		case BPF_S_ANC_LD_W_ABS:
> +			k = K;
> +load_fn_w:
> +			ptr = load_fns->pointer(data, k, 4, &tmp);
> +			if (ptr) {
> +				A = *(u32 *)ptr;
> +				continue;
> +			}
> +			return 0;
> +		case BPF_S_ANC_LD_H_ABS:
> +			k = K;
> +load_fn_h:
> +			ptr = load_fns->pointer(data, k, 2, &tmp);
> +			if (ptr) {
> +				A = *(u16 *)ptr;
> +				continue;
> +			}
> +			return 0;
> +		case BPF_S_ANC_LD_B_ABS:
> +			k = K;
> +load_fn_b:
> +			ptr = load_fns->pointer(data, k, 1, &tmp);
> +			if (ptr) {
> +				A = *(u8 *)ptr;
> +				continue;
> +			}
> +			return 0;
> +		case BPF_S_ANC_LDX_B_MSH:
> +			ptr = load_fns->pointer(data, K, 1, &tmp);
> +			if (ptr) {
> +				X = (*(u8 *)ptr & 0xf) << 2;
> +				continue;
> +			}
> +			return 0;
> +		case BPF_S_ANC_LD_W_IND:
> +			k = X + K;
> +			goto load_fn_w;
> +		case BPF_S_ANC_LD_H_IND:
> +			k = X + K;
> +			goto load_fn_h;
> +		case BPF_S_ANC_LD_B_IND:
> +			k = X + K;
> +			goto load_fn_b;
> +		case BPF_S_ANC_LD_W_LEN:
> +			A = load_fns->length(data);
> +			continue;
> +		case BPF_S_ANC_LDX_W_LEN:
> +			X = load_fns->length(data);

These two should either return 0, be networking-only, just return 0/-1 or
use a constant length.

> +			continue;
>  		default:
>  			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
>  				       fentry->code, fentry->jt,
> @@ -360,7 +415,7 @@ load_b:
>
>  	return 0;
>  }
> -EXPORT_SYMBOL(sk_run_filter);
> +EXPORT_SYMBOL(bpf_run_filter);
>
>  /*
>   * Security :
> @@ -423,9 +478,10 @@ error:
>  }
>
>  /**
> - *	sk_chk_filter - verify socket filter code
> + *	bpf_chk_filter - verify socket filter BPF code
>   *	@filter: filter to verify
>   *	@flen: length of filter
> + *	@flags: May be BPF_CHK_FLAGS_NO_SKB or 0
>   *
>   * Check the user's filter code. If we let some ugly
>   * filter code slip through kaboom! The filter must contain
> @@ -434,9 +490,13 @@ error:
>   *
>   * All jumps are forward as they are not signed.
>   *
> + * If BPF_CHK_FLAGS_NO_SKB is set in flags, any SKB-specific
> + * rules become illegal and a custom set of bpf_load_fns will
> + * be expected by bpf_run_filter.
> + *
>   * Returns 0 if the rule set is legal or -EINVAL if not.
>   */
> -int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
> +int bpf_chk_filter(struct sock_filter *filter, unsigned int flen, u32 flags)
>  {
>  	/*
>  	 * Valid instructions are initialized to non-0.
> @@ -542,9 +602,35 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>  			    pc + ftest->jf + 1 >= flen)
>  				return -EINVAL;
>  			break;
> +#define MAYBE_USE_LOAD_FN(CODE) \
> +			if (flags & BPF_CHK_FLAGS_NO_SKB) { \
> +				code = BPF_S_ANC_##CODE; \
> +				break; \
> +			}

You can as well hide everything in the macro then, including the case,
like the ANCILLARY() macro does.

> +		case BPF_S_LD_W_LEN:
> +			MAYBE_USE_LOAD_FN(LD_W_LEN);
> +			break;
> +		case BPF_S_LDX_W_LEN:
> +			MAYBE_USE_LOAD_FN(LDX_W_LEN);
> +			break;
> +		case BPF_S_LD_W_IND:
> +			MAYBE_USE_LOAD_FN(LD_W_IND);
> +			break;
> +		case BPF_S_LD_H_IND:
> +			MAYBE_USE_LOAD_FN(LD_H_IND);
> +			break;
> +		case BPF_S_LD_B_IND:
> +			MAYBE_USE_LOAD_FN(LD_B_IND);
> +			break;
> +		case BPF_S_LDX_B_MSH:
> +			MAYBE_USE_LOAD_FN(LDX_B_MSH);
> +			break;
>  		case BPF_S_LD_W_ABS:
> +			MAYBE_USE_LOAD_FN(LD_W_ABS);
>  		case BPF_S_LD_H_ABS:
> +			MAYBE_USE_LOAD_FN(LD_H_ABS);
>  		case BPF_S_LD_B_ABS:
> +			MAYBE_USE_LOAD_FN(LD_B_ABS);
>  #define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE:	\
>  				code = BPF_S_ANC_##CODE;	\
>  				break
> @@ -572,7 +658,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>  	}
>  	return -EINVAL;
>  }
> -EXPORT_SYMBOL(sk_chk_filter);
> +EXPORT_SYMBOL(bpf_chk_filter);
>
>  /**
>   * 	sk_filter_release_rcu - Release a socket filter by rcu_head
> --
> 1.7.5.4
>

Greetings,

Indan
