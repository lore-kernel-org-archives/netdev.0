From: "David S. Miller" <davem@redhat.com>
Subject: Re: do_gettimeofday
Date: Fri, 3 Oct 2003 00:41:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003004133.3148c39a.davem@redhat.com>
References: <3F7C6F3B.6070502@sgi.com>
	<20031002125625.72b8c0a7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: modica@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031002125625.72b8c0a7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2 Oct 2003 12:56:25 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> It might be possible to introduce a per-cpu monotonic clock that is lockless
> for use in network code, but that is a moderately painful undertaking which
> is beyond the scope of getting 2.6.0 out.

Yes, this issue is well known and it gets brought up again from time
to time.

And it's by no means just SO_TIMESTAMP that uses the skb->stamp
values, even IPV4/IPV6 fragmentation uses these things.

The SunRPC and RXRPC layers use it as well.

It really is an arch-specific issue of how to "optimize" this the
best, that's why it's hard to decide what the interface is that an
arch needs to provide.

But at the base I say we need three things:

1) Some kind of fast_timestamp_t, the property is that this stores
   enough information at time "T" such that at time "T + something"
   the fast_timestamp_t can be converted what the timeval was back at
   time "T".

   For networking, make skb->stamp into this type.

2) store_fast_timestamp(fast_timestamp_t *)

   For networking, change do_gettimeofday(&skb->stamp) into
   store_fast_timestamp(&skb->stamp)

3) fast_timestamp_to_timeval(arch_timestamp_t *, struct timeval *)

   For networking, change things that read the skb->stamp value
   into calls to fast_timestamp_to_timeval().

It is defined that the timeval given by fast_timestamp_to_timeval()
needs to be the same thing that do_gettimeofday() would have recorded
at the time store_fast_timestamp() was called.

Here is the default generic implementation that would go into
asm-generic/faststamp.h:

1) fast_timestamp_t is struct timeval
2) store_fast_timestamp() is gettimeofday()
3) fast_timestamp_to_timeval() merely copies the fast_timestamp_t
   into the passed in timeval.

And here is how an example implementation could work on sparc64:

1) fast_timestamp_t is a u64

2) store_fast_timestamp() reads the cpu cycle counter

3) fast_timestamp_to_timeval() records the difference between the
   current cpu cycle counter and the one recorded, it takes a sample
   of the current xtime value and adjusts it accordingly to account
   for the cpu cycle counter difference.

This only works because sparc64's cpu cycle counters are synchronized
across all cpus, they increase monotonically, and are guarenteed not
to overflow for at least 10 years.

Alpha, for example, cannot do it this way because it's cpu cycle counter
register overflows too quickly to be useful.

Platforms with inter-cpu TSC synchronization issues will have some
troubles doing the same trick too, because one must handle properly
the case where the fast timestamp is converted to a timeval on a different
cpu on which the fast timestamp was recorded.

Regardless, we could put the infrastructure in there now and arch folks
can work on implementations.  The generic implementation code, which is
what everyone will end up with at first, will cancel out to what we have
currently.

This is a pretty powerful idea that could be applied to other places,
not just the networking.
