From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: slab corruption with current -git
Date: Thu, 13 Oct 2016 22:32:40 +0100
Message-ID: <20161013213240.GV19539@ZenIV.linux.org.uk>
References: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
 <CA+55aFzcweyWCqq-fRAnJkFB7neKwKsXH=TMcLtRQRs2Wn6XEQ@mail.gmail.com>
 <CA+55aFwhscZcWJVLbq+qUgNaN34VwBxFwUR97ktM-7003PcexQ@mail.gmail.com>
 <20161011.045737.227906000874505402.davem@davemloft.net>
 <20161013060206.GA310@x4>
 <20161013060659.GB310@x4>
 <CA+55aFwsUR4-YmOYgJOOO4a2e48M4_tk7YhAo4s5KZQQxUjpZw@mail.gmail.com>
 <20161013062703.GC310@x4>
 <CA+55aFynWiz1UWwQVvFrRsVvgcYZ=ctCPou9BL1b9_DOVTqKOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
        Christoph Lameter <cl@linux.com>, Jens Axboe <axboe@fb.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Aaron Conole <aconole@redhat.com>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Florian Westphal <fw@strlen.de>, Theodore Ts'o <tytso@mit.edu>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFynWiz1UWwQVvFrRsVvgcYZ=ctCPou9BL1b9_DOVTqKOQ@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 13, 2016 at 12:49:33PM -0700, Linus Torvalds wrote:

> That said, xt_hook_ops_alloc() itself is odd. Lookie here, this is the
> loop that initializes things:
> 
>         for (i = 0, hooknum = 0; i < num_hooks && hook_mask != 0;
>              hook_mask >>= 1, ++hooknum) {
> 
> and it makes no sense to me how that tests *both* "i < num_hools" and
> "hook_mask != 0".
> 
> Why? Because
> 
>     num_hooks = hweight32(hook_mask);
> 
> so it's entirely redundant. num_hooks is already how many bits are on
> in hook_mask, so that test is just duplicating the same thing twice
> ("have we done less than that number of bits" and "do we have any bits
> less").
> 
> I don't know. There's something odd going on. Regardless, thsi is a
> different problem from the nf_register_net_hook() list handling, so
> I'll leave it to the networking people. David?

Hey, I remember looking through that stuff. <checks>  There it is, in
a thread started by Krause Randomness(tm)...  Short version: nf_hook_ops
is a mess - it's embedded into different objects, with different subsets
of fields used depending on the containing object and I would seriously
suggest moving some of those into those containing objects.

--------------------------------------------------------------------------
On Thu, Sep 01, 2016 at 08:10:44AM -0500, Eric Sandeen wrote:
> On 8/4/16 8:57 AM, Al Viro wrote:
> 
> > Don't feed the troll.  On all paths leading to that place we have
> >         result->name = kname;
> >         len = strncpy_from_user(kname, filename, EMBEDDED_NAME_MAX);
> > or
> >                 result->name = kname;
> >                 len = strncpy_from_user(kname, filename, PATH_MAX);
> > with failure exits taken if strncpy_from_user() returns an error, which means
> > that the damn thing has already been copied into.
> > 
> > FWIW, it looks a lot like buggered kmemcheck; as usual, he can't be bothered
> > to mention which kernel version would it be (let alone how to reproduce it
> > on the kernel in question), but IIRC davej had run into some instrumentation
> > breakage lately.
> 
> The original report is in https://bugzilla.kernel.org/show_bug.cgi?id=120651
> if anyone is interested in it.

	What the hell does that one have to getname_flags(), other than having
attracted the same... something on the edge of failing the Turing Test?

	FWIW, looking at the netfilter one...  That's nf_register_net_hook()
hitting
        entry->ops      = *reg;
with reg pointing to something uninitialized (according to kmemcheck, that is,
and presuming that it's not an instrumentation bug).  With the callchain
in report, it came (all in the same assumptions) from
	nf_register_net_hooks(net, ops, hweight32(table->valid_hooks))
with hweight32(table->valid_hooks) being greater than the amount of
initialized entries in ops[] (call site in ipt_register_table()).

	This "ops" ought to be net/ipv4/netfilter/iptable_filter.c:filter_ops,
allocated by
        filter_ops = xt_hook_ops_alloc(&packet_filter, iptable_filter_hook);
in iptable_filter_init().  "table" is &packet_filter and its contents ought
to be unchanged, so ->valid_hooks in there is FILTER_VALID_HOOKS, i.e.
((1 << NF_INET_LOCAL_IN) | (1 << NF_INET_FORWARD) | (1 << NF_INET_LOCAL_OUT)).

	Which is to say, filter_ops[] had fewer than 3 initialized elements
when it got to the call of iptable_filter_table_init()...  Since filter_ops
hadn't been NULL, the xt_hook_ops_alloc() call above must've already been
done.  Said xt_hook_ops_alloc() should've allocated a 3-element array and
hooked through all of it, so it's not a wholesale uninitialized element, it's
uninitialized parts of one...

	What gets initialized is ->hook, ->pf, ->hooknum and ->priority.
Let's figure out the offsets:
	0: list (two pointers, i.e. 16 bytes)
	0x10: hook (8)
	0x18: dev (8)
	0x20: priv (8)
	0x28: pf (1)
	0x29: padding (3)
	0x2c: hooknum (4)
	0x30: priority (4)
	0x34: padding (8)
	
OK...  The address of the damn thing is apparently ffff880037b4bd80 and
we see complaint about the accesses at offsets 0, 0x18, 8, 0x20 and then
the same pattern with 0x38 and 0x70 added (i.e. the same fields in the next
two elements of the same array).  Then there are similar complaints, but
with a different call chain (iptable_mangle instead of iptable_filter).

These offsets are ->list, ->dev and ->priv, and those are exactly the ones
not initialized by xt_hook_ops_alloc().  Looking at the nf_register_net_hook(),
we have
        list_add_rcu(&entry->ops.list, elem->list.prev);
a bit further down the road.  ->dev and ->priv are left uninitialized (and
very likely - unused).

I would say it's a false positive.  struct nf_hook_ops is embedded into a
bunch of different objects, with different subsets of fields getting used.
IMO it's a bad idea (in particular, I really wonder if ->list would've
been better off moved into (some of) the containing suckers), but it's
not a bug per se, just a design choice asking for trouble.  One way of
getting kmemcheck off your back would be to switch xt_hook_ops_alloc() from
	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
to
	ops = kcalloc(num_hooks, sizeof(*ops), GFP_KERNEL);
which might have some merits beyond making kmemcheck STFU...
--------------------------------------------------------------------------
