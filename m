From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3 net-next] net: filter: cleanup sk_* and bpf_* names
Date: Tue, 29 Jul 2014 17:31:24 +0200
Message-ID: <20140729153124.GA3231@salvia>
References: <1406615380-3488-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1406615380-3488-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2014 at 11:29:40PM -0700, Alexei Starovoitov wrote:
> clean up names related to socket filtering and bpf in the following way:
> - everything that deals with sockets keeps 'sk_*' prefix
> - everything that is pure BPF is changed to 'bpf_*' prefix
> 
> API for attaching classic BPF to a socket stays the same:
> sk_attach_filter()/sk_detach_filter()
> and SK_RUN_FILTER() to execute a program
> 
> API for 'unattached' BPF programs becomes:
> bpf_prog_create()/bpf_prog_destroy()
> and BPF_PROG_RUN() to execute a program
> 
> Introduce callback mechanism for 'struct sk_filter', so that different
> filtering engines can be used in the future (as requested by Pablo)
> 
> Socket charging logic was complicated, since we had to charge/uncharge a socket
> multiple times while preparing a filter. Simplify it by fully preparing bpf
> program (through classic->ebpf conversion and JITing) and then charge
> the socket memory once.

This includes many changes in one single shot. This needs to be
splitted in smaller patches that can be reviewed separately, that
makes it easier to others to follow track and spot things.  On top of
that, we should also take the time to make sure what is already in
place is correct, this is a good chance to go over the existing code,
review it and make small changes to accomodate the generic
infrastructure that should follow up.

Now below the more specific comments.

> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
[...]
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 20dd50ef7271..448fdd193cdf 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -296,7 +296,7 @@ enum {
>  })
>  
>  /* Macro to invoke filter function. */
> -#define SK_RUN_FILTER(filter, ctx)  (*filter->bpf_func)(ctx, filter->insnsi)
> +#define SK_RUN_FILTER(filter, ctx)  (*filter->run)(ctx, filter)
>  
>  struct bpf_insn {
>  	__u8	code;		/* opcode */
> @@ -323,12 +323,11 @@ struct sk_buff;
>  struct sock;
>  struct seccomp_data;
>  
> -struct sk_filter {
> -	atomic_t		refcnt;
> +struct bpf_prog {
>  	u32			jited:1,	/* Is our filter JIT'ed? */
>  				len:31;		/* Number of filter blocks */
>  	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
> -	struct rcu_head		rcu;
> +	struct rcu_head		rcu;		/* used by 'unattached' progs */

This rcu_head for unattached filters can be avoided, I'll send a
follow up patch for this. After that patch, refcnt and rcu_head can go
out from bpf_prog.

> -#define sk_filter_proglen(fprog)			\
> -		(fprog->len * sizeof(fprog->filter[0]))
> +struct sk_filter {
> +	atomic_t refcnt;
> +	struct rcu_head rcu;
> +	u32 filter_size;
> +	union {
> +		struct bpf_prog *prog;
> +	};
> +	void (*release)(struct sk_filter *fp);
> +	int (*get_filter)(struct sk_filter *fp, void **prog, unsigned int *len);
> +	unsigned int (*run)(const struct sk_buff *skb, struct sk_filter *fp);

I don't think this is the right moment to add this, but we have to
keep in mind that something similar to this will need to be
accomodated in struct sk_filter at some point to avoid sloppy changes
that may result in reintroducing code later on.

Next step should be to wrap the specific bpf fields in struct
bpf_prog in some clean way IMO, which was partially the aim of this
patch.

Thanks.
