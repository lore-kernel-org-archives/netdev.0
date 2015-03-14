From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Sat, 14 Mar 2015 10:00:35 +0100
Message-ID: <20150314090035.GA3561@salvia>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
 <20150309130253.GA6677@salvia>
 <20150309135910.GC1528@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150309135910.GC1528@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 09, 2015 at 02:59:10PM +0100, Florian Westphal wrote:
> Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > > nf_bridge is kmalloced blob with some extra information, including
> > > the bridge in and outports (mainly for iptables' physdev match).
> > > It also has various state bits so we know what manipulations
> > > have been performed by bridge netfilter on the skb (e.g.
> > > ppp header stripping).
> > >
> > > nf_bridge also provides scratch space where br_netfilter saves
> > > (and later restores) various things, e.g. ipv4 address for
> > > dnat detection, mac address to fix up ip fragmented skbs, etc.
> > > 
> > > But in almost all cases we can avoid using ->data completely.
> > 
> > I think one of the goals of this patchset is to prepare the removal of
> > that nf_bridge pointer from sk_buff which sounds as a good idea to me.
> > 
> > Did you consider to implement this scratchpad area using a per-cpu
> > area? I mean, something similar to what we used to have in
> > ip_conntrack for events:
> 
> I see that I misread part of what you wrote.
> 
> We cannot use percpu data for nf_bridge_info; at least its not trivial
> to do (I tried).
> 
> Main issues are:
> - nfqueue (we have to save/restore info)
> - local delivery (skb is enqueued in backlog)
> - skb is dropped (we need to reset scratch data)
> - DNAT mac hack (skb can be queued in qdisc).

What about something like this?

1) We keep a nf_bridge table that contains the nf_bridge structures
   that are currently in used, so you can look it up for them every
   time we need it. This can be implemented as a per-cpu list of
   nf_bridge structures.

2) We have another per-cpu cache to hold a pointer to the current
   nf_bridge.

3) We only need one bit from sk_buff to indicate that this sk_buff has
   nf_bridge info attached.

Then, we can use the sk_buff pointer as an unique way to identify
the owner of the nf_bridge structure.

   struct nf_bridge {
        struct list_head        head;
        const struct sk_buff    *owner;
        ...
   }

so if we need the scratchpad area, we first have to look up for it:

   struct nf_bridge *nf_bridge_find(struct sk_buff *skb)
   {
        ...

        /* First, check if we have it in the per_cpu cache. */
        nf_bridge = per_cpu_ptr(nf_bridge_pcpu);
        if (nf_bridge->owner == skb)
            return nf_bridge;

        /* Otherwise, slow path: find this scratchpad area in the list. */
        ...
        nf_bridge_list = per_cpu_ptr(nf_bridge_pcpu_list);
        list_for_each_entry(n, &nf_bridge_list, head) {
            if (nf_bridge->owner == skb) {
                /* Update the per_cpu cache. */
                rcu_assign_pointer(nf_bridge, n);
                return nf_bridge;
            }
        }

        return NULL;
   }

>From skb_release_head_state() we'll have to:

    if (skb->nf_bridge_present) {
         struct nf_bridge *nf_bridge = nf_bridge_find(skb);

         /* Remove it from the per-cpu nf_bridge cache. */
         list_del(&nf_bridge->head);
         kfree(nf_bridge);
    }

If nfqueue or other situation where we enqueue the packet, we'll enter
the slow path of nf_bridge_find(). This comes with some overhead in
that case, but one of the goal is to get rid of this pointer from
sk_buff which is unused for most people outthere as you already
mentioned on some patch.

I'm proposing this because I have concerns with the approach to place
nf_bridge in skb->cb. This br_netfilter thing makes the skb go back
and forth from different layers while expecting to find the right
right data in it, this seems fragile to me.

What do you think?
