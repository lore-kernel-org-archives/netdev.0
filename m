From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Sat, 14 Mar 2015 12:13:25 +0100
Message-ID: <20150314111325.GG14761@breakpoint.cc>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
 <20150309130253.GA6677@salvia>
 <20150309135910.GC1528@breakpoint.cc>
 <20150314090035.GA3561@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150314090035.GA3561@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > We cannot use percpu data for nf_bridge_info; at least its not trivial
> > to do (I tried).
> > 
> > Main issues are:
> > - nfqueue (we have to save/restore info)
> > - local delivery (skb is enqueued in backlog)
> > - skb is dropped (we need to reset scratch data)
> > - DNAT mac hack (skb can be queued in qdisc).

The DNAT mac hack is no longer an issue, can be handled via skb->cb.

> What about something like this?
> 
> 1) We keep a nf_bridge table that contains the nf_bridge structures
>    that are currently in used, so you can look it up for them every
>    time we need it. This can be implemented as a per-cpu list of
>    nf_bridge structures.

Not sure if it can be percpu.  In particular, when we pass frame up
skb can be enqueud in backlog, also we might encounter ingress scheduler
so I am not sure that skb cannot move to another cpu.

> 2) We have another per-cpu cache to hold a pointer to the current
>    nf_bridge.
> 
> 3) We only need one bit from sk_buff to indicate that this sk_buff has
>    nf_bridge info attached.

Yes, the "put it in skb->cb" also uses this approach, it puts 2bit
"state" information into skb and then removes the pointer.

> Then, we can use the sk_buff pointer as an unique way to identify
> the owner of the nf_bridge structure.
> 
>    struct nf_bridge {
>         struct list_head        head;
>         const struct sk_buff    *owner;
>         ...
>    }
> 
> so if we need the scratchpad area, we first have to look up for it:
> 
>    struct nf_bridge *nf_bridge_find(struct sk_buff *skb)
>    {
>         ...
> 
>         /* First, check if we have it in the per_cpu cache. */
>         nf_bridge = per_cpu_ptr(nf_bridge_pcpu);
>         if (nf_bridge->owner == skb)
>             return nf_bridge;
> 
>         /* Otherwise, slow path: find this scratchpad area in the list. */
>         ...
>         nf_bridge_list = per_cpu_ptr(nf_bridge_pcpu_list);
>         list_for_each_entry(n, &nf_bridge_list, head) {
>             if (nf_bridge->owner == skb) {
>                 /* Update the per_cpu cache. */
>                 rcu_assign_pointer(nf_bridge, n);
>                 return nf_bridge;
>             }
>         }
> 
>         return NULL;
>    }

Ok, I see.  This would work, but I'd prefer to just use the skb control
buffer.

> I'm proposing this because I have concerns with the approach to place
> nf_bridge in skb->cb. This br_netfilter thing makes the skb go back
> and forth from different layers while expecting to find the right
> right data in it, this seems fragile to me.

Mhhh, for the *usual* case of "skb is forwarded by bridge" skb->cb
should be safe since we only move skb between bridge and inet(6).

The only "problematic" case is where skb is DNAT'd, then things get
hairy (e.e.g dnat-to-host-on-other device).

> What do you think?

I think that currently it doesn't matter what solution we'll pick in the
end, I'd first like to send all my refactoring patches.

With those patches, it reduces the nf_bridge_info content that we need
to the physin and physout devices, plus a two-bit state in skb.

Then, if you still think that ->cb is too fragile I'd be happy to add
the lookup table method.  For the normal case of bridge forwarding, it
shouldn't be needed though, perhaps we could also use a hybrid approach,
cb-based fastpath for forwarding, lookup-table slowpath for dnat and
local delivery cases.

One other solution would be to use skb->cb but not store bridge device
pointers but the ifindexes instead (we currently don't hold any
device refcounts either so the current method isn't 100% safe either since
such device can be removed ...).

