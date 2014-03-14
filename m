From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v10 net-next 1/3] filter: add Extended BPF interpreter
 and converter
Date: Fri, 14 Mar 2014 13:58:22 +0100
Message-ID: <20140314125822.GA16457@localhost>
References: <1394660614-4436-1-git-send-email-ast@plumgrid.com>
 <1394660614-4436-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394660614-4436-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 02:43:32PM -0700, Alexei Starovoitov wrote:
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index e568c8ef896b..6e6aab5e062b 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -25,20 +25,45 @@ struct sock;
>  struct sk_filter
>  {
>  	atomic_t		refcnt;
> -	unsigned int         	len;	/* Number of filter blocks */
> +	/* len - number of insns in sock_filter program
> +	 * len_ext - number of insns in socket_filter_ext program
> +	 * jited - true if either original or extended program was JITed
> +	 * orig_prog - original sock_filter program if not NULL
> +	 */
> +	unsigned int		len;
> +	unsigned int		len_ext;
> +	unsigned int		jited:1;

This is consuming 4 bytes just to store the jited bit. I think you can
scratch that bit from len, given the maximum filter length for bpf. I
think the the jited bit change that David suggested have to come in
first place as a separated patch in the series.

> +	struct sock_filter	*orig_prog;

If your new extended filtering is not used, this consumes 8 extra
bytes + len_ext (bytes) in x86_64. I think a more generic way to make
this is that you can move the original bpf filter and its length at
the bottom of this structure after insns to store something like:

struct sk_bpf_compat {
        struct sock_filter      *prog;
        unsigned int            len;
};

This would be only allocated when you filtering approach is used. For
that you'll need some enum in sk_filter to indicate the filtering
approach, but we'll save 8 bytes per filter in the end with regards to
this current patch.

>  	struct rcu_head		rcu;
> -	unsigned int		(*bpf_func)(const struct sk_buff *skb,
> -					    const struct sock_filter *filter);
> +	union {
> +		unsigned int (*bpf_func)(const struct sk_buff *skb,
> +					 const struct sock_filter *fp);
> +		unsigned int (*bpf_func_ext)(const struct sk_buff *skb,
> +					     const struct sock_filter_ext *fp);
> +	};
>  	union {
>  		struct sock_filter     	insns[0];
> +		struct sock_filter_ext	insns_ext[0];
>  		struct work_struct	work;
>  	};
>  };
>  
