From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: Mon, 4 Oct 2004 01:36:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003233647.GN14344@postel.suug.ch>
References: <20041003213124.GG14344@postel.suug.ch> <20041003213954.GI14344@postel.suug.ch> <20041003161436.50293f9a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041003161436.50293f9a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20041003161436.50293f9a.davem@davemloft.net> 2004-10-03 16:14
> On Sun, 3 Oct 2004 23:39:54 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > Introduces a generic rate estimator based on timers. Patch is based on
> > Jamal's patch and adapted to the new generic network statistics API.
> 
> First, how does this new thing ever get built into the tree?

Once we converted all Qdiscs to use the new splitted up stats structs
we can replace all calls to qdisc_new_estimator with gen_new_estimator.

I already have a patch in my tree which does this but I want to test it
a little longer before submitting it. It also involves a change to
struct Qdisc and Qdisc_ops which means that we break all qdiscs not
in the tree. Is this acceptable?

Benefit would be:
No compatibility mess anymore when introducing new stats for both,
all qdiscs or just a single one.

> > +#if (HZ%4) != 0
> > +#error Bad HZ value.
> > +#endif
> 
> This is going to fail to compile on a few platforms, namely m68knommu
> and v850 which have configurations that result in using a HZ value
> of 50 and 122 respectively.

This was taken over from net/sched/estimator.c so I guess there was no
person ever using the rate estimator on such an arch ;)

Can we simply remove the check?

> +int
> +gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
> +	int xstats_type, spinlock_t *lock, struct gnet_dump *d)
> +{
>  ...
> +	return gnet_stats_copy(d, type, NULL, 0);
> 
> What is this dummy zero-sized RTA_PUT() being done for
> (via the gnet_stats_copy() call with size==0 arg)?

It allocates space for the TLV header in the skb, will result in an
empty header. Nested TLVs are appened to it and the header is filled out
afterwards once the size of all nested TLVs are known.
