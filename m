From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: do_gettimeofday
Date: Fri, 3 Oct 2003 01:26:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003082642.GF42593@gaz.sfgoth.com>
References: <3F7C6F3B.6070502@sgi.com> <20031002125625.72b8c0a7.shemminger@osdl.org> <20031003004133.3148c39a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031003004133.3148c39a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> 3) fast_timestamp_to_timeval(arch_timestamp_t *, struct timeval *)
> 
>    For networking, change things that read the skb->stamp value
>    into calls to fast_timestamp_to_timeval().

Are there any common cases where skb->stamp is looked at more than
once?  If so I might recommend changing the API to be more like:

	const struct timeval *skb_timestamp(struct skbuff *skb);

where the generic form would just be:

	typedef struct {
		struct timeval tv;
	} fast_timestamp_t;

	static inline const struct timeval *skb_timestamp(struct skbuff *skb) {
		return &skb->faststamp.tv;
	}

...but an arch could accelerate it with:

	typedef struct {
		union {
			struct timeval tv;
			u64 tsc;
		}
		int is_converted;
	} fast_timestamp_t;

	/* Caller must be sure we have exclusive ownership of this skbuff */
	const struct timeval *skb_timestamp(struct skbuff *skb) {
		if (!skb->faststamp.is_converted) {
			tsc_to_timeval(&skb->faststamp.tv, skb->faststamp.tsc);
			skb->faststamp.is_converted = 1;
		}
		return &skb->faststamp.tv;
	}

If we could hide "is_converted" as a flag somewhere else this would have zero
storage penalty (since most archs would have a fast-stamp at least
as big as a timeval)

I dunno, just an idea.

> Platforms with inter-cpu TSC synchronization issues will have some
> troubles doing the same trick too, because one must handle properly
> the case where the fast timestamp is converted to a timeval on a different
> cpu on which the fast timestamp was recorded.

Yeah, you'd probably have something like

	typedef struct {
		union {
			struct timeval tv;
			struct {
				u64 tsc;
#ifdef CONFIG_SMP
				unsigned int cpu_id;
#endif /* CONFIG_SMP */
			} fast;
		}
		int is_converted;
	} fast_timestamp_t;

And then skb_timestamp() would have to rummage around in the per-cpu timer
state for whatever processor started the packet.  (This is why I thought
it might be good to cache the result - you don't want to thrash those
cachelines more than once if you can help it)

-Mitch
